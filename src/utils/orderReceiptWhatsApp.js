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

/** POS: envía ticket por Meta Cloud API (sin abrir wa.me). */
export async function notifyPosTicket({
  pedidoId,
  telefono,
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
        employeeSessionToken,
        metodoPago,
        productos,
        puntosGanados,
        saldoPuntos,
      }),
    });
    const data = await resp.json().catch(() => ({}));
    if (resp.ok && data?.whatsapp?.sent) {
      return { sent: true, via: "server", whatsapp: data.whatsapp };
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
