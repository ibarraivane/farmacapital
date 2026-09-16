"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("precioCatalogoOnline", async () => {
  const mod = await import(
    pathToFileURL(path.join(__dirname, "precioCatalogoOnline.js")).href
  );
  const { desgloseRecargoPedido, precioConRecargoCatalogo, roundMxn } = mod;

  it("8% sobre 100 = 108", () => {
    assert.equal(precioConRecargoCatalogo(100, 0.08), 108);
  });

  it("redondeo MXN", () => {
    assert.equal(precioConRecargoCatalogo(99.99, 0.08), roundMxn(99.99 * 1.08));
    assert.equal(precioConRecargoCatalogo(150, 0.08), 162);
  });

  it("factor 0 deja base", () => {
    assert.equal(precioConRecargoCatalogo(80, 0), 80);
  });

  it("desglose: items sin recargo + recargo = cobrado", () => {
    const d = desgloseRecargoPedido(
      [
        { precioBase: 100, qty: 1 },
        { precioBase: 50, qty: 2 },
      ],
      0.08
    );
    assert.equal(d.subtotal_productos, 200);
    assert.equal(d.monto_cobrado_mercadopago, roundMxn(108 + 54 * 2));
    assert.equal(
      roundMxn(d.subtotal_productos + d.recargo_procesamiento_pago),
      d.monto_cobrado_mercadopago
    );
  });
});
