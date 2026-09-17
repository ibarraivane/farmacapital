"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { esKit, marcaDe, clasificar, presentacionDe, nombreMostrador } = require("./cosechar-fahorro-vitrina");

test("omite kits y packs, no Effaclar Duo+", () => {
  assert.equal(esKit("La Roche-Posay rutina anti-arrugas"), true);
  assert.equal(esKit("Birdman creatina + Falcon 1.9 kg"), true);
  assert.equal(esKit("La Roche-Posay Effaclar Duo+ M 40 ml"), false);
});

test("marca y rubro desde el nombre", () => {
  assert.equal(marcaDe("Birdman Fitmingo moka 510 g", []), "Birdman");
  assert.equal(clasificar("Nebucor nebulizador P-103", [], "disp").categoria, "Dispositivo médico");
  assert.equal(clasificar("Gold Standard whey 907 g", ["Optimum Nutrition"], "nutri").subcategoria, "Nutrición deportiva");
  assert.equal(presentacionDe("Mela B3 suero 30 ml", "derm"), "30 ml");
});

test("omite higiene íntima y no marca minerales Birdman como deporte", () => {
  assert.equal(clasificar("Eucerin Gel de Higiene Íntima 250 ml", [], "derm"), null);
  const minerales = clasificar("BIRDMAN Minerales 300ml", [], "nutri");
  assert.equal(minerales.categoria, "Suplemento");
  assert.equal(minerales.subcategoria, null);
});

test("tiras y FPS pegado al mililitraje", () => {
  assert.equal(clasificar("Accu-Chek Guide Tiras 25", [], "disp").subcategoria, "Tiras");
  assert.equal(presentacionDe("Accu-Chek Guide Tiras 25", "disp"), "25 tiras");
  assert.equal(presentacionDe("Heliocare 360° Advanced Gel Fps 50250 ml", "derm"), "250 ml");
  assert.equal(nombreMostrador("Heliocare 360° Advanced Gel Fps 50250 ml"), "Heliocare 360° Advanced Gel FPS 50+ 250 ml");
});
