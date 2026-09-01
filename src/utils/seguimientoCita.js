/**
 * C1 — Seguimiento sugerido. No agenda: solo calcula fecha y etiqueta.
 */

export const SEGUIMIENTO_OPCIONES = [
  { dias: 7, label: "7 días" },
  { dias: 14, label: "14 días" },
  { dias: 30, label: "30 días" },
];

/** YYYY-MM-DD a partir de una fecha ISO (consulta) + N días. */
export function fechaSeguimiento(dias, desdeISO) {
  const n = Number(dias);
  if (!Number.isFinite(n) || n <= 0) return null;
  const raw = String(desdeISO || "").slice(0, 10);
  const base = raw && /^\d{4}-\d{2}-\d{2}$/.test(raw)
    ? new Date(`${raw}T12:00:00`)
    : new Date();
  if (Number.isNaN(base.getTime())) return null;
  base.setDate(base.getDate() + n);
  const y = base.getFullYear();
  const m = String(base.getMonth() + 1).padStart(2, "0");
  const d = String(base.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function etiquetaSeguimiento(dias, fecha) {
  if (!dias && !fecha) return "";
  if (fecha) return `Revisión sugerida: ${fecha}${dias ? ` (${dias} días)` : ""}`;
  return `Revisión sugerida en ${dias} días`;
}
