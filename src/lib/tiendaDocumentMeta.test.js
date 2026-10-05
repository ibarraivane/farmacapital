import { aplicarDocumentMeta, metaDeRutaTienda, SITIO_CANONICO } from "./tiendaDocumentMeta";

test("inicio y secciones tienen título y canonical propios", () => {
  const home = metaDeRutaTienda({ page: "home" });
  expect(home.title).toMatch(/FarmaCapital/);
  expect(home.canonical).toBe(`${SITIO_CANONICO}/`);
  const meds = metaDeRutaTienda({ page: "catalogo", seccion: "Medicamentos" });
  expect(meds.title).toBe("Medicamentos · FarmaCapital");
  expect(meds.canonical).toBe(`${SITIO_CANONICO}/medicamentos`);
});

test("cuenta y checkout no se indexan", () => {
  expect(metaDeRutaTienda({ page: "cuenta" }).robots).toMatch(/noindex/);
  expect(metaDeRutaTienda({ page: "checkout" }).robots).toMatch(/noindex/);
  expect(metaDeRutaTienda({ page: "carrito" }).robots).toMatch(/noindex/);
  expect(metaDeRutaTienda({ page: "login" }).robots).toMatch(/noindex/);
});

test("producto publica JSON-LD Product con oferta solo si hay precio", () => {
  const conPrecio = metaDeRutaTienda({
    page: "detalle",
    prod: { id: 5, nombre: "Levofloxacino 500 mg", marca: "AMSA", presentacion: "Caja con 7", precio: 90, stock: 3, imagen_url: "https://x/l.jpg" },
  });
  expect(conPrecio.title).toMatch(/Levofloxacino/);
  expect(conPrecio.canonical).toBe(`${SITIO_CANONICO}/producto?id=5`);
  expect(conPrecio.jsonLd["@type"]).toBe("Product");
  expect(conPrecio.jsonLd.offers.priceCurrency).toBe("MXN");
  expect(conPrecio.jsonLd.offers.price).toBe(90);
  const consultar = metaDeRutaTienda({
    page: "detalle",
    prod: { id: 9, nombre: "Crema", precio: 0, stock: 0 },
  });
  expect(consultar.jsonLd.offers).toBeUndefined();
});

test("aplicarDocumentMeta cambia title, canonical y og", () => {
  document.head.innerHTML = '<link rel="canonical" href="https://www.farmacapital.mx/" /><meta property="og:title" content="x" />';
  aplicarDocumentMeta(metaDeRutaTienda({ page: "faq" }));
  expect(document.title).toBe("Preguntas frecuentes · FarmaCapital");
  expect(document.querySelector('link[rel="canonical"]').getAttribute("href")).toBe(`${SITIO_CANONICO}/preguntas`);
  expect(document.querySelector('meta[property="og:title"]').getAttribute("content")).toBe("Preguntas frecuentes · FarmaCapital");
});
