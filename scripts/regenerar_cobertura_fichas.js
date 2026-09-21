#!/usr/bin/env node
/**
 * Regenera cobertura de fichas desde un CSV de catálogo vivo.
 * Omite columnas de costo. No versionar exportaciones con precios de compra.
 *
 * Uso:
 *   node scripts/regenerar_cobertura_fichas.js sql/preview_catalogo_campos_y_precios.csv
 */
const fs = require("fs");
const path = require("path");

const COST_COLS = /costo|cost|compra|proveedor/i;

function fold(s) {
  return String(s ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
}

function claveDe(principio) {
  return fold(principio)
    .split(/\s*(?:\+|\/|&| y )\s*/i)
    .map((p) => p.replace(/[^a-z0-9]+/g, " ").replace(/\s+/g, " ").trim())
    .filter(Boolean)
    .join(" + ");
}

function viaDe(forma, presentacion) {
  const blob = fold(`${forma || ""} ${presentacion || ""}`);
  if (/oftal|colirio|ojo/i.test(blob)) return "oftalmica";
  if (/otic|oido/i.test(blob)) return "otica";
  if (/nasal|nariz/i.test(blob)) return "nasal";
  if (/vagin/i.test(blob)) return "vaginal";
  if (/inyect|ampolleta|ampolla|im\b|iv\b|subcut/i.test(blob)) return "inyectable";
  if (/inhal|aerosol|nebuliz/i.test(blob)) return "inhalada";
  if (/crema|gel|unguent|pomada|locion|topica|cutane|parche|champu|shampoo/i.test(blob)) return "topica";
  return "oral";
}

function tipoDe(row) {
  const clave = claveDe(row.principio_activo);
  const cat = fold(row.categoria);
  const blob = [row.nombre, row.marca, row.subcategoria, row.categoria].filter(Boolean).join(" ");
  if (/dispositivo|oximetro|termometro|monitor|glucometro/i.test(blob) || cat.includes("dispositivo")) {
    return { tipo_ficha: "equipo_medico", clave_monografia: clave || "", via: "", revisar_clasificacion: false };
  }
  if (/venda|gasa|jering|curacion|algodon|guante|cubreboca/i.test(blob) || cat.includes("botiquin")) {
    return { tipo_ficha: "material", clave_monografia: clave || "", via: "", revisar_clasificacion: false };
  }
  if (/derma|cerave|laroche|isdin|eucerin|avene|bioderma/i.test(blob) && (cat.includes("cuidado") || !clave)) {
    return { tipo_ficha: "dermocosmetico", clave_monografia: "", via: "", revisar_clasificacion: false };
  }
  if (/vitamina|suplement|proteina|colageno|herbolario|hidratacion/i.test(blob + cat)) {
    return { tipo_ficha: "suplemento", clave_monografia: clave || "", via: "", revisar_clasificacion: false };
  }
  if (cat.includes("cuidado") || cat.includes("higiene")) {
    return { tipo_ficha: "cuidado_personal", clave_monografia: "", via: "", revisar_clasificacion: !clave };
  }
  return {
    tipo_ficha: clave ? "medicamento" : "cuidado_personal",
    clave_monografia: clave,
    via: clave ? viaDe(row.forma_farmaceutica, row.presentacion) : "",
    revisar_clasificacion: !clave,
  };
}

function parseCsv(text) {
  const lines = text.replace(/^\uFEFF/, "").split(/\r?\n/).filter(Boolean);
  if (!lines.length) return [];
  const headers = splitCsvLine(lines[0]);
  return lines.slice(1).map((line) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cells[i] ?? ""; });
    return row;
  });
}

function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let q = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (ch === '"') {
      if (q && line[i + 1] === '"') { cur += '"'; i += 1; }
      else q = !q;
    } else if (ch === "," && !q) {
      out.push(cur);
      cur = "";
    } else cur += ch;
  }
  out.push(cur);
  return out;
}

function toCsv(rows) {
  const headers = [
    "producto_id", "sku", "nombre", "principio_activo", "forma_farmaceutica",
    "categoria", "tipo_ficha", "clave_monografia", "via", "revisar_clasificacion",
  ];
  const esc = (v) => {
    const s = v == null ? "" : String(v);
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  return [headers.join(","), ...rows.map((r) => headers.map((h) => esc(r[h])).join(","))].join("\n") + "\n";
}

function main() {
  const src = process.argv[2];
  if (!src) {
    console.error("Uso: node scripts/regenerar_cobertura_fichas.js <catalogo.csv>");
    process.exit(1);
  }
  const raw = fs.readFileSync(src, "utf8");
  const header = raw.split(/\r?\n/)[0] || "";
  const banned = header.split(",").filter((h) => COST_COLS.test(h));
  if (banned.length) {
    console.warn("Aviso: el CSV de origen tiene columnas de costo; no se copian a la cobertura:", banned.join(", "));
  }
  const rows = parseCsv(raw).map((r) => {
    const t = tipoDe(r);
    return {
      producto_id: r.id || r.producto_id,
      sku: r.sku || "",
      nombre: r.nombre || "",
      principio_activo: r.principio_activo || "",
      forma_farmaceutica: r.forma_farmaceutica || "",
      categoria: r.categoria || "",
      ...t,
    };
  });
  const dest = path.join(__dirname, "../docs/catalogo-fichas/cobertura_catalogo.csv");
  fs.writeFileSync(dest, toCsv(rows));
  const revisar = rows.filter((r) => r.revisar_clasificacion).length;
  console.log(`Escribí ${rows.length} filas en ${dest} (${revisar} a revisar).`);
}

if (require.main === module) main();
