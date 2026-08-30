'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { buildAlertaRappiTexto, parseDestinos, notifyRappiStaff } = require('./rappiAlerta');
const { skuInternoDesdeRappi, normalizeRappiInboundOrder } = require('./rappiIngest');

describe('alerta Rappi al mostrador', () => {
  it('arma el texto del pedido', () => {
    const t = buildAlertaRappiTexto({
      order: { external_order_id: '2468274038', items: [{ sku: 'EQ-ULT146', qty: 4 }] },
      pedidoId: 88,
    });
    assert.match(t, /2468274038/);
    assert.match(t, /EQ-ULT146 × 4/);
    assert.match(t, /Aliados/);
  });

  it('parte teléfonos y correos', () => {
    assert.deepEqual(parseDestinos('55 6253 0631, erika@farmacapital.mx'), [
      '55 6253 0631',
      'erika@farmacapital.mx',
    ]);
  });

  it('manda WhatsApp y correo a los destinos de config', async () => {
    const wa = [];
    const mail = [];
    const r = await notifyRappiStaff({
      order: { external_order_id: '1', items: [{ sku: 'EQ-ULT146', qty: 2 }] },
      pedidoId: 9,
      supabase: { supabaseUrl: 'https://example.supabase.co', serviceKey: 't' },
      fetchFn: async () => ({
        json: async () => [
          { clave: 'rappi_alerta_whatsapp', valor: '5511111111' },
          { clave: 'rappi_alerta_email', valor: 'caja@farmacapital.mx' },
        ],
      }),
      sendWaFn: async (args) => {
        wa.push(args);
        return { sent: true };
      },
      sendMailFn: async (args) => {
        mail.push(args);
        return { sent: true };
      },
    });
    assert.equal(r.ok, true);
    assert.equal(wa[0].to, '5511111111');
    assert.equal(mail[0].to, 'caja@farmacapital.mx');
  });
});

describe('SKU Rappi → interno', () => {
  it('quita el prefijo FARMACAPITALmt_', () => {
    assert.equal(skuInternoDesdeRappi('FARMACAPITALmt_eq-ult146'), 'eq-ult146');
    const n = normalizeRappiInboundOrder({
      order_id: '2468274038',
      items: [{ sku: 'FARMACAPITALmt_eq-ult146', quantity: 4 }],
    });
    assert.equal(n.order.items[0].sku, 'eq-ult146');
  });
});
