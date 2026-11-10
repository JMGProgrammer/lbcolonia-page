# 12 · Plan iterativo de construcción

Última actualización: 2026-10-22

Cada iteración termina con: build verde → QA propio → commit + push → **nota de revisión para Juan** (qué mirar, cómo mirarlo) → **checkpoint: Juan da OK** → recién arranca la siguiente. Nada cruza de iteración sin el OK.

Medición de duración: en **sesiones de trabajo** (una sesión = un par de horas de trabajo con agente). El cómputo total es orientativo: el plan se re-calcula al cierre de cada iteración si algo salió más caro.

## Estado del plan

| Iteración | Estado |
|---|---|
| IT0 — Definición + diseño | ✅ hecha (Docs 00–11, decisiones registradas) |
| IT1 — Mockup del home | ✅ aprobada por Juan ("comenzá IT2") — commit `98b047c` pushed |
| IT2 — Base técnica | ✅ aprobada por Juan ("comenzá IT3") — commit `7b1e751` + tag `v0.1` (`92e23fe`) |
| IT3 — Sitio público completo | ✅ hecha (`ffb0cd5` + `12e7506`, tag `v0.2`) — checkpoint 3 **OK** 2026-10-21: deploy Vercel probado desde el celu (menús y secciones, criterio "2 toques" cumplido) |
| IT4 — Panel de la liga | ✅ hecha (sesiones 1, 2 y 3, tag `v0.3`) — Checkpoint 4 **OK** |
| Post-IT4 — Rediseño UI + perfiles de jugador | ✅ hecha (sesión 4, 18 commits del 22/10, tag `v0.4`) — ver nota abajo |
| IT5 — Delegados y planillas | 🟡 activa (sesiones 1–2 hechas: circuito delegado → liga; falta Mi club + sanciones + checkpoint) |
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

**Estado de la sesión 1 (2026-10-21, commit `de87cf2`)**:
- Andamio Astro 5 + Tailwind 4 en `src/` con tokens de `Docs/11` (página de prueba de tokens, no la home); componentes `Base`/`Rotulo`/`Panel`/`Btn`.
- `supabase/migrations/0001_esquema.sql` (~995 líneas): 17 tablas + enums + checks, triggers (`on_auth_user_created`, `partidos_guard_publicacion`, `planilla_verificada_cierre`, `orgs_guard_plan`, `updated_at`), helpers SECURITY DEFINER (`org_activa_id`, `es_superadmin`, `rol_en_org`, `es_organizador`, `es_liga_admin`, `mi_club_de`, `es_delegado_local`, `es_miembro_del_partido`, `es_delegado_local_borrador`, `es_visitante_borrador`, `es_delegado_de_equipo`, `es_planilla_publica`), RLS + policies completas de `Docs/03`, grants, views `v_tabla`/`v_lideres`/`v_sanciones_activas` (semántica definer: agregados de lo publicado) y storage (4 buckets + policies con paths `bucket/{org}/{partido}`).
- `supabase/seed.sql`: org LBC + `app_config org_activa`, 7 cuentas demo (`@demo.lbc.uy`, clave `demo-2026`), 4 clubes reales del afiche, 4 categorías, 16 equipos, 4 torneos, fixture completo de primera (12 partidos del afiche: F1 19:00 finalizada y publicada 78-70 con cuartos, F1 21:00 en disputa, F5-F6 sin sede según afiche), Sub-15 con 1 finalizada + walkover claro.
- Datos reales vs inventados: cuando el esquema pida algo no confirmado, va flag `[a confirmar con la liga]` (categorías de formativas, playoffs sí/no, puntos de tabla, sedes de F5/F6, horarios exactos); los rosters, marcadores y nombres de test son `[demo]`.
- `supabase/tests/rls_negativas.sql`: las 6 negativas de `Docs/03 §5` con emulación de JWT (`set_config('role'/'request.jwt.claims')`) + positivos esperados (2 publicados, 12 programados, v_tabla de primera con Plaza 1º y Juventud).
- Cliente `src/lib/supabase.ts` anon-only + `.env.example` + `config.toml` (CLI 2.121.0 instalada como devDep).
- Build verde. Audited: 0 vulns en producción; las 3 en devDeps quedan documentadas (ver "deuda técnica" abajo).

