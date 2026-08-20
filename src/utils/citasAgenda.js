import { citaEstaPagada } from "./consultaConstants";

const pad2 = (n) => String(n).padStart(2, "0");

/** Suma días a una fecha YYYY-MM-DD (zona local). */
export function addDaysSv(sv, deltaDays) {
  if (!sv || typeof sv !== "string") return sv;
  const [y, m, d] = sv.split("-").map((x) => parseInt(x, 10));
  if (!Number.isFinite(y) || !Number.isFinite(m) || !Number.isFinite(d)) return sv;
  const dt = new Date(y, m - 1, d + deltaDays);
  return `${dt.getFullYear()}-${pad2(dt.getMonth() + 1)}-${pad2(dt.getDate())}`;
}

/** Etiqueta legible para agenda (es-MX). */
export function formatFechaAgendaLargaEs(sv) {
  try {
    const [y, m, d] = sv.split("-").map(Number);
    return new Date(y, m - 1, d).toLocaleDateString("es-MX", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch {
    return sv;
  }
}

/** Misma rejilla que la tienda en línea (consultorio). */
export const TODOS_HORARIOS_CITA = [
  "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
  "12:00", "12:30", "13:00", "13:30", "14:00",
  "16:00", "16:30", "17:00", "17:30", "18:00", "18:30",
];

/**
 * Horarios futuros si la fecha es hoy; si es otro día, todos los slots.
 * @param {string} fecha YYYY-MM-DD
 */
export function horariosDisponiblesCita(fecha) {
  if (!fecha) return TODOS_HORARIOS_CITA;
  const hoy = new Date().toLocaleDateString("sv-SE");
  if (fecha < hoy) return [];
  if (fecha > hoy) return TODOS_HORARIOS_CITA;
  const ahora = new Date();
  return TODOS_HORARIOS_CITA.filter((h) => {
    const [hh, mm] = h.split(":").map(Number);
    return hh > ahora.getHours() || (hh === ahora.getHours() && mm > ahora.getMinutes());
  });
}

/**
 * Una sola cita por horario (un consultorio).
 * Caja/agenda pueden anular si sigue sin pagar y no está en consulta ni atendida.
 */
export function puedeCancelarCitaCaja(cita) {
  if (!cita) return false;
  const est = String(cita.estado || "").toLowerCase();
  if (est === "cancelada" || est === "no_asistio" || est === "completada" || est === "en_consulta") return false;
  if (citaEstaPagada(cita)) return false;
  return true;
}

function inicioCitaLocal(cita) {
  if (!cita?.fecha || cita.hora == null || cita.hora === "") return null;
  const fecha = String(cita.fecha).slice(0, 10);
  const parts = fecha.split("-").map(Number);
  if (parts.length < 3 || parts.some((n) => !Number.isFinite(n))) return null;
  const [hh, mm] = String(cita.hora).split(":").map((x) => parseInt(x, 10));
  return new Date(
    parts[0],
    parts[1] - 1,
    parts[2],
    Number.isFinite(hh) ? hh : 0,
    Number.isFinite(mm) ? mm : 0,
    0,
    0
  );
}

/** Ya pasó la hora de inicio + tolerancia y no pagó: no-show. Incluye citas de días anteriores. */
export function esCitaNoShow(cita, toleranceMin = 10, nowMs = Date.now()) {
  if (!puedeCancelarCitaCaja(cita)) return false;
  const start = inicioCitaLocal(cita);
  if (!start) return false;
  const deadline = start.getTime() + toleranceMin * 60 * 1000;
  return nowMs > deadline;
}

/** @deprecated Usar esCitaNoShow. Conservado porque POS lo importaba. */
export function puedeCancelarCitaNoShow(cita, toleranceMin = 10) {
  return esCitaNoShow(cita, toleranceMin);
}
