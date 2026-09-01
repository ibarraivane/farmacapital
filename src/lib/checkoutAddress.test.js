import test from "node:test";
import assert from "node:assert/strict";
import {
  splitCalleYNumero,
  composeCheckoutCalle,
  checkoutNumeroOk,
  cleanCheckoutColonia,
  formatDestinoLabel,
  isCheckoutDestinoListo,
  applyDestinoSuggestion,
  parseTypedMxAddress,
} from "./checkoutAddress.js";

test("splitCalleYNumero separa número al final", () => {
  assert.deepEqual(splitCalleYNumero("Cerrada Bartolache 1750"), {
    calle: "Cerrada Bartolache",
    numero: "1750",
  });
  assert.deepEqual(splitCalleYNumero("Insurgentes Sur 1234-B"), {
    calle: "Insurgentes Sur",
    numero: "1234-B",
  });
  assert.equal(splitCalleYNumero("Cerrada Doctor José Ignacio Bartolache").numero, "");
});

test("composeCheckoutCalle no duplica número", () => {
  assert.equal(composeCheckoutCalle("Cerrada Bartolache", "1750"), "Cerrada Bartolache 1750");
  assert.equal(composeCheckoutCalle("Cerrada Bartolache 1750", "1750"), "Cerrada Bartolache 1750");
});

test("checkoutNumeroOk", () => {
  assert.equal(checkoutNumeroOk("1750"), true);
  assert.equal(checkoutNumeroOk("S/N"), true);
  assert.equal(checkoutNumeroOk(""), false);
  assert.equal(checkoutNumeroOk("abc"), false);
});

test("cleanCheckoutColonia quita alcaldía", () => {
  assert.equal(cleanCheckoutColonia("Del Valle Sur, Benito Juárez"), "Del Valle Sur");
});

test("formatDestinoLabel y destino listo", () => {
  assert.equal(
    formatDestinoLabel({ calle: "Bartolache", numero: "1750", colonia: "Del Valle Sur", cp: "03104" }),
    "Bartolache 1750, Del Valle Sur, 03104"
  );
  assert.equal(
    isCheckoutDestinoListo({ calle: "Bartolache", numero: "1750", colonia: "Del Valle Sur", cp: "03104" }),
    true
  );
  assert.equal(
    isCheckoutDestinoListo({ calle: "Bartolache", numero: "", colonia: "Del Valle Sur", cp: "03104" }),
    false
  );
});

test("parseTypedMxAddress arma destino desde lo escrito", () => {
  const a = parseTypedMxAddress("Av Insurgentes Sur 300 roma norte 06700");
  assert.equal(a.calle, "Av Insurgentes Sur");
  assert.equal(a.numero, "300");
  assert.equal(a.colonia, "Roma norte");
  assert.equal(a.cp, "06700");
  const b = parseTypedMxAddress("jose ignacio bartolache 1750 del valle sur 03");
  assert.equal(b.numero, "1750");
  assert.match(b.calle, /bartolache/i);
  assert.match(b.colonia, /valle sur/i);
  assert.equal(b.cp, "");
});

test("applyDestinoSuggestion parte calle y número", () => {
  const next = applyDestinoSuggestion({
    calle: "José Ignacio Bartolache 1750",
    colonia: "Del Valle Sur",
    cp: "03104",
    lat: 19.38,
    lng: -99.17,
  });
  assert.equal(next.calle, "José Ignacio Bartolache");
  assert.equal(next.numero, "1750");
  assert.equal(next.colonia, "Del Valle Sur");
  assert.equal(next.lat, 19.38);
});
