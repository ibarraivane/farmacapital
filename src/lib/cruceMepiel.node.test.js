const { test } = require("node:test");
const assert = require("node:assert/strict");
const { cruzarMepiel, sqlReferenciaMepiel } = require("./cruceMepiel");

test("Mepiel solo cruza EAN que ya están y no inventa alta", () => {
  const { enCatalogo, pendientes } = cruzarMepiel({
    eanConocidos: ["7503057040393"],
    filas: [
      { ean: "7503057040393", costo: "199.5", nombre: "Ya lo tenemos", imagen_url: "https://cdn.shopify.com/s/files/x.jpg" },
      { sku: "3337875592413", costo: 80, nombre: "No está en catálogo" },
      { nombre: "Sin código", costo: 10 },
      { ean: "7503057040394", costo: 10, nombre: "Dígito mal" },
    ],
  });
  assert.equal(enCatalogo.length, 1);
  assert.equal(enCatalogo[0].costo, 199.5);
  assert.equal(pendientes.length, 3);
  assert.deepEqual(pendientes.map((p) => p.motivo).sort(), [
    "ean_no_esta_en_catalogo",
    "sin_ean",
    "sin_ean",
  ]);
  const sql = sqlReferenciaMepiel(enCatalogo);
  assert.match(sql, /'mepiel'/);
  assert.match(sql, /7503057040393/);
  assert.doesNotMatch(sql, /insert into public\.productos/i);
});
