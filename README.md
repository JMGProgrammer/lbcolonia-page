# LBC Web — Liga de Basquetbol de Colonia

Última actualización: 2026-10-21

## Summary

Web oficial para la liga de basquetbol local del departamento de Colonia (Uruguay): tabla de posiciones, fixture, resultados, estadísticas, sanciones, noticias y auspiciantes para **todas las competencias** (formativas, primera división y campeonato amateur).

Modelo de negocio: **piloto gratis con la Liga de Colonia** y luego licencia por temporada escalable al resto de las ligas del interior (multi-liga desde el diseño). Los datos los cargan los **delegados de cada club**; la liga verifica y publica.

## Repository

Path:

`/home/Juan/Documentos/Github/lbc-web`

Remote: `https://github.com/JMGProgrammer/lbcolonia-page.git` (rama `main`)

## Stack

- **Astro** + Tailwind CSS 4: sitio público estático on-demand + islands para lo interactivo
- **Supabase**: Postgres + Auth + Storage, control por RLS, solo anon key en el público
- **Panel admin** (`/admin`): liga (verifica/publica/todo el torneo) + delegados (planillas, fichas)
- **Deploy**: Vercel (SSR mínimo para multiliga por dominio)
- Next.js queda como opción de evolución futura si el sitio demanda tiempo real — decisión registrada en `Docs/01-stack.md`

## Docs

Serie numerada, se lee en orden:

| Nº | Doc | Contenido |
|----|-----|-----------|
| 00 | `00-overview.md` | Idea general detallada: producto, usuarios, competencias, diferenciadores |
| 01 | `01-stack.md` | Stack, arquitectura, entorno, deploy, decisión Astro vs Next |
| 02 | `02-datos.md` | Modelo de datos completo (tablas, estados, views SQL, reglas de tabla) |
| 03 | `03-roles-accesos.md` | Auth, roles y RLS por tabla |
| 04 | `04-sitio-publico.md` | Páginas públicas, SEO, rendimiento |
| 05 | `05-panel.md` | Specs del panel (liga y delegados) |
| 06 | `06-flujos-operativos.md` | Ciclo de jornada, planillas, disputas, playoffs, sanciones, casos borde |
| 07 | `07-multiliga.md` | Multi-tenant desde el día 1 y la venta a otras ligas |
| 08 | `08-negocio.md` | Modelo de venta, pricing, pitch, benchmark (Gesdeportiva) |
| 09 | `09-fases.md` | Roadmap de construcción con definición de hecho (DoD) |
| 10 | `10-qa-performance.md` | QA, accesibilidad, rendimiento, datos de prueba |
| 11 | `11-diseno.md` | Dirección visual: paleta, tipografía, home, componentes, decisión de modo oscuro |
| 12 | `12-plan-iterativo.md` | Plan iterativo con iteraciones, entregables, checkpoints y tablero de estado en vivo |

## Convenciones de documentación (igual que lgrestoreuy)

- **Único README en la base del repo**: índice + guía de setup.
- `Docs/` contiene la serie numerada; índice en este README.
- **`FEATURES.md` en la base**: archivo vivo de ideas, próximos cambios y fixes. Formato: checkbox + `[cambio|idea|fix]` + fecha; lo incorporado se borra, no se acumula.

## Assets (aportados por Juan, en el repo)

En `assets/images/` viven los materiales oficiales de la LBC:

- `logo-lbc-bgr.png` y `logo-lbc.jpg` — logo oficial (escudo con pelota, rojo/azul); el `-bgr` es el de fondo transparente, ideal para el sitio.
- `afiche-1era-lbc.jpg` + `afiche-1era-lbc-fixture.jpg` — afiches de Primera División 2026: el segundo tiene **el fixture completo transcrito** (4 clubes, 6 fechas, sábados 19:00/21:00, anfitrión por fecha). Datos usados en `Docs/00 §3` y `Docs/02 §7`.

La identidad visual del sitio arranca de acá: azul marino + rojo + naranja/dorado.

## Estado actual

**Fase 0 — definición completa** (2026-10-21): este directorio con toda la serie de docs. No hay código todavía. Lo próximo es la Fase 1 (`docs/09-fases.md`): scaffolding Astro + migración `0001` de Supabase con el esquema de `Docs/02`.

## Cómo arrancar (pendiente Fase 1)

```bash
npm create astro@latest . -- --template minimal --typescript strict
npm install @tailwindcss/vite tailwindcss @supabase/supabase-js @astrojs/vercel
npm run dev   # localhost (no 127.0.0.1, es IPv6); --host para probar desde el celular
```

Variables de entorno (`.env`, gitignored; solo anon key):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `LBC_ORG` = org slug en desarrollo (multiliga, ver `Docs/07`)

## Verificación

- `npm run build` debe pasar sin errores antes de cualquier commit.
- QA headless de páginas (patrón del harness de lgrestoreuy) cuando haya rutas: `Docs/10`.

## Known issues

- `npm install` en esta máquina es lento (SD al 87%): mantenerlo en background.
- Reglas exactas de la liga (sistema de puntos de tabla, walkovers, cortes de edad de formativas, nombres reales de categorías) están marcadas como **[a confirmar con la liga]** en cada doc y se resuelven con la secretaría antes de la Fase 1.
