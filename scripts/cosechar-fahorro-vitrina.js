#!/usr/bin/env node
/**
 * Cosecha en lote fichas públicas de Fahorro (GraphQL Magento).
 * SKU = EAN. No entra a B2B. No inventa códigos.
 *
 *   node scripts/cosechar-fahorro-vitrina.js
 *
 * Escribe docs/fichas_cosecha_fahorro.json
 */
"use strict";

const fs = require("fs");
const path = require("path");
const https = require("https");
const { esNombreTicket } = require("./alta-bajo-pedido-desde-fichas");

const ROOT = path.resolve(__dirname, "..");
const OUT_JSON = path.join(ROOT, "docs", "fichas_cosecha_fahorro.json");
const PHOTO_DIR = path.join(ROOT, "public", "catalogo-propia");
const MAX_NUEVAS = Number(process.env.FC_COSECHA_MAX || 80);

const BUSQUEDAS = [
  { q: "la roche posay", rubro: "derm" },
  { q: "isdin", rubro: "derm" },
  { q: "heliocare", rubro: "derm" },
  { q: "sesderma", rubro: "derm" },
  { q: "cerave", rubro: "derm" },
  { q: "bioderma", rubro: "derm" },
  { q: "avene", rubro: "derm" },
  { q: "svr sebiaclear", rubro: "derm" },
  { q: "ducray", rubro: "derm" },
  { q: "uriage", rubro: "derm" },
  { q: "a-derma", rubro: "derm" },
  { q: "endocare", rubro: "derm" },
  { q: "leti at4", rubro: "derm" },
  { q: "eucerin", rubro: "derm" },
  { q: "vichy", rubro: "derm" },
  { q: "cetaphil", rubro: "derm" },
  { q: "mustela", rubro: "derm" },
  { q: "birdman", rubro: "nutri" },
  { q: "optimum nutrition gold standard", rubro: "nutri" },
  { q: "muscletech", rubro: "nutri" },
  { q: "falcon proteina", rubro: "nutri" },
  { q: "nebulizador", rubro: "disp" },
  { q: "tensiometro", rubro: "disp" },
  { q: "glucometro", rubro: "disp" },
  { q: "oximetro", rubro: "disp" },
  { q: "omron", rubro: "disp" },
  { q: "accu-chek", rubro: "disp" },
];

const MARCAS = [
  ["la roche-posay", "La Roche-Posay"],
  ["la roche posay", "La Roche-Posay"],
  ["cerave", "CeraVe"],
  ["eucerin", "Eucerin"],
  ["vichy", "Vichy"],
  ["isdin", "Isdin"],
  ["svr", "SVR"],
  ["avene", "Avène"],
  ["avène", "Avène"],
  ["bioderma", "Bioderma"],
  ["heliocare", "Heliocare"],
  ["cetaphil", "Cetaphil"],
  ["ducray", "Ducray"],
  ["a-derma", "A-Derma"],
  ["uriage", "Uriage"],
  ["endocare", "Endocare"],
  ["sesderma", "Sesderma"],
  ["mustela", "Mustela"],
  ["leti", "Leti"],
  ["birdman", "Birdman"],
  ["fitmingo", "Birdman"],
  ["optimum nutrition", "Optimum Nutrition"],
  ["muscletech", "MuscleTech"],
  ["falcon", "Falcon"],
  ["nebucor", "Nebucor"],
  ["omron", "Omron"],
  ["accu-chek", "Accu-Chek"],
  ["accu chek", "Accu-Chek"],
  ["handy", "Handy"],
];

function norm(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function eansYaCargados() {
  const dir = path.join(ROOT, "sql");
  const set = new Set();
  for (const f of fs.readdirSync(dir)) {
    if (!/bajo_pedido/.test(f)) continue;
    // El lote de cosecha se regenera: no lo uses como “ya cargado”.
    if (/cosecha_fahorro/.test(f)) continue;
    const txt = fs.readFileSync(path.join(dir, f), "utf8");
    for (const m of txt.matchAll(/'(\d{8,14})'/g)) set.add(m[1]);
  }
  return set;
}

function gql(query) {
  const body = JSON.stringify({ query });
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: "www.fahorro.com",
        path: "/graphql",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "FarmaCapitalCosecha/1.0",
          "Content-Length": Buffer.byteLength(body),
        },
        timeout: 25000,
      },
      (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => {
          try {
            resolve(JSON.parse(Buffer.concat(chunks).toString("utf8")));
          } catch (err) {
            reject(err);
          }
        });
      }
    );
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function esKit(nombre) {
  const n = norm(nombre);
  if (/\brutina\b/.test(n)) return true;
  if (/\bkit\b/.test(n) && !/\bgluco/.test(n)) return true;
  if (/\bpack\b/.test(n)) return true;
  if (/\s\+\s/.test(nombre)) return true;
  if (/\b\d+\s*ml\b.*\b\d+\s*ml\b/i.test(nombre)) return true;
  return false;
}

