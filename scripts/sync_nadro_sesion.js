/**
 * Cruza el catálogo con iNadro logueado, solo por EAN.
 *
 * - Precio Farmacia (lo que te cobran) → Referencias → Compra, columna Nadro.
 *   Nunca el Público ni el $100 de vitrina.
 * - Foto solo si el producto no tiene imagen_url ni galería.
 *
 *   PLAYWRIGHT_BROWSERS_PATH=0 node scripts/sync_nadro_sesion.js
 *   PLAYWRIGHT_BROWSERS_PATH=0 node scripts/sync_nadro_sesion.js --limit 20
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");
const {
  extraerPrecioFarmaciaTexto,
  elegirPorEan,
  digits,
} = require("../src/lib/monitorPrecios/fuentes/nadro");

const ROOT = path.join(__dirname, "..");
const PROGRESS = path.join(ROOT, "scripts", ".nadro_sync_progress.json");
const SEARCH = "https://i22.nadro.mx/api/io/_v/api/intelligent-search/product_search";
const BUCKET = "productos";
const HOY = () => new Date().toISOString().slice(0, 10);
const CANARY_EAN = "7501314701957";
const DELAY_MS = 1400;

function loadEnv() {
  const env = {};
  for (const line of fs.readFileSync(path.join(ROOT, ".env"), "utf8").split("\n")) {
    const t = line.trim();
    if (!t || t.startsWith("#") || !t.includes("=")) continue;
    const i = t.indexOf("=");
    env[t.slice(0, i).trim()] = t.slice(i + 1).trim().replace(/^['"]|['"]$/g, "");
  }
  return env;
}

function argNum(flag, fallback) {
  const i = process.argv.indexOf(flag);
  if (i < 0) return fallback;
  const n = Number(process.argv[i + 1]);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function headersDe(key) {
  return {
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Content-Type": "application/json",
  };
}

async function rest(url, key, ruta, opts = {}) {
  const r = await fetch(`${url}/rest/v1/${ruta}`, {
    method: opts.method || "GET",
    headers: { ...headersDe(key), ...(opts.headers || {}) },
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });
  const text = await r.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (!r.ok) throw new Error(`supabase ${r.status} ${ruta}: ${String(text).slice(0, 180)}`);
  return data;
}

async function pageAll(url, key, ruta) {
  const out = [];
  let start = 0;
  for (;;) {
    const sep = ruta.includes("?") ? "&" : "?";
    const rows = await rest(url, key, `${ruta}${sep}limit=1000&offset=${start}`);
    if (!Array.isArray(rows) || !rows.length) break;
    out.push(...rows);
    if (rows.length < 1000) break;
    start += 1000;
  }
  return out;
}

function esMedicamento(p) {
  return Boolean(String(p.principio_activo || "").trim())
    || /generico|genérico|marca/i.test(String(p.tipo || ""))
    || /medic/i.test(String(p.categoria || ""));
}

function loadProgress() {
  try {
    return JSON.parse(fs.readFileSync(PROGRESS, "utf8"));
  } catch {
    return { done: {}, stats: {} };
  }
}

function saveProgress(prog) {
  fs.writeFileSync(PROGRESS, JSON.stringify(prog, null, 2));
}

function pdpUrl(hit) {
  const link = String(hit && hit.link || "").trim();
  if (!link) return null;
  if (/^https?:\/\//i.test(link)) return link;
  return `https://i22.nadro.mx/${link.replace(/^\//, "")}`;
}

async function loginNadro(page, user, pass) {
  await page.goto("https://i22.nadro.mx/login", { waitUntil: "domcontentloaded" });
  await page.getByRole("link", { name: /mi cuenta/i }).first().click();
  await page.waitForURL(/login\.nadro\.mx/, { timeout: 20000 });
  await page.getByRole("textbox", { name: /nombre de usuario/i }).fill(user);
  await page.getByRole("textbox", { name: /contraseña/i }).fill(pass);
  await page.getByRole("button", { name: /iniciar sesión/i }).click();
  await page.waitForURL(/i22\.nadro\.mx/, { timeout: 30000 });
  await page.waitForTimeout(4000);
  const ses = await page.evaluate(async () => {
    const data = await (await fetch("/api/sessions?items=*", { credentials: "same-origin" })).json();
    const ns = data.namespaces || {};
    return {
      auth: ns.profile && ns.profile.isAuthenticated && ns.profile.isAuthenticated.value,
      counter: ns.public && ns.public.counter && ns.public.counter.value,
    };
  });
  if (!ses.auth) throw new Error("sesión Nadro no autenticada");
  return ses;
}

async function buscarPorEan(page, ean) {
  const q = digits(ean);
  let lastStatus = 0;
  for (let i = 0; i < 5; i += 1) {
    const res = await page.evaluate(async (url) => {
      const r = await fetch(url, { credentials: "same-origin", headers: { Accept: "application/json" } });
      const text = await r.text();
      let json = null;
      try { json = text ? JSON.parse(text) : null; } catch { json = null; }
      return { status: r.status, json };
    }, `${SEARCH}?q=${encodeURIComponent(q)}&count=8`);
    lastStatus = res.status;
    if (res.status === 429 || res.status === 503) {
      await sleep(5000 * (i + 1));
      continue;
    }
    if (res.status !== 200 || !res.json) return null;
    return elegirPorEan(res.json.products, q);
  }
  throw new Error(`búsqueda ${q} status ${lastStatus}`);
}

async function precioFarmaciaPdp(page, url) {
  await page.goto(url, { waitUntil: "domcontentloaded" });
  try {
    await page.getByText(/Farmacia:/i).first().waitFor({ timeout: 14000 });
  } catch {
    await page.waitForTimeout(2500);
  }
  for (let i = 0; i < 3; i += 1) {
    const texto = await page.evaluate(() => (document.body.innerText || "").replace(/\s+/g, " "));
    const prec = extraerPrecioFarmaciaTexto(texto);
    if (prec && prec.farmacia > 0) return prec;
    await page.waitForTimeout(2000);
  }
  return null;
}

async function subirFoto(url, key, ean, imageUrl) {
  const imgRes = await fetch(imageUrl, {
    headers: { "User-Agent": "FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)" },
  });
  if (!imgRes.ok) return null;
  const buf = Buffer.from(await imgRes.arrayBuffer());
  if (buf.length < 800) return null;
  const ct = String(imgRes.headers.get("content-type") || "image/jpeg").split(";")[0];
  const ext = ct.includes("png") ? "png" : ct.includes("webp") ? "webp" : "jpg";
  const ruta = `distribuidor/nadro-${ean}.${ext}`;
  const up = await fetch(`${url}/storage/v1/object/${BUCKET}/${ruta}`, {
    method: "POST",
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      "Content-Type": ct,
      "x-upsert": "true",
    },
    body: buf,
  });
  if (!up.ok && up.status !== 400) return null;
  return {
    publicUrl: `${url}/storage/v1/object/public/${BUCKET}/${ruta}`,
    ruta,
  };
}

async function main() {
  const env = loadEnv();
  const user = env.NADRO_USER;
  const pass = env.NADRO_PASSWORD;
  const supabaseUrl = (env.REACT_APP_SUPABASE_URL || env.SUPABASE_URL || "").replace(/\/$/, "");
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!user || !pass) {
    console.log("faltan NADRO_USER o NADRO_PASSWORD en .env");
    process.exit(1);
  }
  if (!supabaseUrl || !serviceKey) {
    console.log("faltan REACT_APP_SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY");
    process.exit(1);
  }

  const limit = argNum("--limit", 0);
  const prods = await pageAll(
    supabaseUrl,
    serviceKey,
    "productos?select=id,nombre,codigo_barras,imagen_url,principio_activo,tipo,categoria&activo=eq.true&codigo_barras=not.is.null&order=nombre.asc"
  );
  const gal = new Set((await pageAll(supabaseUrl, serviceKey, "producto_imagenes?select=producto_id")).map((r) => r.producto_id));
  const refsNadro = await pageAll(
    supabaseUrl,
    serviceKey,
    "producto_precios_referencia?select=producto_id,fecha&fuente=eq.nadro"
  );
  const conPrecioHoy = new Set(
    refsNadro.filter((r) => String(r.fecha || "").slice(0, 10) === HOY()).map((r) => r.producto_id)
  );

  const progress = loadProgress();
  const cand = prods.map((p) => {
    const ean = digits(p.codigo_barras);
    const sinFoto = !String(p.imagen_url || "").trim() && !gal.has(p.id);
    return {
      ...p,
      ean,
      necesitaFoto: sinFoto,
      necesitaPrecio: !conPrecioHoy.has(p.id),
      med: esMedicamento(p),
    };
  }).filter((p) => p.ean.length >= 8 && (p.necesitaPrecio || p.necesitaFoto) && !progress.done[p.id]);

  cand.sort((a, b) => {
    if (a.ean === CANARY_EAN) return -1;
    if (b.ean === CANARY_EAN) return 1;
    return Number(b.med) - Number(a.med) || a.id - b.id;
  });
  const lote = limit ? cand.slice(0, limit) : cand;
  console.log(`pendientes: ${cand.length}  este corrida: ${lote.length}  (medicamentos primero, Adel de prueba)`);

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  page.setDefaultTimeout(45000);
  const ses = await loginNadro(page, user, pass);
  console.log(`sesión ok  mostrador ${ses.counter || "?"}`);

  const stats = {
    buscados: 0,
    match: 0,
    precios: 0,
    fotos: 0,
    sinMatch: 0,
    sinFarmacia: 0,
    errores: 0,
  };
  const pendientesPrecio = [];
  let importId = null;

  async function flushPrecios() {
    if (!pendientesPrecio.length) return;
    if (!importId) {
      const imp = await rest(supabaseUrl, serviceKey, "importaciones_referencia", {
        method: "POST",
        headers: { Prefer: "return=representation" },
        body: {
          fuente: "nadro",
          tipo: "compra",
          fecha_lista: HOY(),
          archivo: "nadro_vtex",
          filas_ok: 0,
          filas_error: 0,
          notas: "sesion_playwright",
        },
      });
      importId = Array.isArray(imp) ? imp[0] && imp[0].id : imp && imp.id;
    }
    await rest(supabaseUrl, serviceKey, "producto_precios_referencia", {
      method: "POST",
      headers: { Prefer: "return=minimal" },
      body: pendientesPrecio.splice(0, pendientesPrecio.length).map((x) => ({
        producto_id: x.id,
        fuente: "nadro",
        tipo: "compra",
        precio: x.farmacia,
        fecha: HOY(),
        origen: "job_vtex",
        import_id: importId || null,
        confianza: 95,
        nombre_fuente: x.nombreNadro,
        notas: "rastreo_automatico",
      })),
    });
  }

  for (let i = 0; i < lote.length; i += 1) {
    const p = lote[i];
    stats.buscados += 1;
    try {
      const hit = await buscarPorEan(page, p.ean);
      if (!hit || hit.ean !== p.ean) {
        stats.sinMatch += 1;
        progress.done[p.id] = { ean: p.ean, ok: false, razon: "sin_ean" };
        saveProgress(progress);
        console.log(`  --  ${p.ean}  no está en Nadro  ${String(p.nombre).slice(0, 42)}`);
        await sleep(DELAY_MS);
        continue;
      }
      stats.match += 1;

      if (p.necesitaFoto && hit.imagenes && hit.imagenes[0]) {
        const up = await subirFoto(supabaseUrl, serviceKey, p.ean, hit.imagenes[0]);
        if (up) {
          await rest(supabaseUrl, serviceKey, "producto_imagenes?on_conflict=producto_id,url", {
            method: "POST",
            headers: { Prefer: "return=minimal,resolution=ignore-duplicates" },
            body: [{
              producto_id: p.id,
              url: up.publicUrl,
              storage_path: up.ruta,
              posicion: 1,
              es_principal: true,
              origen: "distribuidor",
            }],
          });
          stats.fotos += 1;
        }
      }

      let farmacia = null;
      const url = pdpUrl(hit);
      if (p.necesitaPrecio && url) {
        const prec = await precioFarmaciaPdp(page, url);
        farmacia = prec && prec.farmacia;
        if (farmacia > 0) {
          pendientesPrecio.push({
            id: p.id,
            farmacia,
            nombreNadro: hit.nombre,
          });
          stats.precios += 1;
          if (pendientesPrecio.length >= 12) await flushPrecios();
        } else {
          stats.sinFarmacia += 1;
        }
      }

      progress.done[p.id] = {
        ean: p.ean,
        ok: true,
        precio: farmacia,
        foto: p.necesitaFoto,
      };
      saveProgress(progress);
      const marca = p.ean === CANARY_EAN ? "  [canario Adel]" : "";
      console.log(
        `  ok  ${p.ean}  ${farmacia != null ? `$${farmacia}` : "sin Farmacia"}  ${String(hit.nombre).slice(0, 40)}${marca}`
      );
    } catch (err) {
      stats.errores += 1;
      console.log(`  !!  ${p.ean}  ${String(err.message || err).slice(0, 160)}`);
      if (/sesión|authenticated|Target closed/i.test(String(err.message || err))) {
        await flushPrecios();
        await browser.close();
        throw err;
      }
      await sleep(4000);
    }
    await sleep(DELAY_MS);
    if ((i + 1) % 25 === 0) {
      await flushPrecios();
      console.log(`  … ${i + 1}/${lote.length}  precios=${stats.precios} fotos=${stats.fotos} sin_ean=${stats.sinMatch}`);
    }
  }

  await flushPrecios();
  await browser.close();
  progress.stats = { ...stats, at: new Date().toISOString(), importId };
  saveProgress(progress);
  console.log(JSON.stringify(stats, null, 2));
}

main().catch((err) => {
  console.log("ERROR", String(err && err.message ? err.message : err).slice(0, 280));
  process.exit(1);
});
