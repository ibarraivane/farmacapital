'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const T = require('./emailTemplates');
const { buildPagoAprobadoEmail } = require('./orderNotifications');

const items = [
  { nombre: 'Omeprazol 20 mg', cantidad: 2, importe: 98 },
  { nombre: 'Ibuprofeno 400 mg', cantidad: 1, importe: 46 },
  { nombre: 'Losartán 50 mg', cantidad: 1, importe: 58 },
];

describe('plantillas de correo v2', () => {
  it('pedir reseña nombra cada producto y no se publica sola', () => {
    const m = T.pedirResena({
      pedidoId: 441,
      nombre: 'Ivan',
      urlResena: 'https://www.farmacapital.mx/cuenta?resena=abc',
      productos: [{ id: 9, nombre: 'Shampoo' }, { id: 10, nombre: 'CeraVe' }],
    });
    assert.match(m.subject, /441/);
    assert.match(m.html, /Shampoo/);
    assert.match(m.html, /CeraVe/);
    assert.match(m.html, /resena=abc/);
    assert.match(m.text, /no se publica sola/);
    assert.match(m.html, /prefers-color-scheme:dark/);
  });

  it('los 5 correos devuelven asunto, preheader, html y texto', () => {
    const all = [
      T.envioCotizado({ pedidoId: 441, nombre: 'Ivan', items, servicio: 5, envio: 100, total: 307 }),
      T.pagoAprobado({ pedidoId: 441, nombre: 'Ivan', items, servicio: 5, envio: 100, total: 307, entrega: 'envio' }),
      T.listoParaRecoger({ pedidoId: 442, nombre: 'Ivan', requiereReceta: true }),
      T.enCamino({ pedidoId: 441, nombre: 'Ivan', paqueteria: 'Uber Direct', llegada: '12:40 h' }),
      T.cotizacionEspecializado({ folio: 'COT-0142', nombre: 'Ivan', medicamento: 'X', precio: 4850 }),
    ];
    for (const m of all) {
      assert.ok(m.subject && m.html && m.text);
      assert.match(m.html, /prefers-color-scheme:dark/);
    }
  });

  it('el desglose muestra el Servicio y cuadra', () => {
    const m = T.envioCotizado({ pedidoId: 441, items, servicio: 5, envio: 100, total: 307 });
    assert.match(m.text, /Productos: \$202\.00/);
    assert.match(m.text, /Servicio: \$5\.00/);
    assert.match(m.text, /Total a pagar: \$307\.00/);
    const d = T._internals.desglose({ items, servicio: 5, envio: 100, total: 307 }, 'Total');
    assert.equal(d.cuadra, true);
  });

  it('recoger no lleva Servicio ni envío', () => {
    const m = T.pagoAprobado({ pedidoId: 9, items, total: 202, entrega: 'recoger' });
    assert.doesNotMatch(m.text, /Servicio/);
    assert.doesNotMatch(m.text, /Envío a domicilio/);
  });

  it('detecta un desglose que no cuadra', () => {
    const warn = console.warn; let avisado = false; console.warn = () => { avisado = true; };
    const d = T._internals.desglose({ items, subtotal: 207, envio: 100, total: 307 }, 'Total');
    console.warn = warn;
    assert.equal(d.cuadra, false);
    assert.equal(avisado, true);
  });

  it('escapa el HTML de los datos', () => {
    const m = T.envioCotizado({ pedidoId: 1, nombre: '<script>', items: [{ nombre: 'A&B "x"', importe: 1 }], total: 1 });
    assert.doesNotMatch(m.html, /<script>/);
    assert.match(m.html, /A&amp;B/);
  });

  it('nunca muestra calle: el destino es solo lo que se pasa (colonia)', () => {
    const m = T.envioCotizado({ pedidoId: 1, items, total: 202, envio: 0, destino: 'Col. Del Valle' });
    assert.match(m.html, /Col\. Del Valle/);
  });
});

describe('correo de pago aprobado desde el pedido', () => {
  it('toma Servicio y envío del pedido y cuadra con el total', () => {
    const m = buildPagoAprobadoEmail({
      pedido: { id: 441, total: 307, tipo_entrega: 'envio', logistics_meta: { cargo_plataforma_mxn: 5, envio: { costo_cotizado: 100 } } },
      cliente: { nombre: 'Ivan' },
      items: [
        { cantidad: 2, precio_unitario: 49, productos: { nombre: 'Omeprazol 20 mg', imagen_url: 'https://x.supabase.co/a.png' } },
        { cantidad: 1, precio_unitario: 46, productos: { nombre: 'Ibuprofeno 400 mg', imagen_url: 'productos/b.png' } },
        { cantidad: 1, precio_unitario: 58, productos: { nombre: 'Losartán 50 mg' } },
      ],
      ticketUrl: 'https://www.farmacapital.mx/r/abc',
    });
    assert.match(m.text, /Productos: \$202\.00/);
    assert.match(m.text, /Servicio: \$5\.00/);
    assert.match(m.text, /Envío a domicilio: \$100\.00/);
    assert.match(m.text, /Total pagado: \$307\.00/);
    assert.match(m.html, /https:\/\/x\.supabase\.co\/a\.png/);
    assert.doesNotMatch(m.html, /productos\/b\.png/);
    assert.match(m.html, /Ver mi ticket/);
  });

  it('pick-up: sin Servicio ni envío', () => {
    const m = buildPagoAprobadoEmail({
      pedido: { id: 9, total: 58, tipo_entrega: 'recoger', logistics_meta: { cargo_plataforma_mxn: 0 } },
      items: [{ cantidad: 1, precio_unitario: 58, productos: { nombre: 'Losartán' } }],
    });
    assert.doesNotMatch(m.text, /Servicio/);
    assert.match(m.text, /Total pagado: \$58\.00/);
  });
});
