#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const sql = fs.readFileSync(
  path.join(__dirname, "../sql/patch_alta_catalogo_citymark_20260905.sql"),
  "utf8"
);
const rule = fs.readFileSync(
  path.join(__dirname, "../.cursor/rules/ticket-alta-catalogo-obligatoria.mdc"),
  "utf8"
);

if (!/insert into public\.productos/i.test(sql)) {
  throw new Error("City Mark SQL no inserta productos");
}
if (/delete from public\.recepcion_items/i.test(sql)) {
  throw new Error("City Mark alta no debe borrar renglones escaneados");
}
const eans = [...sql.matchAll(/'(0?\d{8,14})'/g)].map((m) => m[1]);
const unique = new Set(eans.filter((e) => e.length >= 8));
if (unique.size < 80) {
  throw new Error(`City Mark SQL trae pocos EANs: ${unique.size}`);
}
if (!/pendiente_alta = false/.test(sql)) {
  throw new Error("Falta relink pendiente_alta = false");
}
if (!/ticket-alta-catalogo-obligatoria/.test(rule) && !/pendiente_alta/.test(rule)) {
  throw new Error("Falta la regla de ticket = altas");
}
if (!/City Mark folio/.test(rule)) {
  throw new Error("La regla debe citar City Mark 20260905");
}
console.log(`ok citymark altas eans=${unique.size}`);
