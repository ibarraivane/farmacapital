/** Cliente tienda/POS → API de envío a domicilio (tarifa en checkout). */

const ENVIO_API = "/api/logistics/envio";

async function postEnvio(action, body = {}, sessionToken) {
  const resp = await fetch(ENVIO_API, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(sessionToken ? { Authorization: `Bearer ${sessionToken}` } : {}),
    },
    body: JSON.stringify({ action, ...body }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || data?.ok === false) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      detail: data?.detail || data?.hint || null,
      ...data,
    };
  }
  return data;
}

export function fetchEnvioEstimate({ lat, lng, subtotal }) {
  return postEnvio("estimate", { lat, lng, subtotal });
}

export function attachEnvioPedido({
  pedidoId,
  sessionToken,
  guest,
  guestPhone,
  calle,
  colonia,
  cp,
  referencia,
  lat,
  lng,
  displayedFeeMxn,
}) {
  return postEnvio(
    "attach",
    {
      pedidoId,
      guest: Boolean(guest),
      guestPhone,
      calle,
      colonia,
      cp,
      referencia,
      lat,
      lng,
      displayed_fee_mxn: displayedFeeMxn,
    },
    sessionToken,
  );
}

export function cotizarEnvioPedido({ pedidoId, sessionToken, costo, proveedor, distanciaKm, nota }) {
  return postEnvio(
    "quote",
    { pedidoId, costo, proveedor, distancia_km: distanciaKm, nota },
    sessionToken,
  );
}

/** @deprecated El envío se cobra en checkout. La API responde 410. */
export function crearLinkPagoEnvio({ pedidoId, sessionToken, baseUrl }) {
  return postEnvio(
    "create-payment-link",
    { pedidoId, baseUrl: baseUrl || (typeof window !== "undefined" ? window.location.origin : undefined) },
    sessionToken,
  );
}

export function despacharEnvioPedido({ pedidoId, sessionToken, trackingUrl }) {
  return postEnvio("dispatch", { pedidoId, tracking_url: trackingUrl }, sessionToken);
}

export function leerEnvioPedido({ pedidoId, sessionToken }) {
  return postEnvio("get", { pedidoId }, sessionToken);
}
