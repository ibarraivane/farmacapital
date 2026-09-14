/**
 * Auditoría de PVP vs costo.
 *
 * Caso que no se debe repetir: Sedal Rizos Definidos 135 ml se vendía
 * a $61 con costo $9.08. El dueño lo bajó a $20 (~2.2× el costo).
 * Esta regla usa ese 2.2× como techo de higiene / cuidado personal.
 *
 * No aplica cambios. Solo clasifica y sugiere.
 */

import {
  calcPriceFloor,
  classifyProductoMargen,
  roundPrecioVenta,
} from "./preciosReferencia";

/** Techo de recargo (precio / costo) por familia. */
export const TECHO_MARKUP = {
  higiene: 2.2,
  bebidas: 1.6,
  bebe: 1.8,
  impulso: 2.0,
  vitaminas: 2.0,
  material: 2.0,
  disp_med: 1.8,
  med_generico: 2.6,
  med_patente: 1.55,
  med_otc_marca: 1.8,
  sin_clasificar: 2.6,
  sin_costo: 1,
  otro: 2.2,
};

const COSTO_MINIMO_CONFIABLE = 3;
const UTILIDAD_MINIMA_ALERTA = 8;

export function familiaMargen(producto, classif = null) {
  const cls = classif || classifyProductoMargen(producto);
  if (cls.code === "sin_costo") return "sin_costo";
  if (cls.code === "med_generico") return "med_generico";
  if (cls.code === "med_patente") return "med_patente";
  if (cls.code === "med_otc_marca") return "med_otc_marca";
  if (cls.code === "disp_med") return "disp_med";

  const catL = (producto?.categoria || "").toLowerCase();
  const nombre = (producto?.nombre || "").toLowerCase();
  if (catL.includes("hidrat") || catL === "bebidas" || /electrolit|pedialyte|suero oral|oralit/.test(nombre)) {
    return "bebidas";
  }
  if (catL.includes("beb") || /pañal|huggies|nan |enfamil/.test(nombre)) return "bebe";
  if (catL === "abarrotes" || catL === "minisuper") return "impulso";
  if (catL === "suplemento" || catL === "vitaminas" || nombre.includes("vitamina")) return "vitaminas";
  if (catL.includes("botiqu") || /venda|gasa|jeringa|algodon|algodón|guante/.test(nombre)) return "material";
  if (catL === "higiene" || catL === "cuidado personal") return "higiene";
  if (cls.code === "sin_clasificar") return "sin_clasificar";
  return "otro";
}

export function techoMarkupFamilia(familia) {
  return TECHO_MARKUP[familia] || TECHO_MARKUP.otro;
}

function num(v) {
  const n = parseFloat(v);
  return Number.isFinite(n) ? n : 0;
}

/**
 * El CSV de Bodega (y copias) a veces guarda el IMPORTE del renglón
 * en la columna `precio_unitario` y luego `subtotal = ese × cantidad`.
 * Escudo Rosa: 2 pzas, importe $8.96 → unitario $4.48. El $8.96 no es el de una.
 * Si catálogo × qty ≈ "unitario" del CSV, el catálogo es el costo real.
 */
export function csvGuardoImporteComoUnitario(costoCatalogo, precioCsv, cantidad) {
  const c = num(costoCatalogo);
  const t = num(precioCsv);
  const q = num(cantidad);
  if (c <= 0 || t <= 0 || q < 2) return false;
  return Math.abs(c * q - t) <= 0.25 || Math.abs(c * q - t) / t <= 0.03;
}

/** @deprecated usar csvGuardoImporteComoUnitario — el catálogo no está partido. */
export function costoParecePartidoPorCantidad(costoCatalogo, costoTicket, cantidad) {
  return csvGuardoImporteComoUnitario(costoCatalogo, costoTicket, cantidad);
}

/** Última compra = importe de 2/3/4 pzas guardado como si fuera de una. */
export function ultimaPareceImporteDeVariasPiezas(costoCatalogo, ultimaCompra) {
  const c = num(costoCatalogo);
  const u = num(ultimaCompra);
  if (c <= 0 || u <= 0) return false;
  return [2, 3, 4].some((q) => Math.abs(c * q - u) <= 0.25 || Math.abs(c * q - u) / u <= 0.03);
}

/**
 * Unitario real del renglón. Si el CSV puso el importe en "precio_unitario",
 * se parte entre las piezas. No se usa el subtotal inflado (importe × qty).
 */
export function costoUnitarioDeRenglonTicket({
  cantidad,
  precioEtiquetado,
  subtotal,
  costoCatalogo,
} = {}) {
  const qty = num(cantidad) || 1;
  const pu = num(precioEtiquetado);
  const sub = num(subtotal);
  const cat = num(costoCatalogo);
  if (qty >= 2 && cat > 0 && pu > 0 && csvGuardoImporteComoUnitario(cat, pu, qty)) {
    return Math.round((pu / qty) * 100) / 100;
  }
  if (qty >= 2 && pu > 0 && sub > 0 && Math.abs(pu - sub) <= 0.03) {
    return Math.round((sub / qty) * 100) / 100;
  }
  if (pu > 0) return Math.round(pu * 100) / 100;
  if (sub > 0 && qty > 0) return Math.round((sub / qty) * 100) / 100;
  return null;
}