function marcaDe(nombre, categorias) {
  const blob = norm([nombre, ...(categorias || [])].join(" "));
  for (const [needle, marca] of MARCAS) {
    if (blob.includes(needle)) return marca;
  }
  return "";
}

function presentacionDe(nombre, rubro) {
  const n = norm(nombre);
  if (/tira/.test(n)) {
    const after = String(nombre || "").match(/tiras?\s*(?:reactivas?\s*)?(\d+)/i);
    const before = String(nombre || "").match(/(\d+)\s*tiras?/i);
    const num = (after && after[1]) || (before && before[1]);
    if (num) return `${num} tiras`;
  }
  // "Fps 50250 ml" (50+ pegado al mililitraje) → quita FPS 50 y deja 250 ml
  const raw = String(nombre || "").replace(/fps\s*50\s*\+?\s*/gi, " ");
  const matches = [...raw.matchAll(/(\d+(?:[.,]\d+)?)\s*(ml|mL|g|gr|grs|kg|cápsulas|capsulas|caps|tabletas|tabs|tiras|piezas?)\b/gi)];
  if (!matches.length) return rubro === "disp" ? "1 pieza" : "";
  const m = matches[matches.length - 1];
  let unit = m[2].toLowerCase();
  if (unit === "gr" || unit === "grs") unit = "g";
  if (/caps/.test(unit)) unit = "cápsulas";
  if (/tab/.test(unit)) unit = "tabletas";
  if (/tira/.test(unit)) unit = "tiras";
  if (/pieza/.test(unit)) unit = "pieza";
  return `${m[1].replace(",", ".")} ${unit}`;
}

function formaDe(nombre, rubro) {
  const n = norm(nombre);
  if (/tira/.test(n)) return "Tiras";
  if (rubro === "disp") return "Aparato";
  if (/serum|suero/.test(n)) return "Sérum";
  if (/\bgel\b/.test(n)) return "Gel";
  if (/crema/.test(n)) return "Crema";
  if (/locion/.test(n)) return "Loción";
  if (/fluido/.test(n)) return "Fluido";
  if (/champu|shampoo/.test(n)) return "Champú";
  if (/capsul|caps\b/.test(n)) return "Cápsula";
  if (/polvo|whey|proteina|creatina/.test(n)) return "Polvo";
  return null;
}

function clasificar(nombre, categorias, rubroHint) {
  const blob = norm([nombre, ...(categorias || [])].join(" "));
  if (/higiene intima|intima 250/.test(blob)) return null;
  if (/(tira reactiva|tiras \d|tiras reactivas)/.test(blob)) {
    return { categoria: "Dispositivo médico", subcategoria: "Tiras" };
  }
  if (rubroHint === "disp" || /(nebuliz|tensiometr|glucometr|oximetr|baumanometr|inspirometr)/.test(blob)) {
    return { categoria: "Dispositivo médico", subcategoria: "Diagnóstico" };
  }
  if (/(whey|creatina|proteina|pre[- ]?entren|optimum nutrition|muscletech|fitmingo|falcon)/.test(blob)) {
    return { categoria: "Suplemento", subcategoria: "Nutrición deportiva" };
  }
  if (rubroHint === "nutri" || /\bbirdman\b/.test(blob)) {
    return { categoria: "Suplemento", subcategoria: null };
  }
  if (rubroHint === "derm" || /(cuidado de la piel|cuidado facial|derm|solar|fotoprotec)/.test(blob)) {
    return { categoria: "Cuidado personal", subcategoria: "Dermatología" };
  }
  return null;
}

function nombreMostrador(nombre) {
  return String(nombre || "")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/fps\s*50\+?(?=\d)/gi, "FPS 50+ ");
}

function slugFoto(marca, ean) {
  const m = norm(marca).replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "prod";
  return `${m}-${ean}.jpg`;
}

function bajar(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https
      .get(url, { headers: { "User-Agent": "FarmaCapitalCosecha/1.0" }, timeout: 25000 }, (res) => {
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          file.close();
          fs.unlink(dest, () => {});
          return bajar(res.headers.location, dest).then(resolve, reject);
        }
        if (res.statusCode !== 200) {
          file.close();
          fs.unlink(dest, () => {});
          return reject(new Error(`HTTP ${res.statusCode}`));
        }
        res.pipe(file);
        file.on("finish", () => file.close(() => resolve(dest)));
      })
      .on("error", (err) => {
        file.close();
        fs.unlink(dest, () => {});
        reject(err);
      });
  });
}

