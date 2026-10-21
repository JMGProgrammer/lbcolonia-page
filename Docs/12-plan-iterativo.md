# 12 · Plan iterativo de construcción

Última actualización: 2026-10-21

Cada iteración termina con: build verde → QA propio → commit + push → **nota de revisión para Juan** (qué mirar, cómo mirarlo) → **checkpoint: Juan da OK** → recién arranca la siguiente. Nada cruza de iteración sin el OK.

Medición de duración: en **sesiones de trabajo** (una sesión = un par de horas de trabajo con agente). El cómputo total es orientativo: el plan se re-calcula al cierre de cada iteración si algo salió más caro.

## Estado del plan

| Iteración | Estado |
|---|---|
| IT0 — Definición + diseño | ✅ hecha (Docs 00–11, decisiones registradas) |
| IT1 — Mockup del home | 🟡 terminada — esperando OK de Juan (checkpoint 1) |
| IT2 — Base técnica | pendiente |
| IT3 — Sitio público completo | pendiente |
| IT4 — Panel de la liga | pendiente |
| IT5 — Delegados y planillas | pendiente |
| IT6 — Complejidad del torneo | pendiente |
| IT7 — Endurecimiento | pendiente |
| IT8 — Piloto real con la LBC | pendiente (condicionada a reunión con la liga) |
| IT9 — Comercial | pendiente (condicionada) |

## IT1 — Mockup del home (1 sesión)

**Estado final**: entregada. `mockup/home.html` + `mockup/assets/` (Archivo variable self-hosted, tokens y componentes de `Docs/11`); barrido verificado en 320 / 414 / 768 / 1024 / 1300 con Chrome headless. Resultados de la Fecha 1 marcados como demo hasta que la liga confirme. Flag de aceptación: el OK de Juan para arrancar IT2.

**Objetivo**: ver el diseño antes de amarrar nada. HTML + Tailwind estático, sin base de datos, con los datos reales del afiche incrustados (fecha 1 del 17/10 que ya se jugó + próxima fecha 24/10).

**Entrega concreta**:
- `mockup/` en el repo (fuera de `src/`): home completa según `Docs/11 §4` — switcher de competencias, nav, hero-marcador, 2 noticias demo (marcadas como demo), tabla compacta, próximos partidos, franja de auspiciantes, footer.
- Tokens de paleta/tipografía ya implementados (Archivo self-hosted + tabular-nums).
- Visto en 320 / 414 / 768 / 1024 / 1300 px (barrido headless) + capturas para Juan.

**Checkpoint 1 — revisar cómo**: abrir la captura que Juan prefiera (sirvo el mockup local con `--host` para verlo en el celu). Juan aprueba o pide cambios (ojo: cambios de dirección estructurales, no pixel-picking sin sentido).

**No incluye**: conectividad, rutas extra, panel, Supabase.

## IT2 — Base técnica (2 sesiones)

**Objetivo**: el cimiento. Nada visible nuevo para un hincha.

**Entrega concreta**:
- Scaffolding Astro (TS strict) + Tailwind 4 con los tokens reales del diseño (migración del mockup a `components/`).
- Proyecto Supabase creado y proyecto migrado `0001` completo (`Docs/02`): orgs, org_members, categorías, torneos, clubes, equipos, jugadores, fichas, partidos, planillas, planilla_stats, sanciones, noticias, auspiciantes, paginas + views (`v_tabla`, `v_lideres`, `v_sanciones_activas`) + RLS base (`Docs/03`).
- Seed: org LBC + 4 clubes reales de primera + fixture completo real (6 fechas, doble jornada con anfitrión) + data demo para formativas/amateur (torneo ficticios) + 2 planillas de ejemplo.
- Env vars y clientes supabase configurados; repo remoto actualizado.

**Checkpoint 2 — revisar cómo**: Juan abre Supabase Studio (con la secretaría después, o solo): ve las tablas con datos reales de la liga. El criterio del OK: "el esquema está bien para operar la liga".

**No incluye**: ninguna página pública real conectada, panel.

## IT3 — Sitio público completo (2-3 sesiones)

**Objetivo**: todo lo público de `Docs/04` funcionando sobre datos reales.

