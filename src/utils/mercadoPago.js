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

function employeeAuthHeaders(extra = {}) {
  let tok = "";
  try {
    tok = sessionStorage.getItem("farmacapital_session_token") || "";
  } catch {
    tok = "";
  }
  return {
    "Content-Type": "application/json",
    ...(tok ? { "x-session-token": tok } : {}),
    ...extra,
  };
}

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
        headers: employeeAuthHeaders(),
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
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=get-intent&orderId=${encodeURIComponent(paymentIntentId)}`, {
        headers: employeeAuthHeaders(),
      })
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
        headers: employeeAuthHeaders(),
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
export async function listarDispositivos() {
  assertSecureModeOrThrow();
  const response = MP_PROXY_URL
    ? await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=devices`, {
        headers: employeeAuthHeaders(),
      })
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

// ═══════════════════════════════════════════════════════════
// SPEI — cobro por transferencia con CLABE de referencia única
// ═══════════════════════════════════════════════════════════
// Mercado Pago genera una CLABE distinta por cobro. Cuando el cliente
// transfiere, la orden se acredita sola: nadie tiene que juzgar un
// comprobante. A cambio el dinero cae en la cuenta de MP, no en el banco.

/**
 * Crea un cobro SPEI y devuelve la CLABE que el cliente debe usar.
 * @param {Object} opts
 * @param {number} opts.amount        Monto a cobrar
 * @param {string} [opts.description] Concepto
 * @param {string} [opts.externalReference] Folio interno
 * @param {string} [opts.payerEmail]  Correo del cliente (MP suele exigirlo)
 */
export async function crearCobroSpei({ amount, description, externalReference, payerEmail }) {
  if (!MP_PROXY_URL) {
    throw new Error("El cobro SPEI requiere el backend seguro (REACT_APP_MP_PROXY_URL).");
  }
  const response = await fetch(`${MP_PROXY_URL.replace(/\/$/, "")}?action=spei-create`, {
    method: "POST",
    headers: employeeAuthHeaders(),
    body: JSON.stringify({ amount, description, externalReference, payerEmail }),
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    throw new Error(data?.message || data?.error || `MP Error ${response.status}`);
  }
  return data;
}

/**
 * Consulta si un cobro SPEI ya se acreditó.
 */
export async function consultarCobroSpei(orderId) {
  const response = await fetch(
    `${MP_PROXY_URL.replace(/\/$/, "")}?action=spei-status&orderId=${encodeURIComponent(orderId)}`,
    { headers: employeeAuthHeaders() }
  );
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data?.ok === false) {
    throw new Error(data?.message || data?.error || `MP Error ${response.status}`);
  }
  return data;
}

/**
 * Espera a que la transferencia se acredite.
 *
 * Una SPEI normal tarda segundos, pero puede tardar minutos si el banco
 * emisor la agenda; por eso la espera es más larga que la del Point y el
 * cajero siempre puede cancelar y cobrar de otra forma.
 *
 * @returns {Promise} con .cancelar() para detener el sondeo
 */
export function esperarAcreditacionSpei(orderId, onStatus) {
  const INTERVALO_MS = 6000;
  const MAX_ATTEMPTS = 100; // 100 × 6s = 10 minutos
  let attempts = 0;
  let interval = null;

  const promise = new Promise((resolve, reject) => {
    interval = setInterval(async () => {
      attempts++;
      try {
        const data = await consultarCobroSpei(orderId);
        const estado = String(data?.raw_status || data?.status || "").toLowerCase();
        const detail = String(data?.status_detail || "").toLowerCase();
        onStatus?.(estado, data);

        const acreditado =
          estado === "processed" ||
          estado === "approved" ||
          detail === "accredited" ||
          (estado === "finished" && detail === "accredited");
        const fallo =
          estado === "expired" ||
          estado === "cancelled" ||
          estado === "canceled" ||
          estado === "rejected" ||
          detail === "expired";

        if (acreditado) {
          clearInterval(interval);
          resolve({ success: true, data });
        } else if (fallo) {
          clearInterval(interval);
          reject(new Error(
            estado === "expired" || detail === "expired"
              ? "La referencia SPEI expiró sin recibir la transferencia. Genera una nueva o cobra de otra forma."
              : "Mercado Pago canceló el cobro SPEI. Cobra de otra forma."
          ));
        } else if (attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(new Error(
            "La transferencia no se acreditó en 10 minutos. Si el cliente ya la envió, quedará registrada en Mercado Pago; verifícala ahí antes de entregar el producto."
          ));
        }
      } catch (e) {
        if (attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(e);
        }
      }
    }, INTERVALO_MS);
  });

  promise.cancelar = () => {
    if (interval) clearInterval(interval);
  };

  return promise;
}
