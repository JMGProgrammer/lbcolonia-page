-- ============================================================================
-- Migration 0007: Alta rápida atómica de jugador + ficha (IT5)
--
-- Evita que el cliente cree primero un jugador y deje un registro huérfano si
-- luego falla la ficha. El delegado solo puede solicitar fichas para un equipo
-- de SU club; nunca para el rival. Jugador y ficha se crean en una transacción.
-- ============================================================================

-- La creación directa se reemplaza por la RPC acotada de abajo.
drop policy if exists jugadores_delegado_crear on jugadores;

create or replace function public.solicitar_ficha_jugador(
  _equipo_id uuid,
  _torneo_id uuid,
  _nombre_completo text,
  _fecha_nacimiento date default null,
  _dorsal int default null
) returns table (jugador_id uuid, ficha_id uuid)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_org_id uuid;
  v_jugador_id uuid;
  v_ficha_id uuid;
begin
  if btrim(coalesce(_nombre_completo, '')) = '' then
    raise exception 'el nombre completo es obligatorio';
  end if;

  if _dorsal is not null and _dorsal < 0 then
    raise exception 'el dorsal no puede ser negativo';
  end if;

  select e.org_id
    into v_org_id
    from equipos e
    join torneos t
      on t.id = _torneo_id
     and t.org_id = e.org_id
     and t.categoria_id = e.categoria_id
   where e.id = _equipo_id
     and e.activo = true;

  if v_org_id is null
     or v_org_id is distinct from org_activa_id()
     or not es_delegado_de_equipo(_equipo_id) then
    raise exception 'solo puede solicitar fichas para un equipo de su club';
  end if;

  insert into jugadores (org_id, nombre_completo, fecha_nacimiento)
  values (v_org_id, btrim(_nombre_completo), _fecha_nacimiento)
  returning id into v_jugador_id;

  insert into fichas (
    org_id, jugador_id, equipo_id, torneo_id, dorsal, estado, desde
  ) values (
    v_org_id, v_jugador_id, _equipo_id, _torneo_id, _dorsal,
    'solicitada', current_date
  )
  returning id into v_ficha_id;

  return query select v_jugador_id, v_ficha_id;
end $$;

revoke all on function public.solicitar_ficha_jugador(uuid, uuid, text, date, int) from public;
grant execute on function public.solicitar_ficha_jugador(uuid, uuid, text, date, int) to authenticated;
