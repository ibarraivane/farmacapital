/** Billetes usados para desglose y sugerencias (MXN). */
const BILLETES_MX = [1000, 500, 200, 100, 50, 20, 10, 5];

/**
 * Texto con cantidad de billetes/monedas para entregar como cambio (heurística greedy).
 */
export function desgloseCambioMN(pesos) {
  let n = Math.round(Math.max(0, Number(pesos) || 0) * 100) / 100;
  if (n <= 0) return "";
  const parts = [];
  for (const d of BILLETES_MX) {
    const c = Math.floor((n + 1e-9) / d);
    if (c > 0) {
      parts.push(`${c}×$${d}`);
      n = Math.round((n - c * d) * 100) / 100;
    }
  }
  if (n >= 0.01) parts.push(`$${n.toFixed(2)} (monedas)`);
  return parts.join(" · ");
}

/**
 * Si el cliente paga con billete B (mayor al total), cuánto hay que devolver.
 */
export function sugerenciasPagoCliente(total) {
  const t = Math.round(Math.max(0, Number(total) || 0) * 100) / 100;
  const set = new Set();
  for (const b of BILLETES_MX) {
    if (b >= t) set.add(b);
  }
  let r = Math.ceil(t / 50) * 50;
  if (r >= t) set.add(r);
  r = Math.ceil(t / 100) * 100;
  if (r >= t) set.add(r);
  return [...set]
    .sort((a, b) => a - b)
    .slice(0, 8)
    .map((billete) => ({
      billete,
      cambio: Math.round((billete - t) * 100) / 100,
    }));
}
