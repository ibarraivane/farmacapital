/**
 * Guardrail: nunca publicar el placeholder rosa «A» de Del Ahorro
 * como foto de catálogo (Atoderm Intensive Baume, cosecha 2026-09-17).
 */
import { createHash } from "node:crypto";
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { PLACEHOLDER_FAHORRO_MD5 } from "../lib/imagenCompetencia";

const LOTE_FALTANTES_20260919 = [
  "alcohol-etilico-dibar-azul-71-5-500-ml-7501868901124.jpg",
  "levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419.jpg",
  "buscapina-fem-hioscina-ibuprofeno-20-400-mg-c-10-7501165011656.jpg",
  "cetilver-pirfenidona-gel-8-tubo-10-g-7502009748448.jpg",
  "secret-gel-invisible-lavanda-45-g-7500435129367.jpg",
  "desrotan-fexofenadina-180-mg-c-10-7502227875568.jpg",
  "aceite-de-almendras-dulces-flor-de-aire-125-ml.jpg",
  "aceite-para-bebe-nuvel-250-ml-7501082780246.jpg",
  "advil-ibuprofeno-200-mg-c-10-capsulas-7501108763475.jpg",
  "ampigrin-pfc-capsulas-c-24.jpg",
  "betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg",
  "broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992.jpg",
  "calaffler-diclofenaco-gotas-15-mg-ml-loeffler-7502211784180.jpg",
  "canula-nasal-pediatrica-2-mm-x-1-80-m-sensi-medical.jpg",
  "carnitina-fibra-y-complejo-b-naturex-30-capsulas-560.jpg",
  "teatrical-crema-suavizante-con-lanolina-tarro-400-g.jpg",
  "teatrical-crema-suavizante-con-lanolina-y-rosas-tarr.jpg",
];

const ATODERM_FILES = [
  "bioderma-3701129802069.jpg",
  "bioderma-3701129802076.jpg",
  "bioderma-atoderm-intensive-baume-200ml-3701129802069.jpg",
  "bioderma-atoderm-intensive-baume-500ml-3701129802076.jpg",
];

describe("catalogo-propia sin logo Del Ahorro", () => {
  const root = join(process.cwd(), "public", "catalogo-propia");

  test("Atoderm Intensive Baume no es el placeholder 500×500 de Fahorro", () => {
    for (const name of ATODERM_FILES) {
      const path = join(root, name);
      expect(existsSync(path)).toBe(true);
      const buf = readFileSync(path);
      const md5 = createHash("md5").update(buf).digest("hex");
      expect(md5).not.toBe(PLACEHOLDER_FAHORRO_MD5);
      expect(buf.byteLength).toBeGreaterThan(20_000);
    }
  });

  test("lote fotos faltantes 19-sep no es placeholder y pesa como packshot", () => {
    for (const name of LOTE_FALTANTES_20260919) {
      const path = join(root, name);
      expect(existsSync(path)).toBe(true);
      const buf = readFileSync(path);
      const md5 = createHash("md5").update(buf).digest("hex");
      expect(md5).not.toBe(PLACEHOLDER_FAHORRO_MD5);
      expect(buf.byteLength).toBeGreaterThan(15_000);
    }
  });

  test("ningún archivo en catalogo-propia es el MD5 del logo rosa A", () => {
    expect(existsSync(root)).toBe(true);
    const hits = [];
    for (const name of readdirSync(root)) {
      if (!/\.(jpe?g|png|webp)$/i.test(name)) continue;
      const buf = readFileSync(join(root, name));
      const md5 = createHash("md5").update(buf).digest("hex");
      if (md5 === PLACEHOLDER_FAHORRO_MD5) hits.push(name);
    }
    expect(hits).toEqual([]);
  });
});