**Estado de la sesión 2 (2026-10-21, commit `7b1e751`)**:
- Juan pasó credenciales por `.env` (no viajan al repo). La CLI operó la base **directa** con `--db-url` — sin access token de cuenta (el login por navegador no existe en entorno no-TTY; el diáloguito Connect da URL + publishable key, no auth de CLI).
- `supabase db push` aplicó `0001` en la primera pasada (sin un error de sintaxis) y quedó registrado en el historial de migraciones remoto.
- Seed cargado: 1 org, 16 equipos, 14 partidos (12 primera + 2 Sub-15), 32 fichas, 3 planillas, 32 líneas de stats, 7 usuarios.
- `supabase/tests/rls_negativas.sql` corrió contra la base real: **las 6 negativas en verde** (anon sin planillas; delegado fuera de su club en 0; delegado no escribe partidos ni publica; ayudante sin auspiciantes; dominio de otra org ve 0) + positivos (2 publicados, 12 programados, `v_tabla` con Plaza 1º +8 y Juventud −8).
- Checks de API pública con la publishable key: `/rest/v1/partidos` devuelve solo publicados, `/planillas` vacía para anon, `/v_tabla` con la tabla correcta (el walkover puntúa 1 punto para Estudiantes Sub-15, 0 para Rowing).
- `src/lib/db-types.ts` generado desde la base (`gen types --db-url`) y cliente tipeado con `Database`.
- `scripts/run-sql.mjs` (+ `pg` en devDeps): ejecutor de SQL multi-statement — la CLI abre prepared statement por llamada y los tests necesitan `set_config` + consulta en la misma sesión.
- Validación de Supabase (tablero de advisors de Studio): 28 hallazgos → los 3 ERROR son las views definer (`v_tabla`/`v_lideres`/`v_sanciones_activas`), decisión documentada de `Docs/02`; el resto (25 WARN: 4 initplan + 20 multiple-permissive + 1 search_path en `updated_at`) quedó en la deuda de abajo.

**Deuda técnica pagada (2026-10-21)**: el upgrade Astro `5.18.2` → `7.4.2` (+ `@astrojs/vercel` `8.0.0` → `11.0.16`) se ejecutó con el disparador adelantado por el primer deploy real — Vercel canceló los runtimes 18/20 que era lo único que el adapter viejo emitía, y la v11 exige `astro ^7`. QA completo en verde (detalle en el changelog y en el bullet de deploy de IT3). Ninguna superficie advisory-afectada llegó a usarse y la de esbuild era "Windows dev only". Sigue prohibido `npm audit fix --force`: la cadena nueva de HIGH (`path-to-regexp` vía routing-utils del adapter v11) no tiene fix publicado y el forzado degradaría el adapter → deuda para IT7.

**Deuda de advisors DB (para IT7 Endurecimiento, migración `0002`)**: (a) `auth.uid()` directo en policies de `orgs`/`profiles`/`org_members` — 4 avisos auth_rls_initplan, envolver con `(select auth.uid())`; (b) 20 avisos de multiple_permissive_policies (evaluación extra por fila solo a escala; la corrección queda intacta); (c) `updated_at()` sin `set search_path` fijo (1 aviso); (d) las views definer (`v_tabla`/`v_lideres`/`v_sanciones_activas`) quedan ERROR en el tablero de advisors de Studio por diseño: la barrera real de esas views es su propio WHERE (solo datos publicados), documentado y aceptado — revisar si Supabase cambia su recomendación.

## IT3 — Sitio público completo (2-3 sesiones)

**Objetivo**: todo lo público de `Docs/04` funcionando sobre datos reales.

- Home conectada (marcador, fixture, tabla, ficha de partido, clubes, sanciones). Las noticias completas quedan para IT6; mientras, la home muestra noticias existentes si las hay y si no, la sección desaparece.
- Rutas: fixture (+ filtros), tabla, ficha de partido, clubes + ficha, sanciones, legales, 404 útil, RSS si sale gratis.
- SEO: metadata/OG/JSON-LD (`SportsEvent`), sitemap, robots, favicon + OG image del logo.
- QA: Lighthouse móvil targets, barrido responsive 320-1300, negativas de RLS del público.

**Checkpoint 3**: Juan + gente de la liga navega desde el celu. OK cuando "cualquiera encuentra la de hoy en 2 toques".

