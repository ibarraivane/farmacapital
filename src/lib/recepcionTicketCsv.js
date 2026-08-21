/** Parseo de CSV de ticket para Recibir. No inventa caducidad. */

function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"' && line[i + 1] === '"') {
        cur += '"';
        i += 1;
      } else if (ch === '"') {
        inQuotes = false;
      } else {
        cur += ch;
      }
    } else if (ch === '"') {
      inQuotes = true;
    } else if (ch === ",") {
      out.push(cur);
      cur = "";
    } else {
      cur += ch;
    }
  }
  out.push(cur);
  return out;
}

function normHeader(h) {
  return String(h || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
}

const COL = {
  ean: ["ean", "codigo", "codigo_barras", "codigobarras", "barcode", "upc"],
  sku: ["sku", "sku_farmacapital", "sku_fc"],
  nombre: ["nombre", "descripcion", "descripcion_ticket", "producto"],
  cantidad: ["cantidad", "qty", "cant", "stock", "piezas"],
  costo: ["costo", "precio_unitario", "precio", "p_u", "pu"],
  lote: ["lote", "numero_lote"],
  folio: ["folio", "ticket"],
  proveedor: ["proveedor"],
  total: ["total", "total_ticket", "importe"],
};

function pick(row, keys) {
  for (const k of keys) {
    if (row[k] != null && String(row[k]).trim() !== "") return String(row[k]).trim();
  }
  return "";
}

export function parseTicketCsv(text) {
  const lines = String(text || "")
    .replace(/^\uFEFF/, "")
    .split(/\r?\n/)
    .filter((l) => l.trim());
  if (lines.length < 2) return { renglones: [], folio: "", proveedor: "", total: null };

  const headers = splitCsvLine(lines[0]).map(normHeader);
  const rows = lines.slice(1).map((line) => {
    const cells = splitCsvLine(line);
    const obj = {};
    headers.forEach((h, i) => { obj[h] = cells[i] ?? ""; });
    return obj;
  });

  let folio = "";
  let proveedor = "";
  let total = null;
  const renglones = [];

  for (const row of rows) {
    if (!folio) folio = pick(row, COL.folio);
    if (!proveedor) proveedor = pick(row, COL.proveedor);
    if (total == null) {
      const t = pick(row, COL.total);
      if (t) {
        const n = Number(String(t).replace(/[$,\s]/g, ""));
        if (Number.isFinite(n) && n > 0) total = n;
      }
    }
    const codigo = pick(row, COL.ean).replace(/\D/g, "");
    const sku = pick(row, COL.sku);
    const nombre = pick(row, COL.nombre);
    if (!codigo && !sku && !nombre) continue;
    const qty = parseInt(pick(row, COL.cantidad).replace(/\D/g, ""), 10);
    const costoN = Number(pick(row, COL.costo).replace(/[$,\s]/g, ""));
    renglones.push({
      codigo: codigo || null,
      sku: sku || null,
      nombre: nombre || codigo || sku,
      cantidad: Number.isFinite(qty) && qty > 0 ? qty : 1,
      costo: Number.isFinite(costoN) && costoN > 0 ? costoN : null,
      numero_lote: pick(row, COL.lote) || null,
    });
  }

  return { renglones, folio, proveedor, total };
}
