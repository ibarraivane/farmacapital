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

const env = { ...process.env };

if (!nonEmpty(env.REACT_APP_SUPABASE_URL) && nonEmpty(env.SUPABASE_URL)) {
  env.REACT_APP_SUPABASE_URL = env.SUPABASE_URL;
}
if (!nonEmpty(env.REACT_APP_SUPABASE_ANON_KEY) && nonEmpty(env.SUPABASE_ANON_KEY)) {
  env.REACT_APP_SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY;
}

const buildScript = require.resolve("react-scripts/scripts/build.js");
const result = spawnSync(process.execPath, [buildScript], {
  stdio: "inherit",
  env,
  cwd: appRoot,
});

process.exit(result.status === null ? 1 : result.status);
