'use strict';

const CACHE_MS = 60 * 1000;
let cache = { key: '', at: 0, domains: null };

function resetResendDomainCache() {
  cache = { key: '', at: 0, domains: null };
}

function dominioDeCorreo(from) {
  const raw = String(from || '').trim();
  const angled = raw.match(/<([^>]+)>/);
  const email = (angled ? angled[1] : raw).trim().toLowerCase();
  const at = email.lastIndexOf('@');
  if (at < 0) return '';
  return email.slice(at + 1).replace(/[^a-z0-9.-]/g, '');
}

function nombreVisible(from) {
  const raw = String(from || '').trim();
  const named = raw.match(/^(.*?)</);
  const name = named ? named[1].trim() : '';
  return name || 'FarmaCapital';
}

function parteLocal(from) {
  const raw = String(from || '').trim();
  const angled = raw.match(/<([^>]+)>/);
  const email = (angled ? angled[1] : raw).trim();
  const local = (email.split('@')[0] || 'contacto').trim();
  return /^[a-z0-9._+-]+$/i.test(local) ? local : 'contacto';
}

function dominioEnvia(domain) {
  const status = String(domain?.status || '').toLowerCase();
  if (status !== 'verified' && status !== 'partially_verified') return false;
  const sending = domain?.capabilities?.sending;
  if (sending == null || sending === '') return true;
  return String(sending).toLowerCase() !== 'disabled';
}

/** Dominio de Resend que sí puede enviar. Null si la cuenta no tiene ninguno. */
function elegirDominioVerificado(domains, preferido, alterno) {
  const names = (Array.isArray(domains) ? domains : [])
    .filter(dominioEnvia)
    .map((d) => String(d.name || '').trim().toLowerCase())
    .filter(Boolean);
  if (!names.length) return null;
  const pref = String(preferido || '').toLowerCase();
  if (pref && names.includes(pref)) return pref;
  if (pref) {
    const sub = names.find((n) => n.endsWith(`.${pref}`));
    if (sub) return sub;
  }
  const alt = String(alterno || '').toLowerCase();
  if (alt && names.includes(alt)) return alt;
  const propio = names.find((n) => n === 'farmacapital.mx' || n.endsWith('.farmacapital.mx'));
  return propio || names[0];
}

function correoEnDominio(from, domain) {
  return `${nombreVisible(from)} <${parteLocal(from)}@${domain}>`;
}

function fromParaDominio(domain, from, notifyFrom) {
  if (dominioDeCorreo(from) === domain) return String(from || '').trim();
  if (notifyFrom && dominioDeCorreo(notifyFrom) === domain) return String(notifyFrom).trim();
  return correoEnDominio(from || notifyFrom, domain);
}

async function listarDominiosResend(apiKey, fetchImpl) {
  const now = Date.now();
  if (cache.key === apiKey && Array.isArray(cache.domains) && now - cache.at < CACHE_MS) {
    return cache.domains;
  }
  let resp;
  try {
    resp = await fetchImpl('https://api.resend.com/domains', {
      headers: { Authorization: `Bearer ${apiKey}`, Accept: 'application/json' },
    });
  } catch {
    return null;
  }
  if (!resp || !resp.ok) return null;
  const body = typeof resp.json === 'function' ? await resp.json().catch(() => null) : null;
  const domains = Array.isArray(body?.data) ? body.data : null;
  if (!domains) return null;
  cache = { key: apiKey, at: now, domains };
  return domains;
}

/**
 * Usa el From pedido si ese dominio está verificado en la cuenta.
 * Si no, cambia al dominio verificado (subdominio de farmacapital.mx u otro).
 * Si la lista falla, deja el From original para no bloquear un envío que sí podría salir.
 */
async function resolverFromVerificado({ apiKey, from, notifyFrom, fetchImpl }) {
  const pedido = String(from || notifyFrom || '').trim();
  const preferido = dominioDeCorreo(pedido);
  const alterno = dominioDeCorreo(notifyFrom);
  const domains = await listarDominiosResend(apiKey, fetchImpl);
  if (!domains) return { ok: true, from: pedido, rewritten: false, unknown: true };
  const elegido = elegirDominioVerificado(domains, preferido, alterno);
  if (!elegido) {
    return {
      ok: false,
      reason: 'domain_not_verified',
      detail: {
        message: `The ${preferido || 'farmacapital.mx'} domain is not verified.`,
      },
    };
  }
  const next = fromParaDominio(elegido, pedido, notifyFrom);
  return { ok: true, from: next, rewritten: next !== pedido, domain: elegido };
}

module.exports = {
  elegirDominioVerificado,
  dominioDeCorreo,
  correoEnDominio,
  resolverFromVerificado,
  resetResendDomainCache,
};
