const fs = require("fs");
const path = require("path");
const { RUBROS_BAJO_PEDIDO, rubroDeProducto } = require("./bajoPedido");

const sqlPath = path.join(__dirname, "../../sql/patch_alta_integral_vitaminas_dispositivos_20260917.sql");
const sql = fs.readFileSync(sqlPath, "utf8");
const imgDir = path.join(__dirname, "../../public/catalogo-propia");

test("vitrina tiene pestaña Dispositivos", () => {
  expect(RUBROS_BAJO_PEDIDO.map((r) => r.id)).toEqual([
    "dermatologia",
    "vitaminas",
    "suplementos",
    "proteina",
    "dispositivos",
  ]);
  expect(rubroDeProducto({ categoria: "Dispositivo médico" })).toBe("dispositivos");
  expect(rubroDeProducto({ categoria: "Botiquín" })).toBe("dispositivos");
});

test("SQL Integral trae vitaminas y dispositivos con foto de mostrador", () => {
  expect(sql).toMatch(/farmacia-integral\.odoo\.com\/shop/);
  expect(sql).toMatch(/'Vitaminas'/);
  expect(sql).toMatch(/'Dispositivo médico'/);
  expect(sql).not.toMatch(/BLOQ ANTHE/);
  const rows = [...sql.matchAll(/\('(\d{8,14})',\s*'FC-/g)];
  expect(rows.length).toBeGreaterThanOrEqual(40);
  const fotos = [...sql.matchAll(/catalogo-propia\/([a-z0-9._-]+\.jpe?g)/gi)].map((m) => m[1]);
  expect(fotos.length).toBe(rows.length);
  const missing = fotos.filter((f) => !fs.existsSync(path.join(imgDir, f)));
  expect(missing).toEqual([]);
});
