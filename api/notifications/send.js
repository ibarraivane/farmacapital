'use strict';

const {
  sendWhatsapp,
  sendPosTicketNotification,
  sendOrderNotifications,
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
const { handleSolicitudTienda } = require('../_lib/solicitudTiendaHandler');
const {
  ensurePedidoReciboToken,
  buildReciboPublicUrl,
} = require('../_lib/receiptTicket');
const { lineasTicketCorreo } = require('../_lib/envioDomicilio');
const { ticketPagoAdjunto } = require('../_lib/ticketEnvioPdf');
const { emailsAvisoCliente } = require('../_lib/clienteEmails');
const { enviarPedidoResena } = require('../_lib/pedirResena');

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
  if (q === 'recibo-ensure' || q === 'recibo_ensure') return 'recibo-ensure';
  if (q === 'order-email' || q === 'order_email' || q === 'ticket-email' || q === 'ticket_email') return 'order-email';
  if (q === 'whatsapp' || q === 'whatsapp-send') return 'whatsapp';
  if (q === 'solicitud' || q === 'solicitudes' || q === 'conseguir') return 'solicitud';
  if (q === 'pedir-resena' || q === 'pedir_resena') return 'pedir-resena';
  const b = String(body?.type || body?.notificationType || '').trim().toLowerCase();
  if (b === 'cita' || b === 'cita-confirmacion') return 'cita';
  if (b === 'order' || b === 'order-receipt') return 'order';
  if (b === 'pos-ticket' || b === 'pos_ticket') return 'pos-ticket';
  if (b === 'recibo-ensure' || b === 'recibo_ensure') return 'recibo-ensure';
  if (b === 'order-email' || b === 'order_email' || b === 'ticket-email' || b === 'ticket_email') return 'order-email';
  if (b === 'whatsapp' || b === 'whatsapp-send') return 'whatsapp';
  if (b === 'solicitud' || b === 'solicitudes' || b === 'conseguir') return 'solicitud';
  if (b === 'pedir-resena' || b === 'pedir_resena') return 'pedir-resena';
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
    } catch (e) {
      console.warn('[notifications/send:cita] fetch cita:', e?.message);
    }
  }

  const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim();
  let authorized = false;
  if (employeeToken && supabaseUrl && serviceKey) {
    authorized = await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken);
  } else if (sessionToken && cita && supabaseUrl && serviceKey) {
    const clienteId = await validateClienteToken(supabaseUrl, serviceKey, sessionToken);
    if (clienteId && (cita.cliente_id == null || Number(cita.cliente_id) === Number(clienteId))) {
      authorized = true;
    }
  }

  if (!authorized) {
    return res.status(403).json({ ok: false, error: 'unauthorized' });
  }

  const telefono = String(cita?.telefono || '').trim();
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
    'id,total,tipo,tipo_entrega,metodo_pago,cliente_id,guest_telefono,guest_email,guest_nombre,created_at,payment_status,costo_envio';
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

