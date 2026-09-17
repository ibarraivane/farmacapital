"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { validarFicha, validarFichas, armarSql, skuDe, esNombreTicket } = require("./alta-bajo-pedido-desde-fichas");

const ok = {
  ean: "7501234567890",
  nombre: "Omron tensiómetro de brazo HEM-7120",
  marca: "Omron",
  presentacion: "1 pieza",
  categoria: "Dispositivo médico",
  subcategoria: "Diagnóstico",
  forma: "Aparato",
  precio: 899,
  imagen_url: "https://www.farmacapital.mx/catalogo-propia/omron-hem-7120.jpg",
  fuente: "Promexsa · ficha",
};

test("SKU FC- + últimos 8", () => {
  assert.equal(skuDe("7501234567890"), "FC-34567890");
});

test("rechaza código de ticket y marca de casa", () => {
  assert.equal(esNombreTicket("BLOQ ANTHE UVAIR 50+"), true);
  assert.throws(() => validarFicha({ ...ok, nombre: "BLOQ ANTHE UVAIR 50+" }, 0), /ticket/);
  assert.throws(() => validarFicha({ ...ok, marca: "LGEN" }, 0), /casa/);
  assert.throws(() => validarFicha({ ...ok, ean: "ORT-AGH-1100" }, 0), /8 a 14/);
  assert.throws(() => validarFicha({ ...ok, imagen_url: "" }, 0), /imagen/);
});

test("SQL idempotente con el EAN", () => {
  const sql = armarSql(validarFichas([ok]));
  assert.match(sql, /7501234567890/);
  assert.match(sql, /FC-34567890/);
  assert.match(sql, /Dispositivo médico/);
  assert.match(sql, /fc_buscar_producto_escaneo/);
  assert.match(sql, /coalesce\(p\.stock, 0\) = 0/);
});
