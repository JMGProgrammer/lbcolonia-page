# 02 · Modelo de datos

Última actualización: 2026-10-21

Este doc es la especificación de `supabase/migrations/0001`. Toda tabla de contenido lleva `org_id` (multi-liga desde el día 1, `Docs/07`). Postgres sobre Supabase, UUID v4 para id (`gen_random_uuid()`), `created_at` en todas.

Leyenda de estados con este marcador: **[a confirmar con la liga]**.

## 0. Princípios

1. **RLS primero**: ninguna regla de visibilidad vive en la aplicación (`Docs/03` tiene las policies).
2. **La tabla de posiciones no es una tabla**: es una **view SQL** calculada desde partidos `finalizado`. Nunca se persisten posiciones ni se calculan en JS.
3. **Estadísticas al nivel que aguanta el delegado**: el flag `estadisticas_detalladas` del torneo define cuántas columnas se piden.
4. Todo lo editable por la liga es texto simple; nada de wysiwyg complejo en MVP (markdown con preview).

## 1. Organizaciones y personas

### `orgs` — las ligas (tenants)
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid pk | |
| slug | text uniq | subdominio/fallback de URL |
| nombre | text | "Liga de Basquetbol de Colonia" |
| logo_url | text | Storage |
| color_primario / color_secundario | text | branding del sitio |
| dominio_custom | text null | ligadelbasquetcolonia.com.uy, fase multiliga |
| plan | enum plan | `piloto` \| `licencia` \| `suspendido` |
| config_json | jsonb | página home configurable, enlaces redes, flags |
| licencia_hasta | date null | control de vencimiento comercial |

### `profiles` — espejo de `auth.users`
(id = user id, nombre, foto opcional, `is_superadmin bool` — el rol global de Juan).
Se crea con trigger `on_auth_user_created`.

### `org_members` — vinculación persona×org×rol
| Columna | Notas |
|---|---|
| org_id, user_id | pk compuesta |
| rol | enum: `liga_admin` \| `liga_ayudante` \| `delegado` |
| club_id | uuid null — obligatorio si rol es `delegado` (su club) |

Un mismo usuario puede ser delegado en una org y liga_admin en otra. La sesión resuelve rol por org (el sitio actual fija una sola org por dominio).

## 2. Competencia

### `categorias`
`id, org_id, nombre (Primera / Sub-14 / Amateur…), acronimo, orden, es_formativa bool, activa bool`. Los nombres reales de las categorías del torneo de Colonia **[a confirmar con la liga]** (supuesto del seed: `Primera`, `Sub-18`, `Sub-16`, `Sub-14`, `Amateur`).

### `torneos`
| Columna | Notas |
|---|---|
| id, org_id, categoria_id | |
| temporada | año (ej 2026); permite históricos por año |
| nombre | "Torneo Apertura 2026" |
| formato | enum: `liga` \| `liga_playoffs` \| `torneo` |
| estado | enum: `proximo` \| `en_curso` \| `finalizado` |
| reglas_json | ver abajo |
| estadisticas_detalladas | bool — si el torneo pide reb/asist/tapas (primera ⇒ sí; amateur/formativas bajas ⇒ opcional) |

**`reglas_json`** (defaults FIBA, mandable por reglamento):
```json
{
  "puntos_victoria": 2,
  "puntos_derrota": 1,
  "puntos_victoria_walkover": 1,
  "puntos_derrota_walkover": 0,
  "score_walkover": "20-0",
  "tiebreakers": ["matchup_individual", "dif_puntos", "puntos_favor"]
}
```
Sistema de puntos reales usado por la liga de Colonia en cada competencia **[a confirmar con la liga]**.

### `clubes`
`id, org_id, nombre, slug, escudo_url, color1, color2, gimnasio, redes_json (insta/fb/whatsapp), activo bool`. El `slug` arma la URL pública /clubes/{slug}.

### `equipos`
`id, org_id, club_id, categoria_id, nombre_mostrar (default "CLUB - Cat"), activo bool`. Un club tiene 1 equipo por categoría. Los partidos refieren a equipos; el roster se arma por equipo.

### `jugadores`
`id, org_id, nombre_completo, fecha_nacimiento, foto_url null, notas null`. Un jugador es una persona org-scoped; puede estar en varios equipos vía fichas (mismo chico en Sub-16 y en Amateur). Control de duplicados: índice por `(lower(nombre_completo), fecha_nacimiento)` + aviso en el panel al crear uno casi idéntico.

### `fichas` (roster histórico por torneo)
`id, org_id, jugador_id, equipo_id, torneo_id, dorsal int, estado enum [solicitada | confirmada | baja], desde date, hasta date null`.

Flujo de ficha: el delegado propone (`solicitada`) porque una ficha federada requiere papeles; la liga la confirma → `confirmada`. Fecha de corte de fichas por torneo **[a confirmar con la liga]**.

## 3. Partidos y planillas

### `partidos`
| Columna | Notas |
|---|---|
| id, org_id, torneo_id | |
| ronda | text — `1`..`N` (jornada) o etiqueta playoff (`Semifinal IDA`) |
| fecha_hora | timestamptz — siempre con TZ `America/Montevideo` |
| sede | texto/gimnasio (fk blanda a `clubes.gimnasio` por ahora) |
| equipo_local_id, equipo_visitante_id | fks a equipos |
| estado | enum: `programado` \| `en_juego` (futuro live) \| `finalizado` \| `postergado` \| `suspendido` \| `walkover` |
| puntos_local, puntos_visitante | int null |
| cuartos_local / cuartos_visitante | ints null — se piden si la liga quiere (config por torneo) |
| walkover_ganador_id | uuid null |
| nota_publica | text — "Postergado por lluvia", motivo de walkover |
| publicado | bool — la liga lo marca al verificar |
| publicado_at | timestamptz |

