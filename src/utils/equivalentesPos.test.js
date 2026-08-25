import { claveSustancia, esPatente, agruparOpcionesEquivalentes, grupoEquivalentesDeBusqueda } from "./equivalentesPos";

const treda = { id: 1, nombre: "Treda antidiarreico C/20", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", precio: 189, activo: true };
const kpec = { id: 2, nombre: "Nineka suspensión neomicina/caolín/pectina", marca: "K-PEC", tipo: "generico", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "Frasco 100 mL", precio: 38, activo: true, imagen_url: "http://x/1.jpg" };
const nineka = { id: 3, nombre: "Nineka 20 Tab 129/280/30 Mg", marca: "Novag", tipo: "generico", principio_activo: "Neomicina / Caolín y Pectina", concentracion: "129/280/30 mg", precio: 61, activo: true };
const beAdvance = { id: 4, nombre: "Neomi/Cao/Pecti 20tab", marca: "Be Advance", tipo: "generico", principio_activo: "Neomicina / Caolín y Pectina", precio: 60, activo: true };

describe("claveSustancia", () => {
  it("junta la misma sustancia escrita distinto", () => {
    expect(claveSustancia(treda)).toBe(claveSustancia(nineka));
    expect(claveSustancia(treda)).toBe("caolin+neomicina+pectina");
  });

  it("ignora dosis y sales", () => {
    expect(claveSustancia({ principio_activo: "Naproxeno sódico 550 mg" })).toBe("naproxeno");
    expect(claveSustancia({ principio_activo: "Naproxeno" })).toBe("naproxeno");
    expect(claveSustancia({ principio_activo: "Omeprazol 20 mg" })).toBe("omeprazol");
  });

  it("no confunde la sustancia sola con su combinación", () => {
    expect(claveSustancia({ principio_activo: "Amoxicilina" }))
      .not.toBe(claveSustancia({ principio_activo: "Amoxicilina / Ácido clavulánico" }));
  });

  it("no agrupa rubros que no son sustancias", () => {
    expect(claveSustancia({ principio_activo: "Surfactantes fórmula capilar" })).toBe("");
    expect(claveSustancia({ principio_activo: "Producto homeopático natural" })).toBe("");
    expect(claveSustancia({ principio_activo: "Material de curación" })).toBe("");
  });

  it("devuelve vacío cuando no hay principio activo", () => {
    expect(claveSustancia({ nombre: "Paleta payaso" })).toBe("");
    expect(claveSustancia(null)).toBe("");
  });
});

describe("esPatente", () => {
  it("lee el tipo del catálogo", () => {
    expect(esPatente(treda)).toBe(true);
    expect(esPatente(kpec)).toBe(false);
  });
});

describe("agruparOpcionesEquivalentes", () => {
  const catalogo = [kpec, nineka, beAdvance, treda];

  it("arma el grupo completo aunque el texto esté escrito distinto", () => {
    const g = agruparOpcionesEquivalentes(catalogo, kpec);
    expect(g.total).toBe(4);
    expect(g.marcas).toHaveLength(4);
  });

  it("pone la patente primero y luego lo más barato", () => {
    const g = agruparOpcionesEquivalentes(catalogo, kpec);
    expect(g.marcas.map((m) => m.marca)).toEqual(["Treda", "K-PEC", "Be Advance", "Novag"]);
  });

  it("junta las presentaciones de una marca en una sola tarjeta", () => {
    const tredaJarabe = { ...treda, id: 5, nombre: "Treda jarabe", presentacion: "Frasco 120 mL", precio: 145 };
    const g = agruparOpcionesEquivalentes([...catalogo, tredaJarabe], kpec);
    expect(g.marcas).toHaveLength(4);
    expect(g.marcas[0].marca).toBe("Treda");
    expect(g.marcas[0].opciones.map((p) => p.precio)).toEqual([145, 189]);
    expect(g.marcas[0].precioDesde).toBe(145);
  });

  it("toma la foto de la presentación que sí la tenga", () => {
    const g = agruparOpcionesEquivalentes(catalogo, kpec);
    expect(g.marcas.find((m) => m.marca === "K-PEC").foto).toBe("http://x/1.jpg");
    expect(g.marcas.find((m) => m.marca === "Treda").foto).toBe("");
  });

  it("no muestra tablero cuando la marca es una sola", () => {
    expect(agruparOpcionesEquivalentes([treda], treda)).toBeNull();
    const dosDeLaMisma = [treda, { ...treda, id: 9, presentacion: "C/12", precio: 120 }];
    expect(agruparOpcionesEquivalentes(dosDeLaMisma, treda)).toBeNull();
  });

  it("ignora los productos dados de baja", () => {
    const g = agruparOpcionesEquivalentes([kpec, { ...treda, activo: false }, nineka, beAdvance], kpec);
    expect(g.marcas.map((m) => m.marca)).not.toContain("Treda");
  });

  it("no arma tablero para rubros de consumo", () => {
    const shampoo = { id: 7, nombre: "Shampoo Sedal", marca: "Sedal", principio_activo: "Surfactantes fórmula capilar", precio: 24, activo: true };
    const otro = { id: 8, nombre: "Shampoo Caprice", marca: "Caprice", principio_activo: "Surfactantes fórmula capilar", precio: 21, activo: true };
    expect(agruparOpcionesEquivalentes([shampoo, otro], shampoo)).toBeNull();
  });
});

describe("grupoEquivalentesDeBusqueda", () => {
  const antigripal = { id: 10, nombre: "Tempra antigripal", marca: "Tempra", tipo: "marca", principio_activo: "Paracetamol/fenilefrina/carbinoxamina", precio: 96, activo: true };
  const antigripal2 = { id: 11, nombre: "Tempra XT Noche", marca: "Tempra", tipo: "marca", principio_activo: "Paracetamol/fenilefrina/carbinoxamina", precio: 81, activo: true };
  const tempraForte = { id: 12, nombre: "Tempra Forte C/24", marca: "Tempra", tipo: "marca", principio_activo: "Paracetamol", concentracion: "500 MG", precio: 153, activo: true };
  const tempra500 = { id: 13, nombre: "Tempra 500 mg", marca: "Tempra", tipo: "marca", principio_activo: "Paracetamol", precio: 62, activo: true };
  const acetif = { id: 14, nombre: "Acetif 10 Tab 500 Mg", marca: "Novag", tipo: "generico", principio_activo: "Paracetamol", concentracion: "500 mg", precio: 10, activo: true };
  const catalogo = [antigripal, antigripal2, tempraForte, tempra500, acetif];

  it("manda la sustancia que domina los resultados, no el primer renglón", () => {
    // Así vienen ordenados hoy: el antigripal encabeza por parecido de nombre.
    const grupo = grupoEquivalentesDeBusqueda(catalogo, [antigripal, tempraForte, tempra500, antigripal2]);
    expect(grupo.clave).toBe("paracetamol");
    expect(grupo.marcas.map((m) => m.marca)).toEqual(["Tempra", "Novag"]);
  });

  it("con un solo resultado usa la sustancia de ese resultado", () => {
    const grupo = grupoEquivalentesDeBusqueda(catalogo, [acetif]);
    expect(grupo.clave).toBe("paracetamol");
  });

  it("sin resultados no hay tablero", () => {
    expect(grupoEquivalentesDeBusqueda(catalogo, [])).toBeNull();
    expect(grupoEquivalentesDeBusqueda(catalogo, null)).toBeNull();
  });
});
