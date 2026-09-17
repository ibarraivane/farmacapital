/**
 * Regresión: html + body con overflow-y:auto a la vez generan rebote /
 * “traba” de scroll en móvil (hay que soltar el dedo para poder bajar).
 * Solo html debe ser el scroller vertical; body overflow-y visible.
 * En iPhone Chrome, las bandas con solo overflow-x:auto también atrapan el gesto.
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");

describe("tienda scroll root (index.css)", () => {
  test("html es el único scroller vertical", () => {
    expect(css).toMatch(/html\s*\{[^}]*overflow-y:\s*auto/s);
    expect(css).toMatch(/html\s*\{[^}]*overscroll-behavior-y:\s*none/s);
  });

  test("body no compite con overflow-y:auto", () => {
    // Bloque principal de body (margin:0…), no el refuerzo corto de @supports.
    expect(css).toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*visible/s);
    expect(css).not.toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*auto/s);
  });

  test("bandas son solo scroll horizontal (overflow-y hidden) y en móvil usan snap proximity", () => {
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overflow-y:\s*hidden/s);
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overscroll-behavior-x:\s*contain/s);
    expect(css).toMatch(/@media\s*\(max-width:\s*767px\)\s*\{[^}]*scroll-snap-type:\s*x\s+proximity/s);
  });
});
