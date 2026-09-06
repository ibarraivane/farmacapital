import {
  pageIdToTiendaPath,
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
    expect(pageIdToTiendaPath("conseguir", { search: "losartan" })).toBe("/conseguir?q=losartan");
  });

  test("aliases de flyer y te lo conseguimos", () => {
    expect(resolveTiendaPage("flyer")).toBe("tarjeta");
    expect(resolveTiendaPage("hola")).toBe("tarjeta");
    expect(resolveTiendaPage("te-lo-conseguimos")).toBe("conseguir");
    expect(tiendaPathnameToPageId("/tarjeta")).toBe("tarjeta");
    expect(tiendaPathnameToPageId("/conseguir")).toBe("conseguir");
  });
});
