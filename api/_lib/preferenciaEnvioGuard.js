'use strict';

function round2(n) {
  return Math.round(Number(n) * 100) / 100;
}

/**
 * Costo de envío que debe ir a Mercado Pago.
 * Ojo: Number(null) === 0 — no usar `Number(costo_envio) >= 0` como “hay cotización”.
 */
function feeEnvioParaPreferencia(pedido) {
  if (String(pedido?.tipo_entrega || '').toLowerCase() !== 'envio') {
    return { ok: true, fee: 0 };
  }
  const envio = pedido?.logistics_meta?.envio && typeof pedido.logistics_meta.envio === 'object'
    ? pedido.logistics_meta.envio
    : {};
  const estado = String(envio.estado || '').toLowerCase();
  const rawCol = pedido?.costo_envio;
  const hasCol = rawCol != null && rawCol !== '' && Number.isFinite(Number(rawCol));
  const metaFee = Number(envio.costo_cotizado);
  const hasMeta = Number.isFinite(metaFee) && metaFee >= 0;
  const quoted = ['cotizado', 'link_enviado', 'pagado'].includes(estado)
    || envio.cobrado_en_checkout === true;

  if (!quoted && !hasCol) {
    return { ok: false, error: 'envio_quote_required' };
  }
  if (!hasCol && !hasMeta) {
    return { ok: false, error: 'envio_quote_required' };
  }
  const fee = hasCol ? Number(rawCol) : metaFee;
  if (!Number.isFinite(fee) || fee < 0) {
    return { ok: false, error: 'envio_quote_required' };
  }
  return { ok: true, fee: round2(fee) };
}

/** Productos + servicio + envío deben cuadrar con pedidos.total. */
function desgloseCuadraPreferencia({ totalDb, envioFee, cargo }) {
  const total = round2(totalDb);
  const envio = round2(envioFee || 0);
  const serv = round2(cargo || 0);
  const productos = round2(total - envio - serv);
  if (productos < -0.001) {
    return { ok: false, error: 'total_desglose_mismatch', productsTotal: productos, envioFee: envio, cargo: serv };
  }
  const suma = round2(productos + envio + serv);
  if (Math.abs(suma - total) > 0.01) {
    return { ok: false, error: 'total_desglose_mismatch', productsTotal: productos, envioFee: envio, cargo: serv };
  }
  return { ok: true, productsTotal: Math.max(0, productos), envioFee: envio, cargo: serv, total };
}

module.exports = {
  feeEnvioParaPreferencia,
  desgloseCuadraPreferencia,
  round2,
};
