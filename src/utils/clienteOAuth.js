/**
 * Login social tienda (Google / Facebook / Apple) vía Supabase Auth.
 * Tras el redirect, se canjea la sesión Auth por el token FarmaCapital
 * (sesiones_cliente) usando /api/auth/oauth-bridge.
 */

export const SOCIAL_PROVIDERS = [
  {
    id: "google",
    label: "Continuar con Google",
    short: "Google",
  },
  {
    id: "facebook",
    label: "Continuar con Facebook",
    short: "Facebook",
  },
  {
    id: "apple",
    label: "Continuar con Apple",
    short: "Apple",
  },
];

const PROVIDER_IDS = new Set(SOCIAL_PROVIDERS.map((p) => p.id));

/**
 * Lista habilitada por env (coma-separada). Default: google + apple.
 * Ej: REACT_APP_SOCIAL_LOGIN=google,facebook,apple
 */
export function enabledSocialProviders() {
  const raw =
    process.env.REACT_APP_SOCIAL_LOGIN ||
    process.env.REACT_APP_OAUTH_PROVIDERS ||
    "google,apple";
  const wanted = String(raw)
    .split(/[,;\s]+/)
    .map((s) => s.trim().toLowerCase())
    .filter((id) => PROVIDER_IDS.has(id));
  const unique = [...new Set(wanted.length ? wanted : ["google", "apple"])];
  return SOCIAL_PROVIDERS.filter((p) => unique.includes(p.id));
}

export function oauthCallbackUrl() {
  if (typeof window === "undefined") return "";
  const origin = window.location.origin.replace(/\/+$/, "");
  return `${origin}/auth/callback`;
}

export function isOAuthCallbackLocation(pathname, search, hash) {
  const path = String(pathname || "");
  if (/\/auth\/callback\/?$/i.test(path)) return true;
  try {
    const q = new URLSearchParams(search || "");
    if (q.get("oauth") === "1" || q.get("code")) return true;
  } catch (_) { /* noop */ }
  const h = String(hash || "");
  if (/access_token=|refresh_token=|error=/.test(h)) return true;
  return false;
}

/**
 * Inicia el redirect OAuth con Supabase Auth.
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase
 * @param {'google'|'facebook'|'apple'} provider
 */
export async function startClienteOAuth(supabase, provider) {
  const id = String(provider || "").toLowerCase();
  if (!PROVIDER_IDS.has(id)) {
    return { ok: false, error: "Proveedor no soportado." };
  }
  try {
    sessionStorage.setItem("farmacapital_oauth_provider", id);
  } catch (_) { /* noop */ }

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: id,
    options: {
      redirectTo: oauthCallbackUrl(),
      skipBrowserRedirect: false,
      // Apple: pedir nombre + email en el primer acceso (luego Apple puede ocultarlos).
      scopes: id === "apple" ? "name email" : undefined,
      queryParams:
        id === "google"
          ? { access_type: "online", prompt: "select_account" }
          : undefined,
    },
  });

  if (error) {
    return {
      ok: false,
      error:
        error.message ||
        "No se pudo abrir el inicio de sesión social. Revisá que el proveedor esté activo en Supabase.",
    };
  }
  return { ok: true, url: data?.url || null };
}

/**
 * Tras el redirect: obtiene sesión Auth y la canjea por token FarmaCapital.
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase
 */
export async function completeClienteOAuth(supabase) {
  let providerHint = null;
  try {
    providerHint = sessionStorage.getItem("farmacapital_oauth_provider");
  } catch (_) { /* noop */ }

  // PKCE (?code=) o hash implícito — supabase-js hidrata la sesión.
  const { data: sessData, error: sessErr } = await supabase.auth.getSession();
  if (sessErr) {
    return { ok: false, error: sessErr.message || "Sesión OAuth inválida." };
  }

  let session = sessData?.session || null;
  if (!session?.access_token) {
    // Reintento corto: a veces el exchange del code aún no terminó.
    await new Promise((r) => setTimeout(r, 350));
    const again = await supabase.auth.getSession();
    session = again?.data?.session || null;
  }

  if (!session?.access_token) {
    return {
      ok: false,
      error:
        "No recibimos la sesión del proveedor. Cerrá la ventana e intentá de nuevo desde Iniciar sesión.",
    };
  }

  const resp = await fetch("/api/auth/oauth-bridge", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      access_token: session.access_token,
      provider: providerHint || undefined,
      user_agent: typeof navigator !== "undefined" ? navigator.userAgent : null,
    }),
  });

  const payload = await resp.json().catch(() => ({}));

  // Limpiar sesión Auth de Supabase: FarmaCapital usa su propio token.
  try {
    await supabase.auth.signOut({ scope: "local" });
  } catch (_) { /* noop */ }
  try {
    sessionStorage.removeItem("farmacapital_oauth_provider");
  } catch (_) { /* noop */ }

  if (!resp.ok || !payload?.ok || !payload?.token) {
    return {
      ok: false,
      error:
        payload?.message ||
        payload?.error ||
        "No se pudo vincular tu cuenta social. Intentá de nuevo o usá correo/teléfono.",
    };
  }

  return {
    ok: true,
    token: payload.token,
    session_token: payload.token,
    user: payload.cliente || payload.user || null,
    created: Boolean(payload.created),
    needs_phone: Boolean(
      payload.needs_phone ||
        !(payload.cliente || payload.user || {})?.telefono
    ),
    provider: payload.provider || providerHint,
  };
}
