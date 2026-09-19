/**
 * El buscador, Ver catálogo y las categorías del catálogo deben
 * quedarse visibles al bajar la página (otra búsqueda sin volver arriba).
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");
const tienda = fs.readFileSync(path.join(__dirname, "../Tienda.jsx"), "utf8");

describe("catálogo sticky (buscador + categorías)", () => {
  test("CSS fija el buscador bajo el header", () => {
    expect(css).toMatch(/\.farmacapital-catalogo-busqueda-sticky\s*\{[^}]*position:\s*sticky/s);
    expect(css).toMatch(/\.farmacapital-catalogo-busqueda-sticky\s*\{[^}]*top:\s*var\(--fc-header-h\)/s);
  });

  test("en escritorio las categorías quedan sticky bajo el buscador", () => {
    expect(css).toMatch(
      /@media\s*\(min-width:\s*1025px\)\s*\{[^}]*\.farmacapital-catalogo-categorias\s*\{[^}]*position:\s*sticky/s,
    );
    expect(css).toMatch(
      /top:\s*calc\(var\(--fc-header-h\)\s*\+\s*var\(--fc-catalogo-busq-h\)\)/,
    );
  });

  test("Catalogo usa las clases sticky y no recorta el scrollport con overflow-x clip", () => {
    expect(tienda).toMatch(/farmacapital-catalogo-busqueda-sticky/);
    expect(tienda).toMatch(/farmacapital-catalogo-categorias/);
    expect(tienda).toMatch(/farmacapital-catalogo-cats-scroll/);
    expect(tienda).toMatch(/id="farmacapital-catalogo-busqueda"/);
    const catalogoFn = tienda.match(/function Catalogo\([\s\S]*?\nfunction Carrito/);
    expect(catalogoFn).toBeTruthy();
    expect(catalogoFn[0]).not.toMatch(/overflowX:\s*["']clip["']/);
  });

  test("el input de búsqueda fuerza fondo blanco (iOS dark mode)", () => {
    expect(tienda).toMatch(/className="farmacapital-field-input"/);
    expect(tienda).toMatch(/background:\s*["']#ffffff["']/);
    expect(tienda).toMatch(/colorScheme:\s*["']light["']/);
  });
});
