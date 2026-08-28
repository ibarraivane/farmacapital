import {
  instanteBotVentaDe,
  instanteBotVentaGlobal,
  fmtBotCuando,
  esActualizacionBot,
} from "./preciosReferencia";

test("solo cuenta refs de venta que escribió el bot", () => {
  expect(esActualizacionBot({ notas: "rastreo_automatico" })).toBe(true);
  expect(esActualizacionBot({ notas: "boton_actualizar" })).toBe(false);
  const ts = instanteBotVentaDe({
    similares: { notas: "rastreo_automatico", created_at: "2026-08-24T13:05:00.000Z" },
    fahorro: { notas: "import_csv", created_at: "2026-08-24T18:00:00.000Z" },
  });
  expect(ts).toBe(Date.parse("2026-08-24T13:05:00.000Z"));
});

test("global toma el SKU más reciente", () => {
  const g = instanteBotVentaGlobal({
    1: { similares: { notas: "rastreo_automatico", created_at: "2026-08-24T12:00:00.000Z" } },
    2: { fahorro: { notas: "rastreo_automatico", created_at: "2026-08-24T15:00:00.000Z" } },
  });
  expect(g).toBe(Date.parse("2026-08-24T15:00:00.000Z"));
  expect(fmtBotCuando(g)).toEqual(expect.any(String));
  expect(fmtBotCuando(g).length).toBeGreaterThan(4);
});
