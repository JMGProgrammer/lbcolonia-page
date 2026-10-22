// Capa de datos del sitio público. Todo se consulta con el cliente anon (RLS es la
// única barrera); las funciones devuelven [] / null en lugar de lanzar, y loguean
// el error: una página pública jamás rompe por un fallo puntual de la Data API.
import { supabase } from './supabase';

/* ------------------------------- tipos de vista ------------------------------ */

export interface ClubPublico {
  nombre: string;
  slug: string;
  escudo_url: string | null;
  color1: string | null;
  color2: string | null;
}

export interface EquipoAsociado {
  id: string;
  nombre_mostrar: string | null;
  clubes: ClubPublico;
}

export interface TorneoInfo {
  id: string;
  nombre: string;
  temporada: number;
  estado: 'proximo' | 'en_curso' | 'finalizado';
  formato: 'liga' | 'liga_playoffs' | 'torneo';
  estadisticas_detalladas: boolean;
  categorias: { nombre: string; acronimo: string | null; orden: number };
}

export interface PartidoVista {
  id: string;
  ronda: string;
  estado: 'programado' | 'en_juego' | 'finalizado' | 'postergado' | 'suspendido' | 'walkover';
  publicado: boolean;
  fecha_hora: string;
  sede: string | null;
  nota_publica: string | null;
  puntos_local: number | null;
  puntos_visitante: number | null;
  cuartos_local: number[] | null;
  cuartos_visitante: number[] | null;
  walkover_ganador_id: string | null;
  local: EquipoAsociado | null;
  visitante: EquipoAsociado | null;
  torneos: { id: string; nombre: string; temporada: number; categorias: { nombre: string; acronimo: string | null } } | null;
}

export interface FilaTabla {
  club: string | null;
  dif: number | null;
  equipo: string | null;
  equipo_id: string | null;
  gc: number | null;
  gf: number | null;
  pdw: number | null;
  pg: number | null;
  pj: number | null;
  pp: number | null;
  pts: number | null;
  pw: number | null;
  torneo_id: string | null;
}

export interface SancionVista {
  club: string | null;
  fecha_alta: string | null;
  motivo: string | null;
  partidos_cumplir: number | null;
  partidos_restantes: number | null;
  persona: string | null;
  tipo: 'jugador' | 'tecnico' | 'club' | null;
}

export interface NoticiaPublica {
  slug: string;
  titulo: string;
  bajada: string | null;
  cuerpo_md: string | null;
  etiquetas: string[];
  destacado: boolean;
  publicado: boolean;
  portada_url: string | null;
  publicado_at: string | null;
  created_at: string;
}

export interface PaginaPublica {
  slug: string;
  titulo: string;
  cuerpo_md: string | null;
  publicado: boolean;
}

export interface AuspiciantePublico {
  nombre: string;
  nivel: 'oro' | 'plata' | 'bronce' | 'colaborador';
  activo: boolean;
  link: string | null;
  logo_url: string | null;
  orden: number;
}

export interface EstadisticaPublica {
  partido_id: string;
  stat_id: string;
  dorsal: number | null;
  puntos: number;
  rebotes: number | null;
  asistencias: number | null;
  robos: number | null;
  tapas: number | null;
  faltas: number;
  minutos: number | null;
  equipo_id: string;
  jugador_id: string;
  nombre_completo: string;
}

export interface FichaRoster {
  id: string;
  equipo_id: string;
  dorsal: number | null;
  estado: 'solicitada' | 'confirmada' | 'baja';
  jugadores: {
    id: string;
    nombre_completo: string;
    fecha_nacimiento?: string | null;
    foto_url?: string | null;
  };
  torneos: { id: string; nombre: string };
}

export interface ClubDetalle {
  id: string;
  nombre: string;
  slug: string;
  gimnasio: string | null;
  escudo_url: string | null;
  color1: string | null;
  color2: string | null;
  activo: boolean;
}

/* ----------------------------- selects y helpers ----------------------------- */

const CLUBES_FIELDS = 'nombre,slug,escudo_url,color1,color2';

