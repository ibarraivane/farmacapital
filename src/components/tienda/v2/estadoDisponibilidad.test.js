import { clasificarDisponibilidad, ESTADOS_DISPONIBILIDAD } from "./estadoDisponibilidad";

test("existencia > 0 y no bajo pedido → En sucursal", () => {
  const r = clasificarDisponibilidad({ stock: 4, bajo_pedido: false, nombre: "Omeprazol" });
  expect(r.estado).toBe(ESTADOS_DISPONIBILIDAD.SUCURSAL);
  expect(r.label).toBe("En sucursal");
  expect(r.mark).toBe("on");
});

test("recolectaHoy alarga el texto de sucursal", () => {
  const r = clasificarDisponibilidad({ stock: 2 }, { recolectaHoy: true });
  expect(r.label).toBe("En sucursal · recoge hoy");
});

test("bajo_pedido gana aunque haya stock", () => {
  const r = clasificarDisponibilidad({ stock: 8, bajo_pedido: true }, { confirmarFecha: true });
  expect(r.estado).toBe(ESTADOS_DISPONIBILIDAD.ENCARGO);
  expect(r.label).toBe("Por encargo · te confirmamos la fecha");
  expect(r.mark).toBe("order");
});

test("stock 0 y no bajo pedido → Agotado", () => {
  const r = clasificarDisponibilidad({ stock: 0, bajo_pedido: false });
  expect(r.estado).toBe(ESTADOS_DISPONIBILIDAD.AGOTADO);
  expect(r.label).toBe("Agotado");
});

test("producto ausente o equipo médico sin existencias → Cotización", () => {
  expect(clasificarDisponibilidad(null).estado).toBe(ESTADOS_DISPONIBILIDAD.COTIZACION);
  expect(clasificarDisponibilidad({ stock: 0, categoria: "Dispositivo médico" }).estado)
    .toBe(ESTADOS_DISPONIBILIDAD.COTIZACION);
});

test("estado explícito (tarjetas de categoría) no inventa datos", () => {
  const r = clasificarDisponibilidad(undefined, { estado: "cotizacion" });
  expect(r.label).toBe("Cotización");
  expect(r.mark).toBe("quote");
});
