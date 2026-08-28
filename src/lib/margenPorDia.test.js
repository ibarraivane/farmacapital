import { agruparCostoGananciaPorDia, serieCostoGanancia, totalesCostoGanancia } from "./margenPorDia";

const caja = {
  precio_unitario: 100,
  cantidad: 1,
  productos: { costo: 60, precio: 100, venta_unidad: false, unidades_por_caja: 1 },
};

test("agrupa costo y ganancia por día de México, pegando la fecha de peds", () => {
  const pedsCat = [{ productos: [caja] }, { productos: [{ ...caja, precio_unitario: 50, productos: { ...caja.productos, costo: 20 } }] }];
  const peds = [
    { created_at: "2026-08-15T21:37:00.000Z", total: 100 },
    { created_at: "2026-08-16T18:00:00.000Z", total: 50 },
  ];
  const byDay = agruparCostoGananciaPorDia(pedsCat, peds);
  expect(byDay["2026-08-15"]).toEqual({ ymd: "2026-08-15", ingreso: 100, costo: 60, ganancia: 40 });
  expect(byDay["2026-08-16"]).toEqual({ ymd: "2026-08-16", ingreso: 50, costo: 20, ganancia: 30 });
  expect(totalesCostoGanancia(byDay)).toEqual({
    ingreso: 150,
    costo: 80,
    ganancia: 70,
    margenPct: 46.67,
  });
});

test("serie rellena días sin venta", () => {
  const serie = serieCostoGanancia({
    porDia: { "2026-08-27": { ingreso: 200, costo: 80, ganancia: 120 } },
    dias: 3,
    hoyYmd: "2026-08-27",
  });
  expect(serie.map((p) => p.key)).toEqual(["2026-08-25", "2026-08-26", "2026-08-27"]);
  expect(serie[0].ingreso).toBe(0);
  expect(serie[2].ganancia).toBe(120);
  expect(serie[2].esActual).toBe(true);
});
