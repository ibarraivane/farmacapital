/**
 * Regresión: iOS dark mode pinta negros los inputs sin color-scheme + fondo.
 * La clase farmacapital-field-input debe forzar blanco.
 */
const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "../index.css"), "utf8");
const form = fs.readFileSync(
  path.join(__dirname, "../components/SolicitudCatalogoForm.jsx"),
  "utf8",
);

describe("inputs tienda fondo blanco", () => {
  test("CSS global fuerza fondo blanco en farmacapital-field-input", () => {
    expect(css).toMatch(
      /\.farmacapital-field-input[\s\S]*?background-color:\s*#ffffff\s*!important/,
    );
    expect(css).toMatch(/color-scheme:\s*light/);
  });

  test("buscador de tienda (nombre / catálogo) usa clase + fondo blanco", () => {
    const tienda = fs.readFileSync(path.join(__dirname, "../Tienda.jsx"), "utf8");
    expect(tienda).toMatch(/className="farmacapital-field-input"/);
    expect(tienda).toMatch(/background:\s*["']#ffffff["']/);
    expect(tienda).toMatch(/colorScheme:\s*["']light["']/);
  });

  test("formulario Conseguir usa clase + fondo blanco explícito", () => {
    expect(form).toMatch(/farmacapital-field-input/);
    expect(form).toMatch(/background:\s*[\"']#ffffff[\"']/);
    expect(form).toMatch(/colorScheme:\s*[\"']light[\"']/);
  });

  test("copy de cliente sin jerga y campos con pista", () => {
    expect(form).not.toMatch(/mayorista/i);
    expect(form).toMatch(/Producto que buscas/);
    expect(form).toMatch(/¿Cuántas piezas\?/);
    expect(form).toMatch(/¿Para cuándo lo necesitas\?/);
    expect(form).toMatch(/Enviar pedido/);
    expect(form).not.toMatch(/Levantar pedido/);
  });
});
