/**
 * Guardrail: nunca volver a publicar el placeholder rosa «A» de Del Ahorro
 * como foto de catálogo (Atoderm Intensive Baume, cosecha 2026-09-17).
 */
import { createHash } from "node:crypto";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const PLACEHOLDER_AHORRO_MD5 = "59370f17d7cac03761209f4b0cf46374";

const ATODERM_FILES = [
  "bioderma-3701129802069.jpg",
  "bioderma-3701129802076.jpg",
  "bioderma-atoderm-intensive-baume-200ml-3701129802069.jpg",
  "bioderma-atoderm-intensive-baume-500ml-3701129802076.jpg",
];

describe("catalogo-propia sin logo Del Ahorro", () => {
  test("Atoderm Intensive Baume no es el placeholder 500×500 de Fahorro", () => {
    const root = join(process.cwd(), "public", "catalogo-propia");
    for (const name of ATODERM_FILES) {
      const path = join(root, name);
      expect(existsSync(path)).toBe(true);
      const md5 = createHash("md5").update(readFileSync(path)).digest("hex");
      expect(md5).not.toBe(PLACEHOLDER_AHORRO_MD5);
      expect(readFileSync(path).byteLength).toBeGreaterThan(20_000);
    }
  });
});
