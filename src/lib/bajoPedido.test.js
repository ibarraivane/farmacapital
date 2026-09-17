import {
  BADGE_EN_TIENDA,
  BADGE_SOBRE_PEDIDO,
  CANTIDAD_MAX_BAJO_PEDIDO,
  RUBROS_BAJO_PEDIDO,
  badgeVitrina,
  cantidadMaximaLinea,
  copyMarcasSeccion,
  ctaBajoPedido,
  esNutricionDeportiva,
  estadoReserva,
  filtrarSeccion,
  filtrarVitrina,
  filtrarVitrinaSeccion,
  horasRestantesReserva,
  motivoNoMezclar,
  pedidoEsBajoPedido,
  prepararProductoTienda,
  rubroDeProducto,
  rubroDeQuery,
  seccionConseguirDeQuery,
  tipoCarrito,
} from "./bajoPedido";

const anthelios = { id: 1, nombre: "Anthelios UVMune 400 50 ml", precio: 459, stock: 0, activo: true, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología", descuento_pct: 10 };
const whey = { id: 2, nombre: "Whey Gold 2 lb", precio: 0.01, stock: 0, activo: true, bajo_pedido: true, categoria: "Suplemento", subcategoria: "Proteína" };
const omega = { id: 3, nombre: "Omega 3", precio: 199, stock: 0, activo: true, bajo_pedido: true, categoria: "suplementos" };
const vitC = { id: 4, nombre: "Vitamina C", precio: 80, stock: 0, activo: true, bajo_pedido: true, categoria: "Vitaminas" };
const paracetamol = { id: 5, nombre: "Paracetamol", precio: 25, stock: 20, activo: true, categoria: "Analgésico" };

test("precio web con MP en todo el catálogo, una vez; bajo pedido sin descuentos", () => {
  const web = prepararProductoTienda(anthelios);
  expect(web.precio).toBe(479);
  expect(web.precio_ancla).toBe(459);
  expect(web.descuento_pct).toBe(0);
  expect(prepararProductoTienda(web).precio).toBe(479);
  const anaquel = prepararProductoTienda(paracetamol);
  expect(anaquel.precio).toBe(27);
  expect(anaquel.precio_ancla).toBe(25);
  expect(prepararProductoTienda(anaquel).precio).toBe(27);
  const skittles = prepararProductoTienda({ id: 9, nombre: "Skittles", precio: 10, stock: 4, activo: true });
  expect(skittles.precio).toBe(11);
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
  expect(seccionConseguirDeQuery("?seccion=dermatologia")).toBe("dermatologia");
  expect(seccionConseguirDeQuery("?seccion=derma")).toBe("dermatologia");
  expect(seccionConseguirDeQuery("?seccion=vitaminas")).toBe("nutricion");
  expect(seccionConseguirDeQuery("?seccion=nutricion")).toBe("nutricion");
  expect(seccionConseguirDeQuery("")).toBe("");
  expect(filtrarVitrinaSeccion(todos, "dermatologia").map((p) => p.id)).toEqual([1]);
  expect(filtrarVitrinaSeccion(todos, "nutricion").map((p) => p.id)).toEqual([3, 4, 2]);
  expect(seccionConseguirDeQuery("?seccion=dermocosmetica")).toBe("dermatologia");
});

test("filtrarSeccion por sección y rubro; anaquel e inactivos fuera si no se pide", () => {
  const inactivo = { ...anthelios, id: 8, activo: false };
  const anaquelDerma = { id: 9, nombre: "Cetaphil anaquel", activo: true, bajo_pedido: false, stock: 3, categoria: "Cuidado personal", subcategoria: "Dermatología" };
  const todos = [paracetamol, whey, anthelios, omega, vitC, inactivo, anaquelDerma];
  expect(filtrarSeccion(todos, "dermatologia", { incluirAnaquel: false }).map((p) => p.id)).toEqual([1]);
  expect(filtrarSeccion(todos, "nutricion", { rubro: "proteina" }).map((p) => p.id)).toEqual([2]);
  expect(filtrarSeccion(todos, "nutricion", { rubro: "vitaminas" }).map((p) => p.id)).toEqual([4]);
  expect(filtrarSeccion(todos, "nutricion", { rubro: "suplementos" }).map((p) => p.id)).toEqual([3]);
  expect(filtrarSeccion(todos, "dermatologia", { incluirAnaquel: false }).map((p) => p.id)).not.toContain(9);
  expect(filtrarSeccion(todos, "dermatologia", { incluirAnaquel: false }).map((p) => p.id)).not.toContain(8);
});

test("fase 2: anaquel + encargo en vitrina; anaquel con stock primero", () => {
  const anaquelDerma = { id: 9, nombre: "Cetaphil anaquel", activo: true, bajo_pedido: false, stock: 3, categoria: "Cuidado personal", subcategoria: "Dermatología" };
  const agotadoDerma = { id: 10, nombre: "Zocalo derma", activo: true, bajo_pedido: false, stock: 0, categoria: "Cuidado personal", subcategoria: "Dermatología" };
  const todos = [anthelios, anaquelDerma, agotadoDerma];
  expect(filtrarVitrinaSeccion(todos, "dermatologia").map((p) => p.id)).toEqual([9, 1, 10]);
  expect(badgeVitrina(anaquelDerma)).toBe(BADGE_EN_TIENDA);
  expect(badgeVitrina(anthelios)).toBe(BADGE_SOBRE_PEDIDO);
  expect(badgeVitrina(paracetamol)).toBe("");
});

test("nutrición deportiva: creatina y whey sí; pancreatina y shampoo no", () => {
  expect(RUBROS_BAJO_PEDIDO.find((r) => r.id === "proteina").label).toBe("Nutrición deportiva");
  expect(esNutricionDeportiva("Proteína", "Whey Gold")).toBe(true);
  expect(esNutricionDeportiva("Nutrición deportiva", "Cualquiera")).toBe(true);
  expect(rubroDeProducto({ categoria: "Suplemento", subcategoria: "", nombre: "Creatina monohidratada 300 g" })).toBe("proteina");
  expect(rubroDeProducto({ categoria: "Suplemento", subcategoria: "", nombre: "Pre-entreno tropical" })).toBe("proteina");
  expect(rubroDeProducto({ categoria: "Suplemento", subcategoria: "", nombre: "Pancreatina 150 mg" })).toBe("suplementos");
  expect(rubroDeProducto({ categoria: "Suplemento", subcategoria: "Proteína", nombre: "Shampoo con proteína" })).toBe("suplementos");
  expect(rubroDeQuery("?rubro=creatina")).toBe("proteina");
  expect(rubroDeQuery("?rubro=nutricion-deportiva")).toBe("proteina");
  expect(seccionConseguirDeQuery("?seccion=deporte")).toBe("nutricion");
});

test("copy de marcas solo usa las del catálogo", () => {
  const a = { ...anthelios, marca: "La Roche-Posay" };
  const b = { ...anthelios, id: 11, nombre: "Otra", marca: "La Roche-Posay" };
  const c = { ...anthelios, id: 12, nombre: "Heliocare", marca: "Heliocare" };
  expect(copyMarcasSeccion([a, b, c], "dermatologia")).toMatch(/La Roche-Posay/);
  expect(copyMarcasSeccion([a, b, c], "dermatologia")).toMatch(/Heliocare/);
  expect(copyMarcasSeccion([a, b, c], "dermatologia")).not.toMatch(/Effaclar|Pharmaton/);
  expect(copyMarcasSeccion([vitC], "dermatologia")).toBe("Lo que indica el dermatólogo. En anaquel o lo pedimos.");
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
