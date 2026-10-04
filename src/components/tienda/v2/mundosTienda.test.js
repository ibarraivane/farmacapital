import { MUNDOS, resumirMundos, mundosVisibles } from "./mundosTienda";

const deps = {
  seccionDe: (p) => p.vitrina_seccion || "",
  tieneFoto: (p) => Boolean(p.imagen_url),
};

const P = [
  { id: 1, nombre: "Paracetamol", vitrina_seccion: "Medicamentos", stock: 5, precio: 20 },
  { id: 2, nombre: "Tempra", vitrina_seccion: "Medicamentos", stock: 5, precio: 55, imagen_url: "/t.jpg" },
  { id: 3, nombre: "Fotoprotector", vitrina_seccion: "Dermocosmética", stock: 3, precio: 389, imagen_url: "/i.jpg" },
  { id: 4, nombre: "Gel cabello", vitrina_seccion: "Higiene y cuidado personal", stock: 3, precio: 40, imagen_url: "/g.jpg" },
  { id: 5, nombre: "Proteína", vitrina_seccion: "Nutrición deportiva", stock: 0, precio: 900, imagen_url: "/agotada.jpg" },
  { id: 6, nombre: "Proteína 2", vitrina_seccion: "Nutrición deportiva", stock: 4, precio: 950, imagen_url: "/ok.jpg" },
  { id: 7, nombre: "Inactivo", vitrina_seccion: "Medicamentos", activo: false, stock: 5, precio: 10, imagen_url: "/x.jpg" },
  { id: 8, nombre: "Vitamina C", vitrina_seccion: "Vitaminas y bienestar", stock: 2, precio: 80, imagen_url: "/v.jpg" },
];

test("agrupa cada producto en su sección de vitrina y cuenta", () => {
  const r = resumirMundos(P, deps);
  expect(r.medicamentos.n).toBe(2);
  expect(r.dermocosmetica.n).toBe(1);
  expect(r.higiene.n).toBe(1);
  expect(r["nutricion-deportiva"].n).toBe(2);
  expect(r.vitaminas.n).toBe(1);
  expect(r.botiquin.n).toBe(0);
});

test("la dermocosmética no se cuela en higiene", () => {
  const r = resumirMundos(P, deps);
  expect(r.higiene.producto.id).toBe(4);
  expect(r.dermocosmetica.producto.id).toBe(3);
});

test("el representante tiene foto y, si se puede, existencia", () => {
  const r = resumirMundos(P, deps);
  expect(r.medicamentos.producto.id).toBe(2);
  expect(r["nutricion-deportiva"].producto.id).toBe(6);
});

test("los inactivos no cuentan", () => {
  const r = resumirMundos(P, deps);
  expect(r.medicamentos.n).toBe(2);
});

test("un producto sin sección no abre un mundo", () => {
  const r = resumirMundos([{ id: 9, nombre: "Suelto", categoria: "Otro" }], deps);
  expect(mundosVisibles(r).map((m) => m.id)).toEqual([]);
});

test("oculta mundos vacíos", () => {
  const r = resumirMundos([P[0]], deps);
  expect(mundosVisibles(r).map((m) => m.id)).toEqual(["medicamentos"]);
});

test("mientras carga o si no llegó catálogo muestra todos, para que el inicio no salte", () => {
  const r = resumirMundos([], deps);
  expect(mundosVisibles(r, { cargando: true })).toHaveLength(MUNDOS.length);
  expect(mundosVisibles(r, { hayCatalogo: false })).toHaveLength(MUNDOS.length);
});

test("los discos son las seis secciones publicadas, en el mismo orden del menú", () => {
  expect(MUNDOS.map((m) => m.titulo)).toEqual([
    "Nutrición deportiva",
    "Dermocosmética",
    "Medicamentos",
    "Higiene y cuidado personal",
    "Vitaminas y bienestar",
    "Botiquín y equipo médico",
  ]);
});
