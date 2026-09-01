/**
 * Login social tienda (Google / Facebook / Apple) vía Supabase Auth.
 * Tras el redirect, se canjea la sesión Auth por el token FarmaCapital
 * (sesiones_cliente) usando /api/auth/oauth-bridge.
 */

export const SOCIAL_PROVIDERS = [
  { id: "google", label: "Continuar con Google", short: "Google" },
  { id: "facebook", label: "Continuar con Facebook", short: "Facebook" },
  { id: "apple", label: "Continuar con Apple", short: "Apple" },
];

const PROVIDER_IDS = new Set(SOCIAL_PROVIDERS.map((p) => p.id));
const OAUTH_PROVIDER_KEY = "farmacapital_oauth_provider";

/**
 * Lista habilitada por env (coma-separada). Default: solo Google.
 * Apple requiere Apple Developer Program; actívalo con
 * REACT_APP_SOCIAL_LOGIN=google,apple cuando esté listo.
 */
export function enabledSocialProviders() {
  const raw =
    process.env.REACT_APP_SOCIAL_LOGIN ||
    process.env.REACT_APP_OAUTH_PROVIDERS ||
    "google";
  const wanted = String(raw)
    .split(/[,;\s]+/)
    .map((s) => s.trim().toLowerCase())
    .filter((id) => PROVIDER_IDS.has(id));
  const unique = [...new Set(wanted.length ? wanted : ["google"])];
  return SOCIAL_PROVIDERS.filter((p) => unique.includes(p.id));
}

export function oauthCallbackUrl() {
  if (typeof window === "undefined") return "";
  return `${window.location.origin.replace(/\/+$/, "")}/auth/callback`;
}

export function isOAuthCallbackLocation(pathname, search, hash) {
  if (/\/auth\/callback\/?$/i.test(String(pathname || ""))) return true;
  try {
    const q = new URLSearchParams(search || "");
    if (q.get("oauth") === "1" || q.get("code")) return true;
  } catch (_) { /* noop */ }
  return /access_token=|refresh_token=|error=/.test(String(hash || ""));
}

/**
 * Errores que Google/Supabase ponen en ?error= o #error= al volver del OAuth.
 */
export function readOAuthRedirectError(search, hash) {
  const fromParams = (raw) => {
    try {
      const q = new URLSearchParams(String(raw || "").replace(/^[?#]/, ""));
      const code = q.get("error") || q.get("error_code");
      if (!code) return null;
      const desc = q.get("error_description") || "";
      const pretty = decodeURIComponent(String(desc).replace(/\+/g, " ")).trim();
      if (pretty) return pretty;
      if (code === "access_denied") return "Cancelaste el acceso con Google.";
      return `El proveedor rechazó el acceso (${code}).`;
    } catch (_) {
      return null;
    }
  };
  return fromParams(search) || fromParams(hash);
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
    sessionStorage.setItem(OAUTH_PROVIDER_KEY, id);
  } catch (_) { /* noop */ }

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: id,
    options: {
      redirectTo: oauthCallbackUrl(),
      skipBrowserRedirect: false,
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

async function waitForAuthSession(supabase, ms = 4000) {
  try {
    const existing = await supabase.auth.getSession();
    if (existing?.data?.session?.access_token) {
      return existing.data.session;
    }
  } catch (_) { /* noop */ }

  return new Promise((resolve) => {
    let done = false;
    let sub = null;
    const finish = (session) => {
      if (done) return;
      done = true;
      try {
        sub?.data?.subscription?.unsubscribe?.();
      } catch (_) { /* noop */ }
      resolve(session || null);
    };

    try {
      sub = supabase.auth.onAuthStateChange((event, session) => {
        if (
          session?.access_token &&
          (event === "SIGNED_IN" ||
            event === "INITIAL_SESSION" ||
            event === "TOKEN_REFRESHED")
        ) {
          finish(session);
        }
      });
    } catch (_) { /* noop */ }

    setTimeout(async () => {
      try {
        const again = await supabase.auth.getSession();
        finish(again?.data?.session || null);
      } catch (_) {
        finish(null);
      }
    }, ms);
  });
}

/**
 * Tras el redirect: obtiene sesión Auth y la canjea por token FarmaCapital.
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase
 */
export async function completeClienteOAuth(supabase) {
  let providerHint = null;
  try {
    providerHint = sessionStorage.getItem(OAUTH_PROVIDER_KEY);
  } catch (_) { /* noop */ }

  const redirectErr =
    typeof window !== "undefined"
      ? readOAuthRedirectError(window.location.search, window.location.hash)
      : null;
  if (redirectErr) {
    return { ok: false, error: redirectErr };
  }

  let code = null;
  try {
    code = new URLSearchParams(window.location.search || "").get("code");
  } catch (_) { /* noop */ }

  // Primero: sesión que supabase-js pudo hidratar en initialize().
  let session = await waitForAuthSession(supabase, code ? 1200 : 3500);

  // PKCE: si aún no hay sesión y sigue el ?code=, canje explícito
  // (cubre la carrera donde history.replaceState borraba el query).
  if (!session?.access_token && code) {
    const { data, error: exchangeErr } =
      await supabase.auth.exchangeCodeForSession(code);
    if (data?.session?.access_token) {
      session = data.session;
    } else if (exchangeErr) {
      // Si initialize() ya canjeó el code, el segundo canje falla: reintentar getSession.
      const again = await supabase.auth.getSession();
      session = again?.data?.session || null;
      if (!session?.access_token) {
        return {
          ok: false,
          error:
            exchangeErr.message ||
            "No se pudo validar el acceso de Google. Intentá de nuevo desde Iniciar sesión.",
        };
      }
    }
  }

  if (!session?.access_token) {
    await new Promise((r) => setTimeout(r, 400));
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

  try {
    await supabase.auth.signOut({ scope: "local" });
  } catch (_) { /* noop */ }
  try {
    sessionStorage.removeItem(OAUTH_PROVIDER_KEY);
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
