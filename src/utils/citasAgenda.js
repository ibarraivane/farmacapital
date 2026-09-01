import { citaEstaPagada } from "./consultaConstants";
import { hoyISOMexico, TZ_FARMACIA } from "../lib/fecha";

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

/** Sábado: solo matutino (hasta 14:00). */
export const HORARIOS_CITA_SABADO = TODOS_HORARIOS_CITA.filter((h) => h <= "14:00");

/** Día de la semana 0=dom … 6=sáb para un YYYY-MM-DD civil. */
export function dowFromYmd(ymd) {
  const [y, m, d] = String(ymd || "").slice(0, 10).split("-").map(Number);
  if (!Number.isFinite(y) || !Number.isFinite(m) || !Number.isFinite(d)) return null;
  return new Date(Date.UTC(y, m - 1, d, 12)).getUTCDay();
}

/** Hora actual en America/Mexico_City → { hh, mm }. */
export function horaActualMexico(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ_FARMACIA,
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).formatToParts(now);
  const hh = Number(parts.find((p) => p.type === "hour")?.value || 0);
  const mm = Number(parts.find((p) => p.type === "minute")?.value || 0);
  return { hh, mm };
}

/** Normaliza "09:00:00" / "9:00" → "09:00". */
export function normalizarHoraCita(raw) {
  const s = String(raw || "").trim();
  const m = s.match(/^(\d{1,2}):(\d{2})/);
  if (!m) return "";
  return `${pad2(Number(m[1]))}:${m[2]}`;
}

/**
 * Slots del consultorio:
 * - Domingo: cerrado
 * - Sábado: 09:00–14:00
 * - L–V: rejilla completa
 * - Hoy: solo futuros (reloj México)
 * @param {string} fecha YYYY-MM-DD
 */
export function horariosDisponiblesCita(fecha) {
  if (!fecha) return [];
  const hoy = hoyISOMexico();
  if (fecha < hoy) return [];

  const dow = dowFromYmd(fecha);
  if (dow === 0) return []; // domingo cerrado
  const base = dow === 6 ? HORARIOS_CITA_SABADO : TODOS_HORARIOS_CITA;
  if (fecha > hoy) return base;

  const { hh, mm } = horaActualMexico();
  return base.filter((h) => {
    const [H, M] = h.split(":").map(Number);
    return H > hh || (H === hh && M > mm);
  });
}

/** Texto de ayuda cuando no hay slots. */
export function motivoSinHorariosCita(fecha) {
  if (!fecha) return "Elegí una fecha para ver horarios.";
  const hoy = hoyISOMexico();
  if (fecha < hoy) return "Esa fecha ya pasó. Elegí otro día.";
  if (dowFromYmd(fecha) === 0) {
    return "Domingo el consultorio está cerrado. Elegí lunes a sábado.";
  }
  if (fecha === hoy && horariosDisponiblesCita(fecha).length === 0) {
    return "Ya no hay horarios libres hoy. Elegí otro día.";
  }
  return "No hay horarios disponibles. Elegí otra fecha.";
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
