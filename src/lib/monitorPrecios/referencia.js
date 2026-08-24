/**
 * Precio de referencia: anomalías + mediana. Sin IA.
 * Compara siempre precio_unitario, nunca el de caja.
 */

"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("./config");

function evaluarAnomalia(precioUnitarioNuevo, ultimoPrecioUnitario, umbral) {
  const nuevo = Number(precioUnitarioNuevo);
  const ultimo = Number(ultimoPrecioUnitario);
  const limite = umbral == null ? MONITOR_PRECIOS_CONFIG.umbral_anomalia : umbral;
  if (!Number.isFinite(nuevo) || nuevo <= 0) {
    return { estado: "DESCARTADA", delta: null, actualizar: false };
  }
  if (!Number.isFinite(ultimo) || ultimo <= 0) {
    return { estado: "VIGENTE", delta: null, actualizar: true };
  }
  const delta = Math.abs(nuevo - ultimo) / ultimo;
  if (delta > limite) {
    return { estado: "ANOMALIA_POR_REVISAR", delta, actualizar: false };
  }
  return { estado: "VIGENTE", delta, actualizar: true };
}

function mediana(valores) {
  const xs = (valores || [])
    .map(Number)
    .filter((n) => Number.isFinite(n))
    .sort((a, b) => a - b);
  if (!xs.length) return null;
  const mid = Math.floor(xs.length / 2);
  if (xs.length % 2 === 1) return xs[mid];
  return Math.round(((xs[mid - 1] + xs[mid]) / 2) * 10000) / 10000;
}

function capturaDentroDeVigencia(captura, ahora, dias) {
  const t = new Date(captura.fecha_captura || captura.fecha).getTime();
  if (!Number.isFinite(t)) return false;
  const limite = (ahora || new Date()).getTime() - dias * 86400000;
  return t >= limite;
}

/**
 * historial: capturas ya emparejadas ACEPTADAS, con precio_unitario y fuente.
 * ultimoPorClave: Map "sku::fuente" → ultimo precio_unitario vigente.
 */
function aceptarCapturaEnReferencia(captura, ultimoUnitario, config) {
  const cfg = config || MONITOR_PRECIOS_CONFIG;
  const anom = evaluarAnomalia(captura.precio_unitario, ultimoUnitario, cfg.umbral_anomalia);
  return {
    ...captura,
    estado_ref: anom.estado,
    delta_vs_anterior: anom.delta,
    entra_a_mediana: anom.actualizar && captura.estado_norm === "NORMALIZADO",
  };
}

function consolidarReferencia(filas, opciones = {}) {
  const cfg = opciones.config || MONITOR_PRECIOS_CONFIG;
  const ahora = opciones.ahora || new Date();
  const dias = opciones.dias_vigencia != null ? opciones.dias_vigencia : cfg.dias_vigencia;
  const fuentesVenta = new Set(opciones.fuentes_venta || cfg.fuentes_venta);

  const vigentes = (filas || []).filter((f) => {
    if (f.estado_ref && f.estado_ref !== "VIGENTE") return false;
    if (f.estado && f.estado !== "VIGENTE") return false;
    if (!Number.isFinite(Number(f.precio_unitario))) return false;
    if (fuentesVenta.size && f.fuente && !fuentesVenta.has(f.fuente) && f.tipo !== "venta") {
      return false;
    }
    if (f.tipo === "compra") return false;
    return capturaDentroDeVigencia(f, ahora, dias);
  });

  const porSku = new Map();
  for (const f of vigentes) {
    const sku = f.sku || f.producto_id;
    if (!porSku.has(sku)) porSku.set(sku, []);
    porSku.get(sku).push(f);
  }

  const out = [];
  for (const [sku, rows] of porSku) {
    const porFuente = new Map();
    for (const r of rows) {
      const prev = porFuente.get(r.fuente);
      if (!prev || String(r.fecha_captura) > String(prev.fecha_captura)) {
        porFuente.set(r.fuente, r);
      }
    }
    const latest = [...porFuente.values()];
    const unitarios = latest.map((r) => Number(r.precio_unitario));
    const fechas = latest.map((r) => r.fecha_captura);
    out.push({
      sku,
      producto_id: latest[0].producto_id || null,
      precio_unitario_mediana: mediana(unitarios),
      precio_unitario_min: Math.min(...unitarios),
      precio_unitario_max: Math.max(...unitarios),
      n_fuentes: latest.length,
      fecha_dato_mas_reciente: fechas.sort().slice(-1)[0],
      capturas: latest,
    });
  }
  return out;
}

module.exports = {
  evaluarAnomalia,
  mediana,
  capturaDentroDeVigencia,
  aceptarCapturaEnReferencia,
  consolidarReferencia,
};
