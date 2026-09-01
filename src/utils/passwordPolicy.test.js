import { validarPasswordTienda, PASSWORD_MIN_LENGTH, PASSWORD_RULES_TEXT } from "./passwordPolicy";

describe("passwordPolicy", () => {
  test("el mínimo de la app es 8 caracteres", () => {
    expect(PASSWORD_MIN_LENGTH).toBe(8);
    expect(PASSWORD_RULES_TEXT).toMatch(/8/);
  });

  test("rechaza menos de 8 caracteres", () => {
    expect(validarPasswordTienda("Ab12").ok).toBe(false);
    expect(validarPasswordTienda("Abcde12").ok).toBe(false);
    expect(validarPasswordTienda("Abcde123").ok).toBe(true);
  });

  test("exige letra y número", () => {
    expect(validarPasswordTienda("12345678").ok).toBe(false);
    expect(validarPasswordTienda("abcdefgh").ok).toBe(false);
    expect(validarPasswordTienda("clave123").ok).toBe(true);
  });
});
