#!/usr/bin/env node
/**
 * Extrae productos de tickets PDF con Claude → Excel homologado + SQL de carga.
 *
 * Uso:
 *   node scripts/claude_tickets_a_excel_sql.js
 *   node scripts/claude_tickets_a_excel_sql.js --force   # re-OCR Claude aunque haya cache
 *
 * Requiere REACT_APP_ANTHROPIC_KEY o ANTHROPIC_API_KEY en .env
 */

"use strict";

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const ROOT = path.resolve(__dirname, "..");
const TICKETS_DIR = path.join(
  process.env.HOME || "",
  "Library/CloudStorage/Dropbox/FarmaCapital/Tickets"
);
const SOURCE_XLSX = path.join(
  TICKETS_DIR,
  "FarmaCapital_extraccion_todos_los_PDFs_08-08-2026.xlsx"
);
const OUTPUT_XLSX = path.join(
  TICKETS_DIR,
  "FarmaCapital_inventario_homologado_completo.xlsx"
);
const CACHE_DIR = path.join(ROOT, ".tmp_claude_extractions");
const SQL_DIR = path.join(ROOT, "sql", "generated");

const {
  extraerConClaude,
  normalizarProducto,
  productosFromParsedJson,
  safeJsonParse,
} = require("../lib/inventarioProductos");

let XLSX;
try {
  XLSX = require("xlsx");
} catch {
  console.error("Instala: npm install xlsx --save-dev");
  process.exit(1);
}

const FORCE = process.argv.includes("--force");
const MARGEN_VENTA = 0.35; // 35% sobre costo (ajustable antes de ejecutar SQL)
const MAX_BYTES_SQL = 42 * 1024;

const TICKETS = [
  {
    pdf: "Bodega F-42.pdf",
    proveedor: "Bodega F-42 Ejidos del Moral",
    ubicacion: "Iztapalapa, CDMX",
    ticket: "77827",
    fecha: "2026-08-08",
    fallbackMaestro: false,
  },
  {
    pdf: "Equilibrio.pdf",
    proveedor: "Equilibrio Farmacéutico",
    ubicacion: "Central de Abasto, CDMX",
    ticket: "440393",
    fecha: "2026-08-08",
    fallbackMaestro: true,
  },
  {
    pdf: "El surtidor de su farmacia.pdf",
    proveedor: "El Surtidor de su Farmacia",
    ubicacion: "Central de Abasto, Iztapalapa, CDMX",
    ticket: "112558",
    fecha: "2026-08-08",
    fallbackMaestro: false,
  },
  {
    pdf: "Farma Mx.pdf",
    proveedor: "Farma MX",
    ubicacion: "Iztapalapa, CDMX",
    ticket: "FMX-080826",
    fecha: "2026-08-08",
    fallbackMaestro: false,
  },
  {
    pdf: "FarmaLive.pdf",
    proveedor: "FarmaLive",
    ubicacion: "Chinampac de Juárez, Iztapalapa, CDMX",
    ticket: "FL-080826",
    fecha: "2026-08-08",
    fallbackMaestro: false,
  },
  {
    pdf: "IFC 1.pdf",
    proveedor: "IFC F8 Tienda",
    ubicacion: "Contreras, CDMX",
    ticket: "IFC1-080826",
    fecha: "2026-08-08",
    folio: "118217",
    fallbackMaestro: false,
  },
  {
    pdf: "IFC 2.pdf",
    proveedor: "IFC F8 Tienda",
    ubicacion: "Contreras, CDMX",
    ticket: "IFC2-080826",
    fecha: "2026-08-08",
    folio: "118216",
    fallbackMaestro: false,
  },
];

const HEADERS = [
  "Línea ticket",
  "Código de barras",
  "Tipo de producto",
  "Marca",
  "Nombre / variante",
  "Presentación",
  "Contenido",
  "Unidad",
  "Cantidad",
  "Costo unitario s/IVA",
  "Costo total línea s/IVA",
  "Caducidad",
  "Lote",
  "Proveedor / lugar de compra",
  "Ubicación proveedor",
  "Fecha compra",
  "N.º ticket / orden",
  "Descripción original ticket",
  "Estado captura",
  "Notas",
];

