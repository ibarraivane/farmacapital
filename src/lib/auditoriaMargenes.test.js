import {
  auditarMargenProducto,
  familiaMargen,
  refsVentaComparablesAuditoria,
} from "./auditoriaMargenes";

const sedal135 = {
  nombre: "Crema Para Peinar Sedal Rizos Definidos",
  categoria: "Cuidado personal",
  tipo: "marca",
  presentacion: "135 ML",
  costo: 9.08,
};

test("Sedal 135 ml a $61 es margen abismal; sugerido $20", () => {
  const a = auditarMargenProducto({ ...sedal135, precio: 61 });
  expect(familiaMargen(sedal135)).toBe("higiene");
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(20);
  expect(a.techoOk).toBe(20);
});

test("Sedal 135 ml a $20 (ya corregido) no alerta", () => {
  const a = auditarMargenProducto({ ...sedal135, precio: 20 });
  expect(a.accion).toBe("ok");
  expect(a.sugerido).toBeNull();
});

test("descarta Similares $92 en la crema de $9", () => {
  const refs = refsVentaComparablesAuditoria(9.08, 15, 20, [
    { fuente: "similares", precio: 92 },
    { fuente: "rappi_super", precio: 20 },
    { fuente: "rappi_gdl", precio: 33 },
  ]);
  expect(refs).toEqual([20, 33]);
});

test("Nivea Milk $207 vs costo $22.30 baja hacia el techo", () => {
  const a = auditarMargenProducto({
    nombre: "Nivea Milk Crema corp 400 ML",
    categoria: "Cuidado personal",
    tipo: "marca",
    costo: 22.3,
    precio: 207,
  });
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(50);
});

test("venta bajo costo", () => {
  const a = auditarMargenProducto({
    nombre: "Pañuelos Kleenex",
    categoria: "Higiene",
    costo: 32.83,
    precio: 10,
  });
  expect(a.accion).toBe("bajo_costo");
  expect(a.sugerido).toBeGreaterThan(10);
});

test("costo $0.01 no sugiere bajar el PVP", () => {
  const a = auditarMargenProducto({
    nombre: "Metanucil 1 Polvo Sabor Natural 504 G",
    categoria: "Otro",
    costo: 0.01,
    precio: 150,
  });
  expect(a.accion).toBe("revisar_costo");
  expect(a.sugerido).toBeNull();
});

test("genérico al recargo 60% sobre venta (2.5×) no es alerta", () => {
  const a = auditarMargenProducto({
    nombre: "Omeprazol 20 mg",
    categoria: "Otro",
    tipo: "generico",
    forma_farmaceutica: "capsula",
    principio_activo: "Omeprazol",
    costo: 16.13,
    precio: 41,
  });
  expect(a.accion).toBe("ok");
});

test("genérico a 6× el costo sí se baja", () => {
  const a = auditarMargenProducto({
    nombre: "Cinitaprida 25 Comp 1 Mg",
    categoria: "Otro",
    tipo: "generico",
    forma_farmaceutica: "tableta",
    principio_activo: "Cinitaprida",
    costo: 17.58,
    precio: 119,
  });
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBeLessThan(119);
  expect(a.sugerido).toBeGreaterThanOrEqual(29);
});

test("genérico apenas sobre el piso 1.55× no es alerta", () => {
  const a = auditarMargenProducto({
    nombre: "Cefalver Susp 125 Mg",
    categoria: "Otro",
    tipo: "marca",
    requiere_receta: true,
    costo: 26.25,
    precio: 42,
  });
  expect(a.accion).toBe("ok");
});

test("última compra mucho más cara que el costo catálogo → revisar, no bajar", () => {
  const a = auditarMargenProducto(
    {
      nombre: "Mercurio óxido de zinc C/50",
      categoria: "Otro",
      costo: 9,
      precio: 54,
    },
    { ultimaCompra: 54 },
  );
  expect(a.accion).toBe("revisar_costo");
});
