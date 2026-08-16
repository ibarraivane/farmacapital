/** Confirmación de citas por WhatsApp Business (Twilio / Meta). */

import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";

export function formatCitaFecha(fecha) {
  if (!fecha) return "";
  try {
    const [y, m, d] = String(fecha).slice(0, 10).split("-").map(Number);
    if (!y || !m || !d) return String(fecha);
    const dt = new Date(y, m - 1, d);
    return dt.toLocaleDateString("es-MX", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch {
    return String(fecha);
  }
}

export function formatTelefonoDisplay(tel) {
  const d = String(tel || "").replace(/\D/g, "");
  const local = d.length >= 10 ? d.slice(-10) : d;
  if (local.length === 10) {
    return `${local.slice(0, 2)} ${local.slice(2, 6)} ${local.slice(6)}`;
  }
  if (d.length > 10) return `+${d.slice(0, 2)} ${d.slice(2)}`;
  return tel || "";
}

export function buildCitaConfirmacionMessage({ nombre, fecha, hora, motivo, citaId }) {
  const folio = citaId != null ? `#CITA-${String(citaId).padStart(4, "0")}` : "";
  const fechaTxt = formatCitaFecha(fecha);
  const motivoLine = motivo && String(motivo).trim() ? `Motivo: ${String(motivo).trim()}\n\n` : "";
  const saludo = nombre && String(nombre).trim() ? ` ${String(nombre).trim()}` : "";
  return (
    `📅 *Cita confirmada en FarmaCapital*\n\n` +
    `Hola${saludo}! Tu cita médica ha sido registrada.\n\n` +
    (folio ? `🔖 Folio: ${folio}\n` : "") +
    `🗓 Fecha: ${fechaTxt || fecha}\n` +
    `🕐 Hora: ${hora}\n` +
    `👩‍⚕️ Médico general\n` +
    `📍 ${FARMACIA_FISCAL.direccion_comercial}\n` +
    `🗺 ${FARMACIA_FISCAL.maps_url}\n\n` +
    motivoLine +
    `💊 Al terminar tu consulta, surte tu receta en FarmaCapital con 10% de descuento.\n\n` +
    `Te enviaremos un recordatorio 24 hrs antes.\n` +
    `📱 Dudas: ${FARMACIA_FISCAL.telefono_display}\n\n` +
    `¡Te esperamos! 🏥`
  );
}

const WA_NOT_CONFIGURED = new Set(["twilio_not_configured", "meta_not_configured"]);

/**
 * Envía confirmación de cita vía WhatsApp Business (servidor).
 * Requiere TWILIO_* o META_* en Vercel (ver .env.example).
 */
export async function notifyCitaConfirmacion({
  citaId,
  telefono,
  nombre,
  fecha,
  hora,
  motivo,
  sessionToken,
}) {
  const message = buildCitaConfirmacionMessage({ nombre, fecha, hora, motivo, citaId });
  try {
    const resp = await fetch("/api/notifications/cita-confirmacion", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        citaId,
        telefono,
        nombre,
        fecha,
        hora,
        motivo,
        message,
        sessionToken: sessionToken || null,
      }),
    });
    const data = await resp.json().catch(() => ({}));
    const wa = data?.whatsapp || {};
    if (wa.sent) return { sent: true, via: "server" };
    return {
      sent: false,
      notConfigured: WA_NOT_CONFIGURED.has(wa.reason),
      reason: wa.reason || "send_failed",
      message,
    };
  } catch (e) {
    console.warn("[citaWhatsApp] notify:", e);
    return { sent: false, reason: "network_error", message };
  }
}
