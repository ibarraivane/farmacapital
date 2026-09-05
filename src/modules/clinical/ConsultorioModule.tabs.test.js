import { readFileSync } from "fs";
import { join } from "path";

test("Consultorio ya no usa emoji en pestañas ni en el título", () => {
  const src = readFileSync(join(__dirname, "ConsultorioModule.jsx"), "utf8");
  expect(src).toMatch(/label: "Lista de espera"/);
  expect(src).toMatch(/label: "En consulta"/);
  expect(src).not.toMatch(/⏳ Lista/);
  expect(src).not.toMatch(/🏥 En consulta/);
  expect(src).not.toMatch(/♥ Consultorio/);
  expect(src).not.toMatch(/💧 Finanzas/);
});
