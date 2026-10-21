-- ============================================================================
-- Migration 0004: Permisos completos de gestión de fichas para la secretaría de la Liga
-- Docs/05 §1A & Docs/03 §3: secretaría (liga_admin / liga_ayudante) puede crear,
-- editar, confirmar y dar de baja fichas directamente en la organización.
-- ============================================================================

drop policy if exists fichas_liga on fichas;

create policy fichas_liga on fichas
  for all to authenticated
  using (es_organizador(org_id))
  with check (es_organizador(org_id));
