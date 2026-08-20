import { diagnosisFromPointStatus, formatSupportPacketText, serialFromTerminalId } from "./mpPointSupport";

test("serial extrae el número físico del terminal_id", () => {
  expect(serialFromTerminalId("NEWLAND_N950__N950NCCC05728001")).toBe("N950NCCC05728001");
});

test("diagnóstico: created tras espera indica que el Point no sincroniza", () => {
  expect(
    diagnosisFromPointStatus({
      operatingMode: "PDV",
      pendingCount: 0,
      orderStatusAfterWait: "created",
    })
  ).toMatch(/no sincroniza/i);
});

test("diagnóstico: cola pendiente pide liberación a MP", () => {
  expect(diagnosisFromPointStatus({ operatingMode: "PDV", pendingCount: 7 })).toMatch(/7 cobro/);
});

test("paquete de soporte incluye IDs y nota física", () => {
  const text = formatSupportPacketText({
    ticket: "WCS-43806 / 470711389",
    comercio: "FarmaCapital",
    terminal_id: "NEWLAND_N950__N950NCCC05728001",
    store_id: "84680678",
    pos_id: 135063974,
    external_pos_id: "",
    operating_mode: "PDV",
    pending_count: 0,
    nota: "El terminal permanece encendido, en modo PDV/activado y con conexión estable.",
  });
  expect(text).toContain("store_id: 84680678");
  expect(text).toContain("pos_id: 135063974");
  expect(text).toContain("(vacío)");
  expect(text).toContain("permanece encendido");
});
