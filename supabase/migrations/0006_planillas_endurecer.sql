-- ============================================================================
-- Migration 0006: Endurecimiento del circuito de planillas (IT5)
-- Docs/05 §1B y Docs/06 §1:
--   · la disputa exige motivo obligatorio (no alcanza con el botón)
--   · la planilla verificada exige la foto del papel (la verificación se hace
--     contra el papel, no de memoria)
--   · el delegado solo puede firmar la planilla como cargador a sí mismo
--   · el delegado puede dar de alta jugadores nuevos para su club (ficha
--     'solicitada'; la liga la confirma después)
-- ============================================================================

-- 1. Disputa con motivo obligatorio -----------------------------------------
create or replace function public.planillas_disputa_exige_motivo() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.estado = 'disputada' and old.estado is distinct from 'disputada' then
    if new.motivo_disputa is null or btrim(new.motivo_disputa) = '' then
      raise exception 'la disputa requiere un motivo';
    end if;
  end if;
  return new;
end $$;

create trigger planillas_disputa_exige_motivo
  before update on planillas
  for each row execute function public.planillas_disputa_exige_motivo();

-- 2. Verificación con foto obligatoria --------------------------------------
create or replace function public.planillas_verificada_exige_foto() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.estado = 'verificada' and old.estado is distinct from 'verificada' then
    if new.foto_url is null or btrim(new.foto_url) = '' then
      raise exception 'la planilla verificada requiere la foto del papel';
    end if;
  end if;
  return new;
end $$;

create trigger planillas_verificada_exige_foto
  before update on planillas
  for each row execute function public.planillas_verificada_exige_foto();

-- 3. El delegado firma como cargador únicamente a sí mismo -------------------
-- (la policy anterior no controlaba la columna cargada_por)
drop policy if exists planillas_delegado_cargar on planillas;
create policy planillas_delegado_cargar on planillas
  for insert to authenticated
  with check (
    estado = 'borrador'
    and cargada_por = auth.uid()
    and es_delegado_local(partido_id)
  );

-- 4. Alta rápida de jugadores por el delegado de un club ---------------------
-- La ficha nace 'solicitada'; la confirmación es exclusiva de la liga.
create policy jugadores_delegado_crear on jugadores
  for insert to authenticated
  with check (
    org_id = org_activa_id()
    and mi_club_de(org_id) is not null
  );
