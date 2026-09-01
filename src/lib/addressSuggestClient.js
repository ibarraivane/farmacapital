/** Cliente checkout → /api/address/suggest (Google Places o Photon). */

export async function fetchAddressSuggestions(query) {
  const q = String(query || "").trim();
  if (q.length < 3) return { ok: true, suggestions: [], provider: "none" };
  const resp = await fetch(`/api/address/suggest?q=${encodeURIComponent(q)}`, {
    method: "GET",
    credentials: "include",
    headers: { Accept: "application/json" },
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      suggestions: [],
      provider: data?.provider || null,
    };
  }
  return {
    ok: true,
    suggestions: Array.isArray(data.suggestions) ? data.suggestions : [],
    provider: data.provider || null,
  };
}
