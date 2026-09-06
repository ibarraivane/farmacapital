import {
  bandasCatalogoPorCategoria,
  irACatalogoCategoria,
} from "./tiendaCatalogoCategorias";

describe("bandasCatalogoPorCategoria", () => {
  const productos = [
    { id: 1, nombre: "Zyrtec", categoria: "Alergia", stock: 5, activo: true },
    { id: 2, nombre: "Loratadina", categoria: "Alergia", stock: 0, activo: true },
    { id: 3, nombre: "Ibuprofeno", categoria: "Analgésico", stock: 10, activo: true },
    { id: 4, nombre: "Paracetamol", categoria: "analgesico", stock: 2, activo: true },
    { id: 5, nombre: "Inactivo", categoria: "Gastro", stock: 9, activo: false },
    { id: 6, nombre: "Agua", categoria: "Hidratación", stock: 20, activo: true },
    { id: 7, nombre: "Rareza", categoria: "Dermatología", stock: 3, activo: true },
    { id: 8, nombre: "Misc", categoria: "Otro", stock: 1, activo: true },
  ];

  test("agrupa por categoría canónica y ordena bandas", () => {
    const bandas = bandasCatalogoPorCategoria(productos);
    expect(bandas.map((b) => b.categoria)).toEqual([
      "Analgésico",
      "Alergia",
      "Hidratación",
      "Dermatología",
      "Otro",
    ]);
  });

  test("pone disponibles antes que agotados dentro de la banda", () => {
    const bandas = bandasCatalogoPorCategoria(productos);
    const alergia = bandas.find((b) => b.categoria === "Alergia");
    expect(alergia.productos.map((p) => p.nombre)).toEqual(["Zyrtec", "Loratadina"]);
  });

  test("respeta perCat y omite inactivos", () => {
    const bandas = bandasCatalogoPorCategoria(productos, { perCat: 1 });
    const analgesico = bandas.find((b) => b.categoria === "Analgésico");
    expect(analgesico.productos).toHaveLength(1);
    expect(bandas.every((b) => b.productos.every((p) => p.activo !== false))).toBe(true);
    expect(bandas.some((b) => b.categoria === "Gastro")).toBe(false);
  });

  test("respeta maxCats", () => {
    const bandas = bandasCatalogoPorCategoria(productos, { maxCats: 2 });
    expect(bandas).toHaveLength(2);
  });

  test("lista vacía si no hay productos", () => {
    expect(bandasCatalogoPorCategoria([])).toEqual([]);
    expect(bandasCatalogoPorCategoria(null)).toEqual([]);
  });
});

describe("irACatalogoCategoria", () => {
  test("guarda categoría y navega al catálogo", () => {
    const pages = [];
    irACatalogoCategoria((p, opts) => pages.push([p, opts]), "Alergia");
    expect(sessionStorage.getItem("farmacapital_cat")).toBe("Alergia");
    expect(pages).toEqual([["catalogo", { rx: false }]]);
  });
});
