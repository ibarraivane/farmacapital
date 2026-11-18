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

test("la hoja diario no correlaciona v.fecha_local sin agrupar", () => {
  const sql = readFileSync(join(__dirname, "../../supabase/migrations/20260920100000_reporte_mensual.sql"), "utf8");
  const copia = readFileSync(join(__dirname, "../../sql/patch_reporte_mensual_20260920.sql"), "utf8");
  const patch = readFileSync(join(__dirname, "../../sql/patch_reporte_diario_fecha_local_20260923.sql"), "utf8");
  for (const src of [sql, copia, patch]) {
    expect(src).not.toMatch(/pa\.fecha_local::date = v\.fecha_local::date/);
    expect(src).toContain("partidas as");
  }
  expect(patch).toContain("public.rpc_transacciones_mes");
});

test("Dashboard y Transacciones muestran el PDF del mes", () => {
  const dash = readFileSync(join(__dirname, "../DashboardModule.jsx"), "utf8");
  const tx = readFileSync(join(__dirname, "../TransaccionesTab.jsx"), "utf8");
  expect(dash).toMatch(/<BotonesReporte[^>]*mostrarPdf/);
  expect(tx).toMatch(/<BotonesReporte[^>]*mostrarPdf/);
});

test("el PDF no compara usuarios.id con auth.uid()", () => {
  const sql = readFileSync(join(__dirname, "../../supabase/migrations/20260920100000_reporte_mensual.sql"), "utf8");
  const copia = readFileSync(join(__dirname, "../../sql/patch_reporte_mensual_20260920.sql"), "utf8");
  const patch = readFileSync(join(__dirname, "../../sql/patch_reporte_pdf_generado_por_20260923.sql"), "utf8");
  for (const src of [sql, copia, patch]) {
    expect(src).not.toMatch(/id = auth\.uid\(\)/);
    expect(src).toContain("public.sesiones");
  }
  expect(patch).toContain("public.rpc_reporte_mensual");
});

test("botón Excel usa rolEsAdmin (admin o gerente) y el SQL pide fn_require_admin", () => {
  const botones = readFileSync(join(__dirname, "BotonesReporte.jsx"), "utf8");
  const patch = readFileSync(join(__dirname, "../../sql/patch_reporte_excel_admin_20260923.sql"), "utf8");
  expect(botones).toContain("rolEsAdmin");
  expect(botones).not.toMatch(/rol !== ['"]admin['"]/);
  expect(patch).toContain("fn_require_admin");
  expect(patch).toContain("empleado_rpc_transacciones_mes");
});
