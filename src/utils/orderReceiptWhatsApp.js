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

export async function notifyOnlineOrderReceipt({ pedidoId, telefono, items, total, tipoEntrega, metodoPago }) {
  const msg = buildOnlineOrderReceiptMessage({
    pedidoId,
    items,
    total,
    tipoEntrega,
    metodoPago,
  });

  try {
    const resp = await fetch("/api/notifications/order-receipt", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pedidoId, telefono, message: msg }),
    });
    const data = await resp.json().catch(() => ({}));
    if (data?.whatsapp?.sent) return { sent: true, via: "server", message: msg };
  } catch (e) {
    console.warn("[orderReceiptWhatsApp] API notify:", e);
  }

  return { sent: false, message: msg };
}
