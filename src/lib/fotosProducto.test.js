import { listarFotosEditor, mismaFoto } from "./fotosProducto";

const CONTAC = "https://cdn.ejemplo/contac-roja.jpg";
const LENTE = "https://cdn.ejemplo/bausch.jpg";

it("muestra la principal y las otras fotos, cada una distinta", () => {
  const fotos = listarFotosEditor({
    imagenUrl: CONTAC,
    filas: [
      { id: 1, url: LENTE, posicion: 1, es_principal: true },
      { id: 2, url: `${LENTE}?v=3`, posicion: 2, es_principal: false },
    ],
  });
  expect(fotos.map((f) => f.url)).toEqual([CONTAC, LENTE]);
  expect(fotos[0].esPrincipal).toBe(true);
  expect(fotos[1].esPrincipal).toBe(false);
  expect(mismaFoto(`${CONTAC}?v=1`, CONTAC)).toBe(true);
});

it("sin principal marcada usa la de la galería", () => {
  const fotos = listarFotosEditor({
    imagenUrl: "",
    filas: [
      { id: 1, url: LENTE, posicion: 2, es_principal: false },
      { id: 2, url: CONTAC, posicion: 5, es_principal: true },
    ],
  });
  expect(fotos[0].url).toBe(CONTAC);
  expect(fotos[0].esPrincipal).toBe(true);
});
