# 09 · Fases y roadmap

Última actualización: 2026-10-21

Cada fase con **qué es "hecha"** (DoD). Reglas transversales: `npm run build` sin errores y QA mínimo (`Docs/10`) antes de mergear; nada se adelanta sin pedirle permiso al flujo.

## Fase 0 — Definición ✅ (2026-10-21)

Docs de esta serie + decisiones de stack y modelo. Con Juan se cierra acá antes de apretar un botón: revisar los 3 docs clave (00, 08, 09) juntos.

**DoD cumplida**: este directorio existe con toda la serie y el AGENTS.md.

## Fase 1 — Base técnica (est. 1 semana)

- Repo Astro limpio (TS strict, Tailwind 4, Vercel adapter) + estructura `Docs/01 §7`.
- Proyecto Supabase creado; `0001` con esquema completo de `Docs/02` + RLS base de `Docs/03` + `orgs` seed con LBC.
- **Preguntas de `Docs/02 §7` resueltas con la secretaría** (nombres de categorías, puntos de tabla, walkovers) — si no hay respuesta, defaults FIBA y flag abierto.
- Seed de datos de prueba (`supabase/seed.sql`) con 8 clubes ficticios + jugadores + 1 torneo en curso.

**DoD**: build verde, anón puede leer el seed vía API con RLS y no puede escribir; delegado/liga probado en Supabase Studio.

## Fase 2 — Sitio público MVP (est. 2 semanas)

- Home + fixture + tabla + ficha de partido + clubes + sanciones + legales (`Docs/04`), con el seed.
- SEO base: metadata, sitemap, robots, JSON-LD de partido.
- QA responsive 320–1300px + Lighthouse targets (`Docs/10 §3`).

**DoD**: el seed se navega sin recargas de datos falsos; capturas listas para mostrar.

## Fase 3 — Panel de la liga (est. 2 semanas)

- Panel `/admin` con liga_admin/liga_ayudante: torneos, fixture (carga masiva pegada + individual), ABM de clubes/equipos/jugadores/fichas, confirmar/desconfirmar, publicar partido a mano.
- Revalidate del público al publicar.

**DoD**: con el seed, la liga puede cargar un fixture desde el Excel pegado y publicar resultados; el efecto se ve en el público.

## Fase 4 — Delegados y planillas (est. 2 semanas)

- Faces delegado: mis partidos + carga de planilla en 3 bloques + foto de papel + disputas + roster (`Docs/05 §1B`).
- Verificación contra foto en la mesa de la liga, diff de datos, publicación con auditoría (`audit_log`).
- Storage privado `planillas` con policies; email de dispute no: todo avisa dentro del panel.

**DoD**: una jornada completa simulada: delegado carga desde el celu con foto, visitante disputa, liga corrige con la foto y publica; las policies negativas de `Docs/03 §5` pasan.

## Fase 5 — Complejidad del torneo (est. 2 semanas)

- Playoffs: series, bracket, rúbrica de ganador según reglamento.
- Sanciones con contador de cumple + vista pública.
- Estadísticas líderes + ficha de club con roster.
- Noticias + páginas editables + auspiciantes.

**DoD**: un torneo simulado se juega de inicio a playoffs; archivos históricos legibles tras pasarlo a `finalizado`.

## Fase 6 — Piloto real con la Liga de Colonia ⏳ (a activar con Juan)

- Crear la org real; cargar clubes/delegados/fixture de la temporada vigente; invitar delegados (video de 3 min + sesión de 1 h).
- Backups: esquema pg_dump semanal; `FEATURES.md` como canal de pedidos de la liga.
- Fallback listo: planilla por WhatsApp → carga manual por la liga.

**DoD**: una jornada real del torneo de Colonia completa el ciclo en producción, sin que Juan cargue nada a mano.

## Fase 7 — Endurecer (est. 1 semana)

- Seguridad: negativas de RLS completas, CSP, sanitización de imports de fixture.
- Performance real desde el caché del celu (dispositivo físico de Juan) y del hincha.
- Legales de la liga + privacidad/terminos/creditos.

**DoD**: checklist completa de `Docs/10` sin pendientes críticos.

## Fase 8 — Comercialización (solo si el piloto cierra bien)

- Golpe de pilotos: 2ª liga aprox; landing de producto con el seed como demo; pricing final de `Docs/08 `.
- Decisión del nombre genérico de la plataforma y dominio técnico; enrutamiento multiliga ya vivo desde 0001.

**DoD**: primera licencia firmada (o decisión de que no sale, con notas).

## Fase 9 — Futuro (vía de Next.js y realtime)

- Estadísticas en vivo durante el partido (island sobre Supabase Realtime), notificaciones por WhatsApp, app "en vivo" para el anotador oficial en la mesa (es aquí sí que puede requerir un subárbol app-style — recién ahí se re-evalúa Next.js).

## Versionado

Igual que lgrestoreuy: `v0.N` para feature grande, patch para fix; `v1.0` no se dispara por deploy sino por primera temporada completa de piloto cerrada. `scripts/versionar.sh` cuando exista rama principal.
