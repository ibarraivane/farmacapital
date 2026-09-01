'use strict';

const Stripe = require('stripe');
const { loadOnlinePedidoForPayment } = require('../../_lib/loadOnlinePedidoForPayment');
const { amountToStripeCents } = require('../../_lib/stripePaymentStatus');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'method_not_allowed' });

  const STRIPE_SECRET_KEY = (process.env.STRIPE_SECRET_KEY || '').trim();
  const SUPABASE_URL = normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || ''
  );
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();

  if (!STRIPE_SECRET_KEY) return res.status(503).json({ ok: false, error: 'stripe_not_configured' });
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'missing_supabase_service_role' });
  }

  const body = await safeJson(req);
  const pedidoId = Number(body?.pedidoId);
  const amount = Number(body?.amount || 0);
  const payer = body?.payer && typeof body.payer === 'object' ? body.payer : {};
  const auth = req.headers.authorization || req.headers.Authorization || '';
  const clienteToken = auth.replace(/^Bearer\s+/i, '').trim();
  const guestPhone = String(body?.guestPhone || body?.guest_telefono || '').replace(/\D/g, '');
  const isGuest = body?.guest === true;

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }
  if (!Number.isFinite(amount) || amount <= 0) {
    return res.status(400).json({ ok: false, error: 'invalid_amount' });
  }
  if (!clienteToken && !isGuest) {
    return res.status(401).json({ ok: false, error: 'missing_cliente_token' });
  }
  if (isGuest && guestPhone.length < 10) {
    return res.status(401).json({ ok: false, error: 'missing_guest_phone' });
  }

  try {
    const loaded = await loadOnlinePedidoForPayment({
      supabaseUrl: SUPABASE_URL,
      serviceKey: SUPABASE_SERVICE_ROLE_KEY,
      pedidoId,
      amount,
      clienteToken,
      isGuest,
      guestPhone,
    });
    if (loaded.error) return res.status(loaded.error.status).json(loaded.error.body);

    const { clienteId, totalDb, serviceHeaders } = loaded;
    const cents = amountToStripeCents(totalDb);
    if (!cents) return res.status(400).json({ ok: false, error: 'invalid_amount_cents' });

    const stripe = new Stripe(STRIPE_SECRET_KEY);
    const externalReference = `FARMACAPITAL-PED-${pedidoId}`;
    const email = String(payer?.email || '').trim().slice(0, 120) || undefined;
    const name = String(payer?.name || '').trim().slice(0, 120) || undefined;

    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: cents,
        currency: 'mxn',
        description: `Pedido #${pedidoId} · FarmaCapital`,
        statement_descriptor_suffix: 'FARMACAP',
        automatic_payment_methods: { enabled: true, allow_redirects: 'never' },
        metadata: {
          pedido_id: String(pedidoId),
          cliente_id: String(clienteId || ''),
          external_reference: externalReference,
          payment_channel: 'apple_google_pay',
        },
        receipt_email: email,
        ...(name
          ? {
              shipping: {
                name,
                address: { country: 'MX' },
              },
            }
          : {}),
      },
      { idempotencyKey: `farmacapital-ped-${pedidoId}-wallet-v1` }
    );

    const patchResp = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
      method: 'PATCH',
      headers: {
        ...serviceHeaders,
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      },
      body: JSON.stringify({
        payment_provider: 'stripe',
        payment_status: 'initiated',
        payment_id: String(paymentIntent.id),
        payment_payload: {
          payment_intent_id: paymentIntent.id,
          wallet: 'apple_google_pay',
          amount_cents: cents,
          currency: 'mxn',
        },
      }),
    });
    if (!patchResp.ok) {
      let patchErr = null;
      try {
        patchErr = await patchResp.json();
      } catch {
        patchErr = await patchResp.text();
      }
      return res.status(502).json({
        ok: false,
        error: 'supabase_payment_tracking_update_failed',
        detail: patchErr || null,
      });
    }

    return res.status(200).json({
      ok: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amountCents: cents,
      currency: 'mxn',
      pedidoId,
    });
  } catch (e) {
    return res.status(500).json({
      ok: false,
      error: 'unexpected_error',
      message: e?.message || 'unknown',
      stripeCode: e?.raw?.code || e?.code || null,
    });
  }
};
