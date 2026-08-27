/**
 * Agente de decisiones de precio.
 * Revisa las mismas referencias que la pestaña Referencias de precio
 * y arma alertas para mostrador, Rappi y (cuando se activen) Uber / DiDi.
 * Nunca aplica precios solo.
 */

import {
  FUENTES_COMPRA,
  calcMejorCompra,
  calcMargenVenta,
  calcPrecioSugeridoVenta,
  fmtPrecioRef,
  fmtPrecioVenta,
  roundPrecioVenta,
} from "./preciosReferencia";
import { compraVigenteDe, costoComparacionDe } from "./ultimaCompra";
import {
  CANALES_VENTA,
  esElegibleCanal,
  canalesActivosDeProducto,
  canalesFuturosDeProducto,
  marketplacesActivosDeProducto,
  labelCanales,
} from "./canalesVenta";

/** Más caro que la ref. mínima: 8 % o $10, lo que dispare primero. */
export const CARO_MERCADO_PCT = 0.08;
export const CARO_MERCADO_PESOS = 10;

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
  MARGEN_ACTUAL_BAJO: "margen_actual_bajo",
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
  margen_actual_bajo: {
    label: "Revisar margen",
    chip: "Margen bajo",
    tone: "piso",
  },
};

/** Misma regla que SQL rappi_producto_eligible + controlado si viene en el row. */
export function esElegibleRappi(producto) {
  return esElegibleCanal("rappi", producto);
}