**Estado de la sesión 3 (2026-10-21, commit `ffb0cd5` + tag `v0.2`)**:
- Rendering cambia a `output: 'server'` con `@astrojs/vercel@8.0.0` (única compatible con Astro 5; la 11.x pide astro ^7). Cache de CDN vía `src/middleware.ts`: páginas `s-maxage=60, stale-while-revalidate=300` (la ola del domingo se refresca a ~1 min), feeds canónicos con TTL 1h/1d, assets (`/_astro/`, `/fonts/`, imágenes) sin tocar. Referrer-Policy + nosniff incluidos.
- Migración `0002_v_detalle_publico.sql` aplicada: vista definer con stats por jugador de partidos publicados para la ficha (`Docs/02 §views`); `db-types.ts` regenerado.
- Home conectada: hero con últimos resultados (ResultCard, enlaza a la ficha), próxima fecha, tabla compacta, clubes, noticias (desaparece la sección si no hay) y auspiciantes.
- Fixture con **filtros server-side por query params** (`?torneo=&ronda=&club=`): 0 JS, sin islands; el switcher de torneos conserva el resto de filtros. Mismo patrón en `/tabla` (solo torneo).
- Ficha de partido `/partidos/[id]`: todo lo visible por RLS tiene ficha (agenda incl.); stats por jugador solo si `publicado` (vía `v_detalle_publico`); JSON-LD `SportsEvent` + parciales + walkover con ganador. Los fixtures/cards solo enlazan resultados publicados.
- Clubes: directorio + ficha `/clubes/[slug]` (equipos por categoría con roster visible por RLS — bajas ocultas — y calendario propio por torneo).
- Sanciones (`v_sanciones_activas`), noticias + noticia individual (JSON-LD `NewsArticle`, mini-markdown servidor sin dependencias), páginas de la liga vía `/[slug]` (contacto, reglamento), legales estáticas (privacidad/terminos/créditos), **404 útil con datos reales** (últimos resultados + próxima fecha + accesos).
- Feeds: `sitemap.xml` dinámico (fijas + clubes + noticias + páginas), `robots.txt`, `rss.xml` (RSS 2.0). Metadata/OG completos + JSON-LD de liga en todas las páginas desde `Base.astro`.
- Nav móvil **CSS-only** (checkbox + `:has()`, cero JS); decisión técnica vigente: los componentes .astro **no admiten JSX en el frontmatter** — los condicionales de elementos van en el template.
- Helpers de `src/lib/data.ts` reescritos con tipado correcto: `filas<T>`/`fila<T>` sobre `RespuestaSupa<T[]>` (los primeros `lista/primera` inferían mal y tipeaban `T[][]`), select embeds `alias local/visitante + id` y embed de torneos con `id` (el back-link de la ficha lo usa).
- QA del cierre: `astro check` 0 errores / 22 hints; `npm run build` verde con adaptador Vercel (`engines.node: 20.x` en package.json para anclar runtime del deploy — el local es 24); smoke HTTP de 19 rutas (todas 200; `/pagina-inexistente` y `/partidos/<uuid falso>` 404); `?torneo=zzz-invalido` cae al torneo por defecto; **negativas del público por REST**: `planillas` anon `[]`, `v_detalle_publico` solo filas del publicado, POST anon a noticias → 42501; **barrido responsive 320–1300 sobre 15 rutas × 13 anchos = 195 revisiones, 0 overflows** (harness puppeteer-core + Chrome del sistema en `/tmp/opencode/qa`).
- Deploy (2026-10-21): primera publicación real en Vercel. Cadena de bloqueos resuelta en la misma fecha: (1) runtime Node 20 **discontinuado por Vercel** → `engines.node` `20.x`→`24.x` (`15c0e94`); (2) `@astrojs/vercel@8` hacía fallback a `nodejs18.x` (también cancelado) y la función `_render` salía inválida → **upgrade Astro 5.18.2 → 7.4.2 + adapter v11** con QA completo en verde (check 0/0/22, build emitiendo `nodejs24.x`, smoke con datos reales, barrido 195/0) y deploy desbloqueado. Cuidado local que importa para QA: en Astro 7, `astro dev` daemoniza y `localhost` resuelve a `[::1]` — arrancar con `--host 127.0.0.1` y parar con `npx astro dev stop`.
- Fixes de responsive durante el barrido: sub-línea del brand del TopBar `hidden min-[480px]:flex` (el label "Menú" fijaba el mínimo del documento en 366px); `min-w-0` + caps `max-w-[230px]` en sede/nota de `PartidoFila`, `min-w-0` en card/col/truncates de `ResultCard` y `sm:max-w-[420px]` en su nota (las filas empujaban 704–785px a partir de 640).
- Bugs reales cazados en el check: destructuring de `URLSearchParams` (torneo/ronda/club salían `undefined` en runtime) → reemplazado por `.get()`; `---` fantasma al inicio de `supabase.ts`; props perdidas del destructure de `Base.astro` (ogImage/jsonLd/aviso).

