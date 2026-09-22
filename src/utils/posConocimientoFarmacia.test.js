const test = require("node:test");
const assert = require("node:assert/strict");
const {
  describePosProductUseLocal,
  describePosProductUseFallback,
} = require("./posConocimientoFarmacia");

test("chocolate Turin: descripción de consumo, no químico", () => {
  const product = {
    nombre: "Turin Conejo Chocolate",
    marca: "Turin",
    presentacion: "Conejo 600 g (caja mayoreo 4)",
    categoria: "Minisuper",
    tipo: "marca",
    requiere_receta: false,
    controlado: false,
  };
  const uso = describePosProductUseFallback(product);
  assert.match(uso, /chocolate/i);
  assert.match(uso, /consumo|dulce/i);
  assert.doesNotMatch(uso, /qu[ií]mico/i);
});

test("paracetamol: mantiene descripción farmacéutica", () => {
  const product = {
    nombre: "Tempra 500 mg",
    principio_activo: "Paracetamol",
    categoria: "Analgésico",
    forma_farmaceutica: "Tableta",
  };
  const uso = describePosProductUseLocal(product);
  assert.match(uso, /analg/i);
  assert.match(uso, /fiebre|dolor/i);
});

test("abarrotes sin patrón: fallback comercial", () => {
  const product = {
    nombre: "Atún Dolores en agua",
    categoria: "Abarrotes",
    requiere_receta: false,
  };
  const uso = describePosProductUseFallback(product);
  assert.match(uso, /consumo|abarrotes|alimento/i);
  assert.doesNotMatch(uso, /qu[ií]mico/i);
});

test("OTC genérico sin datos: sí puede mencionar químico", () => {
  const product = {
    nombre: "Producto genérico OTC",
    categoria: "Otro",
    requiere_receta: false,
  };
  const uso = describePosProductUseFallback(product);
  assert.match(uso, /qu[ií]mico|envase/i);
});
