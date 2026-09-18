import { claveSustancia, clasificarRelacionProducto, coincideConsultaDirecta, empaqueComparable, etiquetaTipoProducto, grupoOpcionesRelacionadas, grupoEquivalentesDeBusqueda } from "./equivalentesPos";

const treda = { id: 1, nombre: "Treda antidiarreico C/20", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 189, activo: true };
const nineka = { id: 2, nombre: "Nineka 20 tabletas", marca: "Nineka", tipo: "generico", principio_activo: "Neomicina / Caolín y Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 61, activo: true };
const nineka10 = { ...nineka, id: 3, presentacion: "C/10", precio: 35 };
const suspension = { id: 4, nombre: "Nineka suspensión 75 mL", marca: "Nineka", tipo: "generico", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "Frasco 75 mL", forma_farmaceutica: "Suspensión", concentracion: "500/36/35 mg/5 mL", precio: 38, activo: true };
const catalogo = [suspension, nineka10, nineka, treda];

describe("claveSustancia", () => {
  it("junta la misma sustancia escrita distinto sin mezclar otra combinación", () => {
    expect(claveSustancia(treda)).toBe("caolin+neomicina+pectina");
    expect(claveSustancia(treda)).toBe(claveSustancia(nineka));
    expect(claveSustancia({ principio_activo: "Amoxicilina" })).not.toBe(claveSustancia({ principio_activo: "Amoxicilina / Ácido clavulánico" }));
  });

  it("rechaza rubros que no son sustancias", () => {
    expect(claveSustancia({ principio_activo: "Surfactantes fórmula capilar" })).toBe("");
    expect(claveSustancia(null)).toBe("");
  });
});

describe("clasificación farmacéutica", () => {
  it("7 tabletas y caja con 7 tabletas son el mismo empaque", () => {
    const amsa = { nombre: "Levofloxacino", presentacion: "7 TABLETAS", forma_farmaceutica: "TABLETAS", concentracion: "500 MG", principio_activo: "LEVOFLOXACINO" };
    const bea = { nombre: "Levofloxacino 500 mg Caja con 7 tabletas beadvance", presentacion: "Caja con 7 tabletas", forma_farmaceutica: "Tableta", concentracion: "500 mg", principio_activo: "Levofloxacino" };
    const cina = { nombre: "Cina 750 mg", presentacion: "Caja con 7 tabletas", forma_farmaceutica: "Tableta", concentracion: "750 mg", principio_activo: "Levofloxacino 750 mg" };
    expect(empaqueComparable(amsa)).toBe(empaqueComparable(bea));
    expect(clasificarRelacionProducto(bea, amsa)).toBe("misma_configuracion");
    expect(clasificarRelacionProducto(cina, amsa)).toBe("otra_forma");
  });

  it("separa configuración comparable, contenido distinto y otra forma", () => {
    expect(clasificarRelacionProducto(nineka, treda)).toBe("misma_configuracion");
    expect(clasificarRelacionProducto(nineka10, treda)).toBe("otro_contenido");
    expect(clasificarRelacionProducto(suspension, treda)).toBe("otra_forma");
  });

  it("no inventa Patente o Genérico cuando tipo está vacío o es inconsistente", () => {
    expect(etiquetaTipoProducto(treda)).toBe("Patente");
    expect(etiquetaTipoProducto(nineka)).toBe("Genérico");
    expect(etiquetaTipoProducto({ nombre: "Treda", marca: "Treda" })).toBe("");
    expect(etiquetaTipoProducto({ tipo: "otro" })).toBe("");
  });
});

describe("grupoOpcionesRelacionadas", () => {
  it("mantiene un producto por tarjeta y ordena la marca buscada primero", () => {
    const grupo = grupoOpcionesRelacionadas(catalogo, treda, "Treda");
    expect(grupo.total).toBe(4);
    expect(grupo.coincidenciasDirectas.map((p) => p.id)).toEqual([1]);
    expect(grupo.mismaConfiguracion.map((p) => p.id)).toEqual([2]);
    expect(grupo.otroContenido.map((p) => p.id)).toEqual([3]);
    expect(grupo.otrasPresentaciones.map((p) => p.id)).toEqual([4]);
  });
});

describe("grupoEquivalentesDeBusqueda", () => {
  it("activa por sustancia clara y tolera neomicida", () => {
    expect(grupoEquivalentesDeBusqueda(catalogo, [treda, nineka], "neomicina caolin pectina")?.total).toBe(4);
    expect(grupoEquivalentesDeBusqueda(catalogo, [treda, nineka], "neomicida")?.total).toBe(4);
  });

  it("no activa para consultas cortas o ambiguas", () => {
    expect(grupoEquivalentesDeBusqueda(catalogo, [treda], "tre")).toBeNull();
    expect(grupoEquivalentesDeBusqueda(catalogo, [treda], "pastillas")).toBeNull();
    expect(grupoEquivalentesDeBusqueda(catalogo, [], "neomicina")).toBeNull();
  });

  it("una marca directa gobierna el tablero aunque haya más falsos candidatos", () => {
    const dentales = [1, 2, 3, 4, 5].map((id) => ({
      id: 100 + id,
      nombre: id === 1 ? "Colgate Max Clean Frescura y Limpieza" : `Crema dental ${id}`,
      marca: id === 1 ? "Colgate" : "Sensodyne",
      principio_activo: "Fluoruro de sodio",
      forma_farmaceutica: "Crema",
      activo: true,
    }));
    const resultadosConRuido = [treda, ...dentales, nineka];
    const grupo = grupoEquivalentesDeBusqueda([...catalogo, ...dentales], resultadosConRuido, "treda");
    expect(grupo?.clave).toBe("caolin+neomicina+pectina");
    expect(grupo?.coincidenciasDirectas[0].id).toBe(treda.id);
  });

  it("una coincidencia directa sin alternativas no muestra un grupo ajeno", () => {
    const unico = { id: 700, nombre: "Producto Único", marca: "Único", principio_activo: "Sustancia exclusiva", activo: true };
    const ruido = [
      { id: 701, nombre: "Crema A", principio_activo: "Fluoruro de sodio", activo: true },
      { id: 702, nombre: "Crema B", principio_activo: "Fluoruro de sodio", activo: true },
    ];
    expect(grupoEquivalentesDeBusqueda([unico, ...ruido], [unico, ...ruido], "Producto Único")).toBeNull();
  });

  it("un prefijo de sustancia no se queda con el SKU que empieza igual", () => {
    const polimixi = {
      id: 800,
      nombre: "Neomici Polimixi B Gramicidi 1 Sol",
      marca: "Exakta",
      principio_activo: "Neomicina / Polimixina B / Gramicidina",
      forma_farmaceutica: "Solución",
      activo: true,
    };
    const resultados = [polimixi, treda, nineka];
    const grupo = grupoEquivalentesDeBusqueda([polimixi, ...catalogo], resultados, "neomici");
    expect(grupo?.clave).toBe("caolin+neomicina+pectina");
    expect(grupo?.total).toBe(4);
  });

  it("paleta no abre un tablero de tabletas", () => {
    const broncolin = {
      id: 702,
      nombre: "Broncolin Paleta",
      marca: "Broncolin",
      tipo: "marca",
      forma_farmaceutica: "Paleta",
      activo: true,
    };
    const ruido = [
      { id: 10, nombre: "Paracetamol tabletas", principio_activo: "Paracetamol", forma_farmaceutica: "Tabletas", activo: true },
      { id: 11, nombre: "Tempra tabletas", principio_activo: "Paracetamol", forma_farmaceutica: "Tabletas", activo: true },
    ];
    expect(coincideConsultaDirecta(broncolin, "paleta")).toBe(true);
    expect(grupoEquivalentesDeBusqueda([broncolin, ...ruido], [broncolin, ...ruido], "paleta")).toBeNull();
  });

  it("Jaloma no se colapsa a parafina: aceite y agua salen en la lista normal", () => {
    const aceiteLavanda = {
      id: 1001,
      nombre: "Aceite Bebé Jaloma Lavanda",
      marca: "Jaloma",
      tipo: "marca",
      principio_activo: "PARAFINA",
      forma_farmaceutica: "Aceite",
      precio: 26,
      activo: true,
    };
    const aceiteManzanilla = {
      id: 1002,
      nombre: "Aceite Bebé Jaloma Manzanilla Y Caléndula",
      marca: "Jaloma",
      tipo: "marca",
      principio_activo: "parafina",
      forma_farmaceutica: "Aceite",
      precio: 30,
      activo: true,
    };
    const aguaRosas = {
      id: 1003,
      nombre: "Jaloma Agua De Rosas",
      marca: "Jaloma",
      tipo: "marca",
      principio_activo: "Agua de rosas",
      forma_farmaceutica: "Solución",
      precio: 24,
      activo: true,
    };
    const aguaArroz = {
      id: 1004,
      nombre: "Jaloma Agua De Arroz",
      marca: "Jaloma",
      tipo: "generico",
      principio_activo: "",
      forma_farmaceutica: "Solución",
      precio: 60,
      activo: true,
    };
    const catalogoJaloma = [aceiteLavanda, aceiteManzanilla, aguaRosas, aguaArroz];
    expect(coincideConsultaDirecta(aceiteLavanda, "jaloma")).toBe(true);
    expect(coincideConsultaDirecta(aguaRosas, "jaloma")).toBe(true);
    expect(coincideConsultaDirecta(aguaArroz, "jaloma")).toBe(true);
    expect(grupoEquivalentesDeBusqueda(catalogoJaloma, catalogoJaloma, "jaloma")).toBeNull();
    expect(grupoEquivalentesDeBusqueda(catalogoJaloma, [aguaRosas, aguaArroz], "jaloma agua")).toBeNull();
  });

  it("si busca Afrin, todas las Afrin van arriba aunque cambie la presentación", () => {
    const adulto = { id: 901, nombre: "Afrin Adulto Spray", marca: "Afrin", tipo: "marca", principio_activo: "Oximetazolina", forma_farmaceutica: "Spray", concentracion: "0.05%", presentacion: "20 mL", precio: 120, activo: true };
    const nodrip = { id: 902, nombre: "Afrin No Drip Solución Nasal", marca: "Afrin", tipo: "marca", principio_activo: "Oximetazolina", forma_farmaceutica: "Solución", concentracion: "0.05%", presentacion: "15 mL", precio: 140, activo: true };
    const generico = { id: 903, nombre: "Virindrez Adulto", marca: "Virindrez", tipo: "generico", principio_activo: "Oximetazolina", forma_farmaceutica: "Spray", concentracion: "0.05%", presentacion: "20 mL", precio: 55, activo: true };
    const grupo = grupoEquivalentesDeBusqueda([adulto, nodrip, generico], [adulto, nodrip, generico], "afrin");
    expect(grupo.coincidenciasDirectas.map((p) => p.id).sort()).toEqual([901, 902]);
    expect(grupo.mismaConfiguracion.map((p) => p.id)).toEqual([903]);
    expect(coincideConsultaDirecta(nodrip, "afrin")).toBe(true);
    expect(coincideConsultaDirecta({ nombre: "Neomici Polimixi", marca: "Exakta", tipo: "generico" }, "neomici")).toBe(false);
  });

  it("arnica no reduce a 2 pomadas: árnica / árnica montana / homeopático son familias distintas en catálogo", () => {
    const pomada = {
      id: 1,
      nombre: "Pomada De Árnica Tarro",
      marca: "Mercurio",
      tipo: "marca",
      principio_activo: "Árnica",
      forma_farmaceutica: "Pomada",
      presentacion: "Tarro 50 g",
      precio: 17,
      activo: true,
    };
    const parche = {
      id: 2,
      nombre: "Arnica León Parche",
      marca: "Curitas",
      tipo: "generico",
      principio_activo: "Arnica",
      forma_farmaceutica: "Parche",
      presentacion: "1 parche",
      precio: 95,
      activo: true,
    };
    const untar = {
      id: 3,
      nombre: "Mercurio Arnica Untar",
      marca: "Mercurio",
      tipo: "marca",
      principio_activo: "Arnica montana",
      forma_farmaceutica: "Ungüento",
      presentacion: "C/25",
      precio: 12,
      activo: true,
    };
    const tomar = {
      id: 4,
      nombre: "Mercurio Arnica Tomar",
      marca: "Mercurio",
      tipo: "marca",
      principio_activo: "Arnica montana",
      forma_farmaceutica: "Gotas",
      presentacion: "C/25",
      precio: 12,
      activo: true,
    };
    const flor = {
      id: 5,
      nombre: "Mercurio Flor De Arnica",
      marca: "Mercurio",
      tipo: "marca",
      principio_activo: "Producto homeopatico / natural",
      forma_farmaceutica: "Globulos",
      presentacion: "C/50",
      precio: 88,
      activo: true,
    };
    const resultados = [pomada, parche, untar, tomar, flor];
    // Buscar "arnica" debe traer árnica, árnica montana y el homeopático por nombre.
    const grupo = grupoEquivalentesDeBusqueda(resultados, resultados, "arnica");
    expect(grupo).not.toBeNull();
    const ids = [
      ...grupo.coincidenciasDirectas,
      ...grupo.mismaConfiguracion,
      ...grupo.otroContenido,
      ...grupo.otrasPresentaciones,
    ].map((p) => p.id).sort();
    expect(ids).toEqual([1, 2, 3, 4, 5]);
  });

  it("loratadina trae genéricos, combinaciones y marca Clarityne, no desloratadina", () => {
    const generico = {
      id: 1,
      nombre: "Loratadina 10 mg",
      marca: "Genérico",
      tipo: "generico",
      principio_activo: "Loratadina",
      forma_farmaceutica: "Tabletas",
      presentacion: "C/10",
      precio: 25,
      activo: true,
    };
    const clarityne = {
      id: 2,
      nombre: "Clarityne 10 mg",
      marca: "Clarityne",
      tipo: "marca",
      principio_activo: "Loratadina",
      forma_farmaceutica: "Tabletas",
      presentacion: "C/10",
      precio: 95,
      activo: true,
    };
    const laritolEx = {
      id: 3,
      nombre: "Laritol EX",
      marca: "Maver",
      tipo: "marca",
      principio_activo: "Loratadina / Ambroxol",
      forma_farmaceutica: "Jarabe",
      presentacion: "120 mL",
      precio: 31,
      activo: true,
    };
    const desloro = {
      id: 4,
      nombre: "Histapharm 5 mg",
      marca: "Quimpharma",
      tipo: "generico",
      principio_activo: "Desloratadina",
      forma_farmaceutica: "Tabletas",
      presentacion: "C/10",
      precio: 36,
      activo: true,
    };
    const catalogo = [generico, clarityne, laritolEx, desloro];
    const resultados = [generico, clarityne, laritolEx]; // desloro ya no debe entrar por substring
    const grupo = grupoEquivalentesDeBusqueda(catalogo, resultados, "loratadina");
    expect(grupo).not.toBeNull();
    const ids = [
      ...grupo.coincidenciasDirectas,
      ...grupo.mismaConfiguracion,
      ...grupo.otroContenido,
      ...grupo.otrasPresentaciones,
    ].map((p) => p.id).sort();
    expect(ids).toEqual([1, 2, 3]);
    expect(ids).not.toContain(4);
    expect(claveSustancia(laritolEx)).toBe("ambroxol+loratadina");
  });

  it("familias grandes se truncan pero no tumbaron el tablero (todas las búsquedas)", () => {
    const ancla = {
      id: 1,
      nombre: "Paracetamol 500 mg",
      marca: "Genérico",
      tipo: "generico",
      principio_activo: "Paracetamol",
      forma_farmaceutica: "Tabletas",
      presentacion: "C/10",
      precio: 20,
      activo: true,
    };
    const catalogo = [ancla];
    for (let i = 2; i <= 50; i += 1) {
      catalogo.push({
        ...ancla,
        id: i,
        nombre: `Paracetamol marca ${i}`,
        marca: `Marca${i}`,
        precio: 10 + i,
      });
    }
    const grupo = grupoEquivalentesDeBusqueda(catalogo, catalogo.slice(0, 10), "paracetamol");
    expect(grupo).not.toBeNull();
    expect(grupo.total).toBe(50);
    expect(grupo.mostrados).toBeLessThanOrEqual(80);
    const ids = [
      ...grupo.coincidenciasDirectas,
      ...grupo.mismaConfiguracion,
      ...grupo.otroContenido,
      ...grupo.otrasPresentaciones,
    ].map((p) => p.id);
    expect(ids.length).toBe(grupo.mostrados);
  });

  it("ibuprofeno incluye combinaciones igual que loratadina (regla general de sustancia)", () => {
    const solo = {
      id: 1,
      nombre: "Ibuprofeno 400 mg",
      marca: "Genérico",
      tipo: "generico",
      principio_activo: "Ibuprofeno",
      forma_farmaceutica: "Tabletas",
      precio: 30,
      activo: true,
    };
    const advil = {
      id: 2,
      nombre: "Advil 400 mg",
      marca: "Advil",
      tipo: "marca",
      principio_activo: "Ibuprofeno",
      forma_farmaceutica: "Tabletas",
      precio: 80,
      activo: true,
    };
    const combo = {
      id: 3,
      nombre: "Ibuprofeno / Cafeína",
      marca: "Genérico",
      tipo: "generico",
      principio_activo: "Ibuprofeno / Cafeína",
      forma_farmaceutica: "Tabletas",
      precio: 35,
      activo: true,
    };
    const resultados = [solo, advil, combo];
    const grupo = grupoEquivalentesDeBusqueda(resultados, resultados, "ibuprofeno");
    expect(grupo).not.toBeNull();
    const ids = [
      ...grupo.coincidenciasDirectas,
      ...grupo.mismaConfiguracion,
      ...grupo.otroContenido,
      ...grupo.otrasPresentaciones,
    ].map((p) => p.id).sort();
    expect(ids).toEqual([1, 2, 3]);
  });

  it("levofloxaci y levofloxacino agrupan las mismas tres presentaciones", () => {
    const amsa = {
      id: 1,
      nombre: "Levofloxacino",
      marca: "AMSA",
      tipo: "generico",
      principio_activo: "LEVOFLOXACINO",
      concentracion: "500 MG",
      presentacion: "7 TABLETAS",
      forma_farmaceutica: "TABLETAS",
      precio: 31,
      activo: true,
    };
    const bea = {
      id: 2,
      nombre: "Levofloxacino 500 mg Caja con 7 tabletas beadvance",
      marca: "beadvance",
      tipo: "generico",
      principio_activo: "Levofloxacino",
      concentracion: "500 mg",
      presentacion: "Caja con 7 tabletas",
      forma_farmaceutica: "Tableta",
      precio: 31,
      activo: true,
    };
    const cina = {
      id: 3,
      nombre: "Cina 750 mg Caja con 7 tabletas Landsteiner",
      marca: "Landsteiner",
      tipo: "generico",
      principio_activo: "Levofloxacino 750 mg",
      concentracion: "750 mg",
      presentacion: "Caja con 7 tabletas",
      forma_farmaceutica: "Tableta",
      precio: 47,
      activo: true,
    };
    const catalogo = [cina, bea, amsa];
    const idsDe = (grupo) => [
      ...(grupo?.coincidenciasDirectas || []),
      ...(grupo?.mismaConfiguracion || []),
      ...(grupo?.otroContenido || []),
      ...(grupo?.otrasPresentaciones || []),
    ].map((p) => p.id).sort();

    const porPrefijo = grupoEquivalentesDeBusqueda(catalogo, [cina, bea], "Levofloxaci");
    const porNombre = grupoEquivalentesDeBusqueda(catalogo, [amsa, bea, cina], "Levofloxacino");
    expect(porPrefijo).not.toBeNull();
    expect(porNombre).not.toBeNull();
    expect(idsDe(porPrefijo)).toEqual([1, 2, 3]);
    expect(idsDe(porNombre)).toEqual([1, 2, 3]);
    expect(clasificarRelacionProducto(bea, amsa)).toBe("misma_configuracion");
    expect(clasificarRelacionProducto(cina, amsa)).toBe("otra_forma");
  });
});
