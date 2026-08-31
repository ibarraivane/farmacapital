#!/usr/bin/env node
"use strict";

/**
 * La gráfica de Ventas vs meta vive de CSS de columnas (track + fill).
 * Si esas reglas solo corren bajo max-width de teléfono, en la computadora
 * quedan las fechas amontonadas y sin barras. Este check no deja que se repita.
 */

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const errors = [];

function read(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

function fail(msg) {
  errors.push(msg);
}

function stripComments(css) {
  return css.replace(/\/\*[\s\S]*?\*\//g, "");
}

function stripMediaBlocks(css) {
  let out = "";
  let i = 0;
  while (i < css.length) {
    const rel = css.slice(i).search(/@media\b/);
    if (rel < 0) {
      out += css.slice(i);
      break;
    }
    const start = i + rel;
    out += css.slice(i, start);
    const brace = css.indexOf("{", start);
    if (brace < 0) break;
    let depth = 0;
    let j = brace;
    for (; j < css.length; j++) {
      if (css[j] === "{") depth++;
      else if (css[j] === "}") {
        depth--;
        if (depth === 0) {
          j++;
          break;
        }
      }
    }
    i = j;
  }
  return out;
}

function hasRule(css, selectorNeedle, propNeedle) {
  const re = new RegExp(
    selectorNeedle.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") +
      "[^{]*\\{[^}]*" +
      propNeedle.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
    "i",
  );
  return re.test(css);
}

const chart = stripComments(read("src/styles/ventasMeta.css"));
if (/@media\s*\(\s*max-width/i.test(chart)) {
  fail("ventasMeta.css no debe envolver la gráfica en @media (max-width). Eso rompe la computadora.");
}
if (!hasRule(chart, ".fc-ventas-meta-bars", "display: flex")) {
  fail("ventasMeta.css debe poner .fc-ventas-meta-bars { display: flex } fuera de un media query.");
}
if (!hasRule(chart, ".fc-ventas-meta-col", "flex-direction: column")) {
  fail("ventasMeta.css debe poner .fc-ventas-meta-col en columna (si no, las fechas se amontonan).");
}
if (!hasRule(chart, ".fc-ventas-meta-track", "height: 132px")) {
  fail("ventasMeta.css debe dar altura a .fc-ventas-meta-track (132px). Sin eso no hay barras.");
}
if (!hasRule(chart, ".fc-ventas-meta-fill", "position: absolute")) {
  fail("ventasMeta.css debe posicionar .fc-ventas-meta-fill en absoluto.");
}

const chartJsx = read("src/VentasVsMetaChart.jsx");
if (!/import\s+["']\.\/styles\/ventasMeta\.css["']/.test(chartJsx)) {
  fail('VentasVsMetaChart.jsx debe importar "./styles/ventasMeta.css" (así no se pierde en un merge de index.js).');
}

const indexJs = read("src/index.js");
const baseIdx = indexJs.indexOf("ventasMeta.css");
const phoneIdx = indexJs.indexOf("adminPhone.css");
if (baseIdx < 0) {
  fail("src/index.js debe importar styles/ventasMeta.css (base de computadora y tablet).");
}
if (phoneIdx < 0) {
  fail("src/index.js debe seguir importando adminPhone.css (el celular no se toca).");
}
if (baseIdx >= 0 && phoneIdx >= 0 && phoneIdx < baseIdx) {
  fail("En index.js, adminPhone.css debe ir DESPUÉS de ventasMeta.css para solo ajustar el teléfono.");
}

const phoneRaw = read("src/styles/adminPhone.css");
const phoneRoot = stripMediaBlocks(stripComments(phoneRaw));
for (const sel of [".fc-ventas-meta-bars", ".fc-ventas-meta-col", ".fc-ventas-meta-track"]) {
  if (phoneRoot.includes(sel)) {
    fail(`adminPhone.css: ${sel} quedó fuera del @media. Eso pisa la computadora. Déjalo solo bajo max-width.`);
  }
}

if (errors.length) {
  for (const e of errors) console.error(`[check-ventas-meta-desktop] ${e}`);
  process.exit(1);
}

console.log("[check-ventas-meta-desktop] OK");