const CLAUDE_PROMPT = `Eres un extractor experto de tickets de compra farmacéutica en México.

Analiza TODO el PDF (todas las páginas) y devuelve ÚNICAMENTE JSON válido (sin markdown):
{
  "productos": [
    {
      "linea": 1,
      "codigo": "7501090131234",
      "nombre": "AMOXICILINA",
      "marca": "FARMALAB",
      "presentacion": "40 CAPSULAS",
      "contenido": "500",
      "unidad": "MG",
      "precio": 85.50,
      "cantidad": 2,
      "caducidad": "2028-12-15",
      "lote": "A123456"
    }
  ]
}

Reglas estrictas:
- Incluye CADA línea de producto del ticket, todas las páginas.
- codigo = código de barras EAN (8-14 dígitos) si aparece; si no, null.
- nombre en MAYÚSCULAS, sin precios ni cantidades en el nombre.
- precio = costo unitario s/IVA en MXN (número decimal).
- cantidad = piezas compradas (entero >= 1). NO confundas presentación (ej. "100 TAB") con cantidad.
- Si el ticket dice "233 artículos" son 233 líneas; "467 cantidades" es suma de piezas.
- caducidad ISO YYYY-MM-DD o null; lote texto o null.
- linea = número de renglón en el ticket si visible, si no secuencial desde 1.
- Si no hay productos legibles: {"productos":[]}`;

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return;
  for (const line of fs.readFileSync(filePath, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq <= 0) continue;
    const key = trimmed.slice(0, eq).trim();
    let val = trimmed.slice(eq + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    if (!process.env[key]) process.env[key] = val;
  }
}

function getApiKey() {
  return (
    process.env.ANTHROPIC_API_KEY ||
    process.env.REACT_APP_ANTHROPIC_API_KEY ||
    process.env.REACT_APP_ANTHROPIC_KEY ||
    ""
  ).trim();
}

function sqlQuote(s) {
  return `'${String(s ?? "").replace(/'/g, "''")}'`;
}

function sqlTextOrNull(s, maxLen = 500) {
  const t = String(s ?? "").trim();
  if (!t) return "NULL";
  return sqlQuote(t.slice(0, maxLen));
}

function sqlNumOrNull(n) {
  if (n == null || n === "" || Number.isNaN(Number(n))) return "NULL";
  return String(Number(n));
}

function precioVenta(costo) {
  const c = Number(costo) || 0;
  if (c <= 0) return 0;
  return Math.ceil(c * (1 + MARGEN_VENTA) * 100) / 100;
}

function skuFor(row) {
  const bc = String(row.codigo_barras || "").replace(/\D/g, "");
  if (bc.length >= 8) return `FC-${bc.slice(-8)}`;
  const slug = crypto
    .createHash("md5")
    .update(`${row.ticket}|${row.nombre}|${row.linea}`)
    .digest("hex")
    .slice(0, 8)
    .toUpperCase();
  return `FC-${slug}`;
}

function inferTipo(nombre) {
  const n = String(nombre || "").toUpperCase();
  if (/CAPS|TAB|GRAG|JARABE|SOL |SUSP|INY|MEDIC|HIS/.test(n)) return "Medicamento";
  if (/DESOD|DEO |JBN|JABON|SH |CRA |CHAMP/.test(n)) return "Higiene personal";
  if (/JERINGA|CATETER|VENDA|CINTA|PROTEC|GUANTE/.test(n)) return "Material médico";
  return "Producto";
}

function loadMaestroEquilibrio() {
  if (!fs.existsSync(SOURCE_XLSX)) return [];
  const wb = XLSX.readFile(SOURCE_XLSX);
  const ws = wb.Sheets["Compras_maestro"];
  if (!ws) return [];
  const rows = XLSX.utils.sheet_to_json(ws, { defval: null });
  return rows
    .filter((r) => String(r["N.º ticket / orden"]) === "440393")
    .map((r) => ({
      linea: r["Línea ticket"],
      codigo_barras: r["Código de barras"] ? String(r["Código de barras"]).replace(/\D/g, "") : null,
      nombre: r["Nombre / variante"] || r["Descripción original ticket"],
      marca: r["Marca"],
      presentacion: r["Presentación"],
      contenido: r["Contenido"],
      unidad: r["Unidad"] || "UNIT",
      cantidad: Number(r["Cantidad"]) || 1,
      precio: Number(r["Costo unitario s/IVA"]) || 0,
      caducidad: r["Caducidad"],
      lote: r["Lote"],
      proveedor: r["Proveedor / lugar de compra"],
      ubicacion: r["Ubicación proveedor"],
      fecha_compra: r["Fecha compra"],
      ticket: "440393",
      descripcion: r["Descripción original ticket"],
      estado: "Capturado de ticket (maestro)",
      notas: r["Notas"] || "Equilibrio.pdf — maestro manual",
    }));
}

