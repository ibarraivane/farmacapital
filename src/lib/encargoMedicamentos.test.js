import {
  ENCARGO_ESTADOS,
  ENCARGO_ESTADOS_OPERATIVOS_VENDEDOR,
  COTIZACION_DISPONIBILIDAD,
  TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT,
  calcularVigenciaHasta,
  cotizacionVigente,
  metodoEntregaPermitido,
  validarAvisoDisponibilidad,
  validarEncargoPublico,
  validarCotizacionAdmin,
  puedeMarcarEncargoAceptado,
  buildAvisoDisponibilidadWhatsApp,
  buildCotizacionWhatsApp,
  tiempoVigenciaCotizacionDiasFromEnv,
} from "./encargoMedicamentos";

test("vigencia default = 3 días y respeta env", () => {
  expect(TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT).toBe(3);
  expect(tiempoVigenciaCotizacionDiasFromEnv({})).toBe(3);
  expect(tiempoVigenciaCotizacionDiasFromEnv({ TIEMPO_VIGENCIA_COTIZACION_DIAS: "5" })).toBe(5);
  const from = new Date("2026-09-15T12:00:00.000Z");
  const until = calcularVigenciaHasta(from, 3);
  expect(until.toISOString()).toBe("2026-09-18T12:00:00.000Z");
});

test("cotizacionVigente solo si enviada y no vencida", () => {
  const future = new Date(Date.now() + 86400000).toISOString();
  const past = new Date(Date.now() - 86400000).toISOString();
  expect(cotizacionVigente({ vigencia_hasta: future, estado: "enviada" })).toBe(true);
  expect(cotizacionVigente({ vigencia_hasta: past, estado: "enviada" })).toBe(false);
  expect(cotizacionVigente({ vigencia_hasta: future, estado: "aceptada" })).toBe(false);
});

test("cadena fría bloquea domicilio automático", () => {
  expect(
    metodoEntregaPermitido({ requiere_cadena_fria: true, metodo_entrega: "domicilio" }).ok,
  ).toBe(false);
  expect(
    metodoEntregaPermitido({
      requiere_cadena_fria: true,
      metodo_entrega: "entrega_personalizada",
    }).ok,
  ).toBe(true);
  expect(
    metodoEntregaPermitido({ requiere_cadena_fria: false, metodo_entrega: "domicilio" }).ok,
  ).toBe(true);
});

test("aviso: payload listo para dedupe y teléfono 10 dígitos", () => {
  const bad = validarAvisoDisponibilidad({ producto_id: 1, telefono: "123" });
  expect(bad.ok).toBe(false);
  const ok = validarAvisoDisponibilidad({
    producto_id: 42,
    nombre: "Ana",
    telefono: "55-1234-5678",
  });
  expect(ok.ok).toBe(true);
  expect(ok.value.cliente_telefono).toBe("5512345678");
  expect(ok.value.producto_id).toBe(42);
});

test("encargo público exige receta_url si requiere_receta", () => {
  const sin = validarEncargoPublico({
    nombre: "Luis",
    telefono: "5512345678",
    nombre_medicamento: "Exkutera",
    cantidad: 1,
    requiere_receta: true,
  });
  expect(sin.ok).toBe(false);
  const con = validarEncargoPublico({
    nombre: "Luis",
    telefono: "5512345678",
    nombre_medicamento: "Exkutera",
    cantidad: 2,
    requiere_receta: true,
    receta_url: "https://example.com/receta.jpg",
  });
  expect(con.ok).toBe(true);
  expect(con.value.cantidad).toBe(2);
});

test("cotización admin valida disponibilidad del SQL", () => {
  expect(COTIZACION_DISPONIBILIDAD).toEqual([
    "disponible",
    "sujeto_a_confirmacion",
    "no_disponible",
  ]);
  const bad = validarCotizacionAdmin({
    precio_unitario: 100,
    cantidad: 2,
    tiempo_estimado_dias: 3,
    disponibilidad: "inventada",
  });
  expect(bad.ok).toBe(false);
  const ok = validarCotizacionAdmin({
    precio_unitario: 100.5,
    cantidad: 2,
    tiempo_estimado_dias: 3,
    disponibilidad: "sujeto_a_confirmacion",
    requiere_cadena_fria: true,
  });
  expect(ok.ok).toBe(true);
  expect(ok.value.precio_total).toBe(201);
});

test("no aceptar encargo sin cotización aceptada", () => {
  expect(puedeMarcarEncargoAceptado({ cotizacion_estado: "enviada" })).toBe(false);
  expect(puedeMarcarEncargoAceptado({ cotizacion_estado: "aceptada" })).toBe(true);
});

test("estados operativos vendedor no incluyen cotizar", () => {
  expect(ENCARGO_ESTADOS_OPERATIVOS_VENDEDOR).toEqual([
    "consiguiendo",
    "listo_para_entrega",
    "entregado",
  ]);
  expect(ENCARGO_ESTADOS).toContain("pendiente_cotizacion");
  expect(ENCARGO_ESTADOS_OPERATIVOS_VENDEDOR).not.toContain("cotizado");
});

test("builders wa.me 1:1 con texto precargado", () => {
  const a = buildAvisoDisponibilidadWhatsApp({
    telefono: "5512345678",
    nombre: "Ana",
    producto_nombre: "Paracetamol 500mg",
  });
  expect(a.startsWith("https://wa.me/525512345678?text=")).toBe(true);
  expect(decodeURIComponent(a)).toContain("Paracetamol 500mg");

  const c = buildCotizacionWhatsApp({
    telefono: "5512345678",
    nombre: "Luis",
    nombre_medicamento: "Exkutera",
    precio_total: 1250,
    tiempo_estimado_dias: 3,
    vigencia_hasta: "2026-09-18T12:00:00.000Z",
    accept_url: "https://farmacapital.mx/encargo/aceptar?t=abc",
  });
  expect(c.startsWith("https://wa.me/525512345678?text=")).toBe(true);
  expect(decodeURIComponent(c)).toContain("Exkutera");
  expect(decodeURIComponent(c)).toContain("aceptar");
});
