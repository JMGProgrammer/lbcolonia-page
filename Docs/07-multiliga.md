# 07 · Multiliga (multi-tenant) y fase de producto

Última actualización: 2026-10-21

La idea final no es una web para una liga: es **una plataforma para ligas**, que arranca con Colonia como cliente fundador. El diseño multi-tenant es desde la migración 0001 (todo lleva `org_id`), así que el día que se venda la segunda liga no hay refactoring migratorio: hay dominio + filas.

## 1. Modelo de tenants

| Concepto | Implementación |
|---|---|
| Liga = org | fila de `orgs` con slug, branding, plan |
| Dato aislado | RLS por `org_id` (`Docs/03`); un delegado de una org no ve nada de otra |
| URL | subdominio `liga.lbcweb.app` (dominio técnico a definir) o el dominio custom de la liga |
| Identidad visual | colores/logo por org; plantillas únicas para todas |
| Features por liga | flags en `orgs.config_json` (estadísticas detalladas on/off, sugerencias de sanciones visibles, etc.) |

## 2. Enrutamiento por dominio (lo único de infra que agrega la fase)

- Astro con adapter Vercel en modo SSR mínimo + **middleware que lee el Host** de la request:
  1. `host → org` (tabla de dominios cacheada en memoria/edge con TTL corto);
  2. ese `org_id` queda fijo para la request (cookie firma + área de pages server-side);
  3. todas las páginas públicas consultan con `org_id` explícito: la RLS re-chequea.
- Piloto (una sola liga): el middleware resuelve de todas maneras (un único dominio) — así no se cambia nada al escalar; se agregan filas.
- Dominio custom de una liga: se agrega en Vercel + registro en la tabla de dominios. SSL lo maneja Vercel.
- **Sin data cruzada de ningún tipo**: el anon ve siempre el branding de la org del dominio y nada de otras ligas (RLS + org fija por request).

## 3. Qué cambia al pasar de 1 liga → N

- Un landing comercial propio (presentación de la plataforma, demos, contacto) — sitio separado, no el panel ni el sitio de una liga.
- Superadmin (Juan) desde una consola simple: crear org, estado de licencia, invitar liga_admin.
- Facturación: 1 a 5 ligas al año no justifica un sistema de billing; planilla + vencimiento en el calendario alcanza. Automatizar cuando sea una molestia real (`Docs/08`).
- Cada liga nueva necesita un onboarding repetible: alta de org, carga de clubes + delegados + fixture (una sola checklist de instalación que se mejora liga a liga), seed de prueba y video de capacitación.
- El seed de prueba (`supabase/seed.sql`) doble uso: demo "liga de ejemplo" para vender (tabla/fixture/estadísticas con datos ficticios) y datos para QA.

## 4. Nombre del producto genérico

LBC es la web dela liga de Colonia; si se escala a plataforma, el nombre genérico (para el landing y el dominio técnico) se decide con tiempo — candidatos a evaluar: `ligaweb`, `letasports`, `basquetinterior`... **Decisión aplazada a Fase 8.** El branding de cada liga siempre pasa por encima del de la plataforma.

## 5. Qué NO se promete a una segunda liga (guardas honestas)

- No se importa data histórica a mano por cada liga: el histórico ante juego es "empieza desde cero con esta temporada" (import histórico del Excel viejo es servicio aparte, cobrado).
- No se personalizan features por liga más allá de los flags: forks por cliente matan el producto. Las reglas del gimnasio son "reglas_json", no código.
- No hay integración con FUBB/Gesdeportiva prometida (si la piden, se evalúa como proyecto aparte).
