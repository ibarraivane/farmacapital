/**
 * Fotos de un producto en el editor de inventario.
 * La galería (`producto_imagenes`) es la que sale en la tienda cuando tiene
 * filas. `imagen_url` es la principal del formulario.
 */

export function claveFoto(url) {
  const raw = String(url || "").trim();
  if (!raw) return "";
  try {
    const u = new URL(raw);
    u.search = "";
    u.hash = "";
    return u.href;
  } catch {
    return raw.split("#")[0].split("?")[0];
  }
}

export function mismaFoto(a, b) {
  const ca = claveFoto(a);
  const cb = claveFoto(b);
  return Boolean(ca) && ca === cb;
}

/**
 * Une la foto principal, la galería guardada y las que todavía no tienen producto.
 * La principal va primero. Cada fila se puede quitar.
 */
export function listarFotosEditor({ imagenUrl, filas, locales } = {}) {
  const out = [];
  const seen = new Set();
  const push = (url, extra) => {
    const limpia = String(url || "").trim();
    const clave = claveFoto(limpia);
    if (!clave || seen.has(clave)) return;
    seen.add(clave);
    out.push({
      url: limpia,
      clave,
      id: extra.id ?? null,
      enGaleria: !!extra.enGaleria,
      local: !!extra.local,
      posicion: Number(extra.posicion) || 0,
    });
  };

  const rows = [...(filas || [])].sort(
    (a, b) => (Number(a.posicion) || 0) - (Number(b.posicion) || 0),
  );
  for (const row of rows) {
    push(row.url, {
      id: row.id ?? null,
      enGaleria: true,
      posicion: row.posicion,
    });
  }
  push(imagenUrl, { enGaleria: false, posicion: 0 });
  for (const url of locales || []) {
    push(url, { local: true, posicion: 10000 });
  }

  const principal = claveFoto(imagenUrl);
  for (const foto of out) {
    foto.esPrincipal = principal ? foto.clave === principal : false;
  }
  if (!principal) {
    const marcada = rows.find((r) => r.es_principal);
    const claveMarcada = claveFoto(marcada?.url);
    if (claveMarcada) {
      for (const foto of out) foto.esPrincipal = foto.clave === claveMarcada;
    } else if (out[0]) out[0].esPrincipal = true;
  }

  out.sort((a, b) => {
    if (a.esPrincipal !== b.esPrincipal) return a.esPrincipal ? -1 : 1;
    return a.posicion - b.posicion;
  });
  return out;
}

function tokenSesion() {
  try { return sessionStorage.getItem("farmacapital_session_token") || ""; } catch { return ""; }
}

/**
 * Alta, baja o principal de una foto ya subida.
 * @returns {Promise<{ ok: boolean, message?: string, imagen_url?: string, imagenes?: object[] }>}
 */
export async function gestionarFotoProducto({ action, productoId, url, principal = false }) {
  const token = tokenSesion();
  if (!token) return { ok: false, message: "Sesión expirada. Inicia sesión de nuevo." };
  let resp;
  try {
    resp = await fetch("/api/admin/storage-upload?type=producto-imagenes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Session-Token": token,
      },
      body: JSON.stringify({
        action,
        producto_id: productoId,
        url,
        principal,
      }),
    });
  } catch (e) {
    return { ok: false, message: "No se pudieron guardar las fotos. Revisa la conexión." };
  }
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    return { ok: false, message: data?.message || "No se pudieron guardar las fotos." };
  }
  return data;
}
