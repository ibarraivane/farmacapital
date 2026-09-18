#!/usr/bin/env node
/**
 * Corre sql/alta_bajo_pedido_partes/*.sql contra Postgres (Supabase).
 * Evita pegar 28 archivos en el SQL Editor.
 *
 *   export DATABASE_URL='postgresql://postgres.[ref]:[pass]@aws-0-xx.pooler.supabase.com:6543/postgres'
 *   node scripts/aplicar-alta-bajo-pedido-pg.js
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

function loadDotEnvLocal() {
  const p = path.join(__dirname, "..", ".env.local");
  try {
    for (const line of fs.readFileSync(p, "utf8").split("\n")) {
      const t = line.trim();
      if (!t || t.startsWith("#")) continue;
      const eq = t.indexOf("=");
      if (eq <= 0) continue;
      const key = t.slice(0, eq).trim();
      let val = t.slice(eq + 1).trim().replace(/^['"]|['"]$/g, "");
      if (key === "DATABASE_URL" && val && !process.env.DATABASE_URL) {
        process.env.DATABASE_URL = val;
      }
    }
  } catch { /* noop */ }
}

async function main() {
  loadDotEnvLocal();
  const databaseUrl = process.env.DATABASE_URL || "";
  if (!databaseUrl.startsWith("postgres")) {
    console.error("Falta DATABASE_URL (pooler Session mode, puerto 6543).");
    process.exit(1);
  }
  const dir = path.join(__dirname, "..", "sql", "alta_bajo_pedido_partes");
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".sql")).sort();
  const client = new Client({
    connectionString: databaseUrl,
    ssl: /supabase\./i.test(databaseUrl) ? { rejectUnauthorized: false } : undefined,
  });
  await client.connect();
  console.log(`Conectado. ${files.length} partes…`);
  try {
    for (const f of files) {
      const sql = fs.readFileSync(path.join(dir, f), "utf8");
      const res = await client.query(sql);
      const last = Array.isArray(res) ? res[res.length - 1] : res;
      const rows = last && last.rows ? last.rows : [];
      console.log(f, rows.length ? JSON.stringify(rows[0]) : "ok");
    }
  } finally {
    await client.end();
  }
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