async function buscarPagina(q, page) {
  const query = `{ products(search: ${JSON.stringify(q)}, pageSize: 40, currentPage: ${page}) {
    total_count
    items {
      sku
      name
      url_key
      image { url }
      categories { name }
      price_range { minimum_price { regular_price { value } final_price { value } } }
    }
  } }`;
  const res = await gql(query);
  if (res.errors) throw new Error(res.errors[0].message);
  return res.data.products;
}

function precioDe(item) {
  const p = item.price_range && item.price_range.minimum_price;
  if (!p) return 0;
  const reg = Number(p.regular_price && p.regular_price.value);
  const fin = Number(p.final_price && p.final_price.value);
  if (Number.isFinite(reg) && reg > 0.01) return Math.round(reg);
  if (Number.isFinite(fin) && fin > 0.01) return Math.round(fin);
  return 0;
}

function imagenLimpia(url) {
  const u = String(url || "").split("?")[0];
  return /^https:\/\//i.test(u) ? u : "";
}

async function cosechar() {
  const ya = eansYaCargados();
  const vistos = new Set();
  const candidatos = [];

  for (const { q, rubro } of BUSQUEDAS) {
    let page = 1;
    let total = Infinity;
    while ((page - 1) * 40 < Math.min(total, 120)) {
      const data = await buscarPagina(q, page);
      total = Number(data.total_count) || 0;
      const items = data.items || [];
      if (!items.length) break;
      for (const it of items) {
        const ean = String(it.sku || "").replace(/\D/g, "");
        if (ean.length < 8 || ean.length > 13) continue;
        if (ya.has(ean) || vistos.has(ean)) continue;
        if (esKit(it.name) || esNombreTicket(it.name)) continue;
        const precio = precioDe(it);
        if (precio <= 0) continue;
        const cats = (it.categories || []).map((c) => c.name);
        const marca = marcaDe(it.name, cats);
        if (!marca) continue;
        const clas = clasificar(it.name, cats, rubro);
        if (!clas) continue;
        const presentacion = presentacionDe(it.name, rubro);
        if (!presentacion) continue;
        const img = imagenLimpia(it.image && it.image.url);
        if (!img) continue;
        vistos.add(ean);
        candidatos.push({
          ean,
          nombre: nombreMostrador(it.name),
          marca,
          presentacion,
          categoria: clas.categoria,
          subcategoria: clas.subcategoria,
          forma: formaDe(it.name, rubro),
          precio,
          imagen_src: img,
          fuente: `Fahorro GraphQL · búsqueda «${q}» · SKU=EAN ${ean} · lista $${precio}`,
        });
      }
      page += 1;
      await sleep(120);
    }
  }

  const porMarca = new Map();
  for (const c of candidatos) {
    const arr = porMarca.get(c.marca) || [];
    arr.push(c);
    porMarca.set(c.marca, arr);
  }
  const ordenados = [];
  let seguimos = true;
  while (seguimos && ordenados.length < MAX_NUEVAS) {
    seguimos = false;
    for (const arr of porMarca.values()) {
      if (!arr.length || ordenados.length >= MAX_NUEVAS) continue;
      ordenados.push(arr.shift());
      seguimos = true;
    }
  }

  fs.mkdirSync(PHOTO_DIR, { recursive: true });
  const fichas = [];
  for (const c of ordenados) {
    const file = slugFoto(c.marca, c.ean);
    const dest = path.join(PHOTO_DIR, file);
    try {
      if (!fs.existsSync(dest) || fs.statSync(dest).size < 4000) {
        await bajar(c.imagen_src, dest);
        await sleep(80);
      }
      if (!fs.existsSync(dest) || fs.statSync(dest).size < 4000) continue;
    } catch {
      continue;
    }
    fichas.push({
      ean: c.ean,
      nombre: c.nombre,
      marca: c.marca,
      presentacion: c.presentacion,
      categoria: c.categoria,
      subcategoria: c.subcategoria,
      forma: c.forma,
      precio: c.precio,
      imagen_url: `https://www.farmacapital.mx/catalogo-propia/${file}`,
      fuente: c.fuente,
    });
  }

  fs.writeFileSync(OUT_JSON, `${JSON.stringify(fichas, null, 2)}\n`);
  process.stderr.write(`${fichas.length} fichas → ${OUT_JSON} (de ${candidatos.length} candidatas)\n`);
  return fichas;
}

module.exports = { esKit, marcaDe, clasificar, presentacionDe, nombreMostrador, esNombreTicket };

if (require.main === module) {
  cosechar().catch((err) => {
    process.stderr.write(`${err.message}\n`);
    process.exit(1);
  });
}
