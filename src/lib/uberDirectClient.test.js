import { formatUberEta, formatUberFee, explainUberQuoteError } from "./uberDirectClient";

describe("uberDirectClient display", () => {
  test("formatea pesos", () => {
    expect(formatUberFee(72.5)).toBe("$72.50");
    expect(formatUberFee(null)).toBe("$0.00");
  });

  test("arma rango de tiempo", () => {
    expect(formatUberEta({ duration_min: 40 })).toBe("30–46 min");
    expect(formatUberEta({ duration_min: 0 })).toBe(null);
  });

  test("explica secreto faltante y preview protegido", () => {
    expect(explainUberQuoteError("not_configured")).toMatch(/Client Secret/i);
    expect(explainUberQuoteError({ message: "Protected deployment", code: "401" })).toMatch(/protegido/i);
  });

  test("explica fallo de dirección sin pedir alcaldía", () => {
    expect(explainUberQuoteError("uber_api_failed", "address not found")).toMatch(/sin alcaldía/i);
  });

  test("explica zona no entregable de Uber Direct sin empujar pick-up", () => {
    const msg = explainUberQuoteError(
      "uber_api_failed",
      "The specified location is not in a deliverable area."
    );
    expect(msg).toMatch(/no cubre|Iztapalapa|WhatsApp/i);
    expect(msg).not.toMatch(/pick-up|recoger/i);
  });

  test("el fallo genérico no ofrece recoger en farmacia", () => {
    const msg = explainUberQuoteError("");
    expect(msg).toMatch(/WhatsApp/i);
    expect(msg).not.toMatch(/pick-up|recoger/i);
  });
});
