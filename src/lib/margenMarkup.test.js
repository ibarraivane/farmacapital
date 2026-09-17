import {
  markupSobreCostoPct,
  margenSobreVentaPct,
  precioDesdeMarkup,
  precioDesdeMargenBruto,
  margenPctDesdeMarkupPct,
  markupPctDesdeMargenPct,
  resumenRecargoYMargen,
  ayudaRecargoVsMargen,
} from "./margenMarkup";

test("comprar en $100 y vender en $130 es recargo 30%, no margen 30%", () => {
  expect(markupSobreCostoPct(130, 100)).toBe(30);
  expect(margenSobreVentaPct(130, 100)).toBe(23.1);
  expect(margenPctDesdeMarkupPct(30)).toBe(23.1);
});

test("margen real 30% pide $142.86 sobre costo $100", () => {
  expect(precioDesdeMargenBruto(100, 30)).toBeCloseTo(142.857, 3);
  expect(margenSobreVentaPct(142.857142857, 100)).toBe(30);
  expect(markupPctDesdeMargenPct(30)).toBe(42.9);
});

test("ejemplo de farmacia: costo $250", () => {
  expect(precioDesdeMarkup(250, 30)).toBe(325);
  expect(margenSobreVentaPct(325, 250)).toBe(23.1);
  expect(precioDesdeMargenBruto(250, 30)).toBeCloseTo(357.143, 3);
  expect(precioDesdeMargenBruto(250, 30, { ceil: true })).toBe(358);

  const ayuda = ayudaRecargoVsMargen(250);
  expect(ayuda.genericoPrecio).toBe(400);
  expect(ayuda.patentePrecio).toBe(313);
  expect(ayuda.genericoMargenPct).toBe(37.5);
  expect(ayuda.patenteMargenPct).toBe(20.1);
  expect(ayuda.margen30Precio).toBe(358);
});

test("60% al costo es 37.5% de margen; 25% al costo es 20%", () => {
  expect(margenPctDesdeMarkupPct(60)).toBe(37.5);
  expect(margenPctDesdeMarkupPct(25)).toBe(20);
  expect(precioDesdeMarkup(250, 60, { ceil: true })).toBe(400);
  expect(precioDesdeMarkup(250, 25, { ceil: true })).toBe(313);
});

test("la tabla muestra los dos porcentajes", () => {
  const r = resumenRecargoYMargen(130, 100);
  expect(r.recargoLabel).toBe("30.0%");
  expect(r.margenLabel).toBe("23.1%");
});

test("sin costo no inventa margen", () => {
  expect(margenSobreVentaPct(130, 0)).toBeNull();
  expect(markupSobreCostoPct(130, null)).toBeNull();
  expect(ayudaRecargoVsMargen(null).usoEjemplo).toBe(true);
  expect(ayudaRecargoVsMargen(null).costo).toBe(250);
});