async function fetchClienteCorreo(supabaseUrl, serviceKey, clienteId) {
  if (!clienteId) return null;
  const selects = [
    'id,nombre,telefono,email,email_alt',
    'id,nombre,telefono,email',
  ];
  for (const select of selects) {
    const resp = await fetch(
      `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=${select}&limit=1`,
      {
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
        },
      }
    );
    const rows = await resp.json().catch(() => []);
    if (resp.ok && Array.isArray(rows) && rows[0]) return rows[0];
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

function phoneMatchesStored(storedPhone, verifyDigits) {
  const stored = digitsOnly(storedPhone);
  const verify = digitsOnly(verifyDigits);
  if (stored.length < 10 || verify.length < 10) return false;
  return stored.slice(-10) === verify.slice(-10);
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
    if (phoneMatchesStored(telPedido, phoneVerify)) {
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

async function handleReciboEnsure(req, res, body) {
  const pedidoId = Number(body?.pedidoId);
  const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
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

  const token = await ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId);
  if (!token) {
    return res.status(404).json({ ok: false, error: 'pedido_not_found' });
  }

  return res.status(200).json({
    ok: true,
    pedidoId,
    token,
    ticketUrl: buildReciboPublicUrl(token),
  });
}

/** Empleado: reenvía el ticket/recibo por correo (gracias + PDF). */
async function handleOrderTicketEmail(req, res, body) {
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  const employeeToken = String(
    body?.employeeSessionToken || body?.sessionTokenEmpleado || body?.sessionToken || ''
  ).trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
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

  const pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) {
    return res.status(404).json({ ok: false, error: 'pedido_not_found' });
  }

  const cliente = pedido.cliente_id
    ? await fetchClienteCorreo(supabaseUrl, serviceKey, pedido.cliente_id)
    : null;
  const emails = emailsAvisoCliente({
    guestEmail: pedido.guest_email,
    email: cliente?.email,
    emailAlt: cliente?.email_alt,
  });
  if (!emails.length) {
    return res.status(200).json({
      ok: false,
      error: 'missing_email',
      detail: 'El cliente no tiene correo en la ficha ni en el pedido.',
    });
  }

  const items = Array.isArray(pedido.pedido_items) ? pedido.pedido_items : [];
  let ticket = null;
  let ticketUrl = null;
  try {
    const token = await ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId);
    ticketUrl = token ? buildReciboPublicUrl(token) : null;
    const lineas = lineasTicketCorreo(items);
    const productos = lineas.reduce((sum, l) => sum + Number(l.importe || 0), 0);
    ticket = ticketPagoAdjunto({
      pedidoId,
      nombre: cliente?.nombre || pedido.guest_nombre,
      items: lineas,
      productos,
      envio: pedido.costo_envio,
      total: pedido.total,
      ticketUrl,
    });
  } catch (e) {
    console.warn('[notifications/send:order-email] ticket:', e?.message);
    ticket = null;
  }

  const result = await sendOrderNotifications({
    event: 'payment_approved',
    pedido,
    cliente: {
      ...(cliente || {}),
      email: emails,
      nombre: cliente?.nombre || pedido.guest_nombre || '',
      telefono: cliente?.telefono || pedido.guest_telefono || null,
    },
    items,
    ticket,
    channels: ['email'],
  });

  return res.status(200).json({
    ok: Boolean(result?.email?.sent),
    pedidoId,
    ticketUrl,
    email: result?.email || null,
    to: emails,
  });
}

/** Empleado: pide la reseña si el pedido ya quedó entregado (completado). */
async function handlePedirResena(req, res, body) {
  const pedidoId = Number(body?.pedidoId || body?.pedido_id);
  const employeeToken = String(
    body?.employeeSessionToken || body?.sessionTokenEmpleado || body?.sessionToken || ''
  ).trim();
  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
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
  const result = await enviarPedidoResena({ supabaseUrl, serviceKey, pedidoId });
  return res.status(200).json({ ok: true, pedidoId, resena: result });
}

module.exports = async function handler(req, res) {
  try {
    const body = await safeJson(req);
    const type = resolveNotificationType(req, body);

    if (type === 'solicitud') {
      return handleSolicitudTienda(req, res, body);
    }

    if (req.method !== 'POST') {
      return res.status(405).json({ ok: false, error: 'method_not_allowed' });
    }

    if (type === 'cita') {
      return handleCitaConfirmacion(req, res, body);
    }
    if (type === 'order') {
      return handleOrderReceipt(req, res, body);
    }
    if (type === 'pos-ticket') {
      return handlePosTicket(req, res, body);
    }
    if (type === 'recibo-ensure') {
      return handleReciboEnsure(req, res, body);
    }
    if (type === 'order-email') {
      return handleOrderTicketEmail(req, res, body);
    }
    if (type === 'whatsapp') {
      return handleWhatsAppManualSend(req, res, body);
    }
    if (type === 'pedir-resena') {
      return handlePedirResena(req, res, body);
    }

    return res.status(400).json({ ok: false, error: 'invalid_notification_type' });
  } catch (e) {
    console.error('[notifications/send] unhandled:', e?.message || e);
    return res.status(500).json({ ok: false, error: 'server_error', detail: e?.message || 'unknown' });
  }
};
