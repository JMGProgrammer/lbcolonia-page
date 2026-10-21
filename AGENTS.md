# AGENTS.md — Runbook de sesión en lbc-web

Objetivo del repo: web oficial de la Liga de Básquetbol de Colonia (LBC, Uruguay), construida por iteraciones con checkpoints donde **Juan da el OK** (plan completo en `Docs/12`). Producto vendible al final (`Docs/09`, IT9).

## Estado vivo (leer primero)

- Tablero con el estado por iteración y el registro detalle de cada sesión: **`Docs/12-plan-iterativo.md`** — es el fuente de verdad de "dónde vamos". Si el doc y el código difieren, corregir el doc al cierre de la sesión.
- Historial de entregables y tags: **`Changelog.md`** en la raíz.
- Estado adelantado (noche 2026-10-21): checkpoint 3 **OK** — deploy de Vercel en producción (runtime `nodejs24.x`) navegado desde el celu con datos móviles; menús y secciones revisados por Juan. **IT4 activa**: arrancar por "Pasos de esta sesión" de su prompt (andamio del panel + cara liga); el upgrade Astro 7 ya está pagado, no re-abrir.
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

## Modelos de IA del plan (Google AI Pro / Antigravity)

Este runbook está escrito para **cualquier agente sin memoria externa ni skills instaladas** (Antigravity, OpenCode u otro): todo el contexto necesario vive en este archivo y en `Docs/`. No asumir sesiones ni historial previo; arrancar siempre por "Estado vivo" y la iteración 🟡 de `Docs/12`.

Elección de modelo por tarea (plan Pro: cuotas medidas; Argon tiene cuota **semanal** aparte):

| Tarea | Modelo | Por qué |
|---|---|---|
| Implementación diaria: páginas SSR, filtros, componentes, fixes | **Gemini 3.8 Flash** (thinking alto) | Rápido y suficiente para el trabajo de todos los días |
| Borrador del plan de una sesión/IT | **Gemini 3.8 Flash** (thinking alto) | Pasos, archivos que toca y verificación esperada |
| Lógica difícil: RLS, SQL, refactors multi-archivo, bugs espinosos, crítica del plan | **Gemini 4 Argon** | Mejor lógica agéntica; cuota semanal en Pro → reservarlo para lo que de verdad lo necesita |
| UI design-heavy (mockups, identidad visual de `Docs/11`) | **Claude** (Model Garden) | Flash tiene instintos de diseño flojos; si solo hay Flash, anclar a los tokens de `Docs/11` y barrer igual |
| Bug duro estancado con Flash | `/boost` (multi-agente de Antigravity) | Más barato que gastar cuota de Argon |

Flujo preferido: **Flash redacta el plan → Argon lo critica y ajusta → Flash implementa → Claude pule la UI si es design-heavy.**

Reglas duras del plan:

- Cuota del modelo grande agotada → avisar a Juan y frenar. Los **créditos AI son pagos: no comprarlos ni gastarlos sin OK explícito**.
- Si la sesión terminó usando un modelo distinto al previsto por agotarse la cuota, anotarlo en la nota de sesión de `Docs/12` (el trabajo debe quedar reproducible).
- El modelo elegido **no relaja la verificación mínima** (abajo): build, barrido y negativas los corre quien sea.

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

- QA responsive: barrido 320–1300 con harness (`barrido.cjs`, `diag2.cjs`; puppeteer-core + Chrome del sistema). Requiere dev server arriba. No va al repo: en el entorno OpenCode de Juan vive en `/tmp/opencode/qa`; si no existe (máquina nueva o `/tmp` limpio), recrearlo según la spec de `Docs/10 §3`.
- Archivo temporal del agente: cada agente usa su carpeta temporal propia (en OpenCode de Juan: `/tmp/opencode/`, pre-aprobado). Nada de temporales se commitea.

## Credenciales (reglas duras)

- Nada sensible impreso a la vista, ni commiteado, ni en docs. `.env` está en `.gitignore` (solo `.env.example` viaja).
- Credenciales de sesión: en el entorno OpenCode de Juan viven en `/tmp/opencode/sb-env.sh` (exports `PUBLIC_SUPABASE_*`); en cualquier otro entorno, la CLI opera la base con `--db-url` desde `.env` (sin access token de cuenta). Ese es el camino portable.
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
- Al cierre de un trabajo significativo: el estado durable se registra **en el repo** (nota de sesión en `Docs/12`, entregables en `Changelog.md`, trampas nuevas acá arriba). Agentes con vault Obsidian (entorno OpenCode de Juan): sincronizar además `02-Projects/lbc-web` con lo durable, no transcripciones.