function maestroRowToExcel(p, meta, idx) {
  const qty = Math.max(1, Math.round(Number(p.cantidad) || 1));
  const unit = Number(p.precio) || 0;
  const subtotal = Math.round(unit * qty * 100) / 100;
  return [
    p.linea ?? idx + 1,
    p.codigo_barras || p.codigo || null,
    inferTipo(p.nombre),
    p.marca || null,
    p.nombre,
    p.presentacion || null,
    p.contenido != null ? String(p.contenido) : null,
    p.unidad || "UNIT",
    qty,
    unit,
    subtotal,
    p.caducidad || null,
    p.lote || null,
    meta.proveedor,
    meta.ubicacion,
    meta.fecha,
    meta.ticket,
    p.descripcion || p.nombre,
    p.estado || "Claude PDF",
    p.notas || meta.pdf,
  ];
}

function normalizedToRow(p, meta, idx) {
  return maestroRowToExcel(
    {
      linea: idx + 1,
      codigo_barras: p.codigo_barras || p.codigo,
      nombre: p.nombre,
      marca: p.marca,
      presentacion: p.presentacion,
      contenido: p.contenido,
      unidad: p.unidad,
      cantidad: p.cantidad,
      precio: p.precio,
      caducidad: p.caducidad,
      lote: p.lote,
      descripcion: p.nombre,
      estado: "Claude PDF",
      notas: `${meta.pdf}${meta.folio ? ` folio ${meta.folio}` : ""}`,
    },
    meta,
    idx
  );
}

async function extractPdfWithClaude(apiKey, pdfPath, cachePath) {
  if (!FORCE && fs.existsSync(cachePath)) {
    const cached = JSON.parse(fs.readFileSync(cachePath, "utf8"));
    console.log(`  cache: ${path.basename(cachePath)} (${cached.productos?.length || 0} productos)`);
    return cached.productos || [];
  }

  const buf = fs.readFileSync(pdfPath);
  const mb = buf.length / (1024 * 1024);
  console.log(`  Claude OCR ${path.basename(pdfPath)} (${mb.toFixed(1)} MB)...`);

  const pdfBase64 = buf.toString("base64");
  let productos = await extraerConClaude(apiKey, pdfBase64, {
    prompt: CLAUDE_PROMPT,
    max_tokens: 16384,
  });

  if (productos.length === 0) {
    console.warn(`  ⚠ Sin productos Claude para ${path.basename(pdfPath)}`);
  } else {
    console.log(`  → ${productos.length} productos`);
  }

  fs.writeFileSync(
    cachePath,
    JSON.stringify({ pdf: path.basename(pdfPath), extracted_at: new Date().toISOString(), productos }, null, 2)
  );
  return productos;
}

