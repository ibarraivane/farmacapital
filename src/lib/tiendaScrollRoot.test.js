/**
 * Regresión: html + body con overflow-y:auto a la vez generan rebote /
 * “traba” de scroll en móvil (hay que soltar el dedo para poder bajar).
 * Solo html debe ser el scroller vertical; body overflow-y visible.
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");

function blockFor(selector) {
  const re = new RegExp(`${selector.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\s*\\{([^}]+)\\}`, "m");
  const m = css.match(re);
  return m ? m[1] : "";
}

describe("tienda scroll root (index.css)", () => {
  test("html es el único scroller vertical", () => {
    const html = blockFor("html");
    expect(html).toMatch(/overflow-y:\s*auto/);
    expect(html).toMatch(/overscroll-behavior-y:\s*none/);
  });

  test("body no compite con overflow-y:auto", () => {
    const body = blockFor("body");
    expect(body).toMatch(/overflow-y:\s*visible/);
    expect(body).not.toMatch(/overflow-y:\s*auto/);
    expect(body).toMatch(/overscroll-behavior-y:\s*none/);
  });

  test("bandas contienen overscroll y en móvil usan snap proximity", () => {
    expect(css).toMatch(/\.farmacapital-productos-strip\s*\{[^}]*overscroll-behavior-x:\s*contain/s);
    expect(css).toMatch(/@media\s*\(max-width:\s*767px\)\s*\{[^}]*scroll-snap-type:\s*x\s+proximity/s);
  });
});
