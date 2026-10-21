// Cliente browser de Supabase con persistencia de sesión para el panel /admin (Docs/05).
// Solo anon key; sin service_role nunca.
import { createClient } from '@supabase/supabase-js';
import type { Database } from './db-types';

const url = import.meta.env.PUBLIC_SUPABASE_URL;
const anonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  throw new Error('Faltan PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY en el entorno');
}

export const supabaseBrowser = createClient<Database>(url, anonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});

export interface EstadoAdmin {
  autenticado: boolean;
  userId: string | null;
  email: string | null;
  nombre: string | null;
  orgId: string | null;
  rol: 'liga_admin' | 'liga_ayudante' | 'delegado' | null;
  isSuperadmin: boolean;
  esAdmin: boolean; // liga_admin o superadmin (puede publicar)
  esOrganizador: boolean; // liga_admin, liga_ayudante o superadmin
}

export async function obtenerEstadoAdmin(): Promise<EstadoAdmin> {
  const { data: { session }, error: sesionError } = await supabaseBrowser.auth.getSession();

  if (sesionError || !session?.user) {
    return {
      autenticado: false,
      userId: null,
      email: null,
      nombre: null,
      orgId: null,
      rol: null,
      isSuperadmin: false,
      esAdmin: false,
      esOrganizador: false,
    };
  }

  const user = session.user;

  // Consulta de perfil (superadmin)
  const { data: profile } = await supabaseBrowser
    .from('profiles')
    .select('nombre, is_superadmin')
    .eq('id', user.id)
    .single();

  const isSuperadmin = profile?.is_superadmin ?? false;

  // Consulta de membresía en la organización activa
  const { data: config } = await supabaseBrowser
    .from('app_config')
    .select('valor')
    .eq('clave', 'org_activa')
    .single();

  const orgId = config?.valor ?? null;

  let rol: 'liga_admin' | 'liga_ayudante' | 'delegado' | null = null;

  if (orgId) {
    const { data: miembro } = await supabaseBrowser
      .from('org_members')
      .select('rol')
      .eq('org_id', orgId)
      .eq('user_id', user.id)
      .single();

    rol = (miembro?.rol as 'liga_admin' | 'liga_ayudante' | 'delegado') ?? null;
  }

  const esAdmin = isSuperadmin || rol === 'liga_admin';
  const esOrganizador = isSuperadmin || rol === 'liga_admin' || rol === 'liga_ayudante';

  return {
    autenticado: true,
    userId: user.id,
    email: user.email ?? null,
    nombre: profile?.nombre ?? user.email?.split('@')[0] ?? 'Usuario',
    orgId,
    rol,
    isSuperadmin,
    esAdmin,
    esOrganizador,
  };
}

export async function cerrarSesion(): Promise<void> {
  await supabaseBrowser.auth.signOut();
}
