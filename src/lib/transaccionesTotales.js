/**
 * Totales del pie de Transacciones.
 * La suma de ventas no debe incluir cancelados ni ignorar devoluciones aprobadas.
 */

export function filasParaSumaVentas(filas, filtroEstado = "todos") {
  const rows = Array.isArray(filas) ? filas : [];
  if (filtroEstado === "cancelado") {
    return rows.filter((p) => String(p.estado || "").toLowerCase() === "cancelado");
  }
  return rows.filter((p) => String(p.estado || "").toLowerCase() !== "cancelado");
}

/**
 * @param {Array} filas - filas ya filtradas en UI (fecha/tipo/estado/búsqueda)
 * @param {{ total_devuelto?: number|string, n?: number|string, monto_efectivo?: number|string }} devolucionesPeriodo
 * @param {string} filtroEstado
 */
export function resumenTotalesTransacciones(
  filas,
  devolucionesPeriodo = {},
  filtroEstado = "todos"
) {
  const paraSuma = filasParaSumaVentas(filas, filtroEstado);
  const brutas = paraSuma.reduce((a, p) => a + (parseFloat(p.total || 0) || 0), 0);
  const nDevoluciones = parseInt(devolucionesPeriodo?.n || 0, 10) || 0;
  const totalDevuelto =
    filtroEstado === "cancelado"
      ? 0
      : parseFloat(devolucionesPeriodo?.total_devuelto || 0) || 0;
  const netas = brutas - totalDevuelto;
  const byMetodo = paraSuma.reduce((acc, p) => {
    const k = p.metodo_pago || "otro";
    acc[k] = (acc[k] || 0) + (parseFloat(p.total || 0) || 0);
    return acc;
  }, {});
  const promedio = paraSuma.length ? brutas / paraSuma.length : 0;
  return {
    n: paraSuma.length,
    brutas,
    totalDevuelto,
    nDevoluciones,
    netas,
    promedio,
    byMetodo,
    /** Mostrar desglose bruto / devoluciones cuando hay algo que restar. */
    mostrarDevoluciones: filtroEstado !== "cancelado" && (nDevoluciones > 0 || totalDevuelto > 0),
  };
}