function buildSqlFiles(rows) {
  fs.mkdirSync(SQL_DIR, { recursive: true });
  const stamp = new Date().toISOString().slice(0, 10).replace(/-/g, "");
  const base = `carga_tickets_${stamp}`;

  const header = `-- ============================================================
-- FarmaCapital — Carga inventario desde tickets 2026-08-08
-- Generado: ${new Date().toISOString()}
-- Filas: ${rows.length}
-- Margen venta aplicado: ${(MARGEN_VENTA * 100).toFixed(0)}% sobre costo unitario
--
-- INSTRUCCIONES:
-- 1) Haz backup (GitHub Action o pg_dump).
-- 2) Opcional: ejecuta sql/reset_pre_lanzamiento.sql (v_confirmar := true)
--    para limpiar inventario de prueba.
-- 3) Ejecuta estos fragmentos EN ORDEN en Supabase SQL Editor.
-- 4) Al final: sql/patch_resync_productos_stock_from_lotes.sql
-- ============================================================

begin;
`;

  const footer = `
-- Resync stock desde lotes
update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)
  from public.lotes l
  where l.producto_id = p.id and coalesce(l.activo, true) = true
), 0);

commit;
`;

  const chunks = [];
  let current = header;
  current += `
create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

`;

  for (const r of rows) {
    const bc = r.codigo_barras ? String(r.codigo_barras).replace(/\D/g, "") : "";
    const sku = skuFor(r);
    const costo = Number(r.costo_unitario) || 0;
    const precio = precioVenta(costo);
    const qty = Math.max(1, Math.round(Number(r.cantidad) || 1));
    const lote = r.lote || `TK-${r.ticket}-${r.linea}`;
    const cad = r.caducidad ? sqlQuote(String(r.caducidad).slice(0, 10)) : "NULL";
    const proveedor = sqlQuote(r.proveedor);
    const desc = sqlQuote(
      [r.nombre, r.presentacion, r.ticket ? `Ticket ${r.ticket}` : ""].filter(Boolean).join(" — ")
    );

    const productoJson = `jsonb_build_object(
      'nombre', ${sqlTextOrNull(r.nombre, 200)},
      'sku', ${sqlQuote(sku)},
      'codigo_barras', ${bc ? sqlQuote(bc) : "NULL"},
      'categoria', ${sqlQuote(r.categoria || "GENERAL")},
      'tipo', ${sqlQuote(r.tipo || "MEDICAMENTO")},
      'descripcion', ${desc},
      'costo', ${sqlNumOrNull(costo)},
      'precio', ${sqlNumOrNull(precio)},
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    )`;

    let block;
    if (bc) {
      block = `
-- ${r.ticket} L${r.linea} ${String(r.nombre).slice(0, 50)}
do $$
declare v_pid bigint; v_lid bigint;
begin
  select producto_id into v_pid from _fc_carga_map where codigo_barras = ${sqlQuote(bc)};
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      ${productoJson},
      ${qty},
      ${sqlQuote(lote)},
      ${cad},
      ${sqlNumOrNull(costo)},
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id) values (${sqlQuote(bc)}, v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, ${qty}, ${sqlQuote(lote)}, ${cad}, ${sqlNumOrNull(costo)}, ${proveedor}, null
    );
  end if;
end $$;
`;
    } else {
      block = `
-- ${r.ticket} L${r.linea} ${String(r.nombre).slice(0, 50)} (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  ${productoJson},
  ${qty},
  ${sqlQuote(lote)},
  ${cad},
  ${sqlNumOrNull(costo)},
  null
);
`;
    }

    if (Buffer.byteLength(current + block, "utf8") > MAX_BYTES_SQL) {
      chunks.push(current);
      current = "begin;\n\ncreate temp table if not exists _fc_carga_map (\n  codigo_barras text primary key,\n  producto_id bigint\n) on commit drop;\n\n";
    }
    current += block;
  }

  current += footer;
  chunks.push(current);

  const paths = [];
  chunks.forEach((content, i) => {
    const part = String(i + 1).padStart(4, "0");
    const filePath = path.join(SQL_DIR, `${base}_part${part}.sql`);
    fs.writeFileSync(filePath, content, "utf8");
    paths.push(filePath);
  });

  const manifest = paths.map((p) => path.basename(p)).join("\n");
  fs.writeFileSync(path.join(SQL_DIR, `${base}_manifest.txt`), manifest + "\n");
  return paths;
}

