'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const {
  elegirDominioVerificado,
  resolverFromVerificado,
  resetResendDomainCache,
} = require('./resendFrom');
const { sendEmail } = require('./orderNotifications');

const FROM = 'FarmaCapital <contacto@farmacapital.mx>';

describe('elegirDominioVerificado', () => {
  it('prefiere el dominio pedido cuando ya está verificado', () => {
    const elegido = elegirDominioVerificado([
      { name: 'mail.farmacapital.mx', status: 'verified' },
      { name: 'farmacapital.mx', status: 'verified' },
    ], 'farmacapital.mx');
    assert.equal(elegido, 'farmacapital.mx');
  });

  it('si el apex no está verificado, usa el subdominio que sí', () => {
    const elegido = elegirDominioVerificado([
      { name: 'farmacapital.mx', status: 'not_started' },
      { name: 'mail.farmacapital.mx', status: 'verified', capabilities: { sending: 'enabled' } },
    ], 'farmacapital.mx');
    assert.equal(elegido, 'mail.farmacapital.mx');
  });

  it('ignora un dominio con envío apagado y devuelve null si no hay otro', () => {
    assert.equal(elegirDominioVerificado([
      { name: 'farmacapital.mx', status: 'verified', capabilities: { sending: 'disabled' } },
    ], 'farmacapital.mx'), null);
  });
});

describe('sendEmail elige el remitente verificado', () => {
  let originalFetch;
  beforeEach(() => {
    resetResendDomainCache();
    process.env.RESEND_API_KEY = 're_test_key';
    originalFetch = global.fetch;
  });
  afterEach(() => {
    global.fetch = originalFetch;
    delete process.env.RESEND_API_KEY;
    resetResendDomainCache();
  });

  it('reescribe el From al dominio verificado de la cuenta', async () => {
    const calls = [];
    global.fetch = async (url, opts = {}) => {
      calls.push({ url: String(url), body: opts.body ? JSON.parse(opts.body) : null });
      if (String(url).includes('/domains')) {
        return {
          ok: true,
          json: async () => ({
            data: [{ name: 'mail.farmacapital.mx', status: 'verified' }],
          }),
        };
      }
      return { ok: true, json: async () => ({ id: 'email_1' }) };
    };
    const r = await sendEmail({
      to: 'ibarra.ivan@outlook.com',
      subject: 'Pedido',
      text: 'Hola',
      from: FROM,
      replyTo: 'contacto@farmacapital.mx',
    });
    assert.equal(r.sent, true);
    assert.equal(r.from, 'FarmaCapital <contacto@mail.farmacapital.mx>');
    const post = calls.find((c) => c.url.includes('/emails'));
    assert.equal(post.body.from, 'FarmaCapital <contacto@mail.farmacapital.mx>');
    assert.equal(post.body.reply_to, 'contacto@farmacapital.mx');
  });

  it('no intenta enviar si ningún dominio está verificado', async () => {
    const calls = [];
    global.fetch = async (url) => {
      calls.push(String(url));
      return {
        ok: true,
        json: async () => ({ data: [{ name: 'farmacapital.mx', status: 'pending' }] }),
      };
    };
    const r = await sendEmail({
      to: 'ibarra.ivan@outlook.com',
      subject: 'Pedido',
      text: 'Hola',
      from: FROM,
    });
    assert.equal(r.sent, false);
    assert.equal(r.reason, 'domain_not_verified');
    assert.equal(calls.some((u) => u.includes('/emails')), false);
  });

  it('si la lista de dominios no responde, manda con el From pedido', async () => {
    global.fetch = async (url, opts = {}) => {
      if (String(url).includes('/domains')) return { ok: false, status: 401, json: async () => ({}) };
      const body = JSON.parse(opts.body);
      assert.equal(body.from, FROM);
      return { ok: true, json: async () => ({ id: 'email_2' }) };
    };
    const r = await sendEmail({
      to: 'ibarra.ivan@outlook.com',
      subject: 'Pedido',
      text: 'Hola',
      from: FROM,
    });
    assert.equal(r.sent, true);
    assert.equal(r.from, FROM);
  });
});

describe('resolverFromVerificado', () => {
  it('deja el From original cuando el dominio pedido ya está verificado', async () => {
    resetResendDomainCache();
    const r = await resolverFromVerificado({
      apiKey: 're_exact',
      from: FROM,
      fetchImpl: async () => ({
        ok: true,
        json: async () => ({ data: [{ name: 'farmacapital.mx', status: 'verified' }] }),
      }),
    });
    assert.equal(r.ok, true);
    assert.equal(r.from, FROM);
    assert.equal(r.rewritten, false);
    resetResendDomainCache();
  });
});
