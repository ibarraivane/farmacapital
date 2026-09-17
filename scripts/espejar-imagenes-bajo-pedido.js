#!/usr/bin/env node
/**
 * Baja packshots del manifiesto a public/catalogo-propia/.
 * Rechaza hosts Fahorro y placeholders chicos. No pisa una foto ya propia.
 *
 *   node scripts/espejar-imagenes-bajo-pedido.js [--limit N]
 */
"use strict";

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { spawnSync } = require("child_process");

const ROOT = path.join(__dirname, "..");
const DEST = process.argv.includes("--public")
  ? path.join(ROOT, "public/catalogo-propia")
  : path.join(ROOT, "catalogo-imagenes/bajo-pedido");
const CSV = path.join(ROOT, "docs/catalogos/fotos_bajo_pedido.csv");
const PLACEHOLDER_MD5 = "59370f17d7cac03761209f4b0cf46374";

function parseFotosCsv(filePath) {
  const raw = fs.readFileSync(filePath, "utf8").trim().split(/\r?\n/);
  const rows = [];
  for (const line of raw.slice(1)) {
    const m = line.match(/^([^,]+),([^,]+),([^,]+),([^,]*),([^,]*),(.*)$/);
    if (!m) continue;
    rows.push({
      slug: m[1],
      fuente: m[2],
      url: m[3],
      sku: m[4],
      ean: m[5],
      nombre: m[6].replace(/^"|"$/g, "").replace(/""/g, '"'),
    });
  }
  return rows;
}

function esHostCompetencia(url) {
  try {
    const host = new URL(url).hostname;
    return /(^|\.)fahorro\.com$/i.test(host);
  } catch {
    return true;
  }
}

function main() {
  const limitArg = process.argv.indexOf("--limit");
  const limit = limitArg >= 0 ? Number(process.argv[limitArg + 1]) : Infinity;
  if (!fs.existsSync(CSV)) {
    console.error("Falta docs/catalogos/fotos_bajo_pedido.csv — corre generar-alta-bajo-pedido.js");
    process.exit(2);
  }
  fs.mkdirSync(DEST, { recursive: true });
  const rows = parseFotosCsv(CSV);
  let ok = 0;
  let skip = 0;
  let fail = 0;
  const pendientes = [];
  for (const row of rows) {
    if (ok + skip + fail >= limit) break;
    const dest = path.join(DEST, `${row.slug}.jpg`);
    if (fs.existsSync(dest) && fs.statSync(dest).size > 2000) {
      skip += 1;
      continue;
    }
    if (!row.url || esHostCompetencia(row.url)) {
      fail += 1;
      pendientes.push({ ...row, motivo: "url_competencia_o_vacia" });
      continue;
    }
    const tmp = `${dest}.part`;
    const r = spawnSync("curl", ["-fsSL", "--max-time", "25", "-o", tmp, row.url], { encoding: "utf8" });
    if (r.status !== 0 || !fs.existsSync(tmp)) {
      fail += 1;
      pendientes.push({ ...row, motivo: "download_fail" });
      continue;
    }
    const buf = fs.readFileSync(tmp);
    const md5 = crypto.createHash("md5").update(buf).digest("hex");
    if (md5 === PLACEHOLDER_MD5 || buf.length < 1500 || buf.length === 6334) {
      fs.unlinkSync(tmp);
      fail += 1;
      pendientes.push({ ...row, motivo: "placeholder" });
      continue;
    }
    fs.renameSync(tmp, dest);
    ok += 1;
  }
  const pendPath = path.join(ROOT, "docs/catalogos/fotos_pendientes_bajo_pedido.csv");
  fs.writeFileSync(
    pendPath,
    ["slug,fuente,sku,motivo,nombre"].concat(
      pendientes.map((p) => [p.slug, p.fuente, p.sku, p.motivo, `"${p.nombre.replace(/"/g, '""')}"`].join(",")),
    ).join("\n"),
  );
  console.log(JSON.stringify({ ok, skip, fail, dest: DEST }, null, 2));
}

main();
