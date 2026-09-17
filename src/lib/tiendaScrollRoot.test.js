/**
 * La página tiene que poder bajar. #246 dejó html/body con
 * overscroll-behavior-y:none y body overflow-y:visible → sin scroll.
 * Las bandas siguen siendo solo eje X (overflow-y:hidden, 220px).
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");
const tienda = fs.readFileSync(path.join(__dirname, "../Tienda.jsx"), "utf8");

describe("tienda scroll root (index.css)", () => {
  test("html permite scroll vertical (sin overscroll none)", () => {
    expect(css).toMatch(/html\s*\{[^}]*overflow-y:\s*auto/s);
    expect(css).not.toMatch(/html\s*\{[^}]*overscroll-behavior-y:\s*none/s);
  });

  test("body también scrollea (overflow-y auto, no visible)", () => {
    expect(css).toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*auto/s);
    expect(css).not.toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*visible/s);
    expect(css).toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overscroll-behavior-y:\s*auto/s);
  });

  test("el inline de Tienda no vuelve a bloquear el documento", () => {
    expect(tienda).toMatch(/overflow-y:\s*auto/);
    expect(tienda).toMatch(/overscroll-behavior-y:\s*auto/);
    expect(tienda).not.toMatch(/overscroll-behavior-y:\s*none/);
  });

  test("bandas son solo scroll horizontal (overflow-y hidden) y en móvil usan snap proximity", () => {
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overflow-y:\s*hidden/s);
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overscroll-behavior-x:\s*contain/s);
    expect(css).toMatch(/@media\s*\(max-width:\s*767px\)\s*\{[^}]*scroll-snap-type:\s*x\s+proximity/s);
  });
});
