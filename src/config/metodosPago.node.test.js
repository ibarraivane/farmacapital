"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("metodosPago config", async () => {
  const mod = await import(
    pathToFileURL(path.join(__dirname, "metodosPago.js")).href
  );
  const {
    cumpleMontoMinimoEnvio,
    mensajeMontoMinimoPedidoOnline,
    montoMinimoPedidoOnline,
    recargoCatalogoOnline,
  } = mod;

  it("defaults sin mínimo de envío y 8% recargo", () => {
    assert.equal(montoMinimoPedidoOnline(), 0);
    assert.equal(recargoCatalogoOnline(), 0.08);
  });

  it("sin piso (0) cualquier subtotal de productos pasa", () => {
    assert.equal(cumpleMontoMinimoEnvio(20), true);
    assert.equal(cumpleMontoMinimoEnvio(0.01, 0), true);
    assert.equal(cumpleMontoMinimoEnvio(0, 0), true);
  });

  it("bordes si se reactiva un mínimo", () => {
    assert.equal(cumpleMontoMinimoEnvio(149.99, 150), false);
    assert.equal(cumpleMontoMinimoEnvio(150, 150), true);
    assert.equal(cumpleMontoMinimoEnvio(150.0, 150), true);
    assert.equal(cumpleMontoMinimoEnvio(20, 150), false);
  });

  it("mensaje vacío sin piso; con piso menciona el monto", () => {
    assert.equal(mensajeMontoMinimoPedidoOnline(0), "");
    assert.match(mensajeMontoMinimoPedidoOnline(150), /\$150/);
    assert.match(mensajeMontoMinimoPedidoOnline(150), /farmacia/i);
  });
});
