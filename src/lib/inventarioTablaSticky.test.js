import {
  INV_CHECKBOX_COL_WIDTH,
  INV_COL_WIDTHS_DEFAULT,
  INV_STICKY_COL_IDS,
  invColumnPixelWidth,
  inventarioStickyLefts,
  inventarioStickyStyle,
  invTablePixelWidth,
  stickyWidthsEqual,
} from "./inventarioTablaSticky";

const ORDER = [
  "foto",
  "acciones",
  "skuFarmaCapital",
  "codigoBarras",
  "nombre",
  "marca",
  "stock",
  "precio",
];

describe("inventarioStickyLefts", () => {
  test("el checkbox y las fijas se apilan; cód. barras no suma", () => {
    const lefts = inventarioStickyLefts(ORDER, INV_COL_WIDTHS_DEFAULT, { hasCheckbox: true });
    expect(lefts.checkbox).toBe(0);
    expect(lefts.foto).toBe(INV_CHECKBOX_COL_WIDTH);
    expect(lefts.acciones).toBe(lefts.foto + invColumnPixelWidth("foto"));
    expect(lefts.skuFarmaCapital).toBe(lefts.acciones + invColumnPixelWidth("acciones", INV_COL_WIDTHS_DEFAULT));
    expect(lefts.nombre).toBe(lefts.skuFarmaCapital + invColumnPixelWidth("skuFarmaCapital"));
    expect(lefts.nombre).toBe(INV_CHECKBOX_COL_WIDTH + 44 + 104 + 118);
  });

  test("sin checkbox (consulta) Nombre arranca después de foto+sku", () => {
    const order = ORDER.filter((id) => id !== "acciones");
    const lefts = inventarioStickyLefts(order, INV_COL_WIDTHS_DEFAULT, { hasCheckbox: false });
    expect(lefts.checkbox).toBeUndefined();
    expect(lefts.foto).toBe(0);
    expect(lefts.nombre).toBe(44 + 118);
  });

  test("redondea hacia arriba anchos fraccionarios para no montarse", () => {
    const lefts = inventarioStickyLefts(ORDER, INV_COL_WIDTHS_DEFAULT, {
      hasCheckbox: true,
      measuredWidths: { checkbox: 38.4, foto: 44.6, acciones: 104.2, skuFarmaCapital: 118.8 },
    });
    expect(lefts.foto).toBe(39);
    expect(lefts.acciones).toBe(39 + 45);
    expect(lefts.skuFarmaCapital).toBe(39 + 45 + 105);
    expect(lefts.nombre).toBe(39 + 45 + 105 + 119);
  });

  test("usa anchos medidos si vienen del DOM", () => {
    const lefts = inventarioStickyLefts(ORDER, INV_COL_WIDTHS_DEFAULT, {
      hasCheckbox: true,
      measuredWidths: { checkbox: 40, foto: 50, acciones: 110, skuFarmaCapital: 120 },
    });
    expect(lefts.foto).toBe(40);
    expect(lefts.acciones).toBe(90);
    expect(lefts.skuFarmaCapital).toBe(200);
    expect(lefts.nombre).toBe(320);
  });
});

describe("inventarioStickyStyle", () => {
  test("columnas a la izquierda quedan encima (z-index)", () => {
    const foto = inventarioStickyStyle("foto", ORDER, INV_COL_WIDTHS_DEFAULT, { header: false, bg: "#fff" });
    const sku = inventarioStickyStyle("skuFarmaCapital", ORDER, INV_COL_WIDTHS_DEFAULT, { header: false, bg: "#fff" });
    const nombre = inventarioStickyStyle("nombre", ORDER, INV_COL_WIDTHS_DEFAULT, { header: false, bg: "#fff" });
    expect(foto.zIndex).toBeGreaterThan(sku.zIndex);
    expect(sku.zIndex).toBeGreaterThan(nombre.zIndex);
    expect(nombre.overflow).toBe("hidden");
    expect(nombre.left).toBe(INV_CHECKBOX_COL_WIDTH + 44 + 104 + 118);
  });

  test("el header queda encima del body", () => {
    const th = inventarioStickyStyle("nombre", ORDER, INV_COL_WIDTHS_DEFAULT, { header: true, bg: "#fff" });
    const td = inventarioStickyStyle("nombre", ORDER, INV_COL_WIDTHS_DEFAULT, { header: false, bg: "#fff" });
    expect(th.zIndex).toBeGreaterThan(td.zIndex);
  });

  test("columna no sticky no recibe position", () => {
    expect(inventarioStickyStyle("precio", ORDER, INV_COL_WIDTHS_DEFAULT, { header: false })).toEqual({});
  });
});

describe("invTablePixelWidth / stickyWidthsEqual", () => {
  test("suma checkbox + columnas", () => {
    const w = invTablePixelWidth(["foto", "nombre"], INV_COL_WIDTHS_DEFAULT, { hasCheckbox: true });
    expect(w).toBe(INV_CHECKBOX_COL_WIDTH + 44 + 272);
  });

  test("INV_STICKY_COL_IDS cubre foto acciones sku nombre", () => {
    expect(INV_STICKY_COL_IDS).toEqual(["foto", "acciones", "skuFarmaCapital", "nombre"]);
  });

  test("stickyWidthsEqual tolera subpíxel", () => {
    expect(stickyWidthsEqual({ foto: 44 }, { foto: 44.4 })).toBe(true);
    expect(stickyWidthsEqual({ foto: 44 }, { foto: 46 })).toBe(false);
  });
});
