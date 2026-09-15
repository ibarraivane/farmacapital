'use strict';

const { applyRestrictiveCors } = require('./allowedOrigins');
const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
} = require('./supabaseAdmin');
const {
  getEnvioConfig,
  estimarEnvioDesdeCoords,
  calcularCostoEnvio,
  normalizarProveedor,
  proveedorSugerido,
  deadlineCotizacionIso,
  cotizacionVencida,
  puedeDespacharEnvio,
  PROVEEDORES_ENVIO,
} = require('./envioDomicilio');

function getQuery(req) {
  try {
    const q = req.query;
    if (q && typeof q === 'object' && !Array.isArray(q)) return q;
    const full = req.url || '';
    const qs = full.includes('?') ? full.split('?')[1] : '';
    return Object.fromEntries(new URLSearchParams(qs));
  } catch {
    return {};
  }
}

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object' && !Buffer.isBuffer(req.body)) return req.body;
    return JSON.parse(String(req.body || '{}'));
  } catch {
    return {};
  }
}

function bearer(req) {
  const auth = String(req.headers.authorization || req.headers.Authorization || '');
  return auth.replace(/^Bearer\s+/i, '').trim();
}

function serviceHeaders(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
  };
}

function coordsFromBody(body) {
  const lat = Number(body?.lat ?? body?.latitude ?? body?.dropoff_lat);
  const lng = Number(body?.lng ?? body?.longitude ?? body?.dropoff_lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  if (lat < 14 || lat > 33 || lng < -118 || lng > -86) return null;
  return { lat, lng };
}

function readEnvioMeta(pedido) {
  const meta = pedido?.logistics_meta && typeof pedido.logistics_meta === 'object'
    ? pedido.logistics_meta
    : {};
  const envio = meta.envio && typeof meta.envio === 'object' ? meta.envio : {};
  return { meta, envio };
}

function mergeEnvioMeta(pedido, patch) {
  const { meta, envio } = readEnvioMeta(pedido);
  return {
    ...meta,
    fulfillment_type: patch.fulfillment_type || meta.fulfillment_type || 'courier',
    logistics_provider: patch.proveedor || envio.proveedor || meta.logistics_provider || 'didi',
    order_channel: meta.order_channel || 'web_delivery',
    envio: {
      ...envio,
      ...patch,
    },
  };
}

async function fetchPedido(supabaseUrl, serviceKey, pedidoId) {
  const selects = [
    'id,cliente_id,total,estado,tipo,tipo_entrega,direccion,created_at,guest_telefono,logistics_meta,costo_envio,delivery_provider,delivery_status,payment_status',
    'id,cliente_id,total,estado,tipo,tipo_entrega,direccion,created_at,guest_telefono,logistics_meta,costo_envio,payment_status',
    'id,cliente_id,total,estado,tipo,tipo_entrega,direccion,created_at,guest_telefono,payment_status',
  ];
  for (const select of selects) {
    const resp = await fetch(
      `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${select}&limit=1`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } }
    );
    const rows = await resp.json().catch(() => []);
    if (resp.ok && Array.isArray(rows) && rows[0]) return rows[0];
  }
  return null;
}

async function patchPedido(supabaseUrl, serviceKey, pedidoId, body) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}`, {
    method: 'PATCH',
    headers: { ...serviceHeaders(serviceKey), Prefer: 'return=representation' },
    body: JSON.stringify(body),
  });
  const data = await resp.json().catch(() => null);
  return { ok: resp.ok, data };
}

async function upsertEnvioRow(supabaseUrl, serviceKey, row) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/envios`, {
    method: 'POST',
    headers: {
      ...serviceHeaders(serviceKey),
      Prefer: 'resolution=merge-duplicates,return=representation',
    },
    body: JSON.stringify(row),
  });
  if (resp.ok) return { ok: true, data: await resp.json().catch(() => null) };
  const patch = await fetch(
    `${supabaseUrl}/rest/v1/envios?pedido_id=eq.${row.pedido_id}`,
    {
      method: 'PATCH',
      headers: { ...serviceHeaders(serviceKey), Prefer: 'return=representation' },
      body: JSON.stringify(row),
    }
  );
  if (patch.ok) return { ok: true, data: await patch.json().catch(() => null) };
  return { ok: false, data: await resp.json().catch(() => null) };
}

