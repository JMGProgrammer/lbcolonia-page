# 04 · Sitio público

Última actualización: 2026-10-21

Mobile-first: el 95% de la audiencia entra desde el celular, la mayoría de noche del sábado. Regla táctil: texto base ≥ 15px, botones ≥ 44px de toque, sin zoom horizontal a 320px.

## 1. Mapa de rutas

| Ruta | Contenido | Origen de datos |
|---|---|---|
| `/` | Hero con logo de la liga + `próximos partidos del fin de semana` + `últimos resultados` + tabla compacta de primera + noticia destacada + auspiciantes | views + queries `destacado` |
| `/fixture/{torneo}` | Agenda completa del torneo, residente por jornada/ronda con filtro por club (island alpine) | `partidos` |
| `/tabla/{torneo}` | Tabla de posiciones completa | `v_tabla` |
| `/estadisticas/{torneo}` | Goleadores / rebotes / asistencias, paginados | `v_lideres` |
| `/partidos/{id}` | Ficha del partido: marcador, parciales si hay, jugadores con stats, foto de planilla pública (solo con resolución de la liga) | `partidos` + `v_detalle_publico` |
| `/playoffs/{torneo}` | Bracket con series (si `formato = liga_playoffs`) | series/bracket |
| `/sanciones` | Activas por competencia + históricas | `v_sanciones_activas` |
| `/clubes` | Grilla de clubes con escudos | `clubes` |
| `/clubes/{slug}` | Ficha del club: escudo, categorías, roster por torneo, calendario propio | `equipos/fichas/v_calendario` |
| `/noticias` + `/noticias/{slug}` | Lista paginada + detalle | `noticias` |
| `/liga`, `/reglamento`, `/contacto` | Páginas editables desde el panel | `paginas` |
| `/creditos`, `/privacidad`, `/terminos` | Legales (patrón uruprev, desde el primer despliegue) | estáticas |

Fechas y horas: siempre `America/Montevideo`, formato "Sáb 21/10, 20:30". Sin ambigüedades de TZ (`Docs/02`).

## 2. Componentes clave

- **FixtureCard**: fecha/hora, escudos, nombres, marcador si está jugado y publicado; si no, nota pública ("postergado").
- **TablaPosiciones**: orden por PTS con tie-breakers de la view; degradación elegante a 320px (columnas esenciales PJ PG PP PTS, el resto en la ficha de club).
- **LideresTabs**: island para cambiar entre goleadores/rebotes/asistencias sin recargar la página.
- **FiltroFixture**: island — filtro por club/jornada local, con estado de URL (`?club=x`) para compartir link.
- **BracketPlayoffs**: estático, preparado con CSS grid; sin bibliotecas externas.
- **Sin banner de cookies propio**: solo carga de Supabase propia; las third-party no existen en el público.

## 3. SEO

- `<title>`, `description` y `og` por torneo/página/noticia; `og:image` con la portada o el escudo del club.
- **JSON-LD**: `SportsLeague` en la home (nombre, logo, deporte "basketball"); `SportsEvent` por partido `programado`/`finalizado` (fecha, sede, equipos) — la mejor ficha de resultados que Google va a mostrar para búsquedas tipo "liga basket colonia fixture".
- `sitemap.xml` completo (torneos, clubes, noticias, páginas), `robots.txt` generados en build.
- Página 404 útil con últimos resultados + próxima jornada.
- Canonical cuando entre en juego el dominio custom de multiliga (`Docs/07`).

## 4. Rendimiento (targets medibles)

- imágenes con transform (`width` y `quality`) del CDN de Supabase Storage; escudos `format=webp,width=256`;
- fuentes: sistema de fuentes nativo (0 descargas extra);
- JS del público solo de islands: objetivo < 60KB gzip en el peor caso con filter fixture;
- Lighthouse móvil: Performance ≥ 90, Accessibility ≥ 95, SEO ≥ 95 en home y `/tabla` — verificación de QA (`Docs/10`).

## 5. Accesibilidad

- landmark + skip-link al contenido (patrón lgrestoreuy);
- contraste AA con los colores de la org (definidos en `Docs/07` config, validados al configurar);
- tabla con `<thead>`/th scope correctos (los resultados son datos, no decoración);
- focus visible en modalidades de filtro (carousel/tab islands).
