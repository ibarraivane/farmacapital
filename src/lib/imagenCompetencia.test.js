import {
  PLACEHOLDER_FAHORRO_BYTES,
  PLACEHOLDER_FAHORRO_MD5,
  esPlaceholderImagenCompetencia,
  esUrlImagenCompetencia,
  mensajeRechazoImagenCompetencia,
  urlImagenPublicaTienda,
} from "./imagenCompetencia";

describe("imagenCompetencia", () => {
  test("bloquea hosts Fahorro", () => {
    expect(esUrlImagenCompetencia("https://www.fahorro.com/media/x.jpg")).toBe(true);
    expect(esUrlImagenCompetencia("https://production-media.fahorro.com/media/x.jpg")).toBe(true);
    expect(esUrlImagenCompetencia("https://cdn.fahorro.com/a.png")).toBe(true);
    expect(urlImagenPublicaTienda("https://www.fahorro.com/media/x.jpg")).toBe("");
  });

  test("deja pasar catalogo propio y Nadro", () => {
    const propia = "https://www.farmacapital.mx/catalogo-propia/bioderma.jpg";
    expect(esUrlImagenCompetencia(propia)).toBe(false);
    expect(urlImagenPublicaTienda(propia)).toBe(propia);
    expect(urlImagenPublicaTienda("https://nadro.vtexassets.com/arquivos/ids/1.jpg")).toContain("nadro");
  });

  test("detecta placeholder rosa A por md5 y por 500×500 chico", () => {
    expect(esPlaceholderImagenCompetencia({ md5: PLACEHOLDER_FAHORRO_MD5 })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: PLACEHOLDER_FAHORRO_BYTES })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: 8000, width: 500, height: 500 })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: 120000, width: 1200, height: 1200 })).toBe(false);
    expect(mensajeRechazoImagenCompetencia()).toMatch(/Del Ahorro/i);
  });
});
