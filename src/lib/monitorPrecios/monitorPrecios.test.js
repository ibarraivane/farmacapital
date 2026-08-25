import {
  MONITOR_PRECIOS_CONFIG,
  crearRegistroCrudo,
  normalizarRegistro,
  normalizarNombreCrudo,
  recolectarTodas,
  crearAdaptadorDistribuidor,
  crearAdaptadorProfecoQqp,
  emparejarSku,
  validarRespuestaModelo,
  indexarCache,
  evaluarAnomalia,
  mediana,
  consolidarReferencia,
  calcularPvpSugerido,
  generarPropuesta,
  correrPipeline,
} from "./index";

const HOY = "2026-08-24T12:00:00.000Z";

function crudo(over) {
  return crearRegistroCrudo({
    fuente: "profeco_qqp",
    tipo: "venta",
    nombre_crudo: "PARACETAMOL 500MG C/10 TABS",
    precio: 50,
    moneda: "MXN",
    url_origen: "https://datos.profeco.gob.mx/datos_abiertos/qqp.php",
    fecha_captura: HOY,
    ...over,
  });
}

function productoPara(over) {
  return {
    id: 1,
    sku: "FC-PARA-500",
    nombre: "Paracetamol 500 mg 10 tabletas",
    marca: null,
    principio_activo: "paracetamol",
    concentracion: "500 mg",
    forma_farmaceutica: "tableta",
    presentacion: "Caja con 10",
    unidades_por_caja: 10,
    codigo_barras: null,
    costo: 30,
    precio: 80,
    tipo: "generico",
    requiere_receta: false,
    stock: 20,
    ...over,
  };
}

test("A: normalizar PARACETAMOL 500MG C/10 TABS", () => {
  const n = normalizarNombreCrudo("PARACETAMOL 500MG C/10 TABS");
  expect(n.sustancia_activa).toBe("paracetamol");
  expect(n.concentracion_valor).toBe(500);
  expect(n.concentracion_unidad).toBe("mg");
  expect(n.forma_farmaceutica).toBe("tableta");
  expect(n.piezas_por_empaque).toBe(10);
});

test("B: caja de 10 a $50 vs caja de 30 a $135 — gana la de 30 por pieza", () => {
  const a = normalizarRegistro(crudo({ precio: 50, nombre_crudo: "PARACETAMOL 500MG C/10 TABS" }));
  const b = normalizarRegistro(crudo({
    precio: 135,
    nombre_crudo: "PARACETAMOL 500MG C/30 TABS",
  }));
  expect(a.estado_norm).toBe("NORMALIZADO");
  expect(b.estado_norm).toBe("NORMALIZADO");
  expect(a.precio_unitario).toBe(5);
  expect(b.precio_unitario).toBe(4.5);
  expect(b.precio_unitario).toBeLessThan(a.precio_unitario);
});

test("sin piezas → NO_NORMALIZABLE", () => {
  const n = normalizarRegistro(crudo({ nombre_crudo: "PARACETAMOL 500MG" }));
  expect(n.estado_norm).toBe("NO_NORMALIZABLE");
  expect(n.precio_unitario).toBeNull();
});

test("C: salto de 4.50 a 9.00 es ANOMALIA y no actualiza", () => {
  const r = evaluarAnomalia(9, 4.5, 0.4);
  expect(r.estado).toBe("ANOMALIA_POR_REVISAR");
  expect(r.actualizar).toBe(false);
});

test("D: mediana ignora el 22.00", () => {
  expect(mediana([4.4, 4.5, 4.6, 22])).toBe(4.55);
});

