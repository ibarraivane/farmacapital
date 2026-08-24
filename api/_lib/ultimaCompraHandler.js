'use strict';

const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
} = require('./supabaseAdmin');

async function rest(supabaseUrl, serviceKey, path, { method = 'GET', body, prefer } = {}) {
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    Accept: 'application/json',
    'Content-Type': 'application/json',
  };
  if (prefer) headers.Prefer = prefer;
  const resp = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`rest_failed:${resp.status}:${detail.slice(0, 240)}`);
  }
  return data;
}

function normalizeProveedor(nombre) {
  const n = String(nombre || '').trim();
  if (!n) return '';
  if (/cityfarma|farma\s*city/i.test(n)) return 'Farma City';
  if (/farmalive|farmalife/i.test(n)) return 'Farmalive';
  if (/^levic\b/i.test(n)) return 'Levic';
  if (/exprezo|zorro/i.test(n)) return 'Exprezo';
  if (/equilibrio/i.test(n)) return 'Equilibrio';
  if (/surtidor/i.test(n)) return 'El Surtidor';
  if (/bodega|f-?42/i.test(n)) return 'Bodega F-42';
  if (/\bifc\b/i.test(n)) return 'IFC';
  if (/farma\s*mx|farmamx/i.test(n)) return 'Farma MX';
  return n;
}

async function ensureFuente(supabaseUrl, serviceKey) {
  await rest(supabaseUrl, serviceKey, 'fuentes_precio', {
    method: 'POST',
    prefer: 'resolution=merge-duplicates,return=minimal',
    body: [{
      id: 'ultima_compra',
      nombre: 'Última compra',
      tipo: 'compra',
      metodo: 'manual',
      notas: 'Precio pagado en el último ticket de Recibir. No es lista de proveedor.',
    }],
  });
}

async function registrarDesdeRecepcion(supabaseUrl, serviceKey, recepcionId) {
  const recs = await rest(
    supabaseUrl,
    serviceKey,
    `recepciones?id=eq.${encodeURIComponent(recepcionId)}&select=id,proveedor,folio,fecha`,
  );
  const rec = recs?.[0];
  if (!rec) throw new Error('recepcion_no_existe');

  const items = await rest(
    supabaseUrl,
    serviceKey,
    `recepcion_items?recepcion_id=eq.${encodeURIComponent(recepcionId)}&confirmado=eq.true&pendiente_alta=eq.false&producto_id=not.is.null&select=producto_id,costo_estimado`,
  );

  const proveedor = normalizeProveedor(rec.proveedor) || String(rec.proveedor || '').trim();
  const fecha = rec.fecha || new Date().toISOString().slice(0, 10);
  const folio = rec.folio ? String(rec.folio) : '';
  const byProd = new Map();
  for (const item of items || []) {
    const productoId = Number(item.producto_id);
    const precio = Number(item.costo_estimado);
    if (!productoId || !Number.isFinite(precio) || precio <= 0) continue;
    byProd.set(productoId, {
      producto_id: productoId,
      fuente: 'ultima_compra',
      tipo: 'compra',
      precio,
      fecha,
      nombre_fuente: proveedor,
      sku_externo: folio || null,
      confianza: 100,
      origen: 'manual',
      notas: folio ? `ticket ${folio}` : 'recepcion',
    });
  }
  const filas = [...byProd.values()];
  if (!filas.length) return { ok: true, count: 0 };

  await ensureFuente(supabaseUrl, serviceKey);
  await rest(supabaseUrl, serviceKey, 'producto_precios_referencia', {
    method: 'POST',
    prefer: 'return=minimal',
    body: filas,
  });
  return { ok: true, count: filas.length };
}

async function ultimaCompraHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ error: 'Supabase no configurado en el servidor' });
  }

  let body = {};
  try {
    if (req.body && typeof req.body === 'object') body = req.body;
    else if (typeof req.body === 'string') body = JSON.parse(req.body || '{}');
  } catch {
    body = {};
  }

  const sessionToken = String(body.session_token || '').trim();
  const sessionOk = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!sessionOk) {
    return res.status(401).json({ error: 'Sesión no válida o expirada' });
  }

  const recepcionId = Number(body.recepcion_id);
  if (!Number.isFinite(recepcionId) || recepcionId <= 0) {
    return res.status(400).json({ error: 'recepcion_id requerido' });
  }

  try {
    const result = await registrarDesdeRecepcion(supabaseUrl, serviceKey, recepcionId);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(500).json({ error: err.message || 'No se registró la última compra' });
  }
}

module.exports = { ultimaCompraHandler, registrarDesdeRecepcion, normalizeProveedor };
