/**
 * Guardrail del lote de fotos de caja 02-oct-2026:
 * packshots reales (no logo Fahorro) y SQL cableado a catalogo-propia.
 */
import { createHash } from "node:crypto";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { PLACEHOLDER_FAHORRO_MD5 } from "../lib/imagenCompetencia";

const ROOT = join(process.cwd(), "public", "catalogo-propia");
const SQL_FOTOS = join(process.cwd(), "sql", "patch_fotos_caja_lote_20261002.sql");
const SQL_ALTA = join(process.cwd(), "sql", "patch_alta_aktyzar_c14_20261002.sql");

const LOTE = [
  "levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419-caja-20261002.jpg",
  "aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg",
  "amikacina-amsa-500-mg-2ml-c-2-ampolletas-7501349021488.jpg",
  "broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-120ml-7501573907992-caja-20261002.jpg",
  "cefalver-cefalexina-susp-125mg-5ml-90ml-7503000422610.jpg",
];

describe("lote fotos caja 02-oct-2026", () => {
  test("JPGs existen, no son placeholder Fahorro y pesan como packshot", () => {
    for (const name of LOTE) {
      const path = join(ROOT, name);
      expect(existsSync(path)).toBe(true);
      const buf = readFileSync(path);
      const md5 = createHash("md5").update(buf).digest("hex");
      expect(md5).not.toBe(PLACEHOLDER_FAHORRO_MD5);
      expect(buf.byteLength).toBeGreaterThan(20_000);
    }
  });

  test("SQL de fotos apunta a catalogo-propia y no hotlinkea Nadro/Fahorro", () => {
    const sql = readFileSync(SQL_FOTOS, "utf8");
    for (const name of LOTE) {
      expect(sql).toContain(`catalogo-propia/${name}`);
    }
    expect(sql).not.toMatch(/nadro\.vtexassets|visoti\.mx|fahorro\.com/i);
    expect(sql).toMatch(/origen.*propia|propia'/);
  });

  test("alta Aktyzar C/14 usa EAN 7502274792207 y SKU FC-74792207", () => {
    const sql = readFileSync(SQL_ALTA, "utf8");
    expect(sql).toContain("7502274792207");
    expect(sql).toContain("FC-74792207");
    expect(sql).toMatch(/Aktyzar Omeprazol 20 mg/);
    expect(sql).toMatch(/Caja con 14 cápsulas/);
    expect(sql).toMatch(/where not exists/i);
  });
});
