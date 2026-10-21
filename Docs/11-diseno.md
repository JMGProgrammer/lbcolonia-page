# 11 · Diseño — dirección visual

Última actualización: 2026-10-21

Elemento definido con Juan, luego de analizar las referencias (federacioncolonia.com.uy y fubb.org.uy). Este doc manda sobre cualquier criterio estético en código.

## 1. Lectura de diseño (lo que somos)

Web de liga deportiva regional para hinchas de celular y dirigentes, con identidad ya existente (escudo LBC + afiches de temporada), mercado donde el fútbol coloniense ya se modernizó. No es landing de agencia ni portal de federación nacional: es el **marcador vivo de la liga**, con archivo.

Diales de diseño (a respetar en cada página):

- **VARIANCE 6** — composición con carácter, asimetrías de afiche, pero es un sitio de datos.
- **MOTION 3** — calma: hover y entrada sutil, nada más; el requisito de `prefers-reduced-motion` ya está en `Docs/04`.
- **DENSITY 6** — tablas y fixture son el producto: densas pero respirando.

## 2. Decisión de modo: solo oscuro (Juan, 2026-10-21)

La web vive **siempre en azul marino**, como los afiches y como FUBB. Sin modo claro ni toggle (revisable una vez en producción si un caso real lo exige). Un solo tema por página: nada de secciones que se invierten a mitad de scroll. Contraste AA verificado sobre navy en tablas y texto pequeño.

## 3. Identidad visual

### Paleta (derivada del de los afiches oficiales; afinar con sampler sobre los PNG)

