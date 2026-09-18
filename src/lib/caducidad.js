/**
 * Caducidad de farmacia: las cajas traen mes/año, no día.
 * Interno: último día del mes (ISO). Entrada de pistola: MMAA (0629).
 */

export const DIAS_CADUCIDAD_CRITICO = 30;
export const DIAS_CADUCIDAD_ALERTA = 90;

const MESES_CORTOS = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

/** "0629" | "06/29" | "062029" → "2029-06-30". Inválido → null. */
export function parseCaducidadMMAA(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  let mm;
  let year;
  if (digits.length === 4) {
    mm = parseInt(digits.slice(0, 2), 10);
    year = 2000 + parseInt(digits.slice(2, 4), 10);
  } else if (digits.length === 6) {
    mm = parseInt(digits.slice(0, 2), 10);
    year = parseInt(digits.slice(2, 6), 10);
  } else {
    return null;
  }
  if (!Number.isFinite(mm) || mm < 1 || mm > 12) return null;
  if (!Number.isFinite(year) || year < 2000 || year > 2045) return null;
  const lastDay = new Date(year, mm, 0).getDate();
  return `${year}-${String(mm).padStart(2, "0")}-${String(lastDay).padStart(2, "0")}`;
}

/** ISO → "06/2029" */
export function formatCaducidadMesAnio(iso) {
  if (!iso) return "";
  const [y, m] = String(iso).split("-");
  const mi = parseInt(m, 10);
  if (!mi || mi < 1 || mi > 12) return String(iso);
  return `${String(mi).padStart(2, "0")}/${y}`;
}

/** Preview mientras teclea MMAA: "0629" → "jun 2029" */
export function etiquetaCaducidadMMAA(raw) {
  const iso = parseCaducidadMMAA(raw);
  if (!iso) return "";
  const [y, m] = iso.split("-");
  const mi = parseInt(m, 10);
  return `${MESES_CORTOS[mi - 1]} ${y}`;
}

/** ISO (último día del mes) → "jun 2029". Sin fecha → "". */
export function etiquetaCaducidadIso(iso) {
  if (!iso) return "";
  const [y, m] = String(iso).slice(0, 10).split("-");
  const mi = parseInt(m, 10);
  const year = parseInt(y, 10);
  if (!mi || mi < 1 || mi > 12 || !year) return "";
  return `${MESES_CORTOS[mi - 1]} ${year}`;
}

/** Días civiles hasta la caducidad (hoy farmacia YYYY-MM-DD). Sin fecha → null. */
export function diasRestantesCaducidad(iso, hoyIso) {
  const cad = String(iso || "").slice(0, 10);
  const hoy = String(hoyIso || "").slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(cad) || !/^\d{4}-\d{2}-\d{2}$/.test(hoy)) return null;
  const [cy, cm, cd] = cad.split("-").map(Number);
  const [hy, hm, hd] = hoy.split("-").map(Number);
  const a = Date.UTC(cy, cm - 1, cd);
  const b = Date.UTC(hy, hm - 1, hd);
  return Math.floor((a - b) / 86400000);
}

export function esPorCaducar(dias) {
  return typeof dias === "number" && dias >= 0 && dias <= DIAS_CADUCIDAD_ALERTA;
}

export function esCaducidadCritica(dias) {
  return typeof dias === "number" && dias >= 0 && dias <= DIAS_CADUCIDAD_CRITICO;
}
