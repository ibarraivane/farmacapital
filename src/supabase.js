import { createClient } from '@supabase/supabase-js';

const runtimeEnv =
  typeof window !== "undefined" && window.__FARMAX_ENV ? window.__FARMAX_ENV : {};

const isProd = process.env.NODE_ENV === "production";

/** Evita pantalla en blanco en `npm start` sin .env: Supabase JS exige URL no vacía. No usar en producción. */
const DEV_CLIENT_BOOTSTRAP_URL = "https://dev-bootstrap.invalid";
const DEV_CLIENT_BOOTSTRAP_KEY = "dev-anon-key-bootstrap-only";

/**
 * Create React App (webpack DefinePlugin) solo reemplaza `process.env.REACT_APP_*` cuando el acceso
 * es literal en el fuente. Un objeto `env = process.env` y luego `env.REACT_APP_*` NO se inyecta:
 * en el browser queda siempre undefined y se usa el placeholder dev-bootstrap.invalid.
 */
let supabaseUrl =
  process.env.REACT_APP_SUPABASE_URL ||
  process.env.VITE_SUPABASE_URL ||
  runtimeEnv.REACT_APP_SUPABASE_URL ||
  runtimeEnv.VITE_SUPABASE_URL ||
  "";

let supabaseAnonKey =
  process.env.REACT_APP_SUPABASE_ANON_KEY ||
  process.env.VITE_SUPABASE_ANON_KEY ||
  runtimeEnv.REACT_APP_SUPABASE_ANON_KEY ||
  runtimeEnv.VITE_SUPABASE_ANON_KEY ||
  "";

if (isProd && (!supabaseUrl || !supabaseAnonKey)) {
  throw new Error(
    "[Farmax] Faltan credenciales de Supabase en el build. En Vercel: REACT_APP_SUPABASE_URL + REACT_APP_SUPABASE_ANON_KEY, " +
      "o bien SUPABASE_URL + SUPABASE_ANON_KEY (el script de build las copia a REACT_APP_*). Volvé a desplegar tras guardar."
  );
}

if (!isProd && (!supabaseUrl || !supabaseAnonKey)) {
  // eslint-disable-next-line no-console
  console.warn(
    "[Farmax] Sin REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY: usando placeholder solo para arrancar la UI. " +
      "Creá o editá el archivo .env en la raíz del proyecto (junto a package.json) y pegá REACT_APP_SUPABASE_URL y REACT_APP_SUPABASE_ANON_KEY desde Supabase (Settings → API)."
  );
  supabaseUrl = DEV_CLIENT_BOOTSTRAP_URL;
  supabaseAnonKey = DEV_CLIENT_BOOTSTRAP_KEY;
}

/** Solo desarrollo: cliente “bootstrap” interno (sin proyecto real). */
export const isSupabaseDevPlaceholder =
  !isProd && supabaseUrl === DEV_CLIENT_BOOTSTRAP_URL && supabaseAnonKey === DEV_CLIENT_BOOTSTRAP_KEY;

/**
 * Desarrollo: falta configuración usable para auth (URL/key placeholder, anon sin pegar desde Supabase, etc.).
 * Incluye el caso .env con REACT_APP_SUPABASE_ANON_KEY=sb_publishable_replace_me.
 */
export const isSupabaseLocalMisconfigured =
  !isProd &&
  (isSupabaseDevPlaceholder ||
    !supabaseUrl ||
    !supabaseAnonKey ||
    /replace_me/i.test(supabaseAnonKey));

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
