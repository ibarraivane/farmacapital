#!/usr/bin/env node
/**
 * Lee FARMACOS.xlsx (lista mayorista Farmacia Ventura) y genera SQL INSERT
 * para public.productos con SKU estable FV-{crc32}.
 *
 * Por defecto solo importa filas **visibles** en Excel (respeta autofiltro:
 * las filas ocultas por el filtro tienen hidden en xl/worksheets y SheetJS
 * expone ws["!rows"] con cellStyles). Para incluir todas las filas del sheet:
 *   IMPORT_EXCEL_INCLUDE_HIDDEN=1 node scripts/import-farmac-os-xlsx.js [...]
 *
 * Uso:
 *   node scripts/import-farmac-os-xlsx.js [ruta.xlsx]
 *
 * Salida (fragmentada para Supabase SQL Editor — límite de tamaño por query):
 *   sql/generated/import_farmac_os_<stamp>_partNNNN.sql
 *   sql/generated/import_farmac_os_<stamp>_manifest.txt
 *
 * También podés ejecutar todos los fragmentos contra Postgres sin pegar en el editor:
 *   export DATABASE_URL='postgresql://...'   # Connection string (pooler Session mode en Supabase)
 *   bash scripts/run-farmac-os-sql-parts.sh <stamp>
 */

"use strict";

const fs = require("fs");
const path = require("path");

/**
 * Límite por archivo (bytes UTF-8) para pegar en SQL Editor de Supabase.
 * Si falla igual, bajar a ~14–18 KiB y regenerar.
 */
const MAX_BYTES_PER_SQL_FILE = 42 * 1024;

let XLSX;
try {
  XLSX = require("xlsx");
} catch {
  console.error("Instala dependencia: npm install xlsx --save-dev");
  process.exit(1);
}

function crc32(str) {
  let c = ~0;
  for (let i = 0; i < str.length; i++) {
    c ^= str.charCodeAt(i);
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0);
  }
  return (c ^ -1) >>> 0;
}

function norm(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toUpperCase();
}

function sqlQuote(s) {
  return `'${String(s ?? "").replace(/'/g, "''")}'`;
}

function sqlTextOrNull(s, maxLen) {
  const t = String(s ?? "").trim();
  if (!t) return "NULL";
  return sqlQuote(t.slice(0, maxLen ?? 500));
}

function inferRequiereReceta(grupo) {
  const g = norm(grupo);
  if (!g) return false;
  if (g === "ANTIBIOTICO") return true;
  if (g === "ANTIPSICOTICO") return true;
  if (g === "PSICOESTIMULANTE") return true;
  if (g.includes("ANTIBIOT")) return true;
  return false;
}

function inferControlado(grupo, desc, marca) {
  const g = norm(grupo);
  if (g === "PSICOESTIMULANTE") return true;
  const blob = `${desc} ${marca}`;
  return /\b(TRAMADOL|MORFIN|FENTAN|METADON|METILFENIDATO|OXICOD|CODEINA\s|CLONAZEPAM|ALPRAZOLAM|DIAZEPAM|LORAZEPAM)\b/i.test(
    blob
  );
}

function inferVisibleTienda(jerarquia, grupo) {
  const j = norm(jerarquia);
  const g = norm(grupo);
  if (/PERFUMERIA|PROMOCIONAL/.test(j)) return false;
  if (/ALIMENTO/.test(j) && !g.includes("MEDIC")) return false;
  return true;
}

function buildNombre(marca, descripcion) {
  const m = String(marca ?? "").trim();
  const d = String(descripcion ?? "").trim();
  if (!m) return d;
  if (!d) return m;
  return `${m} — ${d}`;
}

function parsePrecio(raw) {
  const n = Number(String(raw ?? "").replace(/,/g, "").trim());
  return Number.isFinite(n) && n >= 0 ? n : 0;
}

const INSERT_HEAD =
  `INSERT INTO public.productos (
  nombre, sku, marca, categoria, tipo, descripcion,
  presentacion,
  precio,
  requiere_receta, controlado, grupo_controlado,
  visible_tienda,
  stock, stock_minimo, stock_unidades,
  activo,
  notas
) VALUES
`;

function utf8Len(s) {
  return Buffer.byteLength(s, "utf8");
}

/** Índice de fila en sheet_to_json header:1 coincide con índice en ws["!rows"]. */
function isExcelRowHiddenByFilter(ws, rawRowIndex0Based) {
  const meta = ws["!rows"] && ws["!rows"][rawRowIndex0Based];
  return !!(meta && meta.hidden);
}

/**
 * Agrupa tuplas VALUES en uno o más INSERTs sin que cada INSERT supere maxStmtBytes.
 */