async function main() {
  loadEnvFile(path.join(ROOT, ".env"));
  loadEnvFile(path.join(ROOT, ".env.local"));

  const apiKey = getApiKey();
  if (!apiKey) {
    console.warn("Sin ANTHROPIC_API_KEY — usando Vision OCR (Python)...");
    return runVisionFallback();
  }

  fs.mkdirSync(CACHE_DIR, { recursive: true });

  const allExcelRows = [];
  const sqlRows = [];
  const stats = [];
  let claudeFailures = 0;

  for (const meta of TICKETS) {
    const pdfPath = path.join(TICKETS_DIR, meta.pdf);
    if (!fs.existsSync(pdfPath)) {
      console.warn(`Saltando PDF inexistente: ${pdfPath}`);
      continue;
    }

    console.log(`\n=== ${meta.ticket} | ${meta.proveedor} ===`);
    let productosRaw = [];

    if (meta.fallbackMaestro) {
      const manual = loadMaestroEquilibrio();
      if (manual.length > 0 && !FORCE) {
        console.log(`  Usando maestro manual Equilibrio (${manual.length} filas)`);
        productosRaw = manual;
      }
    }

    if (productosRaw.length === 0) {
      const cachePath = path.join(
        CACHE_DIR,
        `${meta.pdf.replace(".pdf", "")}.json`
      );
      try {
        productosRaw = await extractPdfWithClaude(apiKey, pdfPath, cachePath);
      } catch (e) {
        claudeFailures += 1;
        console.error(`  Error Claude: ${e.message}`);
        if (meta.fallbackMaestro) {
          productosRaw = loadMaestroEquilibrio();
          console.log(`  Fallback maestro: ${productosRaw.length} filas`);
        }
      }
    }

    const normalized = [];
    if (Array.isArray(productosRaw) && productosRaw[0]?.ticket === "440393") {
      for (let i = 0; i < productosRaw.length; i++) {
        const p = productosRaw[i];
        normalized.push({
          ...p,
          codigo_barras: p.codigo_barras || null,
          nombre: String(p.nombre || "").toUpperCase(),
        });
      }
    } else {
      for (const raw of productosRaw) {
        const p = normalizarProducto(raw, meta.proveedor);
        if (p) normalized.push(p);
      }
    }

    const ticketRows = normalized.map((p, idx) => normalizedToRow(p, meta, idx));
    allExcelRows.push(...ticketRows);

    for (const p of normalized) {
      sqlRows.push({
        linea: p.linea || sqlRows.length + 1,
        codigo_barras: p.codigo_barras || p.codigo || null,
        nombre: p.nombre,
        presentacion: p.presentacion,
        cantidad: p.cantidad,
        costo_unitario: p.precio,
        caducidad: p.caducidad,
        lote: p.lote,
        proveedor: meta.proveedor,
        ticket: meta.ticket,
        categoria: p.categoria || "GENERAL",
        tipo: inferTipo(p.nombre) === "Medicamento" ? "MEDICAMENTO" : "GENERICO",
      });
    }

    const pieces = ticketRows.reduce((s, r) => s + (Number(r[8]) || 0), 0);
    const cost = ticketRows.reduce((s, r) => s + (Number(r[10]) || 0), 0);
    stats.push({
      ticket: meta.ticket,
      prov: meta.proveedor,
      lines: ticketRows.length,
      pieces,
      cost: Math.round(cost * 100) / 100,
    });
  }

  if (claudeFailures > 0 && allExcelRows.length < 400) {
    console.warn(
      `\nClaude falló en ${claudeFailures} PDF(s) (revisa ANTHROPIC_API_KEY). Usando Vision OCR...`
    );
    return runVisionFallback();
  }

  const wb = XLSX.utils.book_new();
  const ws1 = XLSX.utils.aoa_to_sheet([HEADERS, ...allExcelRows]);
  XLSX.utils.book_append_sheet(wb, ws1, "Compras_maestro");

  const ws2 = XLSX.utils.aoa_to_sheet([
    ["Ticket", "Proveedor", "Líneas", "Piezas", "Costo s/IVA"],
    ...stats.map((s) => [s.ticket, s.prov, s.lines, s.pieces, s.cost]),
  ]);
  XLSX.utils.book_append_sheet(wb, ws2, "Resumen_homologacion");
  XLSX.writeFile(wb, OUTPUT_XLSX);

  const sqlPaths = buildSqlFiles(sqlRows);

  console.log("\n========================================");
  console.log(`Excel: ${OUTPUT_XLSX}`);
  console.log(`Filas: ${allExcelRows.length}`);
  for (const s of stats) {
    console.log(
      `  ${s.ticket} | ${s.lines} líneas | ${s.pieces} pzas | $${s.cost}`
    );
  }
  console.log(`\nSQL (${sqlPaths.length} fragmentos):`);
  sqlPaths.forEach((p) => console.log(`  ${p}`));
  console.log(`Manifest: ${path.join(SQL_DIR, path.basename(sqlPaths[0]).replace(/_part\d+.sql/, "_manifest.txt"))}`);
}

function runVisionFallback() {
  const { execSync } = require("child_process");
  execSync("python3 scripts/homologar_tickets_a_excel.py", {
    cwd: ROOT,
    stdio: "inherit",
  });
}

main().catch((e) => {
  console.error(e);
  console.warn("\nIntentando fallback Vision OCR...");
  try {
    runVisionFallback();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
});
