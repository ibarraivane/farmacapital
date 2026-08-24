/** Historia de compras — pestaña Historia dentro de Recibir.
 *  Filas = productos, columnas = FECHAS de compra. Dentro de cada celda va
 *  el precio y con quién se compró ese día, porque en un mismo día se puede
 *  haber comprado el mismo producto en varias tiendas.
 */

import { proveedorCompraVisible } from "./ultimaCompra";

/** Centavo de tolerancia: dos costos que difieren por redondeo son el mismo. */
const EPS = 0.005;

export function parseCosto(val) {
  const n = parseFloat(val);
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function fechaCorta(f) {
  const s = String(f || "").slice(0, 10);
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  return m ? `${m[3]}/${m[2]}/${m[1].slice(2)}` : "";
}

/** Compara contra la compra anterior de ESE producto, no contra la columna vecina. */
export function tendenciaCosto(costo, anterior) {
  if (costo == null) return null;
  if (anterior == null) return "primera";
  if (costo < anterior - EPS) return "baja";
  if (costo > anterior + EPS) return "sube";
  return "igual";
}

/**
 * @param payload {{tickets: [], renglones: []}} tal cual lo devuelve recepcion_historial
 * @returns {{fechas: [], filas: []}} fechas de la más nueva a la más vieja;
 *          cada fila trae `celdas` alineadas a ese mismo orden.
 */
export function construirHistorial(payload) {
  const tickets = new Map();
  for (const t of payload?.tickets || []) {
    tickets.set(Number(t.id), {
      id: Number(t.id),
      fecha: String(t.fecha || "").slice(0, 10),
      tienda: proveedorCompraVisible(t.proveedor) || "Sin tienda",
      folio: t.folio || "",
    });
  }

  // Una columna por día, de la más reciente a la más vieja.
  const fechas = [...new Set([...tickets.values()].map((t) => t.fecha))]
    .filter(Boolean)
    .sort((a, b) => b.localeCompare(a));
  const idx = new Map(fechas.map((f, i) => [f, i]));

  const porProducto = new Map();
  for (const r of payload?.renglones || []) {
    const productoId = Number(r.producto_id);
    const ticket = tickets.get(Number(r.recepcion_id));
    const precio = parseCosto(r.costo);
    if (!productoId || !ticket || precio == null) continue;
    const col = idx.get(ticket.fecha);
    if (col === undefined) continue;

    let fila = porProducto.get(productoId);
    if (!fila) {
      fila = {
        producto_id: productoId,
        sku: r.sku || "",
        nombre: r.nombre || "",
        celdas: new Array(fechas.length).fill(null),
      };
      porProducto.set(productoId, fila);
    }
    if (!fila.nombre && r.nombre) fila.nombre = r.nombre;
    if (!fila.sku && r.sku) fila.sku = r.sku;

    if (!fila.celdas[col]) fila.celdas[col] = { fecha: ticket.fecha, compras: [] };
    fila.celdas[col].compras.push({
      precio,
      tienda: ticket.tienda,
      folio: ticket.folio,
      cantidad: Number(r.cantidad) || 0,
    });
  }

  const filas = [...porProducto.values()];
  for (const fila of filas) {
    for (const celda of fila.celdas) {
      if (!celda) continue;
      // La más barata del día manda: es la que arriba en la celda y la que
      // se compara contra el día anterior.
      celda.compras.sort((a, b) => a.precio - b.precio || a.tienda.localeCompare(b.tienda, "es"));
      celda.mejor = celda.compras[0].precio;
      celda.tienda = celda.compras[0].tienda;
      celda.cantidad = celda.compras.reduce((s, c) => s + c.cantidad, 0);
      celda.tiendas = celda.compras.length;
    }

    // Del día más viejo al más nuevo, para que «anterior» sea la compra previa.
    let previo = null;
    for (let i = fila.celdas.length - 1; i >= 0; i -= 1) {
      const celda = fila.celdas[i];
      if (!celda) continue;
      celda.tendencia = tendenciaCosto(celda.mejor, previo);
      celda.anterior = previo;
      previo = celda.mejor;
    }

    const conDato = fila.celdas.filter(Boolean);
    fila.dias = conDato.length;
    fila.compras = conDato.reduce((s, c) => s + c.compras.length, 0);
    fila.minCosto = Math.min(...conDato.map((c) => c.mejor));
    fila.maxCosto = Math.max(...conDato.map((c) => c.mejor));
    fila.ultimoCosto = conDato[0].mejor;
    fila.piezas = conDato.reduce((s, c) => s + c.cantidad, 0);

    // La base: la compra más barata es la que manda en la columna Costo.
    for (const celda of conDato) {
      celda.esBase = celda.mejor <= fila.minCosto + EPS;
    }
    const base = fila.celdas.find((c) => c?.esBase);
    fila.tiendaBase = base ? base.tienda : "";
    fila.fechaBase = base ? base.fecha : "";
  }

  filas.sort((a, b) => a.nombre.localeCompare(b.nombre, "es"));
  return { fechas, filas };
}

/** Texto del buscador → filas que lo contienen en nombre, SKU o tienda. */
export function filtrarFilas(filas, q) {
  const term = String(q || "").trim().toLowerCase();
  if (!term) return filas;
  return filas.filter(
    (f) =>
      f.nombre.toLowerCase().includes(term)
      || String(f.sku).toLowerCase().includes(term)
      || f.celdas.some((c) => c?.compras.some((x) => x.tienda.toLowerCase().includes(term))),
  );
}

/** Solo productos comprados en más de un día: los que sí tienen con qué comparar. */
export function soloConComparacion(filas) {
  return filas.filter((f) => f.dias > 1);
}
