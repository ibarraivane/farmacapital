#!/usr/bin/env node
/**
 * Ejecuta sql/pricing/generated/carga_inicial_referencias_20260814.sql en Postgres.
 * Requiere DATABASE_URL (Supabase → Settings → Database → URI, Session mode 6543).
 */
'use strict';

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const SQL_FILE = path.join(__dirname, '..', 'sql/pricing/generated/carga_inicial_referencias_20260814.sql');

function loadEnv() {
  for (const f of ['.env.local', '.env']) {
    const p = path.join(__dirname, '..', f);
    if (!fs.existsSync(p)) continue;
    for (const line of fs.readFileSync(p, 'utf8').split('\n')) {
      const t = line.trim();
      if (!t || t.startsWith('#') || !t.includes('=')) continue;
      const i = t.indexOf('=');
      const k = t.slice(0, i).trim();
      let v = t.slice(i + 1).trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) v = v.slice(1, -1);
      if (!process.env[k]) process.env[k] = v;
    }
  }
}

function sslOpt(url) {
  try {
    const host = new URL(url.replace(/^postgres:/, 'http:')).hostname;
    if (/supabase\.(co|com|net)/i.test(host)) return { rejectUnauthorized: false };
  } catch { /* noop */ }
  return undefined;
}

async function main() {
  loadEnv();
  const url = process.env.DATABASE_URL || process.env.SUPABASE_DB_URL || '';
  if (!url.startsWith('postgres')) {
    console.error('Falta DATABASE_URL o SUPABASE_DB_URL en .env / .env.local');
    process.exit(1);
  }
  if (!fs.existsSync(SQL_FILE)) {
    console.error('No existe:', SQL_FILE);
    process.exit(1);
  }
  const sql = fs.readFileSync(SQL_FILE, 'utf8');
  const client = new Client({ connectionString: url, ssl: sslOpt(url) });
  await client.connect();
  try {
    await client.query(sql);
    const { rows } = await client.query(`
      SELECT fuente, COUNT(*)::int AS n
      FROM public.producto_precios_referencia
      GROUP BY fuente ORDER BY fuente
    `);
    console.log('Carga OK. Referencias por fuente:');
    for (const r of rows) console.log(`  ${r.fuente}: ${r.n}`);
  } finally {
    await client.end();
  }
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
