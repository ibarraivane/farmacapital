/**
 * Reporte de agotados / stock bajo y a qué surtidor pedir (mejor precio).
 *
 * Destino = la opción más barata entre listas B2B (Levic, Exprezo…)
 * y la última compra con nombre (El Surtidor, Farma City, Equilibrio…).
 */

import { opcionesTiendaCompra, fmtPrecioRef } from "./preciosReferencia";
import { normalizeProveedorCompra, parseCostoTicket, proveedorCompraVisible } from "./ultimaCompra";

export const STOCK_MIN_DEFAULT = 5;
export const NIVELES_PEDIDO = ["AGOTADO", "CRÍTICO", "BAJO"];
export const ORDEN_URGENCIA = { AGOTADO: 0, CRÍTICO: 1, BAJO: 2, PRONTO: 3 };

const FUENTE_POR_SURTIDOR = {
  Levic: "levic",
  Exprezo: "exprezo",
  Nadro: "nadro",
  Marzam: "marzam",
  Farmalive: "farmalive",
  Scorpion: "scorpion",
  "El Surtidor": "surtidor:el_surtidor",
  "Farma City": "surtidor:farma_city",
  Equilibrio: "surtidor:equilibrio",
  "Bodega F-42": "surtidor:bodega_f42",
  IFC: "surtidor:ifc",
  "Farma MX": "surtidor:farma_mx",
  "Farma Mayoreo": "surtidor:farma_mayoreo",
};

export function stockDe(p) {
  return Number(p?.stock_peps ?? p?.stock) || 0;
}

export function stockMinimoEfectivo(p) {
  return Number(p?.stock_minimo) > 0 ? Number(p.stock_minimo) : STOCK_MIN_DEFAULT;
}

export function nivelStockUrgencia(p) {
  const min = stockMinimoEfectivo(p);
  const stock = stockDe(p);
  const pct = min > 0 ? stock / min : 0;
  if (stock === 0) return "AGOTADO";
  if (pct <= 0.5) return "CRÍTICO";
  if (pct <= 1) return "BAJO";
  if (pct <= 1.5) return "PRONTO";
  return null;
}

export function estiloUrgencia(nivel, C) {
  if (nivel === "AGOTADO") return { nivel, col: C.red, bg: C.redDim, icon: "🚨" };
  if (nivel === "CRÍTICO") return { nivel, col: C.red, bg: C.redDim, icon: "🔴" };
  if (nivel === "BAJO") return { nivel, col: C.amber, bg: C.amberDim, icon: "🟡" };
  if (nivel === "PRONTO") return { nivel, col: "#0891b2", bg: "#cffafe", icon: "🔵" };
  return { nivel: "OK", col: C.textMid, bg: C.cardDark, icon: "·" };
}

export function cantidadSugerida(p) {
  const min = stockMinimoEfectivo(p);
  const base = Math.max(min * 3 - stockDe(p), 0);
  return Math.max(base, 1);
}

export function idFuenteSurtidor(nombre) {
  const n = normalizeProveedorCompra(nombre);
  if (!n) return null;
  if (FUENTE_POR_SURTIDOR[n]) return FUENTE_POR_SURTIDOR[n];
  return `surtidor:${n.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "")}`;
}

export function esFamiliaSurtidor(fuenteId) {
  return String(fuenteId || "").startsWith("surtidor:");
}

export function opcionesPedidoProducto(refsMap, meta = {}) {
  const tiendas = opcionesTiendaCompra(refsMap).map((t) => ({ ...t }));
  const quien = proveedorCompraVisible(meta.proveedor || meta.nombre_fuente);
  const precio = parseCostoTicket(meta.precio ?? meta.costo);
  if (quien && precio) {
    const fuente = idFuenteSurtidor(quien);
    const existing = tiendas.find((t) => t.fuente === fuente);
    if (existing) {
      if (precio < existing.precio - 0.005) existing.precio = precio;
    } else {
      tiendas.push({
        fuente,
        label: quien,
        precio,
        esSurtidorTicket: true,
      });
    }
  }
  return tiendas
    .filter((t) => t?.fuente && Number(t.precio) > 0)
    .sort((a, b) => a.precio - b.precio);
}

export function calcMejorTiendaPedido(refsMap, meta = {}) {
  const opciones = opcionesPedidoProducto(refsMap, meta);
  if (!opciones.length) return null;
  return { ...opciones[0], opciones };
}

export function metaCompraDeProducto(p, refsMap = {}) {
  return {
    proveedor: refsMap?.ultima_compra?.nombre_fuente || p?.proveedor || "",
    precio: refsMap?.ultima_compra?.precio ?? p?.costo,
  };
}

