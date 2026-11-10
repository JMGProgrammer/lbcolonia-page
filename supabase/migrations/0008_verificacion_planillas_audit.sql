-- ============================================================================
-- Migration 0008: Verificación y resolución de planillas (IT5 sesión 2)
-- Docs/05 §1A/§4 y Docs/06 §1:
--   · resolución documentada de disputas
--   · auditoría de cada corrección de estadísticas y cambio de planilla
-- ============================================================================

alter table public.planillas
  add column if not exists resolucion_disputa text,
  add column if not exists resuelta_por uuid references public.profiles (id) on delete set null,
  add column if not exists resuelta_at timestamptz;

-- Al salir de una disputa se sella quién y cuándo. Anular exige explicación.
create or replace function public.planillas_guard_resolucion() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.estado = 'disputada' and new.estado is distinct from 'disputada' then
    if new.estado = 'anulada'
       and (new.resolucion_disputa is null or btrim(new.resolucion_disputa) = '') then
      raise exception 'anular una planilla disputada requiere una nota de resolución';
    end if;
    new.resuelta_por = auth.uid();
    new.resuelta_at = now();
  end if;
  return new;
end $$;

create trigger planillas_guard_resolucion
  before update on public.planillas
  for each row execute function public.planillas_guard_resolucion();

-- Auditoría de estado, verificación y resolución de la planilla.
create or replace function public.planillas_audit_trigger() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_accion text;
begin
  if new.estado = 'verificada' and old.estado is distinct from 'verificada' then
    v_accion := 'verificar_planilla';
  elsif new.estado = 'anulada' and old.estado is distinct from 'anulada' then
    v_accion := 'anular_planilla';
  elsif old.estado = 'disputada' and new.estado = 'borrador' then
    v_accion := 'resolver_disputa_aceptar';
  elsif new.estado = 'disputada' and old.estado is distinct from 'disputada' then
    v_accion := 'disputar_planilla';
  else
    v_accion := 'actualizar_planilla';
  end if;

  insert into public.audit_log (
    org_id, user_id, tabla, fila_id, accion, antes, despues
  ) values (
    new.org_id, auth.uid(), 'planillas', new.id, v_accion,
    to_jsonb(old), to_jsonb(new)
  );
  return new;
end $$;

create trigger planillas_audit_cambios
  after update of estado, foto_url, motivo_disputa, resolucion_disputa,
                  verificada_por, verificada_at
  on public.planillas
  for each row execute function public.planillas_audit_trigger();

-- Auditoría granular de las correcciones de la liga en el boxscore.
create or replace function public.planilla_stats_audit_trigger() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_fila public.planilla_stats;
  v_org_id uuid;
begin
  v_fila := case when tg_op = 'DELETE' then old else new end;
  v_org_id := v_fila.org_id;

  insert into public.audit_log (
    org_id, user_id, tabla, fila_id, accion, antes, despues
  ) values (
    v_org_id,
    auth.uid(),
    'planilla_stats',
    v_fila.id,
    case tg_op
      when 'INSERT' then 'agregar_linea_planilla'
      when 'UPDATE' then 'corregir_linea_planilla'
      else 'eliminar_linea_planilla'
    end,
    case when tg_op = 'INSERT' then null else to_jsonb(old) end,
    case when tg_op = 'DELETE' then null else to_jsonb(new) end
  );

  return case when tg_op = 'DELETE' then old else new end;
end $$;

create trigger planilla_stats_audit_cambios
  after insert or update or delete on public.planilla_stats
  for each row execute function public.planilla_stats_audit_trigger();
