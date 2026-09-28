/**
 * Carga compartida de Catálogo + Lotes PEPS + Reabasto.
 * Misma paginación, mismas columnas (sin productos.proveedor, que ya no existe)
 * y el mismo criterio de caducidad / stock PEPS.
 */

import { supabase } from "../supabase";

export const PRODUCTOS_POR_PAGINA = 1000;

/** Columnas que sí existen en `productos`. No incluir `proveedor`. */
export const PRODUCTOS_SELECT_HUB =
  "id,nombre,sku,codigo_barras,categoria,stock,stock_minimo,costo,activo,marca,presentacion,forma_farmaceutica";

export const PRODUCTOS_SELECT_LOTES =
  "id,nombre,sku,codigo_barras,marca,presentacion,forma_farmaceutica,categoria,activo";

/**
 * Ficha de la tabla de Inventario, sin `descripcion` ni `notas`.
 * `select("*")` de todo el catálogo pasa el tope de tiempo o de tamaño y la
 * pantalla se queda en el skeleton.
 */
export const PRODUCTOS_SELECT_INVENTARIO = [
  "id", "nombre", "sku", "codigo_barras",
  "categoria", "subcategoria",
  "stock", "stock_minimo", "costo", "precio",
  "activo", "marca", "presentacion", "forma_farmaceutica",
  "principio_activo", "concentracion", "tipo",
  "ubicacion_texto", "descuento_pct",
  "imagen_url", "imagen_mobile_url",
  "bajo_pedido",
  "denominacion_generica", "denominacion_distintiva",
  "venta_unidad", "unidades_por_caja", "precio_unidad", "stock_unidades",
  "requiere_receta",
].join(",");

/** Misma ficha para vendedor, sin costo. */
export const PRODUCTOS_SELECT_INVENTARIO_CONSULTA = PRODUCTOS_SELECT_INVENTARIO
  .split(",")
  .map((c) => c.trim())
  .filter((c) => c && c !== "costo")
  .join(",");

export const LOTES_POR_PAGINA = 1000;

const LOTES_SELECT_DIRECTO = [
  "id", "producto_id", "numero_lote", "fecha_caducidad", "cantidad_actual",
  "costo_unitario", "activo", "fecha_recepcion",
  "proveedores(id,nombre)",
  "productos(nombre,sku,categoria)",
].join(",");

const LOTES_SELECT_DIRECTO_PLANO = [
  "id", "producto_id", "numero_lote", "fecha_caducidad", "cantidad_actual",
  "costo_unitario", "activo", "fecha_recepcion",
].join(",");

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

export function mensajeErrorSupabase(error) {
  return String(error?.message || error?.details || error?.hint || "");
}

