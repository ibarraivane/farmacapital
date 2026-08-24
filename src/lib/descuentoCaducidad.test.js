import { CADUCIDAD_CONFIG } from "../config/caducidad";
import {
  diasEntre,
  evaluarDescuentoCaducidad,
  loteTienePendiente,
  planificarPropuestas,
  propuestaPendienteDuplicada,
  textoEtiquetaPrecioEspecial,
} from "./descuentoCaducidad";

const HOY = "2026-06-01";

function cadEn(dias) {
  const d = new Date(2026, 5, 1);
  d.setDate(d.getDate() + dias);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

test("diasEntre cuenta calendario, no horas", () => {
  expect(diasEntre(cadEn(75), HOY)).toBe(75);
  expect(diasEntre(cadEn(-3), HOY)).toBe(-3);
});

test("A: patente, el piso muerde", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(75),
    pvp: 850,
    costo_unitario: 700,
    existencia_lote: 6,
    rotacion_mensual: 1,
  });
  expect(r.estado).toBe("PROPONER");
  expect(r.fase).toBe(2);
  expect(r.descuento_escalon).toBe(0.2);
  expect(r.precio_calculado).toBe(680);
  expect(r.precio_piso).toBe(700);
  expect(r.precio_propuesto).toBe(700);
  expect(r.descuento_efectivo_pct).toBe(17.6);
  expect(r.margen_resultante).toBeCloseTo(0, 5);
});

test("B: genérico, aún con ganancia", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(45),
    pvp: 120,
    costo_unitario: 66,
    existencia_lote: 20,
    rotacion_mensual: 3,
  });
  expect(r.estado).toBe("PROPONER");
  expect(r.fase).toBe(3);
  expect(r.precio_propuesto).toBe(78);
  expect(r.precio_piso).toBeCloseTo(56.1, 5);
  expect(r.margen_resultante).toBeCloseTo(0.154, 3);
});

test("C: OTC en rescate", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(20),
    pvp: 89,
    costo_unitario: 55,
    existencia_lote: 40,
    rotacion_mensual: 4,
  });
  expect(r.estado).toBe("PROPONER");
  expect(r.fase).toBe(4);
  expect(r.precio_propuesto).toBe(44.5);
  expect(r.precio_piso).toBeCloseTo(35.75, 5);
  expect(r.perdida_pieza).toBeCloseTo(10.5, 5);
});

test("D: se vende solo", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(100),
    pvp: 100,
    costo_unitario: 60,
    existencia_lote: 5,
    rotacion_mensual: 3,
  });
  expect(r.estado).toBe("SIN_ACCION");
  expect(r.propuesta).toBe(false);
  expect(r.cobertura_meses).toBeCloseTo(5 / 3, 2);
});

test("E: canje vigente", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(200),
    pvp: 100,
    costo_unitario: 60,
    existencia_lote: 10,
    rotacion_mensual: 0,
    canje_elegible: true,
    canje_ventana_dias: CADUCIDAD_CONFIG.canje_ventana_dias,
  });
  expect(r.estado).toBe("CANJE");
  expect(r.propuesta).toBe(false);
});

test("F: costo faltante", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(40),
    pvp: 100,
    costo_unitario: null,
    existencia_lote: 8,
    rotacion_mensual: 1,
  });
  expect(r.estado).toBe("DATO_FALTANTE");
  expect(r.propuesta).toBe(false);
});

test("G: ya caducado", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: cadEn(-3),
    pvp: 100,
    costo_unitario: 60,
    existencia_lote: 4,
    rotacion_mensual: 1,
  });
  expect(r.estado).toBe("RETIRAR");
  expect(r.propuesta).toBe(false);
  expect(r.alerta).toBe(true);
});

test("H: job dos veces el mismo día no duplica pendiente", () => {
  const lote = {
    id: 99,
    producto_id: 7,
    fecha_caducidad: cadEn(45),
    cantidad_actual: 20,
    costo_unitario: 66,
    pvp: 120,
  };
  const rotacionPorProducto = { 7: 3 };
  const first = planificarPropuestas({
    hoy: HOY,
    lotes: [lote],
    rotacionPorProducto,
    existentes: [],
    rechazadas: [],
  });
  expect(first.inserts).toHaveLength(1);
  expect(first.inserts[0].lote_id).toBe(99);

  const second = planificarPropuestas({
    hoy: HOY,
    lotes: [lote],
    rotacionPorProducto,
    existentes: [{ lote_id: 99, estado: "PENDIENTE", fecha_job: HOY, fase: 3 }],
    rechazadas: [],
  });
  expect(second.inserts).toHaveLength(0);
  expect(propuestaPendienteDuplicada(second.inserts.concat([{ lote_id: 99, estado: "PENDIENTE", fecha_job: HOY }]), 99, HOY)).toBe(true);
  expect(loteTienePendiente([{ lote_id: 99, estado: "PENDIENTE" }], 99)).toBe(true);
});

test("etiqueta incluye caducidad visible", () => {
  const txt = textoEtiquetaPrecioEspecial({
    descripcion: "Tempra 500 mg",
    pvp: 850,
    precio_propuesto: 700,
    descuento_efectivo: 0.176,
    fecha_caducidad: "2026-08-31",
  });
  expect(txt).toContain("PRECIO ESPECIAL");
  expect(txt).toContain("Tempra 500 mg");
  expect(txt).toContain("Antes $850.00");
  expect(txt).toContain("Ahora $700.00");
  expect(txt).toContain("Ahorra 17.6%");
  expect(txt).toMatch(/Caduca:/);
});

test("lote sin fecha no entra", () => {
  const r = evaluarDescuentoCaducidad({
    hoy: HOY,
    fecha_caducidad: null,
    pvp: 100,
    costo_unitario: 60,
    existencia_lote: 4,
  });
  expect(r.estado).toBe("SIN_CADUCIDAD");
  expect(r.propuesta).toBe(false);
});
