import {
  tipoAltaNormalizado,
  margenAltaRecepcion,
  precioSugeridoAltaRecepcion,
  payloadAltaRecepcion,
  skuAltaRecepcion,
} from "./recepcionAlta";

test("patente 25% y genérico 60% de recargo sobre costo", () => {
  expect(tipoAltaNormalizado("patente")).toBe("marca");
  expect(margenAltaRecepcion("marca")).toBe(25);
  expect(margenAltaRecepcion("generico")).toBe(60);
  expect(precioSugeridoAltaRecepcion(204.38, "marca")).toBe(256);
  expect(precioSugeridoAltaRecepcion(77.28, "generico")).toBe(124);
});

test("sku desde EAN: FC- + últimos 8", () => {
  expect(skuAltaRecepcion("070942303460")).toBe("FC-42303460");
  expect(skuAltaRecepcion("7501300407047")).toBe("FC-00407047");
  expect(skuAltaRecepcion("", 1_725_600_000_123)).toBe("FC-00000123");
});

test("el payload de alta incluye sku y no inventa stock ni caducidad", () => {
  const p = payloadAltaRecepcion({
    nombre: "Febrax 15 tab",
    codigo: "7501300407047",
    tipo: "patente",
    costo: 204.38,
  });
  expect(p.tipo).toBe("marca");
  expect(p.precio).toBe(256);
  expect(p.sku).toBe("FC-00407047");
  expect(p.codigo_barras).toBe("7501300407047");
  expect(p.stock).toBeUndefined();
  expect(p.fecha_caducidad).toBeUndefined();
});

test("City Mark GUM pendiente de alta manda sku NOT NULL", () => {
  const p = payloadAltaRecepcion({
    nombre: "CEP DENT GUM TRAV-LER INTERDENTA 0.8",
    codigo: "070942303460",
    tipo: "marca",
    costo: 82.63,
  });
  expect(p.sku).toBe("FC-42303460");
  expect(p.codigo_barras).toBe("070942303460");
});
