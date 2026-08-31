const {
  clasificarTiendaRappi,
  extraerOfertasRappi,
  agruparOfertasRappi,
  terminoBusquedaRappi,
} = require("./rappi");

test("clasifica cadenas Rappi", () => {
  expect(clasificarTiendaRappi("Farmacias Guadalajara")).toBe("rappi_gdl");
  expect(clasificarTiendaRappi("Farmatodo Polanco")).toBe("rappi_farmatodo");
  expect(clasificarTiendaRappi("Farmacias Benavides")).toBe("rappi_benavides");
  expect(clasificarTiendaRappi("Farmacia La Paz")).toBe("rappi_otros");
  expect(clasificarTiendaRappi("Chedraui Selecto")).toBe("rappi_super");
  expect(clasificarTiendaRappi("Soriana Híper")).toBe("rappi_super");
  expect(clasificarTiendaRappi("7 Eleven")).toBe(null);
});

test("extrae precios por tienda desde __NEXT_DATA__", () => {
  const html = `<script id="__NEXT_DATA__" type="application/json">${JSON.stringify({
    props: {
      pageProps: {
        fallback: {
          x: {
            stores: [
              {
                storeName: "Farmacias Guadalajara",
                products: [{ name: "Agrifen 10 Tabletas", price: 50 }],
              },
              {
                storeName: "Chedraui",
                products: [{ name: "Agrifen 10 Tabletas", price: 25, realPrice: 29 }],
              },
              {
                storeName: "7 Eleven",
                products: [{ name: "Agrifen 10 Tabletas", price: 40 }],
              },
            ],
          },
        },
      },
    },
  })}</script>`;
  const ofertas = extraerOfertasRappi(html);
  expect(ofertas).toHaveLength(2);
  const grouped = agruparOfertasRappi(ofertas);
  expect(grouped.rappi_gdl.precio).toBe(50);
  expect(grouped.rappi_super.precio).toBe(25);
  expect(grouped.rappi_farmatodo).toBeUndefined();
});

test("match Rappi acepta nombre de marca aunque el umbral de catálogo falle", () => {
  const { matchOfertaRappi } = require("./rappi");
  const hit = matchOfertaRappi(
    { nombre: "Agrifen", principio_activo: "paracetamol cafeina clorfenamina" },
    [{ fuente: "rappi_gdl", nombre: "Agrifen Antigripal 10 Tabletas", precio: 50, tienda: "GDL" }]
  );
  expect(hit).toBeTruthy();
  expect(hit.precio).toBe(50);
});

test("Ensure 236 ml no toma el 6-pack ni el polvo", () => {
  const { matchOfertaRappi } = require("./rappi");
  const producto = {
    nombre: "Ensure vainilla",
    marca: "Ensure",
    presentacion: "236 ML",
    precio: 65,
  };
  const hit = matchOfertaRappi(producto, [
    { fuente: "rappi_gdl", nombre: "Ensure Regular Vainilla 6 Pack 237 ml", precio: 393, tienda: "GDL" },
    { fuente: "rappi_gdl", nombre: "Ensure Advance Polvo Vainilla 400 g", precio: 405, tienda: "GDL" },
    { fuente: "rappi_gdl", nombre: "Ensure Advance Vanilla 237Ml", precio: 72, tienda: "GDL" },
    { fuente: "rappi_gdl", nombre: "Ensure Regular Líquido Vainilla 237 ml", precio: 66, tienda: "GDL" },
    { fuente: "rappi_super", nombre: "Ensure Clinical 16 pack", precio: 542.99, tienda: "Chedraui" },
    { fuente: "rappi_super", nombre: "Ensure Vainilla Next Gen 400G", precio: 324, tienda: "Chedraui" },
  ]);
  expect(hit).toBeTruthy();
  expect(hit.precio).toBe(66);
  expect(hit.nombre).toMatch(/237 ml/i);
  expect(hit.nombre).not.toMatch(/advance/i);
});

test("si Rappi solo tiene packs, no inventa precio de botella", () => {
  const { matchOfertaRappi } = require("./rappi");
  const hit = matchOfertaRappi(
    { nombre: "Ensure vainilla", presentacion: "236 ML", precio: 65 },
    [{ fuente: "rappi_gdl", nombre: "Ensure Regular Vainilla 6 Pack 237 ml", precio: 393, tienda: "GDL" }]
  );
  expect(hit).toBeNull();
});

test("el lote de Partner incluye Lizovag aunque no tenga foto", () => {
  const { seleccionarCandidatos } = require("../../../../api/_lib/rastrearRappi");
  const ahora = new Date("2026-08-31T18:00:00.000Z");
  const productos = [
    { id: 1, nombre: "Agrifen", sku: "FC-1" },
    { id: 9, nombre: "Lizovag 10 Tab", sku: "EQ-NOV032", codigo_barras: "7501075717150" },
  ];
  const out = seleccionarCandidatos(productos, {
    ahora,
    linked: new Set(),
    partnerIds: new Set([9]),
    soloPartner: true,
    ultima: {},
    diasStale: 7,
  });
  expect(out.map((p) => p.id)).toEqual([9]);
});

