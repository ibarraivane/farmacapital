import {
  calcPrecioSugeridoRappi,
  listarSubidasRappi,
  precioCalleDe,
  precioFarmaciaRappiMin,
  tienePackRappiDistinto,
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
  expect(precioFarmaciaRappiMin(otc, r)).toBe(27);
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
  expect(precioCalleDe(otc, r)).toBe(28);
  expect(tieneRefRappi(r)).toBe(true);
});

test("Ensure: el 6-pack de Rappi no mueve el sugerido", () => {
  const ensure = {
    nombre: "Ensure vainilla",
    presentacion: "236 ML",
    categoria: "suplemento",
    tipo: "marca",
    costo: 42,
    precio: 65,
  };
  const r = refs({
    rappi_gdl: 542.99,
    rappi_benavides: 405,
    rappi_otros: 393,
    rappi_super: 354,
    otros_venta: 66,
  });
  r.rappi_gdl.nombre_fuente = "Ensure Regular Vainilla 6 Pack 237 ml";
  r.rappi_benavides.nombre_fuente = "Ensure 6 pack";
  r.rappi_otros.nombre_fuente = "Ensure Clinical 16 pzas";
  r.rappi_super.nombre_fuente = "Ensure 24 pack";
  const out = calcPrecioSugeridoRappi(ensure, r);
  expect(precioFarmaciaRappiMin(ensure, r)).toBeNull();
  expect(tienePackRappiDistinto(ensure, r)).toBe(true);
  expect(out.refMin).toBe(66);
  expect(out.sugerido).toBe(65);
  expect(out.nota).toMatch(/otro empaque/i);
});

test("Calle Advance o dieta genérica no cuentan para Ensure Regular", () => {
  const ensure = {
    nombre: "Ensure vainilla",
    marca: "Ensure",
    presentacion: "236 ML",
    categoria: "suplemento",
    tipo: "marca",
    costo: 42,
    precio: 65,
  };
  const r = refs({
    otros_venta: 66,
    similares: 38.62,
  });
  r.otros_venta.notas = "Vitau.mx - Ensure Advance 237ml (referencia similar)";
  r.similares.notas = "No se encontro marca Ensure; Similares maneja DIETA POLIMERICA chocolate 236ML";
  const out = calcPrecioSugeridoRappi(ensure, r);
  expect(precioCalleDe(ensure, r)).toBeNull();
  expect(out.sugerido).toBeNull();
});

test("el lote solo lista subidas, nunca bajadas", () => {
  const barato = { ...otc, id: 1, precio: 20 };
  const caro = { ...otc, id: 2, precio: 80 };
  const subidas = listarSubidasRappi([barato, caro], {
    1: refs({ similares: 40 }),
    2: refs({ similares: 40 }),
  });
  expect(subidas).toHaveLength(1);
  expect(subidas[0].producto.id).toBe(1);
  expect(subidas[0].a).toBeGreaterThan(20);
});

test("sin refs de farmacia ni calle no sugiere", () => {
  const r = refs({ rappi_super: 22 });
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.sugerido).toBeNull();
  expect(out.nota).toMatch(/sin referencias/i);
  expect(tieneRefRappi(r)).toBe(true);
});
