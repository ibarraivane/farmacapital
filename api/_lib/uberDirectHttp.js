'use strict';

const { applyRestrictiveCors } = require('./allowedOrigins');
const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
  rpc,
} = require('./supabaseAdmin');
const {
  getUberDirectConfig,
  parseDireccionCheckout,
  dropoffAddressFromParts,
  createUberQuote,
  createUberDelivery,
  quoteChangedTooMuch,
  mapUberDeliveryStatus,
} = require('./uberDirect');

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

function dropoffFromBody(body) {
  if (body?.street || body?.calle) {
    return dropoffAddressFromParts({
      street: body.street || body.calle,
      colonia: body.colonia,
      zip: body.zip || body.cp,
      city: body.city || body.ciudad,
      referencia: body.referencia || body.referencias,
    });
  }
  const parsed = parseDireccionCheckout(body?.direccion || body?.address || '');
  return parsed ? dropoffAddressFromParts({ ...parsed, referencia: body?.referencia }) : null;
}

/** Coords del autocomplete (Google/Photon). Solo acepta lat/lng en territorio MX aprox. */
function coordsFromBody(body) {
  const lat = Number(body?.lat ?? body?.latitude ?? body?.dropoff_lat);
  const lng = Number(body?.lng ?? body?.longitude ?? body?.dropoff_lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  if (lat < 14 || lat > 33 || lng < -118 || lng > -86) return null;
  return { lat, lng };
}

function serviceHeaders(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
  };
}

async function fetchPedido(supabaseUrl, serviceKey, pedidoId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,cliente_id,total,estado,tipo,tipo_entrega,direccion,metodo_pago,guest_nombre,guest_telefono,payment_status,logistics_meta,delivery_provider,delivery_status,delivery_tracking_url,created_at,guest_email&limit=1`,
    { headers: serviceHeaders(serviceKey) }
  );
  const rows = await resp.json().catch(() => []);
  if (!resp.ok) {
    if (String(JSON.stringify(rows)).includes('logistics_meta')) {
      const retry = await fetch(
        `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,cliente_id,total,estado,tipo,tipo_entrega,direccion,metodo_pago,guest_nombre,guest_telefono,payment_status,delivery_provider,delivery_status,delivery_tracking_url,created_at&limit=1`,
        { headers: serviceHeaders(serviceKey) }
      );
      const retryRows = await retry.json().catch(() => []);
      return Array.isArray(retryRows) ? retryRows[0] : null;
    }
    return null;
  }
  return Array.isArray(rows) ? rows[0] : null;
}

async function fetchPedidoItems(supabaseUrl, serviceKey, pedidoId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedido_items?pedido_id=eq.${pedidoId}&select=cantidad,precio_unitario,productos(nombre)`,
    { headers: serviceHeaders(serviceKey) }
  );
  const rows = await resp.json().catch(() => []);
  return Array.isArray(rows) ? rows : [];
}

