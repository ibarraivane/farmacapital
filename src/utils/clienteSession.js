const TOKEN_KEY = "farmacapital_cliente_token";
const USER_KEY = "farmacapital_user";
const POST_LOGIN_KEY = "farmacapital_post_login_page";

/** Migra sesiones guardadas en sessionStorage (versión anterior). */
function migrateFromSessionStorage() {
  try {
    if (!localStorage.getItem(TOKEN_KEY)) {
      const tok = sessionStorage.getItem(TOKEN_KEY);
      if (tok) localStorage.setItem(TOKEN_KEY, tok);
    }
    if (!localStorage.getItem(USER_KEY)) {
      const u = sessionStorage.getItem(USER_KEY);
      if (u) localStorage.setItem(USER_KEY, u);
    }
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(USER_KEY);
  } catch (_) { /* noop */ }
}

migrateFromSessionStorage();

export function getClienteToken() {
  try { return localStorage.getItem(TOKEN_KEY) || null; }
  catch { return null; }
}

export function getClienteUser() {
  try {
    const u = localStorage.getItem(USER_KEY);
    return u ? JSON.parse(u) : null;
  } catch { return null; }
}

export function setClienteSession(token, user) {
  try {
    if (token) localStorage.setItem(TOKEN_KEY, String(token));
    if (user != null) localStorage.setItem(USER_KEY, JSON.stringify(user));
  } catch (_) { /* noop */ }
}

export function clearClienteSession() {
  try {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(USER_KEY);
  } catch (_) { /* noop */ }
}

export function setPostLoginPage(page) {
  try { sessionStorage.setItem(POST_LOGIN_KEY, page); } catch (_) { /* noop */ }
}

export function getPostLoginPage() {
  try { return sessionStorage.getItem(POST_LOGIN_KEY) || null; }
  catch { return null; }
}

export function consumePostLoginPage() {
  try {
    const p = sessionStorage.getItem(POST_LOGIN_KEY);
    if (p) sessionStorage.removeItem(POST_LOGIN_KEY);
    return p;
  } catch { return null; }
}

/** Si no hay sesión, guarda destino y manda a login; si hay sesión, abre la página de cita. */
export function navigateToCita(setPage) {
  if (getClienteToken()) {
    setPage("cita");
    return;
  }
  setPostLoginPage("cita");
  setPage("login");
}
