"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const {
  costoClienteMepiel,
  costoMayoreoPreferido,
  enriquecerFilaMepiel,
  filaMepiel,
  filasMepielDesdeRaws,
  marcaMepielPorFila,
  nombreDesdeListaMepiel,
} = require("./catalogoBajoPedido");

describe("lista ME Piel 2026", () => {
  it("cobra cliente con IVA y deja el precio de vitrina en cero", () => {
    assert.equal(marcaMepielPorFila(50), "Eucerin");
    assert.equal(marcaMepielPorFila(150), "Bioderma");
    assert.equal(marcaMepielPorFila(800), "La Roche-Posay");
    assert.equal(costoClienteMepiel({ cliente_con: 474.3008, cliente_sin: 408.88 }), 474.3);

    const fila = filaMepiel({
      fila: 130,
      ean: "4005900996169",
      descripcion: "EUCERIN SUN KIDS GEL CREMA DRY TOUCH SPF50 200ML",
      uni: "PZA",
      cliente_sin: 408.88,
      cliente_con: 474.3008,
      publico_con: 692.1952,
      linea: "SOLARES",
    });
    assert.equal(fila.sku, "FC-00996169");
    assert.equal(fila.costo, 474.3);
    assert.equal(fila.precio, 0);
    assert.equal(fila.techo, 692.2);
    assert.equal(fila.subcategoria, "Dermatología");
    assert.equal(fila.marca, "Eucerin");
    assert.equal(fila.oferta, "10+1");
    assert.match(nombreDesdeListaMepiel(fila.nombre_lista), /SPF50/);
    assert.match(nombreDesdeListaMepiel(fila.nombre_lista), /200 ml/);
    assert.equal(nombreDesdeListaMepiel("TISSUSAN 15G"), "Tissusan 15 g");
    assert.equal(nombreDesdeListaMepiel("AV-XERACALM AD BALSAMO"), "Av-Xeracalm Ad Balsamo");
    const xer = enriquecerFilaMepiel(filaMepiel({
      fila: 1700,
      ean: "3282770204667",
      descripcion: "XERACALM AD BALSAMO 200ML",
      uni: "PZA",
      cliente_con: 300,
      marca: "Avène",
    }), {
      derma: { nombre: "AV-XERACALM AD BALSAMO RELIPIDIZANTE 200 ml", marca: "Avene" },
    });
    assert.equal(xer.nombre, "Av-Xeracalm Ad Balsamo Relipidizante");
    assert.equal(xer.presentacion, "200 ml");
  });

  it("se queda la pieza y el nombre de Dermaexpress, sin logo Fahorro", () => {
    const filas = filasMepielDesdeRaws([
      {
        fila: 373,
        ean: "8436574364866",
        descripcion: "ENDOCARE RADIANCE C FERULIC SERUM GEL",
        uni: "MAYO",
        cliente_con: 924,
        publico_con: 1200,
        marca: "Cantabria Labs",
      },
      {
        fila: 377,
        ean: "8436574364866",
        descripcion: "ENDOCARE RADIANCE C FERULIC SERUM GEL 30ML",
        uni: "PZA",
        cliente_con: 923.998,
        publico_con: 1200,
        marca: "Cantabria Labs",
      },
    ]);
    assert.equal(filas.length, 1);
    assert.equal(filas[0].uni, "PZA");
    assert.equal(filas[0].costo, 924);

    const ficha = enriquecerFilaMepiel(filas[0], {
      derma: {
        nombre: "Endocare Radiance C Ferulic Serum Gel 30 ml",
        marca: "Endocare",
        imagen_url: "https://cdn.shopify.com/s/files/endocare.jpg",
      },
    });
    assert.match(ficha.nombre, /Radiance C Ferulic/i);
    assert.equal(ficha.marca, "Endocare");
    assert.match(ficha.presentacion, /30 ml/i);
    assert.equal(ficha.imagen_origen, "dermaexpress");
    assert.equal(ficha.precio, 0);

    const sucio = enriquecerFilaMepiel(filas[0], {
      derma: { imagen_url: "https://production-media.fahorro.com/x.png", nombre: "X largo de caja" },
    });
    assert.equal(sucio.imagen_url, "");
    assert.equal(costoMayoreoPreferido(489, 474.3), 474.3);
    assert.equal(costoMayoreoPreferido(0, 474.3), 474.3);
  });
});
