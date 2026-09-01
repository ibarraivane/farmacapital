import { recomprasFromPedidos, sugeridosFromRecompras } from "./tiendaRecompras";

const catalogo = [
  { id: 1, nombre: "Paracetamol 500 mg", categoria: "Analgésico", activo: true, stock: 10, precio: 20 },
  { id: 2, nombre: "Ibuprofeno 400 mg", categoria: "Analgésico", activo: true, stock: 4, precio: 30 },
  { id: 3, nombre: "Omeprazol 20 mg", categoria: "Digestivo", activo: true, stock: 6, precio: 40 },
];

const pedidos = [
  {
    id: 9,
    estado: "completado",
    created_at: "2026-08-01T10:00:00Z",
    pedido_items: [{ cantidad: 2, productos: { nombre: "Paracetamol 500 mg" } }],
  },
  {
    id: 10,
    estado: "cancelado",
    created_at: "2026-08-20T10:00:00Z",
    pedido_items: [{ cantidad: 1, productos: { nombre: "Omeprazol 20 mg" } }],
  },
];

test("recompras ignora cancelados y resuelve por nombre", () => {
  const rows = recomprasFromPedidos(pedidos, catalogo);
  expect(rows).toHaveLength(1);
  expect(rows[0].prod.id).toBe(1);
  expect(rows[0].lastQty).toBe(2);
});

test("sugeridos son de la misma categoría y no repetidos", () => {
  const rec = recomprasFromPedidos(pedidos, catalogo);
  const sug = sugeridosFromRecompras(rec, catalogo, { limit: 6 });
  expect(sug.map((p) => p.id)).toEqual([2]);
});

test("usa producto_id si el RPC lo manda", () => {
  const rows = recomprasFromPedidos(
    [{
      estado: "pendiente",
      created_at: "2026-08-02",
      pedido_items: [{ producto_id: 3, cantidad: 1, productos: { nombre: "Omeprazol 20 mg" } }],
    }],
    catalogo
  );
  expect(rows[0].prod.id).toBe(3);
});
