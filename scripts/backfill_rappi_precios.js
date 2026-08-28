#!/usr/bin/env node
/**
 * Llena precios de otras tiendas en Rappi (página pública).
 * No inventa precios. Prioriza SKUs que ya cruzamos por foto/EAN.
 *
 *   node scripts/backfill_rappi_precios.js --probe 20
 *   node scripts/backfill_rappi_precios.js --solo-linked --concurrency 2
 */
'use strict';

const fs = require('fs');
const path = require('path');
const { runRastreoRappi } = require('../api/_lib/rastrearRappi');

const ROOT = path.join(__dirname, '..');

function loadEnv() {
  for (const f of ['.env', '.env.local']) {
    const p = path.join(ROOT, f);
    if (!fs.existsSync(p)) continue;
    for (const line of fs.readFileSync(p, 'utf8').split('\n')) {
      const t = line.trim();
      if (!t || t.startsWith('#') || !t.includes('=')) continue;
      const i = t.indexOf('=');
      const k = t.slice(0, i).trim();
      let v = t.slice(i + 1).trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.slice(1, -1);
      }
      if (!process.env[k]) process.env[k] = v;
    }
  }
}

function arg(name, fallback) {
  const i = process.argv.indexOf(name);
  if (i < 0) return fallback;
  const next = process.argv[i + 1];
  if (!next || next.startsWith('--')) return true;
  return next;
}

async function main() {
  loadEnv();
  const supabaseUrl = (process.env.REACT_APP_SUPABASE_URL || process.env.SUPABASE_URL || '').replace(/\/$/, '');
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
  if (!supabaseUrl || !serviceKey) {
    console.error('Falta SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY');
    process.exit(1);
  }

  const probe = arg('--probe');
  const idsRaw = arg('--ids');
  const ids = typeof idsRaw === 'string'
    ? idsRaw.split(',').map((x) => Number(x.trim())).filter(Boolean)
    : [];
  const max = ids.length || (probe ? Number(probe) || 20 : Number(arg('--max', 800)));
  const concurrency = Number(arg('--concurrency', 1));
  const soloLinked = process.argv.includes('--todos') ? false : true;
  const dryRun = process.argv.includes('--dry-run');
  const corto = process.argv.includes('--corto');

  console.log(JSON.stringify({
    max, concurrency, soloLinked, corto, dryRun, url: supabaseUrl,
  }));

  const t0 = Date.now();
  const out = await runRastreoRappi({
    supabaseUrl,
    serviceKey,
    max,
    concurrency,
    soloLinked,
    corto,
    ids,
    timeoutMs: 6000,
    dryRun,
    onProgress: ({ idx, total, producto, filas, error, term }) => {
      const n = filas ? filas.length : 0;
      const mark = error ? error : `${n} precios`;
      console.log(`${idx + 1}/${total} ${producto.sku} ${producto.nombre} · ${term} · ${mark}`);
    },
  });

  console.log(JSON.stringify({
    ...out,
    errores: out.errores.length,
    ms: Date.now() - t0,
  }, null, 2));
  if (out.errores.length) {
    console.log('sin_match/sin_html', out.errores.slice(0, 12));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
