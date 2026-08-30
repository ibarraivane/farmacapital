/**
 * Referencias de venta en línea (Rappi).
 * El súper se muestra; el sugerido usa farmacias Rappi + Del Ahorro / Similares.
 */

import {
  FUENTES_VENTA,
  calcPrecioSugeridoVenta,
  esActualizacionBot,
  instanteDeRef,
  refsDeFuentes,
} from "./preciosReferencia";
import { diagnosticoRefRappi } from "./monitorPrecios/unidadVenta";

export const FUENTES_RAPPI_FARMACIA = [
  "rappi_gdl",
  "rappi_farmatodo",
  "rappi_benavides",
  "rappi_otros",
];
export const FUENTES_RAPPI_SUPER = ["rappi_super"];
export const FUENTES_RAPPI = [...FUENTES_RAPPI_FARMACIA, ...FUENTES_RAPPI_SUPER];
export const FUENTES_SUGERIDO_RAPPI = [...FUENTES_VENTA, ...FUENTES_RAPPI_FARMACIA];

export const COL_LABELS_RAPPI = {
  producto: "Producto",
  tuVenta: "Tu venta",
  margen: "Margen %",
  rappi_gdl: "GDL",
  rappi_farmatodo: "Farmatodo",
  rappi_benavides: "Benavides",
  rappi_otros: "Otras farm.",
  rappi_super: "Súper",
  calle: "Calle",
  sugerido: "Sugerido",
  nota: "Nota",
  accion: "Acción",
};

export function diagnosticoCeldaRappi(producto, refRow) {
  if (!refRow || !(parseFloat(refRow.precio) > 0)) return null;
  return diagnosticoRefRappi(producto, refRow);
}

export function refsRappiUsables(producto, refsMap) {
  const out = { ...(refsMap || {}) };
  for (const id of FUENTES_RAPPI) {
    const row = out[id];
    if (!row) continue;
    if (!diagnosticoRefRappi(producto, row).ok) delete out[id];
  }
  return out;
}

export function calcPrecioSugeridoRappi(producto, refsMap) {
  const packs = FUENTES_RAPPI.filter((id) => {
    const row = refsMap?.[id];
    return row && parseFloat(row.precio) > 0 && !diagnosticoRefRappi(producto, row).ok;
  }).length;
  const out = calcPrecioSugeridoVenta(producto, refsRappiUsables(producto, refsMap), FUENTES_SUGERIDO_RAPPI);
  if (packs && !out.sugerido) {
    return {
      ...out,
      nota: "Rappi trajo packs u otro empaque. No sirven para esta presentación.",
    };
  }
  if (packs && out.nota) {
    return {
      ...out,
      nota: `${out.nota} (${packs} de Rappi son otro empaque.)`,
    };
  }
  return out;
}

export function precioCalleDe(refsMap) {
  const vals = Object.values(refsDeFuentes(refsMap, FUENTES_VENTA));
  if (!vals.length) return null;
  return Math.min(...vals);
}

export function precioFarmaciaRappiMin(producto, refsMap) {
  const mapa = refsDeFuentes(refsRappiUsables(producto, refsMap), FUENTES_RAPPI_FARMACIA);
  const vals = Object.values(mapa);
  if (!vals.length) return null;
  return Math.min(...vals);
}

export function tieneRefRappi(refsMap) {
  return FUENTES_RAPPI.some((id) => {
    const n = parseFloat(refsMap?.[id]?.precio);
    return Number.isFinite(n) && n > 0;
  });
}

export function tieneRefRappiComparable(producto, refsMap) {
  return FUENTES_RAPPI.some((id) => diagnosticoRefRappi(producto, refsMap?.[id] || {}).ok);
}

export function tienePackRappiDistinto(producto, refsMap) {
  return FUENTES_RAPPI.some((id) => {
    const row = refsMap?.[id];
    if (!row || !(parseFloat(row.precio) > 0)) return false;
    return !diagnosticoRefRappi(producto, row).ok;
  });
}

export function instanteBotRappiDe(refsMap) {
  let best = null;
  for (const id of FUENTES_RAPPI) {
    const row = refsMap?.[id];
    if (!esActualizacionBot(row)) continue;
    const t = instanteDeRef(row);
    if (t != null && (best == null || t > best)) best = t;
  }
  return best;
}

export function parseProgresoBackfill(valor) {
  if (!valor) return null;
  try {
    const o = typeof valor === "string" ? JSON.parse(valor) : valor;
    if (!o || typeof o !== "object") return null;
    const total = Number(o.total) || 0;
    const done = Number(o.done) || 0;
    return {
      running: o.running === true,
      done,
      total,
      pct: total > 0 ? Math.min(100, Math.round((done / total) * 1000) / 10) : Number(o.pct) || 0,
      actualizados: Number(o.actualizados) || 0,
      errores: Number(o.errores) || 0,
      sku: o.sku || "",
      nombre: o.nombre || "",
      ultimo: o.ultimo || "",
      updated_at: o.updated_at || null,
    };
  } catch {
    return null;
  }
}

export function instanteBotRappiGlobal(refsByProduct) {
  let best = null;
  for (const refs of Object.values(refsByProduct || {})) {
    const t = instanteBotRappiDe(refs);
    if (t != null && (best == null || t > best)) best = t;
  }
  return best;
}
