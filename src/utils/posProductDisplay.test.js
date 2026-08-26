import { nombreComercialPos, posDestacadoTarjeta, posSubtituloProducto, posTituloProducto } from "./posProductDisplay";

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
});

describe("posDestacadoTarjeta", () => {
  test("usa activos si existen y si no, presentación", () => {
    expect(posDestacadoTarjeta({ principio_activo: "Neomicina + Caolin + Pectina" })).toBe("Activos: Neomicina + Caolín + Pectina");
    expect(posDestacadoTarjeta({ denominacion_distintiva: "NAN 1 OPTIMAL pro", presentacion: "120 g" })).toBe("NAN 1 OPTIMAL pro");
    expect(posDestacadoTarjeta({ presentacion: "120 g", concentracion: "" })).toBe("120 g");
    expect(posDestacadoTarjeta({ nombre: "Leche" })).toBe("");
  });
});
