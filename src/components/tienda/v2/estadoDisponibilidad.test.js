import { clasificarDisponibilidad, ESTADOS_DISPONIBILIDAD, productoSoloRecoger } from "./estadoDisponibilidad";

test("existencia > 0 y no bajo pedido → Disponible en sucursal", () => {
  const r = clasificarDisponibilidad({ stock: 4, bajo_pedido: false, nombre: "Omeprazol" });
  expect(r.estado).toBe(ESTADOS_DISPONIBILIDAD.SUCURSAL);
  expect(r.label).toBe("Disponible en sucursal");
  expect(r.inStock).toBe(true);
});

test("antibiótico con receta añade Solo recoger", () => {
  const r = clasificarDisponibilidad({
    stock: 2,
    requiere_receta: true,
    categoria: "Antibiótico",
  });
  expect(r.label).toBe("Disponible en sucursal · Solo recoger");
  expect(productoSoloRecoger({ requiere_receta: true, categoria: "Antibiótico" })).toBe(true);
});

test("bajo_pedido gana aunque haya stock", () => {
  const r = clasificarDisponibilidad({ stock: 8, bajo_pedido: true });
  expect(r.estado).toBe(ESTADOS_DISPONIBILIDAD.ENCARGO);
  expect(r.label).toBe("Por encargo");
});

test("stock 0 y no bajo pedido no inventa un estado", () => {
  expect(clasificarDisponibilidad({ stock: 0, bajo_pedido: false })).toBeNull();
  expect(clasificarDisponibilidad(null)).toBeNull();
});
