/**
 * Semana de nómina FarmaCapital: sábado–viernes, depósito el viernes.
 * Solo arma el pago. No define horarios ni si se puede abrir o cerrar caja.
 */

import { addDaysISO, dowISO, hoyISOMexico } from "./fecha";

export { addDaysISO, dowISO, hoyISOMexico };

/** Sábado a viernes, inclusive. */
export const DIAS_NOMINA_SEMANA = 7;

export function round2(n) {
  return Math.round((Number(n) + Number.EPSILON) * 100) / 100;
}

/** Sábado que abre la semana de pago que cubre `iso` (YYYY-MM-DD). */
export function sabadoDeSemana(iso) {
  const back = [1, 2, 3, 4, 5, 6, 0][dowISO(iso)];
  return addDaysISO(iso, -back);
}

export function viernesDeSemana(iso) {
  return addDaysISO(sabadoDeSemana(iso), DIAS_NOMINA_SEMANA - 1);
}

export function diasLaboralesSemana(iso) {
  const sabado = sabadoDeSemana(iso);
  return Array.from({ length: DIAS_NOMINA_SEMANA }, (_, i) => addDaysISO(sabado, i));
}

/** Días sáb–vie hasta `hastaISO` (inclusive), recortado al viernes. */
export function diasHastaEnSemana(iso, hastaISO) {
  const sabado = sabadoDeSemana(iso);
  const viernes = addDaysISO(sabado, DIAS_NOMINA_SEMANA - 1);
  const cap = String(hastaISO).slice(0, 10) < viernes ? String(hastaISO).slice(0, 10) : viernes;
  return diasLaboralesSemana(sabado).filter((d) => d <= cap && d >= sabado);
}

export function diarioDeSemanal(salarioSemanal) {
  return round2(Number(salarioSemanal || 0) / DIAS_NOMINA_SEMANA);
}

/** El `semana_inicio` de la base no es el sábado de la semana de nómina de `fechaRef`. */
export function semanaNominaDesfasada(semana, fechaRef) {
  const inicio = String(semana?.semana_inicio || "").slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(inicio)) return false;
  return inicio !== sabadoDeSemana(fechaRef);
}

/** Salario del viernes. No se inventa a partir del quincenal viejo. */
export function salarioSemanalDe(emp) {
  const n = Number(emp?.salario_semanal);
  return Number.isFinite(n) && n > 0 ? n : 0;
}

export function esRpcRhPendiente(error) {
  return /could not find the function|pgrst202/i.test(String(error?.message || error || ""));
}

const IMSS_OBRERO = 0.02375;

export function calcularNominaSemanal({ salarioSemanal, diasTrabajo, aplicarImss = false }) {
  const salario = round2(Number(salarioSemanal || 0));
  const diario = diarioDeSemanal(salario);
  const dias = Math.max(0, Math.min(DIAS_NOMINA_SEMANA, Number(diasTrabajo) || 0));
  const bruto = dias === DIAS_NOMINA_SEMANA ? salario : round2(diario * dias);
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
  const sabado = sabadoDeSemana(iso);
  const viernes = addDaysISO(sabado, DIAS_NOMINA_SEMANA - 1);
  const [, m1, d1] = sabado.split("-").map(Number);
  const [y2, m2, d2] = viernes.split("-").map(Number);
  if (m1 === m2) return `${d1}–${d2} ${MESES_CORTO[m2 - 1]} ${y2}`;
  return `${d1} ${MESES_CORTO[m1 - 1]} – ${d2} ${MESES_CORTO[m2 - 1]} ${y2}`;
}