/** PostgREST / Postgres cuando el select pide una columna que no está en la tabla. */
export function columnaInexistenteDeError(error) {
  const msg = mensajeErrorSupabase(error);
  const directa = /column (?:[\w"]+\.)?["']?(\w+)["']? does not exist/i.exec(msg);
  if (directa) return directa[1];
  const cache = /could not find the ['"](\w+)['"] column/i.exec(msg);
  if (cache) return cache[1];
  return null;
}

export function esErrorColumnaInexistente(error) {
  if (!error) return false;
  if (error.code === "42703" || error.code === "PGRST204") return true;
  return columnaInexistenteDeError(error) != null;
}

export function esErrorFuncionInexistente(error) {
  if (!error) return false;
  if (error.code === "PGRST202" || error.code === "42883") return true;
  return /could not find the function|42883|PGRST202/i.test(mensajeErrorSupabase(error));
}

/** Quita del select la columna que Postgres acaba de rechazar. */
export function selectSinColumnaInexistente(select, error) {
  const col = columnaInexistenteDeError(error);
  if (!col) return null;
  const parts = String(select || "").split(",").map((s) => s.trim()).filter(Boolean);
  if (!parts.includes(col) || parts.length < 2) return null;
  return parts.filter((c) => c !== col).join(",");
}

/**
 * La tabla sale del skeleton en cuanto hay filas, o cuando la primera página
 * ya respondió (aunque el catálogo esté vacío o haya fallado).
 */
export function inventarioDebeSalirDelSkeleton({ filas, error, primeraPaginaLista } = {}) {
  if ((filas || []).length > 0) return true;
  if (error) return true;
  return !!primeraPaginaLista;
}

/** Pinta filas crudas hasta que el mapa de lotes existe; después aplica PEPS. */
export function publicarFilasInventario(filas, lotesByProducto) {
  const list = Array.isArray(filas) ? filas : [];
  if (!lotesByProducto) return list;
  return list.map((p) => enriquecerProductoConLotes(
    p,
    lotesByProducto[p.id] || lotesByProducto[String(p.id)] || []
  ));
}

/**
 * Si la tabla ya devolvió filas, esa página alcanza (no hace falta el RPC).
 * Un resultado directo vacío puede ser RLS, no “no hay lotes”: entonces vale
 * la página nueva y, si esa función aún no existe, el RPC completo.
 */
export function resolverCargaLotes({ pagina, directo } = {}) {
  if (directo && !directo.error && (directo.data || []).length > 0) return "directo";
  if (pagina && !pagina.unsupported && !pagina.error) return "pagina";
  return "completo";
}

export async function fetchProductosPaginados({
  select = PRODUCTOS_SELECT_HUB,
  activosSolo = true,
  order = "nombre",
  onPage,
  vigente = () => true,
} = {}) {
  const filas = [];
  let selectActual = select;
  let reintentosColumna = 0;
  for (let desde = 0; ;) {
    if (!vigente()) return { data: filas, error: null, aborted: true };
    let q = supabase
      .from("productos")
      .select(selectActual)
      .order(order)
      .order("id");
    if (activosSolo) q = q.eq("activo", true);
    const { data, error } = await q.range(desde, desde + PRODUCTOS_POR_PAGINA - 1);
    if (error) {
      const sinCol = selectSinColumnaInexistente(selectActual, error);
      if (sinCol && reintentosColumna < 12) {
        selectActual = sinCol;
        reintentosColumna += 1;
        continue;
      }
      onPage?.({ rows: filas.slice(), page: [], error, done: true });
      return { data: filas.length ? filas : null, error };
    }
    const page = data || [];
    filas.push(...page);
    const done = page.length < PRODUCTOS_POR_PAGINA;
    onPage?.({ rows: filas.slice(), page, error: null, done });
    if (done) break;
    desde += PRODUCTOS_POR_PAGINA;
  }
  return { data: filas, error: null };
}

async function paginarLotesDirecto(select) {
  const filas = [];
  for (let desde = 0; ; desde += LOTES_POR_PAGINA) {
    const { data, error } = await supabase
      .from("lotes")
      .select(select)
      .or("activo.is.null,activo.eq.true")
      .order("id")
      .range(desde, desde + LOTES_POR_PAGINA - 1);
    if (error) return { data: [], error };
    const page = data || [];
    filas.push(...page);
    if (page.length < LOTES_POR_PAGINA) break;
  }
  return { data: filas, error: null };
}

async function fetchLotesInventarioDirecto() {
  const rico = await paginarLotesDirecto(LOTES_SELECT_DIRECTO);
  if (!rico.error) return rico;
  // El embed de proveedor/producto a veces no está en el schema cache.
  // Una columna que no existe sí se puede reintentar en plano; un error de
  // permiso o de relación cae al RPC, que sí trae el nombre del proveedor.
  const msg = mensajeErrorSupabase(rico.error);
  const reintentarPlano = esErrorColumnaInexistente(rico.error) || /fecha_recepcion/i.test(msg);
  if (!reintentarPlano) return rico;
  return paginarLotesDirecto(LOTES_SELECT_DIRECTO_PLANO);
}

async function fetchLotesPorRpcPagina(sessionToken) {
  const filas = [];
  let despues = 0;
  for (;;) {
    const { data, error } = await supabase.rpc("empleado_listar_lotes_inventario_pagina", {
      p_session_token: sessionToken,
      p_despues_de: despues,
      p_limite: LOTES_POR_PAGINA,
    });
    if (error) {
      return { data: filas, error, unsupported: esErrorFuncionInexistente(error) };
    }
    const page = filasJson(data);
    filas.push(...page);
    if (page.length < LOTES_POR_PAGINA) return { data: filas, error: null, unsupported: false };
    const next = Number(page[page.length - 1]?.id);
    if (!Number.isFinite(next) || next <= despues) {
      return { data: filas, error: null, unsupported: false };
    }
    despues = next;
  }
}

async function fetchLotesRpcCompleto(sessionToken) {
  const { data, error } = await supabase.rpc("empleado_listar_lotes_inventario", {
    p_session_token: sessionToken,
  });
  if (error) return { data: [], error };
  return { data: filasJson(data), error: null };
}

export async function fetchLotesInventario(sessionToken) {
  if (!sessionToken) return { data: [], error: null };
  const directo = await fetchLotesInventarioDirecto();
  if (resolverCargaLotes({ directo }) === "directo") {
    return { data: directo.data, error: null };
  }
  const pagina = await fetchLotesPorRpcPagina(sessionToken);
  if (resolverCargaLotes({ pagina, directo }) === "pagina") {
    return { data: pagina.data || [], error: null };
  }
  return fetchLotesRpcCompleto(sessionToken);
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
