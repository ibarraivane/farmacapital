/** Direcciones con nombre (Casa, Trabajo) para el checkout. */

import { cleanCheckoutColonia } from "./checkoutAddress";

export function checkoutUserSuffix(user) {
  const id = user?.id != null ? String(user.id).trim() : "";
  const tel = user?.telefono ? String(user.telefono).replace(/\D/g, "") : "";
  return id || tel || "guest";
}

export function checkoutAddressDraftKey(user) {
  return `farmacapital_checkout_address_${checkoutUserSuffix(user)}`;
}

export function savedAddressesKey(user) {
  return `farmacapital_saved_addresses_${checkoutUserSuffix(user)}`;
}

function foldMx(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

function samePlace(a, b) {
  return (
    foldMx(a.calle) === foldMx(b.calle) &&
    String(a.numero || "").toLowerCase() === String(b.numero || "").toLowerCase() &&
    String(a.cp || "") === String(b.cp || "")
  );
}

export function normalizeSavedAddress(raw) {
  if (!raw || typeof raw !== "object") return null;
  const name = String(raw.name || "").replace(/\s+/g, " ").trim().slice(0, 40);
  const calle = String(raw.calle || "").replace(/\s+/g, " ").trim();
  const numero = String(raw.numero || "").replace(/\s+/g, "").trim();
  const colonia = cleanCheckoutColonia(raw.colonia || "");
  const cp = String(raw.cp || "").replace(/\D/g, "").slice(0, 5);
  if (!name || calle.length < 3 || !numero || colonia.length < 3 || cp.length !== 5) return null;
  return {
    id: String(raw.id || `addr_${Date.now()}`),
    name,
    calle,
    numero,
    colonia,
    cp,
    referencia: String(raw.referencia || "").trim().slice(0, 160),
    lat: Number.isFinite(Number(raw.lat)) ? Number(raw.lat) : null,
    lng: Number.isFinite(Number(raw.lng)) ? Number(raw.lng) : null,
    savedAt: raw.savedAt || new Date().toISOString(),
  };
}

export function loadSavedAddresses(user) {
  try {
    const raw = localStorage.getItem(savedAddressesKey(user));
    if (!raw) return [];
    const arr = JSON.parse(raw);
    if (!Array.isArray(arr)) return [];
    return arr.map(normalizeSavedAddress).filter(Boolean).slice(0, 8);
  } catch {
    return [];
  }
}

export function upsertSavedAddress(user, { name, dest, referencia } = {}) {
  const entry = normalizeSavedAddress({
    id: `addr_${Date.now()}`,
    name,
    calle: dest?.calle,
    numero: dest?.numero,
    colonia: dest?.colonia,
    cp: dest?.cp,
    lat: dest?.lat,
    lng: dest?.lng,
    referencia: referencia != null ? referencia : dest?.referencia,
  });
  const list = loadSavedAddresses(user);
  if (!entry) return { ok: false, error: "incomplete", list };
  const next = [entry, ...list.filter((a) => a.name !== entry.name && !samePlace(a, entry))].slice(0, 8);
  try {
    localStorage.setItem(savedAddressesKey(user), JSON.stringify(next));
  } catch {
    return { ok: false, error: "storage", list };
  }
  return { ok: true, list: next, entry };
}

export function deleteSavedAddress(user, id) {
  const next = loadSavedAddresses(user).filter((a) => a.id !== String(id));
  try {
    localStorage.setItem(savedAddressesKey(user), JSON.stringify(next));
  } catch {
    /* private mode */
  }
  return next;
}

export function savedAddressToDestino(entry) {
  if (!entry) return null;
  return {
    calle: entry.calle,
    numero: entry.numero,
    colonia: entry.colonia,
    cp: entry.cp,
    lat: entry.lat,
    lng: entry.lng,
    referencia: entry.referencia || "",
  };
}
