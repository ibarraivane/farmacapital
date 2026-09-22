jest.mock("../supabase", () => ({ supabase: { rpc: jest.fn(), from: jest.fn() } }));

import { aFecha, aHora, nombreArchivo, nombreMes } from "./config";

test("aFecha no desplaza el día civil", () => {
  const d = aFecha("2026-09-30");
  expect(d.getUTCFullYear()).toBe(2026);
  expect(d.getUTCMonth()).toBe(8);
  expect(d.getUTCDate()).toBe(30);
});

test("aHora guarda hora real, no texto", () => {
  const h = aHora("23:30:00");
  expect(h).toBeInstanceOf(Date);
  expect(h.getUTCHours()).toBe(23);
  expect(h.getUTCMinutes()).toBe(30);
});

test("nombre de archivo incluye el periodo, no la fecha de descarga", () => {
  expect(nombreArchivo("transacciones", 2026, 9, "xlsx")).toBe(
    "farmacapital_transacciones_2026-09.xlsx",
  );
  expect(nombreMes(2026, 9)).toBe("Septiembre 2026");
});
