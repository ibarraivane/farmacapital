import {
  CANTIDAD_MAX_BAJO_PEDIDO,
  cantidadMaximaLinea,
  ctaBajoPedido,
  estadoReserva,
  filtrarVitrina,
  horasRestantesReserva,
  motivoNoMezclar,
  pedidoEsBajoPedido,
  prepararProductoTienda,
  rubroDeProducto,
  tipoCarrito,
} from "./bajoPedido";

const anthelios = { id: 1, nombre: "Anthelios UVMune 400 50 ml", precio: 459, stock: 0, activo: true, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología", descuento_pct: 10 };
const whey = { id: 2, nombre: "Whey Gold 2 lb", precio: 0.01, stock: 0, activo: true, bajo_pedido: true, categoria: "Suplemento", subcategoria: "Proteína" };
const omega = { id: 3, nombre: "Omega 3", precio: 199, stock: 0, activo: true, bajo_pedido: true, categoria: "suplementos" };
const vitC = { id: 4, nombre: "Vitamina C", precio: 80, stock: 0, activo: true, bajo_pedido: true, categoria: "Vitaminas" };
const paracetamol = { id: 5, nombre: "Paracetamol", precio: 25, stock: 20, activo: true, categoria: "Analgésico" };

test("precio web con MP en todo el catálogo, una vez; bajo pedido sin descuentos", () => {
  const web = prepararProductoTienda(anthelios);
  expect(web.precio).toBe(484);
  expect(web.precio_ancla).toBe(459);
  expect(web.descuento_pct).toBe(0);
  expect(prepararProductoTienda(web).precio).toBe(484);
  const anaquel = prepararProductoTienda(paracetamol);
  expect(anaquel.precio).toBe(31);
  expect(anaquel.precio_ancla).toBe(25);
  expect(prepararProductoTienda(anaquel).precio).toBe(31);
  const skittles = prepararProductoTienda({ id: 9, nombre: "Skittles", precio: 10, stock: 4, activo: true });
  expect(skittles.precio).toBe(16);
  expect(skittles.precio_ancla).toBe(10);
});

test("Encargar con precio, Cotizar sin precio usable", () => {
  expect(ctaBajoPedido(anthelios)).toBe("encargar");
  expect(ctaBajoPedido(prepararProductoTienda(anthelios))).toBe("encargar");
  expect(ctaBajoPedido(whey)).toBe("cotizar");
  expect(ctaBajoPedido(prepararProductoTienda(whey))).toBe("cotizar");
  expect(ctaBajoPedido(paracetamol)).toBeNull();
});

test("rubros por categoria/subcategoria (con alias canónicos)", () => {
  expect(rubroDeProducto(anthelios)).toBe("dermatologia");
  expect(rubroDeProducto(whey)).toBe("proteina");
  expect(rubroDeProducto(omega)).toBe("suplementos");
  expect(rubroDeProducto(vitC)).toBe("vitaminas");
  expect(rubroDeProducto(paracetamol)).toBe("");
  const todos = [paracetamol, whey, anthelios, omega, vitC];
  expect(filtrarVitrina(todos).map((p) => p.id)).toEqual([1, 3, 4, 2]);
  expect(filtrarVitrina(todos, "proteina").map((p) => p.id)).toEqual([2]);
});

test("carrito no mezcla encargo con anaquel y tope de 12", () => {
  expect(tipoCarrito([])).toBe("vacio");
  expect(tipoCarrito([anthelios])).toBe("bajo_pedido");
  expect(tipoCarrito([paracetamol])).toBe("normal");
  expect(tipoCarrito([paracetamol, anthelios])).toBe("mixto");
  expect(motivoNoMezclar([], anthelios)).toBeNull();
  expect(motivoNoMezclar([anthelios], vitC)).toBeNull();
  expect(motivoNoMezclar([anthelios], paracetamol)).toMatch(/encargo/);
  expect(motivoNoMezclar([paracetamol], anthelios)).toMatch(/aparte/);
  expect(cantidadMaximaLinea(anthelios)).toBe(CANTIDAD_MAX_BAJO_PEDIDO);
  expect(cantidadMaximaLinea(paracetamol)).toBe(20);
});

test("estado de la reserva", () => {
  const ahora = Date.parse("2026-09-16T12:00:00Z");
  const base = { logistics_meta: { bajo_pedido: true }, payment_payload: { reserva_expira_at: "2026-09-18T12:00:00Z" } };
  expect(pedidoEsBajoPedido(base)).toBe(true);
  expect(pedidoEsBajoPedido({ logistics_meta: null })).toBe(false);
  expect(estadoReserva({ ...base, payment_status: "authorized" }, ahora)).toBe("reservado");
  expect(horasRestantesReserva(base, ahora)).toBe(48);
  expect(estadoReserva({ ...base, payment_status: "authorized" }, Date.parse("2026-09-19T00:00:00Z"))).toBe("vencido");
  expect(estadoReserva({ ...base, payment_status: "approved" }, ahora)).toBe("cobrado");
  expect(estadoReserva({ ...base, payment_status: "cancelled" }, ahora)).toBe("cancelado");
  expect(estadoReserva({ payment_status: null }, ahora)).toBe("sin_reserva");
});
