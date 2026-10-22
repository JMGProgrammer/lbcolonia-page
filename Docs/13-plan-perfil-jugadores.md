# 13 · Plan de integración: Páginas de perfil de jugador y estadísticas avanzadas

> **Objetivo**: Dotar a la web de la LBC de perfiles personales para cada jugador federado de la liga (Primera División y Formativas U10 a U22), con estadísticas detalladas por temporada, promedios, porcentajes de tiro, gráficos de rendimiento e historial completo de partidos jugados.

---

## 1. Visión y propuesta de valor

El perfil de jugador transforma una web institucional de resultados en una **plataforma deportiva viva**:
1. **Para los jugadores y familias**: Cada chico y jugador tiene su link oficial (`lbc.uy/jugadores/martin-sosa`) para compartir en redes, seguir su evolución y sentirse parte del básquetbol federado profesional.
2. **Para los clubes y entrenadores**: Seguimiento del desarrollo deportivo de formativas a primera (minutos, tiros, impacto defensivo y puntos).
3. **Para la Liga y Sponsors**: Activo comercial de alto impacto (ej. "Jugador de la Fecha", "Líder de Anotación auspiciado por Montes del Plata").

---

## 2. Arquitectura de datos (Supabase)

### 2.1. Tabla base existente: `jugadores` y `fichas`
Actualmente en `supabase/migrations/0001_esquema.sql`:
- `jugadores`: `id`, `org_id`, `nombre_completo`, `fecha_nacimiento`, `foto_url`, `notas`.
- `fichas`: `id`, `org_id`, `jugador_id`, `equipo_id`, `torneo_id`, `dorsal`, `estado`.
- `planilla_stats`: `id`, `planilla_id`, `ficha_id`, `dorsal`, `puntos`, `rebotes`, `asistencias`, `robos`, `tapas`, `faltas`, `minutos`.

### 2.2. Extensiones recomendadas (Migration 0004)
Para habilitar porcentajes de tiro avanzados cuando la planilla lo registre:
- En `jugadores`:
  - `posicion`: text null (`Base`, `Escolta`, `Alero`, `Ala-Pívot`, `Pívot`).
  - `altura_cm`: int null (ej. `188`).
  - `mano_habil`: text null (`Derecha` | `Izquierda`).
  - `slug`: text unique (ej. `martin-sosa-plaza`).
  - `ciudad_origen`: text null (ej. `Colonia del Sacramento`, `Rosario`, `Nueva Helvecia`).
- En `planilla_stats` (columnas opcionales para planillas avanzadas):
  - `tc_intentados`, `tc_convertidos` (Tiros de campo dobles).
  - `t3_intentados`, `t3_convertidos` (Triples).
  - `tl_intentados`, `tl_convertidos` (Tiros libres).

### 2.3. Vistas SQL públicas (Views Definer con RLS WHERE)
1. **`v_jugador_perfil`**:
   Datos bio del jugador, equipo actual, categoría, club y foto.
2. **`v_jugador_totales_temporada`**:
   Agregación de partidos jugados (PJ), puntos totales (PTS), promedio por partido (PPG), rebotes (RPG), asistencias (APG), robos, tapas, faltas y porcentajes efectivos (`%TC`, `%3P`, `%TL`).
3. **`v_jugador_partidos_log`**:
   Lista cronológica de partidos verificados y publicados: fecha, rival, condición (local/visitante), resultado (W/L), marcador final, minutos y planilla individual completa.

---

## 3. Especificación visual y experiencia de usuario (UI/UX)

La página `src/pages/jugadores/[slug].astro` se divide en 4 bloques:

```
+------------------------------------------------------------------+
| HERO CARD: Foto oficial recortada + Dorsal translúcido de fondo  |
| Nombre grande, Club actual (Escudo), Categoría, Posición, Altura |
+------------------------------------------------------------------+
| BENTO DE PROMEDIOS DE TEMPORADA (4 Big Numbers + Porcentajes)    |
| [ PPG: 18.5 ]    [ RPG: 7.2 ]    [ APG: 4.1 ]    [ EFF: +21.4 ]  |
| [ %TC: 52.4% ]   [ %3P: 38.0% ]  [ %TL: 81.5% ]  [ PJ: 8 ]       |
+------------------------------------------------------------------+
| GRÁFICOS INTERACTIVOS (Rendimiento por Jornada)                  |
| - Gráfico 1: Evolución de Puntos fecha a fecha (Línea/Barras)    |
| - Gráfico 2: Distribución de puntos (Dobles, Triples, Libres)    |
| - Gráfico 3: Radar de impacto (Anotación, Pases, Rebotes, etc.)  |
+------------------------------------------------------------------+
| GAME LOG (Historial detallado de partidos jugados)               |
| Fecha | Rival | Res | MIN | PTS | REB | AST | ROB | TAP | FAL    |
| 17/10 | CAJ   | W   | 28  | 22  |  8  |  3  |  2  |  1  |  2     |
+------------------------------------------------------------------+
```

### 3.1. Librería de Gráficos liviana
- Implementación con **SVG nativo generado en SSR** o **Chart.js / ApexCharts** cargado con dynamic import en el cliente (`client:visible`), garantizando 0 impacto en el peso inicial de la página y excelente rendimiento móvil.
- Paleta acorde al sistema de diseño LBC (`Docs/11`): acentos en `orange-500`, `gold-400`, fondo `navy-950` con contraste de estadio.

---

## 4. Puntos de integración en el sitio existente

1. **Ficha de Club (`/clubes/[slug]`)**:
   - Cada jugador en la lista desplegable de la categoría (`JugadorFicha.astro`) se convierte en un enlace directo a su perfil: `/jugadores/[slug]`.
2. **Ficha de Partido (`/partidos/[id]`)**:
   - En la tabla de estadísticas del boxscore, el nombre del jugador es un enlace a su perfil.
3. **Nueva sección de Estadísticas y Líderes (`/estadisticas`)**:
   - Top anotadores, líderes en triples y mejores valoraciones de cada categoría con acceso al perfil.

---

## 5. Fases de ejecución

| Fase | Tareas | Entregable |
|---|---|---|
| **Fase 1: Datos** | Migration SQL con campos bio y views `v_jugador_totales` y `v_jugador_partidos_log`. Actualización de `db-types.ts` y `data.ts`. | Base lista y testeada |
| **Fase 2: Layout & Hero** | Creación de `src/pages/jugadores/[slug].astro`, Hero con foto de jugador/placeholder oficial, datos bio y Bento de promedios. | Página navegable |
| **Fase 3: Game Log** | Historial de partidos con boxscore interactivo y adaptado a móvil. Enlaces a `/partidos/[id]`. | Historial completo |
| **Fase 4: Gráficos** | Componente de visualización de rendimiento (evolución por fecha y distribución de tiro). | Gráficos reactivos |
| **Fase 5: Vinculación** | Conectar perfiles desde `/clubes/[slug]` y `/partidos/[id]`. | Navegación cruzada 100% |
