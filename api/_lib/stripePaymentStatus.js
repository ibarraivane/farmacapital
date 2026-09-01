'use strict';

/**
 * Maps Stripe PaymentIntent.status → our pedidos.payment_status values
 * (aligned with Mercado Pago: approved / pending / rejected / …).
 */
function mapStripePaymentIntentStatus(stripeStatus) {
  const s = String(stripeStatus || '').toLowerCase();
  if (s === 'succeeded') return { payment_status: 'approved', approved: true };
  if (s === 'processing' || s === 'requires_capture') {
    return { payment_status: 'pending', approved: false };
  }
  if (s === 'requires_action' || s === 'requires_confirmation' || s === 'requires_payment_method') {
    return { payment_status: 'pending', approved: false };
  }
  if (s === 'canceled') return { payment_status: 'rejected', approved: false };
  return { payment_status: s || 'unknown', approved: false };
}

function amountToStripeCents(mxn) {
  const n = Number(mxn);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.round(n * 100);
}

function stripeCentsToMxn(cents) {
  const n = Number(cents);
  if (!Number.isFinite(n)) return null;
  return Math.round(n) / 100;
}

function pedidoIdFromStripePaymentIntent(pi) {
  const meta = pi?.metadata && typeof pi.metadata === 'object' ? pi.metadata : {};
  const fromMeta = Number(meta.pedido_id || meta.pedidoId || 0);
  if (Number.isFinite(fromMeta) && fromMeta > 0) return fromMeta;
  const ref = String(meta.external_reference || pi?.description || '');
  const m = ref.match(/FARMACAPITAL-PED-(\d+)/i);
  return m ? Number(m[1]) : null;
}

module.exports = {
  mapStripePaymentIntentStatus,
  amountToStripeCents,
  stripeCentsToMxn,
  pedidoIdFromStripePaymentIntent,
};
