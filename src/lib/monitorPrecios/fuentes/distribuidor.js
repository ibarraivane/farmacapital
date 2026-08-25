/**
 * Adaptador: lista de precios del distribuidor (CSV que cargas).
 * Fuente más limpia. No scrapea. No inventa precios.
 */

"use strict";

function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < line.length; i += 1) {
    const c = line[i];
    if (c === "\"") {
      if (inQ && line[i + 1] === "\"") {
        cur += "\"";
        i += 1;
      } else inQ = !inQ;
    } else if (c === "," && !inQ) {
      out.push(cur);
      cur = "";
    } else cur += c;
  }
  out.push(cur);
  return out.map((s) => s.trim());
}

function parseCsvText(text) {
  const lines = String(text || "").replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n").filter((l) => l.trim());
  if (!lines.length) return { headers: [], rows: [] };
  const headers = splitCsvLine(lines[0]);
  const rows = lines.slice(1).map((line, idx) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cells[i] ?? ""; });
    row._line = idx + 2;
    return row;
  });
  return { headers, rows };
}

function findCol(headers, names) {
  const lower = headers.map((h) => String(h || "").toLowerCase().trim());
  for (const name of names) {
    const i = lower.indexOf(name);
    if (i >= 0) return headers[i];
  }
  return null;
}

function parseMoney(val) {
  if (val == null || val === "") return null;
  const n = parseFloat(String(val).replace(/[$,\s]/g, ""));
  return Number.isFinite(n) && n >= 0 ? n : null;
}

function filasDesdeCsv(text, opts) {
  const { headers, rows } = parseCsvText(text);
  const nomH = findCol(headers, ["nombre", "producto", "descripcion", "nombre_crudo", "producto_raw"]);
  const preH = findCol(headers, ["precio", "precio_lista", "precio_ref", "precio_mayoreo", "costo"]);
  const eanH = findCol(headers, ["ean", "gtin", "codigo_barras", "codigobarras", "barcode", "upc"]);
  const skuH = findCol(headers, ["sku", "sku_externo", "codigo"]);
  const ciuH = findCol(headers, ["ciudad", "municipio", "plaza"]);
  if (!preH) throw new Error("distribuidor_sin_columna_precio");
  if (!nomH && !eanH) throw new Error("distribuidor_sin_nombre_ni_ean");

  const url = (opts && opts.url_origen) || "archivo:lista_distribuidor.csv";
  const fecha = (opts && opts.fecha_captura) || new Date().toISOString();
  const fuente = (opts && opts.fuente) || "lista_distribuidor";

  return rows.map((row) => {
    const precio = parseMoney(row[preH]);
    const nombre = nomH ? String(row[nomH] || "").trim() : "";
    if (precio == null || (!nombre && !row[eanH])) return null;
    return {
      fuente,
      tipo: "compra",
      nombre_crudo: nombre || `EAN ${String(row[eanH] || "").replace(/\D/g, "")}`,
      precio,
      moneda: "MXN",
      url_origen: url,
      fecha_captura: fecha,
      ciudad: ciuH ? String(row[ciuH] || "").trim() || null : null,
      gtin_fuente: eanH ? String(row[eanH] || "").replace(/\D/g, "") : "",
      sku_externo: skuH ? String(row[skuH] || "").trim() || null : null,
    };
  }).filter(Boolean);
}

function crearAdaptadorDistribuidor(opts) {
  const options = opts || {};
  return {
    id: options.fuente || "lista_distribuidor",
    tipo: "compra",
    async obtener() {
      if (Array.isArray(options.filas)) {
        return options.filas.map((f) => ({
          ...f,
          fuente: f.fuente || options.fuente || "lista_distribuidor",
          tipo: "compra",
          url_origen: f.url_origen || options.url_origen || "archivo:lista_distribuidor",
          fecha_captura: f.fecha_captura || options.fecha_captura || new Date().toISOString(),
          moneda: f.moneda || "MXN",
        }));
      }
      if (options.csvText) return filasDesdeCsv(options.csvText, options);
      throw new Error("distribuidor_sin_datos");
    },
  };
}

module.exports = {
  parseCsvText,
  filasDesdeCsv,
  parseMoney,
  crearAdaptadorDistribuidor,
};
