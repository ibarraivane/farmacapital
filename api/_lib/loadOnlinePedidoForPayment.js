'use strict';

/**
 * Shared auth + load for online pedido payment endpoints (MP / Stripe).
 */
async function loadOnlinePedidoForPayment({
  supabaseUrl,
  serviceKey,
  pedidoId,
  amount,
  clienteToken,
  isGuest,
  guestPhone,
}) {
  const serviceHeaders = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
  };

  let clienteId = null;

  if (!isGuest) {
    const validTokResp = await fetch(`${supabaseUrl}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: { ...serviceHeaders, 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_token: clienteToken }),
    });
    clienteId = Number(await validTokResp.json());
    if (!validTokResp.ok || !clienteId) {
      return { error: { status: 401, body: { ok: false, error: 'invalid_cliente_token' } } };
    }
  }

  const selectFull =
    'id,cliente_id,total,estado,tipo,metodo_pago,tipo_entrega,created_at,guest_telefono,logistics_meta,delivery_provider,payment_status,payment_provider';
  const selectMin =
    'id,cliente_id,total,estado,tipo,metodo_pago,tipo_entrega,created_at,guest_telefono,delivery_provider,payment_status,payment_provider';

  let pedidoResp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${selectFull}`,
    { headers: serviceHeaders }
  );
  let pedidoRows = await pedidoResp.json();
  if (!pedidoResp.ok) {
    pedidoResp = await fetch(
      `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${selectMin}`,
      { headers: serviceHeaders }
    );
    pedidoRows = await pedidoResp.json();
  }
  const pedido = Array.isArray(pedidoRows) ? pedidoRows[0] : null;
  if (!pedidoResp.ok || !pedido) {
    return { error: { status: 404, body: { ok: false, error: 'pedido_not_found' } } };
  }
  if (!isGuest && Number(pedido.cliente_id) !== clienteId) {
    return { error: { status: 403, body: { ok: false, error: 'pedido_not_owned' } } };
  }
  if (!clienteId) clienteId = Number(pedido.cliente_id);
  if (pedido.tipo !== 'online') {
    return { error: { status: 400, body: { ok: false, error: 'pedido_not_online' } } };
  }
  if (pedido.estado !== 'pendiente') {
    return { error: { status: 409, body: { ok: false, error: 'pedido_not_pending' } } };
  }
  if (String(pedido.payment_status || '').toLowerCase() === 'approved') {
    return { error: { status: 409, body: { ok: false, error: 'pedido_already_paid' } } };
  }

  if (isGuest) {
    const created = new Date(pedido.created_at).getTime();
    if (!Number.isFinite(created) || Date.now() - created > 2 * 60 * 60 * 1000) {
      return { error: { status: 403, body: { ok: false, error: 'guest_checkout_expired' } } };
    }
    let telPedido = String(pedido.guest_telefono || '').replace(/\D/g, '');
    if (telPedido.length < 10 && clienteId) {
      const cliResp = await fetch(
        `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=telefono&limit=1`,
        { headers: serviceHeaders }
      );
      const cliRows = await cliResp.json().catch(() => []);
      telPedido = String(Array.isArray(cliRows) ? cliRows[0]?.telefono || '' : '').replace(/\D/g, '');
    }
    if (telPedido.slice(-10) !== String(guestPhone || '').slice(-10)) {
      return { error: { status: 403, body: { ok: false, error: 'guest_phone_mismatch' } } };
    }
  }

  const totalDb = Number(pedido.total || 0);
  if (!Number.isFinite(totalDb) || totalDb <= 0) {
    return { error: { status: 400, body: { ok: false, error: 'invalid_db_total' } } };
  }
  if (Math.abs(totalDb - Number(amount)) > 0.01) {
    return { error: { status: 409, body: { ok: false, error: 'amount_mismatch' } } };
  }

  const uberSecret = String(process.env.UBER_DIRECT_CLIENT_SECRET || '').trim();
  if (pedido.tipo_entrega === 'envio' && uberSecret) {
    const meta = pedido.logistics_meta && typeof pedido.logistics_meta === 'object' ? pedido.logistics_meta : {};
    const fee = Number(meta?.uber_direct?.fee_mxn);
    const provider = String(pedido.delivery_provider || meta.logistics_provider || '').toLowerCase();
    const hasMetaFee = Number.isFinite(fee) && fee >= 0 && provider === 'uber_direct';
    const hasProviderOnly = pedido.logistics_meta == null && provider === 'uber_direct';
    if (!hasMetaFee && !hasProviderOnly) {
      return { error: { status: 409, body: { ok: false, error: 'uber_quote_required' } } };
    }
  }

  return { pedido, clienteId, totalDb, serviceHeaders };
}

module.exports = { loadOnlinePedidoForPayment };
