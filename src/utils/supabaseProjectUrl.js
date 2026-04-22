/**
 * La Project URL de Supabase debe ser solo el host, p. ej. https://xxx.supabase.co
 * (Dashboard → Settings → API → Project URL). Si copiás una URL que ya trae
 * /rest/v1, el cliente JS la duplica y las peticiones dan 404.
 */
export function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== "string") return url;
  let u = url.trim().replace(/\/+$/g, "");
  while (/\/rest\/v1$/i.test(u)) {
    u = u.replace(/\/rest\/v1$/i, "").replace(/\/+$/g, "");
  }
  return u;
}
