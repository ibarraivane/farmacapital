'use strict';

const { applyRestrictiveCors } = require('./allowedOrigins');
const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
} = require('./supabaseAdmin');
const {
  getEnvioConfig,
  estimarEnvioDesdeCoords,
  normalizarProveedor,
  proveedorSugerido,
  deadlineCotizacionIso,
  cotizacionVencida,
  puedeDespacharEnvio,
  PROVEEDORES_ENVIO,
  totalPedidoConCostoEnvio,
  cotizacionEnvioMeta,
  textoClienteEnvioEnCheckout,
  correoAvisoEnvioCotizado,
  cargoServicioPedido,
  desglosePedido,
} = require('./envioDomicilio');
const { sendWhatsAppSmart } = require('./whatsappCloud');
const { sendEmail } = require('./orderNotifications');
const { emailsAvisoCliente } = require('./clienteEmails');

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

async function resolvePedidoTelefono(supabaseUrl, serviceKey, pedido) {
  let tel = String(pedido?.guest_telefono || '').replace(/\D/g, '');
  if (tel.length >= 10) return tel.slice(-10);
  const clienteId = Number(pedido?.cliente_id);
  if (!Number.isFinite(clienteId) || clienteId <= 0) return '';
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=telefono&limit=1`,
    { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } }
  );
  const rows = await resp.json().catch(() => []);
  tel = String(Array.isArray(rows) ? rows[0]?.telefono || '' : '').replace(/\D/g, '');
  return tel.slice(-10);
}

async function resolvePedidoContacto(supabaseUrl, serviceKey, pedido) {
  const guestEmail = String(pedido?.guest_email || '').trim();
  let nombre = String(pedido?.guest_nombre || '').trim();
  let email = '';
  let emailAlt = '';
  const clienteId = Number(pedido?.cliente_id);
  if (Number.isFinite(clienteId) && clienteId > 0) {
    const resp = await fetch(
      `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=email,email_alt,nombre&limit=1`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } }
    );
    const rows = await resp.json().catch(() => []);
    const row = Array.isArray(rows) ? rows[0] : null;
    email = String(row?.email || '').trim();
    emailAlt = String(row?.email_alt || '').trim();
    if (!nombre) nombre = String(row?.nombre || '').trim();
  }
  const emails = emailsAvisoCliente({ guestEmail, email, emailAlt });
  return { email: emails[0] || '', emails, nombre };
}

async function fetchItemsPedido(supabaseUrl, serviceKey, pedidoId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedido_items?pedido_id=eq.${pedidoId}&select=cantidad,precio_unitario,productos(nombre,imagen_url)`,
    { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } }
  );
  const rows = await resp.json().catch(() => []);
  if (!resp.ok || !Array.isArray(rows)) return [];
  return rows;
}

async function avisarClienteEnvioCotizado({ supabaseUrl, serviceKey, pedido, costo, itemsTotal, cargo = 0 }) {
  const contacto = await resolvePedidoContacto(supabaseUrl, serviceKey, pedido).catch(() => ({ email: '', emails: [], nombre: '' }));
  const items = await fetchItemsPedido(supabaseUrl, serviceKey, pedido.id).catch(() => []);
  const telPedido = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido).catch(() => '');
  const envioMeta = pedido?.logistics_meta?.envio && typeof pedido.logistics_meta.envio === 'object' ? pedido.logistics_meta.envio : {};
  const mail = correoAvisoEnvioCotizado({
    pedidoId: pedido.id,
    costo,
    itemsTotal,
    cargo,
    total: pedido.total,
    nombre: contacto.nombre,
    items,
    proveedor: envioMeta.proveedor || pedido.delivery_provider,
    colonia: envioMeta.colonia,
    telUltimos4: telPedido,
  });
  let email = { sent: false, reason: 'missing_email' };
  const destinos = Array.isArray(contacto.emails) ? contacto.emails : [];
  if (destinos.length) {
    try {
      email = await sendEmail({
        to: destinos,
        subject: mail.subject,
        text: mail.text,
        html: mail.html,
        from: mail.from,
        replyTo: mail.replyTo,
      });
    } catch (e) {
      email = { sent: false, reason: e?.message || 'email_failed' };
    }
  }
  let whatsapp = { sent: false, reason: 'missing_phone' };
  try {
    const tel = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido);
    if (tel && tel.length >= 10) {
      whatsapp = await sendWhatsAppSmart({
        to: tel,
        text: textoClienteEnvioEnCheckout({
          pedidoId: pedido.id,
          costo,
          itemsTotal,
          cargo,
          total: pedido.total,
        }),
        allowTextFallback: true,
      });
    }
  } catch (e) {
    whatsapp = { sent: false, reason: e?.message || 'whatsapp_failed' };
  }
  return { email, whatsapp };
}