async function fetchCliente(supabaseUrl, serviceKey, clienteId) {
  if (!clienteId) return null;
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=id,nombre,telefono,email&limit=1`,
    { headers: serviceHeaders(serviceKey) }
  );
  const rows = await resp.json().catch(() => []);
  return Array.isArray(rows) ? rows[0] : null;
}

async function patchPedido(supabaseUrl, serviceKey, pedidoId, payload) {
  const attempt = async (body) => {
    const resp = await fetch(`${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}`, {
      method: 'PATCH',
      headers: {
        ...serviceHeaders(serviceKey),
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      },
      body: JSON.stringify(body),
    });
    const data = await resp.json().catch(() => null);
    return { ok: resp.ok, data, status: resp.status };
  };
  let res = await attempt(payload);
  if (!res.ok && payload.logistics_meta) {
    const { logistics_meta, ...rest } = payload;
    res = await attempt(rest);
  }
  if (!res.ok && payload.costo_envio != null) {
    const { costo_envio, ...rest } = payload;
    res = await attempt(rest);
  }
  return res;
}

function mergeLogisticsMeta(pedido, patch) {
  const prev = pedido?.logistics_meta && typeof pedido.logistics_meta === 'object'
    ? pedido.logistics_meta
    : {};
  const prevUber = prev.uber_direct && typeof prev.uber_direct === 'object' ? prev.uber_direct : {};
  return {
    ...prev,
    order_channel: 'web_delivery',
    fulfillment_type: 'uber_direct',
    logistics_provider: 'uber_direct',
    ...patch,
    uber_direct: {
      ...prevUber,
      ...(patch.uber_direct || {}),
    },
  };
}

async function assertClienteOwnsPedido(req, supabaseUrl, serviceKey, pedido, body) {
  const token = bearer(req);
  const isGuest = body?.guest === true;
  const guestPhone = String(body?.guestPhone || body?.guest_telefono || '').replace(/\D/g, '');
  if (!isGuest) {
    if (!token) return { ok: false, status: 401, error: 'missing_cliente_token' };
    let clienteId = null;
    try {
      clienteId = Number(await rpc(serviceKey, supabaseUrl, 'fn_validar_token_cliente', { p_token: token }));
    } catch {
      return { ok: false, status: 401, error: 'invalid_cliente_token' };
    }
    if (!clienteId || Number(pedido.cliente_id) !== clienteId) {
      return { ok: false, status: 403, error: 'pedido_not_owned' };
    }
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

async function handleQuote(body) {
  const cfg = getUberDirectConfig();
  if (!cfg.configured) return { status: 503, json: { ok: false, error: 'not_configured' } };
  const dropoff = dropoffFromBody(body);
  if (!dropoff) {
    return { status: 400, json: { ok: false, error: 'invalid_dropoff', hint: 'calle, colonia y CP de 5 dígitos' } };
  }
  const quote = await createUberQuote({
    dropoffAddress: dropoff,
    dropoffCoords: coordsFromBody(body),
  });
  if (!quote.ok) {
    return {
      status: quote.status && quote.status < 500 ? quote.status : 502,
      json: { ok: false, error: quote.error || 'quote_failed', detail: quote.detail || null },
    };
  }
  return { status: 200, json: quote };
}

async function handleAttach(req, body) {
  const cfg = getUberDirectConfig();
  if (!cfg.configured) return { status: 503, json: { ok: false, error: 'not_configured' } };
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };

  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };

  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (pedido.tipo !== 'online') return { status: 400, json: { ok: false, error: 'pedido_not_online' } };
  if (pedido.tipo_entrega !== 'envio') return { status: 400, json: { ok: false, error: 'not_delivery' } };
  if (pedido.estado !== 'pendiente') return { status: 409, json: { ok: false, error: 'pedido_not_pending' } };

  const own = await assertClienteOwnsPedido(req, supabaseUrl, serviceKey, pedido, body);
  if (!own.ok) return { status: own.status, json: { ok: false, error: own.error } };

  const dropoff = dropoffFromBody({
    ...body,
    direccion: body.direccion || pedido.direccion,
  });
  if (!dropoff) return { status: 400, json: { ok: false, error: 'invalid_dropoff' } };

  const quote = await createUberQuote({ dropoffAddress: dropoff, dropoffCoords: coordsFromBody(body) });
  if (!quote.ok) {
    return { status: 502, json: { ok: false, error: quote.error || 'quote_failed', detail: quote.detail || null } };
  }

  const displayed = body.displayed_fee_mxn != null ? Number(body.displayed_fee_mxn) : null;
  if (displayed != null && quoteChangedTooMuch(displayed, quote.fee_mxn)) {
    return {
      status: 409,
      json: { ok: false, error: 'quote_changed', quote },
    };
  }

  const prevMeta = pedido.logistics_meta && typeof pedido.logistics_meta === 'object' ? pedido.logistics_meta : {};
  const alreadyCharged = Number(prevMeta?.uber_direct?.fee_mxn);
  let itemsTotal = Number(pedido.total || 0);
  if (Number.isFinite(alreadyCharged) && alreadyCharged > 0) {
    itemsTotal = Math.round((itemsTotal - alreadyCharged) * 100) / 100;
  }
  const newTotal = Math.round((itemsTotal + quote.fee_mxn) * 100) / 100;

  const dropoffCoords = coordsFromBody(body);
  const logistics_meta = mergeLogisticsMeta(pedido, {
    external_delivery_id: prevMeta.external_delivery_id || null,
    uber_direct: {
      quote_id: quote.quote_id,
      fee_mxn: quote.fee_mxn,
      fee_cents: quote.fee_cents,
      currency: 'MXN',
      duration_min: quote.duration_min,
      expires_at: quote.expires_at,
      charged_at: new Date().toISOString(),
      dropoff_summary: dropoff.street_address?.[0] || null,
      dropoff_lat: dropoffCoords?.lat ?? null,
      dropoff_lng: dropoffCoords?.lng ?? null,
    },
  });

  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    total: newTotal,
    delivery_provider: 'uber_direct',
    delivery_status: 'quoted',
    costo_envio: quote.fee_mxn,
    logistics_meta,
  });
  if (!patched.ok) {
    return { status: 502, json: { ok: false, error: 'pedido_update_failed', detail: patched.data } };
  }

  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      total: newTotal,
      items_total: itemsTotal,
      quote,
    },
  };
}

async function handleCreate(req, body) {
  const cfg = getUberDirectConfig();
  if (!cfg.configured) return { status: 503, json: { ok: false, error: 'not_configured' } };
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };

  const employeeTok = bearer(req) || String(req.headers['x-session-token'] || '').trim();
  const employeeOk = await validateEmployeeSession(supabaseUrl, serviceKey, employeeTok);
  if (!employeeOk) return { status: 401, json: { ok: false, error: 'invalid_employee_session' } };

  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };

  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (pedido.tipo_entrega !== 'envio') return { status: 400, json: { ok: false, error: 'not_delivery' } };

  const existingId = pedido.logistics_meta?.uber_direct?.delivery_id || pedido.logistics_meta?.external_delivery_id;
  if (existingId && pedido.delivery_tracking_url) {
    return {
      status: 200,
      json: {
        ok: true,
        already: true,
        delivery_id: existingId,
        tracking_url: pedido.delivery_tracking_url,
      },
    };
  }

  const dropoff = dropoffFromBody({ direccion: pedido.direccion, ...body });
  if (!dropoff) return { status: 400, json: { ok: false, error: 'invalid_dropoff' } };

  const cliente = await fetchCliente(supabaseUrl, serviceKey, pedido.cliente_id);
  const items = await fetchPedidoItems(supabaseUrl, serviceKey, pedidoId);
  const dropoffName = pedido.guest_nombre || cliente?.nombre || 'Cliente FarmaCapital';
  const dropoffPhone = pedido.guest_telefono || cliente?.telefono || '';

  const savedCoords = (() => {
    const lat = Number(pedido.logistics_meta?.uber_direct?.dropoff_lat);
    const lng = Number(pedido.logistics_meta?.uber_direct?.dropoff_lng);
    if (Number.isFinite(lat) && Number.isFinite(lng)) return { lat, lng };
    return coordsFromBody(body);
  })();

  const quote = await createUberQuote({ dropoffAddress: dropoff, dropoffCoords: savedCoords });
  if (!quote.ok) {
    return { status: 502, json: { ok: false, error: quote.error || 'quote_failed', detail: quote.detail || null } };
  }

  const created = await createUberDelivery({
    quoteId: quote.quote_id,
    dropoffAddress: dropoff,
    dropoffName,
    dropoffPhone,
    dropoffCoords: savedCoords,
    items,
    externalId: String(pedidoId),
    pickupNotes: `Pedido FarmaCapital ${pedidoId}. Recoger en mostrador.`,
  });
  if (!created.ok) {
    return { status: 502, json: { ok: false, error: created.error || 'create_failed', detail: created.detail || null } };
  }

  const logistics_meta = mergeLogisticsMeta(pedido, {
    external_delivery_id: created.delivery_id,
    tracking_url: created.tracking_url,
    uber_direct: {
      delivery_id: created.delivery_id,
      tracking_url: created.tracking_url,
      status: created.status,
      dispatch_quote_id: quote.quote_id,
      dispatch_fee_mxn: created.fee_mxn,
      dispatched_at: new Date().toISOString(),
    },
  });

  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    delivery_provider: 'uber_direct',
    delivery_status: mapUberDeliveryStatus(created.status) || 'courier_requested',
    delivery_tracking_url: created.tracking_url,
    logistics_meta,
  });
  if (!patched.ok) {
    return {
      status: 502,
      json: {
        ok: false,
        error: 'pedido_update_failed',
        delivery_id: created.delivery_id,
        tracking_url: created.tracking_url,
      },
    };
  }

  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      delivery_id: created.delivery_id,
      tracking_url: created.tracking_url,
      status: created.status,
      quote,
    },
  };
}

module.exports = async function handler(req, res) {
  applyRestrictiveCors(req, res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method === 'GET') {
    const cfg = getUberDirectConfig();
    return res.status(200).json({ ok: true, configured: cfg.configured });
  }
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'method_not_allowed' });

  const body = await safeJson(req);
  const action = String(getQuery(req).action || body?.action || 'quote').toLowerCase();

  try {
    let result;
    if (action === 'quote') result = await handleQuote(body);
    else if (action === 'attach') result = await handleAttach(req, body);
    else if (action === 'create' || action === 'dispatch') result = await handleCreate(req, body);
    else result = { status: 400, json: { ok: false, error: 'unknown_action' } };
    return res.status(result.status).json(result.json);
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'unexpected_error', message: e?.message || 'unknown' });
  }
};
