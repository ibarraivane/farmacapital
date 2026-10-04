'use strict';

/**
 * Cambios de la galería `producto_imagenes` antes de escribir en la base.
 * La foto de `productos.imagen_url` es la principal del formulario.
 * Si la galería tiene filas, la tienda la usa y deja de mirar imagen_url:
 * por eso agregar la primera foto extra también guarda la principal actual.
 */

function claveFoto(url) {
  const raw = String(url || '').trim();
  if (!raw) return '';
  try {
    const u = new URL(raw);
    u.search = '';
    u.hash = '';
    return u.href;
  } catch {
    return raw.split('#')[0].split('?')[0];
  }
}

function mismaFoto(a, b) {
  const ca = claveFoto(a);
  const cb = claveFoto(b);
  return Boolean(ca) && ca === cb;
}

function urlFotoPermitida(raw) {
  const url = String(raw || '').trim();
  if (!url || url.length > 2000) return '';
  let parsed;
  try {
    parsed = new URL(url);
  } catch {
    return '';
  }
  if (parsed.protocol !== 'https:' && parsed.protocol !== 'http:') return '';
  if (/(^|\.)fahorro\.com$/i.test(parsed.hostname)) return '';
  return url;
}

function clonar(filas) {
  return (filas || [])
    .map((f) => ({
      id: f.id ?? null,
      url: String(f.url || '').trim(),
      posicion: Number(f.posicion) || 0,
      es_principal: !!f.es_principal,
    }))
    .filter((f) => f.url);
}

function siguientePosicion(filas) {
  return filas.reduce((max, f) => Math.max(max, Number(f.posicion) || 0), 0) + 1;
}

function apagarPrincipales(filas) {
  for (const f of filas) f.es_principal = false;
}

function marcarPrincipal(filas, url) {
  apagarPrincipales(filas);
  const row = filas.find((f) => mismaFoto(f.url, url));
  if (row) row.es_principal = true;
}

function asegurarEnGaleria(filas, url, { principal }) {
  const limpia = String(url || '').trim();
  if (!limpia) return;
  const ya = filas.find((f) => mismaFoto(f.url, limpia));
  if (ya) {
    if (principal) marcarPrincipal(filas, limpia);
    return;
  }
  if (principal) apagarPrincipales(filas);
  const hayPrincipal = filas.some((f) => f.es_principal);
  filas.push({
    id: null,
    url: limpia,
    posicion: siguientePosicion(filas),
    es_principal: principal || !hayPrincipal,
  });
}

/**
 * @param {{ filas?: object[], imagenUrl?: string, action?: string, url?: string, principal?: boolean }} input
 * @returns {{ ok: boolean, message?: string, filas: object[], imagenUrl: string, sinCambio?: boolean }}
 */
function planCambioFotos({ filas, imagenUrl, action, url, principal }) {
  const accion = String(action || '').trim().toLowerCase();
  const rows = clonar(filas);
  const actual = String(imagenUrl || '').trim();
  const destino = String(url || '').trim();

  if (accion === 'listar') {
    return { ok: true, filas: rows, imagenUrl: actual, sinCambio: true };
  }

  if (accion === 'quitar') {
    if (!destino) return { ok: false, message: 'Falta la foto a quitar.', filas: rows, imagenUrl: actual };
    const quitada = rows.find((f) => mismaFoto(f.url, destino));
    const eraFlag = !!quitada?.es_principal;
    const eraImagen = mismaFoto(actual, destino);
    if (!quitada && !eraImagen) {
      return { ok: true, filas: rows, imagenUrl: actual, sinCambio: true };
    }
    const siguientes = rows.filter((f) => !mismaFoto(f.url, destino));
    let imagenFinal = actual;
    if (eraImagen) {
      const candidata = siguientes.find((f) => f.es_principal) || siguientes[0];
      imagenFinal = candidata ? candidata.url : '';
      if (candidata) marcarPrincipal(siguientes, candidata.url);
    } else if (eraFlag) {
      const candidata = siguientes.find((f) => mismaFoto(f.url, actual)) || siguientes[0];
      if (candidata) marcarPrincipal(siguientes, candidata.url);
      if (!actual && candidata) imagenFinal = candidata.url;
    }
    return { ok: true, filas: siguientes, imagenUrl: imagenFinal };
  }

  if (accion !== 'agregar' && accion !== 'principal') {
    return { ok: false, message: 'Acción no reconocida.', filas: rows, imagenUrl: actual };
  }

  const permitida = urlFotoPermitida(destino);
  if (!permitida) {
    return { ok: false, message: 'Esa URL de imagen no se puede usar.', filas: rows, imagenUrl: actual };
  }

  const quierePrincipal = accion === 'principal' || principal === true || principal === 'true';

  if (quierePrincipal) {
    if (actual && !mismaFoto(actual, permitida)) {
      asegurarEnGaleria(rows, actual, { principal: false });
    }
    asegurarEnGaleria(rows, permitida, { principal: true });
    return { ok: true, filas: rows, imagenUrl: permitida };
  }

  // Si la galería tiene filas, la tienda ignora imagen_url. Al sumar fotos
  // hay que dejar la principal del formulario dentro de la galería.
  if (actual && !mismaFoto(actual, permitida)) {
    asegurarEnGaleria(rows, actual, { principal: true });
  }
  asegurarEnGaleria(rows, permitida, { principal: false });
  if (!rows.some((f) => f.es_principal)) marcarPrincipal(rows, permitida);

  const imagenFinal = actual || permitida;
  return { ok: true, filas: rows, imagenUrl: imagenFinal };
}

module.exports = {
  claveFoto,
  mismaFoto,
  urlFotoPermitida,
  planCambioFotos,
};
