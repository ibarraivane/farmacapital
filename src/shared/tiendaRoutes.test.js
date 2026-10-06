import {
  pageIdToTiendaPath,
  productIdParaHistorialTienda,
  resolveTiendaPage,
  seccionVitrinaFromPath,
  tiendaPathnameToPageId,
  tiendaQueryFromSearch,
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
    expect(tiendaPathnameToPageId("/esta-ruta-no-existe")).toBe("notfound");
    expect(pageIdToTiendaPath("notfound")).toBe("/404");
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
    expect(pageIdToTiendaPath("catalogo", { search: "paracetamo" })).toBe("/catalogo?q=paracetamo");
    expect(tiendaQueryFromSearch("?q=omeprazol")).toBe("omeprazol");
  });

  test("slugs de vitrina y los viejos abren el catálogo en la sección nueva", () => {
    expect(tiendaPathnameToPageId("/medicamentos")).toBe("catalogo");
    expect(seccionVitrinaFromPath("/nutricion")).toBe("Nutrición deportiva");
    expect(seccionVitrinaFromPath("/suplementos")).toBe("Nutrición deportiva");
    expect(pageIdToTiendaPath("catalogo", { seccion: "Nutrición deportiva" })).toBe("/nutricion-deportiva");
    expect(pageIdToTiendaPath("catalogo", { seccion: seccionVitrinaFromPath("/dermocosmeticos") })).toBe("/dermocosmetica");
    expect(seccionVitrinaFromPath("/farmacia")).toBe("");
    expect(tiendaPathnameToPageId("/catalogo")).toBe("catalogo");
  });

  test("reescribir historial de detalle conserva ?id= si no se pasa productId", () => {
    expect(productIdParaHistorialTienda("detalle", "", "?id=12345")).toBe("12345");
    expect(productIdParaHistorialTienda("detalle", "99", "?id=12345")).toBe("99");
    expect(productIdParaHistorialTienda("detalle", "", "")).toBe("");
    expect(productIdParaHistorialTienda("catalogo", "", "?id=12345")).toBe("");
    expect(pageIdToTiendaPath("detalle", {
      productId: productIdParaHistorialTienda("detalle", "", "?id=abc-1"),
    })).toBe("/producto?id=abc-1");
    expect(pageIdToTiendaPath("detalle", {
      productId: productIdParaHistorialTienda("detalle", "", ""),
    })).toBe("/producto");
  });

  test("aliases de flyer y te lo conseguimos", () => {
    expect(resolveTiendaPage("flyer")).toBe("tarjeta");
    expect(resolveTiendaPage("hola")).toBe("tarjeta");
    expect(resolveTiendaPage("te-lo-conseguimos")).toBe("conseguir");
    expect(tiendaPathnameToPageId("/tarjeta")).toBe("tarjeta");
    expect(tiendaPathnameToPageId("/conseguir")).toBe("conseguir");
    expect(tiendaPathnameToPageId("/pagar")).toBe("pagar");
    expect(pageIdToTiendaPath("pagar")).toBe("/pagar");
    expect(resolveTiendaPage("pago")).toBe("checkout");
  });
});
