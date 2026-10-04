import {
  mapaUrlsTarjetaPorProducto,
  ordenarGaleriaProducto,
  ordenarUrlsTarjeta,
  esPackshotLegacyInventario,
  fotoGuardadaMandaEnTienda,
  productoTieneFotoInventario,
  resolverFotoTienda,
  siguienteIndiceFotoTarjeta,
} from "./useProductoImagenes";

it("la galería Rappi manda sobre el packshot viejo", () => {
  expect(ordenarGaleriaProducto("packshot.jpg", ["rappi/1.webp", "rappi/2.webp"])).toEqual([
    "rappi/1.webp",
    "rappi/2.webp",
  ]);
});

it("sin galería se queda el packshot", () => {
  expect(ordenarGaleriaProducto("packshot.jpg", [])).toEqual(["packshot.jpg"]);
});

it("no deja pasar URLs de Del Ahorro en galería ni tarjeta", () => {
  expect(
    ordenarGaleriaProducto("https://production-media.fahorro.com/media/x.jpg", [
      "https://www.fahorro.com/media/y.jpg",
      "https://www.farmacapital.mx/catalogo-propia/ok.jpg",
    ]),
  ).toEqual(["https://www.farmacapital.mx/catalogo-propia/ok.jpg"]);
  expect(
    ordenarUrlsTarjeta([
      { url: "https://www.fahorro.com/media/catalog/product/a.jpg", posicion: 1, es_principal: true },
      { url: "https://www.farmacapital.mx/catalogo-propia/ok.jpg", posicion: 2, es_principal: false },
    ]),
  ).toEqual(["https://www.farmacapital.mx/catalogo-propia/ok.jpg"]);
});

it("la tarjeta prueba la principal y si falla sigue con la galería de la ficha", () => {
  const urls = ordenarUrlsTarjeta([
    { url: "https://cdn/rappi/1.png", posicion: 1, es_principal: false },
    { url: "https://cdn/rappi/2.png", posicion: 2, es_principal: false },
    { url: "https://www.farmacapital.mx/catalogo-propia/alka-seltzer-boost-c10.jpg", posicion: 5, es_principal: true },
  ]);
  expect(urls[0]).toContain("catalogo-propia/alka-seltzer-boost-c10.jpg");
  expect(urls.slice(1)).toEqual([
    "https://cdn/rappi/1.png",
    "https://cdn/rappi/2.png",
  ]);
  expect(siguienteIndiceFotoTarjeta(urls, 0)).toBe(1);
  expect(siguienteIndiceFotoTarjeta(urls, 2)).toBe(-1);
});

it("sin foto en inventario no revive la galería con marca de agua", () => {
  const prod = { id: 915, imagen_url: null, imagen_mobile_url: null };
  const marcaDeAgua = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7502226295954/1.webp";
  expect(productoTieneFotoInventario(prod)).toBe(false);
  expect(resolverFotoTienda(prod, marcaDeAgua)).toBe("");
  expect(resolverFotoTienda(prod, marcaDeAgua, { placeholder: "https://cdn/ph.png" })).toBe("https://cdn/ph.png");
});

it("la foto guardada en inventario manda sobre la galería vieja", () => {
  const guardada = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/fc-28833707-1200x1200-1791128503974.webp?v=1791128504982";
  const rappi = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501342802954/1.webp";
  const prod = { imagen_url: guardada, imagen_mobile_url: guardada };
  expect(fotoGuardadaMandaEnTienda(prod)).toBe(true);
  expect(resolverFotoTienda(prod, rappi)).toBe(guardada);
});

it("el desktop.jpg viejo sigue cediendo a la galería", () => {
  const legacy = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/7/desktop.jpg";
  const rappi = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501349021860/1.jpg";
  const prod = { imagen_url: legacy };
  expect(esPackshotLegacyInventario(legacy)).toBe(true);
  expect(fotoGuardadaMandaEnTienda(prod)).toBe(false);
  expect(resolverFotoTienda(prod, rappi)).toBe(rappi);
  expect(resolverFotoTienda(prod, "")).toBe(legacy);
});

it("agrupa las URLs de tarjeta por producto", () => {
  const mapa = mapaUrlsTarjetaPorProducto([
    { producto_id: 644, url: "https://cdn/rappi/1.png", posicion: 1, es_principal: false },
    { producto_id: 644, url: "https://cdn/propia.jpg", posicion: 5, es_principal: true },
    { producto_id: 1, url: "https://cdn/otra.jpg", posicion: 1, es_principal: true },
  ]);
  expect(mapa.get(644)[0]).toBe("https://cdn/propia.jpg");
  expect(mapa.get(644)[1]).toBe("https://cdn/rappi/1.png");
  expect(mapa.get(1)).toEqual(["https://cdn/otra.jpg"]);
});
