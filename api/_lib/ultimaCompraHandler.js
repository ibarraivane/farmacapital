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
      nombre: 'Costo de compra',
      tipo: 'compra',
      metodo: 'manual',
      notas: 'Primera compra (quién + precio). Recibir solo lo pisa si el ticket es más barato.',
    }],
  });
}

function proveedorVisible(nombre) {
  const n = normalizeProveedor(nombre);
  if (!n || /^sin proveedor$/i.test(n)) return '';
  return n;
}

function esMasBarato(actual, nuevo) {
  const n = Number(nuevo);
  if (!Number.isFinite(n) || n <= 0) return false;
  const a = Number(actual);
  if (!Number.isFinite(a) || a <= 0) return true;
  return n < a - 0.005;
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

  const ids = [...new Set((items || []).map((i) => Number(i.producto_id)).filter(Boolean))];
  const actuales = {};
  const quienes = {};
  if (ids.length) {
    const vigentes = await rest(
      supabaseUrl,
      serviceKey,
      `producto_precios_referencia_actual?fuente=eq.ultima_compra&producto_id=in.(${ids.join(',')})&select=producto_id,precio,nombre_fuente`,
    );
    for (const row of vigentes || []) {
      actuales[Number(row.producto_id)] = row.precio;
      quienes[Number(row.producto_id)] = proveedorVisible(row.nombre_fuente);
    }
    if (Object.keys(actuales).length < ids.length) {
      const faltan = ids.filter((id) => actuales[id] == null);
      const prods = await rest(
        supabaseUrl,
        serviceKey,
        `productos?id=in.(${faltan.join(',')})&select=id,costo`,
      );
      for (const p of prods || []) {
        if (actuales[p.id] == null) actuales[p.id] = p.costo;
      }
    }
  }

  const proveedor = proveedorVisible(rec.proveedor) || String(rec.proveedor || '').trim();
  const fecha = new Date().toISOString().slice(0, 10);
  const fechaTicket = rec.fecha || fecha;
  const folio = rec.folio ? String(rec.folio) : '';
  const byProd = new Map();
  for (const item of items || []) {
    const productoId = Number(item.producto_id);
    const precioTicket = Number(item.costo_estimado);
    if (!productoId || !Number.isFinite(precioTicket) || precioTicket <= 0) continue;
    const masBarato = esMasBarato(actuales[productoId], precioTicket);
    const completarQuien = !masBarato && !quienes[productoId] && !!proveedor
      && Number(actuales[productoId]) > 0;
    if (!masBarato && !completarQuien) continue;
    const precio = masBarato ? precioTicket : Number(actuales[productoId]);
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
      notas: folio ? `ticket ${folio} ${fechaTicket}` : `recepcion ${fechaTicket}`,
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
    return res.status(500).json({ error: err.message || 'No se registró el costo de compra' });
  }
}

module.exports = { ultimaCompraHandler, registrarDesdeRecepcion, normalizeProveedor };
