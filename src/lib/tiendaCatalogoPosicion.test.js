import {
  CATALOGO_SCROLL_KEY,
  CATALOGO_VISIBLES_KEY,
  CATALOGO_PRODUCTO_KEY,
  CATALOGO_RESTORE_KEY,
  leerScrollCatalogo,
  guardarScrollCatalogo,
  leerVisiblesCatalogo,
  guardarVisiblesCatalogo,
  leerProductoCatalogo,
  guardarProductoCatalogo,
  hayRestoreCatalogo,
  marcarRestoreCatalogo,
  limpiarRestoreCatalogo,
  resetearPosicionCatalogo,
  intentScrollCatalogo,
  snapshotSalidaCatalogo,
  aplicarPosicionCatalogo,
} from "./tiendaCatalogoPosicion";

describe("tiendaCatalogoPosicion", () => {
  beforeEach(() => {
    sessionStorage.clear();
  });

  test("guarda y lee scroll; 0 o inválido se borra", () => {
    expect(guardarScrollCatalogo(842.6)).toBe(843);
    expect(leerScrollCatalogo()).toBe(843);
    expect(sessionStorage.getItem(CATALOGO_SCROLL_KEY)).toBe("843");
    expect(guardarScrollCatalogo(0)).toBe(0);
    expect(leerScrollCatalogo()).toBe(0);
    expect(sessionStorage.getItem(CATALOGO_SCROLL_KEY)).toBeNull();
    expect(guardarScrollCatalogo("no")).toBe(0);
  });

  test("visibles no baja del page size", () => {
    expect(leerVisiblesCatalogo(36)).toBe(36);
    expect(guardarVisiblesCatalogo(72, 36)).toBe(72);
    expect(leerVisiblesCatalogo(36)).toBe(72);
    expect(guardarVisiblesCatalogo(10, 36)).toBe(36);
    expect(leerVisiblesCatalogo(36)).toBe(36);
    expect(sessionStorage.getItem(CATALOGO_VISIBLES_KEY)).toBe("36");
  });

  test("producto y flag de restore", () => {
    expect(leerProductoCatalogo()).toBe("");
    expect(guardarProductoCatalogo(99)).toBe("99");
    expect(leerProductoCatalogo()).toBe("99");
    expect(sessionStorage.getItem(CATALOGO_PRODUCTO_KEY)).toBe("99");
    expect(hayRestoreCatalogo()).toBe(false);
    marcarRestoreCatalogo();
    expect(hayRestoreCatalogo()).toBe(true);
    expect(sessionStorage.getItem(CATALOGO_RESTORE_KEY)).toBe("1");
    limpiarRestoreCatalogo();
    expect(hayRestoreCatalogo()).toBe(false);
  });

  test("resetear limpia todo", () => {
    guardarScrollCatalogo(400);
    guardarVisiblesCatalogo(72, 36);
    guardarProductoCatalogo("abc");
    marcarRestoreCatalogo();
    resetearPosicionCatalogo();
    expect(leerScrollCatalogo()).toBe(0);
    expect(leerVisiblesCatalogo(36)).toBe(36);
    expect(leerProductoCatalogo()).toBe("");
    expect(hayRestoreCatalogo()).toBe(false);
  });

  test("intent: atrás desde ficha restaura; menú/búsqueda no", () => {
    expect(intentScrollCatalogo({ fromPage: "detalle" })).toBe("restore");
    expect(intentScrollCatalogo({ fromPage: "home" })).toBe("top");
    expect(intentScrollCatalogo({ fromPage: "detalle", catalogoScroll: "results" })).toBe("results");
    expect(intentScrollCatalogo({ fromPage: "detalle", catalogoScroll: "top" })).toBe("top");
    expect(intentScrollCatalogo({ fromPage: "home", catalogoScroll: "restore" })).toBe("restore");
  });

  test("snapshot de salida guarda Y y el producto abierto", () => {
    snapshotSalidaCatalogo({ scrollY: 1200, productId: "sku-1" });
    expect(leerScrollCatalogo()).toBe(1200);
    expect(leerProductoCatalogo()).toBe("sku-1");
  });

  test("aplicar: prioriza el producto, luego Y, luego arriba", () => {
    const scrollTo = jest.fn();
    const el = { scrollIntoView: jest.fn() };
    expect(aplicarPosicionCatalogo({
      y: 900,
      productId: "7",
      scrollTo,
      findProducto: () => el,
    })).toBe("producto");
    expect(el.scrollIntoView).toHaveBeenCalledWith({ block: "center", inline: "nearest" });
    expect(scrollTo).not.toHaveBeenCalled();

    expect(aplicarPosicionCatalogo({
      y: 900,
      productId: "7",
      scrollTo,
      findProducto: () => null,
    })).toBe("scroll");
    expect(scrollTo).toHaveBeenCalledWith(900);

    expect(aplicarPosicionCatalogo({ y: 0, scrollTo, findProducto: () => null })).toBe("top");
    expect(scrollTo).toHaveBeenCalledWith(0);
  });
});