const SELECT_PARTIDO = `
  id, ronda, estado, publicado, fecha_hora, sede, nota_publica,
  puntos_local, puntos_visitante, cuartos_local, cuartos_visitante, walkover_ganador_id,
  local:equipos!partidos_equipo_local_id_fkey(id, nombre_mostrar, clubes(${CLUBES_FIELDS})),
  visitante:equipos!partidos_equipo_visitante_id_fkey(id, nombre_mostrar, clubes(${CLUBES_FIELDS})),
  torneos(id, nombre, temporada, categorias(nombre, acronimo))
`.trim();

const SELECT_TORNEO = 'id,nombre,temporada,estado,formato,estadisticas_detalladas,categorias(nombre,acronimo,orden)';

type RespuestaSupa<T> = { data: T | null; error: { message: string } | null };

/** Colección: [] si la API falla (una página pública jamás rompe por la base). */
async function filas<T>(prom: PromiseLike<RespuestaSupa<T[]>>): Promise<T[]> {
  const res = await prom;
  if (res.error) {
    console.error('[data]', res.error.message);
    return [];
  }
  return (res.data ?? []) as T[];
}

/** Fila única o null (para rutas por id/slug). */
async function fila<T>(prom: PromiseLike<RespuestaSupa<T[]>>): Promise<T | null> {
  const datos = await filas<T>(prom);
  return datos[0] ?? null;
}

/* --------------------------------- consultas --------------------------------- */

/** Torneos en el orden de categorías de la liga (Primera, U22 … U10). */
export async function listarTorneos(): Promise<TorneoInfo[]> {
  const torneos = await filas(
    supabase.from('torneos').select(SELECT_TORNEO).returns<TorneoInfo[]>()
  );
  return torneos.sort((a, b) => (a.categorias?.orden ?? 99) - (b.categorias?.orden ?? 99));
}

/** Torneo por defecto: Primera (1RA); si no hay, el en_curso con menor orden de categoría. */
export function torneoPorDefecto(torneos: TorneoInfo[], acronimoDefault = '1RA'): TorneoInfo | null {
  const ordenEstado: Record<string, number> = { en_curso: 0, proximo: 1, finalizado: 2 };
  if (torneos.length === 0) return null;
  return [...torneos].sort((a, b) => {
    const prioA = a.categorias?.acronimo === acronimoDefault ? 0 : 1;
    const prioB = b.categorias?.acronimo === acronimoDefault ? 0 : 1;
    if (prioA !== prioB) return prioA - prioB;
    if ((ordenEstado[a.estado] ?? 3) !== (ordenEstado[b.estado] ?? 3))
      return (ordenEstado[a.estado] ?? 3) - (ordenEstado[b.estado] ?? 3);
    return (a.categorias?.orden ?? 9) - (b.categorias?.orden ?? 9);
  })[0];
}

export function torneoPorId(torneos: TorneoInfo[], id: string | undefined | null): TorneoInfo | null {
  if (!id) return torneoPorDefecto(torneos);
  return torneos.find((t) => t.id === id) ?? torneoPorDefecto(torneos);
}

export function listarPartidosDeTorneo(torneoId: string): Promise<PartidoVista[]> {
  return filas(
    supabase
      .from('partidos')
      .select(SELECT_PARTIDO)
      .eq('torneo_id', torneoId)
      .order('fecha_hora', { ascending: true })
      .returns<PartidoVista[]>()
  );
}

export function partidoPorId(id: string): Promise<PartidoVista | null> {
  return fila(
    supabase
      .from('partidos')
      .select(SELECT_PARTIDO)
      .eq('id', id)
      .limit(1)
      .returns<PartidoVista[]>()
  );
}

/** v_detalle_publico: líneas de la planilla verificada de un partido publicado (0002). */
export function detallePartido(partidoId: string): Promise<EstadisticaPublica[]> {
  return filas(
    supabase
      .from('v_detalle_publico')
      .select('*')
      .eq('partido_id', partidoId)
      .order('equipo_id', { ascending: true })
      .order('dorsal', { ascending: true, nullsFirst: false })
      .returns<EstadisticaPublica[]>()
  );
}

export function tablaDeTorneo(torneoId: string): Promise<FilaTabla[]> {
  return filas(
    supabase
      .from('v_tabla')
      .select('*')
      .eq('torneo_id', torneoId)
      .order('pts', { ascending: false })
      .order('dif', { ascending: false })
      .order('gf', { ascending: false })
      .returns<FilaTabla[]>()
  );
}

