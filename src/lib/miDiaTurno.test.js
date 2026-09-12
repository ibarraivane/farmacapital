import {
  resolverTurnoMiDia,
  resolverVentanaVentasMiDia,
  resolverTurnosMetaHoy,
} from "./miDiaTurno";

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

  test("caja abierta manda sobre el perfil (cobertura matutino)", () => {
    expect(
      resolverTurnoMiDia({
        jornada: { turno_habitual: "vespertino" },
        sesionCaja: { abierta: true, turno: "matutino" },
        usuario: { turno: "vespertino" },
        now: manana,
      })
    ).toEqual({ turno: "matutino", cubreAmbos: false, fuente: "caja" });
  });

  test("cobertura puntual usa turno_abrir", () => {
    expect(
      resolverTurnoMiDia({
        jornada: {
          turno_habitual: "vespertino",
          turno_abrir: "matutino",
          cobertura: true,
        },
        usuario: { turno: "vespertino" },
        now: manana,
      })
    ).toEqual({ turno: "matutino", cubreAmbos: false, fuente: "cobertura" });
  });

  test("dos sesiones hoy = cubre ambos", () => {
    expect(
      resolverTurnoMiDia({
        jornada: {
          turno_habitual: "vespertino",
          turnos_hoy: ["matutino", "vespertino"],
        },
        now: manana,
      })
    ).toEqual({ turno: null, cubreAmbos: true, fuente: "sesiones_hoy" });
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
});

describe("resolverTurnosMetaHoy", () => {
  const manana = new Date("2026-09-11T15:00:00.000Z");

  test("sesión matutina de vespertina: solo meta matutina", () => {
    expect(
      resolverTurnosMetaHoy({
        jornada: { turno_habitual: "vespertino", cobertura: true, turnos_hoy: ["matutino"] },
        sesionCaja: { abierta: true, turno: "matutino" },
        now: manana,
      })
    ).toEqual({ turnos: ["matutino"], cubreAmbos: false, fuente: "sesiones_hoy" });
  });

  test("cubre_ambos suma ambas metas", () => {
    expect(
      resolverTurnosMetaHoy({
        jornada: { cubre_ambos: true, turno_habitual: "vespertino" },
        now: manana,
      }).turnos
    ).toEqual(["matutino", "vespertino"]);
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
    expect(new Date("2026-09-11T15:06:00.000Z").getTime()).toBeGreaterThanOrEqual(new Date(v.inicio).getTime());
    expect(new Date("2026-09-11T15:06:00.000Z").getTime()).toBeLessThanOrEqual(new Date(v.fin).getTime());
  });
});
