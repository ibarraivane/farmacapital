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

  it("defaults 150 y 8%", () => {
    assert.equal(montoMinimoPedidoOnline(), 150);
    assert.equal(recargoCatalogoOnline(), 0.08);
  });

  it("bordes de mínimo", () => {
    assert.equal(cumpleMontoMinimoEnvio(149.99, 150), false);
    assert.equal(cumpleMontoMinimoEnvio(150, 150), true);
    assert.equal(cumpleMontoMinimoEnvio(150.0, 150), true);
    assert.equal(cumpleMontoMinimoEnvio(20, 150), false);
  });

  it("mensaje menciona el monto", () => {
    assert.match(mensajeMontoMinimoPedidoOnline(150), /\$150/);
    assert.match(mensajeMontoMinimoPedidoOnline(150), /farmacia/i);
  });
});
