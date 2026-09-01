import test from "node:test";
import assert from "node:assert/strict";
import {
  splitCalleYNumero,
  composeCheckoutCalle,
  checkoutNumeroOk,
  cleanCheckoutColonia,
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
