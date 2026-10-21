# 03 · Roles, accesos y RLS

Última actualización: 2026-10-21

Seguridad por diseño: **las policies de Postgres son la única barrera**. La app nunca "confía" en sus propios filtros. Solo el anon key sale al navegador público; el resto viaja con el JWT del usuario autenticado.

## 1. Roles y qué puede cada uno

| Rol | Quién | Alcance |
|---|---|---|
| `anon` (no autenticado) | hincha | Solo lectura de filas publicadas de su org |
| `delegado` | un dirigente por club | Lectura de su org + escritura acotada a **su club**: planilla del partido donde su club es local, fichas de su club |
| `liga_ayudante` | colaborador de la secretaría | Como liga_admin pero sin zonas delicadas (puede tocar noticias, partidos, planillas; no org config ni auspiciantes/cobros) |
| `liga_admin` | secretaría / presidente de la liga | Todo dentro de **su org**: fixture, verificación, sanciones, clubes, jugadores, noticias, auspiciantes, páginas |
| `superadmin` | Juan | Todas las orgs; crea orgs, activa planes, fuerza correcciones. Existe solo para administración de la plataforma |

Reglas de cómo se resuelve el rol de un usuario:
- La membresía vive en `org_members (org_id, user_id, rol, club_id)`. El dominio define la org activa (en el piloto, una sola).
- Un usuario puede tener roles distintos en orgs distintas (fase multiliga).
- Altas: la secretaría/Juan invita por correo desde el panel (mensaje con link de verificación de Supabase Auth). Sin registro autoservicio público en MVP.

## 2. Policies por tabla (resumen accionable)

Principio general: fila visible o editable **solo si su `org_id` pertenece a la org activa del dominio**, más las reglas por rol. Helper SQL: función `rol_en_org(org_id)` que lee `org_members` del JWT.

| Tabla | anon (SELECT) | delegado | liga_admin/ayudante |
|---|---|---|---|
| `orgs, categorias, clubes, equipos` | sí (org del dominio, activa) | sí | todo write de su org |
| `torneos` | sí (solo con estado `proximo|en_curso|finalizado`) | lectura | write |
| `partidos` | solo `publicado = true` **y** `programados` del fixture oficial | lectura de su org + write de la planilla de partidos como local (ver abajo) | write completo; `publicar` solo liga_admin |
| `planillas` | nunca (la tabla entera niega SELECT a anon) | su club como local: insert/update mientras `borrador`; `disputar` si es visitante | write; verificación |
| `planilla_stats` | solo de planillas `verificadas` (vía join a partido publicado) | write las de la planilla borrador de su club | write |
| `jugadores / fichas` | sí (nombres y fotos de rosters publicados) | insert/update fichas de **su club** (estado `solicitada`) | write; solo la liga `confirma` fichas |
| `noticias / paginas` | solo `publicado = true` | lectura | write (borrador privado) |
| `auspiciantes` | solo `activo = true` | lectura | write de liga_admin (ayudante: no) |
| `sanciones` | solo `publicado = true` | lectura de las suyas | write |
| `orgs (config, plan)` | solo branding público (nombre, logo, colores) | no | no (solo superadmin toca plan/licencia) |

Puntos finos:
- **El fixture (programado) es público**, sí: la agenda abierta es parte del producto. Lo no-publicable para anon son resultados y stats de partidos todavía no verificados.
- La planilla nunca va completa al público en `borrador`; el detalle público del partido se arma desde `planilla_stats` de planillas `verificadas` únicamente (view `v_detalle_publico`, `security_invoker = false` con su propia policy interna).
- Nomás delegados del club local insertan planilla; el visitante tiene permiso especial de `disputar` (un update limitado de estado + motivo). Ambos tienen ventana: `now() - publicado no aplica` — la ventana la controla el estado y el flujo (`Docs/06`).

## 3. Storage (policies de buckets)

| Bucket | Visibilidad | Quién escribe |
|---|---|---|
| `logos` (escudos de clubes + logo de org) | público | liga_admin |
| `noticias` | público | liga_admin/ayudante |
| `auspiciantes` | público | liga_admin |
| `planillas` | **privado** | delegado local (foto de su planilla) + liga; lectura: liga y clubes del partido |

El bucket privado sirve para verificar contra el papel firmado. Si en el futuro se quiere mostrar la foto al público, se copia/serve por signed URL (decisión de Fase 4+).

## 4. Autenticación (Supabase Auth)

- Correo + contraseña, con invitación de primera entrada tipo magic-link: el delegado recibe el link y define su contraseña.
- Panel: sesión persistente, cambio de contraseña, recuperación standard.
- Nada de OAuth social en MVP (agregarlo sería innecesario y confuso para la audiencia).
- Doble invitación: liga_admin invita a delegados con club asignado; superadmin invita a liga_admin.

## 5. Qué probar sí o sí cuando exista SQL (negativas)

1. `anon` intenta SELECT de `planillas` → 0 filas.
2. `delegado` de club A intenta SELECT de planilla del club B → 0 filas.
3. `delegado` intenta UPDATE de un partido (resultado) → denegado.
4. `delegado` intenta publicar (`publicado = true`) → denegado.
5. `liga_ayudante` intenta tocar `auspiciantes` → denegado.
6. `anon` de org A con dominio de org B → nada de org B visible.

Estas se quedan como checklist fija en `Docs/10` y se corren en cada migración que toque RLS.
