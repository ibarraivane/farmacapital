#!/usr/bin/env node
/**
 * Create React App carga .env* en orden y NO sobrescribe claves ya definidas (ni vacías).
 * Eso puede dejar REACT_APP_SUPABASE_* bloqueados y el bundle usa dev-bootstrap.invalid.
 *
 * Casos detectados:
 * - Variables vacías exportadas en la shell antes de npm start.
 * - .env.development.local / .env.local con REACT_APP_SUPABASE_* vacíos que “ganan” sobre .env.
 */
"use strict";

const fs = require("fs");
const path = require("path");

const appRoot = path.resolve(__dirname, "..");

function parseEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return {};
  return require("dotenv").parse(fs.readFileSync(filePath));
}

function craEnvFilePaths(nodeEnv) {
  const base = path.join(appRoot, ".env");
  return [
    `${base}.${nodeEnv}.local`,
    nodeEnv !== "test" && `${base}.local`,
    `${base}.${nodeEnv}`,
    base,
  ].filter(Boolean);
}

/** Primera aparición de la clave en la cadena CRA (gana aunque el valor sea ""). */
function firstDefinitionOf(key, nodeEnv) {
  for (const file of craEnvFilePaths(nodeEnv)) {
    const parsed = parseEnvFile(file);
    if (Object.prototype.hasOwnProperty.call(parsed, key)) {
      return { file, value: parsed[key] };
    }
  }
  return null;
}

function isBlank(v) {
  return v == null || String(v).trim() === "";
}

const nodeEnv = process.env.NODE_ENV || "development";
if (nodeEnv === "production") {
  process.exit(0);
}

process.chdir(appRoot);

/** CRA/dotenv no pisan claves ya definidas; un export vacío en la shell cuenta como “definida”. */
function stripEmptySupabaseShellVars() {
  for (const k of ["REACT_APP_SUPABASE_URL", "REACT_APP_SUPABASE_ANON_KEY"]) {
    if (process.env[k] === "") delete process.env[k];
  }
}
stripEmptySupabaseShellVars();

delete require.cache[require.resolve("react-scripts/config/paths")];
delete require.cache[require.resolve("react-scripts/config/env")];
process.env.NODE_ENV = nodeEnv;
require("react-scripts/config/env");

const urlProc = process.env.REACT_APP_SUPABASE_URL;
const keyProc = process.env.REACT_APP_SUPABASE_ANON_KEY;

if (!isBlank(urlProc) && !isBlank(keyProc)) {
  process.exit(0);
}

const dotEnvOnly = parseEnvFile(path.join(appRoot, ".env"));
const urlInDotEnv = dotEnvOnly.REACT_APP_SUPABASE_URL;
const keyInDotEnv = dotEnvOnly.REACT_APP_SUPABASE_ANON_KEY;

const expectedFromDotEnv =
  !isBlank(urlInDotEnv) || !isBlank(keyInDotEnv);

if (!expectedFromDotEnv) {
  process.exit(0);
}

const lines = [];
if (!isBlank(urlInDotEnv) && isBlank(urlProc)) {
  const win = firstDefinitionOf("REACT_APP_SUPABASE_URL", nodeEnv);
  if (win && isBlank(win.value)) {
    lines.push(
      `• REACT_APP_SUPABASE_URL está vacío en "${path.relative(appRoot, win.file)}" y eso impide usar el valor de .env. Borrá esa línea o poné la URL real ahí.`
    );
  } else if (win && !isBlank(win.value) && isBlank(urlProc)) {
    lines.push(
      "• REACT_APP_SUPABASE_URL no llegó al proceso pese a archivos .env (revisá variables en la shell)."
    );
  } else {
    lines.push(
      "• Falta REACT_APP_SUPABASE_URL en el proceso; en .env sí hay URL. Revisá otra capa (.env.local / .env.development.local) o la shell."
    );
  }
}
if (!isBlank(keyInDotEnv) && isBlank(keyProc)) {
  const win = firstDefinitionOf("REACT_APP_SUPABASE_ANON_KEY", nodeEnv);
  if (win && isBlank(win.value)) {
    lines.push(
      `• REACT_APP_SUPABASE_ANON_KEY está vacío en "${path.relative(appRoot, win.file)}" y bloquea la clave de .env. Borrá esa línea o pegá la anon key ahí.`
    );
  } else if (win && !isBlank(win.value) && isBlank(keyProc)) {
    lines.push(
      "• REACT_APP_SUPABASE_ANON_KEY no llegó al proceso pese a archivos .env (revisá variables en la shell)."
    );
  } else {
    lines.push(
      "• Falta REACT_APP_SUPABASE_ANON_KEY en el proceso; en .env sí hay clave. Revisá .env* o la shell."
    );
  }
}

if (lines.length === 0) {
  lines.push(
    "• Las claves en .env no se aplicaron al proceso (CRA no sobrescribe variables ya definidas, aunque estén vacías)."
  );
}

// eslint-disable-next-line no-console
console.error(`
[Farmax] Tenés REACT_APP_SUPABASE_* en el archivo .env pero el dev server no las está usando.
${lines.join("\n")}

En macOS/Linux, probá en la misma terminal:
  unset REACT_APP_SUPABASE_URL REACT_APP_SUPABASE_ANON_KEY
  npm start

Si usás Cursor/VS Code: cerrá terminales integradas que hayan quedado con env viejos, o abrí una terminal nueva en la carpeta del proyecto.

Si existe .env.development.local o .env.local, revisá que no tengan esas variables vacías.

Último recurso: borrá la caché de Webpack y reiniciá:
  rm -rf node_modules/.cache
`);
process.exit(1);
