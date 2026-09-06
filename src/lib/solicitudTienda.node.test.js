"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("solicitudTienda (src)", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "solicitudTienda.js")).href);
  const { validarSolicitudTienda, normalizarTelefonoPedido, buildSolicitudWhatsAppCliente } = mod;

  it("exige nombre, teléfono 10 dígitos y texto", () => {
    assert.equal(
      validarSolicitudTienda({ texto: "a", nombre: "Ana", telefono: "5512345678", cantidad: 1 }).ok,
      false,
    );
    const ok = validarSolicitudTienda({
      texto: "Losartan 50 mg",
      nombre: "Ana Pérez",
      telefono: "55 1234 5678",
      cantidad: 2,
    });
    assert.equal(ok.ok, true);
    assert.equal(ok.value.cliente_telefono, "5512345678");
    assert.equal(ok.value.cantidad, 2);
  });

  it("arma wa.me al cliente", () => {
    assert.equal(normalizarTelefonoPedido("5215512345678"), "5512345678");
    const url = buildSolicitudWhatsAppCliente({
      telefono: "5512345678",
      texto: "Losartan",
      nombre: "Ana",
    });
    assert.match(url, /^https:\/\/wa\.me\/525512345678\?text=/);
    assert.match(decodeURIComponent(url), /Losartan/);
  });
});
