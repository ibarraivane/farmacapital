/** Cliente tienda/POS → API de logística (nunca llama a Uber desde el navegador). */

const UBER_QUOTE_URL = "/api/logistics/webhook?type=uber-api";

export function explainUberQuoteError(err, detail) {
  const code = typeof err === "object" && err ? String(err.code || err.message || "") : String(err || "");
  const blob = `${code} ${detail || ""} ${typeof err === "object" ? JSON.stringify(err) : ""}`.toLowerCase();
  if (blob.includes("not_configured") || blob.includes("503")) {
    return "Falta el Client Secret de Uber en Vercel (Preview y Production). Sin eso no se puede cotizar.";
  }
  if (blob.includes("protected") || blob.includes("401") || blob.includes("vercel_auth")) {
    return "Este Preview está protegido por Vercel. Mezcla el PR a producción o quita Vercel Authentication en Preview.";
  }
  if (blob.includes("invalid_dropoff")) {
    return "Falta calle, colonia o un CP de 5 dígitos.";
  }
  if (blob.includes("uber_api_failed") || blob.includes("address") || blob.includes("geocod")) {
    return "Uber no pudo ubicar la dirección. Pon calle con número, solo la colonia (sin alcaldía) y una referencia (edificio, negocio).";
  }
  if (detail) return `No se pudo cotizar: ${String(detail).slice(0, 160)}`;
  if (code && code !== "undefined") return `No se pudo cotizar (${code}).`;
  return "No se pudo cotizar el envío Uber. Revisa la dirección o elige pick-up.";
}

export function formatUberFee(mxn) {
  const n = Number(mxn);
  if (!Number.isFinite(n)) return "$0.00";
  return `$${n.toFixed(2)}`;
}

export function formatUberEta(quote) {
  const min = Number(quote?.duration_min);
  if (!Number.isFinite(min) || min <= 0) return null;
  const lo = Math.max(10, Math.round(min * 0.75));
  const hi = Math.round(min * 1.15);
  if (hi <= lo) return `~${lo} min`;
  return `${lo}–${hi} min`;
}

export async function fetchUberDirectQuote({ calle, colonia, cp, referencia, lat, lng }) {
  const resp = await fetch(UBER_QUOTE_URL, {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      action: "quote",
      calle: String(calle || "").trim(),
      colonia: String(colonia || "").trim(),
      cp: String(cp || "").trim(),
      referencia: String(referencia || "").trim(),
      lat: lat != null && Number.isFinite(Number(lat)) ? Number(lat) : undefined,
      lng: lng != null && Number.isFinite(Number(lng)) ? Number(lng) : undefined,
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    const err = data?.error || data?.message || `http_${resp.status}`;
    return {
      ok: false,
      error: err,
      detail: data?.detail || data?.error?.message || null,
      hint: explainUberQuoteError(err, data?.detail),
    };
  }
  return data;
}

export async function attachUberDirectQuote({
  pedidoId,
  sessionToken,
  guest,
  guestPhone,
  calle,
  colonia,
  cp,
  referencia,
  displayedFeeMxn,
  lat,
  lng,
}) {
  const resp = await fetch(UBER_QUOTE_URL, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(sessionToken ? { Authorization: `Bearer ${sessionToken}` } : {}),
    },
    body: JSON.stringify({
      action: "attach",
      pedidoId,
      guest: Boolean(guest),
      guestPhone,
      calle: String(calle || "").trim(),
      colonia: String(colonia || "").trim(),
      cp: String(cp || "").trim(),
      referencia: String(referencia || "").trim(),
      displayed_fee_mxn: displayedFeeMxn,
      lat: lat != null && Number.isFinite(Number(lat)) ? Number(lat) : undefined,
      lng: lng != null && Number.isFinite(Number(lng)) ? Number(lng) : undefined,
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      quote: data?.quote || null,
      detail: data?.detail || null,
    };
  }
  return data;
}

export async function dispatchUberDirectDelivery({ pedidoId, sessionToken }) {
  const resp = await fetch(UBER_QUOTE_URL, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(sessionToken ? { Authorization: `Bearer ${sessionToken}` } : {}),
    },
    body: JSON.stringify({ action: "create", pedidoId }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      detail: data?.detail || null,
    };
  }
  return data;
}
