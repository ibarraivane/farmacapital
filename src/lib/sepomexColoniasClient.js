/** Cliente checkout → /api/address/colonias (SEPOMEX vía Zippopotam). */

export async function fetchColoniasByCp(cp) {
  const zip = String(cp || "").replace(/\D/g, "").slice(0, 5);
  if (zip.length !== 5) return { ok: false, error: "cp_invalid", cp: zip, colonias: [] };
  const resp = await fetch(`/api/address/colonias?cp=${encodeURIComponent(zip)}`, {
    method: "GET",
    credentials: "include",
    headers: { Accept: "application/json" },
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      cp: zip,
      colonias: Array.isArray(data?.colonias) ? data.colonias : [],
    };
  }
  return {
    ok: true,
    cp: data.cp || zip,
    colonias: Array.isArray(data.colonias) ? data.colonias : [],
  };
}
