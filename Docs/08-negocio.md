# 08 · Negocio — venta y sostenibilidad

Última actualización: 2026-10-21

Modelo elegido (con Juan, 2026-10-21): **vender a las ligas** con licencia por temporada; el piloto con la Liga de Colonia sale gratis a cambio de datos reales, testimonio y feedback (moneda de confianza).

## 1. Benchmark (de dónde arranca la venta)

| Hoy las ligas del interior… | Problema |
|---|---|
| Pizarras + planillas en papel | Sin archivo, sin acceso remoto, se pierden |
| Grupos de WhatsApp/Instagram | Sin fuente oficial; resultados contradictorios; nada ordenado por categoría |
| Excel de un voluntario | Muere cuando esa persona se cansa; sin goleadores |
| **Gesdeportiva** (usada por la FUBB) | Genérica, extranjera, cara para una liga local, sin soporte cercano ni identidad de cada liga |

| **AMR Software** (local, Uruguay) | Proveedor local que ya vende esta categoría: desarrolló la web de la Federación Departamental de Fútbol de Colonia (federacioncolonia.com.uy, 2026) — fixture con doble filtro, campeonatos por torneo, biblioteca documental | Nuestro referente directo: confirma que el modelo "licencia a federaciones/ligas del interior" es mercado real. Diferenciar con: foco 100% básquet (goleadores, sanciones con cumple, formativas), carga por delegados (la federación depende del upload del proveedor) y soporte cercano |

Ventaja vs Gesdeportiva: precio local de interior, soporte humano en la calle, identidad visual de la liga, y el flujo delegado→secretaria es el mismo que ellas ya conocen.

## 2. Propuesta de piloto con la Liga de Colonia

- **Temporada 1 gratis** con contrapartes claras: la liga aporta fixtures oficiales, contactos de delegados, escudos y logo, y feedback; Juan aporta la plataforma, la carga inicial acompañada y la capacitación.
- Todo el dato que la liga produce en el panel importa para la venta siguiente: banco de capturas reales "web de liga funcionando".
- Contrato simple de 2 páginas: licencia de uso (no venta de código), propiedad de marca de la liga respetada; los datos de la liga son suyos exportables; rescisión con aviso; Juan conserva la propiedad de la plataforma y del dominio técnico.
- Tipo de salida si la liga no se banca la licencia: el dato es exportable y el sitio se congela en modo archivo.

## 3. Pricing (propuesta inicial a calibrar)

Todo por temporada (un pago anual, vencimiento antes del inicio del torneo). Los montos quedan para la reunión del piloto; escala de referencia sugerida:

| Plan | Para qué | Referencia sugerida |
|---|---|---|
| `Licencia Liga` | 1 liga, todas sus categorías y torneos, panel completo, datos ilimitados | Ajuste entre USD 30–60/mes equivalente, un pago anual a la conveniencia |
| `Licencia Liga Estrella` | + consultas de más detalle, feature flags avanzados, estadísticas detalladas activas por defecto | si vende en otras ligas |
| `Setup + fichas de capacitación` | incluido en la licencia (video 3 min + sesión de 1 h con delegados) | no cobrar aparte en MVP |

Criterios para el precio final: cuánto cuesta el hosting (Vercel + Supabase free tier cubren el piloto), cuánto sobra para que valga el mantenimiento, y qué paga hoy la comisión por imprimir un fixture. Regla honesta: es mejor una licencia anual barata que una suscripción mensual que la comisión olvida pagar.

Ingreso lateral dentro de la liga (si la liga lo quiere): los **auspiciantes** que pagan por la visualización del sitio (banners) son negocio de la liga; Juan cobra la plataforma, no una comisión. Va al pitch: la web se autofinancia con sus auspiciantes.

## 4. Pitch (guion corto para reuniones)

1. (2 min) "Tenés tu fixture, tabla y goleadores al saberse los resultados — mostrado desde el celular del delegado en vivo".
2. (Demo con seed o con los datos reales del piloto) fixture → planilla de prueba desde el celu → verifican → tabla actualizada.
3. Cierre: la comisión ahorraría trabajo semanal de volcado manual y gana archivo histórico único. Cierre con auspiciantes: la web se paga sola.

Material a armar en Fase 8 (solo si el piloto cierra bien): landing de producto con demos del seed, video de 3 min, PDF de una hoja.

## 5. Objetivos comerciales (plazos referenciados)

- **6 meses**: piloto LBC corriendo una temporada real completa, testimonio + capturas.
- **12 meses**: 1 licencia pagada (la misma LBC u otra liga del interior que conozca — cercanía de redes: San José, Canelones, Soriano).
- **24 meses**: 3–5 ligas; recuperación del costo de oportunidad + base para las features en vivo (Fase 9 de `Docs/09`).

Riesgo comercial principal: que la comisión de la liga no sostenga el día a día del panel. Mitigación ya diseñada: el flujo delegado→secretaria reparte trabajo y el fallback WhatsApp/foto permite operar sin entrenar a nadie nuevo.