| Token | Valor aproximado | Uso |
|---|---|---|
| `navy-950` | `#131f3d` | fondo base |
| `navy-900` | `#1c2b56` | fondo de secciones / hero |
| `navy-800` | `#24376b` | paneles, cards |
| `navy-700` | `#2e4484` | bordes, divisores |
| `orange-500` | `#f39c2d` | **acento único de acción**: CTA, hora del partido, marcador destacado |
| `red-500` | `#e8222f` | banda institucional, error, foco (uso medido) |
| `gold-400` | `#e9c46a` | rótulos "FECHA X", chiches de temporada (#LBC2026) |
| `ink` | `#0d142b` | texto fuerte sobre paneles claros (no usar negro puro) |
| `paper` | `#f4f1ea` | texto sobre navy (nunca blanco puro) |

Reglas: naranja es **el único color de botón/acción** en toda la web; rojo y dorado son identidad, no acción; un color por intención, sin excepciones.

### Forma

- Un solo radio: **14px** para paneles/cards; 999px solo para chips (switcher/filtros). Esta regla vive en todo el proyecto.
- Paneles estilo afiche: fondo navy-800, borde sutil navy-700, **franja superior fina naranja/roja** como en los afiches ("FECHA X"), tipografía de rótulo en mayúsculas con tracking amplio.
- Sombra: solo elevación real, tintada azul; nada de glows neón.
- Iconos: familia única **Phosphor** (SVG inline, stroke 1.5). Nada de iconos dibujados a mano ni mezcla de familias.

### Tipografía

- **Archivo** (open source, self-hosted woff2, subconjunto español): 800/900 display, 400/600 body.
- Números siempre en `tabular-nums` (marcadores, tablas, fechas): la tabla no "baila" al actualizar.
- Display estilo afiche: mayúsculas, tracking amplio en rótulos ("PRIMERA DIVISIÓN · FECHA 2"), peso 900 en titulares de sección pero escala contenida (máx 2 líneas).
- Emoji: no en UI.

## 4. Home (composición definitiva, reemplaza la previa de `Docs/04 §1`)

1. **Barra de competencias** (estilo switcher FUBB): chips "Primera · Formativas · Amateur" que cambian el contexto de la home (y van con color: naranja la activa). En el piloto baja a una sola si no hay más torneos cargados aún.
2. **Nav de una línea**: Fixture · Tabla · Estadísticas · Clubes · Sanciones · Noticias (+ "Liga" con desplegable: reglamento, contacto, historia). Altura máxima 72px. En celu: hamburger limpio, sin mega-menú.
3. **Hero = el marcador del fin de semana** (nuestra diferencia con FUBB y la federación, que abren por noticias): tarjeta/set de tarjetas con los resultados de la última fecha jugada (estilos de ResultCard de abajo) + franja "PRÓXIMA FECHA — Sáb 24/10 · Gimnasio de Juventud · 19:00 y 21:00" + un CTA naranja al fixture. Rótulo dorado "LBC · PRIMERA DIVISIÓN · FECHA 1" arriba, como en el afiche.
4. **Últimas noticias**: hasta 3 tarjetas con foto; si no hay noticias cargadas, la sección desaparece (nada de cajas vacías decorativas).
5. **Tabla compacta de primera** (4 filas en el piloto: Plaza, Rowing, Estudiantes, Juventud) + CTA "Ver tabla completa".
6. **Próximos partidos paginados** ("1 / 97" al estilo federación cuando haya volumen, con doble filtro fecha/club).
7. **Franja de auspiciantes** con nivel (oro arriba del footer, orden del panel).
8. **Institucional**: 2-3 tarjetas de documentos (reglamento, tabla de distancias cuando exista).
9. **Footer**: contacto de la liga (oficina real, teléfono, redes), links legales, crédito "Desarrollado para la LBC".

Manías prohibidas de la home: eyebrow repetido en cada sección (máx 1 cada 3), hero con estampado de logos "auspician la liga" dentro del hero, 3 cards idénticas en fila, zigzag texto-imagen repetido.

## 5. Componentes clave (estilo)

- **ResultCard** (la pieza insignia): panel navy-800 con franja superior de la ronda; escudos a los lados; **marcador grande central naranja** en peso 900; debajo, hora y sede; estado pendiente → "Sáb 19:00" en lugar de marcador; postergado → banda roja "Postergado". Hover: `-translate-y-[2px]` + sombra; active: `scale-[0.98]`.
- **Tabla del afiche**: header con banda naranja "RRSS · TABLA DE POSICIONES"; filas con divisores navy-700, posición 1 dorada, zona de playoffs (cuando exista) marcada con línea naranja; números tabulares; texto de estado ("pendiente de verificación") solo en el panel de la liga, nunca público.
- **Chips filtro del fixture**: 999px, borde navy-700; activo naranja con texto navy-950. Estados vacíos reales ("Todavía no hay partidos cargados para esta fecha").
- **NoticiasCard**: portada navy-700 con foto, rótulo de categoría, título 2 líneas máx, fecha.
- **Skeleton de carga** por página con la forma final del layout (nunca spinner circular).
- Estados `:active` de botones con push físico; contraste AA auditado en cada botón (incluye ghost sobre foto: con scrim navy).

## 6. Nivel de foto/visual (fase 2 en adelante)

- No hay fotos genéricas ni stock: todo lo que se muestre es material real de la liga (fotos de partidos, escudos reales, el propio logo y paleta).
- Mientras no hay fotos, el diseño se sostiene con marcador + tipografía + paleta (es un sitio de datos, no de vitrina — a diferencia de una landing, no necesita fotos obligatorias para verse terminado).
- Escudos de clubes: subir los oficiales por club desde el panel; mientras, iniciales en círculo con los colores del club (no placeholder gris).

## 7. Referencias — qué llevamos y qué no

| Referencia | Adoptamos | Descartamos |
|---|---|---|
| Federación Fútbol Colonia | grilla de campeonatos, doble filtro del fixture con paginación, biblioteca de docs con categorías, datos de sede "a confirmar" | densidad de listado largo sin jerarquía; noticias sin foto (nuevas sí llevan) |
| FUBB (Genius) | switcher de competencias arriba, taxonomía de estadísticas (líderes/individuales/por equipo/histórico), sección de fallos/tribunales (futuro: resoluciones de sanciones) | portal denso, marquee de logos sin jerarquía, dependencia de macros de plataforma ajena |

Nota de competencia (comercial): la federación de fútbol la desarrolló **AMR Software** (footer del sitio) — proveedor local que ya vende este producto a federaciones del departamento; detalle en `Docs/08`.

## 8. Antes del código público (Fase 2)

1. Mockup estático del home (HTML+Tailwind con el seed) para aprobar con Juan **antes** de amarrar componentes.
2. Verlo de 320px a 1300px en Chrome headless y en el celu físico (patrón lgrestoreuy).
3. Favicon y OG image derivados del logo `logo-lbc-bgr.png`.
