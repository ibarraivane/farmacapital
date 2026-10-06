import { MUNDOS, FOTO_MUNDO_URL, resumirMundos, mundosVisibles, urlFotoMundo } from "./mundosTienda";

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

test("nutrición muestra proteína, no un inyectable que salió primero", () => {
  const r = resumirMundos([
    { id: 1, sku: "FC-2E79C2D8", nombre: "Hierro dextrán 100 mg/2 mL", vitrina_seccion: "Nutrición deportiva", stock: 8, precio: 90, imagen_url: "/hierro.jpg" },
    { id: 2, sku: "FC-37273377", nombre: "Birdman Fitmingo proteína vegetal", marca: "Birdman", vitrina_seccion: "Nutrición deportiva", stock: 0, precio: 604, imagen_url: "/prot.jpg" },
  ], deps);
  expect(r["nutricion-deportiva"].producto.id).toBe(2);
});

test("higiene no usa la marca más barata si hay Dove o Sensodyne", () => {
  const r = resumirMundos([
    { id: 1, nombre: "OBAO Fresquíssima roll-on", marca: "OBAO", vitrina_seccion: "Higiene y cuidado personal", stock: 12, precio: 18, imagen_url: "/obao.jpg" },
    { id: 2, sku: "FC-06248052", nombre: "Dove tono uniforme", marca: "Dove", vitrina_seccion: "Higiene y cuidado personal", stock: 3, precio: 65, imagen_url: "/dove.jpg" },
  ], deps);
  expect(r.higiene.producto.id).toBe(2);
});

test("vitaminas prefiere colágeno a una caja genérica", () => {
  const r = resumirMundos([
    { id: 1, nombre: "Complejo B genérico", vitrina_seccion: "Vitaminas y bienestar", stock: 10, precio: 25, imagen_url: "/b.jpg" },
    { id: 2, sku: "FC-9741524", nombre: "Naturex colágeno hidrolizado 700 mg", marca: "Naturex", vitrina_seccion: "Vitaminas y bienestar", stock: 2, precio: 48, imagen_url: "/col.jpg" },
  ], deps);
  expect(r.vitaminas.producto.id).toBe(2);
});

test("botiquín usa el kit del catálogo, no el tiraleche", () => {
  const r = resumirMundos([
    { id: 1, sku: "FC-41500096", nombre: "Tiraleche de cristal", vitrina_seccion: "Botiquín y equipo médico", stock: 4, precio: 48, imagen_url: "/leche.jpg" },
    { id: 2, sku: "FC-JALOMA1", nombre: "Botiquín Jaloma", marca: "Jaloma", vitrina_seccion: "Botiquín y equipo médico", stock: 1, precio: 89, imagen_url: "/kit.jpg" },
  ], deps);
  expect(r.botiquin.producto.id).toBe(2);
});

test("si no hay kit, botiquín usa Tegaderm y no el tiraleche", () => {
  const r = resumirMundos([
    { id: 1, sku: "FC-41500096", nombre: "Tiraleche de cristal", vitrina_seccion: "Botiquín y equipo médico", stock: 4, precio: 48, imagen_url: "/leche.jpg" },
    { id: 2, sku: "FC-89592876", nombre: "Tegaderm 3M 10 x 12 cm", marca: "Tegaderm", vitrina_seccion: "Botiquín y equipo médico", stock: 1, precio: 696, imagen_url: "/tega.jpg" },
  ], deps);
  expect(r.botiquin.producto.id).toBe(2);
});

test("el disco usa el packshot fijo, no Lactiv ni OBAO aunque tengan foto", () => {
  expect(urlFotoMundo(null, "nutricion-deportiva", (p) => p?.imagen_url)).toBe(FOTO_MUNDO_URL["nutricion-deportiva"]);
  expect(urlFotoMundo(
    { nombre: "Lactiv DS", imagen_url: "/lactiv.jpg" },
    "nutricion-deportiva",
    (p) => p.imagen_url,
  )).toBe(FOTO_MUNDO_URL["nutricion-deportiva"]);
  expect(urlFotoMundo(
    { nombre: "OBAO roll-on", marca: "OBAO", imagen_url: "/obao.jpg" },
    "higiene",
    (p) => p.imagen_url,
  )).toBe(FOTO_MUNDO_URL.higiene);
});

test("si el catálogo trae el kit, botiquín usa esa foto", () => {
  expect(urlFotoMundo(
    { nombre: "Botiquín Jaloma", imagen_url: "/kit.jpg" },
    "botiquin",
    (p) => p.imagen_url,
  )).toBe("/kit.jpg");
});
