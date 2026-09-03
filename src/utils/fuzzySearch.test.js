import {
  inventarioProductMatchesBusqueda,
  inventarioSearchRelevanceRank,
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
    expect(tiendaSearchRelevanceRank(diapro, "pañal")).toBeLessThan(
      tiendaSearchRelevanceRank(affective, "pañal")
    );
    expect(tiendaProductMatchesBusqueda(tempra, "paracetamol")).toBe(true);
    expect(inventarioProductMatchesBusqueda(tempra, "paracetamol")).toBe(true);
    expect(tiendaProductMatchesBusqueda(paraGeneric, "tempra")).toBe(true);
    expect(tiendaSearchRelevanceRank(tempra, "tempra")).toBeLessThan(
      tiendaSearchRelevanceRank(paraGeneric, "tempra")
    );
  });
});
