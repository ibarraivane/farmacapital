'use strict';

const { getSupabaseAdminConfig, validateEmployeeSession } = require('./supabaseAdmin');

const VTEX = 'https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/';
const MAX_PRODUCTOS = 8;
const HOY = () => new Date().toISOString().slice(0, 10);

function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function terminoBusqueda(p) {
  const pa = String(p.principio_activo || '').trim();
  if (pa.length >= 4) return pa.slice(0, 80);
  const nom = String(p.nombre || '')
    .replace(/\b(c\/|con|de|mg|ml|caps?|tab|tabs|tabletas?)\b/gi, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  return nom.split(' ').slice(0, 3).join(' ').slice(0, 80);
}

function precioDeVtex(items) {
  if (!Array.isArray(items)) return null;
  for (const prod of items) {
    const offer = prod?.items?.[0]?.sellers?.[0]?.commertialOffer;
    const precio = parseFloat(offer?.Price);
    if (Number.isFinite(precio) && precio > 0) {
      return {
        precio,
        nombre: prod.productName || prod.productTitle || null,
      };
    }
  }
  return null;
}

async function buscarVtex(term) {
  const url = VTEX + encodeURIComponent(term);
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), 3500);
  try {
    const r = await fetch(url, {
      signal: ctrl.signal,
      headers: { Accept: 'application/json' },
    });
    if (!r.ok) return null;
    const data = await r.json();
    return precioDeVtex(data);
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

async function buscarSimilaresHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const body = safeJson(req);
  const sessionToken = String(body.session_token || req.headers['x-session-token'] || '').trim();
  if (!sessionToken) {
    return res.status(401).json({ ok: false, error: 'missing_session' });
  }
  const valid = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) {
    return res.status(401).json({ ok: false, error: 'invalid_session' });
  }

  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  const prodRes = await fetch(
    `${supabaseUrl}/rest/v1/productos?select=id,sku,nombre,principio_activo,activo&activo=eq.true&order=nombre.asc&limit=400`,
    { headers }
  );
  if (!prodRes.ok) {
    return res.status(502).json({ ok: false, error: 'productos_failed' });
  }
  const productos = await prodRes.json();

  const refRes = await fetch(
    `${supabaseUrl}/rest/v1/producto_precios_referencia?select=producto_id,fuente,fecha&fuente=eq.similares&order=fecha.desc&limit=4000`,
    { headers }
  );
  const refs = refRes.ok ? await refRes.json() : [];
  const yaTiene = new Set((refs || []).map((r) => r.producto_id));

  const candidatos = productos.filter((p) => !yaTiene.has(p.id) && terminoBusqueda(p).length >= 4);
  const lote = candidatos.slice(0, MAX_PRODUCTOS);

  const encontrados = [];
  for (const p of lote) {
    const term = terminoBusqueda(p);
    const hit = await buscarVtex(term);
    if (hit) encontrados.push({ ...p, ...hit, term });
  }

  if (!encontrados.length) {
    return res.status(200).json({
      ok: true,
      buscados: lote.length,
      actualizados: 0,
      message: lote.length
        ? 'Similares no devolvió coincidencias en este lote. Intenta de nuevo o importa CSV.'
        : 'Todos los productos ya tienen precio de Similares. Importa CSV para Exprezo, Levic, Nadro o Marzam.',
    });
  }

  const impRes = await fetch(`${supabaseUrl}/rest/v1/importaciones_referencia`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      fuente: 'similares',
      tipo: 'venta',
      fecha_lista: HOY(),
      archivo: 'buscar_similares_vtex',
      filas_ok: encontrados.length,
      filas_error: 0,
      notas: 'boton_buscar_ui',
    }),
  });
  if (!impRes.ok) {
    const detail = await impRes.text().catch(() => '');
    return res.status(502).json({ ok: false, error: 'import_failed', detail: detail.slice(0, 200) });
  }
  const imp = await impRes.json();
  const importId = Array.isArray(imp) ? imp[0]?.id : imp?.id;

  const payload = encontrados.map((m) => ({
    producto_id: m.id,
    fuente: 'similares',
    tipo: 'venta',
    precio: m.precio,
    fecha: HOY(),
    origen: 'job_vtex',
    import_id: importId || null,
    confianza: 70,
    nombre_fuente: m.nombre,
    notas: `Búsqueda Similares: ${m.term}`,
  }));

  const ins = await fetch(`${supabaseUrl}/rest/v1/producto_precios_referencia`, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload),
  });
  if (!ins.ok) {
    const detail = await ins.text().catch(() => '');
    return res.status(502).json({ ok: false, error: 'insert_failed', detail: detail.slice(0, 200) });
  }

  return res.status(200).json({
    ok: true,
    buscados: lote.length,
    actualizados: encontrados.length,
    pendientes: Math.max(0, candidatos.length - lote.length),
    message: `Se actualizaron ${encontrados.length} precio(s) de Similares.`
      + (candidatos.length > lote.length
        ? ` Quedan ${candidatos.length - lote.length} sin buscar: pulsa otra vez.`
        : ''),
  });
}

module.exports = { buscarSimilaresHandler };
