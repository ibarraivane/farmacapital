/** CSV de ventas para análisis (quién, cuándo, hora, producto). Fechas en CDMX. */

import { TZ_FARMACIA, ymdMexico } from "./fecha";
import { pedidoCoincideFiltroTipo } from "../utils/orderChannels";
import { parseRpcJsonArray } from "../utils/rpcJson";

export const VENTAS_CSV_PAGE_SIZE = 1000;
export const VENTAS_CSV_MAX_PAGES = 200;

export const VENTAS_CSV_COLUMNS = [
  { key: "folio", label: "folio" },
  { key: "pedido_id", label: "pedido_id" },
  { key: "fecha", label: "fecha" },
  { key: "hora", label: "hora" },
  { key: "dia_semana", label: "dia_semana" },
  { key: "vendedor", label: "vendedor" },
  { key: "cliente", label: "cliente" },
  { key: "tipo", label: "tipo" },
  { key: "estado", label: "estado" },
  { key: "metodo_pago", label: "metodo_pago" },
  { key: "total_ticket", label: "total_ticket" },
  { key: "sku", label: "sku" },
  { key: "producto", label: "producto" },
  { key: "categoria", label: "categoria" },
  { key: "marca", label: "marca" },
  { key: "cantidad", label: "cantidad" },
  { key: "precio_unitario", label: "precio_unitario" },
  { key: "importe_linea", label: "importe_linea" },
  { key: "costo_lote", label: "costo_lote" },
  { key: "origen", label: "origen" },
];

export function partesFechaMexico(value) {
  if (value == null || value === "") {
    return { fecha: "", hora: "", dia_semana: "" };
  }
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) {
    return { fecha: "", hora: "", dia_semana: "" };
  }
  const fecha = ymdMexico(d);
  const hora = new Intl.DateTimeFormat("es-MX", {
    timeZone: TZ_FARMACIA,
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(d);
  const dia_semana = new Intl.DateTimeFormat("es-MX", {
    timeZone: TZ_FARMACIA,
    weekday: "long",
  }).format(d).toLowerCase();
  return { fecha, hora, dia_semana };
}

function numCsv(value) {
  if (value == null || value === "") return "";
  const n = Number(value);
  if (!Number.isFinite(n)) return "";
  return String(n);
}

export function csvEscape(value) {
  const s = value == null ? "" : String(value);
  return `"${s.replace(/"/g, '""')}"`;
}

export function normalizarFilaExport(row = {}) {
  const { fecha, hora, dia_semana } = partesFechaMexico(row.fecha_venta || row.created_at);
  return {
    folio: row.folio ?? "",
    pedido_id: row.pedido_id == null ? "" : row.pedido_id,
    fecha,
    hora,
    dia_semana,
    vendedor: row.vendedor ?? "",
    cliente: row.cliente ?? "",
    tipo: row.tipo ?? "",
    estado: row.estado ?? "",
    metodo_pago: row.metodo_pago ?? "",
    total_ticket: numCsv(row.total_ticket),
    sku: row.sku ?? "",
    producto: row.producto ?? "",
    categoria: row.categoria ?? "",
    marca: row.marca ?? "",
    cantidad: numCsv(row.cantidad),
    precio_unitario: numCsv(row.precio_unitario),
    importe_linea: numCsv(row.importe_linea),
    costo_lote: numCsv(row.costo_lote),
    origen: row.origen ?? "pedido",
  };
}

export function filaPasaFiltrosExport(row, { tipo = "todos", estado = "todos" } = {}) {
  if (tipo && tipo !== "todos" && !pedidoCoincideFiltroTipo(row.tipo, tipo)) {
    return false;
  }
  if (!estado || estado === "todos") return true;
  const est = String(row.estado || "").toLowerCase();
  if (est === estado) return true;
  if (row.origen === "devolucion" && estado === "completado" && est === "aprobada") {
    return true;
  }
  return false;
}

export function filtrarLineasExport(rows, filtros) {
  return (rows || []).filter((r) => filaPasaFiltrosExport(r, filtros));
}

export function buildVentasAnalisisCsv(rows) {
  const header = VENTAS_CSV_COLUMNS.map((c) => csvEscape(c.label)).join(",");
  const lines = (rows || []).map((raw) => {
    const fila = normalizarFilaExport(raw);
    return VENTAS_CSV_COLUMNS.map((c) => csvEscape(fila[c.key])).join(",");
  });
  return `${[header, ...lines].join("\n")}\n`;
}

export function nombreArchivoVentasAnalisis(now = new Date()) {
  return `ventas_farmacapital_${ymdMexico(now)}.csv`;
}

export async function paginarLineasVentas(fetchPage, {
  pageSize = VENTAS_CSV_PAGE_SIZE,
  maxPages = VENTAS_CSV_MAX_PAGES,
  onProgress,
} = {}) {
  const rows = [];
  let offset = 0;
  const size = Math.max(1, Number(pageSize) || VENTAS_CSV_PAGE_SIZE);
  for (let page = 0; page < maxPages; page += 1) {
    const chunk = await fetchPage({ offset, limit: size });
    const list = Array.isArray(chunk) ? chunk : [];
    rows.push(...list);
    if (typeof onProgress === "function") onProgress(rows.length);
    if (list.length < size) return { rows, truncated: false };
    offset += size;
  }
  return { rows, truncated: true };
}

export function descargarCsvVentas(text, filename) {
  if (typeof document === "undefined") return;
  const blob = new Blob([`\uFEFF${text}`], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename || nombreArchivoVentasAnalisis();
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export function mensajeErrorExportVentas(err) {
  const msg = String(err?.message || err || "");
  if (/empleado_exportar_ventas_lineas|does not exist|schema cache|PGRST202/i.test(msg)) {
    return "Falta aplicar el SQL en Supabase (patch_exportar_ventas_analisis).";
  }
  return msg ? `No se pudo exportar: ${msg}` : "No se pudo exportar.";
}

/** Baja el CSV (todas las páginas del RPC). Usado en Dashboard y Transacciones. */
export async function ejecutarExportVentasAnalisis({
  rpc,
  sessionToken,
  desde = null,
  hasta = null,
  tipo = "todos",
  estado = "todos",
  onProgress,
  now,
} = {}) {
  if (!sessionToken) {
    const err = new Error("Sesión expirada");
    err.code = "no_session";
    throw err;
  }
  const { rows, truncated } = await paginarLineasVentas(
    async ({ offset, limit }) => {
      const { data, error } = await rpc("empleado_exportar_ventas_lineas", {
        p_session_token: sessionToken,
        p_created_desde: desde,
        p_created_hasta: hasta,
        p_offset: offset,
        p_limite: limit,
      });
      if (error) throw error;
      return parseRpcJsonArray(data);
    },
    { onProgress },
  );
  const filtradas = filtrarLineasExport(rows, { tipo, estado });
  if (!filtradas.length) {
    return { ok: false, empty: true, count: 0, truncated };
  }
  const filename = nombreArchivoVentasAnalisis(now);
  descargarCsvVentas(buildVentasAnalisisCsv(filtradas), filename);
  return { ok: true, empty: false, count: filtradas.length, truncated, filename };
}
