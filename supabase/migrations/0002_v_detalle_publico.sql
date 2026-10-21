-- 0002 · v_detalle_publico: datos por jugador para la ficha de partido (Docs/04 §1).
-- La política stats_anon_leer ya limita qué planillas son públicas, pero anon no puede
-- resolver planilla → partido (las planillas son invisibles para anon). Esta view
-- (semántica definer, patrón decidido y documentado: la barrera real es el WHERE)
-- expone solo las líneas de una planilla verificada de un partido publicado.
create or replace view v_detalle_publico as
select
  pa.id as partido_id,
  pa.org_id,
  pa.torneo_id,
  ps.id as stat_id,
  ps.ficha_id,
  ps.dorsal,
  ps.puntos,
  ps.rebotes,
  ps.asistencias,
  ps.robos,
  ps.tapas,
  ps.faltas,
  ps.minutos,
  f.equipo_id,
  f.jugador_id,
  j.nombre_completo
from planillas pl
join partidos pa on pa.id = pl.partido_id
join planilla_stats ps on ps.planilla_id = pl.id
join fichas f on f.id = ps.ficha_id
join jugadores j on j.id = f.jugador_id
where pl.estado = 'verificada'
  and pa.publicado;

grant select on v_detalle_publico to anon, authenticated;
