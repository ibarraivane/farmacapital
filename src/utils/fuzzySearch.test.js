import {
  inventarioProductMatchesBusqueda,
  inventarioSearchRelevanceRank,
  isAffixedSubstanceCollision,
  tiendaProductMatchesBusqueda,
  tiendaSearchRelevanceRank,
} from "./fuzzySearch";

const tensolastic7 = {
  id: 1,
  activo: true,
  nombre: "Tensolastic Plus Venda Elasti",
  presentacion: "7 CM x 5 M",
  marca: "Protec",
  sku: "FC-48690909",
  codigo_barras: "7501048690909",
  descripcion: "Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827",
};

const loxcelGarbage = {
  id: 2,
  activo: true,
  nombre:
    "(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2",
  sku: "FC-24227339",
  codigo_barras: "7502224227339",
  descripcion: "Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827",
  presentacion: "C/1",
};

const centrum = {
  id: 3,
  activo: true,
  nombre: "Centrum Tab",
  presentacion: "",
  sku: "FC-65095718",
  codigo_barras: "7501065095718",
};

describe("catalog search dimensions", () => {
  test("paleta encuentra Broncolin y no se confunde con tableta", () => {
    const broncolin = {
      id: 702,
      nombre: "Broncolin Paleta",
      marca: "Broncolin",
      forma_farmaceutica: "Paleta",
      presentacion: "1 paleta 10 g",
    };
    const tableta = {
      id: 10,
      nombre: "Paracetamol 500 mg tabletas",
      marca: "Genérico",
      forma_farmaceutica: "Tabletas",
      principio_activo: "Paracetamol",
    };
    expect(tiendaProductMatchesBusqueda(broncolin, "paleta")).toBe(true);
    expect(tiendaProductMatchesBusqueda(broncolin, "paletas")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tableta, "paleta")).toBe(false);
    expect(tiendaSearchRelevanceRank(broncolin, "paleta")).toBeLessThan(
      tiendaSearchRelevanceRank(tableta, "paleta")
    );
  });

  test("Jaloma o agua solas encuentran el agua de rosas", () => {
    const aceite = {
      id: 520,
      nombre: "Aceite Bebé Jaloma Lavanda",
      marca: "Jaloma",
      principio_activo: "PARAFINA",
    };
    const agua = {
      id: 521,
      nombre: "Jaloma Agua De Rosas",
      marca: "Jaloma",
      principio_activo: "Agua de rosas",
    };
    expect(tiendaProductMatchesBusqueda(aceite, "jaloma")).toBe(true);
    expect(tiendaProductMatchesBusqueda(agua, "jaloma")).toBe(true);
    expect(tiendaProductMatchesBusqueda(agua, "agua")).toBe(true);
    expect(tiendaProductMatchesBusqueda(agua, "jaloma agua")).toBe(true);
    expect(tiendaProductMatchesBusqueda(aceite, "jaloma agua")).toBe(false);
    expect(tiendaSearchRelevanceRank(agua, "jaloma")).toBeLessThanOrEqual(
      tiendaSearchRelevanceRank(aceite, "jaloma")
    );
  });

  test("Treda no se confunde con crema", () => {
    const treda = { id: 501, nombre: "Treda Antidiarreico", marca: "Treda", principio_activo: "Neomicina + Caolín + Pectina" };
    const crema = { id: 502, nombre: "Colgate Max Clean", marca: "Colgate", forma_farmaceutica: "Crema", principio_activo: "Fluoruro de sodio" };
    expect(tiendaProductMatchesBusqueda(treda, "treda")).toBe(true);
    expect(tiendaProductMatchesBusqueda(crema, "treda")).toBe(false);
    expect(tiendaSearchRelevanceRank(treda, "treda")).toBeLessThan(tiendaSearchRelevanceRank(crema, "treda"));
  });

  test("un nombre largo se encuentra completo y conserva prioridad exacta", () => {
    const producto = {
      id: 503,
      nombre: "Levofloxacino 500 mg Caja con 7 tabletas beadvance",
      marca: "beadvance",
      principio_activo: "Levofloxacino",
      presentacion: "Caja con 7 tabletas",
      concentracion: "500 mg",
    };
    expect(tiendaProductMatchesBusqueda(producto, producto.nombre)).toBe(true);
    expect(tiendaSearchRelevanceRank(producto, producto.nombre)).toBe(0);
  });

  test("la normalización singular/plural no rebaja un nombre exacto", () => {
    const producto = { id: 504, nombre: "La Femme vitaminas menopausia C/30", marca: "La Femme" };
    expect(tiendaProductMatchesBusqueda(producto, producto.nombre)).toBe(true);
    expect(tiendaSearchRelevanceRank(producto, producto.nombre)).toBe(0);
  });

  test("Tensolastic 7 cm matches venda 7 cm", () => {
    expect(inventarioProductMatchesBusqueda(tensolastic7, "Tensolastic 7 cm")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tensolastic7, "Tensolastic 7 cm")).toBe(true);
  });

  test("OCR garbage with prices does not match Tensolastic 7 cm", () => {
    expect(inventarioProductMatchesBusqueda(loxcelGarbage, "Tensolastic 7 cm")).toBe(false);
  });

  test("descripcion OCR compartida no hace match en inventario", () => {
    expect(inventarioProductMatchesBusqueda(loxcelGarbage, "Tensolastic 7 cm")).toBe(false);
  });

  test("Centrum no matchea por substring cm", () => {
    expect(inventarioProductMatchesBusqueda(centrum, "Tensolastic 7 cm")).toBe(false);
  });

  test("Tensolastic 7 cm rankea antes que ruido", () => {
    expect(inventarioSearchRelevanceRank(tensolastic7, "Tensolastic 7 cm")).toBeLessThan(
      inventarioSearchRelevanceRank(loxcelGarbage, "Tensolastic 7 cm")
    );
  });

  test("busqueda por SKU sigue funcionando", () => {
    expect(inventarioProductMatchesBusqueda(tensolastic7, "FC-48690909")).toBe(true);
    expect(inventarioProductMatchesBusqueda(tensolastic7, "7501048690909")).toBe(true);
  });

  test("el codigo del archivo de mayoreo se encuentra aunque sea corto", () => {
    const acuts = {
      id: 9001,
      activo: true,
      nombre: "A-Cuts Artic Orange",
      marca: "Allmax",
      sku: "FC-08135297",
      notas: "Lista SKU origen: 6474",
      descripcion: "Bajo pedido · suplementosmayoreo · 6474",
    };
    const otro = {
      id: 9002,
      activo: true,
      nombre: "Amino Core",
      marca: "Allmax",
      sku: "FC-53228600",
      notas: "Lista SKU origen: 7341",
    };
    expect(inventarioProductMatchesBusqueda(acuts, "6474")).toBe(true);
    expect(inventarioProductMatchesBusqueda(acuts, "647")).toBe(false);
    expect(inventarioProductMatchesBusqueda(otro, "6474")).toBe(false);
    expect(inventarioProductMatchesBusqueda({
      id: 9003,
      nombre: "A-Cuts Blue Raspberry",
      sku: "FC-53226590",
      descripcion: "Bajo pedido · suplementosmayoreo · 8921",
    }, "8921")).toBe(true);
  });

  test("pañal no matchea lubricante íntimo por marca piel con piel", () => {
    const lubricante = {
      id: 99,
      activo: true,
      nombre: "Lubricante íntimo",
      marca: "Piel con Piel",
      categoria: "Higiene",
      sku: "FC-60101378",
      codigo_barras: "7506460101378",
    };
    const panal = {
      id: 100,
      activo: true,
      nombre: "Pañal Diapro Grande",
      categoria: "Higiene",
      sku: "FC-43475816",
      codigo_barras: "7501943475014",
    };
    expect(inventarioProductMatchesBusqueda(lubricante, "pañal")).toBe(false);
    expect(inventarioProductMatchesBusqueda(panal, "pañal")).toBe(true);
    expect(inventarioSearchRelevanceRank(panal, "pañal")).toBeLessThan(20);
  });

  test("suero encuentra Electrolit y también productos que sí dicen suero", () => {
    const electrolit = {
      id: 201,
      nombre: "Electrolit Uva 625 ml",
      marca: "Electrolit",
      categoria: "Hidratación",
      sku: "FC-EL-001",
    };
    const sueroGlu = {
      id: 202,
      nombre: "Suero Glucosado 5% 500 ml",
      marca: "Pisa",
      categoria: "Hidratación",
      sku: "FC-SG-001",
    };
    expect(tiendaProductMatchesBusqueda(electrolit, "suero")).toBe(true);
    expect(tiendaProductMatchesBusqueda(electrolit, "suero oral")).toBe(true);
    expect(tiendaProductMatchesBusqueda(sueroGlu, "suero")).toBe(true);
    expect(tiendaProductMatchesBusqueda(centrum, "suero")).toBe(false);
    expect(tiendaSearchRelevanceRank(sueroGlu, "suero")).toBeLessThan(
      tiendaSearchRelevanceRank(electrolit, "suero")
    );
  });

  test("Affective Cover Pro: marca, SKU y habla de mostrador", () => {
    const affective = {
      id: 301,
      activo: true,
      nombre: "Affective Cover Pro protector desechable unitalla C/16",
      marca: "Affective",
      presentacion: "Bolsa con 16 protectores 90 x 60 cm",
      forma_farmaceutica: "Protector desechable",
      categoria: "Higiene",
      sku: "FC-11700134",
      codigo_barras: "013117001341",
    };
    const diapro = {
      id: 302,
      activo: true,
      nombre: "Pañal Diapro Grande",
      marca: "Diapro",
      categoria: "Higiene",
      sku: "FC-43475816",
    };
    const solar = {
      id: 303,
      activo: true,
      nombre: "Nivea Sun protector solar FPS 50",
      marca: "Nivea",
      forma_farmaceutica: "Crema",
      categoria: "Cuidado personal",
      sku: "FC-SOL-001",
    };
    const tempra = {
      id: 304,
      activo: true,
      nombre: "Tempra 500 mg tabletas",
      marca: "Tempra",
      principio_activo: "Paracetamol",
      sku: "FC-TMP-001",
    };
    const paraGeneric = {
      id: 305,
      activo: true,
      nombre: "Paracetamol 500 mg",
      principio_activo: "Paracetamol",
      sku: "FC-PARA-001",
    };
    expect(tiendaProductMatchesBusqueda(affective, "affe")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "affective")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "protector")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "cover pro")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "FC-11700134")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "pañal")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "pañales")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "pañales para adultos")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "incontinencia")).toBe(true);
    expect(tiendaProductMatchesBusqueda(affective, "sabanilla")).toBe(true);
    expect(tiendaProductMatchesBusqueda(diapro, "pañal")).toBe(true);
    expect(tiendaProductMatchesBusqueda(diapro, "pañales para adultos")).toBe(true);
    expect(tiendaProductMatchesBusqueda(diapro, "sabanilla")).toBe(false);
    expect(tiendaProductMatchesBusqueda(diapro, "affective")).toBe(false);
    expect(tiendaProductMatchesBusqueda(solar, "pañal")).toBe(false);
    expect(tiendaProductMatchesBusqueda(solar, "protector")).toBe(true);
    expect(tiendaProductMatchesBusqueda(solar, "bloqueador")).toBe(true);
    expect(tiendaProductMatchesBusqueda(solar, "bloqueador solar")).toBe(true);
    expect(tiendaSearchRelevanceRank(diapro, "pañal")).toBeLessThan(
      tiendaSearchRelevanceRank(affective, "pañal")
    );
    expect(tiendaProductMatchesBusqueda(tempra, "paracetamol")).toBe(true);
    expect(tiendaProductMatchesBusqueda(paraGeneric, "tempra")).toBe(true);
    expect(tiendaSearchRelevanceRank(tempra, "tempra")).toBeLessThan(
      tiendaSearchRelevanceRank(paraGeneric, "tempra")
    );
  });

  test("bloqueador encuentra el protector solar aunque el SKU no diga bloqueador", () => {
    const fotosun = {
      id: 401,
      activo: true,
      nombre: "Fotosun UV100",
      marca: "Fotosun",
      presentacion: "125 ML",
      forma_farmaceutica: "Crema",
      categoria: "Cuidado personal",
      sku: "FC-00E8A9C7",
      codigo_barras: "7502253600486",
    };
    const lubriderm = {
      id: 402,
      activo: true,
      nombre: "Lubriderm Uv Fps15",
      marca: "Lubriderm",
      presentacion: "120 ML",
      forma_farmaceutica: "Crema",
      categoria: "Cuidado personal",
      sku: "FC-35469151",
      codigo_barras: "7702035469151",
    };
    const solsun = {
      id: 403,
      activo: true,
      nombre: "Sol Sun protector solar facial crema hidratacion profunda",
      marca: "Sol Sun",
      categoria: "Cuidado personal",
      sku: "FC-09749063",
      codigo_barras: "7502009749063",
    };
    const panty = {
      id: 404,
      activo: true,
      nombre: "Panty protector Saba largo 28",
      marca: "Saba",
      categoria: "Cuidado personal",
      sku: "FC-19068911",
    };
    const anthelios = {
      id: 405,
      activo: true,
      nombre: "La Roche Posay Anthelios UV Mune 400 FPS50",
      marca: "La Roche-Posay",
      presentacion: "50 ML",
      forma_farmaceutica: "Fluido",
      categoria: "Cuidado personal",
      sku: "FC-ANTHELIOS",
    };
    for (const q of ["bloqueador", "bloqueador solar", "protector solar"]) {
      expect(tiendaProductMatchesBusqueda(fotosun, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(fotosun, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(lubriderm, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(lubriderm, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(solsun, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(solsun, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(panty, q)).toBe(false);
      expect(inventarioProductMatchesBusqueda(panty, q)).toBe(false);
      expect(tiendaProductMatchesBusqueda(centrum, q)).toBe(false);
    }
    expect(tiendaProductMatchesBusqueda(fotosun, "pañal")).toBe(false);
    expect(tiendaProductMatchesBusqueda(panty, "protector")).toBe(true);
    expect(tiendaProductMatchesBusqueda(anthelios, "bloqueador")).toBe(true);
    expect(inventarioProductMatchesBusqueda(anthelios, "bloqueador")).toBe(true);
    expect(tiendaProductMatchesBusqueda(anthelios, "la roche")).toBe(true);
    expect(inventarioProductMatchesBusqueda(anthelios, "la roche")).toBe(true);
    expect(tiendaProductMatchesBusqueda(anthelios, "anthelios")).toBe(true);
    const ticketNadro = {
      id: 406,
      activo: true,
      nombre: "BLOQ ANTHE UVAIR 50+ FLU INV 40ML",
      marca: "FRABEL 2",
      presentacion: "40 ml",
      categoria: "Cuidado personal",
      subcategoria: "Protector solar",
      sku: "FC-75917810",
      codigo_barras: "3337875917810",
    };
    const uvAir = {
      id: 407,
      activo: true,
      nombre: "La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml",
      marca: "La Roche-Posay",
      presentacion: "40 ml",
      forma_farmaceutica: "Fluido",
      categoria: "Cuidado personal",
      subcategoria: "Protector solar",
      sku: "FC-75917810",
      codigo_barras: "3337875917810",
    };
    for (const q of ["la roch", "la roche", "anthelios", "bloqueador"]) {
      expect(tiendaProductMatchesBusqueda(ticketNadro, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(ticketNadro, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(uvAir, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(uvAir, q)).toBe(true);
    }
    expect(tiendaProductMatchesBusqueda(fotosun, "la roche")).toBe(false);
    expect(inventarioProductMatchesBusqueda(fotosun, "la roche")).toBe(false);
  });

  test("pegamento dental encuentra Corega y no se confunde con pasta ni parches", () => {
    const corega = {
      id: 501,
      activo: true,
      nombre: "Corega Ultra Sin Sabor 40 g",
      marca: "Corega",
      principio_activo: "Crema adhesiva para protesis dentales",
      categoria: "Cuidado personal",
      subcategoria: "Protesis dental / adhesivo",
      sku: "FC-09490651",
      codigo_barras: "7896009490651",
    };
    const fixodent = {
      id: 502,
      activo: true,
      nombre: "Fixodent Original crema dental 40 mL",
      marca: "Fixodent",
      categoria: "Cuidado personal",
      sku: "FC-74305449",
      codigo_barras: "5000174305449",
    };
    const colgate = {
      id: 503,
      activo: true,
      nombre: "Colgate Total 65 mL",
      marca: "Colgate",
      categoria: "Cuidado personal",
      sku: "FC-66534951",
    };
    const parches = {
      id: 504,
      activo: true,
      nombre: "Parches adhesivos Alfa Med 2 tamaños blanco",
      marca: "Alfa Med",
      categoria: "Botiquín",
      sku: "FC-14279552",
    };
    const ibuprofeno = {
      id: 505,
      activo: true,
      nombre: "Ibuprofeno 400 mg",
      marca: "Genérico",
      principio_activo: "Ibuprofeno",
      subcategoria: "Analgésico",
    };
    const frases = [
      "pegamento",
      "pegamento dental",
      "pegamento para dentadura",
      "adhesivo dental",
      "adhesivo para dentadura",
      "dentadura",
      "prótesis dental",
    ];
    for (const q of frases) {
      expect(tiendaProductMatchesBusqueda(corega, q)).toBe(true);
      expect(inventarioProductMatchesBusqueda(corega, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(fixodent, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(colgate, q)).toBe(false);
      expect(tiendaProductMatchesBusqueda(parches, q)).toBe(false);
    }
    expect(tiendaProductMatchesBusqueda({ ...corega, principio_activo: "", subcategoria: "" }, "pegamento dental")).toBe(true);
    expect(tiendaProductMatchesBusqueda(corega, "corega")).toBe(true);
    expect(tiendaProductMatchesBusqueda(ibuprofeno, "dolor dental")).toBe(true);
    expect(tiendaProductMatchesBusqueda(corega, "dolor dental")).toBe(false);
    expect(tiendaSearchRelevanceRank(corega, "pegamento dental")).toBeLessThan(60);
  });

  test("otras frases de mostrador encuentran la marca aunque el SKU no las diga", () => {
    const sensodyne = {
      id: 601,
      nombre: "Pasta Dent Sensodyne Original",
      marca: "Sensodyne",
      categoria: "Cuidado personal",
    };
    const colgatePasta = {
      id: 602,
      nombre: "Colgate Triple Acc Original",
      marca: "Colgate",
      categoria: "Cuidado personal",
    };
    const cepillo = {
      id: 603,
      nombre: "Cepillo Colgate Premier Clean",
      marca: "Colgate",
      categoria: "Cuidado personal",
    };
    const saba = {
      id: 604,
      nombre: "Saba buenas noches",
      marca: "Saba",
      categoria: "Higiene",
    };
    const huggies = {
      id: 605,
      nombre: "Toallitas húmedas Huggies",
      marca: "Huggies",
      categoria: "Higiene",
    };
    const hisopos = {
      id: 606,
      nombre: "Jaloma Kiuts hisopos biodegradables C/100",
      marca: "Jaloma",
      categoria: "Botiquín",
    };
    const nan = {
      id: 607,
      nombre: "Leche en polvo NAN Optimal Pro 1/ 0 a 6 M",
      marca: "Nestle",
      categoria: "Higiene",
    };
    const sildenafil = {
      id: 608,
      nombre: "Sildenafil 4 Tab 100 Mg",
      principio_activo: "Sildenafil",
    };
    const broncolinAzul = {
      id: 609,
      nombre: "Broncolin Etiqueta Azul jarabe oral 140 ml",
      marca: "Broncolin",
    };
    expect(tiendaProductMatchesBusqueda(sensodyne, "pasta de dientes")).toBe(true);
    expect(tiendaProductMatchesBusqueda(colgatePasta, "pasta dental")).toBe(true);
    expect(tiendaProductMatchesBusqueda(cepillo, "pasta de dientes")).toBe(false);
    expect(tiendaProductMatchesBusqueda(saba, "toallas sanitarias")).toBe(true);
    expect(tiendaProductMatchesBusqueda(saba, "toallas femeninas")).toBe(true);
    expect(tiendaProductMatchesBusqueda(huggies, "toallas sanitarias")).toBe(false);
    expect(tiendaProductMatchesBusqueda(hisopos, "cotonetes")).toBe(true);
    expect(inventarioProductMatchesBusqueda(hisopos, "cotonetes")).toBe(true);
    expect(tiendaProductMatchesBusqueda(nan, "formula")).toBe(true);
    expect(tiendaProductMatchesBusqueda(nan, "leche de fórmula")).toBe(true);
    expect(tiendaProductMatchesBusqueda(sildenafil, "pastilla azul")).toBe(true);
    expect(tiendaProductMatchesBusqueda(sildenafil, "viagra")).toBe(true);
    expect(tiendaProductMatchesBusqueda(broncolinAzul, "pastilla azul")).toBe(false);
  });

  test("terbutan (como lo dicen en mostrador) encuentra Tervutan oxitetraciclina", () => {
    const tervutan = {
      id: 710,
      nombre: "Tervutan Oxitetraciclina 500 mg 16 cápsulas",
      marca: "Tervutan",
      tipo: "generico",
      principio_activo: "Oxitetraciclina",
    };
    expect(tiendaProductMatchesBusqueda(tervutan, "terbutan")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tervutan, "tervutan")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tervutan, "oxitetraciclina")).toBe(true);
  });

  test("kenciclen encuentra doxiciclina Kenciclen", () => {
    const kenciclen = {
      id: 711,
      nombre: "Kenciclen Doxiciclina 100 mg 10 cápsulas",
      marca: "Kenciclen",
      tipo: "generico",
      principio_activo: "Doxiciclina",
    };
    expect(tiendaProductMatchesBusqueda(kenciclen, "kenciclen")).toBe(true);
    expect(tiendaProductMatchesBusqueda(kenciclen, "doxiciclina")).toBe(true);
  });
});

describe("prefijo de la misma molécula", () => {
  const amsa = {
    id: 801,
    activo: true,
    nombre: "Levofloxacino",
    marca: "AMSA",
    tipo: "generico",
    principio_activo: "LEVOFLOXACINO",
    concentracion: "500 MG",
    presentacion: "7 TABLETAS",
    forma_farmaceutica: "TABLETAS",
    precio: 31,
  };
  const beadvance = {
    id: 802,
    activo: true,
    nombre: "Levofloxacino 500 mg Caja con 7 tabletas beadvance",
    marca: "beadvance",
    tipo: "generico",
    principio_activo: "Levofloxacino",
    concentracion: "500 mg",
    presentacion: "Caja con 7 tabletas",
    forma_farmaceutica: "Tableta",
    precio: 31,
  };
  const cina = {
    id: 803,
    activo: true,
    nombre: "Cina 750 mg Caja con 7 tabletas Landsteiner",
    marca: "Landsteiner",
    tipo: "generico",
    principio_activo: "Levofloxacino 750 mg",
    concentracion: "750 mg",
    presentacion: "Caja con 7 tabletas",
    forma_farmaceutica: "Tableta",
    precio: 47,
  };
  const desloro = {
    id: 804,
    activo: true,
    nombre: "Histapharm 5 mg",
    marca: "Quimpharma",
    principio_activo: "Desloratadina",
  };

  test("prefijo de la misma palabra no es otra molécula; desloratadina sí", () => {
    expect(isAffixedSubstanceCollision("levofloxaci", "levofloxacino")).toBe(false);
    expect(isAffixedSubstanceCollision("levofloxacino", "levofloxaci")).toBe(false);
    expect(isAffixedSubstanceCollision("loratadina", "desloratadina")).toBe(true);
    expect(isAffixedSubstanceCollision("desloratadina", "loratadina")).toBe(true);
  });

  test("levofloxaci y levofloxacino encuentran las tres fichas, no otra molécula", () => {
    for (const q of ["Levofloxaci", "Levofloxacino", "levofloxacino"]) {
      expect(tiendaProductMatchesBusqueda(amsa, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(beadvance, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(cina, q)).toBe(true);
      expect(tiendaProductMatchesBusqueda(desloro, q)).toBe(false);
    }
    expect(tiendaProductMatchesBusqueda(amsa, "loratadina")).toBe(false);
  });

  test("el nombre corto Levofloxacino no pierde contra el nombre largo al rankear", () => {
    expect(tiendaSearchRelevanceRank(amsa, "Levofloxaci")).toBeLessThanOrEqual(
      tiendaSearchRelevanceRank(cina, "Levofloxaci")
    );
    expect(tiendaSearchRelevanceRank(amsa, "Levofloxacino")).toBeLessThanOrEqual(
      tiendaSearchRelevanceRank(beadvance, "Levofloxacino")
    );
  });
});

describe("loratadina vs marcas y desloratadina", () => {
  const loratadina = {
    id: 201,
    activo: true,
    nombre: "Loratadina 10 mg",
    marca: "Genérico",
    principio_activo: "Loratadina",
  };
  const clarityne = {
    id: 202,
    activo: true,
    nombre: "Clarityne 10 mg tabletas",
    marca: "Clarityne",
    principio_activo: "Loratadina",
  };
  const clarityneSinPa = {
    id: 203,
    activo: true,
    nombre: "Clarityne",
    marca: "Clarityne",
    principio_activo: "",
  };
  const combinacion = {
    id: 204,
    activo: true,
    nombre: "Laritol EX",
    marca: "Maver",
    principio_activo: "Loratadina / Ambroxol",
  };
  const desloro = {
    id: 205,
    activo: true,
    nombre: "Histapharm 5 mg",
    marca: "Quimpharma",
    principio_activo: "Desloratadina",
  };

  test("loratadina encuentra genérico, Clarityne y combinación; no desloratadina", () => {
    expect(tiendaProductMatchesBusqueda(loratadina, "loratadina")).toBe(true);
    expect(tiendaProductMatchesBusqueda(clarityne, "loratadina")).toBe(true);
    expect(tiendaProductMatchesBusqueda(clarityneSinPa, "loratadina")).toBe(true);
    expect(tiendaProductMatchesBusqueda(combinacion, "loratadina")).toBe(true);
    expect(tiendaProductMatchesBusqueda(desloro, "loratadina")).toBe(false);
  });
});
describe("vernáculo bidireccional fármaco", () => {
  test("sildenafil encuentra viagra y loratadina encuentra Clarityne sin PA", () => {
    const viagra = { id: 301, activo: true, nombre: "Viagra 50 mg", marca: "Viagra", principio_activo: "Sildenafil" };
    const gen = { id: 302, activo: true, nombre: "Sildenafil 50 mg", marca: "Genérico", principio_activo: "Sildenafil" };
    const clarityne = { id: 303, activo: true, nombre: "Clarityne", marca: "Clarityne", principio_activo: "" };
    expect(tiendaProductMatchesBusqueda(viagra, "sildenafil")).toBe(true);
    expect(tiendaProductMatchesBusqueda(gen, "viagra")).toBe(true);
    expect(tiendaProductMatchesBusqueda(clarityne, "loratadina")).toBe(true);
  });
});

describe("ficha partida: búsqueda no depende de meter todo en el nombre", () => {
  const ibuprofenoCorto = {
    id: 801,
    activo: true,
    nombre: "Ibuprofeno 400 mg",
    marca: "Genérico",
    principio_activo: "Ibuprofeno",
    presentacion: "20 tabletas",
    concentracion: "400 mg",
    forma_farmaceutica: "Tabletas",
  };
  const niveaGel = {
    id: 802,
    activo: true,
    nombre: "Gel facial hidratante hialurónico",
    marca: "Nivea",
    presentacion: "200 ml",
    forma_farmaceutica: "Gel",
  };

  test("ibuprofeno 20 tabletas pega aunque el conteo esté solo en presentación", () => {
    expect(tiendaProductMatchesBusqueda(ibuprofenoCorto, "ibuprofeno 20 tabletas")).toBe(true);
    expect(tiendaProductMatchesBusqueda(ibuprofenoCorto, "20 tabletas")).toBe(true);
    expect(tiendaSearchRelevanceRank(ibuprofenoCorto, "ibuprofeno 20 tabletas")).toBeLessThan(60);
  });

  test("paracetamol 500 mg encuentra por dosis (nombre o concentración)", () => {
    const para500 = {
      id: 810,
      activo: true,
      nombre: "Paracetamol",
      marca: "Genérico",
      principio_activo: "Paracetamol",
      concentracion: "500 mg",
      presentacion: "20 tabletas",
      forma_farmaceutica: "Tabletas",
    };
    const para750 = {
      id: 811,
      activo: true,
      nombre: "Paracetamol",
      marca: "Genérico",
      principio_activo: "Paracetamol",
      concentracion: "750 mg",
      presentacion: "10 tabletas",
      forma_farmaceutica: "Tabletas",
    };
    const tempraName = {
      id: 812,
      activo: true,
      nombre: "Tempra 500 mg tabletas",
      marca: "Tempra",
      principio_activo: "Paracetamol",
    };
    expect(tiendaProductMatchesBusqueda(para500, "paracetamol 500")).toBe(true);
    expect(tiendaProductMatchesBusqueda(para500, "paracetamol 500 mg")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tempraName, "paracetamol 500 mg")).toBe(true);
    expect(tiendaProductMatchesBusqueda(para750, "paracetamol 500")).toBe(false);
    expect(tiendaProductMatchesBusqueda(para750, "paracetamol 500 mg")).toBe(false);
    expect(tiendaSearchRelevanceRank(para500, "paracetamol 500 mg")).toBeLessThan(
      tiendaSearchRelevanceRank(para750, "paracetamol 500 mg")
    );
  });

  test("nivea pega por marca aunque el nombre no la repita", () => {
    expect(tiendaProductMatchesBusqueda(niveaGel, "nivea")).toBe(true);
    expect(tiendaSearchRelevanceRank(niveaGel, "nivea")).toBeLessThan(
      tiendaSearchRelevanceRank(ibuprofenoCorto, "nivea")
    );
  });

  test("clarityne y loratadina siguen siendo bidireccionales", () => {
    const clarityne = { id: 803, activo: true, nombre: "Clarityne", marca: "Clarityne", principio_activo: "" };
    const loro = {
      id: 804,
      activo: true,
      nombre: "Loratadina 10 mg",
      marca: "Genérico",
      principio_activo: "Loratadina",
      presentacion: "20 tabletas",
    };
    expect(tiendaProductMatchesBusqueda(clarityne, "loratadina")).toBe(true);
    expect(tiendaProductMatchesBusqueda(loro, "clarityne")).toBe(true);
  });
});
