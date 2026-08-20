'use strict';

const MP_SUPPORT_TICKET = 'WCS-43806 / 470711389';

function normalizeTerminal(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const id = String(raw.id || '').trim();
  if (!id) return null;
  return {
    id,
    pos_id: raw.pos_id ?? null,
    store_id: raw.store_id != null ? String(raw.store_id) : null,
    external_pos_id: raw.external_pos_id == null ? '' : String(raw.external_pos_id),
    operating_mode: raw.operating_mode || null,
  };
}

function terminalsFromV1Payload(data) {
  const rows = data?.data?.terminals || data?.terminals || [];
  if (!Array.isArray(rows)) return [];
  return rows.map(normalizeTerminal).filter(Boolean);
}

function terminalsFromLegacyPayload(data) {
  const rows = data?.devices || [];
  if (!Array.isArray(rows)) return [];
  return rows.map(normalizeTerminal).filter(Boolean);
}

function findTerminal(devices, deviceId) {
  const id = String(deviceId || '').trim();
  if (!id) return null;
  return (devices || []).find((d) => d.id === id) || null;
}

function serialFromTerminalId(terminalId) {
  const raw = String(terminalId || '');
  const parts = raw.split('__');
  return parts.length > 1 ? parts.slice(1).join('__') : raw || null;
}

function diagnosisFromStatus({ operatingMode, pendingCount, orderStatusAfterWait }) {
  if (operatingMode && operatingMode !== 'PDV') {
    return 'Terminal no está en PDV según API.';
  }
  if (Number(pendingCount) > 0) {
    return `Hay ${pendingCount} cobro(s) pendiente(s) en cola. Si no se pueden cancelar por API, pedir a Mercado Pago que las libere.`;
  }
  if (orderStatusAfterWait === 'at_terminal') {
    return 'OK: el Point recibe cobros.';
  }
  if (orderStatusAfterWait === 'created') {
    return 'FarmaCapital y Mercado Pago OK; el Point físico no sincroniza. Desvincula y revincula el lector en la app MP.';
  }
  return 'API en PDV y sin cola visible. Si el cobro no aparece en el Point, el despacho backend↔terminal sigue fallando (firmware / mapeo caja).';
}

function buildSupportPacket({
  deviceId,
  device,
  source,
  pending,
  userId,
  applicationId,
} = {}) {
  const terminalId = String(deviceId || device?.id || '');
  const pendingRows = Array.isArray(pending) ? pending : [];
  return {
    ticket: MP_SUPPORT_TICKET,
    comercio: 'FarmaCapital',
    sitio: 'https://www.farmacapital.mx',
    terminal_id: terminalId || null,
    serial: serialFromTerminalId(terminalId),
    store_id: device?.store_id || null,
    pos_id: device?.pos_id ?? null,
    external_pos_id: device?.external_pos_id || '',
    operating_mode: device?.operating_mode || null,
    user_id: userId || null,
    application_id: applicationId || null,
    terminals_source: source || null,
    pending_count: pendingRows.length,
    pending_order_ids: pendingRows.map((o) => o.id).filter(Boolean),
    create_order_body: {
      type: 'point',
      expiration_time: 'PT16M',
      transactions: { payments: [{ amount: '18.00' }] },
      config: {
        point: {
          terminal_id: terminalId || 'NEWLAND_N950__N950NCCC05728001',
          print_on_terminal: 'seller_ticket',
        },
        payment_method: { default_type: 'credit_card' },
      },
      description: 'Venta FarmaCapital',
    },
    nota: 'El terminal permanece encendido, en modo PDV/activado y con conexión estable. Las órdenes se crean en status created y no pasan a at_terminal.',
  };
}

function formatSupportPacketText(packet) {
  const p = packet || {};
  return [
    `Caso: ${p.ticket || MP_SUPPORT_TICKET}`,
    `Comercio: ${p.comercio || 'FarmaCapital'}`,
    `terminal_id: ${p.terminal_id || ''}`,
    `serial: ${p.serial || ''}`,
    `store_id: ${p.store_id || ''}`,
    `pos_id: ${p.pos_id ?? ''}`,
    `external_pos_id: ${p.external_pos_id === '' ? '(vacío)' : (p.external_pos_id || '')}`,
    `operating_mode: ${p.operating_mode || ''}`,
    `user_id: ${p.user_id || ''}`,
    `application_id: ${p.application_id || ''}`,
    `Pendientes API: ${p.pending_count ?? 0}`,
    p.pending_order_ids?.length ? `IDs pendientes: ${p.pending_order_ids.join(', ')}` : null,
    p.nota || '',
  ]
    .filter((line) => line != null && String(line).length)
    .join('\n');
}

module.exports = {
  MP_SUPPORT_TICKET,
  normalizeTerminal,
  terminalsFromV1Payload,
  terminalsFromLegacyPayload,
  findTerminal,
  serialFromTerminalId,
  diagnosisFromStatus,
  buildSupportPacket,
  formatSupportPacketText,
};
