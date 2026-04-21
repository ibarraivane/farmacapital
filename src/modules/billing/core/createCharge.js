/**
 * Placeholder: conectar con RPC/facturación cuando exista el flujo real.
 * @param {{ type: string, amount: number, reference: string|number }} payload
 */
export function createCharge(payload) {
  if (process.env.NODE_ENV === "development") {
    console.info("[billing/createCharge]", payload);
  }
}
