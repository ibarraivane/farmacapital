import { ordenarGaleriaProducto } from "./useProductoImagenes";

it("la galería Rappi manda sobre el packshot viejo", () => {
  expect(ordenarGaleriaProducto("packshot.jpg", ["rappi/1.webp", "rappi/2.webp"])).toEqual([
    "rappi/1.webp",
    "rappi/2.webp",
  ]);
});

it("sin galería se queda el packshot", () => {
  expect(ordenarGaleriaProducto("packshot.jpg", [])).toEqual(["packshot.jpg"]);
});
