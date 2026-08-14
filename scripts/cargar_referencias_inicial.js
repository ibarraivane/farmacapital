#!/usr/bin/env node
/**
 * Carga referencias de precio (FDA, Exprezo, Similares lote1) vía REST + service role.
 *
 * Requiere en .env (o entorno):
 *   SUPABASE_SERVICE_ROLE_KEY  (Dashboard → Settings → API → service_role)
 *   SUPABASE_URL o REACT_APP_SUPABASE_URL
 *
 * Uso:
 *   node scripts/cargar_referencias_inicial.js
 *   node scripts/cargar_referencias_inicial.js --dry-run
 *
 * Alternativa sin service role: ejecutar sql/pricing/generated/carga_inicial_referencias_20260814.sql
 * en Supabase SQL Editor.
 */
'use strict';

const fs = require('fs');
const path = require('path');

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

function parseCsv(file) {
  const text = fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '');
  const lines = text.split(/\r?\n/).filter((l) => l.trim());
  const headers = lines[0].split(',').map((h) => h.trim());
  return lines.slice(1).map((line) => {
    const row = {};
    const cells = [];
    let cur = '';
    let q = false;
    for (let i = 0; i < line.length; i++) {
      const c = line[i];
      if (c === '"') {
        if (q && line[i + 1] === '"') { cur += '"'; i++; }
        else q = !q;
      } else if (c === ',' && !q) {
        cells.push(cur);
        cur = '';
      } else cur += c;
    }
    cells.push(cur);
    headers.forEach((h, i) => { row[h] = (cells[i] || '').trim(); });
    return row;
  });
}

const CONF = { alta: 85, media: 75, dudoso: 60 };

async function main() {
  loadEnv();
  const dryRun = process.argv.includes('--dry-run');
  const url = (process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '').replace(/\/+$/, '');
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
  if (!url || !key || key.includes('SENSITIVE') || key.length < 40) {
    console.error('Falta SUPABASE_SERVICE_ROLE_KEY válida en .env');
    console.error('Copiala de Supabase → Settings → API → service_role (secret)');
    console.error('O ejecuta sql/pricing/generated/carga_inicial_referencias_20260814.sql en SQL Editor.');
    process.exit(1);
  }

  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  const productos = [];
  let offset = 0;
  while (true) {
    const r = await fetch(
      `${url}/rest/v1/productos?select=id,sku&activo=eq.true&order=id.asc`,
      { headers: { ...headers, Range: `${offset}-${offset + 499}` } }
    );
    if (!r.ok) throw new Error(`productos ${r.status}: ${await r.text()}`);
    const batch = await r.json();
    productos.push(...batch);
    if (batch.length < 500) break;
    offset += 500;
  }
  const skuIdx = Object.fromEntries(productos.filter((p) => p.sku).map((p) => [p.sku, p.id]));

  const batches = [
    { fuente: 'fahorro', tipo: 'venta', archivo: 'import_fahorro_listo.csv', file: 'pricing/importados/import_fahorro_listo.csv' },
    { fuente: 'exprezo', tipo: 'compra', archivo: 'import_exprezo_listo.csv', file: 'pricing/importados/import_exprezo_listo.csv' },
    { fuente: 'similares', tipo: 'venta', archivo: 'import_similares_lote1_listo.csv', file: 'pricing/importados/import_similares_lote1_listo.csv', withNotas: true },
  ];

  const fecha = '2026-08-14';
  let total = 0;

  for (const b of batches) {
    const rows = parseCsv(path.join(ROOT, b.file));
    const matched = [];
    for (const row of rows) {
      const sku = row.sku;
      const precio = parseFloat(String(row.precio || '').replace(/[$,]/g, ''));
      if (!sku || !Number.isFinite(precio)) continue;
      const pid = skuIdx[sku];
      if (!pid) continue;
      const confRaw = row.confianza_match || row.confianza || 'alta';
      const confianza = CONF[String(confRaw).toLowerCase()] || (Number(confRaw) || 85);
      matched.push({
        producto_id: pid,
        sku,
        precio,
        confianza,
        notas: row.notas || null,
      });
    }
    console.log(`${b.fuente}: ${matched.length} SKUs`);
    if (dryRun || !matched.length) continue;

    const impRes = await fetch(`${url}/rest/v1/importaciones_referencia`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        fuente: b.fuente,
        tipo: b.tipo,
        fecha_lista: fecha,
        archivo: b.archivo,
        filas_ok: matched.length,
        filas_error: 0,
        notas: 'cargar_referencias_inicial.js',
      }),
    });
    if (!impRes.ok) throw new Error(`import ${b.fuente} ${impRes.status}: ${await impRes.text()}`);
    const importId = (await impRes.json())[0].id;

    const payload = matched.map((m) => ({
      producto_id: m.producto_id,
      fuente: b.fuente,
      tipo: b.tipo,
      precio: m.precio,
      fecha,
      origen: 'import_csv',
      import_id: importId,
      confianza: m.confianza,
      ...(b.withNotas && m.notas ? { notas: m.notas } : {}),
    }));

    for (let i = 0; i < payload.length; i += 100) {
      const chunk = payload.slice(i, i + 100);
      const r = await fetch(`${url}/rest/v1/producto_precios_referencia`, {
        method: 'POST',
        headers,
        body: JSON.stringify(chunk),
      });
      if (!r.ok) throw new Error(`insert ${b.fuente} ${r.status}: ${await r.text()}`);
    }
    total += matched.length;
  }

  if (dryRun) {
    console.log('Dry-run OK. Quita --dry-run para insertar.');
    return;
  }

  const countRes = await fetch(`${url}/rest/v1/producto_precios_referencia?select=fuente`, {
    headers: { ...headers, Prefer: 'count=exact' },
  });
  console.log(`Listo. Insertadas ${total} referencias. Total en BD: ${countRes.headers.get('content-range')}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
