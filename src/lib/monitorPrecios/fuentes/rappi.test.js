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
