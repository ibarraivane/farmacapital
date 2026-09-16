/**
 * Surtir pedido online en POS: toasts y errores de marcar_pedido_listo + WhatsApp.
 * El pedido puede quedar listo aunque falle el aviso al cliente.
 */

import { parseRpcJsonObject } from "../utils/rpcJson";
import { formatWhatsAppSendError } from "../utils/orderReceiptWhatsApp";

export function telefonoClientePedido(pedido) {
  const cli = pedido?.clientes;
  const fromCli = Array.isArray(cli) ? cli[0]?.telefono : cli?.telefono;
  return String(fromCli || pedido?.guest_telefono || "").trim();
}

export function payloadMarcarPedidoListo(data) {
  const obj = parseRpcJsonObject(data);
  if (obj && typeof obj.success === "boolean") return obj;
  if (Array.isArray(data) && data[0]) return parseRpcJsonObject(data[0]);
  return obj;
}

export function mensajeErrorSurtirPedido(err) {
  const raw = String(err?.message || err || "").trim();
  const lower = raw.toLowerCase();

  if (/sesión inválida|sesion invalida|sesión expirada|sesion expirada|jwt/i.test(raw)) {
    return "Sesión expirada. Vuelve a entrar.";
  }
  if (/pago no confirmado/i.test(raw)) {
    return "Pago no confirmado. Espera la aprobación de Mercado Pago antes de surtir.";
  }
  if (/stock insuficiente|sin lotes disponibles|error al consumir stock/i.test(raw)) {
    return "No hay piezas en lotes para descontar. Recibe el producto (pistola + caducidad MMAA) e inténtalo de nuevo.";
  }
  if (/no se puede marcar listo un pedido en estado/i.test(raw)) {
    return "Este pedido ya no se puede surtir (ya está entregado o cancelado).";
  }
  if (/pedido .+ no encontrado|no encontrado/i.test(raw) && /pedido/i.test(raw)) {
    return "No se encontró el pedido.";
  }
  if (/schema cache|does not exist|pgrst202|could not find the function/i.test(raw)) {
    return "Falta actualizar la base (marcar_pedido_listo). Avisa a sistemas.";
  }
  if (!raw || lower === "no se pudo surtir") return "No se pudo surtir el pedido.";
  return `No se pudo surtir: ${raw}`;
}

function hintEnvio(tipoEntrega) {
  return tipoEntrega === "envio" ? " · pide el mensajero (el cliente ya pagó el envío)" : "";
}

/**
 * Toasts después de marcar_pedido_listo OK.
 * Siempre confirma que el pedido quedó listo. Si WhatsApp falla, el warning va aparte
 * (abajo del success) para que no parezca que el surtido falló.
 */
export function toastsTrasSurtirOk({ tipoEntrega, telefono, wa } = {}) {
  const envioHint = hintEnvio(tipoEntrega);
  const tel = String(telefono || "").trim();
  const sent = Boolean(wa?.sent);

  if (!tel) {
    return [{ tipo: "success", msg: `Pedido marcado como listo${envioHint}` }];
  }

  if (sent) {
    const msg =
      tipoEntrega === "envio"
        ? `Pedido listo${envioHint}`
        : `Pedido listo · pase de recogida enviado por WhatsApp${envioHint}`;
    return [{ tipo: "success", msg }];
  }

  let waHint = "";
  try {
    waHint = formatWhatsAppSendError({
      reason: wa?.reason,
      detail: wa?.detail,
      telefono: tel,
    });
  } catch {
    waHint = "";
  }

  return [
    { tipo: "success", msg: `Pedido marcado como listo${envioHint}` },
    {
      tipo: "warning",
      msg: waHint || "WhatsApp no se envió. El pedido ya quedó listo; avisa al cliente a mano.",
    },
  ];
}
