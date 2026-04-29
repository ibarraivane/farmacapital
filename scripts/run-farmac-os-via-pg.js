#!/usr/bin/env node
/**
 * Ejecuta contra Postgres (Supabase) todos los fragmentos
 * sql/generated/import_farmac_os_<stamp>_part*.sql en orden.
 * No usa el SQL Editor (evita límite de tamaño).
 *
 * Requisitos:
 *   - Cadena URI de Postgres del proyecto (Supabase Dashboard → Settings → Database).
 *   - Usá "Session mode" en pooler (puerto 6543) o conexión directa (5432).
 *
 * Uso:
 *   export DATABASE_URL='postgresql://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres'
 *   npm run import:farmac-os:supabase -- 20260429T001330
 *
 * Opcional: DATABASE_URL en .env.local (una línea DATABASE_URL=...)
 */

"use strict";

const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

function loadDotEnvLocal() {
  const p = path.join(__dirname, "..", ".env.local");
  try {
    const raw = fs.readFileSync(p, "utf8");
    for (const line of raw.split("\n")) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) continue;
      const eq = trimmed.indexOf("=");
      if (eq <= 0) continue;
      const key = trimmed.slice(0, eq).trim();
      let val = trimmed.slice(eq + 1).trim();
      if (
        (val.startsWith('"') && val.endsWith('"')) ||
        (val.startsWith("'") && val.endsWith("'"))
      ) {
        val = val.slice(1, -1);
      }
      if (key === "DATABASE_URL" && val && !process.env.DATABASE_URL) {
        process.env.DATABASE_URL = val;
      }
    }
  } catch {
    /* noop */
  }
}

function sslOption(connectionString) {
  const host =
    (() => {
      try {
        return new URL(connectionString.replace(/^postgres:/, "http:")).hostname;
      } catch {
        return "";
      }
    })() || "";
  if (/supabase\.(co|com|net)/i.test(host)) {
    return { rejectUnauthorized: false };
  }
  return undefined;
}

async function main() {
  loadDotEnvLocal();

  const stamp = process.argv[2];
  if (!stamp) {
    console.error(
      "Uso: npm run import:farmac-os:supabase -- <stamp>\nEjemplo stamp: 20260429T001330 (como en los archivos part*.sql)"
    );
    process.exit(1);
  }

  const databaseUrl = process.env.DATABASE_URL || "";
  if (!databaseUrl.startsWith("postgres")) {
    console.error(
      "Definí DATABASE_URL con la URI de Postgres de Supabase.\n" +
        "Ejemplo:\n" +
        "  export DATABASE_URL='postgresql://postgres.xxxx:TU_PASSWORD@aws-0-xx.pooler.supabase.com:6543/postgres'\n" +
        "O agregá DATABASE_URL=... en .env.local en la raíz del proyecto."
    );
    process.exit(1);
  }

  const dir = path.join(__dirname, "..", "sql", "generated");
  let files = [];
  try {
    files = fs
      .readdirSync(dir)
      .filter(
        (f) =>
          f.startsWith(`import_farmac_os_${stamp}_part`) &&
          f.endsWith(".sql")
      )
      .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
  } catch (e) {
    console.error("No se pudo leer", dir, e.message);
    process.exit(1);
  }

  if (!files.length) {
    console.error(
      `No hay archivos import_farmac_os_${stamp}_part*.sql en ${dir}\n` +
        "Corré antes: npm run import:farmac-os -- \"/ruta/FARMACOS.xlsx\""
    );
    process.exit(1);
  }

  const client = new Client({
    connectionString: databaseUrl,
    ssl: sslOption(databaseUrl),
  });

  await client.connect();
  console.log(`Conectado. Ejecutando ${files.length} archivos…`);

  try {
    for (const name of files) {
      const full = path.join(dir, name);
      const sql = fs.readFileSync(full, "utf8");
      process.stdout.write(`→ ${name} (${Math.round(sql.length / 1024)} KiB)\n`);
      await client.query(sql);
    }
  } catch (err) {
    console.error("\nError:", err.message || err);
    process.exitCode = 1;
  } finally {
    await client.end().catch(() => {});
  }

  if (!process.exitCode) {
    console.log("\nListo. Verificá en SQL Editor:\n");
    console.log(
      `SELECT COUNT(*) FROM public.productos WHERE notas LIKE '%IMPORT_FARMACOS_${stamp}%';`
    );
  }
}

main();
