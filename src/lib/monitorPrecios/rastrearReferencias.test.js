const {
  extraerVtex,
  extraerMayoreoTotal,
  terminoBusqueda,
} = require("./catalogosPublicos");
const { matchOferta, precioOtrosMercado } = require("./matchCatalogo");
const { productosParaVenta, rastrearReferencias } = require("./rastrearReferencias");

test("genérico busca por principio activo; patente por la marca", () => {
  expect(terminoBusqueda({
    nombre: "Amoxicilina 500 mg",
    tipo: "generico",
    principio_activo: "Amoxicilina",
  })).toBe("Amoxicilina");
  expect(terminoBusqueda({
    nombre: "Contac Ultra",
    marca: "Contac",
    tipo: "GENERICO",
    principio_activo: "Paracetamol + Fenilefrina + Clorfenamina",
  })).toBe("Contac");
  expect(terminoBusqueda({
    nombre: "Histiacil NF jarabe",
    marca: "Histiacil",
    tipo: "marca",
    principio_activo: "ambroxol dextrometorfano",
  })).toBe("Histiacil");
});

test("VTEX extrae precio de Similares", () => {
  const rows = extraerVtex(JSON.stringify([{
    productName: "PARACETAMOL 500 MG 10 TABLETAS",
    items: [{ ean: "7501000000001", sellers: [{ commertialOffer: { Price: 36.5 } }] }],
  }]), "similares");
  expect(rows).toHaveLength(1);
  expect(rows[0].precio).toBe(36.5);
  expect(rows[0].fuente).toBe("similares");
});

test("MayoreoTotal extrae variantes", () => {
  const rows = extraerMayoreoTotal(JSON.stringify({
    products: [{
      title: "Jabón Dove 90 g",
      variants: [{ title: "Default Title", price: "18.50", barcode: "7501055301234" }],
    }],
  }));
  expect(rows[0].fuente).toBe("mayoreototal");
  expect(rows[0].precio).toBe(18.5);
});

test("EAN gana sobre el nombre", () => {
  const hit = matchOferta(
    { nombre: "otra cosa", precio: 10, ean: "7501000000001" },
    [
      { id: 1, nombre: "Paracetamol 500", codigo_barras: "7501000000001" },
      { id: 2, nombre: "otra cosa extraña larga", codigo_barras: "000" },
    ]
  );
  expect(hit.producto.id).toBe(1);
  expect(hit.metodo).toBe("GTIN");
});

test("Otros es promedio de Del Ahorro y Similares cuando hay las dos", () => {
  expect(precioOtrosMercado({ fahorro: 80, similares: 70 })).toBe(75);
  expect(precioOtrosMercado({ similares: 70 })).toBe(null);
  expect(precioOtrosMercado({ gi: 90, benavides: 110 })).toBe(100);
});

test("prioriza productos sin Similares reciente", () => {
  const ahora = new Date("2026-08-24T12:00:00Z");
  const cola = productosParaVenta(
    [{ id: 2, nombre: "B" }, { id: 1, nombre: "A" }],
    { 2: { similares: { fecha: "2026-08-20", precio: 10 } } },
    ahora
  );
  expect(cola[0].id).toBe(1);
});

test("rastreo escribe compra y venta sin inventar Otros de una sola cadena", async () => {
  const fetchImpl = async (url) => {
    if (String(url).includes("abarrotero")) {
      return {
        ok: true,
        text: async () => JSON.stringify([{
          name: "Jabón Dove 90 g",
          prices: { price: "1850", sale_price: "1850", currency_minor_unit: 2 },
        }]),
      };
    }
    if (String(url).includes("scorpion") || String(url).includes("mayoreototal")) {
      return { ok: true, text: async () => "" };
    }
    if (String(url).includes("farmaciasdesimilares")) {
      return {
        ok: true,
        text: async () => JSON.stringify([{
          productName: "Jabón Dove 90 g",
          items: [{ sellers: [{ commertialOffer: { Price: 29 } }] }],
        }]),
      };
    }
    return { ok: false, text: async () => "" };
  };
  const out = await rastrearReferencias({
    catalogo: [{ id: 9, nombre: "Jabón Dove 90 g", marca: "Dove", sku: "FC-1" }],
    refsByProduct: {},
    fetchImpl,
    ahora: new Date("2026-08-24T12:00:00Z"),
    presupuestoMs: 20000,
    loteVenta: 3,
  });
  const fuentes = out.filas.map((f) => f.fuente);
  expect(fuentes).toContain("abarrotero");
  expect(fuentes).toContain("similares");
  expect(fuentes).not.toContain("otros_venta");
  expect(out.filas.find((f) => f.fuente === "similares").precio).toBe(29);
});
