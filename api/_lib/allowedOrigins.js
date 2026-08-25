'use strict';

const DEFAULT_ORIGINS = [
  'https://www.farmacapital.mx',
  'https://farmacapital.mx',
  'http://localhost:3000',
  'http://127.0.0.1:3000',
];

function normalizeOrigin(raw) {
  try {
    const u = new URL(String(raw || '').trim());
    if (u.protocol !== 'http:' && u.protocol !== 'https:') return '';
    return `${u.protocol}//${u.host}`;
  } catch {
    return '';
  }
}

function allowedOriginSet() {
  const set = new Set(DEFAULT_ORIGINS);
  for (const key of ['PUBLIC_SITE_URL', 'REACT_APP_SITE_URL']) {
    const origin = normalizeOrigin(process.env[key] || '');
    if (origin) set.add(origin);
  }
  return set;
}

function isAllowedOrigin(origin) {
  const o = String(origin || '').trim();
  if (!o) return false;
  if (allowedOriginSet().has(o)) return true;
  try {
    const u = new URL(o);
    const host = u.hostname.toLowerCase();
    return host.endsWith('.vercel.app') && host.includes('farmacapital');
  } catch {
    return false;
  }
}

function corsOriginForRequest(req) {
  const origin = String(req?.headers?.origin || '').trim();
  if (origin && isAllowedOrigin(origin)) return origin;
  return 'https://www.farmacapital.mx';
}

function isAllowedReturnBase(url) {
  const origin = normalizeOrigin(url);
  return Boolean(origin && isAllowedOrigin(origin));
}

function applyRestrictiveCors(req, res) {
  const origin = corsOriginForRequest(req);
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, x-session-token'
  );
  res.setHeader('Access-Control-Max-Age', '600');
}

module.exports = {
  allowedOriginSet,
  isAllowedOrigin,
  corsOriginForRequest,
  isAllowedReturnBase,
  applyRestrictiveCors,
  normalizeOrigin,
};