test("E: confianza 0.70 → POR_VERIFICAR y no entra a la referencia", async () => {
  const producto = productoPara();
  const cap = normalizarRegistro(crudo({ fuente: "profeco_qqp" }));
  const { mapeos, llamadasModelo } = await emparejarSku(producto, [cap], {
    llamarModelo: async () => ({
      indice_elegido: 0,
      confianza: 0.7,
      razon: "misma sustancia y forma; presentación dudosa",
    }),
  });
  expect(llamadasModelo).toBe(1);
  expect(mapeos[0].estado).toBe("POR_VERIFICAR");

  const pipe = await correrPipeline({
    adaptadores: [crearAdaptadorProfecoQqp({ filas: [cap], url_origen: cap.url_origen, fecha_captura: HOY })],
    catalogo: [producto],
    llamarModelo: async () => ({
      indice_elegido: 0,
      confianza: 0.7,
      razon: "misma sustancia y forma; presentación dudosa",
    }),
    ahora: new Date(HOY),
  });
  expect(pipe.referencia_vigente).toHaveLength(0);
  expect(pipe.propuestas).toHaveLength(0);
});

test("F: GTIN coincidente → confianza 1.0 y cero llamadas al modelo", async () => {
  const producto = productoPara({ codigo_barras: "7501234567890" });
  const cap = normalizarRegistro(crudo({ gtin_fuente: "07501234567890" }));
  let llamadas = 0;
  const { mapeos, llamadasModelo } = await emparejarSku(producto, [cap], {
    llamarModelo: async () => {
      llamadas += 1;
      throw new Error("no se debe llamar al modelo");
    },
  });
  expect(llamadasModelo).toBe(0);
  expect(llamadas).toBe(0);
  expect(mapeos[0].confianza).toBe(1);
  expect(mapeos[0].metodo).toBe("GTIN");
  expect(mapeos[0].estado).toBe("ACEPTADO");
});

test("G: sugerido bajo el piso de margen devuelve el piso", () => {
  const producto = productoPara({ costo: 40, tipo: "generico" });
  const r = calcularPvpSugerido({
    producto,
    referencia_unitaria: 2,
    piezas_por_empaque: 10,
  });
  expect(r.piso).toBe(50);
  expect(r.pvp_sugerido).toBe(50);
  expect(r.motivo).toBe("piso_margen");
});

test("H: segunda corrida con caché lleno → cero llamadas al modelo", async () => {
  const producto = productoPara();
  const cap = normalizarRegistro(crudo());
  let llamadas = 0;
  const modelo = async () => {
    llamadas += 1;
    return {
      indice_elegido: 0,
      confianza: 0.91,
      razon: "misma sustancia, concentración y presentación",
    };
  };
  const primero = await emparejarSku(producto, [cap], { llamarModelo: modelo });
  expect(primero.llamadasModelo).toBe(1);
  const cache = indexarCache(primero.mapeos);
  const segundo = await emparejarSku(producto, [cap], { llamarModelo: modelo, cache });
  expect(segundo.llamadasModelo).toBe(0);
  expect(llamadas).toBe(1);

  const pipe2 = await correrPipeline({
    adaptadores: [crearAdaptadorProfecoQqp({ filas: [cap], url_origen: cap.url_origen, fecha_captura: HOY })],
    catalogo: [producto],
    mapeosCache: primero.mapeos,
    llamarModelo: modelo,
    ahora: new Date(HOY),
  });
  expect(pipe2.llamadas_modelo).toBe(0);
});

test("I: un adaptador lanza y el resto del pipeline completa", async () => {
  const producto = productoPara({ codigo_barras: "7501234567890", precio: 80, costo: 30 });
  const bueno = crearAdaptadorProfecoQqp({
    filas: [{
      producto: "PARACETAMOL 500MG C/10 TABS",
      precio: 48,
      ean: "7501234567890",
      fecha: HOY,
    }],
    url_origen: "https://datos.profeco.gob.mx/datos_abiertos/qqp.php",
    fecha_captura: HOY,
  });
  const roto = {
    id: "fuente_rota",
    tipo: "venta",
    async obtener() {
      throw new Error("timeout_fuente");
    },
  };
  const out = await recolectarTodas([roto, bueno]);
  expect(out.errores).toHaveLength(1);
  expect(out.errores[0].fuente).toBe("fuente_rota");
  expect(out.registros.length).toBeGreaterThan(0);

  const pipe = await correrPipeline({
    adaptadores: [roto, bueno],
    catalogo: [producto],
    llamarModelo: async () => {
      throw new Error("no modelo en GTIN");
    },
    ahora: new Date(HOY),
  });
  expect(pipe.errores_fuente).toHaveLength(1);
  expect(pipe.capturas.length).toBeGreaterThan(0);
  expect(pipe.mapeos[0].metodo).toBe("GTIN");
  expect(pipe.referencia_vigente.length).toBe(1);
});

