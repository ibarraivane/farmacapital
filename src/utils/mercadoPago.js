// ═══════════════════════════════════════════════════════════
// FARMACAPITAL — Mercado Pago Point Smart 2
// Integración con terminal de pago física
// Documentación: https://www.mercadopago.com.mx/developers
// ═══════════════════════════════════════════════════════════

// ── Configuración ────────────────────────────────────────
// IMPORTANTE:
// - REACT_APP_MP_PUBLIC_KEY puede vivir en frontend.
// - REACT_APP_MP_ACCESS_TOKEN NO debe exponerse en frontend en producción.
//   Se permite solo para desarrollo local temporal.
// - Producción segura: usar backend/proxy con token privado.

// Valores por defecto para FarmaCapital (no son secretos — Public Key y Device ID son públicos).
// El Access Token SÍ es secreto y vive solo en el servidor (MP_ACCESS_TOKEN en Vercel, sin REACT_APP_).
const MP_PUBLIC_KEY   = process.env.REACT_APP_MP_PUBLIC_KEY   || "APP_USR-28b7f7b0-2e5d-44d4-a35a-1bef9cb11f44";
const MP_ACCESS_TOKEN = process.env.REACT_APP_MP_ACCESS_TOKEN || null;
const MP_DEVICE_ID    = process.env.REACT_APP_MP_DEVICE_ID    || "NEWLAND_N950__N950NCCC05728001";
const MP_PROXY_URL    = process.env.REACT_APP_MP_PROXY_URL    || "/api/payments/mp/point";
const MP_BASE_URL     = "https://api.mercadopago.com";
const SANDBOX_MODE    = !MP_ACCESS_TOKEN?.startsWith("APP_USR");
const HOSTNAME        = globalThis?.location?.hostname || "";
const IS_LOCAL_DEV    = HOSTNAME === "localhost" || HOSTNAME === "127.0.0.1";

