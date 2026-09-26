'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { decidirEnvioResena, lineasElegibles } = require('./pedirResena');

const shampoo = { productos: { nombre: 'Shampoo', categoria: 'Higiene' } };
const ibuprofeno = { productos: { nombre: 'Ibuprofeno 400 mg', categoria: 'Analgésico' } };

describe('decidirEnvioResena', () => {
  it('un pedido solo de medicamentos no pide reseña', () => {
    const d = decidirEnvioResena({
      pedido: { estado: 'completado' },
      items: [ibuprofeno],
      emails: ['a@b.com'],
    });
    assert.equal(d.action, 'stamp');
    assert.equal(d.reason, 'sin_productos');
  });

  it('en camino todavía no se pide', () => {
    const d = decidirEnvioResena({
      pedido: { estado: 'listo' },
      items: [shampoo],
      emails: ['a@b.com'],
    });
    assert.equal(d.action, 'skip');
    assert.equal(d.reason, 'not_delivered');
  });

  it('con un producto de la lista blanca y correo, sí se manda', () => {
    const d = decidirEnvioResena({
      pedido: { estado: 'completado' },
      items: [ibuprofeno, shampoo],
      emails: ['a@b.com'],
    });
    assert.equal(d.action, 'send');
    assert.equal(d.elegibles.length, 1);
    assert.equal(lineasElegibles([shampoo, ibuprofeno]).length, 1);
  });

  it('no repite si ya se pidió', () => {
    const d = decidirEnvioResena({
      pedido: { estado: 'completado', resena_pedida_at: '2026-09-23' },
      items: [shampoo],
      emails: ['a@b.com'],
    });
    assert.equal(d.reason, 'already_sent');
  });

  it('sin correo no marca el envío como hecho', () => {
    const d = decidirEnvioResena({
      pedido: { estado: 'completado' },
      items: [shampoo],
      emails: [],
    });
    assert.equal(d.action, 'skip');
    assert.equal(d.reason, 'missing_email');
  });
});