## IT4 — Panel de la liga (2-3 sesiones)

- `/admin` con cara liga: resumen de pendientes, torneos, fixture (pegado masivo + individual), clubes/equipos/jugadores/fichas, alta manual de resultados, **publicar partido** (verifica, marca, dispara revalidate del público), noticias y páginas (markdown + preview), auspiciantes, export CSV.
- `audit_log` de publicaciones.

**Checkpoint 4**: Juan juega a ser liga_admin: carga la fecha 3 del fixture desde un Excel pegado, publica un resultado simulado y lo ve vivo en el sitio público. OK = operación de semana posible sin ayuda.

**Estado de la sesión 1 (2026-10-21)**:
- Andamio del panel `/admin` con cara liga: `AdminLayout.astro` con shell institucional, TopBar en desktop, nav-cinta táctil móvil con touch targets ≥ 4.25rem (68px, `Docs/10 §3`), confirmaciones destructivas CSP-safe (`data-confirm` + `<dialog>` nativo).
- Auth & Sesión: `/admin/login` con Supabase Auth (`supabase-js` con sesión persistente en browser); `src/middleware.ts` con `Cache-Control: private, no-store, no-cache, must-revalidate` para `/admin/**` y `/api/**`, más CSP estricta (scripts locales solamente, sin CDNs; `@alpinejs/csp` local sin `'unsafe-eval'`). Guard de rol en cliente verifica `liga_admin`, `liga_ayudante` o `is_superadmin`; mensaje amigable para delegados (su acceso corresponde a IT5).
- Gestión del Fixture oficial (`/admin/fixture`): listado de partidos por torneo con filtro por jornada (chips de ronda), badges de estado (`programado`, `finalizado`, `walkover`, `publicado`), carga individual de partido (modal con timezone `America/Montevideo` y aviso suave de solapes).
- Pegado masivo de Fixture desde Excel / CSV (`/admin/fixture/importar`): parser tolerante (tabulaciones `\t`, punto y coma `;`, comas, fechas `DD/MM/AAAA` o `AAAA-MM-DD`), normalizador fuzzy matching de clubes/equipos, tabla de revisión previa interactiva antes de insertar en Supabase (marca partidos OK, sugeridos y pendientes de asignación manual).
- Carga de resultados oficiales y publicación: modal de carga de marcador, parciales por cuarto opcionales, walkover con ganador y notas de suspensión/postergación. Botón "Publicar partido" con guard exclusivo para `liga_admin` (deshabilitado para ayudante) y diálogo de confirmación accesible.
- Auditoría & Base de datos: migración `0003_audit_log.sql` aplicada en Supabase con tabla `audit_log`, RLS (solo lectura para `liga_admin`) y trigger `partidos_audit_cambios` sobre `partidos`. Script `scripts/db-push.sh` configurado y `src/lib/db-types.ts` regenerado.
- Revalidación: endpoint `/api/revalidate.ts` para disparar actualización del sitio público al publicar resultados.
- QA: `astro check` 0 errores / 22 hints; `npm run build` verde (adapter Vercel Node 24); 48/48 pruebas de RLS en verde (incluidas nuevas negativas de `audit_log`); barrido responsive 320–1300 px sin overflow en todas las rutas públicas y del panel.
- **Checkpoint 4 verificado en vivo por Juan**: login secretaría, pegado masivo de fecha 3 desde Excel con fuzzy match, revisión previa, importación, carga manual de resultado simulado, publicación oficial y reflejo inmediato en el sitio público.
- Modelos usados: Gemini 3.8 Flash (thinking alto) para redacción del plan e implementación tras aprobación.

