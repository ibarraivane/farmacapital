"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("./config");
const { crearRegistroCrudo, huellaCaptura } = require("./registroCrudo");
const { normalizarRegistro, normalizarNombreCrudo } = require("./normalizador");
const { recolectarTodas } = require("./fuentes/interfaz");
const { crearAdaptadorDistribuidor } = require("./fuentes/distribuidor");
const { crearAdaptadorProfecoQqp } = require("./fuentes/profecoQqp");
const { crearAdaptadorDatosGobPatente } = require("./fuentes/datosGobPatente");
const { emparejarSku, validarRespuestaModelo, indexarCache } = require("./emparejador");
const { evaluarAnomalia, mediana, consolidarReferencia } = require("./referencia");
const { calcularPvpSugerido, generarPropuesta } = require("./sugerenciaPvp");
const { correrPipeline } = require("./pipeline");
const { rastrearReferencias } = require("./rastrearReferencias");

module.exports = {
  MONITOR_PRECIOS_CONFIG,
  crearRegistroCrudo,
  huellaCaptura,
  normalizarRegistro,
  normalizarNombreCrudo,
  recolectarTodas,
  crearAdaptadorDistribuidor,
  crearAdaptadorProfecoQqp,
  crearAdaptadorDatosGobPatente,
  emparejarSku,
  validarRespuestaModelo,
  indexarCache,
  evaluarAnomalia,
  mediana,
  consolidarReferencia,
  calcularPvpSugerido,
  generarPropuesta,
  correrPipeline,
  rastrearReferencias,
};
