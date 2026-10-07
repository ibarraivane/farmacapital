#!/usr/bin/env node
/**
 * Baja el catálogo público de Farmacia Yamin (SicarX shop).
 *
 * Usa Playwright solo para capturar Authorization + X-Branch-id del navegador
 * (la tienda los guarda cifrados). Luego pagina facetSearch vía GraphQL.
 *
 * Uso:
 *   PLAYWRIGHT_BROWSERS_PATH=0 node scripts/competencia/scrape_yamin_sicarx.mjs
 *   node scripts/competencia/scrape_yamin_sicarx.mjs --out pricing/reportes/yamin_YYYYMMDD
 *
 * Requiere: playwright (npm i playwright) y chromium instalado.
 */
import { chromium } from "playwright";
import fs from "fs";
import path from "path";

const BASE = "https://farmaciayamin.sicarx.shop";
const API = "https://api.sicarx.com/shop/v1/";
const PAGE_SIZE = 60;

function outDirFromArgs() {
  const i = process.argv.indexOf("--out");
  if (i >= 0 && process.argv[i + 1]) return path.resolve(process.argv[i + 1]);
  const stamp = new Date().toISOString().slice(0, 10).replace(/-/g, "");
  return path.resolve(`pricing/reportes/yamin_${stamp}`);
}

function buildFacetQuery({ items = PAGE_SIZE, offset } = {}) {
  let filter = `filter:{items:${items}`;
  if (offset) filter += `,offset:"${offset}"`;
  filter += "}";
  return `{
    facetSearch(${filter}) {
      paginationToken
      meta {
        count { lowerBound }
        facet {
          categoryFacet { buckets { key count } }
          departmentFacet { buckets { key count } }
          tagsFacet { buckets { key count } }
        }
      }
      docs {
        uuid available stock autoWeigh bulk type prices
        description imageUrl sku categoryUuid departmentUuid salesUnitUuid lot
      }
    }
  }`;
}

