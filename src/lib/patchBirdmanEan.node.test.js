const { test } = require("node:test");
const assert = require("node:assert/strict");
const { elegirPackshotShopify, gtinValido } = require("./catalogoBajoPedido");
const { cruzarBirdman, sqlPatchBirdman } = require("./patchBirdmanEan");

test("gtinValido acepta el EAN de la ficha Birdman y rechaza uno alterado", () => {
  assert.equal(gtinValido("7503057040393"), "7503057040393");
  assert.equal(gtinValido("7503057040394"), "");
  assert.equal(gtinValido("123"), "");
  assert.equal(gtinValido(""), "");
});

test("packshot solo de cdn.shopify.com", () => {
  assert.equal(
    elegirPackshotShopify({ media: [{ media_type: "image", width: 2400, src: "//cdn.shopify.com/s/files/a.png" }] }),
    "https://cdn.shopify.com/s/files/a.png",
  );
  assert.equal(
    elegirPackshotShopify({ media: [{ media_type: "image", width: 500, src: "https://cdn.shopify.com/s/files/chico.png" }] }),
    "https://cdn.shopify.com/s/files/chico.png",
  );
  assert.equal(
    elegirPackshotShopify({ media: [{ media_type: "image", width: 800, src: "https://production-media.fahorro.com/x.jpg" }] }),
    "",
  );
});

test("el cruce no mueve el SKU y deja fuera un EAN repetido", () => {
  const catalogo = [
    { sku: "FCHC1800", nombre: "Falcon Protein 1.8 kg", costo_base_25: 800, disponible_proveedor: 1 },
    { sku: "FCAC480", nombre: "Falcon Protein 480 g", costo_base_25: 400, disponible_proveedor: 1 },
    { sku: "PlayeraNegraHombreGrande", nombre: "Playera Distribuidor Autorizado Hombre - L", linea: "Accesorios", costo_base_25: 200, disponible_proveedor: 1 },
  ];
  const filas = cruzarBirdman({
    catalogo,
    fichas: [
      { sku: "FCHC1800", barcode: "7503057040393", imagen_url: "https://cdn.shopify.com/s/files/falcon.png" },
      { sku: "fcac480", barcode: "7503057040393", imagen_url: "https://cdn.shopify.com/s/files/otro.png" },
    ],
  });
  assert.equal(filas.length, 2);
  assert.equal(filas[0].ean, "");
  assert.equal(filas[0].nota, "ean_repetido");
  assert.equal(filas[1].nota, "ean_repetido");
  assert.match(filas[0].sku, /^FC-\d{8}$/);
  assert.notEqual(filas[0].sku, filas[1].sku);

  const sql = sqlPatchBirdman(filas);
  assert.match(sql, /FCHC1800/);
  assert.doesNotMatch(sql, /7503057040393/);
  assert.match(sql, /cdn\.shopify\.com/);
  assert.doesNotMatch(sql, /Playera/);
  assert.match(sql, /_fc_birdman_destino/);
  assert.doesNotMatch(sql, /from destino\b/);
});