async function fetchPedido(supabaseUrl, serviceKey, pedidoId) {
  const selects = [
    'id,cliente_id,total,estado,tipo,tipo_entrega,direccion,created_at,guest_nombre,guest_telefono,guest_email,logistics_meta,costo_envio,delivery_provider,delivery_status,payment_status',
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
  const prevFee = Number(pedido.costo_envio);
  let itemsTotal = Number(pedido.total || 0);
  if (Number.isFinite(prevFee) && prevFee >= 0) {
    itemsTotal = Math.round((itemsTotal - prevFee) * 100) / 100;
  }

  let distanciaKm = null;
  if (coords) {
    const est = estimarEnvioDesdeCoords({
      lat: coords.lat,
      lng: coords.lng,
      subtotal: itemsTotal,
      config: cfg,
    });
    distanciaKm = est.distancia_km ?? null;
  }

  const colonia = String(body.colonia || '').trim();
  const proveedor = proveedorSugerido(colonia, cfg);
  const deadline = deadlineCotizacionIso(new Date(), cfg.tiempoMaximoCotizacionMin);
  const envioPatch = {
    estado: 'pendiente_cotizacion',
    cobrado_en_checkout: false,
    distancia_km: distanciaKm,
    costo_cotizado: null,
    costo_estimado: null,
    proveedor,
    fulfillment_type: proveedor === 'propio' ? 'own_delivery' : 'courier',
    cotizar_antes_de: deadline,
    dropoff_lat: coords?.lat ?? null,
    dropoff_lng: coords?.lng ?? null,
    calle: String(body.calle || body.street || '').trim() || null,
    colonia: colonia || null,
    cp: String(body.cp || body.zip || '').trim() || null,
    referencia: String(body.referencia || '').trim() || null,
    attached_at: new Date().toISOString(),
  };
  const logistics_meta = mergeEnvioMeta(pedido, envioPatch);
  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    total: itemsTotal,
    logistics_meta,
    delivery_provider: proveedor,
    delivery_status: 'pending_quote',
    costo_envio: null,
  });
  if (!patched.ok) {
    return { status: 502, json: { ok: false, error: 'pedido_update_failed', detail: patched.data } };
  }

  await upsertEnvioRow(supabaseUrl, serviceKey, {
    pedido_id: pedidoId,
    metodo: proveedor,
    estado: 'pendiente_cotizacion',
    distancia_km: distanciaKm,
    proveedor,
    cotizar_antes_de: deadline,
  });

  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      total: itemsTotal,
      items_total: itemsTotal,
      costo_envio: 0,
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
  if (String(pedido.payment_status || '').toLowerCase() === 'approved') {
    return { status: 409, json: { ok: false, error: 'pedido_ya_pagado' } };
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

  const prevFee = Number(pedido.costo_envio);
  const { itemsTotal, total: newTotal } = totalPedidoConCostoEnvio(pedido.total, prevFee, costo);

  const envioPatch = cotizacionEnvioMeta(current, {
    costo,
    proveedor,
    distanciaKm: Number.isFinite(distanciaKm) ? distanciaKm : current.distancia_km,
    nota: body?.nota,
  });
  const logistics_meta = mergeEnvioMeta(pedido, envioPatch);
  const patched = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    total: newTotal,
    logistics_meta,
    delivery_provider: proveedor,
    delivery_status: 'quoted',
    costo_envio: costo,
  });
  if (!patched.ok) {
    return { status: 502, json: { ok: false, error: 'pedido_update_failed', detail: patched.data } };
  }
  await upsertEnvioRow(supabaseUrl, serviceKey, {
    pedido_id: pedidoId,
    metodo: proveedor,
    estado: envioPatch.estado,
    distancia_km: envioPatch.distancia_km,
    costo_cotizado: costo,
    proveedor,
  });

  // pedido.total trae el Servicio $5 del trigger: separarlo para que el cliente vea el desglose real.
  const desglose = desglosePedido(newTotal, costo, cargoServicioPedido(pedido));
  const aviso = await avisarClienteEnvioCotizado({
    supabaseUrl,
    serviceKey,
    pedido: { ...pedido, total: newTotal, costo_envio: costo, delivery_provider: proveedor, logistics_meta },
    costo,
    itemsTotal: desglose.productos,
    cargo: desglose.servicio,
  });
  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      total: newTotal,
      items_total: desglose.productos,
      cargo_plataforma: desglose.servicio,
      costo_envio: costo,
      envio: envioPatch,
      whatsapp: aviso.whatsapp,
      email: aviso.email,
    },
  };
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

