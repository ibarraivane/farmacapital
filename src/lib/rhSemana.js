/** Semana laboral FarmaCapital: martes–viernes. Sáb/dom/lun pertenecen al viernes anterior. */

const TZ = "America/Mexico_City";

export function round2(n) {
  return Math.round((Number(n) + Number.EPSILON) * 100) / 100;
}

export function hoyISOMexico(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

export function addDaysISO(iso, days) {
  const [y, m, d] = String(iso).slice(0, 10).split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d + Number(days)));
  return dt.toISOString().slice(0, 10);
}

export function dowISO(iso) {
  const [y, m, d] = String(iso).slice(0, 10).split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d)).getUTCDay();
}

/** Martes de la semana de pago que cubre `iso` (YYYY-MM-DD). */
export function martesDeSemana(iso) {
  const back = [5, 6, 0, 1, 2, 3, 4][dowISO(iso)];
  return addDaysISO(iso, -back);
}

export function viernesDeSemana(iso) {
  return addDaysISO(martesDeSemana(iso), 3);
}

export function diasLaboralesSemana(iso) {
  const martes = martesDeSemana(iso);
  return [0, 1, 2, 3].map((i) => addDaysISO(martes, i));
}

/** Días mar–vie hasta `hastaISO` (inclusive), recortado al viernes. */
export function diasHastaEnSemana(iso, hastaISO) {
  const martes = martesDeSemana(iso);
  const viernes = addDaysISO(martes, 3);
  const cap = String(hastaISO).slice(0, 10) < viernes ? String(hastaISO).slice(0, 10) : viernes;
  return diasLaboralesSemana(martes).filter((d) => d <= cap && d >= martes);
}

export function diarioDeSemanal(salarioSemanal) {
  return round2(Number(salarioSemanal || 0) / 4);
}

const IMSS_OBRERO = 0.02375;

export function calcularNominaSemanal({ salarioSemanal, diasTrabajo, aplicarImss = false }) {
  const diario = diarioDeSemanal(salarioSemanal);
  const dias = Math.max(0, Math.min(4, Number(diasTrabajo) || 0));
  const bruto = round2(diario * dias);
  const imss = aplicarImss ? round2(bruto * IMSS_OBRERO) : 0;
  return { diario, dias, bruto, imss, neto: round2(bruto - imss) };
}

const MESES_CORTO = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
const DOW_LARGO = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"];

export function etiquetaDiaLaboral(iso) {
  const [y, m, d] = String(iso).slice(0, 10).split("-").map(Number);
  return `${DOW_LARGO[dowISO(iso)]} ${d} ${MESES_CORTO[m - 1]}`;
}

export function etiquetaRangoSemana(iso) {
  const martes = martesDeSemana(iso);
  const viernes = addDaysISO(martes, 3);
  const [, m1, d1] = martes.split("-").map(Number);
  const [y2, m2, d2] = viernes.split("-").map(Number);
  if (m1 === m2) return `${d1}–${d2} ${MESES_CORTO[m2 - 1]} ${y2}`;
  return `${d1} ${MESES_CORTO[m1 - 1]} – ${d2} ${MESES_CORTO[m2 - 1]} ${y2}`;
}
