/** WhatsApp y folios para pedidos online — FarmaCapital */

import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";

export const FARMACIA_WHATSAPP = FARMACIA_FISCAL.telefono;
export const FARMACIA_WHATSAPP_DISPLAY = FARMACIA_FISCAL.telefono_display;
export const FARMACIA_DIRECCION = FARMACIA_FISCAL.direccion_comercial;
export const FARMACIA_MAPS_URL = FARMACIA_FISCAL.maps_url;

export function formatFolioOnline(pedidoId) {
  if (pedidoId == null) return null;
  return `#FC-${String(pedidoId).padStart(4, "0")}`;
}

export function formatFolioPOS(pedidoId) {
  if (pedidoId == null) return null;
  return `VTA-${String(pedidoId).padStart(8, "0")}`;
}

export function digitsOnlyPhone(v) {
  return String(v || "").replace(/\D/g, "");
}

/** Mensaje legible cuando falla notifyPosTicket / notifyOnlineOrderReceipt. */
export function formatWhatsAppSendError({ reason, detail, telefono } = {}) {
  const tel = telefono ? String(telefono).trim() : "";
  const raw = [reason, detail].filter(Boolean).join(" ");
  const lower = raw.toLowerCase();

  const local10 = digitsOnlyPhone(tel).slice(-10);
  const metaTestDisplay =
    local10.length === 10
      ? `+52 ${local10.slice(0, 2)} ${local10.slice(2, 6)} ${local10.slice(6)}`
      : tel || "el teléfono del cliente";

  if (reason === "missing_session") {
    return "Sesión expirada. Vuelve a iniciar sesión en el panel.";
  }
  if (reason === "missing_phone" || reason === "invalid_phone") {
    return "Teléfono inválido. Captura 10 dígitos de México.";
  }
  if (reason === "whatsapp_cloud_not_configured") {
    return "WhatsApp no está configurado en el servidor (token o Phone Number ID).";
  }
  if (reason === "invalid_employee_session") {
    return "Sesión de empleado inválida. Cierra sesión y vuelve a entrar.";
  }
  if (reason === "pedido_not_found") {
    return detail
      ? `No se encontró el pedido en el servidor. ${detail}`
      : "No se encontró el pedido en el servidor (revisa SUPABASE_SERVICE_ROLE_KEY en Vercel).";
  }
  if (reason === "missing_server_env") {
    return "Falta SUPABASE_SERVICE_ROLE_KEY en Vercel (Settings → Environment Variables).";
  }
  if (reason === "http_500" || /function_invocation_failed/i.test(raw)) {
    return (
      "El servidor de WhatsApp no responde (error interno). " +
      "Espera 1–2 min a que termine el deploy en Vercel o revisa Deployments → último build en Error."
    );
  }

  let metaMessage = "";
  try {
    const parsed = typeof detail === "string" && detail.trim().startsWith("{")
      ? JSON.parse(detail)
      : detail;
    metaMessage = parsed?.error?.message || parsed?.error?.error_user_msg || "";
    const code = parsed?.error?.code;
    if (code === 131030 || code === 131031) {
      return `Meta (modo Development): agrega ${metaTestDisplay} en WhatsApp → API Setup → «Números de teléfono de prueba». Debe ser el teléfono del cliente de esa fila (no otro).`;
    }
    if (code === 131047) {
      return (
        "Meta rechazó el mensaje de texto libre (ventana de 24 h cerrada). " +
        "Los tickets deben enviarse con la plantilla pedido_confirmado aprobada — revisa Vercel Logs por «template failed»."
      );
    }
    if (code === 132000 || code === 132001 || code === 132005) {
      return (
        `Meta rechazó la plantilla (${metaMessage || `error ${code}`}). ` +
        "Revisa en Vercel: WHATSAPP_BUSINESS_ACCOUNT_ID=1575449287233472 y WHATSAPP_PHONE_NUMBER_ID=1320112064512676. " +
        "Si WHATSAPP_TEMPLATE_LANGUAGE existe, bórrala o pon es_MX (no «Spanish (MEX)»)."
      );
    }
    if (code === 190 || code === 102 || code === 10) {
      return (
        "Meta rechazó el token (Authentication Error). " +
        "Regenera WHATSAPP_ACCESS_TOKEN en Meta → WhatsApp → API Setup, pégalo en Vercel y redeploy. " +
        "El token temporal dura ~24 h; confirma que WHATSAPP_PHONE_NUMBER_ID sea el de esa misma pantalla."
      );
    }
  } catch {
    /* detail no es JSON */
  }

  if (/authentication error|invalid oauth|error validating access token|session has expired/i.test(raw)) {
    return (
      "Meta rechazó el token (Authentication Error). " +
      "Regenera WHATSAPP_ACCESS_TOKEN en Meta → WhatsApp → API Setup, pégalo en Vercel y redeploy."
    );
  }

  if (reason === "whatsapp_text_outside_window" || reason === "meta_template_error") {
    if (/131047|re-engagement|24 hours/i.test(raw)) {
      return (
        "La plantilla falló y el texto libre no puede enviarse (Meta error 131047). " +
        "Confirma que pedido_confirmado está Aprobada en es_MX con 4 variables."
      );
    }
  }

  if (
    /131030|not in allowed list|recipient.*not allowed|no está en la lista/i.test(raw) ||
    /not a valid whatsapp user/i.test(lower)
  ) {
    return `Meta (modo Development): ${metaTestDisplay} debe estar en «Números de teléfono de prueba» (formato +52, sin el 1 extra).`;
  }

  if (metaMessage) {
    return `Meta rechazó el envío: ${metaMessage}`;
  }

  if (reason === "meta_template_error" || reason === "meta_provider_error") {
    return "Meta rechazó el envío. Revisa plantilla aprobada y números de prueba (+52).";
  }

  return reason
    ? `No se pudo enviar por WhatsApp (${reason}).`
    : "No se pudo enviar por WhatsApp.";
}

