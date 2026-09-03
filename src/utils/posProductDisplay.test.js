import { nombreComercialPos, posDestacadoTarjeta, posEtiquetaVariante, posNombreReconocido, posSubtituloProducto, posTituloProducto } from "./posProductDisplay";

const alumag = {
  sku: "FC-75710113",
  nombre: "Alu-Mag suspensión hidróxido de aluminio/magnesio 3.70/4.00 g",
  marca: "Novag",
  tipo: "generico",
  presentacion: "Frasco 240 mL con vaso dosificador",
  principio_activo: null,
};

describe("posTituloProducto", () => {
  test("Alu-Mag usa el nombre del medicamento, no el laboratorio", () => {
    expect(nombreComercialPos(alumag.nombre)).toBe("Alu-Mag");
    expect(posTituloProducto(alumag)).toBe("Alu-Mag");
    expect(posSubtituloProducto(alumag)).toMatch(/Novag/i);
    expect(posTituloProducto({ nombre: "dolo-neurobion c/20", marca: "Merck" })).toBe("Dolo-Neurobion");
  });

  test("Electrolit conserva sabor corto", () => {
    expect(
      posTituloProducto({
        nombre: "Electrolit Uva",
        marca: "Electrolit",
      })
    ).toBe("Electrolit Uva");
  });

  test("vendas siguen el tipo, no la marca", () => {
    expect(
      posTituloProducto({
        nombre: "Tensolastic Plus Venda Elasti 7 CM",
        marca: "Protec",
      })
    ).toBe("Venda Elástica");
  });

  test("si el nombre es solo la marca, se queda la marca", () => {
    expect(posTituloProducto({ nombre: "Novag", marca: "Novag" })).toBe("Novag");
  });

  test("leche en polvo no se corta en la palabra polvo", () => {
    expect(
      posTituloProducto({
        nombre: "Leche En Polvo Nan 1 Optimal Pro 120 G",
        marca: "Nestle",
      })
    ).toMatch(/Leche En Polvo/i);
    expect(nombreComercialPos("Leche En Polvo Nan 1 Optimal Pro 120 G")).not.toBe("Leche En");
  });

  test("Anthelios no colapsa variantes distintas a La Roche Anthelios", () => {
    const marca = "La Roche-Posay";
    const invisible = {
      nombre: "La Roche Anthelios UV Mune 400 fluido invisible FPS50+ 50 ml",
      marca,
      presentacion: "50 ml",
      forma_farmaceutica: "Fluido",
    };
    const color = {
      nombre: "La Roche Anthelios UV Mune 400 fluido con color FPS50+ 50 ml",
      marca,
      presentacion: "50 ml",
      forma_farmaceutica: "Fluido",
    };
    const oil = {
      nombre: "La Roche Anthelios UV Mune 400 oil control FPS50+ 50 ml",
      marca,
      presentacion: "50 ml",
      forma_farmaceutica: "Fluido",
    };
    const oilColor = {
      nombre: "La Roche Anthelios UV Mune 400 oil control con color FPS50+ 50 ml",
      marca,
      presentacion: "50 ml",
      forma_farmaceutica: "Fluido",
    };
    const uvAir = {
      nombre: "La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml",
      marca,
      presentacion: "40 ml",
      forma_farmaceutica: "Fluido",
    };
    expect(posTituloProducto(invisible)).toMatch(/invisible/i);
    expect(posTituloProducto(color)).toMatch(/color/i);
    expect(posTituloProducto(oil)).toMatch(/oil control/i);
    expect(posTituloProducto(oilColor)).toMatch(/oil control/i);
    expect(posTituloProducto(oilColor)).toMatch(/color/i);
    expect(posTituloProducto(uvAir)).toMatch(/uv air/i);
    const titulos = [invisible, color, oil, oilColor, uvAir].map(posTituloProducto);
    expect(new Set(titulos).size).toBe(5);
    expect(titulos.every((t) => t === "La Roche Anthelios")).toBe(false);
  });
});

describe("posEtiquetaVariante", () => {
  test("XL-3 se reconoce por el nombre, no solo por el C/24", () => {
    const xl3 = {
      nombre: "Xl-3 Vr",
      marca: "",
      presentacion: "C/24",
      concentracion: "375/50/3 MG",
      forma_farmaceutica: "TABLETAS",
    };
    expect(posNombreReconocido(xl3)).toMatch(/xl-3/i);
    expect(posEtiquetaVariante(xl3)).toEqual({
      nombre: "Xl-3 Vr",
      detalle: "C/24 · 375/50/3 MG · TABLETAS",
    });
  });

  test("Antiflu-Des no se queda en cápsulas sueltas", () => {
    const antiflu = {
      nombre: "Antiflu-Des Capsulas",
      marca: "Chinoin",
      presentacion: "C/24 capsulas",
      forma_farmaceutica: "Capsulas",
    };
    expect(posNombreReconocido(antiflu)).toMatch(/antiflu-des/i);
    expect(posEtiquetaVariante(antiflu).detalle).toMatch(/c\/24/i);
  });

  test("un genérico no usa el principio activo como nombre de la ficha", () => {
    const generico = {
      nombre: "Antigripal C/15 tabletas",
      marca: "Wermar",
      tipo: "generico",
      principio_activo: "Paracetamol / Clorfenamina / Fenilefrina",
      presentacion: "C/15",
      concentracion: "50 mg / 3 mg / 300 mg",
      forma_farmaceutica: "Tabletas",
    };
    expect(posNombreReconocido(generico)).toMatch(/antigripal|wermar/i);
    expect(posNombreReconocido(generico)).not.toMatch(/paracetamol/i);
  });
});

describe("posDestacadoTarjeta", () => {
  test("usa activos si existen y si no, presentación", () => {
    expect(posDestacadoTarjeta({ principio_activo: "Neomicina + Caolin + Pectina" })).toBe("Activos: Neomicina + Caolín + Pectina");
    expect(posDestacadoTarjeta({ denominacion_distintiva: "NAN 1 OPTIMAL pro", presentacion: "120 g" })).toBe("NAN 1 OPTIMAL pro");
    expect(posDestacadoTarjeta({ presentacion: "120 g", concentracion: "" })).toBe("120 g");
    expect(posDestacadoTarjeta({ nombre: "Leche" })).toBe("");
  });
});
