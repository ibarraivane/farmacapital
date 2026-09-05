/** Fixture solo para preview/tests. No es una consulta ni un parser. */
export const FLUJO_DEMO_BUNDLE = {
  configurado: true,
  desde: "2026-09-01",
  hasta: "2026-09-05",
  fecha_inicio: "2026-08-18",
  piso_aplicado: "2026-08-18",
  saldo_inicial: 282,
  origen_piso: "sesion",
  entro: -30.5,
  quedo: -210.5,
  en_caja_hoy: 1208.86,
  salio: { total: 180, medicamento: 0, nomina: 0, otros_gastos: 0, liquidacion_mp: 180 },
  completitud: { incompleta: true, mes: "2026-09", sin_compra: false },
  cubetas: {
    cajon_cobrado_servicios: 210,
    saldo_mp_liquidacion: 210,
    saldo_mp_compensacion: 2.1,
    utilidad_servicios: 2.1,
  },
  semanas: [
    { semana: "2026-08-31", entro: -30.5, medicamento: 0, nomina: 0, gastos: 0, quedo: -210.5 },
  ],
  gastos: [],
};
