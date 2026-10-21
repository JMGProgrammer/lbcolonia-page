// Formato de fechas/horas: siempre America/Montevideo (Docs/04 §1).
const TZ = 'America/Montevideo';

interface Partes {
  weekday: string;
  day: string;
  month: string;
  year: string;
  hour: string;
  minute: string;
}

function partes(iso: string): Partes {
  const parts = new Intl.DateTimeFormat('es-UY', {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
    timeZone: TZ,
  }).formatToParts(new Date(iso));
  const acc: Record<string, string> = {};
  for (const p of parts) if (p.type !== 'literal') acc[p.type] = p.value;
  return acc as unknown as Partes;
}

const capitalizar = (s: string) => (s ? s.charAt(0).toLocaleUpperCase('es-UY') + s.slice(1) : s);

/** "Sáb 17/10" */
export function fechaCorta(iso: string): string {
  const p = partes(iso);
  return `${capitalizar(p.weekday)} ${p.day}/${p.month}`;
}

/** "Sáb 17/10/2026" */
export function fechaLarga(iso: string): string {
  const p = partes(iso);
  return `${capitalizar(p.weekday)} ${p.day}/${p.month}/${p.year}`;
}

/** "19:00" */
export function horaCorta(iso: string): string {
  const p = partes(iso);
  return `${p.hour}:${p.minute}`;
}

/** ronda "1" → "Fecha 1"; rondas no numéricas pasan tal cual (playoffs, IT6) */
export function rondaLabel(ronda: string): string {
  const n = Number(ronda);
  return Number.isInteger(n) && n >= 1 ? `Fecha ${n}` : ronda;
}

/** Etiqueta human friendly del estado del partido para badges */
export function etiquetaEstado(
  estado: string
): { texto: string; tono: 'gris' | 'naranja' | 'rojo' | 'dorado' } {
  switch (estado) {
    case 'programado':
      return { texto: 'Programado', tono: 'gris' };
    case 'en_juego':
      return { texto: 'En juego', tono: 'naranja' };
    case 'finalizado':
      return { texto: 'Final', tono: 'naranja' };
    case 'postergado':
      return { texto: 'Postergado', tono: 'gris' };
    case 'suspendido':
      return { texto: 'Suspendido', tono: 'rojo' };
    case 'walkover':
      return { texto: 'Walkover', tono: 'dorado' };
    default:
      return { texto: estado, tono: 'gris' };
  }
}

/** Escapa HTML para el mini-render de markdown (noticias/páginas). */
export function escHtml(s: string): string {
  return s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

/**
 * Mini-render de markdown (Solo servidor, contenido de la liga):
 * headings #/##/###, párrafos, listas -, **negrita**, *itálica* y [link](url).
 * La liga es autora de confianza (RLS: solo liga_admin); nada llega del público.
 */
export function renderMarkdown(md: string): string {
  const lineas = escHtml(md ?? '').split('\n');
  const out: string[] = [];
  let enLista = false;

  const inline = (t: string): string =>
    t
      // enlaces [texto](url) antes de negritas, para conservar el contenido textual
      .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" class="text-orange-500 underline font-semibold" rel="noopener noreferrer">$1</a>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/(?<!\*)\*([^*]+)\*(?!\*)/g, '<em>$1</em>');

  const cerrarLista = () => {
    if (enLista) {
      out.push('</ul>');
      enLista = false;
    }
  };

  for (const linea of lineas) {
    const t = linea.trim();
    if (!t) {
      cerrarLista();
      continue;
    }
    const h = /^(#{1,3})\s+(.*)$/.exec(t);
    if (h) {
      cerrarLista();
      const nivel = h[1].length;
      const cls = nivel === 1 ? 'text-2xl font-black mt-6 mb-2' : 'text-lg font-extrabold mt-5 mb-2';
      out.push(`<h${nivel} class="${cls}">${inline(h[2])}</h${nivel}>`);
      continue;
    }
    const li = /^[-*]\s+(.*)$/.exec(t);
    if (li) {
      if (!enLista) {
        out.push('<ul class="list-disc pl-6 my-3 space-y-1">');
        enLista = true;
      }
      out.push(`<li>${inline(li[1])}</li>`);
      continue;
    }
    cerrarLista();
    out.push(`<p class="my-3 leading-relaxed">${inline(t)}</p>`);
  }
  cerrarLista();
  return out.join('\n');
}