test("JSON del modelo inválido se descarta", () => {
  expect(validarRespuestaModelo({ indice_elegido: 0, confianza: 0.9 }, 3)).toBeNull();
  expect(validarRespuestaModelo({
    indice_elegido: 9,
    confianza: 0.9,
    razon: "ok",
  }, 3)).toBeNull();
  expect(validarRespuestaModelo({
    indice_elegido: 1,
    confianza: 0.91,
    razon: "misma sustancia",
    extra: true,
  }, 3)).toBeNull();
  expect(validarRespuestaModelo({
    indice_elegido: 1,
    confianza: 0.91,
    razon: "misma sustancia",
  }, 3)).toEqual({
    indice_elegido: 1,
    confianza: 0.91,
    razon: "misma sustancia",
  });
});

test("lista de distribuidor parsea CSV sin inventar precios", async () => {
  const csv = [
    "nombre,precio,ean",
    "PARACETAMOL 500MG C/10 TABS,41.5,7501111111111",
  ].join("\n");
  const adapter = crearAdaptadorDistribuidor({
    csvText: csv,
    url_origen: "archivo:nadro_20260824.csv",
    fecha_captura: HOY,
  });
  const filas = await adapter.obtener();
  expect(filas).toHaveLength(1);
  expect(filas[0].precio).toBe(41.5);
  expect(filas[0].url_origen).toBe("archivo:nadro_20260824.csv");
  expect(filas[0].fuente).toBe("lista_distribuidor");
});

test("registro crudo exige URL y fecha; el precio no se inventa", () => {
  expect(() => crearRegistroCrudo({
    fuente: "x",
    nombre_crudo: "a",
    precio: 1,
    url_origen: "",
    fecha_captura: HOY,
  })).toThrow("registro_sin_url_origen");
});

test("propuesta solo si el delta supera 5% o $10", () => {
  const producto = productoPara({ precio: 49, costo: 30, stock: 10 });
  const ref = {
    precio_unitario_mediana: 4.9,
    n_fuentes: 2,
    fecha_dato_mas_reciente: HOY,
  };
  expect(generarPropuesta(producto, ref)).toBeNull();
  const lejos = generarPropuesta({ ...producto, precio: 80 }, ref);
  expect(lejos).not.toBeNull();
  expect(lejos.pvp_sugerido).toBeGreaterThan(0);
});

test("consolidar usa mediana de venta y descarta compra", () => {
  const rows = [
    { sku: "FC-PARA-500", fuente: "profeco_qqp", tipo: "venta", precio_unitario: 4.4, fecha_captura: HOY, estado: "VIGENTE" },
    { sku: "FC-PARA-500", fuente: "datos_gob_patente", tipo: "venta", precio_unitario: 4.6, fecha_captura: HOY, estado: "VIGENTE" },
    { sku: "FC-PARA-500", fuente: "lista_distribuidor", tipo: "compra", precio_unitario: 3.1, fecha_captura: HOY, estado: "VIGENTE" },
  ];
  const [v] = consolidarReferencia(rows, { ahora: new Date(HOY) });
  expect(v.n_fuentes).toBe(2);
  expect(v.precio_unitario_mediana).toBe(4.5);
});

test("config no pide al modelo un precio", () => {
  expect(MONITOR_PRECIOS_CONFIG.umbral_anomalia).toBe(0.4);
  expect(MONITOR_PRECIOS_CONFIG.margen_minimo.patente).toBe(0.12);
});
