/** Historia de compras — pestaña Historia dentro de Recibir.
 *  Arma la tabla producto (filas) × ticket (columnas) y marca, celda por
 *  celda, si esa compra salió más barata, más cara o igual que la anterior.
 */

import { proveedorCompraVisible } from "./ultimaCompra";

/** Centavo de tolerancia: dos costos que difieren por redondeo son el mismo. */
const EPS = 0.005;

export function parseCosto(val) {
  const n = parseFloat(val);
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function etiquetaTicket(t) {
  const quien = proveedorCompraVisible(t?.proveedor) || "Sin tienda";
  return t?.folio ? `${quien} · ${t.folio}` : quien;
}

export function fechaCorta(f) {
  const s = String(f || "").slice(0, 10);
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  return m ? `${m[3]}/${m[2]}` : "";
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
 * @returns {{tickets: [], filas: []}} tickets del más nuevo al más viejo;
 *          cada fila trae `celdas` alineadas a ese mismo orden.
 */
export function construirHistorial(payload) {
  const tickets = [...(payload?.tickets || [])]
    .map((t) => ({
      ...t,
      quien: proveedorCompraVisible(t.proveedor) || "Sin tienda",
      etiqueta: etiquetaTicket(t),
    }))
    .sort((a, b) => {
      const f = String(b.fecha || "").localeCompare(String(a.fecha || ""));
      return f !== 0 ? f : Number(b.id) - Number(a.id);
    });

  const idx = new Map(tickets.map((t, i) => [Number(t.id), i]));
  const porProducto = new Map();

  for (const r of payload?.renglones || []) {
    const productoId = Number(r.producto_id);
    const col = idx.get(Number(r.recepcion_id));
    const costo = parseCosto(r.costo);
    if (!productoId || col === undefined || costo == null) continue;

    let fila = porProducto.get(productoId);
    if (!fila) {
      fila = {
        producto_id: productoId,
        sku: r.sku || "",
        nombre: r.nombre || "",
        celdas: new Array(tickets.length).fill(null),
      };
      porProducto.set(productoId, fila);
    }
    if (!fila.nombre && r.nombre) fila.nombre = r.nombre;
    if (!fila.sku && r.sku) fila.sku = r.sku;
    fila.celdas[col] = { costo, cantidad: Number(r.cantidad) || 0 };
  }

  const filas = [...porProducto.values()];
  for (const fila of filas) {
    // Del más viejo al más nuevo, para que «anterior» sea la compra previa.
    let previo = null;
    for (let i = fila.celdas.length - 1; i >= 0; i -= 1) {
      const celda = fila.celdas[i];
      if (!celda) continue;
      celda.tendencia = tendenciaCosto(celda.costo, previo);
      celda.anterior = previo;
      previo = celda.costo;
    }

    const costos = fila.celdas.filter(Boolean).map((c) => c.costo);
    fila.compras = costos.length;
    fila.minCosto = Math.min(...costos);
    fila.maxCosto = Math.max(...costos);
    fila.ultimoCosto = fila.celdas.find(Boolean)?.costo ?? null;
    fila.piezas = fila.celdas.reduce((s, c) => s + (c?.cantidad || 0), 0);

    // La base: la compra más barata es la que manda en la columna Costo.
    for (const celda of fila.celdas) {
      if (celda) celda.esBase = celda.costo <= fila.minCosto + EPS;
    }
    const colBase = fila.celdas.findIndex((c) => c?.esBase);
    fila.tiendaBase = colBase >= 0 ? tickets[colBase].quien : "";
  }

  filas.sort((a, b) => a.nombre.localeCompare(b.nombre, "es"));
  return { tickets, filas };
}

/** Texto del buscador → filas que lo contienen en nombre o SKU. */
export function filtrarFilas(filas, q) {
  const term = String(q || "").trim().toLowerCase();
  if (!term) return filas;
  return filas.filter(
    (f) =>
      f.nombre.toLowerCase().includes(term)
      || String(f.sku).toLowerCase().includes(term),
  );
}

/** Solo productos comprados más de una vez: los que sí tienen con qué comparar. */
export function soloConComparacion(filas) {
  return filas.filter((f) => f.compras > 1);
}
