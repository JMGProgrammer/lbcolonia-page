# 00 · Overview — idea general detallada

Última actualización: 2026-10-21

## 1. Qué es

**LBC Web** es la web oficial de la liga de basquetbol local del departamento de Colonia (Uruguay): un sitio público con toda la información del torneo y un panel para que esa información se cargue sola, por los propios protagonistas.

Hoy esa información vive en pizarras de gimnasio, planillas de papel, grupos de WhatsApp y fotos sueltas de Facebook. La web la convierte en:

- un **archivo vivo**: tabla de posiciones, fixture, resultados, estadísticas, sanciones y noticias, ordenados por competencia;
- una **vidriera** para clubes, jugadores, auspiciantes y la propia liga;
- un **flujo de carga autogestionado**: los delegados levantan el resultado tras el partido y la liga verifica; nadie (ni Juan) carga nada a mano publicación por publicación.

Nombre de trabajo: **LBC** (Liga de Basquetbol de Colonia). Si el proyecto escala a plataforma multiliga, el nombre genérico del producto se decide en Fase 8 (`Docs/07`).

## 2. Usuarios

| Usuario | Qué hace | Qué recibe |
|---------|----------|------------|
| **Hincha / familia / jugador** | Consulta fixture, resultados, tabla, goleadores, sanciones, noticias | El 99% del uso, desde el celular |
| **Delegado de club** (persona designada por el club, típicamente un dirigente) | Levanta la planilla tras el partido (con foto de respaldo), mantiene el roster de su club, disputa errores del rival | Acceso al panel, menos idas y vueltas |
| **Secretaría de la liga** | Carga el fixture, verifica planillas, liquida sanciones, publica noticias, gestiona auspiciantes | Control editorial total: nada sale público sin su visto bueno |
| **Auspiciante** | Paga por visibilidad | Banner con link y sección propia |
| **Otra liga (futuro)** | Licencia la plataforma | La misma herramienta con su marca (`Docs/07`) |

Regla de oro del flujo: **solo dos niveles escriben** — delegados cargan borradores, la liga verifica y publica. El público jamás escribe. Esto replica el circuito que las ligas del interior ya hacen en papel, sin aprendizaje nuevo.

## 3. Competencias que cubre

Una org (la liga) maneja **varias categorías y varios torneos** con el mismo motor:

| Tipo de competencia | Realidad en el interior uruguayo | Nuestra estructura |
|---|---|---|
| **Primera división** | Torneo masculino principal del departamento: liga regular + playoffs | Categoría + torneo formato `liga_playoffs` |
| **Formativas** (inferiores al estilo U-14, U-16, U-18… **[a confirmar con la liga: cortes de edad y nombres reales]**; en Uruguay se juegan por año calendario) | Torneos por categoría de edad | Una categoría por edad, cada una su torneo; la edad se valida con fecha de nacimiento del jugador |
| **Campeonato amateur** | Torneo paralelo, sin federar, más relajado | Tercera competencia con **el mismo motor**: formato `torneo` (liga regular + definición corta), estadísticas configurables a nivel básico si la liga lo pide |

Decisión (con Juan, 2026-10-21): el amateur usa **la misma estructura** que las otras competencias (tabla + playoffs si aplica) — no un sistema aparte. Es simplemente otra categoría con sus reglas configurables.

La diferencia entre competencias queda en la configuración del torneo: nivel de detalle estadístico, sistema de puntos de tabla, playoffs on/off (ver `Docs/02`).

## 4. El motor de contenido (todo torneo es igual)

1. La liga crea el torneo con formato y reglas (sistema de puntos de tabla, tie-breakers, walkovers 20-0 FIBA o lo que determine el reglamento local).
2. La liga carga el fixture (pegado desde su Excel o a mano) → los partidos quedan `programado` y visibles.
3. Cada fin de semana se juega. El club local levanta la **planilla** (resultado + estadísticas por jugador + foto de la planilla firmada como respaldo) en estado *borrador*, invisible al público.
4. El club visitante puede **disputar** si detecta un error (ventana de 48 h).
5. La secretaría **verifica** contra la foto del papel → el partido pasa a `finalizado` y se **publica**: tabla, estadísticas y página del partido se actualizan solas (revalidación ≤ 60 s).
6. La liga carga las **sanciones** (por conducta o acumulación) con contador visible de partidos pendientes de cumple.
7. Cerrada la regular, se arman los **playoffs** (bracket con series mejor-de-N). Al terminar, la tabla histórica queda congelada como archivo.

## 5. Diferenciadores (por qué la liga paga esto)

Frente al estado de arte actual (WhatsApp + papel + Facebook):

1. **Una sola fuente oficial** en vez de cinco grupos contradictorios: el resultado oficial es único.
2. **Menos trabajo para la comisión**: delegado levanta desde el celular con foto de respaldo; la secretaría verifica en un minuto.
3. **Tablas y goleadores al instante**, solas, sin Excel a mano.
4. **Archivo histórico**: cada temporada queda. Hoy el pasado de las ligas del interior se pierde con cada cambio de comisión.
5. **Vendible a auspiciantes**: "tu marca en la web oficial de la liga" se vende localmente; los auspiciantes se gestionan solos desde el panel.
6. **Soporte humano local**: la herramienta la mantiene alguien de la zona, no un chat de soporte extranjero (frente a Gesdeportiva — ver `Docs/08`).

Aclaración honesta: el MVP **no** necesita tiempo real ni en vivo. La apuesta es orden y archivo, no broadcast.

## 6. Qué NO es (scope defensivo)

- No es streaming / reproductor de video.
- No es red social: no hay comentarios ni perfiles de hincha; lo social queda en los canales de la liga.
- No es sistema de cobros de cuotas ni inscripción online de interesados; el cobro de fichas sigue en cancha.
- No es app nativa: mobile-first, "agregar a la pantalla de inicio", no store.
- No es federador de fichas con la FUBB (fase futura: export o integración, decisión en Fase 8).

## 7. Riesgos de arranque y mitigación

| Riesgo | Mitigación |
|---|---|
| Que todo el día a día dependa de Juan | **Ningún dato de la operación lo carga Juan.** Se junta una vez con la secretaría, se carga el fixture juntos y desde ahí delegados + secretaría sostienen. Panel pensado para personas no técnicas. |
| Delegados no técnicos que no usan el panel | Panel de dos pasos por acción, tipografía grande, video de 3 min de capacitación, y fallback real: la planilla llega por WhatsApp y la liga la carga manual |
| Reglas del torneo distintas al supuesto (puntos de tabla, walkovers) | Todo configurable por `reglas_json` del torneo; el default es FIBA pero manda el reglamento local. **[a confirmar con la liga]** |
| Pico de tráfico sábado a la noche | Astro estático cacheado: el pico es trivial frente a cualquier sitio público de referencia. Sobró la config free de Vercel (`Docs/01`) |
| Que la liga reclame el nombre "LBC" | Contrato de licencia simple: código y plataforma son de Juan; a la liga se le concede el uso (`Docs/08`) |

## 8. El pitch en una frase

> "La liga entera en una web: fixture, tabla y goleadores actualizados el sábado a la noche, sin que nadie vuelque nada a mano, para que le quede más tiempo a los que ya trabajan gratis."

Cierro comercial completo en `Docs/08`.

## 9. Próxima lectura

- `01-stack.md` — cómo se construye y por qué así.
- `09-fases.md` — orden de construcción y qué va primero.
