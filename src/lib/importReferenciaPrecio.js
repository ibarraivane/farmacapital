/**
 * Import genérico de referencias de precio (CSV en browser).
 * Match: SKU exacto → fuzzy nombre+marca (token overlap).
 */

import { normalizeForSearch } from "../utils";

export const FUENTES_IMPORT = [
  { id: "exprezo", label: "Exprezo / Zorro (piso barato: higiene y abarrotes)", tipo: "compra", adapter: "exprezo" },
  { id: "scorpion", label: "Scorpion (higiene / pañales)", tipo: "compra", adapter: "generico" },
  { id: "abarrotero", label: "Abarrotero (OTC / cuidado personal)", tipo: "compra", adapter: "generico" },
  { id: "mayoreototal", label: "MayoreoTotal", tipo: "compra", adapter: "generico" },
  { id: "otros_compra", label: "Otro abarrotero barato (no City Club / Sam's)", tipo: "compra", adapter: "generico" },
  { id: "marzam", label: "Marzam (medicamento)", tipo: "compra", adapter: "generico" },
  { id: "nadro", label: "Nadro (medicamento)", tipo: "compra", adapter: "generico" },
  { id: "levic", label: "Levic (medicamento)", tipo: "compra", adapter: "generico" },
  { id: "fahorro", label: "Del Ahorro (venta)", tipo: "venta", adapter: "generico" },
];

function norm(s) {
  return normalizeForSearch(String(s || ""))
    .replace(/\s+/g, " ")
    .trim();
}

export function parseMoney(val) {
  if (val == null || val === "") return null;
  const n = parseFloat(String(val).replace(/[$,\s]/g, ""));
  return Number.isFinite(n) && n >= 0 ? n : null;
}

/** Aproximación token_set_ratio 0–100 */
export function tokenMatchScore(a, b) {
  const ta = new Set(norm(a).split(" ").filter((t) => t.length > 1));
  const tb = new Set(norm(b).split(" ").filter((t) => t.length > 1));
  if (!ta.size || !tb.size) return 0;
  let inter = 0;
  for (const t of ta) if (tb.has(t)) inter += 1;
  return Math.round((200 * inter) / (ta.size + tb.size));
}

export function parseCsvText(text) {
  const lines = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n").filter((l) => l.trim());
  if (!lines.length) return { headers: [], rows: [] };
  const headers = splitCsvLine(lines[0]);
  const rows = lines.slice(1).map((line, idx) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cells[i] ?? ""; });
    row._line = idx + 2;
    return row;
  });
  return { headers, rows };
}

function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      if (inQ && line[i + 1] === '"') { cur += '"'; i++; }
      else inQ = !inQ;
    } else if (c === "," && !inQ) {
      out.push(cur);
      cur = "";
    } else cur += c;
  }
  out.push(cur);
  return out.map((s) => s.trim());
}

export function parseExprezoRows(rows, precioCol = "mayoreo") {
  return rows.map((row) => {
    const producto = (row.Producto || row.producto || "").trim();
    if (!producto) return null;
    const may = parseMoney(row["Precio Mayoreo"] ?? row.precio_mayoreo);
    const uni = parseMoney(row["Precio por Unidad"] ?? row.precio_unidad);
    let precio = precioCol === "unidad" ? uni : may;
    if (may && uni && may > uni * 2 && precioCol === "mayoreo") precio = uni;
    if (precio == null) return null;
    return { line: row._line, nombre_fuente: producto, precio, mayoreo: may, unidad: uni };
  }).filter(Boolean);
}

export function parseGenericoRows(rows, headers) {
  const findCol = (names) => {
    const i = headers.findIndex((h) => names.includes(h.toLowerCase().trim()));
    return i >= 0 ? headers[i] : null;
  };
  const skuH = findCol(["sku", "sku_farmacapital"]);
  const nomH = findCol(["nombre", "producto", "descripcion"]);
  const preH = findCol(["precio", "precio_ref", "precio_mayoreo", "precio_similares", "precio_del_ahorro"]);
  if (!preH) throw new Error("Falta columna de precio (precio, precio_ref, …)");
  return rows.map((row) => {
    const precio = parseMoney(row[preH]);
    if (precio == null) return null;
    return {
      line: row._line,
      sku: skuH ? String(row[skuH] || "").trim() : "",
      nombre_fuente: nomH ? String(row[nomH] || "").trim() : "",
      precio,
    };
  }).filter(Boolean);
}

export function matchImportRows(parsedRows, productos, { minScore = 70 } = {}) {
  const bySku = {};
  for (const p of productos) {
    if (p.sku) bySku[p.sku.trim()] = p;
  }

  const matched = [];
  const unmatched = [];

  for (const row of parsedRows) {
    let producto = null;
    let confianza = 0;

    if (row.sku && bySku[row.sku]) {
      producto = bySku[row.sku];
      confianza = 100;
    } else if (row.nombre_fuente) {
      let best = null;
      let bestScore = 0;
      for (const p of productos) {
        const score = tokenMatchScore(
          `${p.marca || ""} ${p.nombre || ""}`,
          row.nombre_fuente
        );
        if (score > bestScore) {
          bestScore = score;
          best = p;
        }
      }
      if (best && bestScore >= minScore) {
        producto = best;
        confianza = bestScore;
      }
    }

    if (producto) {
      matched.push({
        ...row,
        producto_id: producto.id,
        sku: producto.sku,
        nombre_catalogo: producto.nombre,
        confianza,
      });
    } else {
      unmatched.push(row);
    }
  }

  return { matched, unmatched };
}

export async function persistImportReferencia(supabase, { fuente, tipo, fecha, archivo, matched }) {
  const { data: imp, error: impErr } = await supabase
    .from("importaciones_referencia")
    .insert({
      fuente,
      tipo,
      fecha_lista: fecha,
      archivo,
      filas_ok: matched.length,
      filas_error: 0,
      notas: "import_ui",
    })
    .select("id")
    .single();

  if (impErr) throw impErr;

  const importId = imp.id;
  const batchSize = 80;
  for (let i = 0; i < matched.length; i += batchSize) {
    const chunk = matched.slice(i, i + batchSize).map((m) => ({
      producto_id: m.producto_id,
      fuente,
      tipo,
      precio: m.precio,
      fecha,
      nombre_fuente: m.nombre_fuente || m.nombre_catalogo,
      confianza: m.confianza,
      origen: "import_csv",
      import_id: importId,
    }));
    const { error } = await supabase.from("producto_precios_referencia").insert(chunk);
    if (error) throw error;
  }

  return { importId, count: matched.length };
}