async function gql(auth, branchId, query) {
  const res = await fetch(API, {
    method: "POST",
    headers: {
      "Content-Type": "application/graphql",
      Authorization: auth,
      "X-Branch-id": String(branchId),
      Origin: BASE,
      Referer: `${BASE}/`,
    },
    body: query,
  });
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error(`Non-JSON ${res.status}: ${text.slice(0, 300)}`);
  }
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${text.slice(0, 500)}`);
  if (data.errors) throw new Error(`GQL: ${JSON.stringify(data.errors).slice(0, 500)}`);
  return data.data;
}

async function captureAuth() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    userAgent:
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    locale: "es-MX",
  });
  const page = await context.newPage();
  let auth = null;
  let branchId = null;

  page.on("request", (req) => {
    if (!req.url().includes("api.sicarx.com")) return;
    const h = req.headers();
    auth = auth || h["authorization"] || h["Authorization"] || null;
    branchId = branchId || h["x-branch-id"] || h["X-Branch-id"] || null;
  });

  await page.goto(BASE, { waitUntil: "domcontentloaded", timeout: 90000 });
  for (let i = 0; i < 40 && (!auth || !branchId); i++) {
    await page.waitForTimeout(500);
  }

  if (!auth || !branchId) {
    const decrypted = await page.evaluate(async () => {
      const SECRET = "S1C4RX1111AM2892021";
      await new Promise((resolve, reject) => {
        if (window.CryptoJS) return resolve();
        const s = document.createElement("script");
        s.src = "https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.2.0/crypto-js.min.js";
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
      const CryptoJS = window.CryptoJS;
      const hashKey = (k) => CryptoJS.SHA256(k, { SECRET_KEY: SECRET }).toString();
      const dec = (v) => {
        try {
          return CryptoJS.AES.decrypt(v, SECRET).toString(CryptoJS.enc.Utf8);
        } catch {
          return null;
        }
      };
      const storeRaw =
        sessionStorage.getItem(hashKey("store-storage")) ||
        localStorage.getItem(hashKey("store-storage"));
      const localRaw =
        localStorage.getItem(hashKey("local-storage")) ||
        sessionStorage.getItem(hashKey("local-storage"));
      return { store: storeRaw ? dec(storeRaw) : null, local: localRaw ? dec(localRaw) : null };
    });
    try {
      const store = JSON.parse(decrypted.store || "{}");
      const local = JSON.parse(decrypted.local || "{}");
      auth = auth || store?.state?.store?.payload;
      branchId =
        branchId ||
        local?.state?.selectedBranch?.branchId ||
        store?.state?.store?.branchId;
    } catch {
      /* ignore */
    }
  }

  await browser.close();
  return { auth, branchId };
}

function pickPrice(prices) {
  if (prices == null) return null;
  if (typeof prices === "number") return prices;
  if (typeof prices === "string") {
    const n = Number(prices);
    return Number.isFinite(n) ? n : null;
  }
  if (Array.isArray(prices)) {
    for (const p of prices) {
      const n = pickPrice(p);
      if (n != null) return n;
    }
    return null;
  }
  if (typeof prices === "object") {
    for (const key of ["price1", "netPrice1", "price", "amount", "value"]) {
      if (prices[key] != null) {
        const n = Number(prices[key]);
        if (Number.isFinite(n)) return n;
      }
    }
  }
  return null;
}

async function main() {
  const outDir = outDirFromArgs();
  fs.mkdirSync(outDir, { recursive: true });
  console.log("Capturando auth…");
  const { auth, branchId } = await captureAuth();
  if (!auth || !branchId) {
    console.error("No se pudo capturar Authorization / X-Branch-id");
    process.exit(1);
  }
  console.log("Branch", branchId);

  let content = null;
  try {
    content = await gql(
      auth,
      branchId,
      `{
      content {
        catalog {
          categories { name uuid }
          departments { name order uuid }
        }
      }
    }`
    );
    fs.writeFileSync(path.join(outDir, "content.json"), JSON.stringify(content, null, 2));
  } catch (e) {
    console.warn("content:", e.message);
  }

  const catMap = Object.fromEntries(
    (content?.content?.catalog?.categories || []).map((c) => [c.uuid, c.name])
  );
  const depMap = Object.fromEntries(
    (content?.content?.catalog?.departments || []).map((d) => [d.uuid, d.name])
  );

  const all = [];
  const byUuid = new Map();
  let offset;
  let page = 0;
  let lowerBound = null;

  while (true) {
    page += 1;
    const data = await gql(auth, branchId, buildFacetQuery({ offset }));
    const fs_ = data?.facetSearch;
    if (!fs_) break;
    if (page === 1) lowerBound = fs_.meta?.count?.lowerBound ?? null;
    const docs = fs_.docs || [];
    console.log(`page ${page}: ${docs.length}`);
    for (const d of docs) {
      if (byUuid.has(d.uuid)) continue;
      const row = {
        uuid: d.uuid,
        sku: d.sku,
        nombre: d.description,
        precio: pickPrice(d.prices),
        prices_raw: d.prices,
        stock: d.stock,
        available: d.available,
        imageUrl: d.imageUrl,
        categoryUuid: d.categoryUuid,
        departmentUuid: d.departmentUuid,
        categoria: catMap[d.categoryUuid] || null,
        departamento: depMap[d.departmentUuid] || null,
        type: d.type,
        lot: d.lot,
      };
      byUuid.set(d.uuid, row);
      all.push(row);
    }
    if (!fs_.paginationToken || docs.length === 0) break;
    offset = String(page * PAGE_SIZE);
    if (page > 500) break;
    await new Promise((r) => setTimeout(r, 150));
  }

  fs.writeFileSync(path.join(outDir, "productos.json"), JSON.stringify(all, null, 2));
  const esc = (v) => {
    const s = v == null ? "" : String(v);
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const headers = [
    "sku",
    "nombre",
    "precio",
    "stock",
    "available",
    "departamento",
    "categoria",
    "uuid",
    "imageUrl",
  ];
  fs.writeFileSync(
    path.join(outDir, "productos.csv"),
    [headers.join(","), ...all.map((r) => headers.map((h) => esc(r[h])).join(","))].join("\n")
  );
  const summary = {
    scraped_at: new Date().toISOString(),
    source: BASE,
    branchId,
    lowerBound,
    total: all.length,
    departamentos: Object.values(depMap),
    categorias: Object.values(catMap),
  };
  fs.writeFileSync(path.join(outDir, "summary.json"), JSON.stringify(summary, null, 2));
  console.log(JSON.stringify(summary, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
