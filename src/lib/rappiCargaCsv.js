/**
 * CSV para subir en Rappi Partner → tienda → Subir plantilla.
 * Columnas que ya usamos: SKU, EAN, STOCK, AVAILABLE.
 * PRICE va extra para pegar precios en su plantilla si la pide.
 *
 * STOCK = existencias − colchón (default 2). Receta, controlado y
 * cajas de granel (Aspirina C/40, Alka C/50…) salen en 0. El POS no cambia.
 */

import { productoEsCajaAbiertaMostrador } from "../utils/cajaAbiertaMostrador";

export const RAPPI_SKU_PREFIX = "FARMACAPITALmt_";
export const DEFAULT_RESERVA = 2;
export const RAPPI_CARGA_HEADERS = ["SKU", "EAN", "STOCK", "AVAILABLE", "PRICE"];

export function rappiSkuFromInternal(sku) {
  const inner = String(sku || "").trim();
  if (!inner) return "";
  return `${RAPPI_SKU_PREFIX}${inner.toLowerCase()}`;
}

/** Partner: FARMACAPITALmt_eq-nov032 → eq-nov032 */
export function skuInternoDesdeRappi(value) {
  let s = String(value || "").trim().toLowerCase();
  if (!s) return "";
  const prefix = RAPPI_SKU_PREFIX.toLowerCase();
  if (s.startsWith(prefix)) s = s.slice(prefix.length);
  return s;
}

export function digitsEan(value) {
  return String(value || "").replace(/\D/g, "");
}

export function reservaMostradorDe(valor, fallback = DEFAULT_RESERVA) {
  const n = Number(valor);
  if (!Number.isFinite(n) || n < 0) return fallback;
  return Math.trunc(n);
}

export function productoPublicableRappi(producto) {
  if (!producto) return false;
  if (producto.activo === false) return false;
  if (producto.requiere_receta) return false;
  if (producto.controlado) return false;
  if (productoEsCajaAbiertaMostrador(producto)) return false;
  return true;
}

export function stockPublicadoRappi(producto, reserva = DEFAULT_RESERVA) {
  if (!productoPublicableRappi(producto)) return 0;
  const s = Math.max(0, Math.trunc(Number(producto.stock) || 0));
  const r = Math.max(0, reservaMostradorDe(reserva, DEFAULT_RESERVA));
  return Math.max(s - r, 0);
}

export function precioCsvRappi(precio) {
  if (precio == null || precio === "") return "";
  const n = Number(precio);
  if (!Number.isFinite(n) || n < 0) return "";
  return Number.isInteger(n) ? String(n) : n.toFixed(2);
}

export function filaCargaRappi(producto, reserva = DEFAULT_RESERVA) {
  const sku = rappiSkuFromInternal(producto?.sku);
  if (!sku) return null;
  const stock = stockPublicadoRappi(producto, reserva);
  return {
    SKU: sku,
    EAN: digitsEan(producto?.codigo_barras),
    STOCK: stock,
    AVAILABLE: stock > 0,
    PRICE: precioCsvRappi(producto?.precio),
  };
}

function csvEscape(value) {
  const s = value == null ? "" : String(value);
  if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

export function csvCargaRappi(productos, reserva = DEFAULT_RESERVA) {
  const lines = [RAPPI_CARGA_HEADERS.join(",")];
  for (const p of productos || []) {
    const row = filaCargaRappi(p, reserva);
    if (!row) continue;
    lines.push([
      csvEscape(row.SKU),
      csvEscape(row.EAN),
      row.STOCK,
      row.AVAILABLE ? "true" : "false",
      row.PRICE,
    ].join(","));
  }
  return `${lines.join("\n")}\n`;
}

export function nombreArchivoCargaRappi(now = new Date()) {
  const ymd = now.toISOString().slice(0, 10);
  return `rappi_carga_${ymd}.csv`;
}

export function descargarTextoCsv(filename, text) {
  if (typeof document === "undefined") return;
  const blob = new Blob([`\uFEFF${text}`], { type: "text/csv;charset=utf-8;" });
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
