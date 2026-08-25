/**
 * Catálogo de datos abiertos de precios de medicamentos de patente
 * (catalogo.datos.gob.mx). Solo archivo o URL oficial. No estima precios.
 */

"use strict";

const URL_CATALOGO = "https://catalogo.datos.gob.mx/";

function crearAdaptadorDatosGobPatente(opts) {
  const options = opts || {};
  const { crearAdaptadorDistribuidor, filasDesdeCsv } = require("./distribuidor");
  return {
    id: "datos_gob_patente",
    tipo: "venta",
    portal: URL_CATALOGO,
    async obtener() {
      if (Array.isArray(options.filas)) {
        return options.filas.map((f) => ({
          ...f,
          fuente: "datos_gob_patente",
          tipo: "venta",
          url_origen: f.url_origen || options.url_origen || URL_CATALOGO,
          fecha_captura: f.fecha_captura || options.fecha_captura || new Date().toISOString(),
          moneda: f.moneda || "MXN",
        }));
      }
      if (options.csvText) {
        return filasDesdeCsv(options.csvText, {
          ...options,
          fuente: "datos_gob_patente",
          url_origen: options.url_origen || URL_CATALOGO,
        }).map((f) => ({ ...f, fuente: "datos_gob_patente", tipo: "venta" }));
      }
      const url = options.csvUrl || process.env.DATOS_GOB_PATENTE_CSV_URL;
      if (!url) return [];
      const resp = await fetch(url, {
        headers: { "User-Agent": "FarmaCapital-MonitorPrecios/1.0 (+https://www.farmacapital.mx)" },
      });
      if (!resp.ok) throw new Error(`datos_gob_http_${resp.status}`);
      const text = await resp.text();
      return filasDesdeCsv(text, { fuente: "datos_gob_patente", url_origen: url })
        .map((f) => ({ ...f, fuente: "datos_gob_patente", tipo: "venta" }));
    },
    _compat: crearAdaptadorDistribuidor,
  };
}

module.exports = {
  URL_CATALOGO,
  crearAdaptadorDatosGobPatente,
};
