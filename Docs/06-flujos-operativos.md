# 06 · Flujos operativos

Última actualización: 2026-10-21

La operación de la semana, paso a paso. Espejo del circuito en papel que los clubes del interior ya hacen; el panel no inventa rituales nuevos.

## 1. Ciclo de jornada (el flujo central)

```
LUNES-VIERNES (liga)
  1. Secretaría carga/ajusta el fixture de la jornada.  →  partidos `programado` (público)
SÁBADO-DOMINGO (club local)
  2. Tras el partido, el delegado abre "Mis partidos" y carga la planilla:
     marcador + stats por jugador + foto del papel firmado  →  `borrador` (invisible al público)
  3. El club visitante revisa. Acepta el silencio o DISPUTA (+ motivo)  →  caso en la liga
48 H DE VENTANA
LUNES (liga)
  4. Secretaría verifica contra la foto (diff de datos, 1 minuto)
     - OK → `verificada` + partido `publicado = true`  →  resultados/tabla/stats al sitio
     - Error → corrige sobre los datos en pantalla, luego publica
     - Disputa válida → corrige/elimina la planilla y notifica; se recarga
```

Reglas del ciclo:
- **Foto del papel obligatoria** al guardar borrador: la verificación se hace con el papel, no de memoria.
- La ventana de disputa son 48 h desde la carga del borrador; pasadas, la planilla pasa a verificable sin disputa (la liga igual puede corregir).
- Publicar dispara revalidate del sitio (`Docs/01`); si falla, el cache vence solo.
- Correcciones post-publicación (p. ej. un error de suma encontrado el martes) las hace la liga y quedan logueadas en `audit_log`; el público no las nota (recalcula tabla igual).

## 2. Partidos especiales

| Caso | Manejo |
|---|---|
| **Postergado** | Estado `postergado` + `nota_publica`; el partido sale de la agenda del día pero queda en el fixture original. Re-agendar = cambiar fecha (misma ronda). No impacta la tabla |
| **Suspendido** | Igual que postergado: estado `suspendido` + nota pública, queda pendiente de resolución. Fecha y tratamiento definitivo de suspendidos en curso según reglamento **[a confirmar con la liga]** |
| **Walkover** | Estado `walkover` + `walkover_ganador_id` + motivo público. La tabla aplica los puntos del `reglas_json` (score nominal 20-0 solo si el reglamento lo maneja así) |
| **Partido sin planilla** (el local no cargó) | Aparece en el inbox de la liga como pendiente; la liga lo puede cargar a mano con foto que le llegó por WhatsApp — sin excusas para el negocio |

## 3. Playoffs

1. Cerrada la regular, la liga marca el torneo `formato = liga_playoffs` y arma las **series** (mejor de 1/3/5) con los clasificados de la tabla; la view de tabla queda congelada como "regular".
2. Cada serie es un grupo de partidos con ronda etiquetada (`S1 IDA`, `S1 VUELTA`, `S1 DEF…`); la vista de series cuenta partidos ganados para declarar al ganador (el desempate cuando quedan igualados en juegos ganados, según formato **[a confirmar con la liga]**).
3. El bracket público se prepara con las series y avanza al momento de obtener ganador confirmado de la serie. Nada de árboles "de esperanza": solo se dibuja lo que ya existe.

## 4. Sanciones

Máquina de estados sencilla:

- Alta: tipo (jugador/técnico/club), motivo, número de partidos a cumplir. `activa`.
- Consumo: cada partido `finalizado` (o `walkover`) del equipo/jugador posterior al alta descuenta 1. Los partidos `postergado/suspendido` **no descuentan** (el jugador sigue suspendido para cuando se juegue).
- `cumplida` desaparece de las activas y queda en la histórica por temporada. Baja anticipada: solo la liga, con nota obligatoria (transparencia hacia los clubes).
- Vista pública: nombre, club, motivo y partidos restantes. Qué tanto motivo se muestra al público **[a confirmar con la liga]**.

## 5. Formativas: control de edad

- El torneo formativo define la categoría por **año calendario** (como se compite en Uruguay). La ficha valida: año de nacimiento del jugador compatible con la categoría **[a confirmar exactamente cómo corta la liga: año calendario o regla de mitad de año]**.
- El aviso de inconsistencia aparece en la ficha (el delegado lo ve al cargar) y en la verificación de la liga; no bloquea la carga del partido (a veces un jugador de mayor edad juega con permiso especial — queda registrado y visible).

## 6. Temporada y archivado

- Al cerrar el torneo (`estado = finalizado`), la vista pública lo pasa a "histórico": la lectura se mantiene, la función de edición desaparece de la UI.
- La temporada nueva se arma duplicando el torneo del año anterior (copa de categorías y clubes, no de partidos), en una pasada desde el panel.
- El histórico es también un activo comercial: la liga acumula años de archivo que ningún Excel viejo podrá reemplazar.
