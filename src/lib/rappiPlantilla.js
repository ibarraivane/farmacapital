/**
 * Plantilla oficial Rappi Partner: ProductosActualizacion-es.xlsx
 * Columnas editables: Precio, Descuento, Disponibilidad (SI/NO).
 * No hay stock por piezas: SI = hay existencias − colchón.
 */

import * as XLSX from "xlsx";
import partnerActual from "../data/rappiPartnerActual.json";
import {
  digitsEan,
  skuInternoDesdeRappi,
  stockPublicadoRappi,
} from "./rappiCargaCsv";

export const RAPPI_PLANTILLA_PUBLIC_PATH = "/catalogo-propia/ProductosActualizacion-es.xlsx";
export const RAPPI_DISP_SI = "SI";
export const RAPPI_DISP_NO = "NO";

export function catalogoPartnerActual() {
  return partnerActual;
}

export function filasPartnerComoCatalogo(catalogo = partnerActual) {
  return (catalogo?.productos || []).map((p) => ({
    sku_local: p.sku,
    sku: p.sku,
    ean: p.ean,
  }));
}

export function disponibilidadRappiDe(producto, reserva) {
  return stockPublicadoRappi(producto, reserva) > 0 ? RAPPI_DISP_SI : RAPPI_DISP_NO;
}

export function precioPlantillaRappi(producto, fallback) {
  const raw = producto?.precio;
  if (raw != null && raw !== "") {
    const n = Number(raw);
    if (Number.isFinite(n) && n >= 0) return Math.round(n * 100) / 100;
  }
  const f = Number(fallback);
  return Number.isFinite(f) && f >= 0 ? f : 0;
}

export function normalizarDispRappi(value) {
  const s = String(value || "").trim().toUpperCase();
  if (s === RAPPI_DISP_SI || s === "SÍ" || s === "YES" || s === "TRUE") return RAPPI_DISP_SI;
  return RAPPI_DISP_NO;
}

function normHeader(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

export function filasDesdeBufferPlantillaRappi(buffer) {
  const wb = XLSX.read(buffer, { type: "array" });
  const ws = hojaProductos(wb);
  const aoa = XLSX.utils.sheet_to_json(ws, { header: 1, raw: true, defval: "" });
  return parseFilasProductosRappi(aoa);
}

export function parseFilasProductosRappi(aoa) {
  let headerIdx = -1;
  let cols = null;
  const limit = Math.min((aoa || []).length, 20);
  for (let i = 0; i < limit; i += 1) {
    const row = (aoa[i] || []).map(normHeader);
    const sku = row.findIndex((c) => c === "sku");
    const precio = row.findIndex((c) => c === "precio");
    const disp = row.findIndex((c) => c === "disponibilidad");
    const ean = row.findIndex((c) => c === "ean");
    if (sku >= 0 && precio >= 0 && disp >= 0) {
      headerIdx = i;
      cols = {
        sku,
        precio,
        disp,
        ean,
        nombre: row.findIndex((c) => c.includes("nombre del producto")),
      };
      break;
    }
  }
  if (headerIdx < 0 || !cols) {
    throw new Error("No es la plantilla ProductosActualizacion de Rappi (hoja Productos).");
  }
  const filas = [];
  for (let i = headerIdx + 1; i < aoa.length; i += 1) {
    const r = aoa[i] || [];
    const sku = String(r[cols.sku] || "").trim();
    if (!sku || normHeader(sku) === "sku") continue;
    if (!/farmacapital/i.test(sku) && !sku.includes("_") && !sku.includes("-")) continue;
    filas.push({
      excelRow: i + 1,
      sku,
      ean: String(r[cols.ean] ?? "").trim(),
      nombre: cols.nombre >= 0 ? String(r[cols.nombre] || "").trim() : "",
      precio: r[cols.precio],
      disponibilidad: r[cols.disp],
    });
  }
  return filas;
}

function clavesEan(value) {
  const d = digitsEan(value);
  if (d.length < 8) return [];
  const trimmed = d.replace(/^0+/, "") || "0";
  return [...new Set([d, trimmed, d.padStart(13, "0")])];
}

export function indiceProductosParaPartner(productos) {
  const bySku = new Map();
  const byEan = new Map();
  for (const p of productos || []) {
    const sku = skuInternoDesdeRappi(p?.sku);
    if (sku && !bySku.has(sku)) bySku.set(sku, p);
    for (const e of clavesEan(p?.codigo_barras)) {
      if (!byEan.has(e)) byEan.set(e, p);
    }
  }
  return { bySku, byEan };
}

export function productoParaFilaPartner(fila, indice) {
  const sku = skuInternoDesdeRappi(fila?.sku);
  if (sku && indice.bySku.has(sku)) return indice.bySku.get(sku);
  for (const e of clavesEan(fila?.ean)) {
    if (indice.byEan.has(e)) return indice.byEan.get(e);
  }
  return null;
}

export function parcheFilaPartner(fila, producto, reserva) {
  if (!producto) {
    return {
      excelRow: fila.excelRow,
      sku: fila.sku,
      matched: false,
      precio: precioPlantillaRappi(null, fila.precio),
      disponibilidad: normalizarDispRappi(fila.disponibilidad),
    };
  }
  return {
    excelRow: fila.excelRow,
    sku: fila.sku,
    matched: true,
    nombre: producto.nombre || fila.nombre,
    precio: precioPlantillaRappi(producto, fila.precio),
    disponibilidad: disponibilidadRappiDe(producto, reserva),
  };
}

export function parchesPlantillaRappi(filas, productos, reserva) {
  const indice = indiceProductosParaPartner(productos);
  return (filas || []).map((fila) => parcheFilaPartner(fila, productoParaFilaPartner(fila, indice), reserva));
}

export function resumenParchesRappi(parches) {
  let si = 0;
  let no = 0;
  let matched = 0;
  for (const p of parches || []) {
    if (p.matched) matched += 1;
    if (p.disponibilidad === RAPPI_DISP_SI) si += 1;
    else no += 1;
  }
  return { filas: (parches || []).length, matched, si, no };
}

export function nombreArchivoPlantillaRappi(now = new Date()) {
  const ymd = now.toISOString().slice(0, 10);
  return `ProductosActualizacion-FarmaCapital-${ymd}.xlsx`;
}

function hojaProductos(wb) {
  const name = wb.SheetNames.find((n) => /productos/i.test(n))
    || wb.SheetNames.find((n) => n !== "Instrucciones")
    || wb.SheetNames[0];
  const ws = wb.Sheets[name];
  if (!ws) throw new Error("La plantilla no trae la hoja Productos.");
  return ws;
}

export function rellenarBufferPlantillaRappi(buffer, parches) {
  const wb = XLSX.read(buffer, { type: "array", cellStyles: true });
  const ws = hojaProductos(wb);
  for (const p of parches || []) {
    if (!p?.excelRow) continue;
    const k = `K${p.excelRow}`;
    const m = `M${p.excelRow}`;
    const prevK = ws[k] || { t: "n" };
    ws[k] = { ...prevK, t: "n", v: Number(p.precio) || 0 };
    const prevM = ws[m] || { t: "s" };
    ws[m] = { ...prevM, t: "s", v: p.disponibilidad };
  }
  return XLSX.write(wb, { bookType: "xlsx", type: "array", cellStyles: true });
}

export function descargarBufferXlsx(filename, bytes) {
  if (typeof document === "undefined") return;
  const u8 = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  const blob = new Blob([u8], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
