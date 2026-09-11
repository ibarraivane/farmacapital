import { resolverTurnoMiDia } from "./miDiaTurno";

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
