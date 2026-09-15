/** Uber Direct API retirada. Los helpers quedan por tests legacy; no llaman a Uber. */

function errorBlob(err, detail) {
  const code = typeof err === "object" && err ? String(err.code || err.message || "") : String(err || "");
  return `${code} ${detail || ""} ${typeof err === "object" && err ? JSON.stringify(err) : ""}`.toLowerCase();
}

export function isUberCoverageError(err, detail) {
  const blob = errorBlob(err, detail);
  return (
    blob.includes("undeliverable_area") ||
    blob.includes("not in a deliverable area") ||
    blob.includes("undeliverable") ||
    blob.includes("outside of the delivery") ||
    blob.includes("no delivery options")
  );
}

export function checkoutPuedePagarEnvio({
  entrega,
  direccionOk,
} = {}) {
  if (entrega === "pickup") return true;
  return Boolean(direccionOk);
}

export function explainUberQuoteError(err, detail) {
  const blob = errorBlob(err, detail);
  if (blob.includes("not_configured") || blob.includes("503")) {
    return "Falta el Client Secret de Uber en Vercel (Preview y Production). Sin eso no se puede cotizar.";
  }
  if (blob.includes("protected") || blob.includes("401") || blob.includes("vercel_auth")) {
    return "Este Preview está protegido por Vercel. Mezcla el PR a producción o quita Vercel Authentication en Preview.";
  }
  if (blob.includes("invalid_dropoff")) {
    return "Falta calle, colonia o un CP de 5 dígitos.";
  }
  if (isUberCoverageError(err, detail)) {
    return "Uber aún no tiene cobertura desde FarmaCapital (Iztapalapa), ni a una cuadra. Puedes pagar el pedido: te coordinamos el envío por WhatsApp.";
  }
  if (blob.includes("uber_api_failed") || blob.includes("address") || blob.includes("geocod")) {
    return "Uber no pudo ubicar la dirección. Pon calle con número, solo la colonia (sin alcaldía) y una referencia (edificio, negocio).";
  }
  if (detail) return `No se pudo cotizar: ${String(detail).slice(0, 160)}`;
  const code = typeof err === "object" && err ? String(err.code || err.message || "") : String(err || "");
  if (code && code !== "undefined") return `No se pudo cotizar (${code}).`;
  return "No se pudo cotizar el envío Uber. Revisa la dirección o escríbenos por WhatsApp.";
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

export async function fetchUberDirectQuote() {
  return { ok: false, error: "uber_direct_retired", hint: "Usar /api/logistics/envio" };
}

export async function attachUberDirectQuote() {
  return { ok: false, error: "uber_direct_retired", hint: "Usar /api/logistics/envio action=attach" };
}

export async function dispatchUberDirectDelivery() {
  return { ok: false, error: "uber_direct_retired", hint: "Usar /api/logistics/envio action=dispatch" };
}
