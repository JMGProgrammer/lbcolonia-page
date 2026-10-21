# 10 · QA, rendimiento y datos de prueba

Última actualización: 2026-10-21

## 1. Barra mínima por commit

- `npm run build` verde.
- Si se tocó RLS: las 6 negativas de `Docs/03 §5` probadas en Supabase Studio o con el cliente.
- Página pública nueva: recorrerla manualmente de 320 a 1300px.
- Panel: las acciones destructivas con `data-confirm` (nunca `onclick` inline, la CSP las bloquea).

## 2. Datos de prueba (`supabase/seed.sql`)

- **8 clubes ficticios** con nombres estilo interior (identificados como demo en pantalla), escudos placeholder, colores contrastantes.
- **Torneo real opcional**: el fixture completo de Primera División 2026 ya está transcrito del afiche oficial (`assets/images/afiche-1era-lbc-fixture.jpg`) — 4 clubes reales, 6 fechas con anfitrión por fecha. Sembrarlo como torneo real de la org LBC: sirve para demo de venta y para arrancar el piloto con datos verdaderos (la fecha 1 del 17/10 ya se jugó; resultados a pedirle a la liga).
- 1 torneo en curso con doble jornada jugada + 1 en playoffs simulados + 1 histórico finalizado del año pasado (para probar archivo).
- Fichas: jugadores duplicados a propósito (control anti-duplicado), jugador sobre-edad en formativas (aviso en UI), sanciones activas con 3 partidos a cumplir.
- 1 planilla borrador + 1 disputada + 1 verificada (para los 3 estados del inbox).

## 3. QA de responsive (patrón lgrestoreuy)

- Sweep con Chrome headless (puppeteer-core + Chrome del sistema) y CSS real del build; harness en `/tmp/opencode` no en el repo.
- Rutas mínimas a barrer: home, fixture, tabla, ficha de partido, club, noticia, panel (inbox + planilla).
- Anchos probados: 320 / 360 / 414 / 768 / 1024 / 1300. Sin scroll horizontal documental en ninguna.
- Nav del panel en celu: cinta deslizable, ítems tocables ≥ 4.25rem.
- Spec del harness (recreable por cualquier agente sin memoria local; no va al repo): script Node con `puppeteer-core` + Chrome del sistema (`executablePath: '/usr/bin/google-chrome'`, headless, `--no-sandbox`), contra el dev server (`127.0.0.1:4321`). Dos scripts:
  - `barrido.cjs`: 13 anchos (320–1300) × ~15 rutas del sitio; por cada combinación compara el `scrollWidth` del documento contra el viewport y lista las rutas con overflow.
  - `diag2.cjs`: para casos puntuales (ancho + ruta), lista los elementos cuyo borde derecho excede el viewport.
  - Mantener la lista de rutas al día con el seed vigente (los partidos van por UUID: ajustar si cambian los datos).
- Arranque del dev en Astro 7 (2026-10-21): `astro dev` daemoniza solo y `localhost` resuelve a `[::1]` (IPv6) — el harness habla IPv4, así que arrancar con `--host 127.0.0.1` y parar con `npx astro dev stop`; si algo rinde `connection refused`, verificar el bind con `ss -tlnp | grep 4321`.

## 4. Rendimiento (medido, no estimado)

- Lighthouse móvil en home y `/tabla`: Performance ≥ 90, Accessibility ≥ 95, Best Practices ≥ 95, SEO ≥ 95.
- El peso del JS del público (< 60KB gzip total peor caso) verificado en el build que lista los assets del bundle de islas.
- Fotos: siempre transform del CDN (`width`, `quality`, webp); ninguna imagen > 150KB en el HTML inicial.
- Prueba de pico: página de tabla con un cache-buster tras publicar (simular la ola del sábado a la noche); comprobar que el cache acelera la segunda carga.

## 5. Seguridad (checklist por release)

- [ ] Anon: no ve planillas, no ve partidos no publicados, no ve orgs ajenas (6 negativas de `Docs/03 §5`).
- [ ] Delegado: no edita resultados, no publica, no toca auspiciantes, no ve sanciones de otras fichas de clubes que no sean las suyas.
- [ ] Storage: bucket `planillas` sin URL pública; signed URLs solo para roles con permiso.
- [ ] Secrets: solo `SUPABASE_URL` + anon key + (opcional) secret de revalidate; ninguna key de servicio en `.env` locales ni en Git.
- [ ] CSP revisada tras cada island nueva.
- [ ] Backups: pg_dump semanal automatizado por cron en el servidor; restauración de prueba verificada 1 vez al mes.

## 6. QA de fecha y hora

- Fechas en la db en UTC; siempre mostradas en `America/Montevideo`.
- Probar un partido cargado a las 23:30 local: no debe caer a otro día en la vista ni en el JSON-LD.

## 7. Control de pendientes

Los pendientes activos de QA van a `FEATURES.md` (checkbox `[fix]`), como en lgrestoreuy. En la Fase 0 no hay código que barrer: la primera pasada real de QA llega con el seed de la Fase 1.
