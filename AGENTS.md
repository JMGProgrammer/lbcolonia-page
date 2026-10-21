# AGENTS.md — Runbook de sesión en lbc-web

Objetivo del repo: web oficial de la Liga de Básquetbol de Colonia (LBC, Uruguay), construida por iteraciones con checkpoints donde **Juan da el OK** (plan completo en `Docs/12`). Producto vendible al final (`Docs/09`, IT9).

## Estado vivo (leer primero)

- Tablero con el estado por iteración y el registro detalle de cada sesión: **`Docs/12-plan-iterativo.md`** — es el fuente de verdad de "dónde vamos". Si el doc y el código difieren, corregir el doc al cierre de la sesión.
- Historial de entregables y tags: **`Changelog.md`** en la raíz.
- Estado al cierre de IT3 (2026-10-21): sitio público SSR completo funcionando sobre datos reales de Supabase (commits `ffb0cd5`, tags `v0.1`/`v0.2` pushed). **Pendiente: checkpoint 3** (Juan + gente de la liga navega desde el celu; criterio "cualquiera encuentra la de hoy en 2 toques") → recién con ese OK arranca IT4.
- Tag automático de "siguiente paso": la iteración en 🟡 del tablero de `Docs/12`.

## Mapa de docs

| Doc | Contenido | Cuándo leerlo |
|---|---|---|
| `Docs/00-overview.md` | Qué es el producto | Siempre (primera vez) |
| `Docs/01-stack.md` | Stack y porqués | Siempre (primera vez) |
| `Docs/02-datos.md` | Modelo, multi-org, views definer | Obligatorio para TOCAR datos/RLS |
| `Docs/03-roles-accesos.md` | Roles, policies, permisos | Obligatorio para TOCAR datos/RLS |
| `Docs/04-sitio-publico.md` | Spec de páginas IT3 | Páginas públicas |
| `Docs/05-panel.md` | Spec del panel | IT4 |
| `Docs/06-flujos-operativos.md` | Flujo delegados/liga | IT5 |
| `Docs/09-fases.md` | Fases + esquema de commits | Siempre (primera vez) |
| `Docs/10-qa-performance.md` | QA por tipo de cambio | Al verificar |
| `Docs/11-diseno.md` | Dirección visual + tokens | UI |
| `Docs/12-plan-iterativo.md` | Plan + estado vivo | Siempre |

## Decisiones fijas (no re-abrir sin motivo)

- Stack: Astro 5 + Tailwind 4 + Supabase + Vercel (`output: 'server'`, adaptador `@astrojs/vercel@8`). Next.js es opción **futura**, no actual.
- Multi-liga desde 0001: **todas** las tablas de contenido llevan `org_id`.
- Solo anon/publishable key al navegador. Jamás `service_role` fuera de acciones servidor de máxima confianza.
- RLS primero: única barrera real (las views definer se barre con su propio WHERE; decisión documentada en `Docs/02`).
- El público **nunca escribe**: negativas de escritura probadas por REST al tocar seguridad.
- Fecha/hora `timestamptz`, zona `America/Montevideo`.
- Filtros SSR por query params con `.get()` (0 JS en listados). Nav móvil CSS-only. **El frontmatter de un componente .astro NO admite JSX**: los condicionales de elementos van en el template.
- UI en español neutro (sin "vos" ni tuteo en textos de UI; "escribir a la liga" en vez de imperativos).

## Trampas conocidas (costaron bugs)

- `URLSearchParams` no se destructura: usar `searchParams.get('x') ?? undefined`.
- En embeds PostgREST alias local/visitante, la propiedad es `p.local.clubes` (no `.club`).
- Al regenerar `db-types.ts` con view nuevas, regenerar también la capa `data.ts` de funciones que las leen.
- Los advisories de Astro y `npm audit fix --force` no se corren sin pedido explícito (ver deuda en `Docs/12`).

## Comandos

```sh
npm run dev        # http://127.0.0.1:4321 (SSR, lee .env)
npm run build      # debe pasar verde antes de cada commit
npm run check      # astro check (0 errores esperado)
npm run db:types   # regenera src/lib/db-types.ts desde la base
npm run db:sql -- supabase/tests/rls_negativas.sql   # SQL multi-statement en la base real
npm run db:push    # aplica supabase/migrations
```

- QA responsive: harness en `/tmp/opencode/qa` (`barrido.cjs`, `diag2.cjs`; puppeteer-core + Chrome del sistema, 320–1300). Requiere dev server arriba. No va al repo.
- Archivo temporal del agente: usar `/tmp/opencode/` (pre-aprobado).

## Credenciales (reglas duras)

- Nada sensible impreso a la vista, ni commiteado, ni en docs. `.env` está en `.gitignore` (solo `.env.example` viaja).
- Credenciales de sesión en `/tmp/opencode/sb-env.sh` (exports `PUBLIC_SUPABASE_*`); la CLI opera la base con `--db-url` desde `.env` (sin access token de cuenta).
- Supabase Studio es la vista de la base para Juan y la secretaría; el agente no pide abrir tableros nuevos.

## Qué NO hacer sin pedido explícito

- No adelantar trabajo de iteraciones futuras (`Docs/09` fija la fase; IT4 no arranca sin checkpoint 3).
- No re-escribir migrations ya aplicadas (`0001`/`0002` son inmutables; cambios van como `00NN` nuevo).
- No tocar el contenido `[demo]` / `[a confirmar con la liga]` (el seed lo mantiene hasta la reunión con la secretaría: categorías reales de formativas, playoffs sí/no, sistema de puntos, sedes F5–F6, contactos de delegados).
- No "optimizar" las views definer que aparecen en el tablero de advisors: decisión tomada (`Docs/02`).
- No mezclar en un commit código + decisiones nuevas sin doc.

## Verificación mínima por commit

1. `npm run build` verde.
2. Página pública nueva o toque de UI: barrido 320–1300 (harness de arriba) sin overflow.
3. Se tocó RLS/views: negativas corrideron (RLS del público + las de `Docs/10 §5` si aplica).
4. `Docs/12` actualizado con estado de la sesión + `Changelog.md` si es entregable.

## Convenciones

- Commits en español, estilo conventional: `feat:`, `fix:`, `docs:`, `chore:` (tags `v0.x` al cierre de cada IT entregable; esquema completo en `Docs/09-fases.md`).
- Documentación en `Docs/` con la serie numerada; doc nuevo → índice del README.
- Ideas y pendientes van a `FEATURES.md`, no a los specs.
- Al cierre de un trabajo significativo: sincronizar memoria Obsidian (`02-Projects/lbc-web`) con lo durable (decisiones, estado), no transcripciones.
