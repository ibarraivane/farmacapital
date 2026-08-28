'use strict';

/**
 * Actualiza precios de compra públicos (Scorpion + Abarrotero) y los escribe
 * en producto_precios_referencia. Lo dispara el botón Actualizar de Inventario.
 * Lotes chicos: Vercel Hobby corta a ~10s.
 */

const { getSupabaseAdminConfig, validateEmployeeSession } = require('./supabaseAdmin');

const UA = 'FarmaCapitalPricingBot/1.0 (+https://farmacapital.mx) AppleWebKit/537.36';
const HOY = () => new Date().toISOString().slice(0, 10);
const MAX_INSERT = 80;

function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function norm(s) {
  return String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .replace(/[^a-z0-9/ ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function tokenScore(a, b) {
  const ta = new Set(norm(a).split(' ').filter((t) => t.length > 1));
  const tb = new Set(norm(b).split(' ').filter((t) => t.length > 1));
  if (!ta.size || !tb.size) return 0;
  let inter = 0;
  for (const t of ta) if (tb.has(t)) inter += 1;
  return Math.round((200 * inter) / (ta.size + tb.size));
}

function marcaEnNombre(marca, nombre) {
  const m = norm(marca);
  if (!m || m.length < 3) return false;
  return (` ${norm(nombre)} `).includes(` ${m} `);
}

function moneyFrom(s) {
  const n = parseFloat(String(s || '').replace(/[$,\s]/g, ''));
  return Number.isFinite(n) && n > 0 ? n : null;
}

async function fetchText(url, ms = 6000) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms);
  try {
    const r = await fetch(url, {
      signal: ctrl.signal,
      headers: { 'User-Agent': UA, Accept: 'application/json,text/html;q=0.9' },
    });
    if (!r.ok) return null;
    return await r.text();
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

async function extraerAbarrotero() {
  const out = [];
  for (const cat of [6873, 8221]) {
    const raw = await fetchText(
      `https://abarrotero.com/wp-json/wc/store/v1/products?category=${cat}&per_page=50&page=1`
    );
    if (!raw) continue;
    let arr;
    try { arr = JSON.parse(raw); } catch { continue; }
    if (!Array.isArray(arr)) continue;
    for (const p of arr) {
      const minor = Number(p.prices?.currency_minor_unit || 0);
      const precio = Number(p.prices?.sale_price || p.prices?.price) / (10 ** minor);
      const caja = String(p.name || '').match(/caja\s+con\s+(\d+)/i);
      const n = caja ? Number(caja[1]) : 1;
      if (!(precio > 0)) continue;
      out.push({
        fuente: 'abarrotero',
        nombre: String(p.name || '').replace(/&#8211;/g, '—'),
        precio: n > 1 ? precio / n : precio,
      });
    }
  }
  return out;
}

function extraerScorpionHtml(html) {
  const out = [];
  const re = /<a class="product-item-link" href="[^"]+">\s*([^<]+?)\s*<\/a>[\s\S]{0,2500}?<h4>\s*Pieza\s*<\/h4>\s*<div class="price"><span class="price">\$([0-9.,]+)/gi;
  let m;
  while ((m = re.exec(html))) {
    const precio = moneyFrom(m[2]);
    if (!precio) continue;
    out.push({ fuente: 'scorpion', nombre: m[1].trim(), precio });
  }
  return out;
}

function matchear(productos, ofertas) {
  const hits = [];
  for (const ofe of ofertas) {
    let best = null;
    let bestScore = 0;
    for (const p of productos) {
      if (p.marca && String(p.marca).trim().length >= 3 && !marcaEnNombre(p.marca, ofe.nombre)) {
        continue;
      }
      const score = tokenScore(`${p.marca} ${p.nombre} ${p.presentacion || ''}`, ofe.nombre);
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    if (best && bestScore >= 78 && ofe.precio > 0) {
      hits.push({
        producto_id: best.id,
        fuente: ofe.fuente,
        precio: Math.round(ofe.precio * 100) / 100,
        nombre_fuente: ofe.nombre,
        confianza: bestScore >= 90 ? 90 : 80,
      });
    }
  }
  // un precio por producto+fuente (el más barato)
  const uniq = new Map();
  for (const h of hits) {
    const k = `${h.producto_id}:${h.fuente}`;
    const prev = uniq.get(k);
    if (!prev || h.precio < prev.precio) uniq.set(k, h);
  }
  return [...uniq.values()].slice(0, MAX_INSERT);
}

async function actualizarCompraHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }
  const body = safeJson(req);
  const sessionToken = String(body.session_token || req.headers['x-session-token'] || '').trim();
  if (!sessionToken) return res.status(401).json({ ok: false, error: 'missing_session' });
  const valid = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) return res.status(401).json({ ok: false, error: 'invalid_session' });

  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  await fetch(`${supabaseUrl}/rest/v1/fuentes_precio`, {
    method: 'POST',
    headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=minimal' },
    body: JSON.stringify([
      { id: 'scorpion', nombre: 'Scorpion', tipo: 'compra', metodo: 'job_api' },
      { id: 'abarrotero', nombre: 'Abarrotero', tipo: 'compra', metodo: 'job_api' },
      { id: 'mayoreototal', nombre: 'MayoreoTotal', tipo: 'compra', metodo: 'job_api' },
    ]),
  }).catch(() => {});

  const prodRes = await fetch(
    `${supabaseUrl}/rest/v1/productos?select=id,sku,nombre,marca,presentacion,costo,categoria,activo&activo=eq.true&order=nombre.asc&limit=800`,
    { headers }
  );
  if (!prodRes.ok) return res.status(502).json({ ok: false, error: 'productos_failed' });
  const productos = await prodRes.json();

  const [abar, scorpHtml] = await Promise.all([
    extraerAbarrotero(),
    fetchText('https://www.scorpion.com.mx/tienda/higiene-y-cuidado-personal.html', 7000),
  ]);
  const scorp = scorpHtml ? extraerScorpionHtml(scorpHtml) : [];
  const ofertas = [...abar, ...scorp];
  const matched = matchear(productos, ofertas);

  if (!matched.length) {
    return res.status(200).json({
      ok: true,
      actualizados: 0,
      ofertas: ofertas.length,
      message: ofertas.length
        ? 'Se bajaron listas públicas, pero no hubo cruce fiable con tu catálogo. Se mantiene lo ya guardado.'
        : 'No se pudo leer Scorpion/Abarrotero ahora. Se mantiene lo guardado; reintenta en un minuto.',
    });
  }

  const porFuente = {};
  for (const m of matched) {
    if (!porFuente[m.fuente]) porFuente[m.fuente] = [];
    porFuente[m.fuente].push(m);
  }

  let insertados = 0;
  for (const [fuente, filas] of Object.entries(porFuente)) {
    const impRes = await fetch(`${supabaseUrl}/rest/v1/importaciones_referencia`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        fuente,
        tipo: 'compra',
        fecha_lista: HOY(),
        archivo: 'boton_actualizar_compra',
        filas_ok: filas.length,
        filas_error: 0,
        notas: 'ui_actualizar',
      }),
    });
    const imp = impRes.ok ? await impRes.json() : [];
    const importId = Array.isArray(imp) ? imp[0]?.id : imp?.id;
    const payload = filas.map((m) => ({
      producto_id: m.producto_id,
      fuente: m.fuente,
      tipo: 'compra',
      precio: m.precio,
      fecha: HOY(),
      origen: 'job_api',
      import_id: importId || null,
      confianza: m.confianza,
      nombre_fuente: m.nombre_fuente,
      notas: 'boton_actualizar',
    }));
    const ins = await fetch(`${supabaseUrl}/rest/v1/producto_precios_referencia`, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });
    if (ins.ok) insertados += filas.length;
  }

  return res.status(200).json({
    ok: true,
    actualizados: insertados,
    ofertas: ofertas.length,
    message: insertados
      ? `Se actualizaron ${insertados} precio(s) de compra (Scorpion/Abarrotero). «Comprar en» ya los usa.`
      : 'Listas leídas, no se pudieron guardar. ¿Corriste sql/patch_fuentes_scorpion_abarrotero.sql?',
  });
}

module.exports = { actualizarCompraHandler };
