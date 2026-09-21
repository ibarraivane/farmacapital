import {
  normalizarClaveMonografia,
  viaDesdeForma,
  parMonografia,
} from "./claveMonografia";

test("minúsculas, sin acentos y + entre sustancias", () => {
  expect(normalizarClaveMonografia("Amoxicilina / Ácido clavulánico")).toBe(
    "amoxicilina + acido clavulanico"
  );
  expect(normalizarClaveMonografia("omeprazol")).toBe("omeprazol");
  expect(normalizarClaveMonografia("Losartán + Hidroclorotiazida")).toBe(
    "losartan + hidroclorotiazida"
  );
});

test("acepta + y / como separadores", () => {
  expect(normalizarClaveMonografia("paracetamol+tramadol")).toBe("paracetamol + tramadol");
  expect(normalizarClaveMonografia("ibuprofeno / paracetamol")).toBe("ibuprofeno + paracetamol");
});

test("vía desde forma farmacéutica", () => {
  expect(viaDesdeForma("Cápsula")).toBe("oral");
  expect(viaDesdeForma("Tableta")).toBe("oral");
  expect(viaDesdeForma("Crema")).toBe("topica");
  expect(viaDesdeForma("Gel tópico")).toBe("topica");
  expect(viaDesdeForma("Colirio")).toBe("oftalmica");
  expect(viaDesdeForma("Gotas óticas")).toBe("otica");
  expect(viaDesdeForma("Spray nasal")).toBe("nasal");
  expect(viaDesdeForma("Óvulo vaginal")).toBe("vaginal");
  expect(viaDesdeForma("Solución inyectable")).toBe("inyectable");
  expect(viaDesdeForma("Aerosol")).toBe("inhalada");
});

test("par monografía combina clave y vía", () => {
  expect(parMonografia("Ómeprazol", "Cápsulas", "30 cápsulas")).toEqual({
    clave: "omeprazol",
    via: "oral",
  });
});
