-- 0003_audit_log.sql
-- Auditoría de operaciones del panel (Docs/05 §4)
-- Registro de publicaciones, cambios de resultados y operaciones de organizadores.

create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id uuid not null references public.orgs (id) on delete cascade,
  user_id uuid references auth.users (id) on delete set null,
  tabla text not null,
  fila_id uuid not null,
  accion text not null,
  antes jsonb,
  despues jsonb
);

create index audit_log_org_fecha on public.audit_log (org_id, created_at desc);
create index audit_log_fila on public.audit_log (tabla, fila_id);

alter table public.audit_log enable row level security;

-- Solo liga_admin de la org (o superadmin) puede leer la auditoría (Docs/05 §4: solo lectura para liga_admin)
create policy audit_log_liga_admin_leer on public.audit_log
  for select to authenticated
  using (es_liga_admin(org_id));

-- Inserción permitida para organizadores de la org (liga_admin y liga_ayudante)
create policy audit_log_liga_insertar on public.audit_log
  for insert to authenticated
  with check (es_organizador(org_id));

-- Trigger de auditoría para cambios sensibles en partidos (Docs/05 §4)
create or replace function public.partidos_audit_trigger() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_accion text;
  v_user_id uuid;
begin
  v_user_id := auth.uid();

  if (tg_op = 'UPDATE') then
    if new.publicado and not old.publicado then
      v_accion := 'publicar';
    elsif not new.publicado and old.publicado then
      v_accion := 'despublicar';
    elsif (new.puntos_local is distinct from old.puntos_local) or (new.puntos_visitante is distinct from old.puntos_visitante) then
      v_accion := 'editar_resultado';
    else
      v_accion := 'actualizar_partido';
    end if;

    insert into public.audit_log (org_id, user_id, tabla, fila_id, accion, antes, despues)
    values (
      new.org_id,
      v_user_id,
      'partidos',
      new.id,
      v_accion,
      to_jsonb(old),
      to_jsonb(new)
    );
    return new;
  elsif (tg_op = 'INSERT') then
    insert into public.audit_log (org_id, user_id, tabla, fila_id, accion, antes, despues)
    values (
      new.org_id,
      v_user_id,
      'partidos',
      new.id,
      'crear_partido',
      null,
      to_jsonb(new)
    );
    return new;
  end if;
  return null;
end $$;

create trigger partidos_audit_cambios
  after insert or update of publicado, puntos_local, puntos_visitante, estado, fecha_hora, sede
  on public.partidos
  for each row execute function public.partidos_audit_trigger();
