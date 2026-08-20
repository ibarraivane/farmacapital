export function serialFromTerminalId(terminalId) {
  const raw = String(terminalId || "");
  const parts = raw.split("__");
  return parts.length > 1 ? parts.slice(1).join("__") : raw || "";
}

export function diagnosisFromPointStatus({ operatingMode, pendingCount, orderStatusAfterWait } = {}) {
  if (operatingMode && operatingMode !== "PDV") {
    return "Terminal no está en PDV según API.";
  }
  if (Number(pendingCount) > 0) {
    return `Hay ${pendingCount} cobro(s) pendiente(s) en cola. Si no se pueden cancelar por API, pedir a Mercado Pago que las libere.`;
  }
  if (orderStatusAfterWait === "at_terminal") {
    return "OK: el Point recibe cobros.";
  }
  if (orderStatusAfterWait === "created") {
    return "FarmaCapital y Mercado Pago OK; el Point físico no sincroniza. Desvincula y revincula el lector en la app MP.";
  }
  return "API en PDV y sin cola visible. Si el cobro no aparece en el Point, el despacho backend↔terminal sigue fallando (firmware / mapeo caja).";
}

export function formatSupportPacketText(packet = {}) {
  return [
    `Caso: ${packet.ticket || "WCS-43806 / 470711389"}`,
    `Comercio: ${packet.comercio || "FarmaCapital"}`,
    `terminal_id: ${packet.terminal_id || ""}`,
    `serial: ${packet.serial || serialFromTerminalId(packet.terminal_id)}`,
    `store_id: ${packet.store_id || ""}`,
    `pos_id: ${packet.pos_id ?? ""}`,
    `external_pos_id: ${packet.external_pos_id === "" ? "(vacío)" : (packet.external_pos_id || "")}`,
    `operating_mode: ${packet.operating_mode || ""}`,
    `user_id: ${packet.user_id || ""}`,
    `application_id: ${packet.application_id || ""}`,
    `Pendientes API: ${packet.pending_count ?? 0}`,
    packet.pending_order_ids?.length ? `IDs pendientes: ${packet.pending_order_ids.join(", ")}` : null,
    packet.nota || "El terminal permanece encendido, en modo PDV/activado y con conexión estable.",
  ]
    .filter((line) => line != null && String(line).length)
    .join("\n");
}
