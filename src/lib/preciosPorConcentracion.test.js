import {
  detectarPrecioIgualDistintaDosis,
  extraerMgConcentracion,
  precioPisoDosisMayor,
} from "./preciosPorConcentracion";

describe("precios por concentración", () => {
  const amsa500 = {
    sku: "FC-C721E8D7",
    nombre: "Levofloxacino",
    principio_activo: "LEVOFLOXACINO",
    concentracion: "500 MG",
    presentacion: "7 TABLETAS",
    forma_farmaceutica: "TABLETAS",
    precio: 31,
    costo: 18.77,
  };
  const bea500 = {
    sku: "FC-28833707",
    nombre: "Levofloxacino 500 mg Caja con 7 tabletas beadvance",
    principio_activo: "Levofloxacino",
    concentracion: "500 mg",
    presentacion: "Caja con 7 tabletas",
    forma_farmaceutica: "Tableta",
    precio: 31,
    costo: 18.77,
  };
  const cina750Barata = {
    sku: "FC-52200809",
    nombre: "Cina 750 mg Caja con 7 tabletas Landsteiner",
    principio_activo: "Levofloxacino",
    concentracion: "750 mg",
    presentacion: "Caja con 7 tabletas",
    forma_farmaceutica: "Tableta",
    precio: 31,
    costo: 28.87,
  };
  const cina750Ok = { ...cina750Barata, precio: 47 };

  test("lee 500 mg y 750 mg del texto", () => {
    expect(extraerMgConcentracion("500 MG")).toBe(500);
    expect(extraerMgConcentracion("Cina 750 mg")).toBe(750);
  });

  test("500 y 750 al mismo PVP es error; 750 a 47 no", () => {
    const mal = detectarPrecioIgualDistintaDosis([amsa500, bea500, cina750Barata]);
    expect(mal.some((p) => p.alto.sku === "FC-52200809" && p.mgAlto === 750)).toBe(true);
    const bien = detectarPrecioIgualDistintaDosis([amsa500, bea500, cina750Ok]);
    expect(bien).toEqual([]);
  });

  test("el piso del 750 no puede quedar en 31 si el 500 ya vale 31", () => {
    expect(precioPisoDosisMayor(31, 500, 750, 28.87)).toBeGreaterThan(31);
    expect(precioPisoDosisMayor(31, 500, 750, 28.87)).toBeGreaterThanOrEqual(47);
  });
});
