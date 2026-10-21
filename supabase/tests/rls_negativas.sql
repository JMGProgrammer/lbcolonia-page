-- ============================================================================
-- RLS: test de las 6 negativas (Docs/03 §5, checklist en Docs/10 §5)
-- A ejecutar en el SQL Editor de Supabase Studio (o psql contra el proyecto)
-- CON EL SEED CARGADO. Cada prueba imprime el resultado esperado al lado.
-- Si algo no calza, el título de la prueba dice qué debe haber y cuánto.
-- ============================================================================

-- ---------- 0. Sanity: la org activa existe
select 'SANITY org activa' as prueba, valor as resultado from app_config where clave = 'org_activa';
-- esperado: la uuid de la org LBC

-- ---------- 1. anon no ve planillas (ni una fila)
begin;
select set_config('role', 'anon', true);
select 'NEG-1 · anon lee planillas → esperado 0' as prueba, count(*) as filas from planillas;
rollback;

-- ---------- 2. delegado de Plaza no ve la planilla disputada (partido de otros clubes)
-- (de la misma org: solo ve las de partidos donde su club es local o visitante)
begin;
select set_config('role', 'authenticated', true);
select set_config('request.jwt.claims',
  '{"role":"authenticated","sub":"00000000-0000-0000-0000-0000000000b1"}', true);
  -- sub = delegado.plaza@demo.lbc.uy (seed)
select 'NEG-2 · delegado Plaza lee planilla en disputa → esperado 0' as prueba,
       count(*) as filas from planillas where estado = 'disputada';
rollback;

-- ---------- 3. delegado intenta cambiar un resultado → 0 filas
begin;
select set_config('role', 'authenticated', true);
select set_config('request.jwt.claims',
  '{"role":"authenticated","sub":"00000000-0000-0000-0000-0000000000b1"}', true);
update partidos
  set puntos_local = 999
  where torneo_id = (select id from torneos where nombre = 'Primera División 2026')
    and ronda = '2';
-- esperado: 0 filas (la policy niega la fila; PostgREST call también)
rollback;

-- ---------- 4. delegado intenta publicar → 0 filas
begin;
select set_config('role', 'authenticated', true);
select set_config('request.jwt.claims',
  '{"role":"authenticated","sub":"00000000-0000-0000-0000-0000000000b4"}', true);
  -- sub = delegado.juventud@demo.lbc.uy (seed)
update partidos
  set publicado = true, publicado_at = now()
  where torneo_id = (select id from torneos where nombre = 'Primera División 2026')
    and ronda = '2' and estado = 'programado';
-- esperado: 0 filas
rollback;

-- ---------- 5. ayudante intenta tocar auspiciantes → 0 filas
begin;
select set_config('role', 'authenticated', true);
select set_config('request.jwt.claims',
  '{"role":"authenticated","sub":"00000000-0000-0000-0000-0000000000a3"}', true);
  -- sub = ayudante@demo.lbc.uy (seed)
update auspiciantes set nombre = 'Prueba ayudante' where activo = false;
-- esperado: 0 filas (los auspiciantes son solo de liga_admin)
rollback;

-- ---------- 6. dominio de otra org: el anon NO ve nada de la org que no es la activa
begin;
-- segunda org de prueba (como si fuera otra liga en la plataforma)
insert into orgs (id, slug, nombre, plan)
values ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'liga-otra', 'Otra Liga [demo]', 'licencia');
update app_config set valor = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'
  where clave = 'org_activa';

select set_config('role', 'anon', true);
select 'NEG-6 · anon con dominio de otra org ve noticias LBC → esperado 0' as prueba,
       count(*) as filas
  from noticias n
  where n.org_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- restaurar
update app_config set valor = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' where clave = 'org_activa';
delete from orgs where id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';
rollback;

-- ============================================================================
-- Positivos rápidos (qué DEBE verse para el hincha):
-- ============================================================================
begin;
select set_config('role', 'anon', true);
-- partidos publicados visibles: la fecha 1 de primera + el walkover Sub-15
select 'POS-1 · anon ve partidos publicados → esperado 2' as prueba,
       count(*) as filas from partidos where publicado;
-- fixture programado visible: 10 de fechas 2-6 + el 21:00 de la fecha 1 + 1 Sub-15
select 'POS-2 · anon ve el fixture programado → esperado 12' as prueba,
       count(*) as filas from partidos where estado = 'programado';
-- tabla calculada de la primera: Plaza 1º
select 'POS-3 · tabla de la Primera (v_tabla)' as prueba,
       pon.pos, pon.equipo, pon.pts, pon.dif
  from (select row_number() over (order by pts desc, dif desc) as pos, equipo, pts, dif
          from v_tabla where torneo_id = (select id from torneos where nombre = 'Primera División 2026')
       ) pon;
-- esperado: 2 filas (solo publicó la fecha 1): Plaza (V, 2 pts, +8) y Juventud (D, 1 pt, −8);
-- Estudiantes y Rowing aún sin puntos (su partido quedó en disputa, no publicado)
rollback;
