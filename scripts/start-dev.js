#!/usr/bin/env node
/**
 * Arranca react-scripts con entorno saneado: si la shell tiene REACT_APP_SUPABASE_* = "",
 * CRA no carga el valor desde .env y el bundle queda en dev-bootstrap.invalid.
 */
"use strict";

const path = require("path");
const { spawnSync } = require("child_process");

const appRoot = path.resolve(__dirname, "..");

const env = { ...process.env };
for (const k of ["REACT_APP_SUPABASE_URL", "REACT_APP_SUPABASE_ANON_KEY"]) {
  if (env[k] === "") delete env[k];
}
env.WATCHPACK_POLLING = "true";
env.CHOKIDAR_USEPOLLING = "true";

const startScript = require.resolve("react-scripts/scripts/start.js");
const result = spawnSync(process.execPath, [startScript], {
  stdio: "inherit",
  env,
  cwd: appRoot,
});

process.exit(result.status === null ? 1 : result.status);
