'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { validarSolicitudTienda, buildStaffEmail, STAFF_EMAILS } = require('./solicitudTienda');

describe('solicitudTienda', () => {
  it('rechaza honeypot y campos cortos', () => {
    const spam = validarSolicitudTienda({
      texto: 'Losartan',
      nombre: 'Ana',
      telefono: '5512345678',
      cantidad: 1,
      website: 'http://spam.test',
    });
    assert.equal(spam.honeypot, true);
    assert.equal(validarSolicitudTienda({ texto: 'x', nombre: 'Ana', telefono: '5512345678', cantidad: 1 }).ok, false);
  });

  it('acepta solicitud mínima y arma correo a ambos destinos', () => {
    const parsed = validarSolicitudTienda({
      texto: '  Bumetadida 1 mg  ',
      nombre: 'Luis',
      telefono: '55-6253-0631',
      cantidad: 1,
      email: 'cliente@example.com',
    });
    assert.equal(parsed.ok, true);
    assert.equal(parsed.value.texto, 'Bumetadida 1 mg');
    const mail = buildStaffEmail({ value: parsed.value, id: 12 });
    assert.match(mail.subject, /#LQ-12/);
    assert.deepEqual(mail.to, STAFF_EMAILS);
    assert.match(mail.text, /contacto@farmacapital.mx|WhatsApp/);
    assert.match(mail.text, /Bumetadida/);
    assert.ok(STAFF_EMAILS.includes('farmacapital@outlook.com'));
  });
});