async function handleResumenPago(body) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) return { status: 500, json: { ok: false, error: 'missing_supabase' } };
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  if (!pedidoId) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const phone = String(body?.guestPhone || body?.guest_telefono || '').replace(/\D/g, '').slice(-10);
  if (phone.length < 10) return { status: 400, json: { ok: false, error: 'missing_guest_phone' } };

  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (pedido.tipo !== 'online') return { status: 400, json: { ok: false, error: 'pedido_not_online' } };

  const tel = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido);
  if (!tel || tel.slice(-10) !== phone) {
    return { status: 403, json: { ok: false, error: 'guest_phone_mismatch' } };
  }

  const created = new Date(pedido.created_at).getTime();
  const windowMs = String(pedido.tipo_entrega || '').toLowerCase() === 'envio'
    ? 72 * 60 * 60 * 1000
    : 2 * 60 * 60 * 1000;
  if (!Number.isFinite(created) || Date.now() - created > windowMs) {
    return { status: 403, json: { ok: false, error: 'guest_checkout_expired' } };
  }

  const { envio } = readEnvioMeta(pedido);
  const current = expireIfNeeded(envio);
  const estado = String(current.estado || '').toLowerCase();
  const costoRaw = pedido.costo_envio != null && pedido.costo_envio !== ''
    ? Number(pedido.costo_envio)
    : Number(current.costo_cotizado);
  const costo = Number.isFinite(costoRaw) && costoRaw >= 0 ? Math.round(costoRaw * 100) / 100 : null;
  const quoted = ['cotizado', 'link_enviado', 'pagado'].includes(estado)
    || current.cobrado_en_checkout === true
    || (pedido.costo_envio != null && pedido.costo_envio !== '' && costo != null);
  const paid = String(pedido.payment_status || '').toLowerCase() === 'approved';
  const cargoRaw = Number(pedido.logistics_meta?.cargo_plataforma_mxn);
  const cargo = Number.isFinite(cargoRaw) && cargoRaw > 0 ? Math.round(cargoRaw * 100) / 100 : 0;
  const total = Math.round((Number(pedido.total) || 0) * 100) / 100;
  const envioFee = quoted && costo != null ? costo : 0;
  const itemsTotal = Math.max(0, Math.round((total - envioFee - cargo) * 100) / 100);

  let lineas = [];
  try {
    const itemsResp = await fetch(
      `${supabaseUrl}/rest/v1/pedido_items?pedido_id=eq.${pedidoId}&select=cantidad,precio_unitario,productos(nombre)`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } }
    );
    const rows = await itemsResp.json().catch(() => []);
    if (itemsResp.ok && Array.isArray(rows)) {
      lineas = rows.map((row) => ({
        nombre: row?.productos?.nombre || 'Producto',
        cantidad: Number(row.cantidad) || 1,
        importe: Math.round((Number(row.precio_unitario) || 0) * (Number(row.cantidad) || 1) * 100) / 100,
      }));
    }
  } catch {
    lineas = [];
  }

  return {
    status: 200,
    json: {
      ok: true,
      pedidoId,
      folio: `#FC-${String(pedidoId).padStart(4, '0')}`,
      total,
      items_total: itemsTotal,
      costo_envio: quoted ? costo : null,
      cargo_plataforma: cargo,
      estado_envio: estado || null,
      payment_status: pedido.payment_status || null,
      tipo_entrega: pedido.tipo_entrega || null,
      puede_pagar: !paid && pedido.estado === 'pendiente' && quoted && pedido.tipo_entrega === 'envio',
      pagado: paid,
      lineas,
    },
  };
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
  if (action === 'resumen-pago' || action === 'resumen_pago') return handleResumenPago(body);
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
