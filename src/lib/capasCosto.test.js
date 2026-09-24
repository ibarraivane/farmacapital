import { capasCostoVivas, textoCapaCosto } from "./capasCosto";

test("el mismo precio de anaquel deja dos márgenes si el costo de compra cambió", () => {
  const capas = capasCostoVivas(
    [
      { cantidad_actual: 8, costo_unitario: 20, activo: true },
      { cantidad_actual: 10, costo_unitario: 12, activo: true },
      { cantidad_actual: 0, costo_unitario: 5, activo: true },
    ],
    25,
  );
  expect(capas).toHaveLength(2);
  expect(capas[0].costo).toBe(12);
  expect(capas[0].piezas).toBe(10);
  expect(capas[0].margenPct).toBe(52);
  expect(capas[1].piezas).toBe(8);
  expect(capas[1].margenPct).toBe(20);
  expect(textoCapaCosto(capas[1])).toBe("8 pzas a $20.00 · margen 20.0%");
});

test("sin costo de lote no inventa una capa", () => {
  expect(capasCostoVivas([{ cantidad_actual: 4, costo_unitario: null, activo: true }], 25)).toEqual([]);
});
