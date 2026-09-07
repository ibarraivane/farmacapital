#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const csv = fs.readFileSync(
  path.join(__dirname, "../sql/generated/ticket_citymark_20260905.csv"),
  "utf8"
);
const eans = [...new Set(csv.split("\n").slice(1).map((l) => l.split(",")[4]).filter(Boolean))];

async function lookup(ean) {
  const urls = [
    `https://world.openbeautyfacts.org/api/v2/product/${ean}.json`,
    `https://world.openfoodfacts.org/api/v2/product/${ean}.json`,
    `https://world.openproductsfacts.org/api/v2/product/${ean}.json`,
  ];
  for (const url of urls) {
    try {
      const r = await fetch(url, {
        headers: { "User-Agent": "FarmaCapital/1.0 (catalogo@farmacapital.mx)" },
      });
      if (!r.ok) continue;
      const j = await r.json();
      if (j.status !== 1 || !j.product) continue;
      const p = j.product;
      return {
        ean,
        found: true,
        source: url.includes("beauty") ? "obf" : url.includes("food") ? "off" : "opf",
        nombre: p.product_name_es || p.product_name || null,
        marca: p.brands || null,
        cantidad: p.quantity || null,
        imagen: p.image_front_url || p.image_url || null,
      };
    } catch {
      /* next */
    }
  }
  return { ean, found: false };
}

(async () => {
  const out = [];
  for (const ean of eans) {
    const row = await lookup(ean);
    out.push(row);
    process.stderr.write(`${ean} ${row.found ? "OK " + (row.nombre || "") : "—"}\n`);
  }
  const dest = path.join(__dirname, "../sql/generated/citymark_obf_lookup.json");
  fs.writeFileSync(dest, JSON.stringify(out, null, 2));
  console.log(`wrote ${dest} found=${out.filter((x) => x.found).length}/${out.length}`);
})();