function packInsertStatements(tupleLines, maxStmtBytes) {
  const stmts = [];
  let chunk = [];

  let i = 0;
  while (i < tupleLines.length) {
    const line = tupleLines[i];
    const trialChunk = [...chunk, line];
    const candidate = INSERT_HEAD + trialChunk.join(",\n") + ";\n";

    if (utf8Len(candidate) <= maxStmtBytes) {
      chunk = trialChunk;
      i++;
      continue;
    }

    if (chunk.length > 0) {
      stmts.push(INSERT_HEAD + chunk.join(",\n") + ";\n");
      chunk = [];
      continue;
    }

    stmts.push(candidate);
    console.warn(
      `[import-farmac-os] Una fila supera maxStmtBytes (${utf8Len(
        candidate
      )} bytes); se emitió igual. Considerá bajar datos en Excel.`
    );
    i++;
  }

  if (chunk.length) {
    stmts.push(INSERT_HEAD + chunk.join(",\n") + ";\n");
  }
  return stmts;
}

/** Une uno o más INSERTs por archivo sin superar MAX_BYTES_PER_SQL_FILE (incluye cabecera BEGIN/COMMIT). */
function writeSqlParts(outDir, baseName, stamp, metaTag, stmts, summaryFooterLines) {
  const WRAP_BYTES = 900;
  const files = [];
  let part = 1;
  let bucket = [];
  let bucketBytes = 0;

  function flushBucket() {
    if (!bucket.length) return;
    let content = `-- FARMACAPITAL — Import catálogo (${stamp})\n`;
    content += `-- Etiqueta notas: ${metaTag}\n`;
    content += `-- Archivo parte ${part}. Ejecutá todas las partes en orden numérico.\n\n`;
    content += `BEGIN;\n\n`;
    content += bucket.join("\n\n");
    content += `\n\nCOMMIT;\n`;
    if (part === 1 && summaryFooterLines.length) {
      content += "\n" + summaryFooterLines.join("\n") + "\n";
    }
    const name = `${baseName}_part${String(part).padStart(4, "0")}.sql`;
    fs.writeFileSync(path.join(outDir, name), content, "utf8");
    files.push(name);
    part++;
    bucket = [];
    bucketBytes = 0;
  }

  for (const stmt of stmts) {
    const stmtBytes = utf8Len(stmt);
    const sepBytes = bucket.length ? utf8Len("\n\n") : 0;
    if (
      bucket.length &&
      bucketBytes + sepBytes + stmtBytes > MAX_BYTES_PER_SQL_FILE - WRAP_BYTES
    ) {
      flushBucket();
    }
    bucket.push(stmt);
    bucketBytes += sepBytes + stmtBytes;
  }
  flushBucket();

  const manifestPath = path.join(outDir, `${baseName}_manifest.txt`);
  fs.writeFileSync(
    manifestPath,
    [
      `stamp: ${stamp}`,
      `metaTag: ${metaTag}`,
      `archivos_sql: ${files.length}`,
      "",
      ...files.map((f) => f),
      "",
      "Opción A — SQL Editor de Supabase: abrir cada archivo arriba en orden y ejecutar.",
      "Opción B — sin editor (requiere DATABASE_URL de Postgres):",
      `  DATABASE_URL='postgresql://...' bash scripts/run-farmac-os-sql-parts.sh ${stamp}`,
      "",
    ].join("\n"),
    "utf8"
  );

  return { files, manifestPath };
}

