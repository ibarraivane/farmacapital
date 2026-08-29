/**
 * Cruce inventario local vs lo que debemos publicar en Rappi
 * vs lo que Rappi tiene (CSV del partner).
 *
 * stock_publicado = max(stock − reserva_mostrador, 0)
 * Elegible: activo y sin receta.
 */

export const RAPPI_SKU_PREFIX = "FARMACAPITALmt_";
export const DEFAULT_RESERVA = 2;

/** Pedido Rappi 2468274038 · 28 ago 2026 · Mercado Leyes De Reforma */
export const INCIDENTE_PIOGLITAZONA = {
  orderId: "2468274038",
  sku: "EQ-ULT146",
  ean: "7502216796737",
  qtyPedida: 4,
  fecha: "2026-08-28",
  precioRappi: 30,
  tienda: "Mercado Leyes De Reforma",
};

export function digitsOnly(value) {
  return String(value || "").replace(/\D/g, "");
}

export function normHeader(value) {
  return String(value || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
}

export function toInt(value, fallback = 0) {
  const n = Number(String(value ?? "").replace(/[,\s]/g, ""));
  if (!Number.isFinite(n)) return fallback;
  return Math.trunc(n);
}

export function calcStockPublicado(stock, reserva = DEFAULT_RESERVA) {
  const s = Math.max(0, toInt(stock, 0));
  const r = Math.max(0, toInt(reserva, DEFAULT_RESERVA));
  return Math.max(s - r, 0);
}

export function productoEligibleRappi(producto) {
  if (!producto) return false;
  if (producto.activo === false) return false;
  if (producto.requiere_receta) return false;
  return true;
}

export function rappiSkuFromInternal(sku, prefix = RAPPI_SKU_PREFIX) {
  const inner = String(sku || "").trim();
  if (!inner) return "";
  return `${prefix}${inner.toLowerCase()}`;
}

export function internalSkuFromRappi(rappiSku, prefix = RAPPI_SKU_PREFIX) {
  const raw = String(rappiSku || "").trim();
  if (!raw) return "";
  const low = raw.toLowerCase();
  const p = String(prefix || "").toLowerCase();
  if (p && low.startsWith(p)) return raw.slice(prefix.length);
  const mt = low.indexOf("mt_");
  if (mt >= 0) return raw.slice(mt + 3);
  return raw;
}

export function skuKey(value) {
  return String(value || "").trim().toLowerCase();
}

export function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < line.length; i += 1) {
    const c = line[i];
    if (c === '"') {
      if (inQ && line[i + 1] === '"') {
        cur += '"';
        i += 1;
      } else {
        inQ = !inQ;
      }
    } else if ((c === "," || c === ";") && !inQ) {
      out.push(cur);
      cur = "";
    } else {
      cur += c;
    }
  }
  out.push(cur);
  return out.map((s) => s.trim());
}

export function parseCsvText(text) {
  const lines = String(text || "")
    .replace(/^\uFEFF/, "")
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .split("\n")
    .filter((l) => l.trim());
  if (!lines.length) return { headers: [], rows: [] };
  const headers = splitCsvLine(lines[0]);
  const rows = lines.slice(1).map((line, idx) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((h, i) => {
      row[h] = cells[i] ?? "";
    });
    row._line = idx + 2;
    return row;
  });
  return { headers, rows };
}

const SKU_HEADERS = new Set([
  "sku", "sku_rappi", "sku_interno", "product_sku", "store_sku", "id", "id_sku",
]);
const EAN_HEADERS = new Set([
  "ean", "gtin", "barcode", "codigo_barras", "codigo_de_barras", "bar_code",
]);
const STOCK_HEADERS = new Set([
  "stock", "inventory", "quantity", "qty", "existencias", "inventario",
  "unidades", "und", "available_stock", "stock_rappi",
]);
const NAME_HEADERS = new Set(["nombre", "name", "product_name", "producto", "title"]);
const PRICE_HEADERS = new Set(["precio", "price", "precio_venta", "sale_price"]);
const AVAIL_HEADERS = new Set([
  "available", "disponible", "disponibilidad", "status", "estado", "is_available",
]);

function pickField(row, aliases) {
  for (const [key, val] of Object.entries(row || {})) {
    if (key.startsWith("_")) continue;
    if (aliases.has(normHeader(key))) return val;
  }
  return "";
}

