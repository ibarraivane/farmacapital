#!/usr/bin/env node
/**
 * Cruza un export de Mepiel por EAN contra el catálogo que ya tenemos
 * (Dermaexpress usa el EAN como sku). No da de alta productos nuevos.
 *
 *   node scripts/cruzar-mepiel-por-ean.js docs/catalogos/catalogo_mepiel.csv
 *
 * Columnas: ean (o codigo_barras / sku numérico), costo, nombre, imagen_url.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { gtinValido } = require("../src/lib/catalogoBajoPedido");
const { cruzarMepiel, sqlReferenciaMepiel } = require("../src/lib/cruceMepiel");

const ROOT = path.join(__dirname, "..");
const DERMA = path.join(ROOT, "docs/catalogos/catalogo_dermaexpress.csv");

function parseCsv(filePath) {
  const raw = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  const lines = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < raw.length; i += 1) {
    const ch = raw[i];
    if (ch === '"') {
      if (inQ && raw[i + 1] === '"') { cur += '"'; i += 1; }
      else inQ = !inQ;
    } else if ((ch === "\n" || ch === "\r") && !inQ) {
      if (ch === "\r" && raw[i + 1] === "\n") i += 1;
      if (cur.trim()) lines.push(cur);
      cur = "";
    } else cur += ch;
  }
  if (cur.trim()) lines.push(cur);
  const split = (line) => {
    const out = [];
    let cell = "";
    let q = false;
    for (let i = 0; i < line.length; i += 1) {
      const ch = line[i];
      if (ch === '"') {
        if (q && line[i + 1] === '"') { cell += '"'; i += 1; }
        else q = !q;
      } else if (ch === "," && !q) { out.push(cell); cell = ""; }
      else cell += ch;
    }
    out.push(cell);
    return out;
  };
  const headers = split(lines[0]).map((h) => h.trim().toLowerCase());
  return lines.slice(1).map((line) => {
    const cols = split(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cols[i] == null ? "" : cols[i]; });
    return row;
  });
}

function csvCell(value) {
  const s = String(value ?? "");
  if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

function main() {
  const entrada = process.argv[2];
  if (!entrada) {
    console.error("Falta el CSV de Mepiel. Ejemplo: node scripts/cruzar-mepiel-por-ean.js docs/catalogos/catalogo_mepiel.csv");
    console.error("La tienda pública responde 403 desde este servidor; el export (ean, costo, nombre) tiene que venir de la cuenta.");
    process.exit(2);
  }
  const filas = parseCsv(path.resolve(entrada));
  const derma = parseCsv(DERMA);
  const eanConocidos = derma.map((r) => r.sku).filter((s) => gtinValido(s));
  const { enCatalogo, pendientes } = cruzarMepiel({ filas, eanConocidos });

  const reporte = path.join(ROOT, "docs/catalogos/mepiel_cruce_ean.csv");
  const lineas = ["estado,ean,costo,nombre,motivo"].concat(
    enCatalogo.map((f) => ["en_catalogo", f.ean, f.costo, f.nombre, ""].map(csvCell).join(",")),
    pendientes.map((f) => ["pendiente", f.ean, f.costo ?? "", f.nombre, f.motivo].map(csvCell).join(",")),
  );
  fs.writeFileSync(reporte, lineas.join("\n") + "\n");

  const sql = sqlReferenciaMepiel(enCatalogo);
  const sqlPath = path.join(ROOT, "sql/patch_mepiel_referencia_por_ean.sql");
  if (sql) fs.writeFileSync(sqlPath, sql);

  console.log(JSON.stringify({
    filas: filas.length,
    en_catalogo: enCatalogo.length,
    con_costo: enCatalogo.filter((f) => f.costo).length,
    pendientes: pendientes.length,
    reporte: path.relative(ROOT, reporte),
    sql: sql ? path.relative(ROOT, sqlPath) : null,
  }, null, 2));
}

main();
