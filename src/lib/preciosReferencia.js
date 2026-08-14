/**
 * Lógica compartida — pestaña Referencias de precio (Inventario).
 * Espejo simplificado de scripts/pricing_preview.py (classify + piso de margen).
 */

export const FUENTES_COMPRA = ["exprezo", "marzam", "nadro", "levic"];
export const FUENTES_VENTA = ["fahorro", "similares"];

export const FUENTE_META = {
  exprezo: { label: "Exprezo", tipo: "compra", listaDistribuidor: false },
  marzam: { label: "Marzam", tipo: "compra", listaDistribuidor: true },
  nadro: { label: "Nadro", tipo: "compra", listaDistribuidor: true },
  levic: { label: "Levic", tipo: "compra", listaDistribuidor: false },
  similares: { label: "Similares", tipo: "venta", listaDistribuidor: false },
  fahorro: { label: "Del Ahorro", tipo: "venta", listaDistribuidor: false },
};

const fmtMoney = (n) =>
  `$${parseFloat(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

export { fmtMoney as fmtPrecioRef };

/** Mapa producto_id → { fuente → fila ref } desde filas de producto_precios_referencia_actual */
export function buildReferenciasPorProducto(rows) {
  const byProduct = {};
  for (const row of rows || []) {
    const pid = row.producto_id;
    if (!pid) continue;
    if (!byProduct[pid]) byProduct[pid] = {};
    byProduct[pid][row.fuente] = row;
  }
  return byProduct;
}

/** Fallback: deduplicar historial crudo (si la vista aún no existe en Supabase) */
export function dedupeReferenciasActuales(rows) {
  const best = new Map();
  for (const row of rows || []) {
    const key = `${row.producto_id}:${row.fuente}`;
    const prev = best.get(key);
    if (!prev) {
      best.set(key, row);
      continue;
    }
    const rowDate = `${row.fecha || ""}${row.created_at || ""}`;
    const prevDate = `${prev.fecha || ""}${prev.created_at || ""}`;
    if (rowDate > prevDate) best.set(key, row);
  }
  return Array.from(best.values());
}

/** Δ% compra: positivo = proveedor más caro que tu costo */
export function diffPctCompra(costo, precioRef) {
  const c = parseFloat(costo);
  const r = parseFloat(precioRef);
  if (!Number.isFinite(c) || c <= 0 || !Number.isFinite(r)) return null;
  return (((r - c) / c) * 100).toFixed(1);
}

/** Δ% venta vs competencia: positivo = tú más caro */
export function diffPctVenta(precio, precioRef) {
  const p = parseFloat(precio);
  const r = parseFloat(precioRef);
  if (!Number.isFinite(p) || !Number.isFinite(r) || r <= 0) return null;
  return (((p - r) / r) * 100).toFixed(1);
}

export function refsCompraDeProducto(refsMap) {
  const out = {};
  for (const id of FUENTES_COMPRA) {
    const row = refsMap?.[id];
    if (row?.precio != null) out[id] = parseFloat(row.precio);
  }
  return out;
}

export function refsVentaDeProducto(refsMap) {
  const out = {};
  for (const id of FUENTES_VENTA) {
    const row = refsMap?.[id];
    if (row?.precio != null) out[id] = parseFloat(row.precio);
  }
  return out;
}

/** Mejor proveedor de compra (precio mínimo entre refs disponibles) */
export function calcMejorCompra(costo, refsMap) {
  const precios = refsCompraDeProducto(refsMap);
  const entries = Object.entries(precios).filter(([, v]) => Number.isFinite(v) && v > 0);
  if (!entries.length) return null;
  entries.sort((a, b) => a[1] - b[1]);
  const [fuente, precio] = entries[0];
  const c = parseFloat(costo);
  const ahorro = Number.isFinite(c) && c > 0 ? c - precio : null;
  return {
    fuente,
    label: FUENTE_META[fuente]?.label || fuente,
    precio,
    ahorro,
    masBaratoQueTuCosto: ahorro != null && ahorro > 0.01,
  };
}

function minProfit(costo) {
  if (costo < 20) return 5;
  if (costo < 50) return 8;
  return 0;
}

function calcPriceFloor(costo, markup) {
  const base = costo * (1 + markup);
  const floor = costo + minProfit(costo);
  return Math.ceil(Math.max(base, floor));
}

/** Clasificación de margen mínimo (espejo pricing_preview.py) */
export function classifyProductoMargen(p) {
  const catL = (p.categoria || "").toLowerCase();
  const nombre = (p.nombre || "").toLowerCase();
  const tipo = (p.tipo || "").toLowerCase();
  const forma = (p.forma_farmaceutica || "").toLowerCase();
  const costo = parseFloat(p.costo) || 0;
  const pa = (p.principio_activo || "").trim();
  const rx = Boolean(p.requiere_receta);

  if (costo <= 0) return { markup: 0, code: "sin_costo" };
  if (costo < 2) return { markup: 0.35, code: "sin_clasificar" };

  const checks = [
    [() => catL.includes("hidrat") || catL === "bebidas" || /electrolit|pedialyte|suero oral|oralit/.test(nombre), 0.3],
    [() => catL.includes("beb") || /pañal|huggies|nan |enfamil/.test(nombre), 0.3],
    [() => catL === "abarrotes" || catL === "minisuper", 0.4],
    [() => catL === "suplemento" || catL === "vitaminas" || nombre.includes("vitamina"), 0.45],
    [() => catL.includes("botiqu") || /venda|gasa|jeringa|algodon|guante/.test(nombre), 0.5],
    [() => catL === "higiene" || catL === "cuidado personal", 0.4],
  ];
  for (const [cond, mk] of checks) {
    if (cond()) return { markup: mk, code: "categoria" };
  }

  if (/tensiometro|glucometro|nebulizador|termometro|oximetro/.test(nombre)) {
    return { markup: costo >= 300 ? 0.3 : 0.5, code: "disp_med" };
  }

  const medForm = /tableta|capsula|cápsula|jarabe|suspension|solucion|inyect|comprim|gragea/.test(forma);
  if ((tipo === "generico" || tipo === "genérico") && pa && medForm) return { markup: 0.6, code: "med_generico" };
  if (tipo === "marca" && rx) return { markup: 0.25, code: "med_patente" };
  if (tipo === "marca" && medForm && !rx) return { markup: 0.35, code: "med_otc_marca" };

  return { markup: 0.35, code: "sin_clasificar" };
}

/**
 * Precio de venta sugerido: min(FDA, Similares) con tope competitivo (×0.98)
 * y piso de margen bruto mínimo según tipo de producto.
 */
export function calcPrecioSugeridoVenta(producto, refsMap) {
  const refs = refsVentaDeProducto(refsMap);
  const vals = Object.values(refs).filter((v) => Number.isFinite(v) && v > 0);
  if (!vals.length) return { sugerido: null, refMin: null, nota: "Sin referencias de venta" };

  const refMin = Math.min(...vals);
  const costo = parseFloat(producto.costo) || 0;
  const precioActual = parseFloat(producto.precio) || 0;
  const { markup } = classifyProductoMargen(producto);
  const piso = costo > 0 ? calcPriceFloor(costo, markup) : 0;

  let objetivo = refMin * 0.98;
  if (precioActual > 0) objetivo = Math.min(precioActual, objetivo);
  if (piso > 0) objetivo = Math.max(objetivo, piso);

  const sugerido = Math.ceil(objetivo * 100) / 100;
  let nota = "Basado en min(FDA, Similares) −2%";
  if (piso > 0 && sugerido >= piso && sugerido > refMin * 0.98) {
    nota = `Margen mínimo (${Math.round(markup * 100)}%) limita bajar más`;
  }
  if (precioActual > 0 && Math.abs(sugerido - precioActual) < 0.01) {
    nota = "Tu precio ya es competitivo";
  }

  return { sugerido, refMin, piso, nota };
}

export function colorDiffCompra(pctStr) {
  if (pctStr == null) return null;
  const n = parseFloat(pctStr);
  if (Number.isNaN(n)) return null;
  if (n < -0.5) return "oportunidad"; // proveedor más barato
  if (n > 0.5) return "caro";
  return "neutral";
}

export function colorDiffVenta(pctStr) {
  if (pctStr == null) return null;
  const n = parseFloat(pctStr);
  if (Number.isNaN(n)) return null;
  if (n <= 0) return "ok";
  if (n > 0) return "caro";
  return "neutral";
}
