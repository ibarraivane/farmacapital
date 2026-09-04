import {
  calcPrecioSugeridoRappi,
  enriquecerListaConPartner,
  idsEnCatalogoRappi,
  listarSugerenciasRappi,
  listarBajadasRappi,
  listarLotePartnerRappi,
  listarSubidasRappi,
  mensajeVacioListaRappi,
  pasaFiltroListaRappi,
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
  expect(out.refPromedio).toBeCloseTo((50 + 45 + 27) / 3, 5);
  expect(out.sugerido).toBe(40);
  expect(precioFarmaciaRappiMin(otc, r)).toBe(27);
});

test("mezcla Del Ahorro / Similares con farmacias Rappi", () => {
  const r = refs({
    fahorro: 30,
    similares: 28,
    rappi_gdl: 50,
    rappi_super: 20,
  });
  r.similares.nombre_fuente = "Agrifen 10 tabletas";
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.refMin).toBe(28);
  expect(precioCalleDe(otc, r)).toBe(28);
  expect(tieneRefRappi(r)).toBe(true);
});

test("Similares sin la marca no cuenta para Agrifen", () => {
  const r = refs({ fahorro: 30, similares: 28 });
  r.similares.nombre_fuente = "PARACETAMOL / FENILEFRINA / CLORFENAMINA 10 TABLETAS";
  expect(precioCalleDe(otc, r)).toBe(30);
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

test("el lote de sugerencias incluye subidas y bajadas", () => {
  const barato = { ...otc, id: 1, precio: 20 };
  const caro = { ...otc, id: 2, precio: 80 };
  const r40 = refs({ similares: 40 });
  r40.similares.nombre_fuente = "Agrifen 10 tabletas";
  const mapa = {
    1: r40,
    2: r40,
  };
  const todas = listarSugerenciasRappi([barato, caro], mapa);
  expect(todas.map((s) => s.producto.id).sort()).toEqual([1, 2]);
  expect(todas.find((s) => s.producto.id === 1).accion).toBe("subir");
  expect(todas.find((s) => s.producto.id === 2).accion).toBe("bajar");
  const subidas = listarSubidasRappi([barato, caro], mapa);
  expect(subidas).toHaveLength(1);
  expect(subidas[0].producto.id).toBe(1);
  const bajadas = listarBajadasRappi([barato, caro], mapa);
  expect(bajadas).toHaveLength(1);
  expect(bajadas[0].producto.id).toBe(2);
  const lotePartner = listarLotePartnerRappi([barato, caro], mapa, new Set([1]), "subir");
  expect(lotePartner).toHaveLength(1);
  expect(listarLotePartnerRappi([barato, caro], mapa, new Set([1]), "bajar")).toHaveLength(0);
});

test("el promedio no persigue al más barato; el piso de patente es 20%", () => {
  const patente = { ...otc, tipo: "marca", costo: 80, precio: 90 };
  const r = refs({ rappi_gdl: 88, rappi_farmatodo: 92, similares: 90 });
  r.similares.nombre_fuente = "Agrifen 10 tabletas";
  const out = calcPrecioSugeridoRappi(patente, r);
  expect(out.refPromedio).toBeCloseTo(90, 5);
  expect(out.sugerido).toBe(100);
  expect(out.alerta).toBe("piso_gt_techo");
  expect(out.nota).toMatch(/piso/i);
});

test("genérico no baja de 40% de margen sobre venta", () => {
  const gen = { ...otc, tipo: "generico", costo: 50, precio: 70, principio_activo: "ketoconazol" };
  const r = refs({ rappi_gdl: 60, similares: 62 });
  const out = calcPrecioSugeridoRappi(gen, r);
  expect(out.sugerido).toBe(84);
  expect(out.alerta).toBe("piso_gt_techo");
  expect(out.nota).toMatch(/piso/i);
});

test("Lizovag sin foto ni scrape no entra a En Rappi", () => {
  expect(pasaFiltroListaRappi({
    filtro: "en_rappi",
    busq: "",
    linked: false,
    hasRef: false,
  })).toBe(false);
});

test("buscar lizovag muestra el renglón aunque En Rappi esté activo", () => {
  expect(pasaFiltroListaRappi({
    filtro: "en_rappi",
    busq: "lizovag",
    linked: false,
    hasRef: false,
  })).toBe(true);
});

test("SKU Partner FARMACAPITALmt_eq-nov032 liga EQ-NOV032", () => {
  const ids = idsEnCatalogoRappi(
    [{ id: 9, sku: "EQ-NOV032", codigo_barras: "7501075717150" }],
    [{ sku_local: "FARMACAPITALmt_eq-nov032" }],
  );
  expect([...ids]).toEqual([9]);
});

test("EAN del catálogo liga el producto aunque falte producto_id", () => {
  const ids = idsEnCatalogoRappi(
    [{ id: 9, sku: "EQ-NOV032", codigo_barras: "7501075717150" }],
    [{ ean: "07501075717150" }],
  );
  expect([...ids]).toEqual([9]);
});

test("el vacío de En Rappi menciona la plantilla Partner", () => {
  expect(mensajeVacioListaRappi({ filtro: "en_rappi", busq: "lizovag" })).toMatch(/plantilla|Todos/i);
  expect(mensajeVacioListaRappi({ filtro: "en_rappi" })).toMatch(/Partner/i);
});

test("sin refs de farmacia ni calle no sugiere", () => {
  const r = refs({ rappi_super: 22 });
  const out = calcPrecioSugeridoRappi(otc, r);
  expect(out.sugerido).toBeNull();
  expect(out.nota).toMatch(/sin referencias/i);
  expect(tieneRefRappi(r)).toBe(true);
});

test("otra marca no se etiqueta como otro empaque", () => {
  const gen = {
    nombre: "Lizovag",
    tipo: "generico",
    principio_activo: "ketoconazol",
    precio: 26,
  };
  const r = refs({ rappi_gdl: 40 });
  r.rappi_gdl.nombre_fuente = "Ibuprofeno 400 mg 10 tabletas";
  expect(tienePackRappiDistinto(gen, r)).toBe(false);
});

test("enriquece el renglón con el nombre Partner", () => {
  const out = enriquecerListaConPartner([
    { id: 9, sku: "EQ-NOV032", codigo_barras: "7501075717150", nombre: "Lizovag" },
  ]);
  expect(out[0].nombre_partner).toMatch(/Lizovag/i);
  expect(out[0].nombre_rappi).toMatch(/Lizovag/i);
});
