/**
 * Carga compartida de Catálogo + Lotes PEPS + Reabasto.
 * Misma paginación, mismas columnas (sin productos.proveedor, que ya no existe)
 * y el mismo criterio de caducidad / stock PEPS.
 */

import { supabase } from "../supabase";

export const PRODUCTOS_POR_PAGINA = 1000;

/** Columnas que sí existen en `productos`. No incluir `proveedor`. */
export const PRODUCTOS_SELECT_HUB =
  "id,nombre,sku,codigo_barras,categoria,stock,stock_minimo,costo,activo,marca,presentacion,forma_farmaceutica,principio_activo,denominacion_generica,concentracion";

export const PRODUCTOS_SELECT_LOTES =
  "id,nombre,sku,codigo_barras,marca,presentacion,forma_farmaceutica,categoria,activo,principio_activo,denominacion_generica";

export function fechaCaducidadInvalida(fecha) {
  if (!fecha) return false;
  const y = parseInt(String(fecha).slice(0, 4), 10);
  return !Number.isFinite(y) || y < 1990 || y > 2045;
}

export function minCaducidadLotes(lotes) {
  const conFecha = (lotes || []).filter(
    (l) => l.activo !== false && l.fecha_caducidad && !fechaCaducidadInvalida(l.fecha_caducidad)
  );
  if (!conFecha.length) return null;
  const conStock = conFecha.filter((l) => (Number(l.cantidad_actual) || 0) > 0);
  const pool = conStock.length ? conStock : conFecha;
  return pool.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
}

export function diasParaCaducar(fecha) {
  if (!fecha || fechaCaducidadInvalida(fecha)) return null;
  return Math.ceil((new Date(fecha) - new Date()) / (1000 * 60 * 60 * 24));
}

export function stockDesdeLotes(lotes) {
  return (lotes || [])
    .filter((l) => l.activo !== false)
    .reduce((s, l) => s + (Number(l.cantidad_actual) || 0), 0);
}

export function proveedorDesdeLotes(lotes) {
  const list = (lotes || []).filter((l) => l.activo !== false);
  const conNombre = list.filter((l) => l.proveedores?.nombre || l.proveedor_nombre);
  const pool = (conNombre.length ? conNombre : list)
    .slice()
    .sort((a, b) => {
      const sa = Number(a.cantidad_actual) || 0;
      const sb = Number(b.cantidad_actual) || 0;
      if (sb !== sa) return sb - sa;
      return String(b.fecha_recepcion || b.id || "").localeCompare(String(a.fecha_recepcion || a.id || ""));
    });
  const top = pool[0];
  return (top?.proveedores?.nombre || top?.proveedor_nombre || "").trim();
}

export function filasJson(data) {
  let raw = data;
  if (raw == null) return [];
  if (typeof raw === "string") {
    try { raw = JSON.parse(raw); } catch { return []; }
  }
  if (Array.isArray(raw)) return raw;
  if (Array.isArray(raw?.data)) return raw.data;
  return [];
}

export function productoIdDeLote(l) {
  const raw = l?.producto_id ?? l?.productos?.id;
  const n = typeof raw === "number" ? raw : parseInt(String(raw || ""), 10);
  return Number.isFinite(n) ? n : null;
}

export function agruparLotesPorProducto(lotesRaw) {
  const byProducto = {};
  for (const l of Array.isArray(lotesRaw) ? lotesRaw : []) {
    const pid = productoIdDeLote(l);
    if (pid == null) continue;
    if (!byProducto[pid]) byProducto[pid] = [];
    byProducto[pid].push(l);
  }
  return byProducto;
}

export async function fetchProductosPaginados({
  select = PRODUCTOS_SELECT_HUB,
  activosSolo = true,
  order = "nombre",
} = {}) {
  const filas = [];
  for (let desde = 0; ; desde += PRODUCTOS_POR_PAGINA) {
    let q = supabase
      .from("productos")
      .select(select)
      .order(order)
      .order("id");
    if (activosSolo) q = q.eq("activo", true);
    const { data, error } = await q.range(desde, desde + PRODUCTOS_POR_PAGINA - 1);
    if (error) return { data: null, error };
    filas.push(...(data || []));
    if ((data || []).length < PRODUCTOS_POR_PAGINA) break;
  }
  return { data: filas, error: null };
}

export async function fetchLotesInventario(sessionToken) {
  if (!sessionToken) return { data: [], error: null };
  const { data, error } = await supabase.rpc("empleado_listar_lotes_inventario", {
    p_session_token: sessionToken,
  });
  if (error) return { data: [], error };
  return { data: filasJson(data), error: null };
}

export function enriquecerProductoConLotes(p, lotes) {
  const lotesList = lotes || [];
  const lotesActivos = lotesList.filter((l) => l.activo !== false);
  const lotesConStock = lotesActivos.filter((l) => (Number(l.cantidad_actual) || 0) > 0);
  const stockPeps = stockDesdeLotes(lotesList);
  const minCad = minCaducidadLotes(lotesList);
  const proveedorLote = proveedorDesdeLotes(lotesList);
  return {
    ...p,
    lotes: lotesList,
    lotes_activos: lotesConStock,
    // Solo lotes con piezas cuentan como PEPS. Un lote vacío (qty 0, activo)
    // no debe tapar productos.stock: eso marcaba AGOTADO con mercancía en anaquel.
    stock_peps: lotesConStock.length ? stockPeps : (Number(p.stock) || 0),
    min_caducidad_lotes: minCad,
    diasCaducidad: diasParaCaducar(minCad),
    proveedor: proveedorLote || "",
    sinLotePeps: lotesConStock.length === 0 && (Number(p.stock) || 0) > 0,
  };
}

/** Orden PEPS: ilegibles, sin fecha (stock ciego), luego la caducidad más próxima. */
export function compararLotesPeps(a, b) {
  const rank = (l) => {
    if (fechaCaducidadInvalida(l.fecha_caducidad)) return [0, 0];
    if (!l.fecha_caducidad) return [1, 0];
    return [2, new Date(l.fecha_caducidad).getTime() || 0];
  };
  const aa = rank(a);
  const bb = rank(b);
  return aa[0] - bb[0] || aa[1] - bb[1];
}
