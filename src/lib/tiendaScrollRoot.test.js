/**
 * Regresión: html + body con overflow-y:auto a la vez generan rebote /
 * “traba” de scroll en móvil (hay que soltar el dedo para poder bajar).
 * Solo html debe ser el scroller vertical.
 * body/main no pueden usar overflow-x:hidden: en CSS eso convierte
 * overflow-y:visible en auto y Chrome de escritorio se traga la rueda.
 * En iPhone Chrome, las bandas con solo overflow-x:auto también atrapan el gesto.
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");
const html = fs.readFileSync(path.join(__dirname, "../../public/index.html"), "utf8");
const tienda = fs.readFileSync(path.join(__dirname, "../Tienda.jsx"), "utf8");

describe("tienda scroll root (index.css)", () => {
  test("html es el único scroller vertical", () => {
    expect(css).toMatch(/html\s*\{[^}]*overflow-y:\s*auto/s);
    expect(css).toMatch(/html\s*\{[^}]*overscroll-behavior-y:\s*none/s);
  });

  test("body no es scrollport: clip en X y visible en Y", () => {
    // Bloque principal de body (margin:0…), no el refuerzo corto de @supports.
    expect(css).toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-x:\s*clip/s);
    expect(css).toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*visible/s);
    expect(css).not.toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-x:\s*hidden/s);
    expect(css).not.toMatch(/body\s*\{[^}]*margin:\s*0;[^}]*overflow-y:\s*auto/s);
  });

  test("bandas son solo scroll horizontal (overflow-y hidden) y en móvil usan snap proximity", () => {
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overflow-y:\s*hidden/s);
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overscroll-behavior-x:\s*contain/s);
    expect(css).toMatch(/@media\s*\(max-width:\s*767px\)\s*\{[^}]*scroll-snap-type:\s*x\s+proximity/s);
  });
});

describe("tienda scroll root (shell)", () => {
  test("index.html no deja body como overflow-y:auto", () => {
    expect(html).toMatch(/overflow-x:\s*clip/);
    expect(html).not.toMatch(/body\s*\{[^}]*overflow-y:\s*auto/s);
  });

  test("Tienda no pone overflow-x:hidden en body/main/shell", () => {
    expect(tienda).toMatch(/overflow-x:clip/);
    expect(tienda).not.toMatch(/body\{[^}]*overflow-x:hidden/s);
    expect(tienda).not.toMatch(/main\{\s*overflow-x:hidden/s);
    expect(tienda).not.toMatch(/farmacapital-tienda-shell\{\s*overflow-x:hidden/s);
  });

  test("el hero recorta con clip, no hidden (hidden traga la rueda)", () => {
    expect(tienda).toMatch(/className="hero-carousel"[\s\S]*?overflow:"clip"/);
    expect(tienda).toMatch(/heroShellSx[\s\S]*?overflow:\s*"clip"/);
  });

  test("volver al catálogo desde un producto restaura scroll (no siempre top)", () => {
    expect(tienda).toMatch(/aplicarPosicionCatalogo/);
    expect(tienda).toMatch(/intentScrollCatalogo/);
    expect(tienda).toMatch(/hayRestoreCatalogo/);
    expect(tienda).toMatch(/leerVisiblesCatalogo/);
    expect(tienda).not.toMatch(/requestAnimationFrame\(\(\)=>\{ window\.scrollTo\(0, 0\); \}\)/);
  });
});
