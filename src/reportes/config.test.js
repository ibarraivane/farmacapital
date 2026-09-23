jest.mock("../supabase", () => ({ supabase: { rpc: jest.fn(), from: jest.fn() } }));

import { aFecha, aHora, nombreArchivo, nombreMes, traducirError } from "./config";

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

test("traducirError no confunde todo 42501 con falta de admin", () => {
  expect(
    traducirError({ message: "ACCESO_DENEGADO: este reporte es exclusivo del rol admin", code: "42501" })
      .message,
  ).toMatch(/exclusivo del administrador/);
  expect(
    traducirError({ message: "Requiere rol admin o gerente", code: "42501" }).message,
  ).toMatch(/exclusivo del administrador/);
  expect(
    traducirError({ message: "permission denied for view v_rep_partida", code: "42501" }).message,
  ).toMatch(/permission denied/);
  expect(
    traducirError({ message: "Sesión inválida o expirada", code: "28000" }).message,
  ).toMatch(/Sesión expirada/);
});
