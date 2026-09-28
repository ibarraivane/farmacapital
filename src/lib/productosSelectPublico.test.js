import { PRODUCTOS_COLUMNAS_TIENDA, PRODUCTOS_SELECT_TIENDA, selectIncluyeCosto } from "./productosSelectPublico";

describe("productosSelectPublico", () => {
  it("la tienda no pide costo", () => {
    expect(PRODUCTOS_COLUMNAS_TIENDA).not.toContain("costo");
    expect(selectIncluyeCosto(PRODUCTOS_SELECT_TIENDA)).toBe(false);
  });

  it("incluye lo que la vitrina y el delta necesitan", () => {
    for (const col of ["id", "nombre", "precio", "stock", "bajo_pedido", "vitrina_seccion", "visible_tienda", "venta_unidad", "updated_at"]) {
      expect(PRODUCTOS_COLUMNAS_TIENDA).toContain(col);
    }
  });

  it("detecta costo y el comodín", () => {
    expect(selectIncluyeCosto("*")).toBe(true);
    expect(selectIncluyeCosto("id,costo,precio")).toBe(true);
    expect(selectIncluyeCosto("id, costo ,precio")).toBe(true);
    expect(selectIncluyeCosto("id,precio,stock")).toBe(false);
    expect(selectIncluyeCosto("id, stock, lotes(costo_unitario)")).toBe(false);
  });
});
