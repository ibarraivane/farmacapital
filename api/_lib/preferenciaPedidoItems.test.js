'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { itemsPreferenciaPedido } = require('./preferenciaPedidoItems');

describe('líneas de Mercado Pago', () => {
  it('manda cada producto y el envío cuando cuadran con el total', () => {
    const items = itemsPreferenciaPedido({
      pedidoId: 441,
      productsTotal: 202,
      envioFee: 100,
      lineas: [
        { cantidad: 1, precio_unitario: 120, productos: { nombre: 'Paracetamol 500 mg' } },
        { cantidad: 2, precio_unitario: 41, productos: { nombre: 'Gasas estériles' } },
      ],
    });
    assert.deepEqual(items.map((i) => [i.title, i.quantity, i.unit_price]), [
      ['Paracetamol 500 mg', 1, 120],
      ['Gasas estériles', 2, 41],
      ['Envío a domicilio', 1, 100],
    ]);
  });

  it('si las piezas no cuadran, deja un solo renglón de productos más el envío', () => {
    const items = itemsPreferenciaPedido({
      pedidoId: 441,
      productsTotal: 202,
      envioFee: 100,
      lineas: [{ cantidad: 1, precio_unitario: 10, productos: { nombre: 'Otra cosa' } }],
    });
    assert.equal(items[0].title, 'Pedido #441');
    assert.equal(items[0].unit_price, 202);
    assert.equal(items[1].title, 'Envío a domicilio');
  });
});
