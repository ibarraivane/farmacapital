import { readFileSync } from "fs";
import { join } from "path";

const sql = readFileSync(
  join(__dirname, "../../sql/patch_fase2_vitrina_nutricion_deportiva_20260917.sql"),
  "utf8"
);

test("SQL fase 2 solo reclasifica; no alta ni bajo_pedido", () => {
  expect(sql).toMatch(/Nutrición deportiva/);
  expect(sql).toMatch(/pancreatin/);
  expect(sql).toMatch(/shampoo/);
  expect(sql).not.toMatch(/insert\s+into\s+public\.productos/i);
  expect(sql).not.toMatch(/bajo_pedido\s*=\s*true/i);
  expect(sql).toMatch(/set\s+subcategoria\s*=\s*'Nutrición deportiva'/i);
});
