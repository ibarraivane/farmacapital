import {
  PLACEHOLDER_FAHORRO_BYTES,
  PLACEHOLDER_FAHORRO_MD5,
  TEXTO_IMAGEN_PROXIMAMENTE,
  esPlaceholderImagenCompetencia,
  esUrlImagenCompetencia,
  esUrlImagenProveedor,
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

  test("bloquea Nadro, Levic/Visoti y copias distribuidor/nadro en Storage", () => {
    expect(esUrlImagenProveedor("https://nadro.vtexassets.com/arquivos/ids/1.jpg")).toBe(true);
    expect(esUrlImagenProveedor("https://i22.nadro.mx/arquivos/ids/1.jpg")).toBe(true);
    expect(esUrlImagenProveedor("https://visoti.mx/imagenes/Grande/MAV088.webp")).toBe(true);
    expect(
      esUrlImagenProveedor(
        "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/distribuidor/nadro-7501314701957.jpg",
      ),
    ).toBe(true);
    expect(urlImagenPublicaTienda("https://nadro.vtexassets.com/arquivos/ids/1.jpg")).toBe("");
    expect(urlImagenPublicaTienda("https://visoti.mx/imagenes/Grande/MAV088.webp")).toBe("");
  });

  test("deja pasar catalogo propio y packshots ajenos al mayoreo", () => {
    const propia = "https://www.farmacapital.mx/catalogo-propia/bioderma.jpg";
    expect(esUrlImagenCompetencia(propia)).toBe(false);
    expect(esUrlImagenProveedor(propia)).toBe(false);
    expect(urlImagenPublicaTienda(propia)).toBe(propia);
    const rappi = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/1.webp";
    expect(urlImagenPublicaTienda(rappi)).toBe(rappi);
    expect(TEXTO_IMAGEN_PROXIMAMENTE).toMatch(/próximamente/i);
  });

  test("detecta placeholder rosa A por md5 y por 500×500 chico", () => {
    expect(esPlaceholderImagenCompetencia({ md5: PLACEHOLDER_FAHORRO_MD5 })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: PLACEHOLDER_FAHORRO_BYTES })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: 8000, width: 500, height: 500 })).toBe(true);
    expect(esPlaceholderImagenCompetencia({ byteLength: 120000, width: 1200, height: 1200 })).toBe(false);
    expect(mensajeRechazoImagenCompetencia()).toMatch(/Del Ahorro/i);
  });
});