/** Refs de venta usables: descarta matches locos (Similares $92 en una crema de $9). */
export function refsVentaComparablesAuditoria(costo, piso, techoOk, refsVenta = []) {
  const hi = Math.max(techoOk * 2.5, costo * 4, 1);
  const lo = Math.max(costo * 0.8, 1);
  return (refsVenta || [])
    .map((r) => num(r?.precio ?? r))
    .filter((p) => p >= lo && p <= hi);
}

function percentil40(vals) {
  if (!vals.length) return null;
  const s = [...vals].sort((a, b) => a - b);
  if (s.length === 1) return s[0];
  const idx = (s.length - 1) * 0.4;
  const lo = Math.floor(idx);
  const hi = Math.ceil(idx);
  if (lo === hi) return s[lo];
  return s[lo] + (s[hi] - s[lo]) * (idx - lo);
}

/**
 * @param {object} producto
 * @param {object} [opts]
 * @param {number} [opts.ultimaCompra]
 * @param {number} [opts.costoTicket]
 * @param {number} [opts.cantidadTicket]
 * @param {Array<{precio?: number, fuente?: string}>} [opts.refsVenta]
 */
export function auditarMargenProducto(producto, opts = {}) {
  const costo = num(producto?.costo);
  const precio = num(producto?.precio);
  const classif = classifyProductoMargen(producto);
  const familia = familiaMargen(producto, classif);
  const factor = techoMarkupFamilia(familia);
  const piso = costo > 0 ? calcPriceFloor(costo, classif.markup) : null;
  const techoOk = costo > 0 ? roundPrecioVenta(costo * factor) : null;
  const markupPct = costo > 0 && precio > 0 ? Math.round((precio / costo - 1) * 1000) / 10 : null;
  const margenVentaPct = precio > 0 && costo > 0 ? Math.round(((precio - costo) / precio) * 1000) / 10 : null;
  const utilidad = costo > 0 && precio > 0 ? Math.round((precio - costo) * 100) / 100 : null;
  const ultima = num(opts.ultimaCompra);

  const base = {
    familia,
    markupObjetivo: classif.markup,
    markupPct,
    margenVentaPct,
    utilidad,
    piso,
    techoOk,
    sugerido: null,
    accion: "ok",
    motivo: "",
  };

  if (costo <= 0) {
    return { ...base, accion: "revisar_costo", motivo: "Sin costo de compra" };
  }
  if (costo < 2) {
    return { ...base, accion: "revisar_costo", motivo: "Costo < $2 — revisar ticket / pieza vs caja" };
  }
  if (precio <= 0) {
    return { ...base, accion: "sin_precio", motivo: "Sin precio de venta", sugerido: piso };
  }
  if (precio + 0.009 < costo) {
    return {
      ...base,
      accion: "bajo_costo",
      motivo: "Se vende más barato de lo que costó",
      sugerido: piso || techoOk,
    };
  }

  const ticket = num(opts.costoTicket);
  const qtyTicket = num(opts.cantidadTicket);
  const csvEsImporte = csvGuardoImporteComoUnitario(costo, ticket, qtyTicket);
  if (ticket > 0 && !csvEsImporte && ticket > costo * 1.4) {
    return {
      ...base,
      accion: "revisar_costo",
      motivo: `Ticket $${ticket.toFixed(2)} vs costo catálogo $${costo.toFixed(2)} — no bajar el PVP a ciegas`,
      costoSugerido: Math.round(ticket * 100) / 100,
      sugerido: null,
    };
  }

  const costoDudoso =
    ultima > 0 && ultima > costo * 1.4 && !ultimaPareceImporteDeVariasPiezas(costo, ultima);
  if (costoDudoso && precio > (techoOk || 0) + 0.5) {
    return {
      ...base,
      accion: "revisar_costo",
      motivo: `Última compra $${ultima.toFixed(2)} vs costo catálogo $${costo.toFixed(2)} — no bajar el PVP a ciegas`,
      sugerido: null,
    };
  }

  const refsOk = refsVentaComparablesAuditoria(costo, piso, techoOk, opts.refsVenta);
  const anclaMercado = percentil40(refsOk);
  let sugerido = techoOk;
  if (anclaMercado != null) {
    const m = roundPrecioVenta(anclaMercado);
    sugerido = Math.max(piso || 0, Math.min(m, techoOk));
  }

  const claramenteArriba =
    familia === "higiene"
      ? precio > techoOk + 0.5
      : precio > techoOk * 1.3;
  const abismal =
    techoOk != null &&
    claramenteArriba &&
    utilidad >= UTILIDAD_MINIMA_ALERTA &&
    costo >= COSTO_MINIMO_CONFIABLE;

  if (abismal) {
    return {
      ...base,
      accion: "bajar",
      motivo: `PVP ${markupPct}% sobre costo (techo ${familia} ${(factor * 100 - 100).toFixed(0)}%)`,
      sugerido,
      anclaMercado: anclaMercado != null ? Math.round(anclaMercado * 100) / 100 : null,
    };
  }

  return { ...base, sugerido: null, anclaMercado: anclaMercado != null ? Math.round(anclaMercado * 100) / 100 : null };
}

export function esAlertaMargen(audit) {
  return audit?.accion === "bajar" || audit?.accion === "bajo_costo" || audit?.accion === "revisar_costo";
}

export function colorMargenInventario(audit, fallback) {
  if (!audit) return fallback;
  if (audit.accion === "bajar" || audit.accion === "bajo_costo") return "alerta";
  if (audit.accion === "revisar_costo") return "revisar";
  if (audit.margenVentaPct == null) return "neutro";
  if (audit.accion === "ok" && audit.piso && num(audit.piso) > 0) return "ok";
  return "neutro";
}
