/** Empleado: reenvía ticket/recibo del pedido online por correo (gracias + PDF). */

export async function reenviarTicketCorreoPedido({ pedidoId, sessionToken }) {
  const resp = await fetch("/api/notifications/order-email", {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      pedidoId,
      employeeSessionToken: sessionToken,
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || data?.ok === false) {
    return {
      ok: false,
      error: data?.error || `http_${resp.status}`,
      detail: data?.detail || null,
      ...data,
    };
  }
  return { ok: true, ...data };
}