export function clasificarAlertas(productos) {
  const buckets = { AGOTADO: [], CRÍTICO: [], BAJO: [], PRONTO: [] };
  for (const p of productos || []) {
    const nivel = nivelStockUrgencia(p);
    if (!nivel) continue;
    buckets[nivel].push(p);
  }
  return {
    agotados: buckets.AGOTADO,
    criticos: buckets.CRÍTICO,
    bajo: buckets.BAJO,
    pronto: buckets.PRONTO,
    paraPedir: [...buckets.AGOTADO, ...buckets.CRÍTICO, ...buckets.BAJO],
  };
}

export function filaReporteDe(p) {
  const tienda = p.mejorTienda;
  return {
    id: p.id,
    nombre: p.nombre || "",
    sku: p.sku || "",
    codigo_barras: p.codigo_barras || "",
    stock: stockDe(p),
    stock_minimo: stockMinimoEfectivo(p),
    sugerido: cantidadSugerida(p),
    urgencia: nivelStockUrgencia(p),
    surtidor: tienda?.label || "",
    surtidorId: tienda?.fuente || "",
    precio: tienda?.precio ?? null,
    alternativas: (tienda?.opciones || [])
      .slice(1)
      .map((o) => `${o.label} ${fmtPrecioRef(o.precio)}`)
      .join(" · "),
    producto: p,
  };
}

export function filasReporte(productos) {
  return (productos || [])
    .filter((p) => nivelStockUrgencia(p))
    .map(filaReporteDe)
    .sort((a, b) => {
      const d = (ORDEN_URGENCIA[a.urgencia] ?? 9) - (ORDEN_URGENCIA[b.urgencia] ?? 9);
      if (d) return d;
      const sa = (a.surtidor || "\uFFFF").localeCompare(b.surtidor || "\uFFFF", "es");
      if (sa) return sa;
      return String(a.nombre).localeCompare(String(b.nombre), "es");
    });
}

export function agruparFilasPorSurtidor(filas) {
  const m = new Map();
  for (const f of filas || []) {
    const key = f.surtidorId || "_sin";
    const label = f.surtidor || "Sin coincidencia de tienda";
    if (!m.has(key)) m.set(key, { id: key, label, filas: [] });
    m.get(key).filas.push(f);
  }
  return [...m.values()].sort((a, b) => {
    if (a.id === "_sin") return 1;
    if (b.id === "_sin") return -1;
    return b.filas.length - a.filas.length;
  });
}

const HEADERS_REPORTE = [
  "Urgencia",
  "Producto",
  "SKU",
  "Código de barras",
  "Stock",
  "Mínimo",
  "Pedir",
  "Surtidor",
  "Mejor precio",
  "Otras opciones",
];

function filaAoa(f) {
  return [
    f.urgencia,
    f.nombre,
    f.sku,
    f.codigo_barras,
    f.stock,
    f.stock_minimo,
    f.sugerido,
    f.surtidor || "Sin coincidencia",
    f.precio != null ? Number(Number(f.precio).toFixed(2)) : "",
    f.alternativas,
  ];
}

export function buildReporteReabastoSheets(filas) {
  const agotados = (filas || []).filter((f) => f.urgencia === "AGOTADO");
  const bajo = (filas || []).filter((f) => f.urgencia === "CRÍTICO" || f.urgencia === "BAJO");
  const pronto = (filas || []).filter((f) => f.urgencia === "PRONTO");
  const paraPedir = (filas || []).filter((f) => NIVELES_PEDIDO.includes(f.urgencia));
  const grupos = agruparFilasPorSurtidor(paraPedir);

  const resumen = [
    ["Reporte de reabasto — FarmaCapital"],
    ["Cada producto se asigna al surtidor con el mejor precio (listas + última compra)."],
    [],
    ["Urgencia", "Productos"],
    ["Agotados (stock 0)", agotados.length],
    ["Críticos / bajo (≤ mínimo)", bajo.length],
    ["Pronto (cerca del mínimo)", pronto.length],
    [],
    ["Surtidor", "Líneas a pedir", "Total estimado"],
    ...grupos.map((g) => [
      g.label,
      g.filas.length,
      Number(g.filas.reduce((a, f) => a + (Number(f.precio) || 0) * f.sugerido, 0).toFixed(2)),
    ]),
  ];

  return {
    Resumen: resumen,
    Agotados: [HEADERS_REPORTE, ...agotados.map(filaAoa)],
    "Stock bajo": [HEADERS_REPORTE, ...bajo.map(filaAoa)],
    "Por surtidor": [HEADERS_REPORTE, ...grupos.flatMap((g) => g.filas.map(filaAoa))],
  };
}

export function itemsParaPedir(productos, { incluirPronto = false } = {}) {
  return (productos || [])
    .filter((p) => {
      const n = nivelStockUrgencia(p);
      if (!n) return false;
      if (incluirPronto) return true;
      return NIVELES_PEDIDO.includes(n);
    })
    .map((p) => ({ producto: p, cantidad: cantidadSugerida(p) }));
}
