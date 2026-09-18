import {
  CANTIDAD_MAX_BAJO_PEDIDO,
  COLOR_CTA_ENCARGADO,
  COLOR_CTA_ENCARGAR,
  CONSEGUIR_UI,
  RUBROS_BAJO_PEDIDO,
  STRIP_TOPE_CONSEGUIR,
  cantidadMaximaLinea,
  colorCtaEncargar,
  ctaBajoPedido,
  estadoReserva,
  estiloRecuadroConseguir,
  ETIQUETA_CTA_ORDENAR,
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
const omron = { id: 6, nombre: "Omron Monitor de Presión Automático", precio: 847, stock: 0, activo: true, bajo_pedido: true, categoria: "Dispositivo médico", subcategoria: "Diagnóstico" };
const nebucor = { id: 8, nombre: "Nebucor nebulizador P-103", precio: 890, stock: 0, activo: true, bajo_pedido: true, categoria: "Dispositivo médico", subcategoria: "Respiratorio" };
const gasa = { id: 7, nombre: "Gasa estéril 10x10 Dibar", precio: 122, stock: 0, activo: true, bajo_pedido: true, categoria: "Botiquín", subcategoria: "Material de curación" };

test("vitrina no publica precio: Ordenar, aunque el inventario traiga cifra", () => {
  const web = prepararProductoTienda(anthelios);
  expect(web.precio).toBe(0);
  expect(web.precio_ancla).toBe(0);
  expect(web.descuento_pct).toBe(0);
  expect(web.precio_marca).toBeNull();
  expect(prepararProductoTienda(web).precio).toBe(0);
  const anaquel = prepararProductoTienda(paracetamol);
  expect(anaquel.precio).toBe(27);
  expect(anaquel.precio_ancla).toBe(25);
  expect(prepararProductoTienda(anaquel).precio).toBe(27);
  const skittles = prepararProductoTienda({ id: 9, nombre: "Skittles", precio: 10, stock: 4, activo: true });
  expect(skittles.precio).toBe(11);
  expect(skittles.precio_ancla).toBe(10);
});

test("Ordenar en toda la vitrina, nunca Encargar", () => {
  expect(ETIQUETA_CTA_ORDENAR).toBe("Ordenar");
  expect(ctaBajoPedido(anthelios)).toBe("ordenar");
  expect(ctaBajoPedido(prepararProductoTienda(anthelios))).toBe("ordenar");
  expect(ctaBajoPedido(whey)).toBe("ordenar");
  expect(ctaBajoPedido(prepararProductoTienda(whey))).toBe("ordenar");
  expect(ctaBajoPedido(omron)).toBe("ordenar");
  expect(ctaBajoPedido(vitC)).toBe("ordenar");
  expect(ctaBajoPedido(paracetamol)).toBeNull();
});

test("rubros por categoria/subcategoria (con alias canónicos)", () => {
  expect(RUBROS_BAJO_PEDIDO.map((r) => r.id)).toEqual([
    "dermatologia",
    "vitaminas",
    "suplementos",
    "proteina",
    "dispositivos",
  ]);
  expect(rubroDeProducto(anthelios)).toBe("dermatologia");
  expect(rubroDeProducto(whey)).toBe("proteina");
  expect(rubroDeProducto(omega)).toBe("suplementos");
  expect(rubroDeProducto(vitC)).toBe("vitaminas");
  expect(rubroDeProducto(omron)).toBe("dispositivos");
  expect(rubroDeProducto(nebucor)).toBe("dispositivos");
  expect(rubroDeProducto(gasa)).toBe("dispositivos");
  expect(rubroDeProducto(paracetamol)).toBe("");
  expect(RUBROS_BAJO_PEDIDO.find((r) => r.id === "dispositivos")?.label).toBe("Dispositivos médicos");
  const todos = [paracetamol, whey, anthelios, omega, vitC, omron, nebucor, gasa];
  expect(filtrarVitrina(todos).map((p) => p.id)).toEqual([1, 7, 8, 3, 6, 4, 2]);
  expect(filtrarVitrina(todos, "proteina").map((p) => p.id)).toEqual([2]);
  expect(filtrarVitrina(todos, "dispositivos").map((p) => p.id)).toEqual([7, 8, 6]);
  expect(filtrarVitrina(todos, "vitaminas").map((p) => p.id)).toEqual([4]);
  expect(filtrarVitrina(todos).filter((p) => !rubroDeProducto(p))).toEqual([]);
});

test("Encargar usa terracota, no el navy de Ver detalle", () => {
  expect(COLOR_CTA_ENCARGAR).toBe("#C9451F");
  expect(COLOR_CTA_ENCARGADO).toBe("#02A158");
  expect(colorCtaEncargar(false)).toBe("#C9451F");
  expect(colorCtaEncargar(true)).toBe("#02A158");
});

test("recuadro de conseguir es ámbar/crema, distinto del anaquel", () => {
  expect(CONSEGUIR_UI.cream).toBe("#fffbeb");
  expect(STRIP_TOPE_CONSEGUIR).toBe(12);
  const rec = estiloRecuadroConseguir();
  expect(rec.background).toBe(CONSEGUIR_UI.cream);
  expect(rec.border).toMatch(CONSEGUIR_UI.border);
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
