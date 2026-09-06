"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("tiendaRoutes flyer/conseguir", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "tiendaRoutes.js")).href);
  const { resolveTiendaPage, pageIdToTiendaPath, tiendaPathnameToPageId } = mod;

  it("resuelve /tarjeta y /conseguir", () => {
    assert.equal(resolveTiendaPage("flyer"), "tarjeta");
    assert.equal(resolveTiendaPage("hola"), "tarjeta");
    assert.equal(resolveTiendaPage("te-lo-conseguimos"), "conseguir");
    assert.equal(pageIdToTiendaPath("tarjeta"), "/tarjeta");
    assert.equal(pageIdToTiendaPath("conseguir", { search: "losartan" }), "/conseguir?q=losartan");
    assert.equal(tiendaPathnameToPageId("/tarjeta"), "tarjeta");
    assert.equal(tiendaPathnameToPageId("/conseguir"), "conseguir");
  });
});
