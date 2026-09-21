'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  haversineKm,
  lookupTarifa,
  calcularCostoEnvio,
  estimarEnvioDesdeCoords,
  getEnvioConfig,
  coloniaEsPropia,
  proveedorSugerido,
  deadlineCotizacionIso,
  cotizacionVencida,
  puedeDespacharEnvio,
  DEFAULT_TARIFAS,
  totalPedidoConCostoEnvio,
  cotizacionEnvioMeta,
  textoClienteEnvioEnCheckout,
} = require('./envioDomicilio');

describe('envioDomicilio tarifas y radio', () => {
  it('tramo 0–2 km cobra $30 y es gratis desde $180', () => {
    const a = calcularCostoEnvio({ distanciaKm: 0, subtotal: 100 });
    assert.equal(a.ok, true);
    assert.equal(a.costo, 30);
    const b = calcularCostoEnvio({ distanciaKm: 2, subtotal: 180 });
    assert.equal(b.ok, true);
    assert.equal(b.costo, 0);
    assert.equal(b.gratis, true);
  });

  it('tramo 2–4 y 4–5', () => {
    assert.equal(calcularCostoEnvio({ distanciaKm: 2.01, subtotal: 50 }).costo, 45);
    assert.equal(calcularCostoEnvio({ distanciaKm: 4, subtotal: 50 }).costo, 45);
    assert.equal(calcularCostoEnvio({ distanciaKm: 4.01, subtotal: 50 }).costo, 65);
    assert.equal(calcularCostoEnvio({ distanciaKm: 5, subtotal: 50 }).costo, 65);
    assert.equal(calcularCostoEnvio({ distanciaKm: 5, subtotal: 320 }).costo, 0);
  });

  it('rechaza 5.01 km y sin tramo', () => {
    const r = calcularCostoEnvio({ distanciaKm: 5.01, radioMaximoKm: 5 });
    assert.equal(r.ok, false);
    assert.equal(r.error, 'fuera_radio');
    assert.equal(lookupTarifa(5.01, DEFAULT_TARIFAS), null);
  });

  it('lee config de env sin hardcode de negocio', () => {
    const cfg = getEnvioConfig({
      RADIO_MAXIMO_KM: '4',
      TIEMPO_MAXIMO_COTIZACION_MIN: '12',
      ENVIO_PROVEEDOR_DEFAULT: 'didi',
      FACTOR_COLCHON_PREAUTORIZACION: '1.4',
      ENVIO_COLONIAS_PROPIO: 'Chinampac de Juárez, Reforma Política',
    });
    assert.equal(cfg.radioMaximoKm, 4);
    assert.equal(cfg.tiempoMaximoCotizacionMin, 12);
    assert.equal(cfg.proveedorDefault, 'didi');
    assert.equal(cfg.factorColchonPreautorizacion, 1.4);
    assert.ok(coloniaEsPropia('Col. Chinampac de Juarez', cfg.coloniasPropio));
    assert.equal(proveedorSugerido('Reforma Política', cfg), 'propio');
    assert.equal(proveedorSugerido('Roma Norte', cfg), 'didi');
  });
});

