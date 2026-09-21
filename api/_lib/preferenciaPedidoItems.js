'use strict';

function round2(n) {
  return Math.round(Number(n) * 100) / 100;
}

/**
 * Líneas de Checkout Pro: cada producto del pedido, luego el envío.
 * Si la suma de piezas no cuadra con el total de productos, se manda un solo renglón.
 */
function itemsPreferenciaPedido({
  pedidoId,
  lineas,
  productsTotal,
  envioFee = 0,
  cargo = 0,
  conceptoCargo = 'Servicio',
} = {}) {
  const productos = [];
  for (const row of Array.isArray(lineas) ? lineas : []) {
    const qtyRaw = Number(row?.cantidad ?? row?.qty);
    const unitRaw = Number(row?.precio_unitario ?? row?.precio);
    const nombre = String(row?.nombre || row?.productos?.nombre || 'Producto').trim() || 'Producto';
    if (!Number.isFinite(qtyRaw) || qtyRaw <= 0 || !Number.isFinite(unitRaw)) continue;
    const entera = Math.abs(qtyRaw - Math.round(qtyRaw)) < 1e-6;
    const quantity = entera ? Math.round(qtyRaw) : 1;
    const unit = entera ? round2(unitRaw) : round2(unitRaw * qtyRaw);
    if (quantity < 1 || !Number.isFinite(unit)) continue;
    productos.push({
      title: nombre.slice(0, 120),
      quantity,
      currency_id: 'MXN',
      unit_price: unit,
    });
  }
  const suma = round2(productos.reduce((s, it) => s + it.quantity * it.unit_price, 0));
  const esperado = round2(productsTotal);
  const items = productos.length && Math.abs(suma - esperado) <= 0.01
    ? productos
    : [{ title: `Pedido #${pedidoId}`, quantity: 1, currency_id: 'MXN', unit_price: esperado }];
  const cargoN = round2(cargo);
  if (cargoN > 0) {
    items.push({ title: String(conceptoCargo || 'Servicio'), quantity: 1, currency_id: 'MXN', unit_price: cargoN });
  }
  const envioN = round2(envioFee);
  if (envioN > 0) {
    items.push({ title: 'Envío a domicilio', quantity: 1, currency_id: 'MXN', unit_price: envioN });
  }
  return items;
}

module.exports = { itemsPreferenciaPedido, round2 };
