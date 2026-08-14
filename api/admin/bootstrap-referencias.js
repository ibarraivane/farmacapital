'use strict';

const fs = require('fs');
const path = require('path');
const { getSupabaseAdminConfig, validateEmployeeSession, readRawBody } = require('../_lib/supabaseAdmin');

const ROOT = path.join(__dirname, '..', '..');
const FECHA = '2026-08-14';

function isAuthorized(req) {
  const cron = String(process.env.CRON_SECRET || '').trim();
  const auth = String(req.headers.authorization || '').replace(/^Bearer\s+/i, '').trim();
  if (cron && auth === cron) return true;
  return false;
}

function parseCsv(text) {
  const lines = text.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n').split('\n').filter((l) => l.trim());
  if (!lines.length) return [];
  const headers = lines[0].split(',').map((h) => h.trim());
  return lines.slice(1).map((line) => {
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
    const row = {};
    headers.forEach((h, i) => { row[h] = (cells[i] || '').trim(); });
    return row;
  });
}

function loadBatch(fuente, tipo, archivo, filePath, withNotas = false) {
  const full = path.join(ROOT, filePath);
  if (!fs.existsSync(full)) return null;
  const rows = parseCsv(fs.readFileSync(full, 'utf8'));
  return { fuente, tipo, archivo, rows, withNotas };
}

const CONF = { alta: 85, media: 75, dudoso: 60 };

async function fetchSkuIndex(url, key) {
  const headers = { apikey: key, Authorization: `Bearer ${key}` };
  const map = {};
  let offset = 0;
  while (true) {
    const r = await fetch(
      `${url}/rest/v1/productos?select=id,sku&activo=eq.true&order=id.asc`,
      { headers: { ...headers, Range: `${offset}-${offset + 499}` } }
    );
    if (!r.ok) throw new Error(`productos ${r.status}`);
    const batch = await r.json();
    for (const p of batch) {
      if (p.sku) map[p.sku] = p.id;
    }
    if (batch.length < 500) break;
    offset += 500;
  }
  return map;
}

async function applyBatch(url, key, skuIdx, batch) {
  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  const matched = [];
  for (const row of batch.rows) {
    const sku = row.sku;
    const precio = parseFloat(String(row.precio || '').replace(/[$,]/g, ''));
    if (!sku || !Number.isFinite(precio)) continue;
    const pid = skuIdx[sku];
    if (!pid) continue;
    const confRaw = row.confianza_match || row.confianza || 'alta';
    const confianza = CONF[String(confRaw).toLowerCase()] || (Number(confRaw) || 85);
    matched.push({ producto_id: pid, precio, confianza, notas: row.notas || null });
  }
  if (!matched.length) return { fuente: batch.fuente, inserted: 0 };

  const impRes = await fetch(`${url}/rest/v1/importaciones_referencia`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      fuente: batch.fuente,
      tipo: batch.tipo,
      fecha_lista: FECHA,
      archivo: batch.archivo,
      filas_ok: matched.length,
      filas_error: 0,
      notas: 'bootstrap-referencias API',
    }),
  });
  if (!impRes.ok) {
    throw new Error(`import ${batch.fuente}: ${impRes.status} ${(await impRes.text()).slice(0, 200)}`);
  }
  const importId = (await impRes.json())[0].id;

  const payload = matched.map((m) => ({
    producto_id: m.producto_id,
    fuente: batch.fuente,
    tipo: batch.tipo,
    precio: m.precio,
    fecha: FECHA,
    origen: 'import_csv',
    import_id: importId,
    confianza: m.confianza,
    ...(batch.withNotas && m.notas ? { notas: m.notas } : {}),
  }));

  for (let i = 0; i < payload.length; i += 100) {
    const chunk = payload.slice(i, i + 100);
    const r = await fetch(`${url}/rest/v1/producto_precios_referencia`, {
      method: 'POST',
      headers,
      body: JSON.stringify(chunk),
    });
    if (!r.ok) throw new Error(`insert ${batch.fuente}: ${r.status} ${(await r.text()).slice(0, 200)}`);
  }

  return { fuente: batch.fuente, inserted: matched.length };
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  let authed = isAuthorized(req);
  if (!authed) {
    const sessionToken = String(req.headers['x-session-token'] || '').trim();
    authed = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  }
  if (!authed) {
    return res.status(401).json({ ok: false, error: 'unauthorized' });
  }

  try {
    const countRes = await fetch(`${supabaseUrl}/rest/v1/producto_precios_referencia?select=id&limit=1`, {
      headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, Prefer: 'count=exact' },
    });
    const existing = countRes.headers.get('content-range');
    const already = existing && !existing.endsWith('/0');
    if (already && !String(req.url || '').includes('force=1')) {
      return res.status(200).json({
        ok: true,
        skipped: true,
        message: 'Ya hay referencias cargadas. Usa ?force=1 para volver a insertar.',
        content_range: existing,
      });
    }

    const skuIdx = await fetchSkuIndex(supabaseUrl, serviceKey);
    const batches = [
      loadBatch('fahorro', 'venta', 'import_fahorro_listo.csv', 'pricing/importados/import_fahorro_listo.csv'),
      loadBatch('exprezo', 'compra', 'import_exprezo_listo.csv', 'pricing/importados/import_exprezo_listo.csv'),
      loadBatch('similares', 'venta', 'import_similares_lote1_listo.csv', 'pricing/importados/import_similares_lote1_listo.csv', true),
    ].filter(Boolean);

    const results = [];
    for (const b of batches) {
      results.push(await applyBatch(supabaseUrl, serviceKey, skuIdx, b));
    }

    const total = results.reduce((s, r) => s + r.inserted, 0);
    return res.status(200).json({ ok: true, total, results, fecha: FECHA });
  } catch (err) {
    return res.status(500).json({ ok: false, error: String(err.message || err).slice(0, 300) });
  }
};
