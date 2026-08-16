'use strict';

const {
  sendWhatsapp,
  sendPosTicketNotification,
  buildReceiptMessage,
  buildCitaConfirmacionMessage,
  buildOrderTemplateBodyParams,
  buildCitaTemplateBodyParams,
  resolveOrderEventTemplate,
  resolveCitaTemplate,
  pedidoQuiereWhatsAppRecibo,
} = require('../_lib/orderNotifications');
const { getSupabaseAdminConfig, validateEmployeeSession } = require('../_lib/supabaseAdmin');
const { handleWhatsAppManualSend } = require('../_lib/whatsappSendHandler');
const {
  ensurePedidoReciboToken,
  buildReciboPublicUrl,
} = require('../_lib/receiptTicket');

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function resolveNotificationType(req, body) {
  const q = String(req.query?.type || '').trim().toLowerCase();
  if (q === 'cita' || q === 'cita-confirmacion') return 'cita';
  if (q === 'order' || q === 'order-receipt') return 'order';
  if (q === 'pos-ticket' || q === 'pos_ticket') return 'pos-ticket';
  if (q === 'whatsapp' || q === 'whatsapp-send') return 'whatsapp';
  const b = String(body?.type || body?.notificationType || '').trim().toLowerCase();
  if (b === 'cita' || b === 'cita-confirmacion') return 'cita';
  if (b === 'order' || b === 'order-receipt') return 'order';
  if (b === 'pos-ticket' || b === 'pos_ticket') return 'pos-ticket';
  if (b === 'whatsapp' || b === 'whatsapp-send') return 'whatsapp';
  if (body?.citaId != null && body?.pedidoId == null) return 'cita';
  if (body?.pedidoId != null && body?.citaId == null) return 'order';
  return '';
}

async function fetchCita(supabaseUrl, serviceKey, citaId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/citas?id=eq.${citaId}&select=id,nombre,telefono,fecha,hora,motivo,cliente_id,estado&limit=1`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    }
  );
  const rows = await resp.json().catch(() => []);
  return Array.isArray(rows) ? rows[0] : null;
}

async function validateClienteToken(supabaseUrl, serviceKey, token) {
  if (!token) return null;
  try {
    const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ p_token: token }),
    });
    const data = await resp.json().catch(() => null);
    const id = typeof data === 'number' ? data : parseInt(String(data || ''), 10);
    return Number.isFinite(id) && id > 0 ? id : null;
  } catch {
    return null;
  }
}

async function handleCitaConfirmacion(req, res, body) {
  const citaId = Number(body?.citaId);
  const sessionToken = String(body?.sessionToken || '').trim() || null;

  if (!citaId || !Number.isFinite(citaId)) {
    return res.status(400).json({ ok: false, error: 'invalid_cita_id' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  let cita = null;

  if (supabaseUrl && serviceKey) {
    try {
      cita = await fetchCita(supabaseUrl, serviceKey, citaId);
      if (cita && sessionToken) {
        const clienteId = await validateClienteToken(supabaseUrl, serviceKey, sessionToken);
        if (!clienteId) {
          return res.status(403).json({ ok: false, error: 'invalid_session' });
        }
        if (cita.cliente_id != null && Number(cita.cliente_id) !== Number(clienteId)) {
          return res.status(403).json({ ok: false, error: 'cita_not_owned' });
        }
      }
    } catch (e) {
      console.warn('[notifications/send:cita] fetch cita:', e?.message);
    }
  }

  const telefono = String(cita?.telefono || body?.telefono || '').trim();
  if (!telefono) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'missing_phone' } });
  }

  const message =
    String(body?.message || '').trim() ||
    buildCitaConfirmacionMessage({
      nombre: cita?.nombre || body?.nombre,
      fecha: cita?.fecha || body?.fecha,
      hora: cita?.hora || body?.hora,
      motivo: cita?.motivo ?? body?.motivo,
      citaId: cita?.id || citaId,
    });

  const templateName = resolveCitaTemplate();
  const bodyParameters = templateName
    ? buildCitaTemplateBodyParams({
        nombre: cita?.nombre || body?.nombre,
        fecha: cita?.fecha || body?.fecha,
        hora: cita?.hora || body?.hora,
      })
    : undefined;

  const waRes = await sendWhatsapp({
    to: telefono,
    text: message,
    templateName: templateName || undefined,
    bodyParameters,
  });
  return res.status(200).json({ ok: true, whatsapp: waRes, citaId });
}

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

async function supabaseGetPedidoRow(supabaseUrl, serviceKey, pedidoId, select) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${encodeURIComponent(select)}&limit=1`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    }
  );
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const msg = data?.message || data?.hint || `HTTP ${resp.status}`;
    const err = new Error(msg);
    err.status = resp.status;
    err.code = data?.code;
    throw err;
  }
  return Array.isArray(data) ? data[0] : null;
}

