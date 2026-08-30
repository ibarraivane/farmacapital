import {
  productoPermitidoEnTiendaFarmaciaWeb,
  razonBloqueoProductoTiendaFarmacia,
} from "./tiendaFarmaciaCatalogo";

test("caja de Aspirina C/40 no se puede comprar en la tienda web", () => {
  const p = {
    activo: true,
    venta_unidad: true,
    unidades_por_caja: 40,
    nombre: "Aspirina 500 mg C/40",
    presentacion: "C/40 tabletas",
    categoria: "Analgésico",
    requiere_receta: false,
  };
  expect(productoPermitidoEnTiendaFarmaciaWeb(p)).toBe(false);
  expect(razonBloqueoProductoTiendaFarmacia(p)).toMatch(/pieza/);
});

test("Tabcin C/12 sí se puede comprar en línea", () => {
  expect(
    productoPermitidoEnTiendaFarmaciaWeb({
      activo: true,
      venta_unidad: true,
      unidades_por_caja: 12,
      nombre: "Tabcin 500 C/12",
      presentacion: "C/12 capsulas",
      categoria: "Respiratorio",
      requiere_receta: false,
    }),
  ).toBe(true);
});
