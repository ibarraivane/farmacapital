/** Precio de lista usable en POS / tienda. $0.01 es placeholder de alta. */
export function productoPrecioLista(producto) {
  const n = parseFloat(producto?.precio);
  return Number.isFinite(n) ? n : 0;
}

export function productoEsVendible(producto) {
  return productoPrecioLista(producto) > 0.01;
}
