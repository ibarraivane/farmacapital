import { createClient } from '@supabase/supabase-js';

const env = (typeof process !== "undefined" && process.env) ? process.env : {};
const runtimeEnv = (typeof window !== "undefined" && window.__FARMAX_ENV) ? window.__FARMAX_ENV : {};

const SUPABASE_URL =
  env.REACT_APP_SUPABASE_URL ||
  env.VITE_SUPABASE_URL ||
  runtimeEnv.REACT_APP_SUPABASE_URL ||
  runtimeEnv.VITE_SUPABASE_URL ||
  'https://qyabhoftqfmqwpqcsdrb.supabase.co';
const SUPABASE_ANON_KEY =
  env.REACT_APP_SUPABASE_ANON_KEY ||
  env.VITE_SUPABASE_ANON_KEY ||
  runtimeEnv.REACT_APP_SUPABASE_ANON_KEY ||
  runtimeEnv.VITE_SUPABASE_ANON_KEY ||
  'sb_publishable_xheeQJTGohfTzPaaQ3VqFQ_8U0nx-Ec';

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  // Keep app booting, but make misconfiguration obvious in console.
  // eslint-disable-next-line no-console
  console.error("[Farmax] Missing Supabase configuration variables.");
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
