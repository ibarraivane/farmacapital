/** Compensación oficial de Mercado Pago por recarga / pago de servicio (Point). */
export const COMPENSACION_MP_TASA = 0.01;

export function money2(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.round(x * 100) / 100;
}

/** 1% del monto recargado. Entra al saldo MP, no al cajón. */
export function compensacionMpDe(montoServicio) {
  const n = money2(montoServicio);
  if (n <= 0) return 0;
  return money2(n * COMPENSACION_MP_TASA);
}

/** Lo que sale del saldo MP al fondear la recarga (débito bruto). */
export function costoLiquidacionDe(montoServicio) {
  const n = money2(montoServicio);
  return n > 0 ? n : 0;
}

export function utilidadServicio({ comision = 0, compensacionMp = 0 } = {}) {
  return money2(money2(comision) + money2(compensacionMp));
}

/** Si el API aún no manda compensacion_mp, se estima al 1%. */
export function compensacionMpDeFila(row) {
  if (!row) return 0;
  if (row.compensacion_mp != null && row.compensacion_mp !== "") {
    const n = money2(row.compensacion_mp);
    if (Number.isFinite(n)) return n;
  }
  return compensacionMpDe(row.monto_servicio);
}
