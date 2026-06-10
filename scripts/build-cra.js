#!/usr/bin/env node
/**
 * Create React App solo inyecta en el bundle variables REACT_APP_*.
 * En Vercel suele definirse SUPABASE_URL / SUPABASE_ANON_KEY (p. ej. para /api/*).
 * Antes de compilar, copiamos esas al prefijo REACT_APP_ si faltan o están vacías.
 */
"use strict";

const path = require("path");
const { spawnSync } = require("child_process");

const appRoot = path.resolve(__dirname, "..");

function nonEmpty(v) {
  return v != null && String(v).trim() !== "";
}

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== "string") return url;
  let u = url.trim().replace(/\/+$/g, "");
  while (/\/rest\/v1$/i.test(u)) {
    u = u.replace(/\/rest\/v1$/i, "").replace(/\/+$/g, "");
  }
  return u;
}

const env = { ...process.env };

if (!nonEmpty(env.REACT_APP_SUPABASE_URL) && nonEmpty(env.SUPABASE_URL)) {
  env.REACT_APP_SUPABASE_URL = normalizeSupabaseProjectUrl(env.SUPABASE_URL);
} else if (nonEmpty(env.REACT_APP_SUPABASE_URL)) {
  env.REACT_APP_SUPABASE_URL = normalizeSupabaseProjectUrl(env.REACT_APP_SUPABASE_URL);
}
if (!nonEmpty(env.REACT_APP_SUPABASE_ANON_KEY) && nonEmpty(env.SUPABASE_ANON_KEY)) {
  env.REACT_APP_SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY;
}

/** Visible en el navegador como window.__FARMACAPITAL_BUILD_ID__ para comprobar que el deploy es reciente. */
if (!nonEmpty(env.REACT_APP_FARMACAPITAL_BUILD_ID)) {
  env.REACT_APP_FARMACAPITAL_BUILD_ID = new Date().toISOString();
}

const buildScript = require.resolve("react-scripts/scripts/build.js");
const result = spawnSync(process.execPath, [buildScript], {
  stdio: "inherit",
  env,
  cwd: appRoot,
});

process.exit(result.status === null ? 1 : result.status);
