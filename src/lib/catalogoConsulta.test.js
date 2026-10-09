import { COLUMNAS_TIENDA, FILTRO_ANAQUEL, aplicarModoCatalogo, esErrorTimeoutCatalogo, traerProductoPorId, traerProductosActivos } from "./catalogoConsulta";

function cliente(filas) {
  const llamadas = [];
  const query = () => {
    const q = {
      select: (s) => { llamadas.push(["select", s]); return q; },
      eq: (col, val) => { llamadas.push(["eq", col, val]); return q; },
      or: (expr) => { llamadas.push(["or", expr]); return q; },
      order: (col) => { llamadas.push(["order", col]); return q; },
      range: (a, b) => {
        llamadas.push(["range", a, b]);
        const page = filas.slice(a, b + 1);
        return Promise.resolve({ data: page, error: null });
      },
    };
    return q;
  };
  return {
    llamadas,
    from: (table) => {
      llamadas.push(["from", table]);
      return query();
    },
  };
}

test("el anaquel no pide la vitrina", async () => {
  const db = cliente([
    { id: 1, nombre: "Omeprazol" },
    { id: 2, nombre: "Anthelios" },
  ]);
  const { data, error } = await traerProductosActivos(db, { modo: "anaquel", pageSize: 10 });
  expect(error).toBeNull();
  expect(data).toHaveLength(2);
  expect(db.llamadas).toContainEqual(["or", FILTRO_ANAQUEL]);
  expect(db.llamadas.some((c) => c[0] === "eq" && c[1] === "bajo_pedido")).toBe(false);
});

test("la vitrina se pide sola y con tope", async () => {
  const db = cliente([
    { id: 1 }, { id: 2 }, { id: 3 },
  ]);
  const { data } = await traerProductosActivos(db, { modo: "vitrina", limite: 2, pageSize: 10 });
  expect(data.map((p) => p.id)).toEqual([1, 2]);
  expect(db.llamadas).toContainEqual(["eq", "bajo_pedido", true]);
  expect(db.llamadas.some((c) => c[0] === "or")).toBe(false);
});

test("la tienda no recibe servicios aunque vengan en la página", async () => {
  const db = cliente([
    { id: 1, nombre: "Omeprazol", tipo: "generico" },
    { id: 2, nombre: "Toma de presión arterial", tipo: "servicio" },
    { id: 3, nombre: "Paracetamol", tipo: "generico" },
  ]);
  const { data, error } = await traerProductosActivos(db, { modo: "anaquel", pageSize: 10 });
  expect(error).toBeNull();
  expect(data.map((p) => p.id)).toEqual([1, 3]);
});

test("el deep-link de un servicio no abre ficha", async () => {
  const llamadas = [];
  const q = {
    select: (s) => { llamadas.push(["select", s]); return q; },
    eq: (col, val) => { llamadas.push(["eq", col, val]); return q; },
    maybeSingle: () => Promise.resolve({
      data: { id: 9, nombre: "Toma de presión arterial", tipo: "servicio" },
      error: null,
    }),
  };
  const client = { from: () => q };
  const { data, error } = await traerProductoPorId(client, "9");
  expect(error).toBeNull();
  expect(data).toBeNull();
});

test("trae un producto por id para el deep-link", async () => {
  const llamadas = [];
  const q = {
    select: (s) => { llamadas.push(["select", s]); return q; },
    eq: (col, val) => { llamadas.push(["eq", col, val]); return q; },
    maybeSingle: () => Promise.resolve({ data: { id: 2, nombre: "Omeprazol" }, error: null }),
  };
  const client = { from: (table) => { llamadas.push(["from", table]); return q; } };
  const { data, error } = await traerProductoPorId(client, "2");
  expect(error).toBeNull();
  expect(data).toEqual({ id: 2, nombre: "Omeprazol" });
  expect(llamadas).toContainEqual(["from", "productos"]);
  expect(llamadas).toContainEqual(["eq", "id", 2]);
});

test("la lista de la tienda no pide select *", async () => {
  const db = cliente([{ id: 1 }]);
  await traerProductosActivos(db, { modo: "anaquel", pageSize: 10 });
  expect(db.llamadas).toContainEqual(["select", COLUMNAS_TIENDA]);
  expect(COLUMNAS_TIENDA.split(",")).toEqual(expect.arrayContaining(["id", "nombre", "imagen_url", "precio", "stock"]));
  expect(COLUMNAS_TIENDA).not.toMatch(/\*/);
});

test("57014 es un timeout que se puede reintentar", () => {
  expect(esErrorTimeoutCatalogo({ code: "57014", message: "canceling statement due to statement timeout" })).toBe(true);
  expect(esErrorTimeoutCatalogo({ message: "upstream request timeout" })).toBe(true);
  expect(esErrorTimeoutCatalogo({ message: "permission denied" })).toBe(false);
});

test("aplica el modo sobre el query", () => {
  const ops = [];
  const q = {
    eq: (c, v) => { ops.push(["eq", c, v]); return q; },
    or: (e) => { ops.push(["or", e]); return q; },
  };
  aplicarModoCatalogo(q, "todos");
  expect(ops).toEqual([]);
  aplicarModoCatalogo(q, "anaquel");
  expect(ops).toEqual([["or", FILTRO_ANAQUEL]]);
});
