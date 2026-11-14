#!/usr/bin/env node
/**
 * Baja EAN y packshot de b2b.birdman.com y arma el parche de suplementos.
 * El listado products.json no trae el código; la ficha /products/{handle}.js sí.
 *
 *   node scripts/enriquecer-birdman-ean.js
 */
"use strict";

const fs = require("fs");
const https = require("https");
const path = require("path");
const { elegirPackshotShopify, gtinValido } = require("../src/lib/catalogoBajoPedido");
const { cruzarBirdman, sqlPatchBirdman } = require("../src/lib/patchBirdmanEan");

const ROOT = path.join(__dirname, "..");
const CSV_CATALOGO = path.join(ROOT, "docs/catalogos/catalogo_birdman.csv");
const CSV_SALIDA = path.join(ROOT, "docs/catalogos/birdman_ean_imagen.csv");
const SQL_SALIDA = path.join(ROOT, "sql/patch_birdman_ean_imagen_20260923.sql");
const ORIGEN = "https://b2b.birdman.com";
const TIENDA = "https://mx.birdman.com";

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getJson(url, intento = 0) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        "User-Agent": "FarmaCapital/catalogo",
        Accept: "application/json",
      },
    }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        const next = new URL(res.headers.location, url).href;
        res.resume();
        resolve(getJson(next, intento));
        return;
      }
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", async () => {
        const body = Buffer.concat(chunks).toString("utf8");
        if ((res.statusCode === 429 || res.statusCode >= 500) && intento < 5) {
          resolve(sleep(800 * (intento + 1)).then(() => getJson(url, intento + 1)));
          return;
        }
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode} ${url}`));
          return;
        }
        try {
          resolve(JSON.parse(body));
        } catch (err) {
          reject(err);
        }
      });
    });
    req.setTimeout(25000, () => req.destroy(new Error(`timeout ${url}`)));
    req.on("error", (err) => {
      if (intento < 5) resolve(sleep(800 * (intento + 1)).then(() => getJson(url, intento + 1)));
      else reject(err);
    });
  });
}

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
  const headers = split(lines[0]).map((h) => h.trim());
  return lines.slice(1).map((line) => {
    const cols = split(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cols[i] == null ? "" : cols[i]; });
    return row;
  });
}

async function mapPool(items, limit, fn) {
  const out = new Array(items.length);
  let cursor = 0;
  async function worker() {
    while (cursor < items.length) {
      const i = cursor;
      cursor += 1;
      out[i] = await fn(items[i], i);
    }
  }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => worker()));
  return out;
}

function csvCell(value) {
  const s = String(value ?? "");
  if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

async function fichasDe(origen, productos) {
  const fichasJs = await mapPool(productos, 3, async (p) => {
    const ficha = await getJson(`${origen}/products/${p.handle}.js`);
    const imagen = elegirPackshotShopify(ficha);
    return (ficha.variants || []).map((v) => ({
      sku: v.sku || "",
      barcode: v.barcode || "",
      imagen_url: imagen,
      titulo: ficha.title || p.title || "",
    }));
  });
  return fichasJs.flat();
}

async function main() {
  const listado = await getJson(`${ORIGEN}/products.json?limit=250&page=1`);
  const productos = listado.products || [];
  if (!productos.length) throw new Error("b2b.birdman.com no devolvió productos");

  const fichas = await fichasDe(ORIGEN, productos);
  const sinBarcode = new Set(
    fichas.filter((f) => f.sku && !gtinValido(f.barcode)).map((f) => f.sku.toUpperCase()),
  );
  if (sinBarcode.size) {
    const tienda = await getJson(`${TIENDA}/products.json?limit=250&page=1`);
    const candidatos = (tienda.products || []).filter((p) =>
      (p.variants || []).some((v) => sinBarcode.has(String(v.sku || "").toUpperCase())),
    );
    const extra = await fichasDe(TIENDA, candidatos);
    const porSku = new Map(extra.filter((f) => gtinValido(f.barcode)).map((f) => [f.sku.toUpperCase(), f]));
    for (const f of fichas) {
      const hit = porSku.get(String(f.sku || "").toUpperCase());
      if (hit && !gtinValido(f.barcode)) f.barcode = hit.barcode;
    }
  }
  const catalogo = parseCsv(CSV_CATALOGO);
  const filas = cruzarBirdman({ catalogo, fichas });
  const conEan = filas.filter((f) => f.ean).length;
  const conFoto = filas.filter((f) => f.imagen_url).length;

  const header = "sku_birdman,sku_fc,ean,imagen_url,nombre,nota";
  const body = filas.map((f) => [
    f.sku_externo, f.sku, f.ean, f.imagen_url, f.nombre, f.nota,
  ].map(csvCell).join(","));
  fs.writeFileSync(CSV_SALIDA, [header, ...body].join("\n") + "\n");
  fs.writeFileSync(SQL_SALIDA, sqlPatchBirdman(filas));

  const resumen = {
    fichas_b2b: fichas.length,
    suplementos: filas.length,
    con_ean: conEan,
    sin_ean: filas.length - conEan,
    con_foto: conFoto,
    csv: path.relative(ROOT, CSV_SALIDA),
    sql: path.relative(ROOT, SQL_SALIDA),
  };
  console.log(JSON.stringify(resumen, null, 2));
  if (conEan < filas.length * 0.5) {
    throw new Error("Muy pocos EAN válidos; no se publica el parche a ciegas");
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
