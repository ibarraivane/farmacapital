const MSG_TIMEOUT =
  "No se pudo guardar. La base tardó demasiado; volvé a intentar en un momento.";

export function esTimeoutEditarProducto(error) {
  const msg = typeof error === "string" ? error : error?.message;
  return /statement timeout|lock timeout|canceling statement/i.test(String(msg || ""));
}

export function mensajeErrorEditarProducto(error) {
  const msg = typeof error === "string" ? error : error?.message;
  if (esTimeoutEditarProducto(msg)) return MSG_TIMEOUT;
  return msg || "No se pudo guardar.";
}

/**
 * admin_editar_producto a veces lo corta Postgres a los ~8 s
 * (candado del renglón o la consulta de columnas). Reintenta ese corte.
 */
export async function rpcAdminEditarProducto(client, args, { intentos = 3, esperar } = {}) {
  let ultimo = null;
  const veces = Math.max(1, intentos);
  for (let i = 0; i < veces; i += 1) {
    const res = await client.rpc("admin_editar_producto", args);
    if (!res?.error) return res;
    ultimo = res;
    const msg = res.error?.message || "";
    if (!esTimeoutEditarProducto(msg) || i === veces - 1) return res;
    if (esperar) await esperar(300 * (i + 1));
  }
  return ultimo;
}
