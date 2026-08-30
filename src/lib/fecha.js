/** Calendario de la farmacia (America/Mexico_City). Una sola definición de "hoy". */

export const TZ_FARMACIA = "America/Mexico_City";

export function hoyISOMexico(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ_FARMACIA,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

/** YYYY-MM-DD en zona farmacia para cualquier instante. */
export function ymdMexico(value = new Date()) {
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return hoyISOMexico();
  return hoyISOMexico(d);
}

/**
 * YYYY-MM-DD del Date en reloj local del dispositivo (rejillas de calendario
 * construidas con `new Date(y, m, d)`).
 */
export function ymdLocalDate(d) {
  const x = d instanceof Date ? d : new Date(d);
  const y = x.getFullYear();
  const m = String(x.getMonth() + 1).padStart(2, "0");
  const day = String(x.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

export function addDaysISO(iso, days) {
  const [y, m, d] = String(iso).slice(0, 10).split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d + Number(days)));
  // eslint-disable-next-line no-restricted-syntax -- aritmética Date.UTC, no "hoy" de mostrador
  return dt.toISOString().slice(0, 10);
}

export function dowISO(iso) {
  const [y, m, d] = String(iso).slice(0, 10).split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d)).getUTCDay();
}

/** Lunes de la semana ISO (lun–dom) que contiene `iso` (YYYY-MM-DD). */
export function lunesISODe(iso) {
  const dow = dowISO(iso); // 0=dom … 6=sáb
  const back = dow === 0 ? 6 : dow - 1;
  return addDaysISO(iso, -back);
}

function mexicoMidnightUtcMs(day) {
  const ymdAt = (ms) =>
    new Intl.DateTimeFormat("en-CA", {
      timeZone: TZ_FARMACIA,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(new Date(ms));
  let lo = Date.parse(`${day}T00:00:00.000Z`) - 12 * 3600_000;
  let hi = Date.parse(`${day}T00:00:00.000Z`) + 14 * 3600_000;
  while (hi - lo > 1) {
    const mid = Math.floor((lo + hi) / 2);
    if (ymdAt(mid) < day) lo = mid;
    else hi = mid;
  }
  return hi;
}

/** Rango [inicio, fin) del día de farmacia, en ISO, para filtrar timestamps. */
export function rangoDiaMexico(iso = hoyISOMexico()) {
  const day = String(iso).slice(0, 10);
  const startMs = mexicoMidnightUtcMs(day);
  const endMs = mexicoMidnightUtcMs(addDaysISO(day, 1));
  return {
    start: new Date(startMs).toISOString(),
    end: new Date(endMs).toISOString(),
  };
}