function newIdempotencyKey() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  return `fc-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function isFrontendTokenModeAllowed() {
  return IS_LOCAL_DEV;
}

function assertSecureModeOrThrow() {
  if (MP_PROXY_URL) return;
  if (MP_ACCESS_TOKEN && !isFrontendTokenModeAllowed()) {
    throw new Error(
      "Configuración insegura: REACT_APP_MP_ACCESS_TOKEN no debe exponerse en frontend en producción. Usa REACT_APP_MP_PROXY_URL con backend seguro."
    );
  }
}

/**
 * Verifica si Mercado Pago está configurado
 */
export function isMPConfigured() {
  // Modo seguro preferente: proxy/backend
  if (MP_PUBLIC_KEY && MP_PROXY_URL) return true;
  // Modo legacy directo SOLO local/dev
  if (MP_PUBLIC_KEY && MP_ACCESS_TOKEN && isFrontendTokenModeAllowed()) return true;
  return false;
}

/**
 * Crea una intención de pago en el Point Smart 2
 * @param {Object} opts
 * @param {number} opts.amount - Monto en MXN
 * @param {string} opts.description - Descripción de la venta
 * @param {string} opts.externalReference - Folio de la venta (VTA-00000001)
 * @returns {Promise<Object>} - Payment intent data
 */
export async function crearIntenciónDePago({ amount, description, externalReference }) {
  if(!isMPConfigured()) {
    throw new Error("Mercado Pago no está configurado en modo seguro. Configura REACT_APP_MP_PUBLIC_KEY + REACT_APP_MP_PROXY_URL.");
  }
  if(!MP_DEVICE_ID) {
    throw new Error("ID del dispositivo Point Smart 2 no configurado (REACT_APP_MP_DEVICE_ID)");
  }
  assertSecureModeOrThrow();

  const response = MP_PROXY_URL
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=create-intent&deviceId=${encodeURIComponent(MP_DEVICE_ID)}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ amount, description, externalReference }),
      })
    : await fetch(`${MP_BASE_URL}/v1/orders`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
          "Content-Type": "application/json",
          "X-Idempotency-Key": newIdempotencyKey(),
        },
        body: JSON.stringify({
          type: "point",
          external_reference: String(externalReference || `FC-${Date.now()}`).slice(0, 64),
          transactions: { payments: [{ amount: Number(amount).toFixed(2) }] },
          config: {
            point: {
              terminal_id: MP_DEVICE_ID,
              print_on_terminal: "seller_ticket",
            },
            payment_method: { default_type: "credit_card" },
          },
          description: description || "Venta FarmaCapital",
        }),
      });

  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    const msg = data?.message || data?.error || JSON.stringify(data);
    if (data?.error === 'terminal_mode_switched_to_pdv') {
      throw new Error(String(msg));
    }
    throw new Error(`MP Error ${response.status}: ${msg}`);
  }

  return { ...data, id: data.id || data.order_id };
}

/**
 * Consulta el estado de un pago
 * @param {string} paymentIntentId
 */
function normalizePointOrderStatus(data) {
  const status = String(data?.status || data?.state || "").toLowerCase();
  const detail = String(data?.status_detail || "").toLowerCase();
  return { status, detail };
}

export function mensajeEstadoPoint(status, detail) {
  const st = String(status || "").toLowerCase();
  const det = String(detail || "").toLowerCase();
  if (st === "created") {
    return "Cobro enviado. En el Point toca Actualizar (↻) para que aparezca el monto.";
  }
  if (st === "at_terminal") {
    return "Cobro en pantalla del Point — pasa tarjeta o NFC.";
  }
  if (st === "processed" || det === "accredited") return "¡Pago aprobado!";
  if (st === "expired" || det === "expired") return "El cobro expiró. Intenta de nuevo.";
  if (det === "canceled_on_terminal" || (st === "canceled" && det === "canceled")) {
    return "Se canceló en el Point (botón X). Vuelve a cobrar.";
  }
  if (det === "canceled_by_api") return "Cobro cancelado desde el sistema.";
  if (st === "failed") return "Pago rechazado en el terminal.";
  return `Estado: ${st || "..."}${det ? ` (${det})` : ""}`;
}

function errorPagoPoint(estado, detail, data) {
  const msg = mensajeEstadoPoint(estado, detail);
  if (msg.startsWith("Se canceló") || msg.startsWith("Pago rechazado") || msg.startsWith("El cobro expiró")) {
    return new Error(msg);
  }
  return new Error(`Pago ${estado}${detail ? ` (${detail})` : ""}: ${data?.message || msg}`);
}

export async function consultarEstadoPago(paymentIntentId) {
  assertSecureModeOrThrow();
  const response = MP_PROXY_URL
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=get-intent&orderId=${encodeURIComponent(paymentIntentId)}`)
    : await fetch(`${MP_BASE_URL}/v1/orders/${encodeURIComponent(paymentIntentId)}`, {
        headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` },
      });
  const data = await response.json().catch(() => ({}));
  const { status, detail } = normalizePointOrderStatus(data);
  return { ...data, status, state: status, status_detail: detail };
}

/**
 * Cancela una intención de pago
 * @param {string} paymentIntentId
 */
export async function cancelarPago(paymentIntentId) {
  assertSecureModeOrThrow();
  const response = MP_PROXY_URL
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=cancel-intent&orderId=${encodeURIComponent(paymentIntentId)}`, {
        method: "POST",
      })
    : await fetch(`${MP_BASE_URL}/v1/orders/${encodeURIComponent(paymentIntentId)}/cancel`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
          "Content-Type": "application/json",
          "X-Idempotency-Key": newIdempotencyKey(),
        },
        body: "{}",
      });
  return response.ok;
}

/**
 * Lista los dispositivos Point disponibles
 */
function pointProxyUrl(action, extra = {}) {
  const params = new URLSearchParams({ action, ...extra });
  return `${MP_PROXY_URL.replace(/\/$/, "")}?${params.toString()}`;
}

