# Changelog — lbc-web

Web oficial de la Liga de Básquetbol de Colonia (Uruguay).
Historial invertido (lo nuevo arriba). Los tags marcan versiones entregables: `v0.1` = web pública (IT1+IT2), `v0.2` = web pública SSR completa (IT3).

## [Unreleased] · IT4: Panel de la Liga (cara secretaría) — sesiones 1 y 2

**Qué puede hacer Juan / la liga**:
- Acceder al panel institucional `/admin` con cuenta de secretaría (`liga@demo.lbc.uy`), middleware con cabeceras `no-store`, CSP estricta y navegación móvil adaptada (touch targets ≥ 68px).
- Importar fechas completas desde Excel/CSV con parser tolerante, previsualizador interactivo y fuzzy matching de equipos.
- Cargar marcadores oficiales, parciales por cuarto y walkovers; publicar partidos con auditoría (`audit_log`) y revalidación en vivo de la tabla pública.
- Administrar Torneos oficiales con selector de temporada, formato (`liga`, `playoffs`, `torneo`), flags de estadísticas y reglas de puntuación FIBA.
- Administrar Clubes y Equipos con sincronizador de colores en vivo, gimnasio sede y asignación de categorías.
- Gestionar Padrón de Jugadores con detector de duplicados en tiempo real por coincidencia de nombre y fecha de nacimiento (`Docs/02 §2`).
- Administrar Fichas de jugadores con bandeja de entrada filtrada por estado (`solicitada`, `confirmada`, `baja`), confirmación de pases, edición de dorsales (#) y bajas.
- Bandeja de pendientes del día en `/admin` con contadores en tiempo real (fichas solicitadas, resultados sin publicar, partidos sin sede y disputas).

## 2026-10-21 · hotfix de deploy post-v0.2: runtime Node 24 y deuda Astro pagada (`15c0e94`→)

**Qué cambió**: la primera publicación real en Vercel canceló el build (runtime Node 20 discontinuado) y destapó que el adapter viejo solo sabía emitir runtimes 18/20 ya cancelados. La deuda técnica con disparador "antes del panel de IT4" se adelantó **con OK de Juan**.

### Changed
- `engines.node`: `20.x` → `24.x` (`15c0e94`).
- Astro `5.18.2` → `7.4.2`; `@astrojs/vercel` `8.0.0` → `11.0.16` (la v11 exige `astro ^7` y emite `nodejs24.x`); import `@astrojs/vercel/serverless` → `@astrojs/vercel` (deprecated en la v8 que usaba el proyecto, removida en la v11).
- QA del upgrade en verde: `astro check` 0 errores / 0 warnings / 22 hints (mismo baseline que antes), `npm run build` completo con `runtime: nodejs24.x` en el `.vc-config.json`, smoke HTTP (home/fixture/tabla 200 con datos reales — SSR + RLS + cache intactos) y **barrido responsive 320–1300 × 15 rutas = 195 revisiones, 0 overflows**.

### Known issues
- `npm audit --omit=dev`: 3 HIGH, una sola cadena — `path-to-regexp` (ReDoS) vía `@vercel/routing-utils` en `@astrojs/vercel@11`. No hay fix publicado: el `--force` propuesto degradaría el adapter a 8 (rompe el deploy). Deuda para revisión en **IT7 Endurecimiento**; `audit fix --force` sigue prohibido sin pedido explícito.
- Astro 7: `astro dev` daemoniza por defecto y `localhost` resuelve a `[::1]` — para el harness de QA arrancar con `--host 127.0.0.1` y parar con `npx astro dev stop` (actualizado en `Docs/10 §3`).

## [v0.2] — 2026-10-21 · IT3: web pública SSR completa (`ffb0cd5`)

**Qué puede hacer Juan / la liga**: navegar todo el sitio público con datos reales — fixture, resultados, tabla, fichas, clubes, sanciones, noticias — desde el celu, sin cookies y sin JS.

### Added
- Rendering `output: 'server'` con `@astrojs/vercel@8.0.0` + `src/middleware.ts`: cache de CDN `s-maxage=60, stale-while-revalidate=300` para páginas (la ola del domingo refresca a ~1 min), TTL mayor para feeds, assets sin tocar; `Referrer-Policy` + `X-Content-Type-Options`.
- Páginas: home conectada; fixture con **filtros server-side** `?torneo=&ronda=&club=` (0 JS, sin islands); tabla por torneo; ficha `/partidos/[id]` (v_detalle_publico cuando hay stats: parciales, cuartos, walkover); `/clubes` + ficha de club (equipos por categoría, roster visible por RLS, calendario propio); `/sanciones`; `/noticias` + noticia individual; `/[slug]` para páginas de la liga (contacto, reglamento); legales (privacidad/terminos/créditos); **404 útil con datos reales**.
- Componentes: TopBar (nav móvil CSS-only con checkbox + `:has()`), Escudo, SwitcherTorneos, ResultCard, PartidoFila, TablaPosiciones, NoticiaCard, AuspicianteTile, Footer, Base (topbar + footer + OG + JSON-LD de liga).
- Feeds y SEO: `sitemap.xml` dinámico, `robots.txt`, `rss.xml` (RSS 2.0), metadata/OG por página, JSON-LD (`SportsLeague` global + `SportsEvent` por ficha + `NewsArticle` por noticia), canonical.
- `supabase/migrations/0002_v_detalle_publico.sql`: vista definer con stats por jugador de partidos publicados (la barrera es el WHERE de la vista, igual que `v_tabla`/`v_lideres`/`v_sanciones_activas`).
- `src/lib/data.ts`: capa de queries tipadas (`filas<T>`/`fila<T>` sobre `RespuestaSupa<T[]>`); select con embeds alias `local`/`visitante`. `src/lib/fmt.ts`: fechas/horas America/Montevideo, marcador, mini-markdown servidor sin dependencias.
- Scripts DB: `npm run db:types` / `db:sql` (operan la base sin access token, credenciales desde `.env`).

### Changed
- `package.json`: `engines.node: 20.x` (runtime de las funciones de Vercel; el local es 24 y avisaba con 18).
- Componentes del mockup IT1 migrados a `.astro` con datos reales; escudos resuelven `escudo_url` con transform del CDN de storage y caen a iniciales con colores del club.

### Fixed / QA
- Bugs cazados y corregidos: destructuring de `URLSearchParams` en fixture/tabla (los filtros en runtime llegaban `undefined`) → `.get()`; `---` fantasma al inicio de `src/lib/supabase.ts`; destructure de `Base.astro` sin `ogImage`/`jsonLd`/`aviso`; embed de torneos sin `id`; tipos genéricos de datos (`T[][]`).
- Negativas RLS del público por REST: `planillas` anon `[]`; `v_detalle_publico` devuelve solo filas del partido publicado; POST anon a noticias → error `42501` de RLS.
- Smoke HTTP: 19 rutas; `/pagina-inexistente` y `/partidos/<uuid falso>` → 404; `?torneo=zzz-invalido` cae al torneo por defecto.
- Barrido responsive 320–1300 px × 15 rutas = **195 revisiones, 0 overflows** (puppeteer-core + Chrome del sistema). Fixes: sublínea del brand `hidden min-[480px]:flex` (el label "Menú" fijaba mínimo 366px), `min-w-0` caps en PartidoFila/ResultCard (empujaban 704–785px ≥640).
- `astro check` 0 errores / build verde con adaptador Vercel.

## [v0.1] — 2026-10-21 · IT1 (mockup) + IT2 (base técnica) (`98b047c`…`92e23fe`)

### IT1 — mockup del home (`98b047c`)
- `mockup/home.html` + `mockup/assets/` con tokens de `Docs/11`: Archivo variable self-hosted, paleta de archivo LBC, solo oscuro, hero-marcador, doble jornada.
- Datos reales del afiche (F1 17/10 jugada 78–70, F2 24/10 doble de Juventud); lo no confirmado marcado `[demo]` / `[a confirmar con la liga]` donde corresponde.
- Barrido verificado 320/414/768/1024/1300 con Chrome headless. **Aprobado por Juan** (checkpoint 1: "comenzá IT2").

### IT2 — base técnica (`de87cf2`, `7b1e751`, docs `92e23fe`)
- `supabase/migrations/0001_esquema.sql` (~995 líneas): 17 tablas + enums/checks + triggers (`on_auth_user_created`, `partidos_guard_publicacion`, `planilla_verificada_cierre`, `orgs_guard_plan`, `updated_at`), helpers SECURITY DEFINER, RLS + policies completas de `Docs/03`, views `v_tabla`/`v_lideres`/`v_sanciones_activas` (semántica definer) y storage (4 buckets + policies por path).
- seed: org LBC + `app_config` + 7 cuentas demo + 4 clubes reales + fixture completo de primera (12 partidos del afiche) + Sub-15 + 2 planillas de ejemplo + stats.
- Base remota operada por CLI con `--db-url` (sin access token): `0001` aplicada, seed cargado, `rls_negativas.sql` corrió **6/6 negativas en verde** contra la base real; API demostrada con la publishable key (partidos solo publicados, planillas vacías para anon, walkover puntúa 1–0).
- Andamio Astro 5 + Tailwind 4 con tokens reales; cliente `src/lib/supabase.ts` anon-only; `db-types.ts` generado desde la base; `.env.example`.
- Deuda registrada con disparadores: advisories de Astro (upgrade antes de IT4, cuando entren islas), advisors DB para **IT7** (initplan, multiple-permissive, search_path; las views definer quedan en ERROR del tablero a propósito) (`92e23fe`).
- **Aprobado por Juan** en Studio (checkpoint 2: "comenzá IT3").

## IT0 — definición y diseño (docs) (`1200d40`…`a1a6192`)
- Serie `Docs/00–11`: overview, stack, modelo de datos + multi-org desde 0001, roles/RLS, spec del sitio público (`Docs/04`), panel, flujos, multiliga, benchmark AMR (`Docs/08`), dirección de diseño con Juan (`Docs/11`, solo oscuro, Archivo, hero-marcador) y plan iterativo con checkpoints (`Docs/12`, 10 iteraciones, nada cruza sin el OK de Juan).
- Datos reales pasados a los specs desde el material oficial: clubes y fixture de primera 2026, formato doble jornada, paleta (`89ce109`).
- Repo remoto conectado: `JMGProgrammer/lbcolonia-page` (`76171f5`).

---

### Convenciones de este changelog
- Un bloque por versión entregable; el detalle sesión por sesión vive en `Docs/12-plan-iterativo.md`.
- Los tags: `v0.1` en `92e23fe` (cierre IT2), `v0.2` en `ffb0cd5` (cierre IT3).
- "Aprobado por Juan" siempre refiere al checkpoint de `Docs/12`.
