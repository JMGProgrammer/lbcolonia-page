-- ============================================================================
-- Migration 0005: Perfiles de jugador y estadísticas avanzadas
-- Docs/13: columnas bio en jugadores, columnas opcionales de tiro en planilla_stats,
-- views definer públicas v_jugadores_publico, v_jugador_partidos_log, v_jugador_totales_temporada.
-- ============================================================================

-- 1. Columnas bio en jugadores
alter table public.jugadores add column if not exists posicion text;
alter table public.jugadores add column if not exists altura_cm int;
alter table public.jugadores add column if not exists mano_habil text;
alter table public.jugadores add column if not exists slug text;
alter table public.jugadores add column if not exists ciudad_origen text;

-- Generar slugs iniciales basados en nombre
update public.jugadores
set slug = lower(regexp_replace(nombre_completo, '[^a-zA-Z0-9]+', '-', 'g'))
where slug is null or slug = '';

-- Crear índice para slug
create index if not exists idx_jugadores_slug on public.jugadores (org_id, slug);

-- 2. Columnas opcionales para tiros avanzados en planilla_stats
alter table public.planilla_stats add column if not exists tc_intentados int;
alter table public.planilla_stats add column if not exists tc_convertidos int;
alter table public.planilla_stats add column if not exists t3_intentados int;
alter table public.planilla_stats add column if not exists t3_convertidos int;
alter table public.planilla_stats add column if not exists tl_intentados int;
alter table public.planilla_stats add column if not exists tl_convertidos int;

-- 3. View definer pública: datos bio y club de los jugadores
create or replace view public.v_jugadores_publico as
select distinct on (j.id)
  j.id as jugador_id,
  j.org_id,
  j.nombre_completo,
  j.fecha_nacimiento,
  j.foto_url,
  j.posicion,
  j.altura_cm,
  j.mano_habil,
  coalesce(j.slug, j.id::text) as slug,
  j.ciudad_origen,
  f.dorsal,
  f.equipo_id,
  f.torneo_id,
  c.id as club_id,
  c.nombre as club_nombre,
  c.slug as club_slug,
  cat.nombre as categoria_nombre
from public.jugadores j
left join public.fichas f on f.jugador_id = j.id and f.estado = 'confirmada'
left join public.equipos eq on eq.id = f.equipo_id
left join public.clubes c on c.id = eq.club_id
left join public.categorias cat on cat.id = eq.categoria_id
order by j.id, f.desde desc nulls last;

grant select on public.v_jugadores_publico to anon, authenticated;

-- 4. View definer pública: log de partidos jugados por jugador
create or replace view public.v_jugador_partidos_log as
select
  pa.id as partido_id,
  pa.org_id,
  pa.torneo_id,
  t.nombre as torneo_nombre,
  pa.fecha_hora,
  pa.ronda,
  pa.sede,
  pa.puntos_local,
  pa.puntos_visitante,
  pa.estado as partido_estado,
  j.id as jugador_id,
  j.nombre_completo,
  coalesce(j.slug, j.id::text) as jugador_slug,
  ps.dorsal,
  ps.minutos,
  ps.puntos,
  ps.rebotes,
  ps.asistencias,
  ps.robos,
  ps.tapas,
  ps.faltas,
  ps.tc_intentados,
  ps.tc_convertidos,
  ps.t3_intentados,
  ps.t3_convertidos,
  ps.tl_intentados,
  ps.tl_convertidos,
  f.equipo_id,
  eq_propio.club_id as mi_club_id,
  c_propio.nombre as mi_club_nombre,
  c_propio.slug as mi_club_slug,
  case when pa.equipo_local_id = f.equipo_id then true else false end as es_local,
  case when pa.equipo_local_id = f.equipo_id then pa.equipo_visitante_id else pa.equipo_local_id end as rival_equipo_id,
  case when pa.equipo_local_id = f.equipo_id then c_vis.nombre else c_loc.nombre end as rival_nombre,
  case when pa.equipo_local_id = f.equipo_id then c_vis.slug else c_loc.slug end as rival_slug,
  case
    when pa.puntos_local is null or pa.puntos_visitante is null then null
    when pa.equipo_local_id = f.equipo_id and pa.puntos_local > pa.puntos_visitante then 'W'
    when pa.equipo_visitante_id = f.equipo_id and pa.puntos_visitante > pa.puntos_local then 'W'
    when pa.puntos_local = pa.puntos_visitante then 'D'
    else 'L'
  end as resultado
from public.planillas pl
join public.partidos pa on pa.id = pl.partido_id
join public.torneos t on t.id = pa.torneo_id
join public.planilla_stats ps on ps.planilla_id = pl.id
join public.fichas f on f.id = ps.ficha_id
join public.jugadores j on j.id = f.jugador_id
join public.equipos eq_propio on eq_propio.id = f.equipo_id
join public.clubes c_propio on c_propio.id = eq_propio.club_id
join public.equipos eq_loc on eq_loc.id = pa.equipo_local_id
join public.clubes c_loc on c_loc.id = eq_loc.club_id
join public.equipos eq_vis on eq_vis.id = pa.equipo_visitante_id
join public.clubes c_vis on c_vis.id = eq_vis.club_id
where pl.estado = 'verificada'
  and pa.publicado;

grant select on public.v_jugador_partidos_log to anon, authenticated;

-- 5. View definer pública: totales y promedios por jugador
create or replace view public.v_jugador_totales_temporada as
select
  j.id as jugador_id,
  j.org_id,
  t.id as torneo_id,
  t.nombre as torneo_nombre,
  c_propio.id as club_id,
  c_propio.nombre as club_nombre,
  c_propio.slug as club_slug,
  count(distinct pa.id) as pj,
  coalesce(sum(ps.puntos), 0) as puntos_totales,
  round(coalesce(avg(ps.puntos), 0), 1) as ppg,
  coalesce(sum(ps.rebotes), 0) as rebotes_totales,
  round(coalesce(avg(ps.rebotes), 0), 1) as rpg,
  coalesce(sum(ps.asistencias), 0) as asistencias_totales,
  round(coalesce(avg(ps.asistencias), 0), 1) as apg,
  coalesce(sum(ps.robos), 0) as robos_totales,
  round(coalesce(avg(ps.robos), 0), 1) as spg,
  coalesce(sum(ps.tapas), 0) as tapas_totales,
  round(coalesce(avg(ps.tapas), 0), 1) as bpg,
  coalesce(sum(ps.faltas), 0) as faltas_totales,
  round(coalesce(avg(ps.faltas), 0), 1) as fpg,
  coalesce(max(ps.puntos), 0) as max_puntos,
  coalesce(max(ps.rebotes), 0) as max_rebotes,
  coalesce(max(ps.asistencias), 0) as max_asistencias
from public.planillas pl
join public.partidos pa on pa.id = pl.partido_id
join public.torneos t on t.id = pa.torneo_id
join public.planilla_stats ps on ps.planilla_id = pl.id
join public.fichas f on f.id = ps.ficha_id
join public.jugadores j on j.id = f.jugador_id
join public.equipos eq_propio on eq_propio.id = f.equipo_id
join public.clubes c_propio on c_propio.id = eq_propio.club_id
where pl.estado = 'verificada'
  and pa.publicado
group by j.id, j.org_id, t.id, t.nombre, c_propio.id, c_propio.nombre, c_propio.slug;

grant select on public.v_jugador_totales_temporada to anon, authenticated;
