import { repartirChips, agruparPorInicial, filtrarOpciones, MAX_CHIPS_VISIBLES } from "./chipsFiltro";

const MARCAS = ["Todos", "Solar", "Afrodit", "Agecaps", "Bepanthen", "CeraVe", "Dibar", "Eucerin", "Fixodent", "Gillette", "Nair", "Vaseline"];

test("con pocas opciones no esconde nada", () => {
  const r = repartirChips(["Todos", "Gastro", "Alergia"]);
  expect(r.visibles).toEqual(["Todos", "Gastro", "Alergia"]);
  expect(r.ocultas).toEqual([]);
});

test("con muchas, deja «Todos» y las de más producto; el resto va al panel", () => {
  const conteos = { Eucerin: 80, CeraVe: 60, Bepanthen: 40, Solar: 355, Nair: 5 };
  const r = repartirChips(MARCAS, { conteos, max: 5 });
  expect(r.visibles[0]).toBe("Todos");
  expect(r.visibles).toHaveLength(5);
  expect(new Set(r.visibles)).toEqual(new Set(["Todos", "Solar", "Eucerin", "CeraVe", "Bepanthen"]));
  expect(r.visibles.length + r.ocultas.length).toBe(MARCAS.length);
  expect(r.ocultas).toContain("Nair");
});

test("los visibles conservan el orden original", () => {
  const conteos = { Eucerin: 80, Solar: 355 };
  const r = repartirChips(MARCAS, { conteos, max: 4 });
  const idx = r.visibles.map((o) => MARCAS.indexOf(o));
  expect(idx).toEqual([...idx].sort((a, b) => a - b));
});

test("la opción seleccionada nunca desaparece de los chips", () => {
  const conteos = { Eucerin: 80, CeraVe: 60, Bepanthen: 40 };
  const r = repartirChips(MARCAS, { valor: "Vaseline", conteos, max: 4 });
  expect(r.visibles).toContain("Vaseline");
  expect(r.visibles).toContain("Todos");
  expect(r.visibles).toHaveLength(4);
});

test("sin conteos respeta el orden de llegada", () => {
  const r = repartirChips(MARCAS, { max: 4 });
  expect(r.visibles).toEqual(["Todos", "Solar", "Afrodit", "Agecaps"]);
});

test("el máximo por omisión no inunda", () => {
  const muchas = ["Todos", ...Array.from({ length: 127 }, (_, i) => `Marca ${i}`)];
  expect(repartirChips(muchas).visibles).toHaveLength(MAX_CHIPS_VISIBLES);
});

test("duplicados y vacíos no rompen", () => {
  const r = repartirChips(["Todos", "A", "A", "", null, "B"]);
  expect(r.visibles).toEqual(["Todos", "A", "B"]);
});

test("agrupa A–Z sin importar acentos y manda lo que no es letra al final", () => {
  const g = agruparPorInicial(["Vaseline", "Avène", "Afrodit", "3M", "Ávila", "CeraVe"]);
  expect(g.map((x) => x.letra)).toEqual(["A", "C", "V", "#"]);
  expect(g[0].items).toEqual(["Afrodit", "Avène", "Ávila"]);
  expect(g[3].items).toEqual(["3M"]);
});

test("buscar ignora acentos y mayúsculas", () => {
  expect(filtrarOpciones(["Avène", "Eucerin", "La Roche-Posay"], "avene")).toEqual(["Avène"]);
  expect(filtrarOpciones(["Avène", "Eucerin"], "  ")).toEqual(["Avène", "Eucerin"]);
  expect(filtrarOpciones(["Avène", "Eucerin"], "zzz")).toEqual([]);
});
