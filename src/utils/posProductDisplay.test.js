import { nombreComercialPos, posSubtituloProducto, posTituloProducto } from "./posProductDisplay";

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
});
