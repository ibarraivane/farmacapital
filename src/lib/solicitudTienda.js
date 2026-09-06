/** Solicitud «te lo conseguimos» desde la tienda → Lo que buscan. */

export const SOLICITUD_STAFF_EMAILS = [
  "contacto@farmacapital.mx",
  "farmacapital@outlook.com",
];

export const SOLICITUD_API_PATH = "/api/solicitudes";

export function normalizarTextoPedido(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 200);
}

export function normalizarNotasPedido(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 500);
}

export function normalizarNombreCliente(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 120);
}

export function normalizarEmail(raw) {
  const e = String(raw || "").trim().toLowerCase();
  if (!e) return "";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e)) return "";
  return e.slice(0, 120);
}

export function normalizarTelefonoPedido(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.length >= 10) return digits.slice(-10);
  return digits;
}

export function normalizarDireccionPedido(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 240);
}

export function validarSolicitudTienda(raw = {}) {
  const texto = normalizarTextoPedido(raw.texto);
  const cantidad = Number(raw.cantidad);
  const nombre = normalizarNombreCliente(raw.nombre || raw.cliente_nombre);
  const telefono = normalizarTelefonoPedido(raw.telefono || raw.cliente_telefono);
  const email = normalizarEmail(raw.email || raw.cliente_email);
  const direccion = normalizarDireccionPedido(raw.direccion);
  const notas = normalizarNotasPedido(raw.notas);
  let urgencia = String(raw.urgencia || "sin_prisa").trim();
  if (!["hoy", "manana", "sin_prisa"].includes(urgencia)) urgencia = "sin_prisa";

  const errors = [];
  if (texto.length < 2) errors.push("Escribe el medicamento o producto que buscas.");
  if (!Number.isFinite(cantidad) || cantidad < 1 || cantidad > 999) {
    errors.push("La cantidad debe ser entre 1 y 999.");
  }
  if (nombre.length < 2) errors.push("Escribe tu nombre.");
  if (telefono.length !== 10) errors.push("Teléfono de 10 dígitos para WhatsApp.");

  return {
    ok: errors.length === 0,
    errors,
    value: {
      texto,
      cantidad: Number.isFinite(cantidad) ? Math.max(1, Math.min(999, Math.round(cantidad))) : 1,
      urgencia,
      notas,
      cliente_nombre: nombre,
      cliente_telefono: telefono,
      cliente_email: email,
      direccion,
    },
  };
}

export function buildSolicitudWhatsAppCliente({ telefono, texto, nombre } = {}) {
  const digits = normalizarTelefonoPedido(telefono);
  if (digits.length !== 10) return "";
  const quien = nombre ? ` ${nombre}` : "";
  const que = texto ? ` por *${texto}*` : "";
  const msg =
    `Hola${quien}, soy FarmaCapital.${que} Ya lo estamos cotizando. ` +
    `Te paso el costo y la liga de pago por aquí. El envío a domicilio tiene costo.`;
  return `https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`;
}

export function buildSolicitudMailtoStaff({ texto, nombre, telefono } = {}) {
  const subject = encodeURIComponent(`Pedido por conseguir: ${texto || "solicitud"}`);
  const body = encodeURIComponent(
    `Hola, te escribimos de FarmaCapital sobre tu solicitud${nombre ? ` (${nombre})` : ""}.\n\n` +
      `Producto: ${texto || "—"}\nWhatsApp: ${telefono || "—"}\n\n` +
      `Te pasamos el costo y la liga de pago en cuanto lo cotice el equipo.`,
  );
  return `mailto:${SOLICITUD_STAFF_EMAILS.join(",")}?subject=${subject}&body=${body}`;
}
