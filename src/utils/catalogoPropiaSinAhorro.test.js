/**
 * Guardrail: nunca publicar el placeholder rosa «A» de Del Ahorro
 * como foto de catálogo (Atoderm Intensive Baume, cosecha 2026-09-17).
 */
import { createHash } from "node:crypto";
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { PLACEHOLDER_FAHORRO_MD5 } from "../lib/imagenCompetencia";

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
