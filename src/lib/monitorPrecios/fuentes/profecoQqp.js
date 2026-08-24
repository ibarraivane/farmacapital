/**
 * Adaptador PROFECO — Quién es Quién en los Precios.
 * Fuente oficial: datos.profeco.gob.mx (CSV abierto) / qqp.profeco.gob.mx.
 * No inventa precios. Si no hay archivo ni URL, obtiene lista vacía.
 */

"use strict";

const { filasDesdeCsv } = require("./distribuidor");

const URL_PORTAL = "https://datos.profeco.gob.mx/datos_abiertos/qqp.php";
const URL_CONSULTA = "https://qqp.profeco.gob.mx/";

function pareceMedicamento(row) {
  const cat = [row.categoria, row.catalogo, row.giro].filter(Boolean).join(" ").toLowerCase();
  if (!cat) return true;
  return /medic|farmac|salud|tableta|capsul|jarabe|suspens|analge|antibiot/.test(cat);
}

function coincideCiudad(row, ciudad) {
  if (!ciudad) return true;
  const want = String(ciudad).toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  const have = [row.ciudad, row.municipio, row.estado, row.plaza]
    .filter(Boolean)
    .join(" ")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  if (!have) return true;
  return have.includes(want) || want.includes(have);
}

function mapearFilasQqp(rawRows, opts) {
  const url = (opts && opts.url_origen) || URL_PORTAL;
  const fechaDefault = (opts && opts.fecha_captura) || new Date().toISOString();
  const ciudadFiltro = opts && opts.ciudad;

  return (rawRows || []).map((row) => {
    const nombre = String(
      row.nombre_crudo || row.producto || row.descripcion || row.presentacion || ""
    ).trim();
    const precioRaw = row.precio != null ? row.precio : row.precio_promedio;
    const precio = Number(String(precioRaw || "").replace(/[$,\s]/g, ""));
    if (!nombre || !Number.isFinite(precio) || precio < 0) return null;
    if (!pareceMedicamento(row)) return null;
    if (!coincideCiudad(row, ciudadFiltro)) return null;
    const fecha = row.fecha_registro || row.fecha || row.fecha_captura || fechaDefault;
    return {
      fuente: "profeco_qqp",
      tipo: "venta",
      nombre_crudo: nombre,
      precio,
      moneda: "MXN",
      url_origen: url,
      fecha_captura: new Date(fecha).toISOString(),
      ciudad: row.ciudad || row.municipio || null,
      region: row.estado || null,
      gtin_fuente: String(row.ean || row.gtin || row.codigo_barras || "").replace(/\D/g, ""),
      sku_externo: row.sku_externo || null,
    };
  }).filter(Boolean);
}

async function fetchCsvOficial(url) {
  const resp = await fetch(url, {
    headers: { "User-Agent": "FarmaCapital-MonitorPrecios/1.0 (+https://www.farmacapital.mx)" },
  });
  if (!resp.ok) throw new Error(`profeco_http_${resp.status}`);
  return resp.text();
}

function crearAdaptadorProfecoQqp(opts) {
  const options = opts || {};
  return {
    id: "profeco_qqp",
    tipo: "venta",
    portal: URL_PORTAL,
    consulta: URL_CONSULTA,
    async obtener() {
      if (Array.isArray(options.filas)) {
        return mapearFilasQqp(options.filas, options);
      }
      if (options.csvText) {
        const { rows } = require("./distribuidor").parseCsvText(options.csvText);
        return mapearFilasQqp(rows, { ...options, url_origen: options.url_origen || URL_PORTAL });
      }
      const url = options.csvUrl || process.env.PROFECO_QQP_CSV_URL;
      if (url) {
        const text = await fetchCsvOficial(url);
        const { rows } = require("./distribuidor").parseCsvText(text);
        return mapearFilasQqp(rows, {
          ...options,
          url_origen: url,
          ciudad: options.ciudad || process.env.PROFECO_QQP_CIUDAD || null,
        });
      }
      return [];
    },
  };
}

module.exports = {
  URL_PORTAL,
  URL_CONSULTA,
  pareceMedicamento,
  coincideCiudad,
  mapearFilasQqp,
  crearAdaptadorProfecoQqp,
  filasDesdeCsv,
};
