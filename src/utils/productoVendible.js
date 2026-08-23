/** Acepta 15.5 o 15,5. Vacío → NaN. */
export function parseDinero(raw) {
  const t = String(raw ?? "").trim().replace(/\s/g, "").replace(",", ".");
  if (!t) return NaN;
  const n = parseFloat(t);
  return Number.isFinite(n) ? n : NaN;
}

/** Precio de lista usable en POS / tienda. $0.01 es placeholder de alta. */
export function productoPrecioLista(producto) {
  const n = parseDinero(producto?.precio);
  return Number.isFinite(n) ? n : 0;
}

export function productoEsVendible(producto) {
  return productoPrecioLista(producto) > 0.01;
}
