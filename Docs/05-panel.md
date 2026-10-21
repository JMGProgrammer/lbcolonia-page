# 05 · Panel admin (`/admin`)

Última actualización: 2026-10-21

Un solo panel, dos caras según rol (patrón lgrestoreuy: Astro + Alpine + supabase-js, `no-store`, CSP estricta). Lengua de UI: español neutro, acciones en dos pasos máximo, tipografía grande, funciona bien en el celular (los delegados cargan desde el gimnasio).

## 1. Caras del panel

### A) Secretaría de la liga (`liga_admin` / `liga_ayudante`)

| Sección | Qué hace |
|---|---|
| **Resumen** | Pendientes del día: planillas por verificar, fichas por confirmar, disputas abiertas, partidos sin programa de fin de semana. "Próximos pasos" dinámicos |
| **Torneos** | Crear/editar torneo: categoría, temporada, formato, `reglas_json` (con defaults visibles), `estadisticas_detalladas` on/off, estado |
| **Fixture** | Carga promedio + individual. Import masivo: pegar texto del Excel (formato esperado documentado en pantalla con ejemplo) o cargar a mano partido por partido. Edición de fecha/hora/sede con validación de solapes de equipo (dos partidos el mismo día = mala señal, avisa) |
| **Planillas** | Inbox de verificación: lista de partidos con planilla `borrador`, abre al lado `diff` "lo que cargó el delegado" vs "la foto del papel", corrige y confirma → `publicado`. Historial de correcciones sobre publicados (auditoría básica: quién cambió qué y cuándo) |
| **Disputas** | Caso por caso: ver foto, decidir (acepta planilla / corrige / pide re-carga). Resuelve con un botón, con nota obligatoria si elimina/altera datos del delegado |
| **Sanciones** | Alta de sanción (jugador/técnico, motivo, cantidad de partidos), contador automático de partidos pendientes de cumple con la lista de partidos en que se descuenta. Dar de baja anticipada con nota |
| **Clubes y jugadores** | ABM de clubes (escudo, colores, redes), equipos, jugadores (con alerta de duplicado), confirmación de fichas `solicitadas` |
| **Noticias / Páginas** | Markdown con preview + portada; publicar/despublicar; destacados para la home |
| **Auspiciantes** | ABM con nivel y orden (solo `liga_admin`) |
| **Export** | Descarga CSV de: tabla, stats por torneo, clubes/jugadores/fichas (respaldo y para volver a un Excel de siempre) |

### B) Delegado de club (`delegado`)

| Sección | Qué hace |
|---|---|
| **Mis partidos** | Próximos y jugados de su club. Solo ve los suyos (RLS) |
| **Cargar planilla** | Cuando su club fue local: formulario `planilla del partido` (marcador, y una fila por jugador presente del **propio club y del rival**, fichas existentes + alta rápida "jugador nuevo"), minutos/puntos/faltas + detallado si el torneo pide. Adjunta **foto del papel** (obligatoria, compresión client-side). Guarda `borrador` — un partido puede re-editarse mientras esté borrador |
| **Disputar** | Cuando su club fue visitante y ya hay planilla borrador del rival: botón "disputar" + motivo. Se abre caso en la sección de la liga |
| **Mi club** | Roster: altas de ficha (estado `solicitada`, con fecha de nacimiento y dorsal), bajas, foto — todo pasa por confirmación de la liga |
| **Mis sanciones** | Ver las activas de sus jugadores con partidos pendientes |

## 2. Formularios — decisiones específicas

- **Planilla en 3 bloques** (como el papel): resultado + jugadores locales + jugadores visitantes. Guardado por bloque: cada bloque se persiste al completarlo, para que una conexión floja no pierda nada. El estado de borrador queda siempre a la vista ("Guardado hace 2 min").
- **Autocompletado de jugadores**: las fichas existentes de ambos equipos, ordenadas por dorsal; el botón "+ jugador nuevo" crea la ficha `solicitada` en el mismo paso.
- **Validaciones con tacto**: la suma de puntos no cuadra con el marcador → aviso suave, no bloqueo (el papel manda); dorsal repetido → aviso; jugador de otra categoría → bloqueo con explicación.
- **Todo confirmación destructiva CSP-safe** (`data-confirm` + diálogo propio, patrón lgrestoreuy).
- **No hay texto de estrategia**: es un formulario de datos, no un CMS. Cero opciones decorativas.

## 3. UX de carga masiva del fixture (la sección más delicada)

Formato de pegado esperado:
```
Fecha;Hora;Sede;Local;Visitante;Jornada
21/10/2026;20:30;Gimnasio Plaza;Plaza Colonia;Jardines;5
```
- Se mapean nombres de club → equipo con fuzzy-match y muestra tabla de revisión previa ("confirma estos 14 partidos") antes de insertar. Nada se escribe sin revisar la vista previa.
- Si un club no existe se ofrece crearlo en el punto (o saltar esos partidos y avisar).

## 4. Auditoría mínima

- Publicación de partido guarda `verificada_por`, `verificada_at`.
- Edición de resultados/post-publicación guarda el diff en `audit_log` (tabla simple: quién, qué fila, antes/después JSON, cuando).
- `audit_log` es solo lectura para `liga_admin` (no editable).

## 5. Navegación del panel

- Barra superior con: org/selección, estado de sesión, campanita de pendientes (badge).
- En celu: navegación inferior con secciones escrollables (patrón nav-cinta de lgrestoreuy, ítems ≥ 4.25rem).
- Sesión separada del sitio público: pasar del panel al público lleva aviso; el delegado nunca "cae" de un lado al otro sin enterarse.
