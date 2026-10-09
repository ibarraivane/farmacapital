/**
 * Atención en mostrador (inyección, presión, oximetría, glucosa).
 * Es un producto tipo `servicio`: se cobra en el POS y no tiene stock ni lotes.
 */

export function esServicio(p) {
  return String(p?.tipo || "").trim().toLowerCase() === "servicio";
}

/** Un servicio nunca está agotado. No imprimir este valor en pantalla. */
export const STOCK_SERVICIO_POS = Number.POSITIVE_INFINITY;

const ETIQUETA_POR_SKU = {
  "SERV-INY-IM": "Inyección",
  "SERV-PRESION": "Presión",
  "SERV-OXIMETRIA": "Oxigenación",
  "SERV-GLUCOSA": "Glucosa",
};

/** Texto corto del botón de acceso rápido. */
export function etiquetaCortaAtencion(p) {
  const sku = String(p?.sku || "").trim().toUpperCase();
  if (ETIQUETA_POR_SKU[sku]) return ETIQUETA_POR_SKU[sku];
  const n = String(p?.nombre || "").toLowerCase();
  if (n.includes("inyecc")) return "Inyección";
  if (n.includes("presi")) return "Presión";
  if (n.includes("oxi")) return "Oxigenación";
  if (n.includes("gluc")) return "Glucosa";
  const corto = String(p?.nombre || "Atención").trim().split(/\s+/).slice(0, 2).join(" ");
  return corto || "Atención";
}

/** Activos, ordenados por nombre. Glucosa desactivada no entra. */
export function serviciosAtencionActivos(productos) {
  return (productos || [])
    .filter((p) => esServicio(p) && p.activo !== false)
    .slice()
    .sort((a, b) => String(a.nombre || "").localeCompare(String(b.nombre || ""), "es"));
}

export function catalogoSinServicios(productos) {
  return (productos || []).filter((p) => !esServicio(p));
}

/**
 * Pre-cobro: un servicio no se compara contra stock.
 * Sin producto en catálogo, un renglón normal sí falta.
 */
export function lineaFaltaStock(linea, producto, available) {
  if (esServicio(linea) || esServicio(producto)) return false;
  // Sin fila local, el servidor decide. Igual que el cobro de siempre.
  if (!producto) return false;
  const requested = Number(linea?.qty) || 0;
  return requested > available;
}
