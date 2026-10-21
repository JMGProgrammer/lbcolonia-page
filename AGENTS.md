# AGENTS.md — Instrucciones para agentes en lbc-web

## Antes de programar

1. Leer `Docs/00-overview.md` y `Docs/01-stack.md` para entender qué es y con qué se hace.
2. Leer `Docs/09-fases.md` para saber en qué Fase va el proyecto y qué se construye ahora. **No adelantar trabajo de fases futuras** sin que el usuario lo pida.
3. Para tocar datos/seguridad: leer obligatoriamente `Docs/02-datos.md` y `Docs/03-roles-accesos.md`.

## Decisiones fijas (no re-abrir sin motivo)

- Stack: Astro + Tailwind 4 + Supabase + Vercel. Next.js es opción **futura**, no actual.
- Multi-liga desde 0001: **todas** las tablas de contenido llevan `org_id`.
- Solo anon key en cliente. Jamás service_role fuera de acciones servidor de la máxima confianza (autohospedadas).
- Fecha y hora en `timestamptz`, zona de referencia del sitio `America/Montevideo`.
- UI en español (rioplatense, tuteo no: trato informal correcto, "vos" no en textos de UI — usar neutro).
- RLS primero: ninguna consulta pública confiada a filtros de aplicación; las policies son la única barrera.

## Convenciones

- Commits en español, estilo conventional: `feat:`, `fix:`, `docs:`, `chore:` (esquema de tags completo en `Docs/09-fases.md`, igual que lgrestoreuy).
- Documentación en `Docs/` con la serie numerada; agregar doc nuevo al índice del README.
- Ideas y pendientes van a `FEATURES.md` de la base, no a los docs de specs.
- Sincronización de notas de proyecto en Obsidian tras trabajo significativo (proyecto canónico: `02-Projects/lbc-web`).

## Verificación mínima por commit

- `npm run build` sin errores.
- Si se tocó RLS o sus views: negativas de rol probadas (delegado no puede leer planillas de otro club, anon no puede escribir). Ver `Docs/10`.
- Página pública nueva: probar de 320px a 1300px (móvil primero).
