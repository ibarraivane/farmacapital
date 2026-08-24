/**
 * Orquesta los 5 componentes. Idempotente. Una fuente caída no detiene el resto.
 */

"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("./config");
const { huellaCaptura } = require("./registroCrudo");
const { normalizarRegistro } = require("./normalizador");
const { recolectarTodas } = require("./fuentes/interfaz");
const { emparejarSku, indexarCache } = require("./emparejador");
const { aceptarCapturaEnReferencia, consolidarReferencia } = require("./referencia");
const { generarPropuesta } = require("./sugerenciaPvp");

async function correrPipeline(input) {
  const cfg = input.config || MONITOR_PRECIOS_CONFIG;
  const adaptadores = input.adaptadores || [];
  const catalogo = input.catalogo || [];
  const cache = indexarCache(input.mapeosCache || []);
  const ultimoUnitario = input.ultimoUnitarioPorClave || new Map();
  const historialVigente = input.historialVigente || [];
  const llamarModelo = input.llamarModelo || null;
  const ahora = input.ahora || new Date();

  const { registros, errores } = await recolectarTodas(adaptadores, input.ctx || {});
  const capturas = registros.map((r) => {
    const norm = normalizarRegistro(r);
    return { ...norm, huella: huellaCaptura(r) };
  });
  const normalizadas = capturas.filter((c) => c.estado_norm === "NORMALIZADO");

  const mapeosNuevos = [];
  let llamadasModelo = 0;
  const mapeosAceptados = [];
  const presupuesto = {
    usadas: 0,
    max: cfg.emparejador.max_llamadas_por_corrida,
  };

  for (const producto of catalogo) {
    const result = await emparejarSku(producto, normalizadas, {
      config: cfg,
      cache,
      llamarModelo,
      presupuesto,
    });
    llamadasModelo += result.llamadasModelo || 0;
    for (const m of result.mapeos || []) {
      if (!m.desdeCache) mapeosNuevos.push(m);
      if (m.estado === "ACEPTADO" && m.captura) mapeosAceptados.push({ producto, mapeo: m });
    }
  }

  const refsNuevas = [];
  for (const { producto, mapeo } of mapeosAceptados) {
    const cap = mapeo.captura;
    const clave = `${producto.sku}::${cap.fuente}`;
    const decidida = aceptarCapturaEnReferencia(cap, ultimoUnitario.get(clave), cfg);
    refsNuevas.push({
      ...decidida,
      sku: producto.sku,
      producto_id: producto.id || null,
      tipo: cap.tipo || (cfg.fuentes_venta.includes(cap.fuente) ? "venta" : "compra"),
      mapeo_estado: mapeo.estado,
    });
  }

  const paraMediana = [
    ...historialVigente,
    ...refsNuevas.filter((r) => r.entra_a_mediana),
  ];
  const vigentes = consolidarReferencia(paraMediana, { config: cfg, ahora });

  const propuestas = [];
  const porSku = new Map(vigentes.map((v) => [v.sku, v]));
  for (const producto of catalogo) {
    const ref = porSku.get(producto.sku);
    if (!ref) continue;
    const prop = generarPropuesta(producto, ref, cfg);
    if (prop) propuestas.push(prop);
  }

  return {
    capturas,
    mapeos: mapeosNuevos,
    referencias: refsNuevas,
    referencia_vigente: vigentes,
    propuestas,
    errores_fuente: errores,
    llamadas_modelo: llamadasModelo,
  };
}

module.exports = { correrPipeline };
