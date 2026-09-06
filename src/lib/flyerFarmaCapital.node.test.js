"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("flyerFarmaCapital", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "flyerFarmaCapital.js")).href);
  const { flyerHomeUrl, flyerConseguirPath, flyerWhatsAppShareUrl, flyerShareCaption } = mod;

  it("QR apunta a la home con UTM", () => {
    assert.equal(
      flyerHomeUrl("https://www.farmacapital.mx"),
      "https://www.farmacapital.mx/?utm_source=flyer&utm_medium=whatsapp&utm_campaign=tarjeta",
    );
  });

  it("conseguir y share de WhatsApp", () => {
    assert.equal(flyerConseguirPath("losartan 50"), "/conseguir?q=losartan%2050");
    const url = flyerWhatsAppShareUrl("https://www.farmacapital.mx");
    assert.ok(url.startsWith("https://wa.me/?text="));
    assert.match(decodeURIComponent(url), /farmacapital\.mx\/\?utm_source=flyer/);
    assert.match(flyerShareCaption("https://www.farmacapital.mx"), /te lo conseguimos/i);
  });
});
