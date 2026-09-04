import {
  percentilRefs,
  calcPrecioSugeridoVenta,
  calcPrecioSugeridoReferencias,
  resolverDecisionSugeridoFila,
  listarSubidasSugeridas,
  captionRefNoComparable,
} from "./preciosReferencia";

test("percentil 40 no es el mínimo", () => {
  expect(percentilRefs([10, 20, 30, 40, 50], 0.4)).toBe(26);
  expect(percentilRefs([18], 0.4)).toBe(18);
});

function refs(map) {
  const out = {};
  for (const [fuente, precio] of Object.entries(map)) {
    out[fuente] = { fuente, precio, tipo: "venta" };
  }
  return out;
}

test("Referencias no persigue el min − 2% si hay piso", () => {
  const p = {
    nombre: "Amoxicilina 500",
    tipo: "generico",
    forma_farmaceutica: "tableta",
    principio_activo: "Amoxicilina",
    costo: 20,
    precio: 32,
  };
  const r = refs({ similares: 18, fahorro: 30, otros_venta: 28 });
  const oldMin = calcPrecioSugeridoVenta(p, r, undefined, {
    usarMinimo: true,
    respetarPisoMargen: false,
    factorPosicion: 0.98,
  });
  expect(oldMin.sugerido).toBe(18);

  const neu = calcPrecioSugeridoReferencias(p, r);
  expect(neu.refMin).toBe(18);
  expect(neu.piso).toBeGreaterThan(18);
  expect(neu.sugerido).toBeGreaterThanOrEqual(neu.piso);
  expect(neu.alerta).toBe("piso_gt_techo");
  expect(neu.accion).toBe("revisar_compra");
});

test("sin refs no inventa precio", () => {
  const out = calcPrecioSugeridoReferencias({ costo: 10, precio: 16 }, {});
  expect(out.sugerido).toBeNull();
  expect(out.nota).toMatch(/sin referencias/i);
});

test("la fila no tapa revisar_compra con un subir por pesos", () => {
  const base = {
    alerta: "piso_gt_techo",
    accion: "revisar_compra",
    sugerido: 59,
  };
  const out = resolverDecisionSugeridoFila(base, {
    precioActual: 49,
    sugeridoFinal: 59,
    margenSugerido: { tone: null },
  });
  expect(out.alerta).toBe("piso_gt_techo");
  expect(out.accion).toBe("revisar_compra");
});

test("Similares genérico no baja el techo de Contac ni pide revisar compra", () => {
  const p = {
    nombre: "Contac Ultra",
    marca: "Contac",
    tipo: "GENERICO",
    forma_farmaceutica: "tabletas",
    principio_activo: "Paracetamol + Fenilefrina + Clorfenamina",
    costo: 32.34,
    precio: 44,
  };
  const r = refs({ similares: 36 });
  r.similares.nombre_fuente = "CLORFENAMINA / FENILEFRINA / PARACETAMOL 24 TABLETAS";
  const out = calcPrecioSugeridoReferencias(p, r);
  expect(out.sugerido).toBeNull();
  expect(out.accion).toBeNull();
  expect(captionRefNoComparable(p, "similares", r.similares).texto).toMatch(/No es Contac/i);
});

test("el lote de subidas no incluye piso arriba del mercado", () => {
  const p = {
    id: 9,
    nombre: "Amoxicilina 500",
    tipo: "generico",
    forma_farmaceutica: "tableta",
    principio_activo: "Amoxicilina",
    costo: 20,
    precio: 16,
  };
  const r = { 9: refs({ similares: 18, fahorro: 30, otros_venta: 28 }) };
  const neu = calcPrecioSugeridoReferencias(p, r[9]);
  expect(neu.accion).toBe("revisar_compra");
  expect(listarSubidasSugeridas([p], r, calcPrecioSugeridoReferencias)).toHaveLength(0);
});
