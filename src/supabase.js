import { createClient } from '@supabase/supabase-js';

const env = (typeof process !== "undefined" && process.env) ? process.env : {};
const runtimeEnv = (typeof window !== "undefined" && window.__FARMAX_ENV) ? window.__FARMAX_ENV : {};

const SUPABASE_URL =
  env.REACT_APP_SUPABASE_URL ||
  env.VITE_SUPABASE_URL ||
  runtimeEnv.REACT_APP_SUPABASE_URL ||
  runtimeEnv.VITE_SUPABASE_URL ||
  "";

const SUPABASE_ANON_KEY =
  env.REACT_APP_SUPABASE_ANON_KEY ||
  env.VITE_SUPABASE_ANON_KEY ||
  runtimeEnv.REACT_APP_SUPABASE_ANON_KEY ||
  runtimeEnv.VITE_SUPABASE_ANON_KEY ||
  "";

const isProd = process.env.NODE_ENV === "production";

if (isProd && (!SUPABASE_URL || !SUPABASE_ANON_KEY)) {
  throw new Error(
    "[Farmax] Definí REACT_APP_SUPABASE_URL y REACT_APP_SUPABASE_ANON_KEY en el entorno de build (p. ej. Vercel → Environment Variables)."
  );
}

if (!isProd && (!SUPABASE_URL || !SUPABASE_ANON_KEY)) {
  // eslint-disable-next-line no-console
  console.warn(
    "[Farmax] Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY. Creá .env.local para desarrollo o inyectá window.__FARMAX_ENV."
  );
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