export function parseRappiInventarioRows(rows) {
  return (rows || []).map((row) => {
    const sku = String(pickField(row, SKU_HEADERS) || "").trim();
    const ean = digitsOnly(pickField(row, EAN_HEADERS));
    const nombre = String(pickField(row, NAME_HEADERS) || "").trim();
    const stockRaw = pickField(row, STOCK_HEADERS);
    const stock = stockRaw === "" || stockRaw == null ? null : Math.max(0, toInt(stockRaw, 0));
    const availRaw = String(pickField(row, AVAIL_HEADERS) || "").trim().toLowerCase();
    let disponible = null;
    if (["1", "true", "si", "sí", "yes", "available", "disponible", "activo"].includes(availRaw)) {
      disponible = true;
    } else if (["0", "false", "no", "unavailable", "agotado", "inactivo", "cancelado"].includes(availRaw)) {
      disponible = false;
    }
    const precio = pickField(row, PRICE_HEADERS);
    if (!sku && !ean) return null;
    return {
      sku,
      ean,
      nombre,
      stock,
      disponible,
      precio: precio === "" ? null : precio,
      line: row._line || null,
    };
  }).filter(Boolean);
}

export function parseRappiInventarioCsv(text) {
  const { headers, rows } = parseCsvText(text);
  return { headers, rows: parseRappiInventarioRows(rows) };
}

export function matchRappiRow(rappiRow, bySku, byEan, prefix = RAPPI_SKU_PREFIX) {
  const skuRaw = skuKey(rappiRow?.sku);
  if (skuRaw && bySku.has(skuRaw)) return bySku.get(skuRaw);
  const stripped = skuKey(internalSkuFromRappi(rappiRow?.sku, prefix));
  if (stripped && bySku.has(stripped)) return bySku.get(stripped);
  const ean = digitsOnly(rappiRow?.ean);
  if (ean && byEan.has(ean)) return byEan.get(ean);
  return null;
}

function lastQueueBySku(queueRows) {
  const map = new Map();
  const sorted = [...(queueRows || [])].sort((a, b) => {
    const ta = Date.parse(a?.created_at || "") || 0;
    const tb = Date.parse(b?.created_at || "") || 0;
    return ta - tb;
  });
  for (const row of sorted) {
    const key = skuKey(row?.sku);
    if (key) map.set(key, row);
  }
  return map;
}

/**
 * @returns {'incidente'|'peligro'|'desfase'|'ok'|'catalogo'}
 */
export function alertaDeFila(fila) {
  if (fila?.incidente) return "incidente";
  if (fila?.rappiStock != null && fila.rappiStock > fila.stockPublicado) return "peligro";
  if (fila?.rappiDisponible === true && !fila.disponible) return "peligro";
  if (fila?.colaQuiereApagar && fila.colaPendiente) return "peligro";
  if (fila?.rappiStock != null && fila.rappiStock !== fila.stockPublicado) return "desfase";
  if (fila?.elig && fila.stockLocal > 0 && fila.stockPublicado === 0 && fila.rappiStock == null) {
    return "catalogo";
  }
  return "ok";
}

