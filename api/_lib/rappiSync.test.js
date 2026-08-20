'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  applyPushResult,
  drainSimulatedQueue,
  MAX_INTENTOS,
  loginIntegrationsUrl,
  rappiAuthHeaders,
  getIntegrationsAccessToken,
  resetRappiTokenCache,
} = require('./rappiSync');
const { normalizeRappiInboundOrder } = require('./rappiIngest');

function row(overrides) {
  return {
    id: 1,
    sku: 'EQ-AVT216',
    estado: 'pendiente',
    intentos: 0,
    payload: { sku: 'EQ-AVT216', disponible: false, stock_rappi: 0 },
    available_at: new Date(0).toISOString(),
    created_at: new Date(0).toISOString(),
    ...overrides,
  };
}

describe('rappiSync worker (cola simulada, sin HTTP a Rappi)', () => {
  it('queda inerte si faltan credenciales', async () => {
    const queue = [row()];
    const res = await drainSimulatedQueue(queue, {
      creds: { hasSecrets: false, apiBase: '' },
      pushFn: async () => {
        throw new Error('no debe llamar a Rappi');
      },
    });
    assert.equal(res.skipped, 'no_credentials');
    assert.equal(queue[0].estado, 'pendiente');
  });

  it('queda inerte sin RAPPI_API_BASE aunque haya secretos', async () => {
    const queue = [row()];
    const res = await drainSimulatedQueue(queue, {
      creds: { hasSecrets: true, apiBase: '' },
      pushFn: async () => {
        throw new Error('no debe llamar a Rappi');
      },
    });
    assert.equal(res.skipped, 'adapter_unverified');
    assert.equal(queue[0].estado, 'pendiente');
  });

  it('no drena si el sync está pausado', async () => {
    const queue = [row()];
    const res = await drainSimulatedQueue(queue, {
      creds: { hasSecrets: true, apiBase: 'https://example.invalid' },
      paused: true,
      pushFn: async () => ({ ok: true }),
    });
    assert.equal(res.skipped, 'paused');
    assert.equal(queue[0].estado, 'pendiente');
  });

  it('marca ok con push simulado y reintenta con backoff', async () => {
    const okRow = row({ id: 1 });
    const failRow = row({ id: 2, sku: 'EQ-NOV179', payload: { sku: 'EQ-NOV179', disponible: true } });
    const res = await drainSimulatedQueue([okRow, failRow], {
      creds: { hasSecrets: true, apiBase: 'https://example.invalid' },
      allowUnverifiedPush: true,
      pushFn: async (payload) =>
        payload.sku === 'EQ-AVT216' ? { ok: true } : { ok: false, error: 'rate_limit' },
    });
    assert.equal(res.processed, 2);
    assert.equal(okRow.estado, 'ok');
    assert.equal(failRow.estado, 'pendiente');
    assert.ok(new Date(failRow.available_at).getTime() > Date.now());
    assert.equal(failRow.intentos, 1);
  });

  it('tras 5 intentos marca error', () => {
    const patch = applyPushResult(
      { intentos: MAX_INTENTOS },
      { ok: false, error: 'timeout' },
      new Date('2026-08-19T12:00:00Z')
    );
    assert.equal(patch.estado, 'error');
    assert.equal(patch.last_error, 'timeout');
  });
});

describe('ingestRappiOrder (RPC simulado)', () => {
  it('manda el pedido canónico al RPC y no llama a Rappi', async () => {
    const { ingestRappiOrder } = require('./rappiIngest');
    let seen = null;
    const r = await ingestRappiOrder(
      { order_id: 'RAPP-9', items: [{ sku: 'EQ-AVT216', quantity: 1 }] },
      {
        supabase: { supabaseUrl: 'https://example.supabase.co', serviceKey: 'test' },
        rpcFn: async (_key, _url, fn, payload) => {
          seen = { fn, payload };
          return { ok: true, pedido_id: 42 };
        },
      }
    );
    assert.equal(r.ok, true);
    assert.equal(r.pedido_id, 42);
    assert.equal(seen.fn, 'ingest_rappi_order');
    assert.equal(seen.payload.p_payload.external_order_id, 'RAPP-9');
    assert.deepEqual(seen.payload.p_payload.items, [{ sku: 'EQ-AVT216', qty: 1 }]);
  });
});

describe('normalizeRappiInboundOrder', () => {
  it('exige external_order_id e items', () => {
    assert.equal(normalizeRappiInboundOrder({}).ok, false);
    const n = normalizeRappiInboundOrder({
      order_id: 'RAPP-1',
      items: [{ sku: 'EQ-AVT216', quantity: 2 }],
    });
    assert.equal(n.ok, true);
    assert.equal(n.order.external_order_id, 'RAPP-1');
    assert.deepEqual(n.order.items, [{ sku: 'EQ-AVT216', qty: 2 }]);
  });
});

describe('Rappi Authentication (docs)', () => {
  it('arma el login de integrations en el NEW_DOMAIN', () => {
    assert.equal(
      loginIntegrationsUrl('https://api.dev.rappi.com'),
      'https://api.dev.rappi.com/restaurants/auth/v1/token/login/integrations'
    );
    assert.equal(
      loginIntegrationsUrl('https://api.rappi.com.mx/'),
      'https://api.rappi.com.mx/restaurants/auth/v1/token/login/integrations'
    );
  });

  it('manda el token en x-authorization, no Basic', () => {
    const h = rappiAuthHeaders('tok_abc');
    assert.equal(h['x-authorization'], 'Bearer: tok_abc');
    assert.equal(h.Authorization, undefined);
  });

  it('pide el access_token con client_id/client_secret', async () => {
    resetRappiTokenCache();
    let seen = null;
    const token = await getIntegrationsAccessToken(
      { clientId: 'id1', clientSecret: 'sec1', apiBase: 'https://api.dev.rappi.com' },
      async (url, opts) => {
        seen = { url, body: JSON.parse(opts.body) };
        return {
          ok: true,
          json: async () => ({ access_token: 'jwt-x', token_type: 'Bearer', expires_in: 86400 }),
        };
      }
    );
    assert.equal(token, 'jwt-x');
    assert.equal(seen.url, 'https://api.dev.rappi.com/restaurants/auth/v1/token/login/integrations');
    assert.deepEqual(seen.body, { client_id: 'id1', client_secret: 'sec1' });
  });
});
