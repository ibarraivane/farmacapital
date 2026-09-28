import {
  marcaDeltaDesde,
  mezclarCatalogoDelta,
  requiereRefrescoCompleto,
  CATALOGO_DELTA_MARGEN_MS,
} from "./catalogoDelta";

describe("marcaDeltaDesde", () => {
  it("usa el updated_at más reciente menos el margen", () => {
    const rows = [
      { id: 1, updated_at: "2026-09-27T10:00:00.000Z" },
      { id: 2, updated_at: "2026-09-27T12:00:00.000Z" },
      { id: 3, updated_at: null },
    ];
    const m = marcaDeltaDesde(rows);
    expect(Date.parse(m)).toBe(Date.parse("2026-09-27T12:00:00.000Z") - CATALOGO_DELTA_MARGEN_MS);
  });

  it("sin fechas conserva la marca anterior", () => {
    expect(marcaDeltaDesde([], "2026-01-01T00:00:00.000Z")).toBe("2026-01-01T00:00:00.000Z");
    expect(marcaDeltaDesde([{ id: 1 }], null)).toBeNull();
  });

  it("no retrocede la marca", () => {
    const anterior = "2026-09-27T12:00:00.000Z";
    const m = marcaDeltaDesde([{ id: 1, updated_at: "2026-09-27T11:00:00.000Z" }], anterior);
    expect(m).toBe(anterior);
  });
});

describe("mezclarCatalogoDelta", () => {
  const prev = [
    { id: 1, nombre: "A", activo: true },
    { id: 2, nombre: "B", activo: true },
  ];

  it("sin delta devuelve el mismo arreglo", () => {
    expect(mezclarCatalogoDelta(prev, [])).toBe(prev);
    expect(mezclarCatalogoDelta(prev, null)).toBe(prev);
  });

  it("reemplaza, agrega y quita inactivos", () => {
    const out = mezclarCatalogoDelta(prev, [
      { id: 2, nombre: "B2", activo: true },
      { id: 1, nombre: "A", activo: false },
      { id: 3, nombre: "C", activo: true },
    ]);
    expect(out.map((p) => p.nombre)).toEqual(["B2", "C"]);
  });

  it("conservarInactivos deja los inactivos (vista admin con inactivos)", () => {
    const out = mezclarCatalogoDelta(prev, [{ id: 1, nombre: "A", activo: false }], { conservarInactivos: true });
    expect(out).toHaveLength(2);
    expect(out[0].activo).toBe(false);
  });

  it("ids numéricos y texto se tratan igual y no duplica", () => {
    const out = mezclarCatalogoDelta(prev, [{ id: "2", nombre: "B3" }, { id: "2", nombre: "B3" }]);
    expect(out).toHaveLength(2);
    expect(out[1].nombre).toBe("B3");
  });
});

describe("requiereRefrescoCompleto", () => {
  it("primera vez o vencido => completo", () => {
    expect(requiereRefrescoCompleto({ desde: null, fullAt: 0 }, 1000, 5000)).toBe(true);
    expect(requiereRefrescoCompleto({ desde: "x", fullAt: 1000 }, 1000, 2500)).toBe(true);
    expect(requiereRefrescoCompleto({ desde: "x", fullAt: 1000 }, 1000, 1500)).toBe(false);
  });
});
