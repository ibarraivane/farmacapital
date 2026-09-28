import { FILTRO_ANAQUEL, aplicarModoCatalogo, traerProductosActivos } from "./catalogoConsulta";

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