`programado` ya es visible al público (así se ve el fixture), pero sin resultado ni stats. `finalizado` sin `publicado` = cargado por delegado, pendiente de verificación de la liga.

### `planillas` — una por partido
Decisión (2026-10-21): **la planilla es única por partido y la levanta el club local** (quien tiene el papel firmado). El visitante la revisa y puede disputar.

| Columna | Notas |
|---|---|
| id, org_id, partido_id | uniq(partido_id) |
| estado | enum: `borrador` \| `disputada` \| `verificada` \| `anulada` (esta última solo la liga) |
| foto_url | Storage privado `planillas/{org}/{partido}` |
| cargada_por | user id (delegado) |
| disputada_por_club | uuid null |
| motivo_disputa | text null |
| verificada_por, verificada_at | liga |

### `planilla_stats` — líneas por jugador
| Columna | Notas |
|---|---|
| id, planilla_id, ficha_id | fk a ficha (el jugador por ese torneo/equipo) |
| dorsal | int — redundante con la ficha: agiliza la carga |
| minutos | int null — solo si el torneo lo pide |
| puntos, faltas | int (siempre se piden) |
| rebotes, asistencias, tapas, robos | int null — solo si `estadisticas_detalladas` |

Reglas: una fila de `planilla_stats` es válida solo si su `ficha_id` pertenece a uno de los dos equipos del partido. `faltas = 5` marca eventual descalificación (se muestra en el detalle del partido).
**[a confirmar con la liga: si se piden triples por jugador en primera]** (bajo costo: una columna más condicionada).

## 4. Standings y estadísticas — views SQL

### `v_tabla` — una sola view genérica, filtrable por torneo (esbozo)
```sql
create view v_tabla as
select
  e.id                                                  as equipo_id,
  p.torneo_id                                           as torneo_id,
  count(*)                                              as pj,
  sum(case when ganador(p, e.id) then 1 else 0 end)     as pg,
  sum(case when perdedor(p, e.id) then 1 else 0 end)    as pp,
  sum(puntos_favor(p, e.id))                            as gf,
  sum(puntos_contra(p, e.id))                           as gc
from equipos e
join partidos p on e.id in (p.equipo_local_id, p.equipo_visitante_id)
where p.publicado and p.estado in ('finalizado','walkover')
group by e.id, p.torneo_id;
```
Luego PTS = `puntos_victoria·PG + puntos_derrota·PP` (+ regla de walkover según `reglas_json`). El orden final (tie-breakers) se lee del `reglas_json` del torneo.

### `v_lideres` — goleadores/asistidores/tapera
Por torneo: suma de `puntos/reb/asis` agrupado por jugador (a través de `fichas`), con mín. de partidos **[a confirmar]**. Los "tops" se exponen paginados.

### `v_sanciones_activas`
Sanciones en vigor con los partidos pendientes de cumple (ver `Docs/06`).

## 5. Contenido editorial

### `noticias`
`id, org_id, slug (uniq per org), titulo, bajada, cuerpo_md, portada_url, destacado bool, publicado bool, publicado_at, etiquetas text[]`.
El cuerpo es markdown con preview en el panel. Imágenes inline subidas al bucket `noticias`.

### `auspiciantes`
`id, org_id, nombre, logo_url, link, nivel enum [oro|plata|bronce|colaborador], activo bool, orden int, vigencia_hasta date`.
La home y el footer leen por nivel; la liga ordena y activa/desactiva desde el panel. Sin reportes de clics en MVP.

### `paginas` — contenido estático editable
`id, org_id, slug, titulo, cuerpo_md, publicado bool` → /liga, /reglamento, /precios-entrada, /contacto (texto editable, no código).

## 6. Índices y más SQL

- `partidos(torneo_id, fecha_hora)` y `(equipo_local_id)` / `(equipo_visitante_id)`.
- `fichas(jugador_id, torneo_id)` index; `planillas(partido_id)` unique.
- `noticias(org_id, publicado_at desc)`.
- Triggers: `updated_at`, creación de `profile` al alta de usuario, y **publicación de partido** (en Fase 4) que dispara revalidate del front + re-cálculo de vistas (views son dinámicas, no requieren refresco).
- Convención de migraciones: 0001 con todo el esquema + seed separado. Cambios posteriores: 0002 en adelante; nunca volver a editar migraciones ya aplicadas.

## 7. Preguntas para la secretaría (chequeo pre-0001)

Resueltas con el material oficial (afiches):

- ✅ Primera División 2026: 4 clubes (Plaza Colonia, Colonia Rowing, Estudiantes El Colla, Juventud), ida y vuelta, 6 fechas, sábados 19:00/21:00, club anfitrión por fecha. El fixture completo está en el afiche (`assets/images/afiche-1era-lbc-fixture.jpg`) — puede sembrarse tal cual en el seed de la Fase 1.

Pendientes **[a confirmar con la liga]**:

1. Nombres y cortes exactos de las categorías formativas (¿U-14/U-16/U-18? ¿por año calendario hasta cuándo?) y qué clubes juegan cada una.
2. ¿Hay playoffs tras la fase regular de primera? (el afiche dice "Fase Regular"; asumo sí hasta confirmar)
3. Sistema de puntos de tabla por competencia (¿2/1 FIBA con derrota por walkover 0?)
4. ¿Se piden cuartos/parciales en la planilla? ¿Triples por jugador?
5. Mínimos para líderes (¿PJ mínimos?)
6. Nombres de gimnasios/sedes exactos por club (el anfitrión por fecha ya lo da el fixture; falta el nombre del gimnasio) y contactos reales de delegados para las cuentas del piloto.
