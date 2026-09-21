'use strict';

/** Correos únicos con @, sin vacíos. Conserva el orden (primero el principal). */
function emailsValidos(...candidatos) {
  const out = [];
  const seen = new Set();
  for (const raw of candidatos.flat()) {
    const trimmed = String(raw || '').trim();
    if (!trimmed.includes('@')) continue;
    const key = trimmed.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(trimmed);
  }
  return out;
}

/**
 * Lista a la que hay que avisar: guest del pedido, email de la ficha y email_alt.
 * El de Google (clientes.email) no se pisa; el Hotmail va en email_alt.
 */
function emailsAvisoCliente({ guestEmail, email, emailAlt } = {}) {
  return emailsValidos(guestEmail, email, emailAlt);
}

module.exports = {
  emailsValidos,
  emailsAvisoCliente,
};
