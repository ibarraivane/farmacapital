import { avisoLotesAnaquel, gruposCaducidadAnaquel } from "./posAvisoLotes";

const hoy = "2026-08-30";

function prod(lotes) {
  return { id: 1, nombre: "Tegaderm", lotes };
}

describe("gruposCaducidadAnaquel", () => {
  test("junta el mismo mes/año y ordena FEFO", () => {
    const grupos = gruposCaducidadAnaquel(prod([
      { id: 2, cantidad_actual: 5, fecha_caducidad: "2030-12-31", activo: true },
      { id: 1, cantidad_actual: 2, fecha_caducidad: "2029-06-30", activo: true },
      { id: 3, cantidad_actual: 1, fecha_caducidad: "2029-06-30", activo: true },
    ]), hoy);
    expect(grupos).toHaveLength(2);
    expect(grupos[0]).toMatchObject({ etiqueta: "jun 2029", cantidad: 3 });
    expect(grupos[1]).toMatchObject({ etiqueta: "dic 2030", cantidad: 5 });
  });

  test("sin fecha va primero; vencidos no salen", () => {
    const grupos = gruposCaducidadAnaquel(prod([
      { id: 1, cantidad_actual: 2, fecha_caducidad: "2025-01-31", activo: true },
      { id: 2, cantidad_actual: 3, fecha_caducidad: null, activo: true },
      { id: 3, cantidad_actual: 4, fecha_caducidad: "2029-06-30", activo: true },
    ]), hoy);
    expect(grupos.map((g) => g.clave)).toEqual(["sin_fecha", "2029-06-30"]);
    expect(grupos[0].cantidad).toBe(3);
  });
});

describe("avisoLotesAnaquel", () => {
  test("dos fechas: dice cuál tomar y cuál también hay", () => {
    const aviso = avisoLotesAnaquel(prod([
      { id: 1, cantidad_actual: 2, fecha_caducidad: "2029-06-30", activo: true },
      { id: 2, cantidad_actual: 5, fecha_caducidad: "2030-12-31", activo: true },
    ]), hoy);
    expect(aviso.mostrar).toBe(true);
    expect(aviso.multi).toBe(true);
    expect(aviso.textoFichaTitulo).toBe("Toma el de jun 2029 · 2 cajas");
    expect(aviso.textoFichaOtros).toBe("También hay dic 2030 · 5 cajas");
    expect(aviso.textoCorto).toBe("Toma jun 2029");
    expect(aviso.textoCarrito).toBe("Del anaquel: jun 2029");
  });

  test("una sola fecha: caduca, sin 'toma'", () => {
    const aviso = avisoLotesAnaquel(prod([
      { id: 1, cantidad_actual: 8, fecha_caducidad: "2029-06-30", activo: true },
    ]), hoy);
    expect(aviso.multi).toBe(false);
    expect(aviso.textoFichaTitulo).toBe("Caduca jun 2029 · 8 cajas");
    expect(aviso.textoFichaOtros).toBe("");
    expect(aviso.textoCorto).toBe("");
    expect(aviso.textoCarrito).toBe("Caduca jun 2029");
  });

  test("lote próximo (90 días) marca urgente", () => {
    const aviso = avisoLotesAnaquel(prod([
      { id: 1, cantidad_actual: 1, fecha_caducidad: "2026-10-31", activo: true },
    ]), hoy);
    expect(aviso.urgente).toBe(true);
  });

  test("sin lotes no muestra", () => {
    expect(avisoLotesAnaquel(prod([]), hoy).mostrar).toBe(false);
    expect(avisoLotesAnaquel({}, hoy).mostrar).toBe(false);
  });

  test("sin fecha: avisa que hay que capturar MMAA", () => {
    const aviso = avisoLotesAnaquel(prod([
      { id: 1, cantidad_actual: 4, fecha_caducidad: null, activo: true },
      { id: 2, cantidad_actual: 2, fecha_caducidad: "2029-06-30", activo: true },
    ]), hoy);
    expect(aviso.textoFichaTitulo).toBe("Toma las cajas sin fecha · 4 cajas");
    expect(aviso.textoFichaOtros).toMatch(/jun 2029/);
    expect(aviso.urgente).toBe(true);
  });
});
