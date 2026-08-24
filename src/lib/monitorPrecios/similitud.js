/**
 * Similitud determinista (trigramas + Levenshtein). Sin IA.
 */

"use strict";

const { colapsar, digitsOnly } = (() => {
  const n = require("./normalizador");
  const r = require("./registroCrudo");
  return { colapsar: n.colapsar, digitsOnly: r.digitsOnly };
})();

function trigramas(texto) {
  const s = `  ${colapsar(texto)} `;
  const set = new Set();
  for (let i = 0; i < s.length - 2; i += 1) set.add(s.slice(i, i + 3));
  return set;
}

function scoreTrigramas(a, b) {
  const A = trigramas(a);
  const B = trigramas(b);
  if (!A.size || !B.size) return 0;
  let inter = 0;
  A.forEach((t) => {
    if (B.has(t)) inter += 1;
  });
  return (2 * inter) / (A.size + B.size);
}

function levenshtein(a, b) {
  const s = colapsar(a);
  const t = colapsar(b);
  if (s === t) return 0;
  if (!s.length) return t.length;
  if (!t.length) return s.length;
  const prev = new Array(t.length + 1);
  const cur = new Array(t.length + 1);
  for (let j = 0; j <= t.length; j += 1) prev[j] = j;
  for (let i = 1; i <= s.length; i += 1) {
    cur[0] = i;
    for (let j = 1; j <= t.length; j += 1) {
      const cost = s[i - 1] === t[j - 1] ? 0 : 1;
      cur[j] = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost);
    }
    for (let j = 0; j <= t.length; j += 1) prev[j] = cur[j];
  }
  return prev[t.length];
}

function scoreLevenshtein(a, b) {
  const s = colapsar(a);
  const t = colapsar(b);
  const maxLen = Math.max(s.length, t.length, 1);
  return 1 - levenshtein(s, t) / maxLen;
}

function scoreNombre(a, b) {
  const tri = scoreTrigramas(a, b);
  const lev = scoreLevenshtein(a, b);
  return 0.7 * tri + 0.3 * lev;
}

function eanKeys(raw) {
  const d = digitsOnly(raw);
  if (!d) return [];
  const keys = new Set([d, d.replace(/^0+/, "") || "0"]);
  if (d.length < 12) keys.add(d.padStart(12, "0"));
  if (d.length < 13) keys.add(d.padStart(13, "0"));
  if (d.length === 12) keys.add(`0${d}`);
  if (d.length === 13 && d.startsWith("0")) keys.add(d.slice(1));
  return [...keys];
}

function gtinCoincide(a, b) {
  const ka = new Set(eanKeys(a));
  if (!ka.size) return false;
  return eanKeys(b).some((k) => ka.has(k));
}

function hashEstable(texto) {
  const s = String(texto || "");
  let h = 2166136261;
  for (let i = 0; i < s.length; i += 1) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return (h >>> 0).toString(16);
}

function mismaSustancia(a, b) {
  const x = colapsar(a);
  const y = colapsar(b);
  if (!x || !y) return false;
  return x === y || x.includes(y) || y.includes(x);
}

function mismaForma(a, b) {
  return colapsar(a) === colapsar(b) && Boolean(colapsar(a));
}

module.exports = {
  trigramas,
  scoreTrigramas,
  levenshtein,
  scoreLevenshtein,
  scoreNombre,
  eanKeys,
  gtinCoincide,
  hashEstable,
  mismaSustancia,
  mismaForma,
};
