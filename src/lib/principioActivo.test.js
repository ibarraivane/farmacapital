import {
  completarPrincipioActivo,
  esSoloConcentracionPrincipio,
  inferirPrincipioActivoDesdeNombre,
  opcionesPrincipioActivo,
  productoPasaFiltroPrincipioActivo,
  textoPrincipioActivo,
} from "./principioActivo";
import {
  categoriaRequierePrincipioActivo,
  productoFaltaPrincipioActivo,
  productoRequierePrincipioActivo,
  productoTienePrincipioActivo,
} from "../constants/categoriasProducto";

test("infiere el genérico entre paréntesis y no toma público ni dosis", () => {
  expect(inferirPrincipioActivoDesdeNombre("Eferox (Cefalexina)")).toBe("Cefalexina");
  expect(inferirPrincipioActivoDesdeNombre("Infamid (Metamizol + Dexametasona)")).toBe("Metamizol + Dexametasona");
  expect(inferirPrincipioActivoDesdeNombre("Desodorante Axe (Hombre)")).toBe("");
  expect(inferirPrincipioActivoDesdeNombre("Tempra (500 mg)")).toBe("");
  expect(inferirPrincipioActivoDesdeNombre("Ampicilina (inyectable)")).toBe("");
});

test("texto usa el campo, luego denominación, luego el nombre", () => {
  expect(textoPrincipioActivo({ principio_activo: "Paracetamol" })).toBe("Paracetamol");
  expect(textoPrincipioActivo({ principio_activo: "500 mg", denominacion_generica: "Paracetamol" })).toBe("Paracetamol");
  expect(textoPrincipioActivo({ nombre: "Bactiver (Sulfametoxazol / Trimetoprima)" })).toBe("Sulfametoxazol / Trimetoprima");
  expect(completarPrincipioActivo({ nombre: "Cina (Ciprofloxacino)" })).toBe("Ciprofloxacino");
});

test("el filtro de compras/reabasto agrupa por principio", () => {
  const para = { nombre: "Tempra", principio_activo: "Paracetamol" };
  const combo = { nombre: "Agrifen", principio_activo: "Paracetamol / Cafeína / Clorfenamina" };
  const jabon = { nombre: "Jabón", categoria: "Higiene" };
  expect(productoPasaFiltroPrincipioActivo(para, "paracetamol")).toBe(true);
  expect(productoPasaFiltroPrincipioActivo(combo, "paracetamol")).toBe(true);
  expect(productoPasaFiltroPrincipioActivo(jabon, "paracetamol")).toBe(false);
  expect(productoPasaFiltroPrincipioActivo(jabon, "sin")).toBe(true);
  expect(productoPasaFiltroPrincipioActivo(para, "sin")).toBe(false);
  expect(opcionesPrincipioActivo([para, combo, jabon]).map((o) => o.label)).toEqual([
    "Paracetamol",
    "Paracetamol / Cafeína / Clorfenamina",
  ]);
});

test("medicamentos piden principio activo; higiene no", () => {
  expect(categoriaRequierePrincipioActivo("Antibiótico")).toBe(true);
  expect(categoriaRequierePrincipioActivo("Analgésico")).toBe(true);
  expect(categoriaRequierePrincipioActivo("Higiene")).toBe(false);
  expect(categoriaRequierePrincipioActivo("Abarrotes")).toBe(false);
  expect(productoRequierePrincipioActivo({ categoria: "Otro", tipo: "generico" })).toBe(true);
  expect(productoRequierePrincipioActivo({ categoria: "Otro", forma_farmaceutica: "Tabletas" })).toBe(true);
  expect(productoRequierePrincipioActivo({ categoria: "Higiene", tipo: "marca" })).toBe(false);
  expect(productoTienePrincipioActivo({ principio_activo: "Amoxicilina" })).toBe(true);
  expect(productoFaltaPrincipioActivo({ categoria: "Antibiótico" })).toBe(true);
  expect(productoFaltaPrincipioActivo({ categoria: "Antibiótico", principio_activo: "Cefalexina" })).toBe(false);
  expect(productoFaltaPrincipioActivo({ categoria: "Higiene" })).toBe(false);
});

test("una dosis suelta no cuenta como principio", () => {
  expect(esSoloConcentracionPrincipio("500 mg")).toBe(true);
  expect(esSoloConcentracionPrincipio("Paracetamol")).toBe(false);
});