/** Mensaje cuando Meta aceptó el envío (aún puede fallar en entrega — revisar webhook). */
export function formatWhatsAppSuccessMessage({ telefono, whatsapp, devHint, ticketUrl } = {}) {
  const local10 = digitsOnlyPhone(telefono).slice(-10);
  const dest =
    local10.length === 10
      ? `+52 ${local10.slice(0, 2)} ${local10.slice(2, 6)} ${local10.slice(6)}`
      : telefono || "el cliente";
  const viaLabel =
    whatsapp?.via === "template"
      ? `plantilla ${whatsapp.template || "Meta"}`
      : whatsapp?.via === "text_fallback" || whatsapp?.via === "text"
        ? "mensaje de texto"
        : "Meta API";
  const idHint = whatsapp?.messageId ? ` Ref: …${String(whatsapp.messageId).slice(-10)}.` : "";
  const linkHint = ticketUrl ? ` Ticket: ${ticketUrl}` : "";

  return (
    `Envío aceptado por Meta (${viaLabel}).${idHint}${linkHint} ` +
    `Abre WhatsApp en ${dest} (chat del +1 555… de prueba Meta). ` +
    (devHint || "El enlace del ticket también queda guardado en el pedido.")
  );
}

export function buildOnlineOrderReceiptMessage({
  pedidoId,
  items = [],
  total = 0,
  tipoEntrega = "recoger",
  metodoPago = null,
  includeFarmaciaContact = true,
}) {
  const folio = formatFolioOnline(pedidoId) || `#FC-${pedidoId || "?"}`;
  const lines = (items || []).map((i) => {
    const qty = Number(i.qty ?? i.cantidad ?? 1);
    const precio = Number(i.precio ?? i.precio_unitario ?? 0);
    const nombre = i.nombre || i.productos?.nombre || "Producto";
    return `• ${nombre} ×${qty} = $${(precio * qty).toFixed(2)}`;
  });
  const entregaTxt =
    tipoEntrega === "recoger"
      ? "Pick-up en FarmaCapital"
      : "Envío a domicilio";
  const pickupNote =
    tipoEntrega === "recoger"
      ? `\n\n🏪 Muestra tu folio *${folio}* o menciona tu teléfono al llegar.\n📍 ${FARMACIA_MAPS_URL}`
      : "\n\n📞 Te contactamos para coordinar tu entrega.";
  const pagoTxt = metodoPago
    ? `\n💳 *Pago:* ${String(metodoPago).replace(/_/g, " ")}`
    : "";

  let msg =
    `🏥 *FarmaCapital*\n${FARMACIA_DIRECCION}\n\n` +
    `✅ *Pedido confirmado*\n🔖 *Folio:* ${folio}\n\n` +
    `${lines.join("\n") || "• (sin detalle de productos)"}\n\n` +
    `💰 *Total: $${Number(total || 0).toFixed(2)}*\n` +
    `📦 *Entrega:* ${entregaTxt}` +
    pagoTxt +
    pickupNote +
    `\n\n¡Gracias por tu preferencia! 💊`;

  if (includeFarmaciaContact) {
    msg += `\n\n📱 *WhatsApp farmacia:* ${FARMACIA_WHATSAPP_DISPLAY}\nResponde a este número si tienes dudas.`;
  }
  return msg;
}