/** PostgREST falla si faltan columnas opcionales (whatsapp_recibo, logistics_meta). Reintenta select mínimo. */
async function fetchPedido(supabaseUrl, serviceKey, pedidoId) {
  const base =
    'id,total,tipo,tipo_entrega,metodo_pago,cliente_id,guest_telefono,created_at';
  const withItems = `${base},pedido_items(cantidad,precio_unitario,productos(nombre))`;
  const withOptional = `${withItems},whatsapp_recibo,logistics_meta`;

  for (const select of [withOptional, withItems, base]) {
    try {
      const row = await supabaseGetPedidoRow(supabaseUrl, serviceKey, pedidoId, select);
      if (row) return row;
    } catch (e) {
      console.warn('[fetchPedido] select failed:', select.slice(0, 48), e?.message);
    }
  }

  return null;
}

async function fetchClienteTelefono(supabaseUrl, serviceKey, clienteId) {
  if (!clienteId) return null;
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=telefono&limit=1`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    }
  );
  const rows = await resp.json().catch(() => []);
  const cli = Array.isArray(rows) ? rows[0] : null;
  return cli?.telefono ? String(cli.telefono) : null;
}

function phoneTailMatches(storedPhone, verifyDigits) {
  const stored = digitsOnly(storedPhone);
  const verify = digitsOnly(verifyDigits);
  if (!stored || verify.length < 4) return false;
  return stored.endsWith(verify.slice(-4));
}

function pedidoReciente(createdAt, maxMinutes = 15) {
  if (!createdAt) return false;
  const ts = new Date(createdAt).getTime();
  if (!Number.isFinite(ts)) return false;
  return Date.now() - ts <= maxMinutes * 60 * 1000;
}

async function resolvePedidoTelefono(supabaseUrl, serviceKey, pedido) {
  if (pedido?.guest_telefono) return String(pedido.guest_telefono);
  if (pedido?.cliente_id) {
    const tel = await fetchClienteTelefono(supabaseUrl, serviceKey, pedido.cliente_id);
    if (tel) return tel;
  }
  return null;
}

async function handleOrderReceipt(req, res, body) {
  const pedidoId = Number(body?.pedidoId);
  const sessionToken = String(body?.sessionToken || '').trim() || null;
  const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim() || null;
  const phoneVerify = String(body?.phoneVerify || '').trim() || null;
  const telefonoOverride = String(body?.telefono || body?.phone || '').trim() || null;
  const forceWhatsApp = body?.forceWhatsApp === true;
  const event = String(body?.event || 'order_created').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  let pedido = null;
  try {
    pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  } catch (e) {
    console.warn('[notifications/send:order] fetch pedido:', e?.message);
  }

  if (!pedido) {
    return res.status(404).json({ ok: false, error: 'pedido_not_found' });
  }

  let authorized = false;

  if (employeeToken && (await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken))) {
    authorized = true;
  } else if (sessionToken) {
    const clienteId = await validateClienteToken(supabaseUrl, serviceKey, sessionToken);
    if (clienteId != null) {
      if (pedido.cliente_id == null || Number(pedido.cliente_id) === Number(clienteId)) {
        authorized = true;
      }
    }
  } else if (phoneVerify && pedidoReciente(pedido.created_at)) {
    const telPedido = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido);
    if (phoneTailMatches(telPedido, phoneVerify)) {
      authorized = true;
    }
  }

  if (!authorized) {
    return res.status(403).json({ ok: false, error: 'unauthorized' });
  }

  const telefono = telefonoOverride || (await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido));
  if (!telefono) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'missing_phone' } });
  }

  const staffForce = forceWhatsApp && authorized && !!employeeToken;
  if (!staffForce && !pedidoQuiereWhatsAppRecibo(pedido)) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'whatsapp_opt_out' }, pedidoId });
  }

  const message = buildReceiptMessage({
    event,
    pedido,
    items: pedido.pedido_items || [],
  });

  let reciboToken = null;
  let ticketUrl = null;
  try {
    reciboToken = await ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId);
    ticketUrl = reciboToken ? buildReciboPublicUrl(reciboToken) : null;
  } catch (e) {
    console.warn('[notifications/send:order] recibo token:', e?.message);
  }

  const templateName = resolveOrderEventTemplate(event);
  const bodyParameters = templateName
    ? buildOrderTemplateBodyParams({ event, pedido, ticketUrl })
    : undefined;

  const waRes = await sendWhatsapp({
    to: telefono,
    text: message,
    templateName: templateName || undefined,
    bodyParameters,
    buttonUrlSuffix: reciboToken || undefined,
    allowTextFallback: false,
  });
  return res.status(200).json({ ok: true, whatsapp: waRes, pedidoId, ticketUrl });
}

async function handlePosTicket(req, res, body) {
  const pedidoId = Number(body?.pedidoId);
  const telefono = String(body?.telefono || body?.phone || '').trim();
  const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }
  if (!telefono) {
    return res.status(400).json({ ok: false, error: 'missing_phone' });
  }
  if (!employeeToken) {
    return res.status(403).json({ ok: false, error: 'missing_employee_session' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  const validEmployee = await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken);
  if (!validEmployee) {
    return res.status(403).json({ ok: false, error: 'invalid_employee_session' });
  }

  let pedido = null;
  try {
    pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  } catch (e) {
    console.warn('[notifications/send:pos-ticket] fetch pedido:', e?.message);
  }

  const itemsFromBody = Array.isArray(body?.productos) ? body.productos : [];
  const totalFromBody = Number(body?.total ?? body?.pedidoTotal);
  const metodoFromBody = body?.metodoPago || body?.metodo_pago || null;

  if (!pedido) {
    if (itemsFromBody.length && Number.isFinite(totalFromBody)) {
      pedido = {
        id: pedidoId,
        total: totalFromBody,
        metodo_pago: metodoFromBody,
        tipo: 'pos',
      };
    } else {
      return res.status(404).json({
        ok: false,
        error: 'pedido_not_found',
        detail: 'Verifica SUPABASE_SERVICE_ROLE_KEY y que SUPABASE_URL apunte al mismo proyecto que el panel.',
      });
    }
  }

  const items = itemsFromBody.length ? itemsFromBody : (pedido.pedido_items || []);

  let reciboToken = null;
  let ticketUrl = null;
  try {
    reciboToken = await ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId);
    ticketUrl = reciboToken ? buildReciboPublicUrl(reciboToken) : null;
  } catch (e) {
    console.warn('[notifications/send:pos-ticket] recibo token:', e?.message);
  }

  const waRes = await sendPosTicketNotification({
    telefono,
    pedido,
    items,
    metodoPago: metodoFromBody || pedido.metodo_pago,
    puntosGanados: body?.puntosGanados ?? body?.puntos_ganados ?? null,
    saldoPuntos: body?.saldoPuntos ?? body?.saldo_puntos ?? null,
    ticketUrl,
    ticketUrlSuffix: reciboToken,
  });

  if (!waRes?.sent) {
    return res.status(502).json({
      ok: false,
      error: waRes?.reason || 'whatsapp_send_failed',
      detail: waRes?.detail || waRes?.templateDetail || null,
      template: waRes?.template || null,
      pedidoId,
    });
  }

  if (waRes.via === 'text_fallback' || waRes.via === 'text') {
    return res.status(502).json({
      ok: false,
      error: 'whatsapp_text_outside_window',
      detail: waRes?.templateDetail || waRes?.detail || null,
      pedidoId,
    });
  }

  console.log('[notifications/send:pos-ticket] ok', JSON.stringify({
    pedidoId,
    messageId: waRes.messageId || null,
    via: waRes.via || null,
    template: waRes.template || null,
    to: waRes.to || null,
    waId: waRes.waId || null,
  }));

  return res.status(200).json({
    ok: true,
    whatsapp: waRes,
    pedidoId,
    ticketUrl,
    devHint:
      'Modo Development: el mensaje llega al WhatsApp del cliente desde el número de prueba Meta (+1 555…), no desde +52 FarmaCapital. Revisa ese chat en el celular del destinatario.',
  });
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const body = await safeJson(req);
  const type = resolveNotificationType(req, body);

  if (type === 'cita') {
    return handleCitaConfirmacion(req, res, body);
  }
  if (type === 'order') {
    return handleOrderReceipt(req, res, body);
  }
  if (type === 'pos-ticket') {
    return handlePosTicket(req, res, body);
  }
  if (type === 'whatsapp') {
    return handleWhatsAppManualSend(req, res, body);
  }

  return res.status(400).json({ ok: false, error: 'invalid_notification_type' });
};
