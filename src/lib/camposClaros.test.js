import { readFileSync } from "fs";
import { join } from "path";

const css = readFileSync(join(__dirname, "../index.css"), "utf8");

test("los inputs del pedido especial fuerzan celda blanca (Safari oscuro)", () => {
  expect(css).toMatch(/#pedido-especial-form input/);
  expect(css).toMatch(/background-color:\s*#ffffff\s*!important/);
  expect(css).toMatch(/prefers-color-scheme:\s*dark/);
  expect(css).toMatch(/color-scheme:\s*light\s*!important/);
});
