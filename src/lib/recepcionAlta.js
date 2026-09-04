/**
 * Alta desde Recibir: recargo sobre costo (markup).
 * Genérico 60%, marca/patente 25%. No es margen sobre venta.
 * No inventa caducidad ni stock: eso lo pone la caja (MMAA + cantidad).
 */

import { roundPrecioVenta } from "./preciosReferencia";

export const MARKUP_ALTA_PATENTE = 0.25;
export const MARKUP_ALTA_GENERICO = 0.6;

/** @deprecated usar markupAltaRecepcion — era margen sobre venta */
export const MARGEN_ALTA_PATENTE = 25;
export const MARGEN_ALTA_GENERICO = 60;

export function tipoAltaNormalizado(tipo) {
  const t = String(tipo || "").toLowerCase();
  if (t === "marca" || t === "patente") return "marca";
  return "generico";
}

export function markupAltaRecepcion(tipo) {
  return tipoAltaNormalizado(tipo) === "marca" ? MARKUP_ALTA_PATENTE : MARKUP_ALTA_GENERICO;
}

export function margenAltaRecepcion(tipo) {
  return tipoAltaNormalizado(tipo) === "marca" ? MARGEN_ALTA_PATENTE : MARGEN_ALTA_GENERICO;
}

export function precioSugeridoAltaRecepcion(costo, tipo) {
  const c = Number(costo);
  if (!Number.isFinite(c) || c <= 0) return null;
  return roundPrecioVenta(c * (1 + markupAltaRecepcion(tipo)));
}

export function payloadAltaRecepcion({ nombre, codigo, tipo, costo }) {
  const tipoN = tipoAltaNormalizado(tipo);
  const costoN = Number(costo);
  const precio = precioSugeridoAltaRecepcion(costoN, tipoN);
  return {
    nombre: String(nombre || "").trim(),
    codigo_barras: String(codigo || "").replace(/\D/g, "") || null,
    tipo: tipoN,
    categoria: "Otro",
    costo: Number.isFinite(costoN) && costoN > 0 ? costoN : null,
    precio,
    activo: true,
    stock_minimo: 1,
  };
}
