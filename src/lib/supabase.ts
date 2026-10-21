---
// Cliente público (anon). La app NUNCA usa service_role (Docs/03).
// La sesión de delegados/liga se agrega en el panel (IT4+); por ahora solo lectura pública.
import { createClient } from '@supabase/supabase-js';
import type { Database } from './db-types';

const url = import.meta.env.PUBLIC_SUPABASE_URL;
const anonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  throw new Error('Faltan PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY en .env (ver .env.example)');
}

export const supabase = createClient<Database>(url, anonKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});
