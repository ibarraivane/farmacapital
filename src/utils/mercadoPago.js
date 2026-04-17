// ═══════════════════════════════════════════════════════════
// FARMAX — Mercado Pago Point Smart 2
// Integración con terminal de pago física
// Documentación: https://www.mercadopago.com.mx/developers
// ═══════════════════════════════════════════════════════════

// ── Configuración ────────────────────────────────────────
// IMPORTANTE: Estas keys van en variables de entorno (.env)
// REACT_APP_MP_PUBLIC_KEY=TEST-xxxx (sandbox)
// REACT_APP_MP_ACCESS_TOKEN=TEST-xxxx (sandbox)
// Para producción: usar keys reales de MP

const MP_PUBLIC_KEY   = process.env.REACT_APP_MP_PUBLIC_KEY   || null;
const MP_ACCESS_TOKEN = process.env.REACT_APP_MP_ACCESS_TOKEN || null;
const MP_DEVICE_ID    = process.env.REACT_APP_MP_DEVICE_ID    || null; // ID del Point Smart 2
const MP_BASE_URL     = "https://api.mercadopago.com";
const SANDBOX_MODE    = !MP_ACCESS_TOKEN?.startsWith("APP_USR");

/**
 * Verifica si Mercado Pago está configurado
 */
export function isMPConfigured() {
  return !!(MP_PUBLIC_KEY && MP_ACCESS_TOKEN);
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
    throw new Error("Mercado Pago no está configurado. Agrega las keys en .env");
  }
  if(!MP_DEVICE_ID) {
    throw new Error("ID del dispositivo Point Smart 2 no configurado (REACT_APP_MP_DEVICE_ID)");
  }

  const payload = {
    amount,
    description: description || "Venta Farmax",
    payment: {
      installments:        1,
      installments_cost:   "seller",
      type:                "credit_card",
    },
    additional_info: {
      external_reference: externalReference,
      print_on_terminal:  true, // Imprimir recibo en el terminal
    },
  };

  const response = await fetch(
    `${MP_BASE_URL}/point/integration-api/devices/${MP_DEVICE_ID}/payment-intents`,
    {
      method:  "POST",
      headers: {
        "Authorization": `Bearer ${MP_ACCESS_TOKEN}`,
        "Content-Type":  "application/json",
        "X-Sandbox":     SANDBOX_MODE ? "true" : "false",
      },
      body: JSON.stringify(payload),
    }
  );

  if(!response.ok) {
    const err = await response.json();
    throw new Error(`MP Error ${response.status}: ${err.message || JSON.stringify(err)}`);
  }

  return response.json();
}

/**
 * Consulta el estado de un pago
 * @param {string} paymentIntentId
 */
export async function consultarEstadoPago(paymentIntentId) {
  const response = await fetch(
    `${MP_BASE_URL}/point/integration-api/payment-intents/${paymentIntentId}`,
    {
      headers: { "Authorization": `Bearer ${MP_ACCESS_TOKEN}` }
    }
  );
  return response.json();
}

/**
 * Cancela una intención de pago
 * @param {string} paymentIntentId
 */
export async function cancelarPago(paymentIntentId) {
  const response = await fetch(
    `${MP_BASE_URL}/point/integration-api/devices/${MP_DEVICE_ID}/payment-intents/${paymentIntentId}`,
    {
      method:  "DELETE",
      headers: { "Authorization": `Bearer ${MP_ACCESS_TOKEN}` }
    }
  );
  return response.ok;
}

/**
 * Lista los dispositivos Point disponibles
 */
export async function listarDispositivos() {
  const response = await fetch(
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
export async function esperarConfirmacionPago(intentId, onStatus) {
  const MAX_ATTEMPTS = 36; // 36 × 5s = 3 minutos
  let attempts = 0;

  return new Promise((resolve, reject) => {
    const interval = setInterval(async () => {
      attempts++;
      try {
        const data = await consultarEstadoPago(intentId);
        const estado = data?.state || data?.status;
        onStatus?.(estado, data);

        if(estado === "FINISHED" || estado === "approved") {
          clearInterval(interval);
          resolve({ success:true, data });
        } else if(estado === "CANCELED" || estado === "rejected" || estado === "error") {
          clearInterval(interval);
          reject(new Error(`Pago ${estado}: ${data?.message || "Terminal rechazó el pago"}`));
        } else if(attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(new Error("Timeout: El terminal no respondió en 3 minutos"));
        }
      } catch(e) {
        if(attempts >= MAX_ATTEMPTS) {
          clearInterval(interval);
          reject(e);
        }
      }
    }, 5000); // Consultar cada 5 segundos
  });
}