describe('envioDomicilio cotización en checkout', () => {
  it('cotización del vendedor entra al total del checkout', () => {
    const { itemsTotal, total } = totalPedidoConCostoEnvio(480, null, 60);
    assert.equal(itemsTotal, 480);
    assert.equal(total, 540);
    const otra = totalPedidoConCostoEnvio(540, 60, 75);
    assert.equal(otra.itemsTotal, 480);
    assert.equal(otra.total, 555);
    const meta = cotizacionEnvioMeta(
      { calle: 'Río Grijalva 37' },
      { costo: 60, proveedor: 'didi', distanciaKm: null, now: new Date('2026-09-21T00:00:00Z') },
    );
    assert.equal(meta.cobrado_en_checkout, true);
    assert.equal(meta.estado, 'cotizado');
    assert.equal(meta.costo_cotizado, 60);
    assert.equal(meta.distancia_km, null);
    assert.equal(meta.calle, 'Río Grijalva 37');
    const texto = textoClienteEnvioEnCheckout({
      pedidoId: 333,
      costo: 60,
      itemsTotal: 480,
      total: 540,
    });
    assert.match(texto, /Pagar ahora/);
    assert.match(texto, /\/pagar\?pedido=333/);
    assert.match(texto, /Todavía no está pagado/);
    assert.doesNotMatch(texto, /\/carrito/);
    assert.match(texto, /envío \$60\.00/);
    assert.match(texto, /\$540\.00/);
  });

  it('el correo sale de contacto y abre la liga para pagar', () => {
    const { correoAvisoEnvioCotizado } = require('./envioDomicilio');
    const mail = correoAvisoEnvioCotizado({
      pedidoId: 333,
      costo: 60,
      itemsTotal: 480,
      total: 540,
      nombre: 'Ivan Ibarra',
    });
    assert.equal(mail.from, 'FarmaCapital <contacto@farmacapital.mx>');
    assert.equal(mail.replyTo, 'contacto@farmacapital.mx');
    assert.match(mail.subject, /#FC-0333/);
    assert.match(mail.subject, /ya tiene precio/);
    assert.match(mail.text, /Hola Ivan Ibarra/);
    assert.match(mail.text, /Envío a domicilio: \$60\.00/);
    assert.match(mail.text, /Total a pagar: \$540\.00/);
    assert.match(mail.text, /ticket de compra se crea cuando terminas el pago/);
    assert.doesNotMatch(mail.text, /va adjunto/);
    assert.equal(mail.filename, undefined);
    assert.match(mail.text, /Todavía no está pagado/);
    assert.match(mail.text, /https:\/\/www\.farmacapital\.mx\/pagar\?pedido=333/);
    assert.match(mail.html, /href="https:\/\/www\.farmacapital\.mx\/pagar\?pedido=333"/);
    assert.doesNotMatch(mail.text, /ya está confirmado/);
    assert.doesNotMatch(mail.text, /\/carrito/);
    assert.doesNotMatch(mail.html, /\/carrito/);
    assert.match(mail.html, /Pagar \$540\.00/);
    assert.match(mail.html, /Paso 2 de 5/);
  });
  it('el Servicio $5 aparece en el desglose del correo y de WhatsApp', () => {
    const { correoAvisoEnvioCotizado, desglosePedido, cargoServicioPedido } = require('./envioDomicilio');
    // Pedido con envío: productos 202 + servicio 5 (trigger) + envío 100
    const pedido = { total: 207, logistics_meta: { cargo_plataforma_mxn: 5 } };
    const { itemsTotal, total } = totalPedidoConCostoEnvio(pedido.total, null, 100);
    assert.equal(total, 307);
    const d = desglosePedido(total, 100, cargoServicioPedido(pedido));
    assert.deepEqual(d, { productos: 202, servicio: 5, envio: 100, total: 307 });
    assert.equal(itemsTotal, 207); // por eso ya no se usa itemsTotal para el correo
    const mail = correoAvisoEnvioCotizado({
      pedidoId: 441, costo: 100, itemsTotal: d.productos, cargo: d.servicio, total,
      items: [{ nombre: 'A', cantidad: 1, precio_unitario: 85 }, { nombre: 'B', cantidad: 1, precio_unitario: 59 }, { nombre: 'C', cantidad: 1, precio_unitario: 58 }],
    });
    assert.match(mail.text, /Productos: \$202\.00/);
    assert.match(mail.text, /Servicio: \$5\.00/);
    assert.match(mail.text, /Total a pagar: \$307\.00/);
    assert.match(mail.html, />Servicio</);
    const wa = textoClienteEnvioEnCheckout({ pedidoId: 441, costo: 100, itemsTotal: 202, cargo: 5, total: 307 });
    assert.match(wa, /Productos \$202\.00 \+ servicio \$5\.00 \+ envío \$100\.00 = \$307\.00/);
  });

  it('recoger en tienda no lleva Servicio', () => {
    const { desglosePedido, cargoServicioPedido } = require('./envioDomicilio');
    const d = desglosePedido(202, 0, cargoServicioPedido({ logistics_meta: { cargo_plataforma_mxn: 0 } }));
    assert.deepEqual(d, { productos: 202, servicio: 0, envio: 0, total: 202 });
  });

  it('haversine de la sucursal a ~0 km', () => {
    const d = haversineKm(19.3714047, -99.0526916, 19.3714047, -99.0526916);
    assert.equal(d, 0);
  });

  it('estima dentro y fuera de radio desde coords', () => {
    const cfg = getEnvioConfig({});
    const cerca = estimarEnvioDesdeCoords({
      lat: 19.375, lng: -99.055, subtotal: 80, config: cfg,
    });
    assert.equal(cerca.ok, true);
    assert.ok(cerca.distancia_km < 5);
    const lejos = estimarEnvioDesdeCoords({
      lat: 19.43, lng: -99.19, subtotal: 80, config: { ...cfg, radioMaximoKm: 5 },
    });
    assert.equal(lejos.ok, false);
    assert.equal(lejos.error, 'fuera_radio');
    const lejosSinTope = estimarEnvioDesdeCoords({
      lat: 19.43, lng: -99.19, subtotal: 80, config: { ...cfg, radioMaximoKm: 0 },
    });
    assert.equal(lejosSinTope.ok, true);
  });
});

describe('envioDomicilio SLA y despacho', () => {
  it('deadline y vencido', () => {
    const iso = deadlineCotizacionIso(new Date('2026-09-15T18:00:00Z'), 15);
    assert.equal(iso, '2026-09-15T18:15:00.000Z');
    assert.equal(cotizacionVencida('2026-09-15T18:14:00Z', new Date('2026-09-15T18:15:00Z')), true);
    assert.equal(cotizacionVencida('2026-09-15T18:16:00Z', new Date('2026-09-15T18:15:00Z')), false);
  });

  it('solo despacha si pagó o el envío es gratis', () => {
    assert.equal(puedeDespacharEnvio({ estado: 'pagado', costo_cotizado: 45 }), true);
    assert.equal(puedeDespacharEnvio({ estado: 'cotizado', costo_cotizado: 0 }), true);
    assert.equal(puedeDespacharEnvio({ estado: 'cotizado', costo_cotizado: 45 }), false);
    assert.equal(puedeDespacharEnvio({ estado: 'pendiente_cotizacion' }), false);
    assert.equal(puedeDespacharEnvio({
      estado: 'cotizado', costo_cotizado: 45, cobrado_en_checkout: true,
    }), false);
    assert.equal(puedeDespacharEnvio({
      estado: 'cotizado', costo_cotizado: 45, cobrado_en_checkout: true,
    }, { paymentApproved: true }), true);
  });
});
