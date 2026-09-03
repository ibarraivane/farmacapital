const {
  esNombreTicketProveedor,
  tituloDesdeMeta,
  fichaCatalogoDesdeNadro,
  fichaListaParaAlta,
} = require("./fichaProveedor");

const antheliosNadro = {
  nombre: "BLOQ ANTHE UVAIR 50+ FLU INV 40ML",
  productName: "BLOQ ANTHE UVAIR 50+ FLU INV 40ML",
  marca: "FRABEL 2",
  brand: "FRABEL 2",
  ean: "3337875917810",
  description:
    "Muy alta protección UVA/UVB de uso diario, tan ligera como el aire. Protege del daño ambiental y contaminación, con 16horas de efecto antioxidante, 50FPS+, PA++++",
  metaTagDescription:
    "La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml - 3337875917810 - Cuidado Personal y belleza - Solares - Bloqueadores",
  linkText: "larocheposayantheliosuvairfps50protectorsolarligero40ml",
  categories: [
    "/Cuidado Personal y belleza/Solares/Bloqueadores/",
    "/Cuidado Personal y belleza/Solares/",
    "/Cuidado Personal y belleza/",
  ],
  imagenes: ["https://nadro.vtexassets.com/arquivos/ids/218211/3337875917810_01.jpg"],
  precioPublico: 391.29,
};

describe("ficha desde la página del proveedor", () => {
  test("el código del ticket Nadro no se usa como nombre de mostrador", () => {
    expect(esNombreTicketProveedor("BLOQ ANTHE UVAIR 50+ FLU INV 40ML")).toBe(true);
    expect(esNombreTicketProveedor("JBN GRISI CONCHA NACAR 125G")).toBe(true);
    expect(esNombreTicketProveedor("Adel 250 mg Suspensión 60 ml")).toBe(false);
  });

  test("el meta de Nadro suelta el título y descarta EAN y miga", () => {
    expect(
      tituloDesdeMeta(antheliosNadro.metaTagDescription)
    ).toBe("La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml");
  });

  test("Anthelios UV Air: marca La Roche, 40 ml, protector solar, no FRABEL", () => {
    const ficha = fichaCatalogoDesdeNadro(antheliosNadro);
    expect(ficha.nombre).toMatch(/La Roche-Posay Anthelios UV Air/i);
    expect(ficha.nombre).not.toMatch(/BLOQ ANTHE/i);
    expect(ficha.marca).toBe("La Roche-Posay");
    expect(ficha.presentacion).toBe("40 ml");
    expect(ficha.categoria).toBe("Cuidado personal");
    expect(ficha.subcategoria).toBe("Protector solar");
    expect(ficha.forma_farmaceutica).toBe("Fluido");
    expect(ficha.imagen_url).toContain("3337875917810");
    expect(ficha.nombre_ticket).toBe("BLOQ ANTHE UVAIR 50+ FLU INV 40ML");
    expect(fichaListaParaAlta(ficha)).toBe(true);
  });

  test("FRABEL + CeraVe no se etiqueta como La Roche", () => {
    const ficha = fichaCatalogoDesdeNadro({
      nombre: "GEL CERAVE LIMP CONTR IMPER 236ML",
      marca: "FRABEL 2",
      metaTagDescription:
        "CeraVe Gel Limpiador Contr Imperfecciones 236 ml - 3337875784054 - Cuidado Personal y belleza",
      categories: ["/Cuidado Personal y belleza/"],
    });
    expect(ficha.marca).toBe("CeraVe");
    expect(ficha.nombre).toMatch(/CeraVe/i);
  });

  test("sin meta y con nombre de mostrador se respeta la ficha", () => {
    const ficha = fichaCatalogoDesdeNadro({
      nombre: "Adel 250 mg Suspensión 60 ml",
      marca: "SENOSIAIN",
    });
    expect(ficha.nombre).toBe("Adel 250 mg Suspensión 60 ml");
    expect(ficha.marca).toBe("SENOSIAIN");
    expect(fichaListaParaAlta(ficha)).toBe(true);
  });

  test("si solo hay código de ticket, no está lista para alta", () => {
    expect(
      fichaListaParaAlta(
        fichaCatalogoDesdeNadro({
          nombre: "BLOQ ANTHE UVAIR 50+ FLU INV 40ML",
          marca: "FRABEL 2",
        })
      )
    ).toBe(false);
  });
});