export function buildFilasInventario({
  productos = [],
  queueRows = [],
  rappiRows = [],
  reserva = DEFAULT_RESERVA,
  prefix = RAPPI_SKU_PREFIX,
} = {}) {
  const bySku = new Map();
  const byEan = new Map();
  for (const p of productos) {
    const key = skuKey(p?.sku);
    if (key) bySku.set(key, p);
    const ean = digitsOnly(p?.codigo_barras);
    if (ean && !byEan.has(ean)) byEan.set(ean, p);
  }

  const queueBySku = lastQueueBySku(queueRows);
  const rappiByProductoId = new Map();
  const rappiSinMatch = [];
  for (const row of rappiRows || []) {
    const prod = matchRappiRow(row, bySku, byEan, prefix);
    if (!prod) {
      rappiSinMatch.push(row);
      continue;
    }
    rappiByProductoId.set(prod.id, row);
  }

  const filas = productos.map((p) => {
    const stockLocal = Math.max(0, toInt(p.stock, 0));
    const elig = productoEligibleRappi(p);
    const stockPublicado = elig ? calcStockPublicado(stockLocal, reserva) : 0;
    const disponible = elig && stockPublicado > 0;
    const q = queueBySku.get(skuKey(p.sku));
    const payload = q?.payload || {};
    const rappi = rappiByProductoId.get(p.id) || null;
    const incidente = skuKey(p.sku) === skuKey(INCIDENTE_PIOGLITAZONA.sku)
      || digitsOnly(p.codigo_barras) === INCIDENTE_PIOGLITAZONA.ean;
    const fila = {
      id: p.id,
      sku: p.sku || "",
      skuRappi: rappiSkuFromInternal(p.sku, prefix),
      ean: digitsOnly(p.codigo_barras),
      nombre: p.nombre || "",
      precio: p.precio,
      requiereReceta: Boolean(p.requiere_receta),
      activo: p.activo !== false,
      stockLocal,
      reserva: toInt(reserva, DEFAULT_RESERVA),
      stockPublicado,
      elig,
      disponible,
      cola: q || null,
      colaEstado: q?.estado || null,
      colaPendiente: q?.estado === "pendiente",
      colaQuiereApagar: payload.disponible === false,
      colaStockRappi: payload.stock_rappi,
      rappiStock: rappi?.stock ?? null,
      rappiDisponible: rappi?.disponible ?? null,
      rappiNombre: rappi?.nombre || null,
      rappiSku: rappi?.sku || null,
      incidente,
    };
    fila.alerta = alertaDeFila(fila);
    return fila;
  });

  const rank = { incidente: 0, peligro: 1, desfase: 2, catalogo: 3, ok: 4 };
  filas.sort((a, b) => {
    const ra = rank[a.alerta] ?? 9;
    const rb = rank[b.alerta] ?? 9;
    if (ra !== rb) return ra - rb;
    if (a.incidente !== b.incidente) return a.incidente ? -1 : 1;
    return String(a.nombre).localeCompare(String(b.nombre), "es");
  });

  return { filas, rappiSinMatch, reserva: toInt(reserva, DEFAULT_RESERVA) };
}

export function resumirCruce(filas, rappiSinMatch = []) {
  const out = {
    total: filas.length,
    publicables: 0,
    peligro: 0,
    desfase: 0,
    catalogo: 0,
    colaApagar: 0,
    colaPrender: 0,
    incidente: 0,
    rappiSinMatch: rappiSinMatch.length,
    conRappi: 0,
    rappiVendeDeMas: 0,
  };
  for (const f of filas) {
    if (f.disponible) out.publicables += 1;
    if (f.alerta === "peligro") out.peligro += 1;
    if (f.alerta === "desfase") out.desfase += 1;
    if (f.alerta === "catalogo") out.catalogo += 1;
    if (f.incidente) out.incidente += 1;
    if (f.colaPendiente && f.colaQuiereApagar) out.colaApagar += 1;
    if (f.colaPendiente && f.disponible) out.colaPrender += 1;
    if (f.rappiStock != null) out.conRappi += 1;
    if (f.rappiStock != null && f.rappiStock > f.stockPublicado) out.rappiVendeDeMas += 1;
  }
  return out;
}

function csvEscape(value) {
  const s = value == null ? "" : String(value);
  if (/[",\n;]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

export function csvCargaSegura(filas) {
  const header = ["SKU", "EAN", "STOCK", "AVAILABLE"];
  const lines = [header.join(",")];
  for (const f of filas) {
    if (!f.sku) continue;
    lines.push([
      csvEscape(f.skuRappi || f.sku),
      csvEscape(f.ean),
      f.stockPublicado,
      f.disponible ? "true" : "false",
    ].join(","));
  }
  return lines.join("\n");
}

export function csvCruceCompleto(filas) {
  const header = [
    "alerta", "sku", "sku_rappi", "ean", "nombre",
    "stock_local", "reserva", "stock_publicado", "disponible",
    "cola_estado", "cola_quiere_apagar",
    "rappi_stock", "rappi_disponible",
  ];
  const lines = [header.join(",")];
  for (const f of filas) {
    lines.push([
      f.alerta,
      csvEscape(f.sku),
      csvEscape(f.skuRappi),
      csvEscape(f.ean),
      csvEscape(f.nombre),
      f.stockLocal,
      f.reserva,
      f.stockPublicado,
      f.disponible,
      csvEscape(f.colaEstado || ""),
      f.colaQuiereApagar,
      f.rappiStock == null ? "" : f.rappiStock,
      f.rappiDisponible == null ? "" : f.rappiDisponible,
    ].join(","));
  }
  return lines.join("\n");
}
