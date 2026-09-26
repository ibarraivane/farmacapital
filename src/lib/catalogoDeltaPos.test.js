import { mergeCatalogoDelta } from "./catalogoDeltaPos";

describe("mergeCatalogoDelta", () => {
  const base = [
    { id: 1, nombre: "A", stock: 5 },
    { id: 2, nombre: "B", stock: 3 },
    { id: 3, nombre: "C", stock: 0 },
  ];

  test("sin cambios devuelve el mismo arreglo", () => {
    expect(mergeCatalogoDelta(base, [])).toBe(base);
    expect(mergeCatalogoDelta(base, null)).toBe(base);
  });

  test("reemplaza por id conservando el orden y no toca el resto", () => {
    const out = mergeCatalogoDelta(base, [{ id: 2, nombre: "B", stock: 1 }]);
    expect(out.map((p) => p.id)).toEqual([1, 2, 3]);
    expect(out[1].stock).toBe(1);
    expect(out[0]).toBe(base[0]);
    expect(out[2]).toBe(base[2]);
  });

  test("agrega productos nuevos al final", () => {
    const out = mergeCatalogoDelta(base, [{ id: 9, nombre: "Nuevo", stock: 2 }]);
    expect(out.map((p) => p.id)).toEqual([1, 2, 3, 9]);
  });

  test("quita los inactivos, existan o no en pantalla", () => {
    const out = mergeCatalogoDelta(base, [
      { id: 1, activo: false },
      { id: 77, activo: false },
    ]);
    expect(out.map((p) => p.id)).toEqual([2, 3]);
  });

  test("id numérico y texto se tratan igual", () => {
    const out = mergeCatalogoDelta(base, [{ id: "3", nombre: "C", stock: 8 }]);
    expect(out.find((p) => String(p.id) === "3").stock).toBe(8);
    expect(out).toHaveLength(3);
  });
});
