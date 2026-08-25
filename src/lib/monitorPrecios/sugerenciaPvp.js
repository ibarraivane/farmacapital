/**
 * Sugerencia de PVP. Regla pura, sin IA.
 * Ningún precio se escribe aquí; solo se propone.
 */

"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("./config");
const { clasificarTipoComercial } = require("./normalizador");
const { piezasProducto } = require("./emparejador");

function margenMinimoDe(producto, config) {
  const cfg = config || MONITOR_PRECIOS_CONFIG;
  const tipo = clasificarTipoComercial(producto);
  return cfg.margen_minimo[tipo] != null ? cfg.margen_minimo[tipo] : cfg.margen_minimo.default;
}

function factorDe(producto, config) {
  const cfg = config || MONITOR_PRECIOS_CONFIG;
  const tipo = clasificarTipoComercial(producto);
  return cfg.factor_posicionamiento[tipo] != null
    ? cfg.factor_posicionamiento[tipo]
    : cfg.factor_posicionamiento.default;
}

function calcularPvpSugerido(input, config) {
  const cfg = config || MONITOR_PRECIOS_CONFIG;
  const producto = input.producto;
  const refUnit = Number(input.referencia_unitaria);
  const piezas = Number(input.piezas_por_empaque) || piezasProducto(producto);
  const costo = Number(producto.costo);
  const pmvp = producto.pmvp != null ? Number(producto.pmvp) : null;
  const factor = factorDe(producto, cfg);
  const margenMin = margenMinimoDe(producto, cfg);

  if (!Number.isFinite(refUnit) || refUnit <= 0) {
    return { pvp_sugerido: null, piso: null, motivo: "sin_referencia" };
  }
  if (!Number.isFinite(piezas) || piezas < 1) {
    return { pvp_sugerido: null, piso: null, motivo: "sin_piezas" };
  }

  let sugerido = refUnit * piezas * factor;
  const piso = Number.isFinite(costo) && costo > 0 ? costo * (1 + margenMin) : null;
  if (piso != null && sugerido < piso) sugerido = piso;
  if (pmvp != null && pmvp > 0 && sugerido > pmvp) sugerido = pmvp;

  return {
    pvp_sugerido: Math.round(sugerido * 100) / 100,
    piso: piso == null ? null : Math.round(piso * 100) / 100,
    factor_posicionamiento: factor,
    margen_minimo_categoria: margenMin,
    referencia_caja: Math.round(refUnit * piezas * 100) / 100,
    motivo: piso != null && refUnit * piezas * factor < piso ? "piso_margen" : "mercado",
  };
}

function superaUmbral(precioActual, pvpSugerido, config) {
  const cfg = config || MONITOR_PRECIOS_CONFIG;
  const actual = Number(precioActual);
  const sug = Number(pvpSugerido);
  if (!Number.isFinite(actual) || !Number.isFinite(sug)) return false;
  const diff = Math.abs(sug - actual);
  const porPct = actual > 0 ? diff / actual : 1;
  return porPct > cfg.umbral_sugerencia_pct || diff > cfg.umbral_sugerencia_pesos;
}

function margenResultante(pvp, costo) {
  const p = Number(pvp);
  const c = Number(costo);
  if (!Number.isFinite(p) || p <= 0 || !Number.isFinite(c)) return null;
  return Math.round(((p - c) / p) * 10000) / 10000;
}

function generarPropuesta(producto, referencia, config) {
  const calc = calcularPvpSugerido({
    producto,
    referencia_unitaria: referencia.precio_unitario_mediana,
    piezas_por_empaque: piezasProducto(producto),
  }, config);
  if (calc.pvp_sugerido == null) return null;
  if (!superaUmbral(producto.precio, calc.pvp_sugerido, config)) return null;

  const stock = Number(producto.stock) || 0;
  return {
    producto_id: producto.id || null,
    sku: producto.sku,
    nombre: producto.nombre,
    precio_actual: Number(producto.precio) || 0,
    costo_usado: Number(producto.costo) || null,
    piezas_por_empaque: piezasProducto(producto),
    referencia_unitaria: referencia.precio_unitario_mediana,
    referencia_caja: calc.referencia_caja,
    n_fuentes: referencia.n_fuentes,
    fecha_dato_mas_reciente: referencia.fecha_dato_mas_reciente,
    factor_posicionamiento: calc.factor_posicionamiento,
    margen_minimo_categoria: calc.margen_minimo_categoria,
    piso: calc.piso,
    pmvp: producto.pmvp != null ? Number(producto.pmvp) : null,
    pvp_sugerido: calc.pvp_sugerido,
    margen_resultante: margenResultante(calc.pvp_sugerido, producto.costo),
    impacto_estimado: Math.round((calc.pvp_sugerido - (Number(producto.precio) || 0)) * stock * 100) / 100,
    umbral_motivo: calc.motivo,
    estado: "PENDIENTE",
  };
}

module.exports = {
  margenMinimoDe,
  factorDe,
  calcularPvpSugerido,
  superaUmbral,
  margenResultante,
  generarPropuesta,
};
