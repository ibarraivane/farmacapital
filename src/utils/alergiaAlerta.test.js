import { alergiasQueCruzan, tokensAlergia, mensajeAlertaAlergia } from "./alergiaAlerta";

describe("alergiaAlerta (C2)", () => {
  test("tokeniza alergias y ignora 'ninguna'", () => {
    expect(tokensAlergia("Penicilina, AINES; ninguna")).toEqual(["penicilina", "aines"]);
  });

  test("cruza penicilina con amoxicilina+ácido clavulánico si el token está en el nombre", () => {
    expect(alergiasQueCruzan("penicilina", "Penicilina G sódica")).toEqual(["penicilina"]);
    expect(alergiasQueCruzan("ibuprofeno", "Paracetamol 500 mg")).toEqual([]);
  });

  test("mensaje vacío si no hay cruce", () => {
    expect(mensajeAlertaAlergia([])).toBe("");
    expect(mensajeAlertaAlergia(["penicilina"])).toMatch(/penicilina/);
  });
});