- Home conectada (marcador, fixture, tabla, ficha de partido, clubes, sanciones). Las noticias completas quedan para IT6; mientras, la home muestra noticias existentes si las hay y si no, la sección desaparece.
- Rutas: fixture (+ filtros), tabla, ficha de partido, clubes + ficha, sanciones, legales, 404 útil, RSS si sale gratis.
- SEO: metadata/OG/JSON-LD (`SportsEvent`), sitemap, robots, favicon + OG image del logo.
- QA: Lighthouse móvil targets, barrido responsive 320-1300, negativas de RLS del público.

**Checkpoint 3**: Juan + gente de la liga navega desde el celu. OK cuando "cualquiera encuentra la de hoy en 2 toques".

## IT4 — Panel de la liga (2-3 sesiones)

- `/admin` con cara liga: resumen de pendientes, torneos, fixture (pegado masivo + individual), clubes/equipos/jugadores/fichas, alta manual de resultados, **publicar partido** (verifica, marca, dispara revalidate del público), noticias y páginas (markdown + preview), auspiciantes, export CSV.
- `audit_log` de publicaciones.

**Checkpoint 4**: Juan juega a ser liga_admin: carga la fecha 3 del fixture desde un Excel pegado, publica un resultado simulado y lo ve vivo en el sitio público. OK = operación de semana posible sin ayuda.

## IT5 — Delegados y planillas (2-3 sesiones)

- Cara delegado: mis partidos, **planilla en 3 bloques**, foto de papel obligatoria (Storage privado), disputas, roster propio con fichas `solicitada`.
- Verificación contra foto: diff pantalla, corrección y publicación con auditoría.
- Policies duras + las 6 negativas de `Docs/03 §5` en verde.

**Checkpoint 5**: simulacro de jornada completa con Juan actuando dos roles (delegado local, luego liga): carga, disputa, verifica, publica. OK = el circuito real del sábado cerrado.

## IT6 — Complejidad del torneo (2-3 sesiones)

- Playoffs: series, bracket, vista de series.
- Sanciones con contador de cumple y vista pública; líderes estadísticos; noticias + páginas editables completas; auspiciantes con niveles; export CSV de tabla y stats.
- Secciones de formativas/amateur con nivel de estadísticas configurable.

**Checkpoint 6**: un torneo demo se juega desde el arranque hasta los playoffs en local (seed completo). OK = "el cierre de la temporada está cubierto".

## IT7 — Endurecimiento (1 sesión)

- Checklist completa de `Docs/10`: seguridad (RLS + Storage + secrets), rendimiento (Lighthouse + pico de sábado), accesibilidad, backups pg_dump por cron, legales y créditos; versionado con tags (primer `v0.x` formal).
- Revisión visual real en el celu físico de Juan.

**Checkpoint 7 — release candidate**: revisional completo de `Docs/10` sin críticos pendientes. OK = listo para piloto real.

## IT8 — Piloto real con la Liga de Colonia (continua de 1-2 semanas)

- Org real cargada con la secretaría: clubes, delegados (invitaciones + video de 3 min), fixture vigente, escudos.
- Primera jornada real opera: delegados cargan, liga verifica y publica.
- `FEATURES.md` absorbe los pedidos reales de la liga.

**Checkpoint 8**: una fecha real completa del torneo de Colonia visible y publicada por sus protagonistas, sin que Juan cargue resultado alguno.

## IT9 — Comercial (condicionada al cierre del piloto)

- Landing de producto con demo del seed, pricing final (`Docs/08`), contrato de licencia, primera liga segundo piloto.

## Reglas del plan

1. **Un checkpoint sin OK = pausa**. Los pedidos "agregá además esto" que aparezcan a mitad de iteración van a `FEATURES.md` y se negocian al final; o se reabre la iteración de común acuerdo.
2. Cada iteración cierra con **tag** (`v0.1` para IT2, y así sucesivamente, esquema lgrestoreuy); IT1 (mockup) no tag de release.
3. El plan se actualiza aquí mismo (esta tabla de estado) al cerrar cada iteración — es el tablero en vivo del proyecto.
4. Si Juan pide reordenar ("salteamos X", "adelantá Y") se copian los cambios acá mismo en la tabla de estado y `Docs/09` queda como mapa macro: no se contradicen — `Docs/09` son las fases, este doc es la ejecución iterada.