**Estado de la sesión 2 (2026-10-21)**:
- ABMs institucionales del panel de la secretaría (`/admin`):
  - **Torneos y Categorías** (`/admin/torneos`): creación y edición de torneos con selector de temporada, formato (`liga`, `liga_playoffs`, `torneo`), estadísticas detalladas on/off y modal para reglas de puntuación FIBA o personalizadas (`puntos_victoria`, `puntos_derrota`, etc.).
  - **Clubes y Equipos** (`/admin/clubes`): administración de clubes con paleta de colores y selector hexadecimal sincronizado en vivo, gimnasio sede, logo/escudo y modal de categorías/equipos asignados al club.
  - **Padrón de Jugadores** (`/admin/jugadores`): registro y edición de basquetbolistas con cálculo automático de edad y detector en tiempo real de duplicados por coincidencia de `nombre_completo` y `fecha_nacimiento` (`Docs/02 §2`).
  - **Bandeja de Fichas** (`/admin/fichas`): bandeja de entrada tipo inbox filtrada por estado (`solicitada`, `confirmada`, `baja`), torneo y club; confirmación de solicitudes de delegados, asignación/modificación de dorsal (#) y baja de fichas oficiales con confirmación nativa.
  - **Inbox del Panel** (`/admin`): hub con contadores en vivo de tareas pendientes (fichas solicitadas, resultados sin publicar, partidos programados sin sede y disputas) con accesos directos de 1 clic y grilla completa de módulos.
- Permisos & Migración: `0004_fichas_liga_permisos.sql` aplicada en Supabase para permitir gestión integral de fichas a organizadores (`es_organizador(org_id)`).
- Verificación: `npm run check` 0 errores / 0 warnings; `npm run build` verde; 48/48 pruebas RLS pasando; barrido responsive 320–1300 px (91 revisiones en 7 rutas del panel) con 0 fallas de overflow.
- Modelos usados: Gemini 3.8 Flash (thinking alto).

**Estado de la sesión 3 (2026-10-22) — Cierre de IT4**:
- **Noticias y Prensa** (`/admin/noticias`): gestión integral con editor Markdown, vista previa en tiempo real client-side compatible con CSP estricta, autogeneración de slug, asignación de etiquetas y switch de destacado.
- **Páginas Institucionales** (`/admin/paginas`): gestor de páginas oficiales (estatutos, reglamento, contacto) con Markdown y preview en vivo que alimentan la ruta dinámica `/[slug]`.
- **Auspiciantes Comerciales** (`/admin/auspiciantes`): gestión de marcas oficiales por nivel (`oro`, `plata`, `bronce`, `colaborador`), links, logos y orden de prioridad. Guard de seguridad: solo `liga_admin` puede modificar auspicios (aviso explicativo y botones deshabilitados para `liga_ayudante`).
- **Centro de Exportación CSV** (`/admin/export`): descargas directas en formato CSV con BOM UTF-8 (`\uFEFF`) y separador `;` para apertura perfecta en Excel de Tabla de Posiciones, Fixture completo, Rosters/Fichas y Directorio de Clubes.
- **Navegación e Integración**: `AdminLayout.astro` actualizado con los nuevos accesos en desktop y cinta táctil móvil; hub `/admin` completado con los 10 módulos de secretaría.
- **Verificación**: `npm run check` 0 errores / 0 warnings en 51 archivos; `npm run build` verde con adapter Vercel Node 24; 48/48 pruebas RLS pasando; barrido responsive exhaustivo 320–1300 px (143 revisiones en 11 rutas del panel) con 0 fallas de overflow.
- **Cierre formal**: Tag `v0.3`.

**Estado de la sesión 4 (2026-10-22) — Post-IT4: rediseño UI + perfiles de jugador**:
- **Perfiles personales de jugador** (`/jugadores/[slug]`, `2d13f3b`): hero con foto y dorsal, bento de promedios de temporada (PJ/PTS/RPG/APG/%TC/%3P/%TL/EFF), game log con boxscore interactivo y navegación cruzada. Migración `0005_perfil_jugadores.sql`: columnas bio en `jugadores` (`posicion`, `altura_cm`, `mano_habil`, `slug`, `ciudad_origen`), columnas opcionales de tiro en `planilla_stats` y 3 views definer (`v_jugadores_publico`, `v_jugador_totales_temporada`, `v_jugador_partidos_log`); `db-types.ts` y `data.ts` regenerados/ampliados. Plan de integración en `Docs/13-plan-perfil-jugadores.md` (fases 1–5; quedan pendientes fases 4–5: gráficos y vinculación con `/estadisticas`).
- **Interacción hover/click** en boxscore de `/partidos/[id]` y en roster/fichas de `/clubes/[slug]`: realce de fila y navegación al perfil.
- **Rediseño visual integral del sitio público**: header LBC y TopBar rediseñados; cards de clubes con colores institucionales oficiales, patrones de camiseta y bordes redondeados; sección de **campeonatos** (`/campeonatos`) con equipos por torneo y franja de sponsors; banners laterales de video con inicio diferido 1s y loop; navegador interactivo de fechas en home y tabla; ficha de club con escudo grande, reseña cultural enciclopédica, planteles plegables y fichas deportivas de jugadores (`src/lib/clubes-info.ts`); escudos reales de los 5 clubes y fotos de jugadores en el afiche de próxima fecha.
- **QoL móvil**: scoreboard horizontal en ficha de partido, `ResultCard` rediseñado, corrección de solapamiento de botones en categorías formativas, alineación rígida de partidos y reescalado de logos de sponsors.
- **Datos**: seed actualizado con categorías formativas U10–U22 (Valdense) y noticias; ajustes en `rls_negativas.sql`.
- **Verificación**: `npm run check` 0 errores / 0 warnings; `npm run build` verde; 48/48 RLS en verde; barrido responsive 320–1300 px sin overflow en las rutas tocadas.
- **Nota de proceso**: este bloque se hizo **después del checkpoint 4 OK** y no cierra ninguna IT del plan; es una entrega de valor paralela (rediseño + feature nuevo). Tag `v0.4` creado con OK de Juan (2026-10-22).
- Modelos usados: Gemini 3.8 Flash (thinking alto) para implementación; redacción de `Docs/13`.

## IT5 — Delegados y planillas (2-3 sesiones)

> **Siguiente paso del plan.** El rediseño post-IT4 (sesión 4) no forma parte de IT5: fue una entrega paralela de UI + perfiles (`Docs/13`). IT5 arranca por la cara delegado y el circuito de planillas.

- Cara delegado: mis partidos, **planilla en 3 bloques**, foto de papel obligatoria (Storage privado), disputas, roster propio con fichas `solicitada`.
- Verificación contra foto: diff pantalla, corrección y publicación con auditoría.
- Policies duras + las 6 negativas de `Docs/03 §5` en verde.

**Checkpoint 5**: simulacro de jornada completa con Juan actuando dos roles (delegado local, luego liga): carga, disputa, verifica, publica. OK = el circuito real del sábado cerrado.

**Estado de la sesión 1 (2026-10-22) — Cara delegado: andamio, planilla y disputa**:
- **Layout propio del delegado** (`src/layouts/DelegadoLayout.astro`): nav institucional con sus secciones (Partidos / Mi club / Sanciones), badge de rol y club, confirmaciones CSP-safe (`data-confirm` + `<dialog>`) y aviso al salir al sitio público.
- **Hub "Mis partidos"** (`/admin/delegado`): solo los partidos de su club (local y visitante) con acciones según el caso: cargar/continuar planilla, ver planilla (verificada o en disputa), disputar (visitante con borrador) o "esperando al local". Resumen de cargas pendientes.
- **Planilla en 3 bloques** (`/admin/delegado/partidos/[id]/planilla`): (1) resultado calculado por suma de puntos, (2) jugadores locales y (3) visitantes con guardado por bloque; foto del papel **obligatoria** (bucket privado `planillas/{org}/{partido}`, con preview firmado) y alta rápida de jugador (crea `jugadores` + ficha `solicitada`). El marcador del partido se deriva de la suma de stats al verificar (trigger `planilla_verificada_cierre` de `0001`).
- **Disputa del visitante** (`/admin/delegado/partidos/[id]/disputar`): motivo obligatorio; actualiza la planilla a `disputada` con `disputada_por_club`. La policy de `0001` ya lo permitía; el trigger nuevo refuerza el motivo.
- **Login y redirección**: los delegados entran directo a `/admin/delegado`; la secretaría sigue en `/admin`; `AdminLayout` redirige al delegado a su cara.
- **Migración `0006_planillas_endurecer.sql` aplicada**: disputa con motivo obligatorio, verificación con foto obligatoria, `cargada_por = auth.uid()` en el insert de planilla y policy de alta rápida de jugadores para delegados.
- **Verificación**: `astro check` 0 errores; `npm run build` verde; smoke HTTP de las rutas nuevas (`/admin/login`, `/admin`, `/admin/delegado`, `/club`, `/sanciones` → 200; planilla con id falso → 302); negativas RLS en verde contra la base real. El barrido responsive queda pendiente (el harness de QA no existe en `/tmp/opencode/qa` en esta sesión).
- **Fix durante la prueba de Juan**: las filas de jugadores se estaban imprimiendo como HTML literal por interpolar strings en el template Astro; reemplazadas por markup Astro tipado (sin `set:html`) para render correcto y escape seguro de nombres.
- **Fix de alta rápida durante la prueba**: el botón del visitante permitía intentar crear una ficha para el rival, que RLS rechazaba correctamente después de haber creado el jugador. Se eliminó esa acción del rival y la migración `0007_alta_jugador_delegado_atomica.sql` agrega la RPC transaccional `solicitar_ficha_jugador`: jugador + ficha `solicitada` se crean juntos y solo para un equipo del club del delegado. Migración aplicada, tipos regenerados y prueba positiva con rollback en verde.
- **QoL de feedback**: toasts de carga y disputa movidas a la esquina inferior derecha, con mayor tamaño, contraste, duración (4,2 s) y `aria-live`; en móvil quedan por encima de la nav inferior.
- **Pendiente para la sesión 3**: Mi club (roster), Mis sanciones, QA responsive y simulacro completo del checkpoint 5.
- Modelos usados: Gemini 3.8 Flash (thinking alto).

**Estado de la sesión 2 (2026-10-22) — Mesa de verificación de la liga**:
- **Inbox de planillas** (`/admin/planillas`): bandeja con filtros Pendientes / En disputa / Verificadas / Todas, estado de foto, motivo de disputa y acceso a revisión. Integrado al nav desktop/móvil y a la tarjeta de pendientes del hub de secretaría (ahora cuenta borradores + disputadas).
- **Comparación papel vs pantalla** (`/admin/planillas/[id]`): foto privada mediante signed URL (10 min) en columna sticky y boxscore editable al lado, agrupado por equipo; marcador recalculado en vivo para contrastar con el papel.
- **Acciones de liga**: guardar correcciones, devolver una disputa al delegado con nota, anular con confirmación + nota, verificar (exige foto; si estaba disputada exige resolución) y publicar. `liga_ayudante` puede corregir/verificar; solo `liga_admin` ve y ejecuta la publicación final. Publicar dispara `/api/revalidate`.
- **Migración `0008_verificacion_planillas_audit.sql` aplicada**: campos `resolucion_disputa`, `resuelta_por`, `resuelta_at`; guard de nota para anulación; auditoría de cambios de estado/resolución y de cada INSERT/UPDATE/DELETE en `planilla_stats`.
- **Verificación**: `astro check` 0 errores; build Vercel verde; consultas reales de inbox (4 planillas) y detalle (6 líneas) con cuenta liga; prueba transaccional con rollback de auditoría de corrección y resolución de disputa en verde; negativas RLS en verde; smoke HTTP de `/admin`, `/admin/planillas` y detalle → 200. Barrido visual pendiente: no hay Chrome del sistema ni harness en este entorno.
- **Rediseño por devolución de Juan**: el inicio del delegado dejó de ser una lista compacta. Ahora prioriza “Requiere tu atención”, separa “En seguimiento”, “Agenda del club” (3 visibles + expansión) e historial colapsado, con contexto explícito de quién tiene el próximo paso. `DelegadoLayout` incorpora navegación desktop visible (Mis partidos / Mi club / Mis sanciones); la cinta inferior sigue en móvil.
- **Pulido de carga (2026-11-10)**: el tablero dinámico reutiliza el mismo resolver de escudos que el sitio público y prioriza los `.webp` locales por `slug`; mientras cada imagen carga muestra una silueta animada y solo usa iniciales ante un error real. El estado inicial ahora replica la estructura final (resumen, tarjetas con espacios de escudos/textos/acción y agenda) y oculta métricas, tags y contenido hasta recibir los datos.
- **Fix visual público (2026-11-10)**: la tabla de puntos por cuarto de `/partidos/[id]` usa layout fijo, columna de equipo acotada y parciales/totales centrados en la misma grilla; se eliminó el padding exterior que sobredimensionaba el bloque de dos filas.

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
