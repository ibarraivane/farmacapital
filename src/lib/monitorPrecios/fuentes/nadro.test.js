const {
  esPrecioPlaceholderNadro,
  extraerProductoNadro,
  extraerPrecioFarmaciaTexto,
  elegirPorEan,
} = require("./nadro");

const adel = {
  productId: "88",
  productName: "Adel 250 mg Suspensión 60 ml",
  productReference: "11001",
  brand: "SENOSIAIN",
  items: [{
    ean: "7501314701957",
    images: [{ imageUrl: "https://nadro.vtexassets.com/arquivos/ids/1/7501314701957_01.jpg?v=1" }],
    sellers: [{
      commertialOffer: { Price: 100, ListPrice: 100, AvailableQuantity: 10000 },
    }],
  }],
  "Precio público": ["$920.00"],
};

test("no toma el $100 de vitrina como costo Nadro", () => {
  expect(esPrecioPlaceholderNadro({ Price: 100, ListPrice: 100, AvailableQuantity: 10000 })).toBe(true);
  expect(esPrecioPlaceholderNadro({ Price: 0, ListPrice: 0, AvailableQuantity: 0 })).toBe(true);
  expect(esPrecioPlaceholderNadro({ Price: 717.06, ListPrice: 717.06, AvailableQuantity: 12 })).toBe(false);
});

test("extrae ficha y foto; deja compra vacía si el precio es placeholder", () => {
  const hit = extraerProductoNadro(adel);
  expect(hit.ean).toBe("7501314701957");
  expect(hit.nombre).toMatch(/Adel/i);
  expect(hit.imagenes[0]).toContain("7501314701957_01.jpg");
  expect(hit.precioCompra).toBe(null);
  expect(hit.precioPublico).toBe(920);
  expect(hit.ficha.nombre).toMatch(/Adel/i);
  expect(hit.ficha.marca).toBe("SENOSIAIN");
});

test("lee Farmacia del PDP y no el público", () => {
  const t = "SKU: 7501314701957 Público: $ 1,000 Farmacia: $ 717.06 Entrega mañana";
  expect(extraerPrecioFarmaciaTexto(t)).toEqual({ farmacia: 717.06, publico: 1000 });
  expect(extraerPrecioFarmaciaTexto("Farmacia: $ 100 Público: $ 100")).toBe(null);
  expect(extraerPrecioFarmaciaTexto("Público: $ 250 Farmacia: $ 100")).toBe(null);
});

test("elige el EAN exacto y descarta el resto", () => {
  const otro = { ...adel, productId: "1", productName: "Otro", items: [{ ean: "7500000000000", images: [], sellers: [] }] };
  const hit = elegirPorEan([otro, adel], "7501314701957");
  expect(hit.productId).toBe("88");
  expect(elegirPorEan([otro], "7501314701957")).toBe(null);
});
