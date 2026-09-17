import {
  pageIdToTiendaPath,
  resolveTiendaLocation,
  resolveTiendaPage,
  tiendaPathnameToPageId,
  TIENDA_PAGE_IDS,
} from "./tiendaRoutes";

describe("tiendaRoutes", () => {
  test("ids canónicos resuelven a sí mismos", () => {
    TIENDA_PAGE_IDS.forEach((id) => {
      expect(resolveTiendaPage(id)).toBe(id);
    });
  });

  test("alias de banners y typos comunes", () => {
    expect(resolveTiendaPage("promociones")).toBe("promo");
    expect(resolveTiendaPage("faq")).toBe("faq");
    expect(resolveTiendaPage("preguntas")).toBe("faq");
    expect(resolveTiendaPage("consulta")).toBe("cita");
    expect(resolveTiendaPage("Catálogo")).toBe("catalogo");
    expect(resolveTiendaPage("no-existe")).toBeNull();
  });

  test("pathname ↔ page id", () => {
    expect(tiendaPathnameToPageId("/")).toBe("home");
    expect(tiendaPathnameToPageId("/catalogo")).toBe("catalogo");
    expect(tiendaPathnameToPageId("/promociones/")).toBe("promo");
    expect(tiendaPathnameToPageId("/cuenta")).toBe("cuenta");
    expect(tiendaPathnameToPageId("/auth/callback")).toBe("auth-callback");
    expect(tiendaPathnameToPageId("/auth/callback/")).toBe("auth-callback");
    expect(tiendaPathnameToPageId("/admin/ventas")).toBeNull();
  });

  test("path canónico no choca con admin", () => {
    expect(pageIdToTiendaPath("home")).toBe("/");
    expect(pageIdToTiendaPath("catalogo")).toBe("/catalogo");
    expect(pageIdToTiendaPath("catalogo", { rx: true })).toBe("/catalogo?rx=1");
    expect(pageIdToTiendaPath("promo")).toBe("/promociones");
    expect(pageIdToTiendaPath("faq")).toBe("/preguntas");
    expect(pageIdToTiendaPath("detalle", { productId: "abc-1" })).toBe("/producto?id=abc-1");
    expect(pageIdToTiendaPath("auth-callback")).toBe("/auth/callback");
    expect(pageIdToTiendaPath("tarjeta")).toBe("/tarjeta");
    expect(pageIdToTiendaPath("pedidos-especiales", { search: "losartan" })).toBe("/pedidos-especiales?q=losartan");
    expect(pageIdToTiendaPath("dermocosmetica")).toBe("/dermocosmetica");
    expect(pageIdToTiendaPath("vitaminas", { rubro: "proteina" })).toBe("/vitaminas?rubro=proteina");
    expect(pageIdToTiendaPath("conseguir", { seccion: "dermatologia" })).toBe("/dermocosmetica");
    expect(pageIdToTiendaPath("conseguir", { seccion: "nutricion" })).toBe("/vitaminas");
  });

  test("aliases de flyer y conseguir", () => {
    expect(resolveTiendaPage("flyer")).toBe("tarjeta");
    expect(resolveTiendaPage("hola")).toBe("tarjeta");
    expect(resolveTiendaPage("te-lo-conseguimos")).toBe("pedidos-especiales");
    expect(resolveTiendaPage("conseguir")).toBe("pedidos-especiales");
    expect(tiendaPathnameToPageId("/tarjeta")).toBe("tarjeta");
    expect(tiendaPathnameToPageId("/conseguir")).toBe("pedidos-especiales");
    expect(tiendaPathnameToPageId("/dermocosmetica")).toBe("dermocosmetica");
    expect(tiendaPathnameToPageId("/vitaminas")).toBe("vitaminas");
    expect(tiendaPathnameToPageId("/pedidos-especiales")).toBe("pedidos-especiales");
  });

  test("resolveTiendaLocation: canónicas, aliases y rubro desconocido", () => {
    expect(resolveTiendaLocation("/dermocosmetica", "")).toMatchObject({
      page: "dermocosmetica", seccion: "dermatologia", rubro: "", shouldReplace: false,
    });
    expect(resolveTiendaLocation("/vitaminas", "?rubro=proteina")).toMatchObject({
      page: "vitaminas", seccion: "nutricion", rubro: "proteina", canonicalPath: "/vitaminas?rubro=proteina",
    });
    expect(resolveTiendaLocation("/vitaminas", "?rubro=noexiste")).toMatchObject({
      page: "vitaminas", rubro: "", canonicalPath: "/vitaminas", shouldReplace: true,
    });
    expect(resolveTiendaLocation("/pedidos-especiales", "?q=losartan")).toMatchObject({
      page: "pedidos-especiales", search: "losartan",
    });
    const aliasesDerma = ["derma", "dermatologia", "dermatologico", "dermocosmetica"];
    aliasesDerma.forEach((seccion) => {
      const loc = resolveTiendaLocation("/conseguir", `?seccion=${seccion}`);
      expect(loc.page).toBe("dermocosmetica");
      expect(loc.canonicalPath).toBe("/dermocosmetica");
      expect(loc.shouldReplace).toBe(true);
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=nutri")).toMatchObject({
      page: "vitaminas", rubro: "", canonicalPath: "/vitaminas",
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=nutricion")).toMatchObject({
      page: "vitaminas", canonicalPath: "/vitaminas",
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=vitaminas")).toMatchObject({
      page: "vitaminas", rubro: "",
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=suplementos")).toMatchObject({
      page: "vitaminas", rubro: "suplementos", canonicalPath: "/vitaminas?rubro=suplementos",
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=proteina")).toMatchObject({
      page: "vitaminas", rubro: "proteina", canonicalPath: "/vitaminas?rubro=proteina",
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=proteinas")).toMatchObject({
      page: "vitaminas", rubro: "proteina",
    });
    expect(resolveTiendaLocation("/conseguir", "")).toMatchObject({
      page: "pedidos-especiales", canonicalPath: "/pedidos-especiales", shouldReplace: true,
    });
    expect(resolveTiendaLocation("/conseguir", "?seccion=desconocida")).toMatchObject({
      page: "pedidos-especiales",
    });
    expect(resolveTiendaLocation("/te-lo-conseguimos", "")).toMatchObject({
      page: "pedidos-especiales",
    });
  });
});
