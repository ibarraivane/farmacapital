import {
  claveGrupoPublico,
  colapsarListaPublica,
  colapsarSugerenciasPublicas,
  leyendaSabores,
  productoSinVistaGrupo,
  representanteGrupo,
  tituloGrupoPublico,
  variantesDelGrupo,
} from "./grupoPublico";

const falcon480 = [
  { id: 1, sku: "FC-34437733", nombre: "Falcon Protein - Nueva Fórmula - Chai 480gr", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Chai", activo: true },
  { id: 2, sku: "FC-10011410", nombre: "Falcon Protein - Nueva Fórmula - Chocolate 480g", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Chocolate", activo: true, imagen_url: "https://ejemplo/choco.jpg" },
  { id: 3, sku: "FC-53536505", nombre: "Falcon Protein - Nueva Fórmula - Fresa 480g", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Fresa", activo: true },
  { id: 4, sku: "FC-40393268", nombre: "Falcon Protein - Nueva Fórmula - Natural 480g", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Natural", activo: true },
  { id: 5, sku: "FC-31502844", nombre: "Falcon Protein - Nueva Fórmula - Vainilla 480g", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Vainilla", activo: true },
  { id: 6, sku: "FC-03985090", nombre: "Falcon Protein - Nueva Fórmula -Pumpkin Spice 480g Edición Limitada", marca: "Birdman", grupo_publico: "birdman-falcon-protein-480", variante_publica: "Pumpkin Spice", activo: true },
];

const falcon960 = [
  { id: 11, nombre: "Falcon Protein - Nueva Fórmula - Chocolate 960gr", grupo_publico: "birdman-falcon-protein-960", variante_publica: "Chocolate", activo: true },
  { id: 12, nombre: "Falcon Protein - Nueva Fórmula - Vainilla 960 gr", grupo_publico: "birdman-falcon-protein-960", variante_publica: "Vainilla", activo: true },
];

const suelto = { id: 99, nombre: "Omeprazol 20 mg", activo: true, precio: 89 };

describe("tituloGrupoPublico", () => {
  test("quita el sabor y deja el tamaño", () => {
    expect(tituloGrupoPublico(falcon480[1])).toBe("Falcon Protein - Nueva Fórmula 480g");
    expect(tituloGrupoPublico(falcon480[5])).toBe("Falcon Protein - Nueva Fórmula 480g Edición Limitada");
    expect(tituloGrupoPublico({
      nombre: "BCAAs & Glutamina 405 g - Mora - Limón",
      variante_publica: "Mora-Limón",
    })).toBe("BCAAs & Glutamina 405 g");
    expect(tituloGrupoPublico({
      nombre: "Creatine for Women - Sabor Pink Lemonade - 40 Porciones",
      variante_publica: "Pink Lemonade",
    })).toBe("Creatine for Women - 40 Porciones");
    expect(tituloGrupoPublico({
      nombre: "Falcon Performance - Nueva Fórmula - Choco Bronze - 1.140 KG",
      variante_publica: "Choco Bronze",
    })).toBe("Falcon Performance - Nueva Fórmula - 1.140 KG");
  });

  test("sin variante el nombre se queda", () => {
    expect(tituloGrupoPublico(suelto)).toBe("Omeprazol 20 mg");
  });
});

describe("variantes y representante", () => {
  test("el 480 g no se mezcla con el 960 g", () => {
    const todos = [...falcon480, ...falcon960, suelto];
    expect(variantesDelGrupo(todos, falcon480[0]).map((p) => p.id)).toEqual([1, 2, 3, 4, 6, 5]);
    expect(variantesDelGrupo(todos, falcon960[0]).map((p) => p.id)).toEqual([11, 12]);
    expect(variantesDelGrupo(todos, suelto)).toEqual([suelto]);
  });

  test("inactivo no entra al grupo", () => {
    const off = { ...falcon480[3], activo: false };
    const vivos = variantesDelGrupo([falcon480[0], off], falcon480[0]);
    expect(vivos.map((p) => p.id)).toEqual([1]);
  });

  test("representante prefiere foto", () => {
    expect(representanteGrupo(variantesDelGrupo(falcon480, falcon480[0])).id).toBe(2);
  });
});

describe("colapsarListaPublica", () => {
  const catalogo = [...falcon480, ...falcon960, suelto];

  test("vitrina: una tarjeta por grupo y el suelto sigue", () => {
    const cards = colapsarListaPublica(catalogo, { universo: catalogo, preferirCoincidencia: false });
    expect(cards.map((p) => p.id)).toEqual([2, 11, 99]);
    expect(cards[0].sabores_publicos).toBe(6);
    expect(cards[0].titulo_grupo_publico).toMatch(/480g/);
    expect(cards[0].titulo_grupo_publico).not.toMatch(/Chocolate/i);
    expect(leyendaSabores(cards[0].sabores_publicos)).toBe("6 sabores");
    expect(cards[2].sabores_publicos).toBeUndefined();
    expect(claveGrupoPublico(cards[2])).toBe("");
  });

  test("buscar chocolate deja ese sabor y cuenta el grupo entero", () => {
    const hits = [falcon480[1], falcon960[0], suelto];
    const cards = colapsarListaPublica(hits, { universo: catalogo, preferirCoincidencia: true });
    expect(cards.map((p) => p.id)).toEqual([2, 11, 99]);
    expect(cards[0].variante_publica).toBe("Chocolate");
    expect(cards[0].sabores_publicos).toBe(6);
    expect(cards[1].sabores_publicos).toBe(2);
  });

  test("productoSinVistaGrupo no se lleva la etiqueta al carrito", () => {
    const vista = colapsarListaPublica(catalogo, { preferirCoincidencia: false })[0];
    const limpio = productoSinVistaGrupo(vista);
    expect(limpio.sabores_publicos).toBeUndefined();
    expect(limpio.titulo_grupo_publico).toBeUndefined();
    expect(limpio.id).toBe(vista.id);
    expect(limpio.sku).toBe("FC-10011410");
    expect(productoSinVistaGrupo(suelto)).toBe(suelto);
  });
});

describe("colapsarSugerenciasPublicas", () => {
  test("un renglón por grupo, con el id del sabor que coincidió", () => {
    const sugerencias = [
      { id: 2, nombre: "Chocolate 480" },
      { id: 3, nombre: "Fresa 480" },
      { id: 11, nombre: "Chocolate 960" },
      { id: 99, nombre: "Omeprazol 20 mg" },
    ];
    const out = colapsarSugerenciasPublicas(sugerencias, [...falcon480, ...falcon960, suelto]);
    expect(out.map((s) => s.id)).toEqual([2, 11, 99]);
    expect(out[0].sabores_publicos).toBe(6);
    expect(out[2].sabores_publicos).toBeUndefined();
  });
});
