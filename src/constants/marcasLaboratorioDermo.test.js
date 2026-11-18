import { MARCAS_LABORATORIO_DERMO, esMarcaLaboratorioDermo } from "./marcasLaboratorioDermo";

test("lista fija de laboratorio", () => {
  expect([...MARCAS_LABORATORIO_DERMO]).toEqual(["svr", "alastin", "medik8"]);
});

test("reconoce marcas sin importar mayúsculas", () => {
  expect(esMarcaLaboratorioDermo("SVR")).toBe(true);
  expect(esMarcaLaboratorioDermo(" Alastin ")).toBe(true);
  expect(esMarcaLaboratorioDermo("Medik8")).toBe(true);
  expect(esMarcaLaboratorioDermo("Eucerin")).toBe(false);
  expect(esMarcaLaboratorioDermo("CeraVe")).toBe(false);
  expect(esMarcaLaboratorioDermo("")).toBe(false);
});
