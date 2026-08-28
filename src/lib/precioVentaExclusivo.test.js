import { cobroLinea } from "../utils/pesoPublico";
import { importeCajasFefo, precioLineaCajaPos, precioUnitarioCaja } from "./precioVentaExclusivo";

const HOY = "2026-06-01";

test("caducidad vigente pisa descuento_pct y promo", () => {
  const r = precioUnitarioCaja({
    pvp: 100,
    descuento_pct: 20,
    hoy: HOY,
    propuesta: {
      estado: "APROBADA",
      precio_propuesto: 70,
      vigencia_desde: "2026-05-01",
      vigencia_hasta: "2026-06-15",
    },
  });
  expect(r.fuente).toBe("caducidad");
  expect(r.apilar).toBe(false);
  expect(r.precio).toBe(70);
  expect(r.precio).not.toBe(cobroLinea(100, 1, 20));
});

test("sin especial, aplica descuento del catálogo", () => {
  const r = precioUnitarioCaja({
    pvp: 100,
    descuento_pct: 20,
    hoy: HOY,
    propuesta: null,
  });
  expect(r.fuente).toBe("catalogo");
  expect(r.precio).toBe(cobroLinea(100, 1, 20));
});

test("FEFO: primera caja al especial, la siguiente al PVP", () => {
  const r = importeCajasFefo({
    hoy: HOY,
    qty: 2,
    pvp: 100,
    descuento_pct: 0,
    lotes: [
      { id: 1, cantidad_actual: 1, fecha_caducidad: "2026-07-31", activo: true },
      { id: 2, cantidad_actual: 5, fecha_caducidad: "2026-12-31", activo: true },
    ],
    propuestasByLote: {
      1: {
        estado: "APROBADA",
        precio_propuesto: 70,
        vigencia_desde: HOY,
        vigencia_hasta: "2026-07-30",
      },
    },
  });
  expect(r.total).toBe(170);
  expect(r.usaCaducidad).toBe(true);
  expect(r.detalle[0].fuente).toBe("caducidad");
  expect(r.detalle[1].fuente).toBe("catalogo");
});

test("propuesta vencida no pisa el descuento del catálogo", () => {
  const r = precioUnitarioCaja({
    pvp: 100,
    descuento_pct: 10,
    hoy: HOY,
    propuesta: {
      estado: "APROBADA",
      precio_propuesto: 70,
      vigencia_desde: "2026-04-01",
      vigencia_hasta: "2026-05-31",
    },
  });
  expect(r.fuente).toBe("catalogo");
  expect(r.precio).toBe(cobroLinea(100, 1, 10));
});

test("linea POS: especial pone descuento_pct en 0", () => {
  const r = precioLineaCajaPos(
    {
      precio: 100,
      descuento_pct: 20,
      lotes: [{ id: 9, cantidad_actual: 3, fecha_caducidad: "2026-07-01", activo: true }],
    },
    1,
    {
      9: {
        estado: "APROBADA",
        precio_propuesto: 70,
        vigencia_desde: HOY,
        vigencia_hasta: "2026-06-30",
      },
    },
    HOY
  );
  expect(r.fuentePrecio).toBe("caducidad");
  expect(r.descuento_pct).toBe(0);
  expect(r.precio).toBe(70);
});