export function esMuchoMasCaroQueMercado(precioActual, refMin) {
  const actual = Number(precioActual);
  const ref = Number(refMin);
  if (!Number.isFinite(actual) || !Number.isFinite(ref) || ref <= 0) return false;
  const delta = actual - ref;
  if (delta <= 0) return false;
  return delta >= CARO_MERCADO_PESOS || delta / ref >= CARO_MERCADO_PCT;
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
  else if (d.tipo === TIPO_DECISION.MARGEN_ACTUAL_BAJO && d.alerta === "debajo_costo") s = 980;
  else if (d.tipo === TIPO_DECISION.VENTA_BAJAR) s = 800 + Math.min(150, impacto || stock) + (d.mucho_mas_caro ? 40 : 0);
  else if (d.tipo === TIPO_DECISION.MARGEN_ACTUAL_BAJO) s = 730;
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
    canales: extra.canales || ["mostrador"],
    canales_futuros: extra.canales_futuros || [],
    rappi: extra.rappi ?? (extra.canales || []).includes("rappi"),
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
  const canalesActivos = canalesActivosDeProducto(producto).map((c) => c.id);
  const canalesFuturos = canalesFuturosDeProducto(producto).map((c) => c.id);
  const appsActivas = marketplacesActivosDeProducto(producto);
  const margenActual = calcMargenVenta(actual, producto);
  const out = [];

  if (mejor?.masBaratoQueTuCosto) {
    const ahorro = Number(mejor.ahorroVsTuCosto) || 0;
    out.push(filaBase(producto, {
      tipo: TIPO_DECISION.COMPRA_OPORTUNIDAD,
      ambito: "compra",
      rappi,
      canales: ["mostrador", ...appsActivas.map((c) => c.id)],
      canales_futuros: canalesFuturos,
      mejor_fuente: mejor.fuente,
      mejor_label: mejor.label,
      mejor_precio: mejor.precio,
      impacto: Math.round(ahorro * 100) / 100,
      detalle: `${mejor.label} a ${fmtPrecioRef(mejor.precio)}: ${fmtPrecioRef(ahorro)} menos que tu compra. Baja el costo y el margen de mostrador / apps mejora.`,
    }));
  }

  if (margenActual.tone === "debajo_costo" || margenActual.tone === "debajo_piso") {
    const pisoTxt = margenActual.piso != null ? fmtPrecioVenta(margenActual.piso) : "—";
    out.push(filaBase(producto, {
      tipo: TIPO_DECISION.MARGEN_ACTUAL_BAJO,
      ambito: "venta",
      rappi,
      canales: canalesActivos,
      canales_futuros: canalesFuturos,
      alerta: margenActual.tone,
      margen_pct: margenActual.pct,
      piso: margenActual.piso,
      ref_min: venta.refMin,
      detalle: margenActual.tone === "debajo_costo"
        ? `Tu venta ${fmtPrecioVenta(actual)} no cubre el costo (${fmtPrecioRef(producto.costo)}). Revisa costo o precio antes de publicar en apps.`
        : `Margen ${margenActual.pct}% bajo el piso habitual (${pisoTxt}). El precio actual no deja el margen que usas en Referencias.`,
    }));
  }

  if (venta.sugerido != null && actual != null && actual !== venta.sugerido) {
    const delta = venta.sugerido - actual;
    let tipo = delta < 0 ? TIPO_DECISION.VENTA_BAJAR : TIPO_DECISION.VENTA_SUBIR;
    if (venta.alerta === "debajo_costo") tipo = TIPO_DECISION.VENTA_DEBAJO_COSTO;
    else if (venta.alerta === "debajo_piso") tipo = TIPO_DECISION.VENTA_DEBAJO_PISO;
    const mucho = tipo === TIPO_DECISION.VENTA_BAJAR && esMuchoMasCaroQueMercado(actual, venta.refMin);

    let detalle = venta.nota;
    if (mucho) {
      detalle = `Estás ${fmtPrecioVenta(actual)} vs ref. ${fmtPrecioRef(venta.refMin)}: te sales del mercado. Competir a ${fmtPrecioVenta(venta.sugerido)}.`;
    }
    if (appsActivas.length) {
      const labels = appsActivas.map((c) => c.label).join(" / ");
      detalle = `${detalle} En ${labels} el sync no manda precio: si cambias mostrador, actualiza el catálogo de la app.`;
    }
    if (canalesFuturos.length) {
      detalle = `${detalle} Uber y DiDi usarán este mismo precio cuando se conecten.`;
    }

    out.push(filaBase(producto, {
      tipo,
      ambito: "venta",
      rappi,
      canales: canalesActivos,
      canales_futuros: canalesFuturos,
      sugerido: venta.sugerido,
      ref_min: venta.refMin,
      alerta: venta.alerta,
      mucho_mas_caro: mucho,
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
      canales: ["rappi"],
      canales_futuros: canalesFuturos,
      detalle: tieneCompra
        ? "Elegible para Rappi (y luego Uber/DiDi) sin Del Ahorro / Similares / Otros. Sin esa referencia no sabes si el precio de las apps está bien."
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

function tocaCanal(d, canalId) {
  const activos = d.canales || (d.rappi ? ["rappi"] : ["mostrador"]);
  const futuros = d.canales_futuros || [];
  return activos.includes(canalId) || futuros.includes(canalId);
}

export function filtrarDecisiones(decisiones, filtro) {
  const list = decisiones || [];
  if (!filtro || filtro === "todas") return list;
  if (filtro === "venta") return list.filter((d) => d.ambito === "venta");
  if (filtro === "compra") return list.filter((d) => d.ambito === "compra");
  if (filtro === "rappi") return list.filter((d) => tocaCanal(d, "rappi") && (d.ambito === "venta" || d.ambito === "rappi"));
  if (filtro === "uber") return list.filter((d) => tocaCanal(d, "uber") && d.ambito === "venta");
  if (filtro === "didi") return list.filter((d) => tocaCanal(d, "didi") && d.ambito === "venta");
  if (filtro === "mostrador") return list.filter((d) => tocaCanal(d, "mostrador"));
  if (filtro === "caro") {
    return list.filter((d) => d.tipo === TIPO_DECISION.VENTA_BAJAR || d.mucho_mas_caro);
  }
  if (filtro === "margen") {
    return list.filter((d) =>
      d.tipo === TIPO_DECISION.MARGEN_ACTUAL_BAJO
      || d.tipo === TIPO_DECISION.VENTA_DEBAJO_PISO
      || d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO
    );
  }
  if (filtro === "criticas") {
    return list.filter((d) =>
      d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO
      || d.alerta === "debajo_costo"
    );
  }
  return list;
}

export function resumenDecisiones(decisiones) {
  const list = decisiones || [];
  const rappi = filtrarDecisiones(list, "rappi");
  return {
    total: list.length,
    venta: list.filter((d) => d.ambito === "venta").length,
    compra: list.filter((d) => d.ambito === "compra").length,
    rappi: rappi.length,
    uber: filtrarDecisiones(list, "uber").length,
    didi: filtrarDecisiones(list, "didi").length,
    mostrador: filtrarDecisiones(list, "mostrador").length,
    caro: filtrarDecisiones(list, "caro").length,
    margen: filtrarDecisiones(list, "margen").length,
    criticas: filtrarDecisiones(list, "criticas").length,
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
  const apps = (d.canales || []).filter((id) => CANALES_VENTA[id]?.marketplace && CANALES_VENTA[id].activo);
  const futuros = d.canales_futuros || [];
  if (apps.length) {
    msg += `\n\nApps: ${labelCanales(apps).join(", ")}. El sync no publica precio; actualiza el catálogo de la app a mano.`;
  }
  if (futuros.length) {
    msg += `\n\n${labelCanales(futuros).join(" y ")} aún no están conectados; el mismo precio de mostrador es el que publicarás ahí.`;
  }
  return msg;
}

/**
 * Resumen por producto para el catálogo (compra + venta + apps).
 * No aplica precios; solo chips de revisión.
 */
export function alertaCatalogoDe(producto, refsMap) {
  const refs = refsMap || {};
  const decisiones = clasificarProducto(producto, refs);
  const venta = calcPrecioSugeridoVenta(producto, refs);
  const actual = roundPrecioVenta(producto.precio);
  const margenActual = calcMargenVenta(actual, producto);
  const vigente = compraVigenteDe(producto, refs);
  const mejor = calcMejorCompra(costoComparacionDe(producto, refs), refs, vigente || {});
  const chips = [];

  if (margenActual.tone === "debajo_costo") {
    chips.push({ id: "bajo_costo", label: "Bajo costo", tone: "critica" });
  } else if (margenActual.tone === "debajo_piso") {
    chips.push({ id: "bajo_piso", label: "Margen bajo", tone: "piso" });
  }

  if (venta.refMin != null && actual != null && actual > venta.refMin) {
    const pct = ((actual - venta.refMin) / venta.refMin) * 100;
    const mucho = esMuchoMasCaroQueMercado(actual, venta.refMin);
    chips.push({
      id: "caro",
      label: mucho ? `+${pct.toFixed(0)}% vs mercado` : `+${pct.toFixed(0)}% vs ref.`,
      tone: "caro",
    });
  }

  if (mejor?.masBaratoQueTuCosto) {
    chips.push({
      id: "compra",
      label: `Compra ${mejor.label}`,
      tone: "compra",
    });
  }

  const apps = marketplacesActivosDeProducto(producto);
  if (apps.length && chips.some((c) => c.id === "caro" || c.id === "bajo_costo")) {
    chips.push({
      id: "apps",
      label: apps.map((c) => c.label).join(" · "),
      tone: "rappi",
    });
  }

  return {
    refMin: venta.refMin ?? null,
    sugerido: venta.sugerido ?? null,
    margenActual,
    mejorCompra: mejor?.masBaratoQueTuCosto ? mejor : null,
    chips,
    tieneAlerta: chips.length > 0,
    decisiones,
  };
}

export function productoTieneAlertaPrecio(producto, refsMap, tipo) {
  const a = alertaCatalogoDe(producto, refsMap);
  if (!tipo || tipo === "alerta_precio") return a.tieneAlerta;
  if (tipo === "caro_mercado") return a.chips.some((c) => c.id === "caro");
  if (tipo === "margen_bajo") return a.chips.some((c) => c.id === "bajo_costo" || c.id === "bajo_piso");
  return a.tieneAlerta;
}

