import {
  barcodeDigitsMatch,
  codigosBarrasDeProducto,
  findProductExactScan,
  normalizeBarcodeRaw,
  splitBarcodeCandidates,
} from "./barcodeProductLookup";
import { normalizeForSearch } from "../utils";

/** Implementación anterior (lineal, sin índice): referencia para comprobar equivalencia. */
function legacyMatches(product, candidate, qN, matchOpts, includeDescripcion) {
  if (!product) return false;
  if (
    codigosBarrasDeProducto(product, { includeDescripcion }).some((cb) =>
      barcodeDigitsMatch(candidate, cb, matchOpts)
    )
  ) {
    return true;
  }
  return !!(product.sku && normalizeForSearch(product.sku) === qN);
}

function legacyFind(products, raw, { activeOnly = true, allowNearPrefix = true } = {}) {
  const trimmed = normalizeBarcodeRaw(raw);
  if (!trimmed || !Array.isArray(products)) return null;
  const candidates = splitBarcodeCandidates(trimmed);
  const qN = normalizeForSearch(trimmed);
  const matchOpts = { allowNearPrefix };
  const first = (cand, q, inc) =>
    products.find((p) => {
      if (activeOnly && p?.activo === false) return false;
      return legacyMatches(p, cand, q, matchOpts, inc);
    }) || null;
  for (const inc of [false, true]) {
    for (const cand of candidates) {
      const hit = first(cand, normalizeForSearch(cand), inc);
      if (hit) return hit;
    }
    const hit = first(trimmed, qN, inc);
    if (hit) return hit;
  }
  return null;
}

function rng(seed) {
  let s = seed >>> 0;
  return () => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0;
    return s / 4294967296;
  };
}

function digits(r, n) {
  let out = "";
  for (let i = 0; i < n; i += 1) out += String(Math.floor(r() * 10));
  return out;
}

describe("findProductExactScan con índice = comportamiento anterior", () => {
  test("coincide con la búsqueda lineal en catálogo sintético", () => {
    const r = rng(20260924);
    const eans = [];
    const products = [];
    for (let i = 0; i < 400; i += 1) {
      const len = [8, 12, 13, 13, 13, 14][Math.floor(r() * 6)];
      const ean = r() < 0.05 ? "6502400" + digits(r, 6) : digits(r, len);
      eans.push(ean);
      const otro = eans[Math.floor(r() * eans.length)];
      products.push({
        id: i + 1,
        nombre: `Prod ${i}`,
        codigo_barras: r() < 0.1 ? "" : ean,
        sku: r() < 0.3 ? `FC-${1000 + i}` : "",
        activo: r() < 0.9,
        descripcion: r() < 0.25 ? `distinto de ${otro} c/20` : "tabletas",
      });
    }
    products.push(null);
    products.push({ id: 9001, codigo_barras: "747589705123", activo: true });

    const scans = [];
    for (const e of eans) {
      scans.push(e, e.slice(0, -1), e + "7", e.slice(1), `0${e}`, e + e);
    }
    scans.push("FC-1003", "fc-1010", "  fc-1020 ", "747589705123", "714706903205", "123", "", "abc");

    for (const raw of scans) {
      for (const opts of [{}, { activeOnly: false }, { allowNearPrefix: false }]) {
        expect(findProductExactScan(products, raw, opts)).toBe(legacyFind(products, raw, opts));
      }
    }
  });

  test("reutiliza el índice mientras la lista no cambie y lo rehace si cambia", () => {
    const lista = [{ id: 1, codigo_barras: "7501369200016", activo: true }];
    expect(findProductExactScan(lista, "7501369200016")?.id).toBe(1);
    const nueva = [...lista, { id: 2, codigo_barras: "7501234567890", activo: true }];
    expect(findProductExactScan(nueva, "7501234567890")?.id).toBe(2);
    lista.push({ id: 3, codigo_barras: "7509999999999", activo: true });
    expect(findProductExactScan(lista, "7509999999999")?.id).toBe(3);
  });

  test("rendimiento: 1,000 lecturas sobre 2,000 productos", () => {
    const r = rng(7);
    const products = Array.from({ length: 2000 }, (_, i) => ({
      id: i,
      codigo_barras: digits(r, 13),
      descripcion: "caja con 30 tabletas de uso oral",
      activo: true,
    }));
    const objetivo = products[1999].codigo_barras;
    const t0 = Date.now();
    for (let i = 0; i < 1000; i += 1) findProductExactScan(products, i % 2 ? objetivo : digits(r, 13));
    const ms = Date.now() - t0;
    // Holgado a propósito (CI lento): la búsqueda lineal anterior tardaba ~56 ms por lectura (~56 s en total).
    expect(ms).toBeLessThan(15000);
  });
});
