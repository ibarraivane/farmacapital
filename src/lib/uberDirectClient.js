/** Cliente tienda/POS → /api/logistics/uber-direct (nunca llama a Uber desde el navegador). */

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

export async function fetchUberDirectQuote({ calle, colonia, cp }) {
  const resp = await fetch("/api/logistics/uber-direct", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      action: "quote",
      calle: String(calle || "").trim(),
      colonia: String(colonia || "").trim(),
      cp: String(cp || "").trim(),
    }),
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

export async function attachUberDirectQuote({
  pedidoId,
  sessionToken,
  guest,
  guestPhone,
  calle,
  colonia,
  cp,
  displayedFeeMxn,
}) {
  const resp = await fetch("/api/logistics/uber-direct", {
    method: "POST",
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
      displayed_fee_mxn: displayedFeeMxn,
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
  const resp = await fetch("/api/logistics/uber-direct", {
    method: "POST",
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
