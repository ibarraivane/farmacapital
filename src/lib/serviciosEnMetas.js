/**
 * Pagos de servicio (recargas + CFE/Sky/etc.) en metas de vendedora.
 * No son venta de producto (folio VTA), pero sí cuentan en Mi Día,
 * comisiones RRHH y “ventas por empleado”. Monto = total_cobrado.
 */

export function montoServicioParaMeta(row) {
  if (!row) return 0;
  const total = Number(row.total_cobrado);
  if (Number.isFinite(total) && total > 0) return total;
  const monto = Number(row.monto_servicio);
  if (Number.isFinite(monto) && monto > 0) return monto;
  // Snapshot midia / RRHH: a veces solo mandamos `total` ya normalizado.
  const legacy = Number(row.total);
  if (Number.isFinite(legacy) && legacy > 0) return legacy;
  return 0;
}

export function sumServiciosParaMeta(rows) {
  return (rows || []).reduce((a, r) => a + montoServicioParaMeta(r), 0);
}

export function sumarVentasConServicios(ventasPedidos, rowsServicio) {
  return (Number(ventasPedidos) || 0) + sumServiciosParaMeta(rowsServicio);
}

/** Nombre para agrupar en dashboard / RRHH. */
export function nombreAtendidoServicio(row) {
  if (!row) return "Sin asignar";
  const n =
    row.atendido_por_nombre ||
    row.usuarios?.nombre ||
    row.atendido_por;
  if (n == null || n === "") return "Sin asignar";
  return n;
}

/**
 * Suma montos de servicio al mapa { [nombre]: total }.
 * Mutates `byEmp` and returns it.
 */
export function acumularServiciosEnMapaEmpleado(byEmp, rows) {
  const map = byEmp && typeof byEmp === "object" ? byEmp : {};
  (rows || []).forEach((r) => {
    const monto = montoServicioParaMeta(r);
    if (monto <= 0) return;
    const k = nombreAtendidoServicio(r);
    map[k] = (map[k] || 0) + monto;
  });
  return map;
}

/**
 * Para rachas / días cumplidos en Mi Día: suma servicios al mapa día → ventas.
 * Clave YYYY-MM-DD desde created_at (UTC ISO slice, igual que pedidos hoy).
 */
export function acumularServiciosPorDia(ventasPorDia, rows) {
  const map = ventasPorDia instanceof Map ? ventasPorDia : new Map();
  (rows || []).forEach((r) => {
    const monto = montoServicioParaMeta(r);
    if (monto <= 0 || !r.created_at) return;
    const k = new Date(r.created_at).toISOString().slice(0, 10);
    map.set(k, (map.get(k) || 0) + monto);
  });
  return map;
}

/** Etiqueta de piso sin montos (lista Mi Día). */
export function labelServicioTicket(row) {
  if (!row) return "Servicio";
  const cat = String(row.categoria || "").trim().toLowerCase();
  const prov = String(row.proveedor || "").trim();
  if (cat === "recarga") return prov ? `Recarga ${prov}` : "Recarga";
  if (prov) return `Pago ${prov}`;
  return "Pago de servicio";
}

/**
 * Une pedidos + servicios del turno para la lista de tickets.
 * Sin montos. `ticketsProducto` se usa en KPIs de cruzada / prod.
 */
export function ticketsTurnoDesdePedidosYServicios(pedTurno, srvTurno) {
  const fromPed = [...(pedTurno || [])].map((p) => ({
    id: `ped-${p.id}`,
    folioLabel: null,
    pedidoId: p.id,
    created_at: p.created_at,
    conCliente: p.cliente_id != null,
    esServicio: false,
    // Campos internos para reimpresión (no se muestran en la lista de Mi Día).
    total: p.total != null ? Number(p.total) : null,
    metodoPago: p.metodo_pago || null,
    clienteId: p.cliente_id ?? null,
    items: (p.pedido_items || []).map((it) => ({
      cantidad: it.cantidad || 0,
      nombre: String(it.productos?.nombre || it.productos?.categoria || "Artículo").trim() || "Artículo",
      lote: it.lotes?.numero_lote || null,
    })),
  }));
  const fromSrv = [...(srvTurno || [])].map((s) => ({
    id: `srv-${s.id}`,
    folioLabel: s.folio || `SRV-${s.id}`,
    pedidoId: null,
    created_at: s.created_at,
    conCliente: false,
    esServicio: true,
    total: s.total_cobrado != null ? Number(s.total_cobrado) : null,
    metodoPago: s.metodo_pago || null,
    servicio: s,
    items: [{ cantidad: 1, nombre: labelServicioTicket(s), lote: null }],
  }));
  return [...fromPed, ...fromSrv].sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );
}

/** Acepta srv_* (nuevo) o rec_* (patch viejo solo-recargas). */
export function filasServicioDesdeSnapshot(snap, ambito) {
  if (!snap || typeof snap !== "object") return [];
  if (ambito === "turno") {
    return snap.srv_turno || snap.rec_turno || [];
  }
  return snap.srv_mes || snap.rec_mes || [];
}
