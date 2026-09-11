/**
 * Recargas (tiempo aire) en metas de vendedora.
 * No son venta de producto (folio VTA), pero sí cuentan en Mi Día,
 * comisiones RRHH y “ventas por empleado”. Solo categoria = recarga;
 * CFE/Sky/etc. no entran. Monto = total_cobrado (en recarga = monto aire).
 */

export function esRecargaCategoria(categoria) {
  return String(categoria || "").trim().toLowerCase() === "recarga";
}

/** Monto que suma a la meta. Ignora filas que no son recarga si traen categoria. */
export function montoRecargaParaMeta(row) {
  if (!row) return 0;
  if (row.categoria != null && !esRecargaCategoria(row.categoria)) return 0;
  const total = Number(row.total_cobrado);
  if (Number.isFinite(total) && total > 0) return total;
  const monto = Number(row.monto_servicio);
  if (Number.isFinite(monto) && monto > 0) return monto;
  // Snapshot midia / RRHH: a veces solo mandamos `total` ya normalizado.
  const legacy = Number(row.total);
  if (Number.isFinite(legacy) && legacy > 0) return legacy;
  return 0;
}

export function sumRecargasParaMeta(rows) {
  return (rows || []).reduce((a, r) => a + montoRecargaParaMeta(r), 0);
}

export function sumarVentasConRecargas(ventasPedidos, rowsRecarga) {
  return (Number(ventasPedidos) || 0) + sumRecargasParaMeta(rowsRecarga);
}

/** Nombre para agrupar en dashboard / RRHH. */
export function nombreAtendidoRecarga(row) {
  if (!row) return "Sin asignar";
  const n =
    row.atendido_por_nombre ||
    row.usuarios?.nombre ||
    row.atendido_por;
  if (n == null || n === "") return "Sin asignar";
  return n;
}

/**
 * Suma montos de recarga al mapa { [nombre]: total }.
 * Mutates `byEmp` and returns it.
 */
export function acumularRecargasEnMapaEmpleado(byEmp, rows) {
  const map = byEmp && typeof byEmp === "object" ? byEmp : {};
  (rows || []).forEach((r) => {
    const monto = montoRecargaParaMeta(r);
    if (monto <= 0) return;
    const k = nombreAtendidoRecarga(r);
    map[k] = (map[k] || 0) + monto;
  });
  return map;
}

/**
 * Para rachas / días cumplidos en Mi Día: suma recargas al mapa día → ventas.
 * Clave YYYY-MM-DD desde created_at (UTC ISO slice, igual que pedidos hoy).
 */
export function acumularRecargasPorDia(ventasPorDia, rows) {
  const map = ventasPorDia instanceof Map ? ventasPorDia : new Map();
  (rows || []).forEach((r) => {
    const monto = montoRecargaParaMeta(r);
    if (monto <= 0 || !r.created_at) return;
    const k = new Date(r.created_at).toISOString().slice(0, 10);
    map.set(k, (map.get(k) || 0) + monto);
  });
  return map;
}
