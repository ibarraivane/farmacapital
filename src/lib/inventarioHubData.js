/**
 * Carga compartida de Catálogo + Lotes PEPS + Reabasto.
 * Misma paginación, mismas columnas (sin productos.proveedor, que ya no existe)
 * y el mismo criterio de caducidad / stock PEPS.
 */

import { supabase } from "../supabase";
import { aplicarModoCatalogo } from "./catalogoConsulta";

export const PRODUCTOS_POR_PAGINA = 1000;

/** Columnas que sí existen en `productos`. No incluir `proveedor`. */
export const PRODUCTOS_SELECT_HUB =
  "id,nombre,sku,codigo_barras,categoria,stock,stock_minimo,costo,activo,marca,presentacion,forma_farmaceutica";

export const PRODUCTOS_SELECT_LOTES =
  "id,nombre,sku,codigo_barras,marca,presentacion,forma_farmaceutica,categoria,activo";

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

/**
 * Número que pinta la columna Stock: suma de lotes activos (stock_peps).
 * productos.stock puede ir adelante (Afrín: la celda dice 2 y el input abría 4).
 */
export function stockVisibleInventario(p) {
  const raw = p?.stock_peps != null && p?.stock_peps !== "" ? p.stock_peps : p?.stock;
  const n = Number(raw);
  if (!Number.isFinite(n)) return 0;
  return Math.trunc(n);
}

/**
 * adjust_stock_secure resta contra productos.stock, no contra los lotes de la celda.
 * Para que el anaquel quede en `deseado`, el absoluto que se manda compensa ese desfase.
 */
export function stockObjetivoAjusteInline(producto, deseado) {
  const col = Number(producto?.stock);
  const columna = Number.isFinite(col) ? Math.trunc(col) : 0;
  const visible = stockVisibleInventario(producto);
  const want = Number(deseado);
  const objetivoVisible = Number.isFinite(want) ? Math.trunc(want) : visible;
  return columna + (objetivoVisible - visible);
}

/** Lote que representa el proveedor visible en Inventario (más piezas, luego el más reciente). */
export function loteObjetivoProveedor(lotes) {
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
  return pool[0] || null;
}

export function proveedorDesdeLotes(lotes) {
  const top = loteObjetivoProveedor(lotes);
  return (top?.proveedores?.nombre || top?.proveedor_nombre || "").trim();
}

/**
 * `productos.proveedor` no existe. Quitar esa clave del patch de
 * `admin_editar_producto` para no tumbar el resto de la ficha.
 */
export function patchProductoSinColumnaProveedor(patch) {
  if (!patch || typeof patch !== "object" || Array.isArray(patch)) return patch;
  if (!Object.prototype.hasOwnProperty.call(patch, "proveedor")) return patch;
  const next = { ...patch };
  delete next.proveedor;
  return next;
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

/** Postgres cortó la consulta (statement_timeout / lock_timeout). */
export function esTimeoutPostgres(msg) {
  return /statement timeout|lock timeout|canceling statement/i.test(String(msg || ""));
}

export function mensajeErrorGuardadoInventario(error) {
  const msg = error?.message || (typeof error === "string" ? error : "");
  if (esTimeoutPostgres(msg)) {
    return "No se pudo guardar: la base estaba ocupada. Vuelve a intentar.";
  }
  return msg || "No se pudo guardar.";
}

export function rpcPostgresNoExiste(error) {
  const msg = `${error?.message || ""} ${error?.details || ""} ${error?.hint || ""}`;
  const code = String(error?.code || "");
  return code === "PGRST202" || /could not find the function|schema cache|does not exist/i.test(msg);
}

/** Respuesta de empleado_listar_lotes_inventario_pagina. */
export function paginaLotesDesdeRpc(data) {
  let raw = data;
  if (typeof raw === "string") {
    try { raw = JSON.parse(raw); } catch { return { filas: [], hayMas: false }; }
  }
  if (Array.isArray(raw)) return { filas: raw, hayMas: false };
  if (!raw || typeof raw !== "object") return { filas: [], hayMas: false };
  const filas = Array.isArray(raw.filas) ? raw.filas : [];
  return { filas, hayMas: raw.hay_mas === true };
}

const LOTES_POR_PAGINA = 500;
const LOTES_PAGINAS_MAX = 40;

async function fetchLotesInventarioEntero(sessionToken) {
  const { data, error } = await supabase.rpc("empleado_listar_lotes_inventario", {
    p_session_token: sessionToken,
  });
  if (error) return { data: [], error };
  return { data: filasJson(data), error: null };
}

/**
 * Una página por llamada. El RPC que devolvía todos los lotes en un JSON
 * se pasaba de los 8 s y cancelaba el guardado del precio en la misma sesión.
 */
export async function fetchLotesInventario(sessionToken) {
  if (!sessionToken) return { data: [], error: null };
  const filas = [];
  for (let pagina = 0; pagina < LOTES_PAGINAS_MAX; pagina += 1) {
    const offset = pagina * LOTES_POR_PAGINA;
    const { data, error } = await supabase.rpc("empleado_listar_lotes_inventario_pagina", {
      p_session_token: sessionToken,
      p_offset: offset,
      p_limite: LOTES_POR_PAGINA,
    });
    if (error) {
      if (pagina === 0 && rpcPostgresNoExiste(error)) return fetchLotesInventarioEntero(sessionToken);
      return { data: filas, error };
    }
    const page = paginaLotesDesdeRpc(data);
    filas.push(...page.filas);
    if (!page.hayMas || page.filas.length === 0) break;
  }
  return { data: filas, error: null };
}

/** Reintenta solo si Postgres canceló por tiempo. Un error de datos no se repite. */
export async function ejecutarConReintentoTimeout(run, { intentos = 2, esperaMs = 600, dormir } = {}) {
  const pausa = dormir || ((ms) => new Promise((resolve) => { setTimeout(resolve, ms); }));
  let last = { error: null };
  const veces = Math.max(1, intentos);
  for (let i = 0; i < veces; i += 1) {
    last = await run();
    const msg = last?.error?.message || "";
    if (!last?.error || !esTimeoutPostgres(msg) || i === veces - 1) return last;
    await pausa(esperaMs);
  }
  return last;
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
  incluirVitrina = false,
} = {}) {
  const filas = [];
  for (let desde = 0; ; desde += PRODUCTOS_POR_PAGINA) {
    let q = supabase
      .from("productos")
      .select(select)
      .order(order)
      .order("id");
    if (activosSolo) q = q.eq("activo", true);
    if (!incluirVitrina) q = aplicarModoCatalogo(q, "anaquel");
    const { data, error } = await q.range(desde, desde + PRODUCTOS_POR_PAGINA - 1);
    if (error) return { data: null, error };
    filas.push(...(data || []));
    if ((data || []).length < PRODUCTOS_POR_PAGINA) break;
  }
  return { data: filas, error: null };
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