export async function consultarEstadoPoint() {
  assertSecureModeOrThrow();
  if (!MP_PROXY_URL) throw new Error("Falta REACT_APP_MP_PROXY_URL");
  const response = await fetch(pointProxyUrl("status", MP_DEVICE_ID ? { deviceId: MP_DEVICE_ID } : {}));
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    throw new Error(data?.message || data?.error || `MP status ${response.status}`);
  }
  return data;
}

export async function activarPdvPoint() {
  assertSecureModeOrThrow();
  if (!MP_DEVICE_ID) throw new Error("ID del dispositivo Point Smart 2 no configurado");
  const response = await fetch(pointProxyUrl("set-pdv", { deviceId: MP_DEVICE_ID }), { method: "POST" });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    throw new Error(data?.message || data?.error || `MP set-pdv ${response.status}`);
  }
  return data;
}

export async function resetearTerminalPoint() {
  assertSecureModeOrThrow();
  if (!MP_DEVICE_ID) throw new Error("ID del dispositivo Point Smart 2 no configurado");
  const response = await fetch(pointProxyUrl("reset-terminal", { deviceId: MP_DEVICE_ID }), { method: "POST" });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    throw new Error(data?.message || data?.error || `MP reset ${response.status}`);
  }
  return data;
}

export function textoPaqueteSoportePoint(status, extra = {}) {
  const packet = status?.support_packet || {};
  const lines = [
    status?.support_text,
    extra.orderId ? `Última orden: ${extra.orderId}` : null,
    extra.orderStatus ? `Estado última orden: ${extra.orderStatus}` : null,
    extra.orderJson ? `JSON última orden:\n${extra.orderJson}` : null,
  ].filter(Boolean);
  if (lines.length) return lines.join("\n\n");
  return [
    `Caso: WCS-43806 / 470711389`,
    `terminal_id: ${packet.terminal_id || MP_DEVICE_ID}`,
    `store_id: ${packet.store_id || ""}`,
    `pos_id: ${packet.pos_id ?? ""}`,
    `operating_mode: ${status?.operating_mode || packet.operating_mode || ""}`,
    "El terminal permanece encendido, en modo PDV/activado y con conexión estable.",
  ].join("\n");
}

export async function listarDispositivos() {
  assertSecureModeOrThrow();
  const response = MP_PROXY_URL
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=devices`)
    : await fetch(
        `${MP_BASE_URL}/point/integration-api/devices`,
        {
          headers: { "Authorization": `Bearer ${MP_ACCESS_TOKEN}` }
        }
      );
  return response.json();
}

/**
 * Polling para esperar confirmación de pago (máx 3 min)
 * @param {string} intentId
 * @param {Function} onStatus - callback con estado actual
 */
export function esperarConfirmacionPago(intentId, onStatus) {
  const MAX_ATTEMPTS = 36; // 36 × 5s = 3 minutos
  let attempts = 0;
  let interval = null;

  const promise = new Promise((resolve, reject) => {
    interval = setInterval(async () => {
      attempts++;
      try {
        const data = await consultarEstadoPago(intentId);
        const estado = String(data?.status || data?.state || "").toLowerCase();
        const detail = String(data?.status_detail || "").toLowerCase();
        onStatus?.(estado, data);

        const pagoOk =
          estado === "processed" ||
          (estado === "finished" && detail === "accredited") ||
          estado === "approved";
        const pagoFallo =
          estado === "failed" ||
          estado === "expired" ||
          estado === "rejected" ||
          estado === "error" ||
          detail === "expired" ||
          (estado === "canceled" || estado === "cancelled" || detail === "canceled_by_api" || detail === "canceled_on_terminal");

        if (pagoOk) {
          clearInterval(interval);
          resolve({ success: true, data });
        } else if (pagoFallo) {
          clearInterval(interval);
          reject(errorPagoPoint(estado, detail, data));
        } else if (attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(new Error(
            "Timeout: el Point no confirmó el pago. En el terminal toca Actualizar (↻), verifica que aparezca el monto y pasa la tarjeta."
          ));
        }
      } catch (e) {
        if (attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(e);
        }
      }
    }, 5000);
  });

  promise.cancelar = () => {
    if (interval) clearInterval(interval);
  };

  return promise;
}
