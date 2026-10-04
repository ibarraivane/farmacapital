'use strict';

const {
  getSupabaseAdminConfig,
  validateAdminSession,
  readRawBody,
  rpc,
} = require('./supabaseAdmin');
const { planCambioFotos, claveFoto } = require('./fotosProductoPlan');

function isProductoImagenesRequest(req) {
  const t = String(req.query?.type || '').trim().toLowerCase();
  return t === 'producto-imagenes' || t === 'producto_imagenes';
}

async function rest(supabaseUrl, serviceKey, path, { method = 'GET', body } = {}) {
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    Accept: 'application/json',
  };
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    headers.Prefer = 'return=representation';
  }
  const resp = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await resp.text();
  let data = null;
  if (text) {
    try { data = JSON.parse(text); } catch { data = text; }
  }
  if (!resp.ok) {
    const detail = typeof data === 'string' ? data : JSON.stringify(data || {});
    const err = new Error(`rest_${resp.status}:${detail.slice(0, 300)}`);
    err.status = resp.status;
    throw err;
  }
  return data;
}

async function leerProducto(supabaseUrl, serviceKey, productoId) {
  const rows = await rest(
    supabaseUrl,
    serviceKey,
    `productos?id=eq.${productoId}&select=id,imagen_url`,
  );
  return Array.isArray(rows) ? rows[0] : null;
}

async function leerFilas(supabaseUrl, serviceKey, productoId) {
  const rows = await rest(
    supabaseUrl,
    serviceKey,
    `producto_imagenes?producto_id=eq.${productoId}&select=id,url,posicion,es_principal&order=posicion.asc`,
  );
  return Array.isArray(rows) ? rows : [];
}

async function escribirPlan(supabaseUrl, serviceKey, productoId, antes, plan) {
  if (plan.sinCambio) return;

  await rest(
    supabaseUrl,
    serviceKey,
    `producto_imagenes?producto_id=eq.${productoId}&es_principal=eq.true`,
    { method: 'PATCH', body: { es_principal: false } },
  );

  const despuesClaves = new Set(plan.filas.map((f) => claveFoto(f.url)));
  for (const row of antes) {
    if (!row.id || despuesClaves.has(claveFoto(row.url))) continue;
    await rest(supabaseUrl, serviceKey, `producto_imagenes?id=eq.${row.id}`, { method: 'DELETE' });
  }

  const antesClaves = new Set(antes.map((f) => claveFoto(f.url)));
  const nuevas = plan.filas.filter((f) => !antesClaves.has(claveFoto(f.url)));
  if (nuevas.length) {
    await rest(supabaseUrl, serviceKey, 'producto_imagenes', {
      method: 'POST',
      body: nuevas.map((f) => ({
        producto_id: productoId,
        url: f.url,
        posicion: f.posicion,
        es_principal: false,
        origen: 'propia',
      })),
    });
  }

  const principal = plan.filas.find((f) => f.es_principal);
  if (!principal) return;
  const actuales = await leerFilas(supabaseUrl, serviceKey, productoId);
  const row = actuales.find((f) => claveFoto(f.url) === claveFoto(principal.url));
  if (!row?.id) return;
  await rest(
    supabaseUrl,
    serviceKey,
    `producto_imagenes?id=eq.${row.id}`,
    { method: 'PATCH', body: { es_principal: true } },
  );
}

async function guardarImagenUrl(supabaseUrl, serviceKey, sessionToken, productoId, antes, despues) {
  const prev = String(antes || '').trim();
  const next = String(despues || '').trim();
  if (prev === next) return;
  await rpc(serviceKey, supabaseUrl, 'admin_editar_producto', {
    p_session_token: sessionToken,
    p_producto_id: productoId,
    p_patch: { imagen_url: next || null, imagen_mobile_url: next || null },
  });
}

function responder(res, status, body) {
  return res.status(status).json(body);
}

async function productoImagenesHandler(req, res) {
  if (req.method !== 'POST') {
    return responder(res, 405, { ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return responder(res, 500, { ok: false, error: 'supabase_not_configured' });
  }

  const sessionToken = String(req.headers['x-session-token'] || '').trim();
  if (!sessionToken) {
    return responder(res, 401, { ok: false, error: 'missing_session' });
  }
  const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
  if (!isAdmin) {
    return responder(res, 403, { ok: false, error: 'admin_required' });
  }

  let body = {};
  try {
    const raw = await readRawBody(req);
    body = raw?.length ? JSON.parse(raw.toString('utf8')) : {};
  } catch (e) {
    return responder(res, 400, { ok: false, error: 'invalid_json', message: 'No se pudo leer la solicitud.' });
  }

  const productoId = Number(body.producto_id);
  if (!Number.isInteger(productoId) || productoId <= 0) {
    return responder(res, 400, { ok: false, error: 'invalid_producto', message: 'Falta el producto.' });
  }

  try {
    const producto = await leerProducto(supabaseUrl, serviceKey, productoId);
    if (!producto) {
      return responder(res, 404, { ok: false, error: 'not_found', message: 'No encontré ese producto.' });
    }
    const antes = await leerFilas(supabaseUrl, serviceKey, productoId);
    const plan = planCambioFotos({
      filas: antes,
      imagenUrl: producto.imagen_url || '',
      action: body.action,
      url: body.url,
      principal: body.principal,
    });
    if (!plan.ok) {
      return responder(res, 400, { ok: false, error: 'invalid_action', message: plan.message });
    }
    await escribirPlan(supabaseUrl, serviceKey, productoId, antes, plan);
    await guardarImagenUrl(
      supabaseUrl,
      serviceKey,
      sessionToken,
      productoId,
      producto.imagen_url || '',
      plan.imagenUrl,
    );
    const imagenes = await leerFilas(supabaseUrl, serviceKey, productoId);
    return responder(res, 200, {
      ok: true,
      imagen_url: plan.imagenUrl || '',
      imagenes,
    });
  } catch (e) {
    console.error('[producto-imagenes]', e);
    return responder(res, 502, {
      ok: false,
      error: 'server_error',
      message: 'No se pudieron guardar las fotos. Intenta de nuevo.',
    });
  }
}

module.exports = {
  isProductoImagenesRequest,
  productoImagenesHandler,
};
