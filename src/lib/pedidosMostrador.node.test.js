"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("pedidosMostrador", async () => {
  const mod = await import(
    pathToFileURL(path.join(__dirname, "pedidosMostrador.js")).href
  );
  const {
    ESTADOS_SOLICITUD,
    URGENCIAS,
    PAGOS,
    FILTROS_LISTA,
    etiquetaEstado,
    etiquetaUrgencia,
    etiquetaTipo,
    etiquetaPago,
    siguientesEstados,
    normalizarTextoSolicitud,
    puedeGuardarSolicitud,
  } = mod;

  it("normaliza espacios y recorta a 200", () => {
    assert.equal(normalizarTextoSolicitud("  bumetadina   1mg  "), "bumetadina 1mg");
    assert.equal(normalizarTextoSolicitud("x".repeat(250)).length, 200);
  });

  it("exige texto y cantidad válidos para guardar", () => {
    assert.equal(puedeGuardarSolicitud({ texto: "a", cantidad: 1 }), false);
    assert.equal(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 1 }), true);
    assert.equal(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 0 }), false);
    assert.equal(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 999 }), true);
    assert.equal(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 1000 }), false);
  });

  it("cubre estados, urgencias y pagos del contrato SQL", () => {
    assert.deepEqual(
      ESTADOS_SOLICITUD.map((e) => e.id),
      ["pendiente", "pedir", "pedido", "llego", "descartado"],
    );
    assert.deepEqual(
      URGENCIAS.map((u) => u.id),
      ["hoy", "manana", "sin_prisa"],
    );
    assert.deepEqual(
      PAGOS.map((p) => p.id),
      ["nada", "deposito", "completo"],
    );
    assert.ok(FILTROS_LISTA.some((f) => f.id === "abiertas"));
  });

  it("sugiere siguientes estados desde pendiente y pedido", () => {
    assert.ok(siguientesEstados("pendiente").includes("pedir"));
    assert.ok(siguientesEstados("pedido").includes("llego"));
    assert.ok(siguientesEstados("descartado").includes("pendiente"));
  });

  it("etiqueta tipo, urgencia, estado y pago (depósito / todo)", () => {
    assert.match(etiquetaTipo("agotado"), /Agotado/);
    assert.match(etiquetaTipo("no_catalogo"), /catálogo/i);
    assert.equal(etiquetaEstado("pendiente"), "Pendiente");
    assert.equal(etiquetaUrgencia("hoy"), "Hoy");
    assert.match(etiquetaPago("nada"), /Sin anticipo/i);
    assert.match(etiquetaPago("deposito", 50), /50/);
    assert.match(etiquetaPago("completo", 200), /todo/i);
    assert.equal(etiquetaPago("deposito"), "Dejó depósito");
  });
});
