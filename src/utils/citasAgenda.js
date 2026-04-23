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
 * Una sola cita por horario (un consultorio). Tras hora + tolerancia (min), si sigue sin pagar, la caja puede cancelar.
 */
export function puedeCancelarCitaNoShow(cita, toleranceMin = 10) {
  if (!cita || cita.estado === "cancelada") return false;
  if (cita.estado === "completada" || cita.estado === "en_consulta") return false;
  if (citaEstaPagada(cita)) return false;
  if (!cita.fecha || cita.hora == null || cita.hora === "") return false;
  const hoy = new Date().toLocaleDateString("sv-SE");
  if (cita.fecha !== hoy) return false;
  const parts = String(cita.fecha).split("-").map(Number);
  const [hh, mm] = String(cita.hora).split(":").map((x) => parseInt(x, 10));
  const start = new Date(parts[0], parts[1] - 1, parts[2], Number.isFinite(hh) ? hh : 0, Number.isFinite(mm) ? mm : 0, 0, 0);
  const deadline = new Date(start.getTime() + toleranceMin * 60 * 1000);
  return Date.now() > deadline.getTime();
}