export function openWhatsAppToCustomer(telefono, message) {
  const digits = digitsOnlyPhone(telefono);
  if (!digits || digits.length < 10) return false;
  const url =
    "https://wa.me/52" +
    digits +
    "?text=" +
    encodeURIComponent(message || "");
  window.open(url, "_blank", "noopener,noreferrer");
  return true;
}

export function openWhatsAppToFarmacia(message) {
  const url =
    "https://wa.me/52" +
    FARMACIA_WHATSAPP +
    "?text=" +
    encodeURIComponent(message || "");
  window.open(url, "_blank", "noopener,noreferrer");
  return true;
}

export function buildCustomerToFarmaciaMessage({ pedidoId, total, customerName, customerTel }) {
  const folio = formatFolioOnline(pedidoId) || `#FC-${pedidoId || "?"}`;
  const nombre = customerName ? `, soy ${customerName}` : "";
  const tel = customerTel ? ` (${customerTel})` : "";
  return (
    `Hola FarmaCapital${nombre}${tel}. Confirmo mi pedido ${folio} por $${Number(total || 0).toFixed(2)}. ` +
    `Por favor envíenme el recibo por WhatsApp. Gracias.`
  );
}

export function buildPosTicketWhatsAppMessage({
  venta = {},
  productos = [],
  metodoPago = "Efectivo",
  config = {},
  puntosGanados = null,
  saldoPuntos = null,
}) {
  const cfgNombre = config?.nombre_farmacia || "FarmaCapital";
  const direccion = config?.direccion_farmacia || FARMACIA_DIRECCION;
  const folio = venta.folio || formatFolioPOS(venta.id) || `#${venta.id || "?"}`;
  const lines = (productos || []).map((p) => {
    const qty = Number(p.qty ?? p.cantidad ?? 1);
    const precio = Number(p.precio ?? p.precio_unitario ?? 0);
    const nombre = p.nombre || p.productos?.nombre || "Producto";
    return `• ${nombre} ×${qty} = $${(precio * qty).toFixed(2)}`;
  });
  const total = Number(venta.total || 0);
  let msg =
    `🏥 *${cfgNombre}*\n${direccion}\n🗺 ${FARMACIA_MAPS_URL}\n\n` +
    `🧾 *Ticket de compra*\n🔖 *Folio:* ${folio}\n\n` +
    `${lines.join("\n") || "• (sin detalle)"}\n\n` +
    `💰 *Total: $${total.toFixed(2)}*\n` +
    `💳 *Pago:* ${String(metodoPago || "—").replace(/_/g, " ")}`;
  if (puntosGanados != null && puntosGanados > 0) {
    msg += `\n\n⭐ *+${puntosGanados} puntos FarmaCapital*`;
    if (saldoPuntos != null) msg += `\nSaldo: *${saldoPuntos} pts*`;
  }
  msg += `\n\n¡Gracias por su preferencia! 💊`;
  return msg;
}

