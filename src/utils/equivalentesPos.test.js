import { claveSustancia, clasificarRelacionProducto, coincideConsultaDirecta, etiquetaTipoProducto, grupoOpcionesRelacionadas, grupoEquivalentesDeBusqueda } from "./equivalentesPos";

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

  it("trata Busconet y Pasmodil como el mismo activo", () => {
    expect(claveSustancia({ principio_activo: "Bromuro de butil hiocina y metamizol sódico" }))
      .toBe(claveSustancia({ principio_activo: "Hioscina / Metamizol sódico" }));
    expect(claveSustancia({ principio_activo: "Butilhioscina / Metamizol" })).toBe("hioscina+metamizol");
  });
});

describe("clasificación farmacéutica", () => {
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
});
