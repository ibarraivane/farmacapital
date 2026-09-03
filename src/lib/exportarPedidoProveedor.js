/**
 * Exporta reabasto:
 * 1. Reporte_reabasto — agotados, stock bajo y asignación por surtidor.
 * 2. Pedido_Levic_portal — plantilla del portal (código de barras + piezas).
 * 3. Pedidos_por_surtidor — una hoja por surtidor (El Surtidor, Exprezo, …).
 */

import * as XLSX from "xlsx";
import { buildReporteReabastoSheets } from "./reporteReabasto";

export const esLevic = (orden) =>
  String(orden.fuente || "").toLowerCase() === "levic" ||
  /levic/i.test(orden.proveedor || "");

function fechaArchivo() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}`;
}

function barcodeDe(p) {
  const raw = String(p.codigo_barras || p.barcode || "").replace(/\D/g, "");
  return raw || "";
}

function precioDe(p) {
  return Number(p.precioUnit ?? p.mejorCompra?.precio ?? p.mejorTienda?.precio ?? p.costo ?? 0);
}

const COLS_PEDIDO = [
  { wch: 22 }, { wch: 16 }, { wch: 14 }, { wch: 42 },
  { wch: 8 }, { wch: 12 }, { wch: 12 }, { wch: 40 },
];

const HEADERS_PEDIDO = [
  "Pedir en", "Código de barras", "SKU", "Producto", "Piezas", "Costo unit.", "Total", "Nota",
];

/** Hoja idéntica a /Downloads/plantilla_pedido.xlsx de Levic. */
export function hojaPlantillaLevic(productos) {
  const aoa = [
    [null, "FORMATO DE PEDIDO"],
    ["CÓDIGO DE BARRAS", "No DE PIEZAS"],
  ];
  const sinCodigo = [];
  for (const p of productos) {
    const ean = barcodeDe(p);
    if (!ean) {
      sinCodigo.push(p);
      continue;
    }
    aoa.push([ean, p.cantidadPedida]);
  }
  return { aoa, sinCodigo };
}

export function nombreHojaExcel(label, used = new Set()) {
  let base = String(label || "Surtidor")
    .replace(/[\\/*?:[\]]/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 31);
  if (!base) base = "Surtidor";
  let name = base;
  let i = 2;
  while (used.has(name)) {
    const suffix = ` ${i}`;
    name = `${base.slice(0, Math.max(1, 31 - suffix.length))}${suffix}`;
    i += 1;
  }
  used.add(name);
  return name;
}

function filaPedidoDe(orden, p, notaExtra) {
  const unit = precioDe(p);
  return [
    orden.proveedor,
    barcodeDe(p) || "",
    p.sku || "",
    p.nombre || "",
    p.cantidadPedida,
    Number(unit.toFixed(2)),
    Number((unit * p.cantidadPedida).toFixed(2)),
    notaExtra || p.motivoAgrupado || "",
  ];
}

export function buildPedidosPorSurtidorSheets(ordenes, levicSinCodigo = []) {
  const used = new Set();
  const sheets = [];
  const list = Array.isArray(ordenes) ? ordenes : [];

  const resumen = [
    ["Pedidos de reabasto — una hoja por surtidor"],
    ["Levic: el archivo Pedido_Levic_portal.xlsx se sube al portal. Aquí va la lista de lectura."],
    [],
    ["Pedir en", "Líneas", "Total estimado"],
    ...list.map((orden) => [
      orden.proveedor,
      (orden.productos || []).length,
      Number((orden.total || 0).toFixed(2)),
    ]),
  ];
  if (levicSinCodigo.length) {
    resumen.push(["Levic (falta código)", levicSinCodigo.length, ""]);
  }
  sheets.push({ name: nombreHojaExcel("Resumen", used), aoa: resumen });

  for (const orden of list) {
    const filas = (orden.productos || []).map((p) => filaPedidoDe(orden, p));
    sheets.push({
      name: nombreHojaExcel(orden.proveedor, used),
      aoa: [HEADERS_PEDIDO, ...filas],
    });
  }

  if (levicSinCodigo.length) {
    const filas = levicSinCodigo.map((p) =>
      filaPedidoDe(
        { proveedor: "Levic (falta código)" },
        p,
        "No entra al portal de Levic: no tiene código de barras"
      )
    );
    sheets.push({
      name: nombreHojaExcel("Levic falta código", used),
      aoa: [HEADERS_PEDIDO, ...filas],
    });
  }

  return sheets;
}

function appendSheets(wb, sheets) {
  for (const sheet of sheets) {
    const ws = XLSX.utils.aoa_to_sheet(sheet.aoa);
    if (sheet.aoa?.[0]?.[0] === HEADERS_PEDIDO[0]) ws["!cols"] = COLS_PEDIDO;
    XLSX.utils.book_append_sheet(wb, ws, sheet.name);
  }
}

function descargarLibro(wb, nombre) {
  const out = XLSX.write(wb, { bookType: "xlsx", type: "array" });
  const blob = new Blob([out], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = nombre;
  a.click();
  URL.revokeObjectURL(a.href);
}

function bajarConPausa(fn, ms) {
  return new Promise((resolve) => {
    fn();
    setTimeout(resolve, ms);
  });
}

/** Archivo 1: el que se sube a levicventas.mx. Solo 2 columnas. */
export function descargarPlantillaPortalLevic(orden) {
  const { aoa } = hojaPlantillaLevic(orden.productos);
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet(aoa);
  ws["!cols"] = [{ wch: 22 }, { wch: 14 }];
  XLSX.utils.book_append_sheet(wb, ws, "Hoja1");
  descargarLibro(wb, `Pedido_Levic_portal_${fechaArchivo()}.xlsx`);
  return hojaPlantillaLevic(orden.productos).sinCodigo;
}

function descargarPedidosPorSurtidor(ordenes, levicSinCodigo) {
  const sheets = buildPedidosPorSurtidorSheets(ordenes, levicSinCodigo);
  const tieneLineas = sheets.some((s) => s.name !== "Resumen" && (s.aoa?.length || 0) > 1);
  if (!tieneLineas) return false;
  const wb = XLSX.utils.book_new();
  appendSheets(wb, sheets);
  descargarLibro(wb, `Pedidos_por_surtidor_${fechaArchivo()}.xlsx`);
  return true;
}

export function descargarReporteReabasto(filas) {
  const byName = buildReporteReabastoSheets(filas);
  const wb = XLSX.utils.book_new();
  const cols = [
    { wch: 12 }, { wch: 42 }, { wch: 14 }, { wch: 16 },
    { wch: 8 }, { wch: 8 }, { wch: 8 }, { wch: 18 }, { wch: 12 }, { wch: 36 },
  ];
  for (const [name, aoa] of Object.entries(byName)) {
    const ws = XLSX.utils.aoa_to_sheet(aoa);
    if (name !== "Resumen") ws["!cols"] = cols;
    XLSX.utils.book_append_sheet(wb, ws, name);
  }
  descargarLibro(wb, `Reporte_reabasto_${fechaArchivo()}.xlsx`);
}

/**
 * Baja:
 * - Pedido_Levic_portal_…xlsx  → se sube al portal (si hay Levic)
 * - Pedidos_por_surtidor_…xlsx → una hoja por surtidor
 */
export async function descargarPedidosWorkbook(ordenes) {
  const list = ordenes || [];
  const levic = list.find(esLevic);
  let levicSin = [];

  if (levic && levic.productos?.length) {
    const { aoa, sinCodigo } = hojaPlantillaLevic(levic.productos);
    levicSin = sinCodigo;
    if (aoa.length > 2) {
      const wb = XLSX.utils.book_new();
      const ws = XLSX.utils.aoa_to_sheet(aoa);
      ws["!cols"] = [{ wch: 22 }, { wch: 14 }];
      XLSX.utils.book_append_sheet(wb, ws, "Hoja1");
      await bajarConPausa(
        () => descargarLibro(wb, `Pedido_Levic_portal_${fechaArchivo()}.xlsx`),
        400
      );
    }
  }

  descargarPedidosPorSurtidor(list, levicSin);
}

/** Un solo archivo: Levic = portal; el resto = hoja de ese surtidor. */
export function descargarPedidoTienda(orden) {
  if (esLevic(orden)) {
    descargarPlantillaPortalLevic(orden);
    return;
  }
  descargarPedidosPorSurtidor([orden], []);
}