function main() {
  const xlsxPath =
    process.argv[2] ||
    "/Users/ibarra/Library/CloudStorage/Dropbox/Farmacia Ventura/FARMACOS.xlsx";

  if (!fs.existsSync(xlsxPath)) {
    console.error("No existe el archivo:", xlsxPath);
    process.exit(1);
  }

  const wb = XLSX.readFile(xlsxPath, { cellStyles: true });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const raw = XLSX.utils.sheet_to_json(ws, { header: 1, defval: "" });
  const hdr = raw[1];
  if (!hdr || String(hdr[0]).trim() !== "SKU") {
    console.error("Formato inesperado: la fila 2 debe tener SKU en columna A.");
    process.exit(1);
  }

  const includeHidden =
    process.env.IMPORT_EXCEL_INCLUDE_HIDDEN === "1" ||
    process.env.IMPORT_EXCEL_INCLUDE_HIDDEN === "true";

  const rows = [];
  let skippedHidden = 0;
  for (let idx = 2; idx < raw.length; idx++) {
    const r = raw[idx];
    if (String(r[0] ?? "").trim() === "") continue;
    if (!includeHidden && isExcelRowHiddenByFilter(ws, idx)) {
      skippedHidden++;
      continue;
    }
    rows.push(r);
  }

  const stamp = new Date().toISOString().replace(/[-:]/g, "").slice(0, 15);
  const outDir = path.join(__dirname, "..", "sql", "generated");
  fs.mkdirSync(outDir, { recursive: true });
  const baseName = `import_farmac_os_${stamp}`;

  const metaTag = `IMPORT_FARMACOS_${stamp}`;
  let inserted = 0;
  let rx = 0;
  let ctrl = 0;

  const tupleLines = [];

  for (const r of rows) {
    const skuRaw = String(r[0] ?? "").trim();
    const marca = String(r[1] ?? "").trim();
    const descripcion = String(r[2] ?? "").trim();
    const precio = parsePrecio(r[3]);
    const concentracion = String(r[4] ?? "").trim();
    const contenido = String(r[5] ?? "").trim();
    const presentacionTipo = String(r[7] ?? "").trim();
    const lineaGeneral = String(r[8] ?? "").trim();
    const lineaComercial = String(r[9] ?? "").trim();
    const jerarquia = String(r[10] ?? "").trim();
    const grupo = String(r[11] ?? "").trim();

    const keyNorm = [skuRaw, marca, descripcion].map(norm).join("|");
    const skuFv = `FV-${crc32(keyNorm).toString(16).padStart(8, "0")}`;
    const nombre = buildNombre(marca, descripcion);
    const reqRx = inferRequiereReceta(grupo);
    const ctl = inferControlado(grupo, descripcion, marca);
    const vis = inferVisibleTienda(jerarquia, grupo);

    const presParts = [concentracion, contenido, presentacionTipo].filter(Boolean);
    const presentacion = presParts.join(" · ") || null;

    const tipoVal = lineaComercial || lineaGeneral || jerarquia || null;
    const notas =
      `${metaTag} · Lista SKU origen: ${skuRaw} · Jerarquía: ${jerarquia || "—"} · Línea: ${lineaGeneral || "—"}`;

    if (reqRx) rx++;
    if (ctl) ctrl++;

    const descLarga = [
      descripcion,
      concentracion && `Conc.: ${concentracion}`,
      contenido && `Cont.: ${contenido}`,
      presentacionTipo && `Forma: ${presentacionTipo}`,
      grupo && `Grupo artículos: ${grupo}`,
    ]
      .filter(Boolean)
      .join("\n")
      .slice(0, 2400);

    const vals = [
      sqlQuote(nombre.slice(0, 500)),
      sqlQuote(skuFv.slice(0, 120)),
      sqlTextOrNull(marca, 200),
      sqlTextOrNull(grupo, 200),
      tipoVal ? sqlQuote(String(tipoVal).slice(0, 200)) : "NULL",
      sqlQuote(descLarga),
      presentacion ? sqlQuote(presentacion.slice(0, 500)) : "NULL",
      String(precio),
      reqRx ? "true" : "false",
      ctl ? "true" : "false",
      ctl ? sqlTextOrNull(grupo, 120) : "NULL",
      vis ? "true" : "false",
      "0",
      "2",
      "0",
      "true",
      sqlQuote(notas.slice(0, 2000)),
    ].join(",\n  ");

    tupleLines.push(`(${vals})`);
    inserted++;
  }

  /** Cada INSERT parcial no debe pasar este tamaño (varios INSERT caben por archivo). */
  const stmts = packInsertStatements(
    tupleLines,
    Math.min(22000, Math.floor(MAX_BYTES_PER_SQL_FILE * 0.48))
  );

  const summaryFooterLines = [
    `-- Resumen estimado:`,
    `-- requiere_receta true (aprox): ${rx}`,
    `-- controlado true (aprox): ${ctrl}`,
    ...(includeHidden
      ? [`-- IMPORT_EXCEL_INCLUDE_HIDDEN: todas las filas con SKU.`]
      : [`-- Filas omitidas (Excel ocultas por filtro/autofiltro): ${skippedHidden}`]),
    `-- DELETE masivo previo (re-import mismo lote):`,
    `-- DELETE FROM public.productos WHERE notas LIKE '%${metaTag}%';`,
  ];

  const { files, manifestPath } = writeSqlParts(
    outDir,
    baseName,
    stamp,
    metaTag,
    stmts,
    summaryFooterLines
  );

  console.log("Directorio:", outDir);
  console.log("Manifiesto:", manifestPath);
  console.log("Archivos SQL:", files.length, "(ejecutá en orden part0001 → …)");
  console.log("Filas INSERT:", inserted);
  if (!includeHidden && skippedHidden > 0) {
    console.log(
      "Filas omitidas (Excel ocultas por filtro):",
      skippedHidden,
      "(IMPORT_EXCEL_INCLUDE_HIDDEN=1 para importar todas)"
    );
  }
  console.log("Marcados requiere_receta (~):", rx);
  console.log("Marcados controlado (~):", ctrl);
  console.log(
    "\nSi el Editor sigue rechazando una parte, reducí MAX_BYTES_PER_SQL_FILE en scripts/import-farmac-os-xlsx.js y regenerá."
  );
}

main();
