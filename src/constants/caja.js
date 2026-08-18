/** Billetes y monedas que se cuentan en apertura y corte. */
export const DENOMINACIONES_CAJA = [1000, 500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5];

export function etiquetaDenominacion(d) {
  return d >= 1 ? `$${d}` : "$0.50";
}

/** Suma piezas × denominación. Claves pueden ser number o string. */
export function totalDesdeDenominaciones(denoms) {
  if (!denoms || typeof denoms !== "object") return 0;
  return DENOMINACIONES_CAJA.reduce((acc, d) => {
    const n = parseInt(denoms[d] ?? denoms[String(d)], 10) || 0;
    return acc + d * Math.max(0, n);
  }, 0);
}

/** Quita ceros; el backend ignora un total tecleado y suma esto. */
export function denominacionesLimpias(denoms) {
  const out = {};
  for (const d of DENOMINACIONES_CAJA) {
    const n = parseInt(denoms?.[d] ?? denoms?.[String(d)], 10) || 0;
    if (n > 0) out[String(d)] = n;
  }
  return out;
}

export function hayPiezasDenominacion(denoms) {
  return DENOMINACIONES_CAJA.some((d) => (parseInt(denoms?.[d], 10) || 0) > 0);
}
