/**
 * Agente de decisiones de precio.
 * Revisa las mismas referencias que la pestaña Referencias de precio
 * y arma una bandeja (venta, compra y Rappi). Nunca aplica precios solo.
 */

import {
  FUENTES_COMPRA,
  calcMejorCompra,
  calcPrecioSugeridoVenta,
  fmtPrecioRef,
  fmtPrecioVenta,
  roundPrecioVenta,
} from "./preciosReferencia";
import { compraVigenteDe, costoComparacionDe } from "./ultimaCompra";

export const REFRESH_MS = 3 * 60 * 1000;
export const DISMISS_HORAS = 24;
export const DISMISS_STORAGE_KEY = "farmacapital_decisiones_precios_dismiss_v1";

export const TIPO_DECISION = {
  VENTA_BAJAR: "venta_bajar",
  VENTA_SUBIR: "venta_subir",
  VENTA_DEBAJO_COSTO: "venta_debajo_costo",
  VENTA_DEBAJO_PISO: "venta_debajo_piso",
  COMPRA_OPORTUNIDAD: "compra_oportunidad",
  RAPPI_SIN_REF: "rappi_sin_ref",
};

export const DECISION_META = {
  venta_bajar: {
    label: "Bajar venta",
    chip: "Más cara que ref.",
    tone: "caro",
  },
  venta_subir: {
    label: "Subir venta",
    chip: "Debajo del mercado",
    tone: "subir",
  },
  venta_debajo_costo: {
    label: "Revisar costo",
    chip: "Sugerido bajo costo",
    tone: "critica",
  },
  venta_debajo_piso: {
    label: "Competir bajo piso",
    chip: "Bajo piso",
    tone: "piso",
  },
  compra_oportunidad: {
    label: "Comprar más barato",
    chip: "Lista más barata",
    tone: "compra",
  },
  rappi_sin_ref: {
    label: "Rappi sin referencia",
    chip: "Rappi",
    tone: "rappi",
  },
};

/** Misma regla que SQL rappi_producto_eligible + controlado si viene en el row. */
export function esElegibleRappi(producto) {
  if (!producto) return false;
  if (producto.activo === false) return false;
  if (producto.requiere_receta) return false;
  if (producto.controlado) return false;
  return true;
}

export function claveDecision(d) {
  const extra = d.sugerido ?? d.mejor_precio ?? "na";
  return `${d.producto_id}:${d.tipo}:${extra}`;
}

export function puntuarDecision(d) {
  const stock = Number(d.stock) || 0;
  const impacto = Number(d.impacto) || 0;
  let s = 0;
  if (d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO) s = 1000;
  else if (d.tipo === TIPO_DECISION.VENTA_BAJAR) s = 800 + Math.min(150, impacto || stock);
  else if (d.tipo === TIPO_DECISION.VENTA_DEBAJO_PISO) s = 700;
  else if (d.tipo === TIPO_DECISION.COMPRA_OPORTUNIDAD) s = 600 + Math.min(100, impacto);
  else if (d.tipo === TIPO_DECISION.VENTA_SUBIR) s = 400 + Math.min(80, impacto);
  else if (d.tipo === TIPO_DECISION.RAPPI_SIN_REF) s = 200;
  if (d.rappi && d.tipo !== TIPO_DECISION.RAPPI_SIN_REF) s += 40;
  return s;
}

function filaBase(producto, extra) {
  return {
    producto_id: producto.id,
    sku: producto.sku || "",
    nombre: producto.nombre || "",
    stock: Number(producto.stock) || 0,
    precio_actual: roundPrecioVenta(producto.precio),
    costo: parseFloat(producto.costo) || null,
    puede_aplicar: false,
    ...extra,
  };
}

