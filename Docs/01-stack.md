# 01 · Stack y arquitectura

Última actualización: 2026-10-21

## 1. Stack elegido

| Capa | Tecnología | Por qué |
|---|---|---|
| Sitio público | **Astro** (última estable) + islands puntuales | El 90% del sitio es lectura; pre-render, JS casi cero, SEO de fábrica |
| Estilo | **Tailwind CSS 4** (`@tailwindcss/vite`, tokens en `globals.css`) | Patrón ya usado en lgrestoreuy y uruprev; velocidad + consistencia |
| Datos | **Supabase**: Postgres + Auth + Storage + RLS | Sin servidor propio; RLS como única barrera; Storage para escudos, fotos y planillas |
| Panel admin | mismo Astro + `@supabase/supabase-js` en el navegador + islands **Alpine.js** | CRUD con auth, no server actions; patrón validado en lgrestoreuy |
| Hosting | **Vercel** (adapter `@astrojs/vercel`) | Deploy desde el repo; SSR solo lo mínimo |
| Dominio | dominio propio de la liga (a gestionar) + subdominio por liga en la fase multiliga | `Docs/07` |
| Notificaciones | fuera del MVP; WhatsApp y mail manual en fases posteriores | `Docs/09` |

## 2. Decisión registrada: Astro vs Next.js (2026-10-21)

Comparado honestamente; decisión: **Astro**, con Next.js como opción de evolución (no como presente):

- **El producto es 90% lectura**: fixture, tablas, resultados, noticias. Eso es HTML cacheable: Astro lo pre-renderiza y revalida on-demand (`s-maxage=60`), que es exactamente lo que hace falta; no un árbol React hidratado.
- **El panel es formularios, no realtime**: delegado envía planilla → liga verifica → se pubblica. Es un CRUD con auth + RLS; Server Actions de Next.js no aportarían poder extra acá.
- **Costo Vercel**: lo estático amortiza gratis en el plan Hobby; el SSR se reserva para lo mínimo de multiliga. Next.js gastaría más invocaciones sin beneficio visible para este caso.
- **Multiliga barata**: cada liga nueva = filas nuevas + dominio; no un server más.
- **Puerta de evolución**: si más adelante el proyecto demanda estadísticas en vivo durante el partido (Supabase Realtime, play por play), se puede agregar una island pesada o una subruta app-like sin reescribir. Recién ahí vale la pena revisar Next.js. La decisión queda asentada, no como dogma.

## 3. Arquitectura en un diagrama

```
                 ┌─────────────────────────────┐
   hincha        │           Vercel            │
 (celular) ─────▶│ Astro: prerender + cache    │
                 │ + islands interactivas      │
   delegado      │                             │
   liga ────────▶│ /admin (SSR, auth por rol)  │
                 └──────────────┬──────────────┘
                anon key (público) │
                user JWT  (panel)  │
                 ┌──────────────▼──────────────┐
                 │          Supabase           │
                 │  Postgres + RLS + views     │
                 │  Auth (delegados / liga)    │
                 │  Storage (escudos / planillas)│
                 └─────────────────────────────┘
```

- El público viaja con **anon key**: la RLS garantiza que solo se lee lo publicado.
- El panel autentica con Supabase Auth y escribe según el rol (policies en `Docs/03`).
- La tabla de posiciones y los líderes estadísticos son **views SQL** sobre partidos `finalizado`: nada se calcula en JS.

## 4. Render y caché (reglas concretas)

| Página | Render | Cache |
|---|---|---|
| Home | prerender + revalidate | `s-maxage=60` |
| Fixture / tabla / stats / bracket | prerender + revalidate | `s-maxage=60` |
| Ficha de partido | prerender + revalidate | `s-maxage=60` |
| Noticias / fichas de clubes | prerender + revalidate | `s-maxage=300` |
| `/admin/**` | SSR dinámico | `no-store` |

Publicar un partido dispara la revalidación vía endpoint interno (`/api/revalidate`) llamado desde el flujo de verificación del panel. Si ese disparo falla, el `s-maxage` igual actualiza la página en ≤ 60 s: lento pero seguro.

## 5. Seguridad

- Cliente público: **solo anon key**. Service_role jamás en el repo ni en el navegador; si algún día se necesita, va en una acción servidor aislada con su secret en Vercel.
- Storage: buckets públicos para `escudos`, `noticias`, `auspiciantes`; bucket **privado** `planillas` (fotos de planillas firmadas: acceso por policies de Storage según el club correspondiente).
- CSP estricta desde el día 1 (patrón lgrestoreuy: `data-confirm` en vez de `onclick` inline, que la CSP bloquea).
- Escrituras del panel validadas doblemente: constraints y checks en la base, no solo el formulario; triggers para reglas que la RLS no cubre.

## 6. Entorno de desarrollo

- `npm run dev` con `localhost` (nunca `127.0.0.1`, que es IPv6); `--host` para probar desde el celular físico (patrón lgrestoreuy).
- Supabase: proyecto cloud único; **migraciones numeradas y versionadas en Git** (`supabase/migrations/0001_...`) — 0001 es el esquema completo de `Docs/02`.
- Seed de Datos de prueba separado (`supabase/seed.sql`): 8 clubes ficticios con jugadores para demo y QA (detalle en `Docs/10`).
- `npm install` en esta máquina es lento (SD al 87%): mantenerlo en background.

## 7. Estructura del proyecto (cuando exista código)

```
src/
  pages/             público (/, /fixture, /tabla, /clubes, /noticias …)
  pages/admin/       panel (liga + delegados)
  islands/           piezas interactivas (filtros, editor de planilla, bracket)
  components/        UI compartida
  layouts/           BaseLayout (público) y AdminLayout
  lib/               clientes supabase, config, helpers
Docs/                 esta serie numerada
supabase/migrations/  SQL versionado
supabase/seed.sql     datos de prueba
```
