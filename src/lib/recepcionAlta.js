/**
 * Alta desde Recibir: patente 25% / genérico 60% sobre venta.
 * No inventa caducidad ni stock: eso lo pone la caja (MMAA + cantidad).
 */

import { precioDesdeMargen } from "./preciosReferencia";

export const MARGEN_ALTA_PATENTE = 25;
export const MARGEN_ALTA_GENERICO = 60;

export function tipoAltaNormalizado(tipo) {
  const t = String(tipo || "").toLowerCase();
  if (t === "marca" || t === "patente") return "marca";
  return "generico";
}

export function margenAltaRecepcion(tipo) {
  return tipoAltaNormalizado(tipo) === "marca" ? MARGEN_ALTA_PATENTE : MARGEN_ALTA_GENERICO;
}

export function precioSugeridoAltaRecepcion(costo, tipo) {
  return precioDesdeMargen(costo, margenAltaRecepcion(tipo));
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