export function clasificarProducto(producto, refsMap) {
  if (!producto?.id) return [];
  const refs = refsMap || {};
  const vigente = compraVigenteDe(producto, refs);
  const costo = costoComparacionDe(producto, refs);
  const mejor = calcMejorCompra(costo, refs, vigente || {});
  const venta = calcPrecioSugeridoVenta(producto, refs);
  const rappi = esElegibleRappi(producto);
  const actual = roundPrecioVenta(producto.precio);
  const stock = Number(producto.stock) || 0;
  const out = [];

  if (mejor?.masBaratoQueTuCosto) {
    const ahorro = Number(mejor.ahorroVsTuCosto) || 0;
    out.push(filaBase(producto, {
      tipo: TIPO_DECISION.COMPRA_OPORTUNIDAD,
      ambito: "compra",
      rappi,
      mejor_fuente: mejor.fuente,
      mejor_label: mejor.label,
      mejor_precio: mejor.precio,
      impacto: Math.round(ahorro * 100) / 100,
      detalle: `${mejor.label} a ${fmtPrecioRef(mejor.precio)}: ${fmtPrecioRef(ahorro)} menos que tu compra.`,
    }));
  }

  if (venta.sugerido != null && actual != null && actual !== venta.sugerido) {
    const delta = venta.sugerido - actual;
    let tipo = delta < 0 ? TIPO_DECISION.VENTA_BAJAR : TIPO_DECISION.VENTA_SUBIR;
    if (venta.alerta === "debajo_costo") tipo = TIPO_DECISION.VENTA_DEBAJO_COSTO;
    else if (venta.alerta === "debajo_piso") tipo = TIPO_DECISION.VENTA_DEBAJO_PISO;

    let detalle = venta.nota;
    if (rappi) {
      detalle = `${detalle} En Rappi el sync solo manda stock: si cambias el precio de mostrador, actualiza el mismo SKU en el catálogo de Rappi.`;
    }

    out.push(filaBase(producto, {
      tipo,
      ambito: "venta",
      rappi,
      sugerido: venta.sugerido,
      ref_min: venta.refMin,
      alerta: venta.alerta,
      impacto: Math.round(Math.abs(delta) * stock * 100) / 100,
      detalle,
      puede_aplicar: tipo !== TIPO_DECISION.VENTA_DEBAJO_COSTO,
      nota_venta: venta.nota,
    }));
  }

  if (rappi && venta.refMin == null) {
    const tieneCompra = FUENTES_COMPRA.some((f) => refs[f]?.precio != null);
    out.push(filaBase(producto, {
      tipo: TIPO_DECISION.RAPPI_SIN_REF,
      ambito: "rappi",
      rappi: true,
      detalle: tieneCompra
        ? "Elegible para Rappi y sin Del Ahorro / Similares / Otros. Sin esa referencia no sabes si el precio del catálogo Rappi está bien."
        : "Elegible para Rappi y sin referencias de venta. Captura competencia antes de publicar o tocar el precio.",
    }));
  }

  return out.map((d) => {
    const conClave = { ...d, prioridad: 0, clave: "" };
    conClave.prioridad = puntuarDecision(conClave);
    conClave.clave = claveDecision(conClave);
    return conClave;
  });
}

export function clasificarDecisiones(productos, refsByProduct, opts = {}) {
  const dismissed = new Set(opts.dismissedKeys || []);
  const out = [];
  for (const p of productos || []) {
    const filas = clasificarProducto(p, (refsByProduct || {})[p.id] || {});
    for (const d of filas) {
      if (dismissed.has(d.clave)) continue;
      out.push(d);
    }
  }
  out.sort((a, b) => b.prioridad - a.prioridad || String(a.nombre).localeCompare(String(b.nombre), "es"));
  return out;
}

export function filtrarDecisiones(decisiones, filtro) {
  const list = decisiones || [];
  if (!filtro || filtro === "todas") return list;
  if (filtro === "venta") return list.filter((d) => d.ambito === "venta");
  if (filtro === "compra") return list.filter((d) => d.ambito === "compra");
  if (filtro === "rappi") return list.filter((d) => d.rappi && (d.ambito === "venta" || d.ambito === "rappi"));
  if (filtro === "criticas") {
    return list.filter((d) => d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO || d.alerta === "debajo_costo");
  }
  return list;
}

export function resumenDecisiones(decisiones) {
  const list = decisiones || [];
  const rappi = list.filter((d) => d.rappi && (d.ambito === "venta" || d.ambito === "rappi"));
  return {
    total: list.length,
    venta: list.filter((d) => d.ambito === "venta").length,
    compra: list.filter((d) => d.ambito === "compra").length,
    rappi: rappi.length,
    criticas: list.filter((d) => d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO).length,
  };
}

export function loadDismissed(now = Date.now(), storage) {
  const store = storage || (typeof localStorage !== "undefined" ? localStorage : null);
  if (!store) return {};
  try {
    const raw = JSON.parse(store.getItem(DISMISS_STORAGE_KEY) || "{}");
    const live = {};
    for (const [k, v] of Object.entries(raw || {})) {
      if (v && Number(v.until) > now) live[k] = v;
    }
    return live;
  } catch {
    return {};
  }
}

export function dismissDecision(clave, horas = DISMISS_HORAS, now = Date.now(), storage) {
  const store = storage || (typeof localStorage !== "undefined" ? localStorage : null);
  if (!store || !clave) return {};
  const all = loadDismissed(now, store);
  all[clave] = { until: now + horas * 3600 * 1000 };
  try {
    store.setItem(DISMISS_STORAGE_KEY, JSON.stringify(all));
  } catch { /* quota / privado */ }
  return all;
}

export function textoConfirmacionAplicar(d) {
  const nombre = d.nombre || "este producto";
  const actual = fmtPrecioVenta(d.precio_actual);
  const sug = fmtPrecioVenta(d.sugerido);
  let msg = `¿Aplicar ${sug} a «${nombre}»?\n\nTu precio actual: ${actual}`;
  if (d.tipo === TIPO_DECISION.VENTA_DEBAJO_PISO) {
    msg += "\n\nQueda bajo tu piso habitual de margen. Solo si priorizas share.";
  }
  if (d.rappi) {
    msg += "\n\nSKU elegible para Rappi: el sync no publica precio. Actualiza el catálogo de Rappi a mano.";
  }
  return msg;
}