export function buildOnlineOrderReadyMessage({
  pedidoId,
  items = [],
  total = 0,
  tipoEntrega = "recoger",
  metodoPago = null,
}) {
  const folio = formatFolioOnline(pedidoId) || `#FC-${pedidoId || "?"}`;
  const receipt = buildOnlineOrderReceiptMessage({
    pedidoId,
    items,
    total,
    tipoEntrega,
    metodoPago,
    includeFarmaciaContact: false,
  });
  const listo =
    tipoEntrega === "recoger"
      ? `\n\n✅ *¡Tu pedido está listo para recoger!*\n📍 ${FARMACIA_DIRECCION}\n🗺 ${FARMACIA_MAPS_URL}\nMuestra tu folio *${folio}* en mostrador.`
      : `\n\n✅ *¡Tu pedido está listo!* Te contactamos para la entrega.`;
  return receipt + listo;
}

/** Asegura recibo_token en el pedido y devuelve la URL pública del ticket (/r/{token}). */
export async function ensurePedidoTicketUrl(pedidoId) {
  if (!pedidoId) return { ok: false, reason: "missing_pedido_id" };

  const employeeSessionToken = sessionStorage.getItem("farmacapital_session_token");
  if (!employeeSessionToken) return { ok: false, reason: "missing_session" };

  try {
    const resp = await fetch("/api/recibos/ensure", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pedidoId, employeeSessionToken }),
    });
    const data = await resp.json().catch(() => ({}));
    if (resp.ok && data?.ticketUrl) {
      return { ok: true, ticketUrl: data.ticketUrl, token: data.token || null };
    }
    return { ok: false, reason: data?.error || `http_${resp.status}` };
  } catch {
    return { ok: false, reason: "network_error" };
  }
}

/** POS: envía ticket por Meta Cloud API (sin abrir wa.me). */
export async function notifyPosTicket({
  pedidoId,
  telefono,
  total = null,
  metodoPago = null,
  productos = [],
  puntosGanados = null,
  saldoPuntos = null,
}) {
  if (!pedidoId || !telefono) return { sent: false, reason: "missing_params" };

  const employeeSessionToken = sessionStorage.getItem("farmacapital_session_token");
  if (!employeeSessionToken) return { sent: false, reason: "missing_session" };

  try {
    const resp = await fetch("/api/notifications/pos-ticket", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        pedidoId,
        telefono,
        total,
        employeeSessionToken,
        metodoPago,
        productos,
        puntosGanados,
        saldoPuntos,
      }),
    });
    const data = await resp.json().catch(() => ({}));
    if (resp.ok && data?.whatsapp?.sent) {
      return {
        sent: true,
        via: data.whatsapp.via || "server",
        whatsapp: data.whatsapp,
        devHint: data.devHint || null,
        ticketUrl: data.ticketUrl || null,
      };
    }
    return {
      sent: false,
      reason: data?.error || data?.whatsapp?.reason || `http_${resp.status}`,
      detail: data?.detail || data?.whatsapp?.detail || null,
    };
  } catch (e) {
    console.warn("[orderReceiptWhatsApp] pos-ticket:", e);
    return { sent: false, reason: "network_error" };
  }
}

export async function notifyOnlineOrderReceipt({
  pedidoId,
  sessionToken = null,
  phoneVerify = null,
  event = "order_created",
  employeeSessionToken = null,
  telefono = null,
  forceWhatsApp = false,
}) {
  if (!pedidoId) return { sent: false, reason: "missing_pedido_id" };

  const tok = employeeSessionToken || sessionStorage.getItem("farmacapital_session_token");

  try {
    const resp = await fetch("/api/notifications/order-receipt", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        pedidoId,
        sessionToken,
        phoneVerify,
        event,
        employeeSessionToken: tok,
        telefono,
        forceWhatsApp: forceWhatsApp === true,
      }),
    });
    const data = await resp.json().catch(() => ({}));
    if (data?.whatsapp?.sent) return { sent: true, via: "server", whatsapp: data.whatsapp };
    return {
      sent: false,
      reason: data?.error || data?.whatsapp?.reason || `http_${resp.status}`,
      detail: data?.detail || data?.whatsapp?.detail || null,
    };
  } catch (e) {
    console.warn("[orderReceiptWhatsApp] API notify:", e);
    return { sent: false, reason: "network_error" };
  }
}
