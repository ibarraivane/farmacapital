'use strict';

const Stripe = require('stripe');
const { readRawBody } = require('./supabaseAdmin');
const { sendOrderNotifications } = require('./orderNotifications');
const {
  mapStripePaymentIntentStatus,
  stripeCentsToMxn,
  pedidoIdFromStripePaymentIntent,
} = require('./stripePaymentStatus');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

async function stripeWebhookHandler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'method_not_allowed' });

  const STRIPE_SECRET_KEY = (process.env.STRIPE_SECRET_KEY || '').trim();
  const STRIPE_WEBHOOK_SECRET = (process.env.STRIPE_WEBHOOK_SECRET || '').trim();
  const SUPABASE_URL = normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || ''
  );
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();

  if (!STRIPE_SECRET_KEY || !STRIPE_WEBHOOK_SECRET) {
    return res.status(500).json({ ok: false, error: 'missing_stripe_webhook_env' });
  }
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  const stripe = new Stripe(STRIPE_SECRET_KEY);
  let event;
  try {
    const rawBody = await readRawBody(req);
    const sig = req.headers['stripe-signature'] || req.headers['Stripe-Signature'];
    event = stripe.webhooks.constructEvent(rawBody, sig, STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    return res.status(400).json({
      ok: false,
      error: 'invalid_signature',
      message: err?.message || 'bad_sig',
    });
  }

  try {
    const type = String(event.type || '');
    if (
      type !== 'payment_intent.succeeded' &&
      type !== 'payment_intent.payment_failed' &&
      type !== 'payment_intent.canceled' &&
      type !== 'payment_intent.processing'
    ) {
      return res.status(200).json({ ok: true, ignored: true, reason: `event_${type || 'unknown'}` });
    }

    const pi = event.data?.object;
    if (!pi || !pi.id) {
      return res.status(200).json({ ok: true, ignored: true, reason: 'missing_payment_intent' });
    }

    const pedidoId = pedidoIdFromStripePaymentIntent(pi);
    if (!pedidoId) {
      return res.status(200).json({ ok: true, ignored: true, reason: 'no_pedido_reference' });
    }

    const pedidoResp = await fetch(
      `${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,cliente_id,total,tipo_entrega,payment_status,whatsapp_recibo,logistics_meta&limit=1`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      }
    );
    const pedidoRows = await pedidoResp.json().catch(() => []);
    const pedidoBefore = Array.isArray(pedidoRows) ? pedidoRows[0] : null;

    const mapped = mapStripePaymentIntentStatus(pi.status);
    const status = mapped.payment_status;
    const approved = mapped.approved;
    const paidMxn = stripeCentsToMxn(pi.amount_received || pi.amount);
    if (approved && pedidoBefore) {
      const expected = Number(pedidoBefore.total || 0);
      if (!Number.isFinite(paidMxn) || Math.abs(paidMxn - expected) > 0.5) {
        return res.status(409).json({
          ok: false,
          error: 'payment_amount_mismatch',
          expected,
          paid: paidMxn,
        });
      }
    }

    const walletType =
      pi.charges?.data?.[0]?.payment_method_details?.card?.wallet?.type ||
      pi.metadata?.payment_channel ||
      null;

    const patch = {
      payment_provider: 'stripe',
      payment_status: status || 'unknown',
      payment_id: String(pi.id),
      paid_at: approved ? new Date().toISOString() : null,
      payment_payload: {
        stripe_status: pi.status || null,
        amount_received: pi.amount_received ?? null,
        currency: pi.currency || 'mxn',
        wallet: walletType,
        last_event: type,
        last_event_at: new Date().toISOString(),
      },
    };

    const patchResp = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      },
      body: JSON.stringify(patch),
    });
    if (!patchResp.ok) {
      let detail = null;
      try {
        detail = await patchResp.json();
      } catch {
        detail = await patchResp.text();
      }
      return res.status(502).json({ ok: false, error: 'supabase_update_failed', detail });
    }

    if (approved) {
      try {
        await fetch(`${SUPABASE_URL}/rest/v1/rpc/service_acreditar_puntos_pedido`, {
          method: 'POST',
          headers: {
            apikey: SUPABASE_SERVICE_ROLE_KEY,
            Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ p_pedido_id: pedidoId }),
        });
      } catch (_) {
        // Puntos no bloquean el webhook.
      }
    }

    if (pedidoBefore && pedidoBefore.payment_status !== status) {
      try {
        const [cliResp, itemsResp] = await Promise.all([
          fetch(
            `${SUPABASE_URL}/rest/v1/clientes?id=eq.${pedidoBefore.cliente_id}&select=id,nombre,telefono,email&limit=1`,
            {
              headers: {
                apikey: SUPABASE_SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
              },
            }
          ),
          fetch(
            `${SUPABASE_URL}/rest/v1/pedido_items?pedido_id=eq.${pedidoId}&select=cantidad,precio_unitario,productos(nombre)`,
            {
              headers: {
                apikey: SUPABASE_SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
              },
            }
          ),
        ]);
        const cliRows = await cliResp.json().catch(() => []);
        const itemRows = await itemsResp.json().catch(() => []);
        const cliente = Array.isArray(cliRows) ? cliRows[0] : null;
        const eventName =
          status === 'approved'
            ? 'payment_approved'
            : status === 'pending'
              ? 'payment_pending'
              : 'payment_rejected';
        await sendOrderNotifications({
          event: eventName,
          pedido: { ...pedidoBefore, id: pedidoId },
          cliente: cliente || {},
          items: Array.isArray(itemRows) ? itemRows : [],
        });
      } catch (_) {
        // Notificaciones no bloquean webhook.
      }
    }

    return res.status(200).json({ ok: true, pedidoId, status, event: type });
  } catch (e) {
    return res.status(500).json({
      ok: false,
      error: 'unexpected_error',
      message: e?.message || 'unknown',
    });
  }
}

module.exports = { stripeWebhookHandler };