test("el lote prioriza foto Rappi y se salta lo fresco", () => {
  const { seleccionarCandidatos } = require("../../../../api/_lib/rastrearRappi");
  const ahora = new Date("2026-08-26T18:00:00.000Z");
  const productos = [
    { id: 1, nombre: "Agrifen", codigo_barras: "7501125116810" },
    { id: 2, nombre: "XL-3 Xtra", codigo_barras: "6502400170941" },
    { id: 3, nombre: "Sin foto", codigo_barras: "1234567890123" },
  ];
  const out = seleccionarCandidatos(productos, {
    ahora,
    linked: new Set([1, 2]),
    ultima: { 1: "2026-08-26" },
    soloLinked: true,
    diasStale: 7,
  });
  expect(out.map((p) => p.id)).toEqual([2]);
});

test("el reintento corto usa 2-3 palabras del nombre local", () => {
  const { terminoCortoRappi } = require("./rappi");
  expect(terminoCortoRappi({
    nombre: "Redoxon 1g Naranja",
    nombre_rappi: "Redoxon Vitamina C Tubo Con 10 Tabletas Efervescentes Naranja",
  })).toBe("Redoxon 1g Naranja");
  expect(terminoCortoRappi({ nombre: "Tempra Forte C/24" })).toBe("Tempra Forte");
});

test("busca por nombre comercial, no por EAN", () => {
  expect(terminoBusquedaRappi({ codigo_barras: "7501125116810", nombre: "Agrifen" }))
    .toBe("Agrifen");
  expect(terminoBusquedaRappi({
    nombre: "Agrifen",
    nombre_rappi: "Agrifen Antigripal 10 Tabletas",
  })).toBe("Agrifen Antigripal 10 Tabletas");
  expect(terminoBusquedaRappi({ nombre: "Agrifen C/10 tabletas", nombre_rappi: "" }))
    .toBe("Agrifen C/10 tabletas");
});

test("consultas Rappi: EAN, nombre Partner y principio activo", () => {
  const { consultasBusquedaRappi } = require("./rappi");
  expect(consultasBusquedaRappi({
    nombre: "Lizovag",
    tipo: "generico",
    codigo_barras: "7501075717150",
    nombre_rappi: "Lizovag (200 mg)",
    principio_activo: "Ketoconazol",
    concentracion: "200 mg",
  })).toEqual([
    "7501075717150",
    "Ketoconazol 200 mg",
    "Lizovag (200 mg)",
  ]);
});

test("match Rappi por EAN gana aunque el nombre no coincida", () => {
  const { matchOfertaRappi } = require("./rappi");
  const hit = matchOfertaRappi(
    { nombre: "Lizovag", codigo_barras: "7501075717150", precio: 26 },
    [
      { fuente: "rappi_gdl", nombre: "Otro producto 10 tabletas", precio: 10, ean: "111" },
      { fuente: "rappi_gdl", nombre: "Ketoconazol 200 mg 10 tabletas", precio: 29, ean: "7501075717150" },
    ],
  );
  expect(hit).toBeTruthy();
  expect(hit.precio).toBe(29);
  expect(hit.metodo).toBe("GTIN");
});

test("genérico sin la marca en Rappi igual toma el mismo PA y caja", () => {
  const { matchOfertaRappi } = require("./rappi");
  const hit = matchOfertaRappi(
    {
      nombre: "Lizovag",
      tipo: "generico",
      principio_activo: "Ketoconazol",
      presentacion: "10Und",
      concentracion: "200 mg",
      precio: 26,
    },
    [
      { fuente: "rappi_gdl", nombre: "Ketoconazol 200 mg 20 tabletas", precio: 48, tienda: "GDL" },
      { fuente: "rappi_gdl", nombre: "Ketoconazol 200 mg 10 tabletas", precio: 28, tienda: "GDL" },
      { fuente: "rappi_gdl", nombre: "Ensure Regular Vainilla 237 ml", precio: 66, tienda: "GDL" },
    ],
  );
  expect(hit).toBeTruthy();
  expect(hit.precio).toBe(28);
  expect(hit.nombre).toMatch(/10 tabletas/i);
});

test("Partner con refs de otro empaque se vuelve a buscar", () => {
  const { seleccionarCandidatos } = require("../../../../api/_lib/rastrearRappi");
  const ahora = new Date("2026-08-31T18:00:00.000Z");
  const productos = [
    { id: 9, nombre: "Lizovag 10 Tab", sku: "EQ-NOV032", codigo_barras: "7501075717150" },
  ];
  const out = seleccionarCandidatos(productos, {
    ahora,
    linked: new Set([9]),
    partnerIds: new Set([9]),
    soloPartner: true,
    ultima: { 9: "2026-08-31" },
    forzarIds: new Set([9]),
    diasStale: 7,
  });
  expect(out.map((p) => p.id)).toEqual([9]);
});
