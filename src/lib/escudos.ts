// Resolución compartida de escudos para componentes Astro y vistas dinámicas.
// Los assets locales optimizados tienen prioridad sobre Storage.
export interface ClubConEscudo {
  nombre?: string | null;
  slug?: string | null;
  escudo_url?: string | null;
}

export const ESCUDOS_LOCALES: Record<string, string> = {
  'plaza-colonia': '/escudos/plaza-colonia-rbg-logo.webp',
  'colonia-rowing': '/escudos/colonia-rowing-rbg-logo.webp',
  'estudiantes-el-colla': '/escudos/ceec-rbg-logo.webp',
  ceec: '/escudos/ceec-rbg-logo.webp',
  'juventud-caj': '/escudos/juventud-rbg-logo.webp',
  juventud: '/escudos/juventud-rbg-logo.webp',
  'cac-valdense': '/escudos/cac-valdense-rbg-logo.webp',
  valdense: '/escudos/cac-valdense-rbg-logo.webp',
  'independiente-jl': '/escudos/independiente-jl-rbg-logo.webp',
  independiente: '/escudos/independiente-jl-rbg-logo.webp',
};

const normalizar = (valor: string): string => valor
  .toLowerCase()
  .normalize('NFD')
  .replace(/[\u0300-\u036f]/g, '');

export function resolverEscudo(club?: ClubConEscudo | null): string | null {
  const slug = normalizar(club?.slug ?? '').replace(/\s+/g, '-');
  const nombre = normalizar(club?.nombre ?? '');

  let url: string | null = ESCUDOS_LOCALES[slug] ?? null;
  if (!url) {
    if (nombre.includes('plaza')) url = ESCUDOS_LOCALES['plaza-colonia'];
    else if (nombre.includes('rowing')) url = ESCUDOS_LOCALES['colonia-rowing'];
    else if (nombre.includes('colla') || nombre.includes('estudiantes')) url = ESCUDOS_LOCALES['estudiantes-el-colla'];
    else if (nombre.includes('juventud')) url = ESCUDOS_LOCALES.juventud;
    else if (nombre.includes('valdense')) url = ESCUDOS_LOCALES['cac-valdense'];
    else if (nombre.includes('independiente')) url = ESCUDOS_LOCALES['independiente-jl'];
  }

  url ??= club?.escudo_url ?? null;
  if (url?.includes('/storage/v1/object/') && !url.includes('?')) {
    return `${url}?width=256&quality=80&format=webp`;
  }
  return url;
}
