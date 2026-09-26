const { productosSimilaresTienda } = require("./productosSimilaresTienda");

const whey = {
  id: 1,
  nombre: "Gold Standard 100% Whey proteína chocolate",
  marca: "Optimum Nutrition",
  categoria: "Suplemento",
  subcategoria: "Nutrición deportiva",
  presentacion: "5 lb",
};

test("la proteína no arrastra Ensure, Glucerna ni hierro por ser suplemento", () => {
  const catalogo = [
    whey,
    { id: 2, nombre: "Hierro dextrán 100 mg", marca: "Pisa", categoria: "Suplemento", subcategoria: "Hierro" },
    { id: 3, nombre: "Ensure líquido vainilla", marca: "Ensure", categoria: "Suplemento", presentacion: "237 ml" },
    { id: 4, nombre: "Glucerna líquido chocolate", marca: "Glucerna", categoria: "Suplemento", presentacion: "237 ml" },
    { id: 5, nombre: "Ensure líquido fresa", marca: "Ensure", categoria: "Suplemento" },
  ];
  expect(productosSimilaresTienda(whey, catalogo).map((p) => p.id)).toEqual([]);
});

test("sí muestra otro sabor o presentación de la misma línea", () => {
  const catalogo = [
    whey,
    {
      id: 8,
      nombre: "Gold Standard 100% Whey proteína vainilla",
      marca: "Optimum Nutrition",
      categoria: "Suplemento",
      subcategoria: "Nutrición deportiva",
      presentacion: "2 lb",
    },
    { id: 3, nombre: "Ensure líquido vainilla", marca: "Ensure", categoria: "Suplemento" },
  ];
  expect(productosSimilaresTienda(whey, catalogo).map((p) => p.id)).toEqual([8]);
});

test("un medicamento parecido es la misma sustancia, no la categoría", () => {
  const ibu = { id: 10, nombre: "Ibuprofeno 400 mg", marca: "Advil", principio_activo: "Ibuprofeno", categoria: "Antiinflamatorio" };
  const catalogo = [
    ibu,
    { id: 11, nombre: "Ibuprofeno 600 mg", marca: "Genérico", principio_activo: "Ibuprofeno", categoria: "Antiinflamatorio" },
    { id: 12, nombre: "Paracetamol 500 mg", marca: "Tempra", principio_activo: "Paracetamol", categoria: "Antiinflamatorio" },
  ];
  expect(productosSimilaresTienda(ibu, catalogo).map((p) => p.id)).toEqual([11]);
});
