#!/usr/bin/env node
/**
 * Sonda para el cobro por transferencia SPEI en Mercado Pago.
 *
 * Antes de construir el flujo completo en el POS hay que responder tres cosas
 * que la documentación no aclara:
 *
 *   1. ¿La cuenta acepta órdenes con payment_method "clabe"?
 *   2. ¿Devuelve una CLABE de referencia única por cobro?
 *   3. ¿Cobra comisión, y de cuánto?
 *
 * El script crea una orden de monto mínimo y muestra la respuesta cruda de MP.
 * NO mueve dinero: sólo genera una referencia de cobro que nadie va a pagar y
 * que expira sola. Si quieres, después puedes consultarla con --estado.
 *
 * Uso — el token nunca se escribe en el código ni se comparte:
 *
 *   MP_ACCESS_TOKEN='APP_USR-...' node scripts/probar_spei_mp.js
 *   MP_ACCESS_TOKEN='APP_USR-...' node scripts/probar_spei_mp.js --estado <order_id>
 *
 * El token está en Vercel → Settings → Environment Variables → REACT_APP_MP_ACCESS_TOKEN.
 */
const BASE = "https://api.mercadopago.com";
const TOKEN = process.env.MP_ACCESS_TOKEN;
const MONTO = process.env.MONTO || "5.00";

if (!TOKEN) {
  console.error("Falta MP_ACCESS_TOKEN.\n");
  console.error("  MP_ACCESS_TOKEN='APP_USR-...' node scripts/probar_spei_mp.js\n");
  process.exit(1);
}

const headers = (extra = {}) => ({
  Authorization: `Bearer ${TOKEN}`,
  "Content-Type": "application/json",
  ...extra,
});

function buscar(obj, clave, prof = 0) {
  // Las respuestas de MP anidan hondo y cambian de forma entre versiones;
  // más vale buscar la llave que asumir la ruta.
  if (!obj || typeof obj !== "object" || prof > 8) return undefined;
  if (clave in obj) return obj[clave];
  for (const v of Object.values(obj)) {
    const r = buscar(v, clave, prof + 1);
    if (r !== undefined) return r;
  }
  return undefined;
}

async function consultar(orderId) {
  const res = await fetch(`${BASE}/v1/orders/${encodeURIComponent(orderId)}`, { headers: headers() });
  const data = await res.json().catch(() => ({}));
  console.log(`HTTP ${res.status}\n`);
  console.log(JSON.stringify(data, null, 2));
  if (res.ok) {
    console.log("\n── Resumen ──");
    console.log("estado    :", buscar(data, "status"), "/", buscar(data, "status_detail"));
    console.log("referencia:", buscar(data, "reference"));
  }
}

async function crear() {
  const externalRef = `FC-SPEI-TEST-${Date.now()}`;
  const body = {
    type: "online",
    processing_mode: "automatic",
    external_reference: externalRef,
    transactions: {
      payments: [{
        amount: MONTO,
        payment_method: { id: "clabe", type: "bank_transfer" },
      }],
    },
    description: "Prueba SPEI FarmaCapital",
  };

  console.log("→ POST /v1/orders");
  console.log(JSON.stringify(body, null, 2), "\n");

  const res = await fetch(`${BASE}/v1/orders`, {
    method: "POST",
    headers: headers({ "X-Idempotency-Key": externalRef }),
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));

  console.log(`← HTTP ${res.status}\n`);
  console.log(JSON.stringify(data, null, 2));

  if (!res.ok) {
    console.log("\n── No funcionó ──");
    console.log("Puede ser que la cuenta no tenga habilitado el cobro por");
    console.log("transferencia, o que el formato del cuerpo cambió. El mensaje");
    console.log("de arriba lo dice; pásamelo y lo ajusto.");
    return;
  }

  const id  = buscar(data, "id");
  const ref = buscar(data, "reference");
  const url = buscar(data, "ticket_url");

  console.log("\n── Lo que importa ──");
  console.log("order_id  :", id);
  console.log("referencia:", ref ?? "(no vino — revisa el JSON de arriba)");
  console.log("liga      :", url ?? "(no vino)");
  console.log("estado    :", buscar(data, "status"), "/", buscar(data, "status_detail"));
  console.log("\nSi hay referencia, transfiere los $" + MONTO + " desde tu banco y luego:");
  console.log(`  MP_ACCESS_TOKEN='...' node scripts/probar_spei_mp.js --estado ${id}`);
  console.log("\nLa comisión NO aparece aquí: sale en el detalle del pago ya");
  console.log("acreditado, o preguntándole directo a Mercado Pago.");
}

const [flag, orderId] = process.argv.slice(2);
(flag === "--estado" && orderId ? consultar(orderId) : crear())
  .catch(e => { console.error("Error:", e.message); process.exit(1); });
