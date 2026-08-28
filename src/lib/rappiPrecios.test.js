import {
  calcPrecioSugeridoRappi,
  precioCalleDe,
  precioFarmaciaRappiMin,
  tieneRefRappi,
} from "./rappiPrecios";

const otc = {
  id: 1,
  nombre: "Agrifen",
  categoria: "medicamento",
  tipo: "marca",
  forma_farmaceutica: "tableta",
  costo: 12,
  precio: 27,
  requiere_receta: false,
};

function refs(map) {
  const out = {};
  for (const [fuente, precio] of Object.entries(map)) {
    out[fuente] = { fuente, precio, tipo: "venta" };
  }
  return out;
}

test("el súper no baja el sugerido de Rappi", () => {
  const r = refs({
    rappi_super: 25,
    rappi_gdl: 50,
    rappi_farmatodo: 45,
    rappi_otros: 27,
  });
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.refMin).toBe(27);
  expect(out.sugerido).toBe(27);
  expect(precioFarmaciaRappiMin(r)).toBe(27);
});

test("mezcla Del Ahorro / Similares con farmacias Rappi", () => {
  const r = refs({
    fahorro: 30,
    similares: 28,
    rappi_gdl: 50,
    rappi_super: 20,
  });
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.refMin).toBe(28);
  expect(precioCalleDe(r)).toBe(28);
  expect(tieneRefRappi(r)).toBe(true);
});

test("sin refs de farmacia ni calle no sugiere", () => {
  const r = refs({ rappi_super: 22 });
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.sugerido).toBeNull();
  expect(out.nota).toMatch(/sin referencias/i);
  expect(tieneRefRappi(r)).toBe(true);
});
