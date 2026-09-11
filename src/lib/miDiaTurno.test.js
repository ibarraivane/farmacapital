import { resolverTurnoMiDia, resolverVentanaVentasMiDia } from "./miDiaTurno";

describe("resolverTurnoMiDia", () => {
  const manana = new Date("2026-09-11T15:00:00.000Z"); // 09:00 CDMX

  test("cubre ambos gana", () => {
    expect(
      resolverTurnoMiDia({
        jornada: { cubre_ambos: true, turno_habitual: "matutino" },
        usuario: { turno: "vespertino" },
        now: manana,
      })
    ).toEqual({ turno: null, cubreAmbos: true, fuente: "cubre_ambos" });
  });

  test("caja abierta manda sobre el perfil", () => {
    expect(
      resolverTurnoMiDia({
        jornada: { turno_habitual: "vespertino" },
        sesionCaja: { abierta: true, turno: "matutino" },
        usuario: { turno: "vespertino" },
        now: manana,
      })
    ).toEqual({ turno: "matutino", cubreAmbos: false, fuente: "caja" });
  });

  test("sin caja usa turno habitual / perfil", () => {
    expect(
      resolverTurnoMiDia({
        jornada: { turno_habitual: "matutino" },
        usuario: { turno: "vespertino" },
        now: manana,
      }).turno
    ).toBe("matutino");
  });

  test("sin perfil infiere por reloj", () => {
    expect(
      resolverTurnoMiDia({ jornada: null, usuario: {}, now: manana })
    ).toEqual({ turno: "matutino", cubreAmbos: false, fuente: "reloj" });
  });
});

describe("resolverVentanaVentasMiDia", () => {
  const diaRango = {
    start: "2026-09-11T06:00:00.000Z", // 00:00 CDMX
    end: "2026-09-12T06:00:00.000Z",
  };

  test("caja abierta usa abierta_at → ahora", () => {
    const v = resolverVentanaVentasMiDia({
      sesionCaja: { abierta: true, abierta_at: "2026-09-11T14:05:00.000Z", turno: "matutino" },
      diaRango,
      turno: "vespertino",
    });
    expect(v.fuente).toBe("caja_abierta");
    expect(v.inicio).toBe("2026-09-11T14:05:00.000Z");
    expect(new Date(v.fin).getTime()).toBeGreaterThan(new Date(v.inicio).getTime());
  });

  test("sin caja: día completo aunque el perfil sea vespertino", () => {
    const v = resolverVentanaVentasMiDia({
      sesionCaja: null,
      diaRango,
      turno: "vespertino",
      cubreAmbos: false,
    });
    expect(v.fuente).toBe("dia_completo");
    expect(v.inicio).toBe(diaRango.start);
    // Incluye ventas ~09:06 CDMX (15:06Z)
    expect(new Date("2026-09-11T15:06:00.000Z").getTime()).toBeGreaterThanOrEqual(new Date(v.inicio).getTime());
    expect(new Date("2026-09-11T15:06:00.000Z").getTime()).toBeLessThanOrEqual(new Date(v.fin).getTime());
  });
});
