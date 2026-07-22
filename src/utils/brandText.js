/** Sustituye el nombre legacy «Farmax» por FarmaCapital en textos visibles. */
export function fixLegacyFarmaxBrand(text) {
  if (!text || typeof text !== "string") return text;
  return text.replace(/\bFarmax\b/gi, "FarmaCapital");
}
