import { readFileSync } from "fs";
import { join } from "path";

test("exceljs y pdfmake no se importan en estático", () => {
  const excel = readFileSync(join(__dirname, "excelTransacciones.js"), "utf8");
  const pdf = readFileSync(join(__dirname, "pdfReporteMensual.js"), "utf8");
  const botones = readFileSync(join(__dirname, "BotonesReporte.jsx"), "utf8");
  expect(excel).toMatch(/import\('exceljs'\)/);
  expect(excel).not.toMatch(/^import .* from ['"]exceljs['"]/m);
  expect(pdf).toMatch(/import\(['"]pdfmake/);
  expect(botones).not.toMatch(/from ['"]exceljs['"]/);
  expect(botones).not.toMatch(/from ['"]pdfmake/);
});

test("PR 1 exporta las hojas acordadas", () => {
  const excel = readFileSync(join(__dirname, "excelTransacciones.js"), "utf8");
  expect(excel).toContain("HOJAS_PR1");
  expect(excel).toContain("transacciones");
  expect(excel).toContain("detalle");
  expect(excel).toContain("diario");
  expect(excel).toContain("cortes");
  expect(excel).toContain("por_hora");
});