async function assertClienteOwnsPedido(req, supabaseUrl, serviceKey, pedido, body) {
  const token = bearer(req);
  const guest = body?.guest === true;
  const guestPhone = String(body?.guestPhone || body?.guest_telefono || '').replace(/\D/g, '');
  if (!guest && token) {
    const valid = await fetch(`${supabaseUrl}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: serviceHeaders(serviceKey),
      body: JSON.stringify({ p_token: token }),
    });
    const clienteId = Number(await valid.json().catch(() => 0));
    if (!valid.ok || !clienteId) return { ok: false, status: 401, error: 'invalid_cliente_token' };
    if (Number(pedido.cliente_id) !== clienteId) return { ok: false, status: 403, error: 'pedido_not_owned' };
    return { ok: true, clienteId };
  }
  const created = new Date(pedido.created_at).getTime();
  if (!Number.isFinite(created) || Date.now() - created > 2 * 60 * 60 * 1000) {
    return { ok: false, status: 403, error: 'guest_checkout_expired' };
  }
  const telPedido = String(pedido.guest_telefono || '').replace(/\D/g, '');
  if (guestPhone.length < 10 || telPedido.slice(-10) !== guestPhone.slice(-10)) {
    return { ok: false, status: 403, error: 'guest_phone_mismatch' };
  }
  return { ok: true, clienteId: Number(pedido.cliente_id) };
}

function handleEstimate(body) {
  const cfg = getEnvioConfig();
  const coords = coordsFromBody(body);
  if (!coords) {
    return {
      status: 200,
      json: {
        ok: true,
        pending_coords: true,
        radio_maximo_km: cfg.radioMaximoKm,
        hint: 'Completa la dirección en el mapa para estimar cobertura.',
      },
    };
  }
  const est = estimarEnvioDesdeCoords({
    lat: coords.lat,
    lng: coords.lng,
    subtotal: Number(body?.subtotal || 0),
    config: cfg,
  });
  if (!est.ok) {
    return {
      status: 200,
      json: {
        ok: false,
        error: est.error,
        distancia_km: est.distancia_km ?? null,
        radio_maximo_km: cfg.radioMaximoKm,
        hint: est.error === 'fuera_radio'
          ? `Por ahora solo entregamos hasta ${cfg.radioMaximoKm} km de la farmacia. Puedes recoger en tienda.`
          : 'No se pudo estimar la distancia.',
      },
    };
  }
  return {
    status: 200,
    json: {
      ok: true,
      ...est,
      hint: est.gratis
        ? 'Envío gratis por el monto del pedido. Va en el total del checkout.'
        : `Envío ${est.costo.toFixed(2)} MXN. Se suma al total y se paga en el checkout.`,
    },
  };
}

async function handleAttach(req, body) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };
  const cfg = getEnvioConfig();
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (pedido.tipo !== 'online') return { status: 400, json: { ok: false, error: 'pedido_not_online' } };
  if (pedido.tipo_entrega !== 'envio') return { status: 400, json: { ok: false, error: 'not_delivery' } };

  const own = await assertClienteOwnsPedido(req, supabaseUrl, serviceKey, pedido, body);
  if (!own.ok) return { status: own.status, json: { ok: false, error: own.error } };

  const coords = coordsFromBody(body);
  if (!coords) {
    return { status: 400, json: { ok: false, error: 'coords_required' } };
  }

  const prevFee = Number(pedido.costo_envio);
  let itemsTotal = Number(pedido.total || 0);
  if (Number.isFinite(prevFee) && prevFee >= 0) {
    itemsTotal = Math.round((itemsTotal - prevFee) * 100) / 100;
  }

  const est = estimarEnvioDesdeCoords({
    lat: coords.lat,
    lng: coords.lng,
    subtotal: itemsTotal,
    config: cfg,
  });
  if (est.error === 'fuera_radio') {
    const logistics_meta = mergeEnvioMeta(pedido, {
      estado: 'fuera_radio',
      distancia_km: est.distancia_km,
      radio_maximo_km: cfg.radioMaximoKm,
      dropoff_lat: coords.lat,
      dropoff_lng: coords.lng,
      calle: body.calle || body.street || null,
      colonia: body.colonia || null,
      cp: body.cp || body.zip || null,
      referencia: body.referencia || null,
      proveedor: proveedorSugerido(body.colonia, cfg),
    });
    await patchPedido(supabaseUrl, serviceKey, pedidoId, {
      logistics_meta,
      delivery_provider: logistics_meta.logistics_provider,
      delivery_status: 'cancelled',
    });
    return {
      status: 422,
      json: {
        ok: false,
        error: 'fuera_radio',
        distancia_km: est.distancia_km,
        radio_maximo_km: cfg.radioMaximoKm,
      },
    };
  }
  if (!est.ok) {
    return { status: 400, json: { ok: false, error: est.error || 'estimate_failed' } };
  }

  const displayed = body.displayed_fee_mxn != null ? Number(body.displayed_fee_mxn) : null;
  if (displayed != null && Number.isFinite(displayed) && Math.abs(displayed - est.costo) > 0.5) {
    return {
      status: 409,
      json: { ok: false, error: 'quote_changed', costo: est.costo, distancia_km: est.distancia_km },
    };
  }

  const colonia = String(body.colonia || '').trim();
  const proveedor = proveedorSugerido(colonia, cfg);
  const deadline = deadlineCotizacionIso(new Date(), cfg.tiempoMaximoCotizacionMin);
  const newTotal = Math.round((itemsTotal + est.costo) * 100) / 100;
  const envioPatch = {
    estado: 'cotizado',
    cobrado_en_checkout: true,
    distancia_km: est.distancia_km,
    costo_tabla: est.costo_tabla,
    costo_cotizado: est.costo,
    costo_estimado: est.costo,
    gratis: Boolean(est.gratis),
    proveedor,
    fulfillment_type: proveedor === 'propio' ? 'own_delivery' : 'courier',
    cotizar_antes_de: deadline,
    radio_maximo_km: cfg.radioMaximoKm,
    dropoff_lat: coords.lat,
    dropoff_lng: coords.lng,
    calle: String(body.calle || body.street || '').trim() || null,
    colonia: colonia || null,
    cp: String(body.cp || body.zip || '').trim() || null,
    referencia: String(body.referencia || '').trim() || null,
    attached_at: new Date().toISOString(),
  };
  const logistics_meta = mergeEnvioMeta(pedido, envioPatch);
  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    total: newTotal,
    logistics_meta,
    delivery_provider: proveedor,
    delivery_status: 'quoted',
    costo_envio: est.costo,
  });
  if (!patched.ok) {
    return { status: 502, json: { ok: false, error: 'pedido_update_failed', detail: patched.data } };
  }

  await upsertEnvioRow(supabaseUrl, serviceKey, {
    pedido_id: pedidoId,
    metodo: proveedor,
    estado: 'cotizado',
    distancia_km: est.distancia_km,
    costo_tabla: est.costo_tabla,
    costo_cotizado: est.costo,
    proveedor,
    cotizar_antes_de: deadline,
  });

  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      total: newTotal,
      items_total: itemsTotal,
      costo_envio: est.costo,
      envio: envioPatch,
    },
  };
}

async function requireEmployee(req, supabaseUrl, serviceKey) {
  const tok = bearer(req) || String(req.headers['x-session-token'] || '').trim();
  const ok = await validateEmployeeSession(supabaseUrl, serviceKey, tok);
  if (!ok) return { ok: false, status: 401, error: 'invalid_employee_session' };
  return { ok: true };
}

function expireIfNeeded(envio) {
  if (!envio) return envio;
  if (['pagado', 'en_ruta', 'entregado', 'fuera_radio'].includes(envio.estado)) return envio;
  if (cotizacionVencida(envio.cotizar_antes_de) && envio.estado === 'pendiente_cotizacion') {
    return { ...envio, estado: 'vencido' };
  }
  return envio;
}

async function handleQuote(req, body) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };
  const emp = await requireEmployee(req, supabaseUrl, serviceKey);
  if (!emp.ok) return { status: emp.status, json: { ok: false, error: emp.error } };

  const cfg = getEnvioConfig();
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (pedido.tipo_entrega !== 'envio') return { status: 400, json: { ok: false, error: 'not_delivery' } };

  const { envio } = readEnvioMeta(pedido);
  const current = expireIfNeeded(envio);
  if (current.estado === 'fuera_radio') {
    return { status: 409, json: { ok: false, error: 'fuera_radio' } };
  }

  const costo = Number(body?.costo ?? body?.costo_cotizado);
  if (!Number.isFinite(costo) || costo < 0) {
    return { status: 400, json: { ok: false, error: 'invalid_costo' } };
  }
  const proveedor = normalizarProveedor(body?.proveedor, cfg.proveedorDefault);
  if (!PROVEEDORES_ENVIO.includes(proveedor)) {
    return { status: 400, json: { ok: false, error: 'invalid_proveedor' } };
  }

  let distanciaKm = Number(body?.distancia_km ?? current.distancia_km);
  if (!Number.isFinite(distanciaKm) && current.dropoff_lat != null) {
    const est = estimarEnvioDesdeCoords({
      lat: current.dropoff_lat,
      lng: current.dropoff_lng,
      subtotal: Number(pedido.total || 0),
      config: cfg,
    });
    distanciaKm = est.distancia_km;
  }
  if (Number.isFinite(distanciaKm) && distanciaKm > cfg.radioMaximoKm) {
    return { status: 422, json: { ok: false, error: 'fuera_radio', distancia_km: distanciaKm } };
  }

  const tabla = Number.isFinite(distanciaKm)
    ? calcularCostoEnvio({
      distanciaKm,
      subtotal: Number(pedido.total || 0),
      tarifas: cfg.tarifas,
      radioMaximoKm: cfg.radioMaximoKm,
    })
    : null;

  const cobradoCheckout = Boolean(current.cobrado_en_checkout);
  const envioPatch = {
    ...current,
    estado: cobradoCheckout ? current.estado : (costo === 0 ? 'pagado' : 'cotizado'),
    costo_real_mensajeria: costo,
    costo_cotizado: cobradoCheckout ? current.costo_cotizado : costo,
    costo_tabla: tabla?.ok ? tabla.costo_tabla : current.costo_tabla ?? null,
    distancia_km: Number.isFinite(distanciaKm) ? distanciaKm : current.distancia_km ?? null,
    proveedor,
    fulfillment_type: proveedor === 'propio' ? 'own_delivery' : 'courier',
    cotizado_at: new Date().toISOString(),
    nota_interna: String(body?.nota || '').trim() || current.nota_interna || null,
  };
  const logistics_meta = mergeEnvioMeta(pedido, envioPatch);
  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    logistics_meta,
    delivery_provider: proveedor,
    delivery_status: current.delivery_status || 'quoted',
    ...(cobradoCheckout ? {} : { costo_envio: costo }),
  });
  if (!patched.ok) {
    return { status: 502, json: { ok: false, error: 'pedido_update_failed', detail: patched.data } };
  }
  await upsertEnvioRow(supabaseUrl, serviceKey, {
    pedido_id: pedidoId,
    metodo: proveedor,
    estado: envioPatch.estado,
    distancia_km: envioPatch.distancia_km,
    costo_cotizado: cobradoCheckout ? current.costo_cotizado : costo,
    costo_tabla: envioPatch.costo_tabla,
    proveedor,
  });
  return { status: 200, json: { ok: true, pedidoId, envio: envioPatch } };
}

async function handlePaymentLink() {
  return {
    status: 410,
    json: {
      ok: false,
      error: 'checkout_one_pay',
      hint: 'El envío se cobra en el checkout junto con los productos. No se manda un segundo link.',
    },
  };
}

async function handleDispatch(req, body) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };
  const emp = await requireEmployee(req, supabaseUrl, serviceKey);
  if (!emp.ok) return { status: emp.status, json: { ok: false, error: emp.error } };
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  const { envio } = readEnvioMeta(pedido);
  const current = expireIfNeeded(envio);
  const pedidoPaid = String(pedido.payment_status || '').toLowerCase() === 'approved';
  if (current.estado === 'fuera_radio') {
    return { status: 409, json: { ok: false, error: 'fuera_radio' } };
  }
  if (!puedeDespacharEnvio(current, { paymentApproved: pedidoPaid })) {
    return { status: 409, json: { ok: false, error: 'envio_no_pagado' } };
  }
  const tracking = String(body?.tracking_url || current.tracking_url || '').trim() || null;
  const envioPatch = {
    ...current,
    estado: 'en_ruta',
    tracking_url: tracking,
    despachado_at: new Date().toISOString(),
  };
  await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    logistics_meta: mergeEnvioMeta(pedido, envioPatch),
    delivery_status: 'in_route',
    delivery_tracking_url: tracking,
  });
  if (current.estado !== 'pagado' && current.estado !== 'en_ruta') {
    await upsertEnvioRow(supabaseUrl, serviceKey, {
      pedido_id: pedidoId,
      estado: 'pagado',
    });
  }
  await upsertEnvioRow(supabaseUrl, serviceKey, {
    pedido_id: pedidoId,
    estado: 'en_ruta',
    tracking,
  });
  return { status: 200, json: { ok: true, envio: envioPatch } };
}

async function handleGet(body) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  const { envio } = readEnvioMeta(pedido);
  const current = expireIfNeeded(envio);
  if (current.estado === 'vencido' && envio.estado !== 'vencido') {
    await patchPedido(supabaseUrl, serviceKey, pedidoId, {
      logistics_meta: mergeEnvioMeta(pedido, current),
    });
  }
  return {
    status: 200,
    json: {
      ok: true,
      envio: current,
      config: {
        radio_maximo_km: getEnvioConfig().radioMaximoKm,
        tiempo_maximo_cotizacion_min: getEnvioConfig().tiempoMaximoCotizacionMin,
        proveedor_default: getEnvioConfig().proveedorDefault,
      },
    },
  };
}

async function dispatch(req) {
  const body = await safeJson(req);
  const action = String(body?.action || getQuery(req).action || 'estimate').toLowerCase();
  if (req.method === 'GET' || action === 'get') return handleGet({ ...body, ...getQuery(req) });
  if (action === 'estimate') return handleEstimate(body);
  if (action === 'attach') return handleAttach(req, body);
  if (action === 'quote') return handleQuote(req, body);
  if (action === 'create-payment-link' || action === 'payment_link') return handlePaymentLink(req, body);
  if (action === 'dispatch' || action === 'en_ruta') return handleDispatch(req, body);
  return { status: 400, json: { ok: false, error: 'unknown_action' } };
}

module.exports = async function handleEnvioDomicilioHttp(req, res) {
  applyRestrictiveCors(req, res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (!['POST', 'GET'].includes(req.method)) {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }
  try {
    const out = await dispatch(req);
    return res.status(out.status).json(out.json);
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'unexpected_error', message: e?.message || 'unknown' });
  }
};