export function sancionesActivas(): Promise<SancionVista[]> {
  return filas(
    supabase
      .from('v_sanciones_activas')
      .select('*')
      .order('club', { ascending: true })
      .returns<SancionVista[]>()
  );
}

export function listarNoticias(limite = 30): Promise<NoticiaPublica[]> {
  return filas(
    supabase
      .from('noticias')
      .select('slug,titulo,bajada,cuerpo_md,etiquetas,destacado,publicado,portada_url,publicado_at,created_at')
      .eq('publicado', true)
      .order('publicado_at', { ascending: false, nullsFirst: false })
      .limit(limite)
      .returns<NoticiaPublica[]>()
  );
}

export function noticiaPorSlug(slug: string): Promise<NoticiaPublica | null> {
  return fila(
    supabase
      .from('noticias')
      .select('slug,titulo,bajada,cuerpo_md,etiquetas,destacado,publicado,portada_url,publicado_at,created_at')
      .eq('publicado', true)
      .eq('slug', slug)
      .limit(1)
      .returns<NoticiaPublica[]>()
  );
}

export function listarAuspiciantes(): Promise<AuspiciantePublico[]> {
  return filas(
    supabase
      .from('auspiciantes')
      .select('nombre,nivel,activo,link,logo_url,orden')
      .eq('activo', true)
      .order('orden', { ascending: true })
      .returns<AuspiciantePublico[]>()
  );
}

export function listarPaginas(): Promise<PaginaPublica[]> {
  return filas(
    supabase
      .from('paginas')
      .select('slug,titulo,cuerpo_md,publicado')
      .eq('publicado', true)
      .order('titulo', { ascending: true })
      .returns<PaginaPublica[]>()
  );
}

export function paginaPorSlug(slug: string): Promise<PaginaPublica | null> {
  return fila(
    supabase
      .from('paginas')
      .select('slug,titulo,cuerpo_md,publicado')
      .eq('publicado', true)
      .eq('slug', slug)
      .limit(1)
      .returns<PaginaPublica[]>()
  );
}

export function listarClubes(): Promise<ClubDetalle[]> {
  return filas(
    supabase
      .from('clubes')
      .select('id,nombre,slug,gimnasio,escudo_url,color1,color2,activo')
      .eq('activo', true)
      .order('nombre', { ascending: true })
      .returns<ClubDetalle[]>()
  );
}

export function clubPorSlug(slug: string): Promise<ClubDetalle | null> {
  return fila(
    supabase
      .from('clubes')
      .select('id,nombre,slug,gimnasio,escudo_url,color1,color2,activo')
      .eq('activo', true)
      .eq('slug', slug)
      .limit(1)
      .returns<ClubDetalle[]>()
  );
}

export async function listarEquiposDeClube(clubId: string) {
  return filas(
    supabase
      .from('equipos')
      .select('id,nombre_mostrar,categorias(nombre,acronimo,orden)')
      .eq('club_id', clubId)
      .order('id', { ascending: true })
      .returns<
        Array<{
          id: string;
          nombre_mostrar: string | null;
          categorias: { nombre: string; acronimo: string | null; orden: number };
        }>
      >()
  );
}

export function rosterDeEquipos(equipoIds: string[]): Promise<FichaRoster[]> {
  if (equipoIds.length === 0) return Promise.resolve([]);
  return filas(
    supabase
      .from('fichas')
      .select('equipo_id,id,dorsal,estado,jugadores(id,nombre_completo,fecha_nacimiento,foto_url),torneos(id,nombre)')
      .in('equipo_id', equipoIds)
      .order('dorsal', { ascending: true, nullsFirst: false })
      .returns<FichaRoster[]>()
  );
}

/* --------------------------- derives útiles de UI ---------------------------- */

/** Filas agrupadas por ronda, en el orden en que llegan (fecha_hora asc). */
export function agruparPorRonda(partidos: PartidoVista[]): Map<string, PartidoVista[]> {
  const grupos = new Map<string, PartidoVista[]>();
  for (const p of partidos) {
    const ronda = p.ronda || '—';
    if (!grupos.has(ronda)) grupos.set(ronda, []);
    grupos.get(ronda)!.push(p);
  }
  return grupos;
}
