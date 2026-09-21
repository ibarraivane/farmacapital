'use strict';

const { jsPDF } = require('jspdf');
const { FARMACIA_FISCAL } = require('./farmaciaFiscal');

function dinero(n) {
  const v = Number(n);
  return `$${(Number.isFinite(v) ? v : 0).toFixed(2)}`;
}

function folioTicket(pedidoId) {
  return `#FC-${String(pedidoId).padStart(4, '0')}`;
}

function nombreArchivoTicket(pedidoId) {
  return `ticket-FC-${String(pedidoId).padStart(4, '0')}.pdf`;
}

/**
 * PDF del ticket que ya existe (pago aprobado + URL /r/{token}).
 * No se usa al cotizar el envío: ahí el ticket todavía no existe.
 */
function ticketCompraPdfBase64({
  pedidoId,
  nombre,
  items,
  productos,
  envio,
  total,
  ticketUrl,
  ahora = new Date(),
} = {}) {
  const url = String(ticketUrl || '').trim();
  if (!url) return null;
  const folio = folioTicket(pedidoId);
  const doc = new jsPDF({ unit: 'mm', format: 'a5' });
  const cfg = FARMACIA_FISCAL;
  let y = 16;
  doc.setFont('times', 'bold');
  doc.setFontSize(16);
  doc.text('FarmaCapital', 14, y);
  y += 6;
  doc.setFont('times', 'normal');
  doc.setFontSize(9);
  doc.text(cfg.direccion_comercial, 14, y);
  y += 4;
  doc.text(`Tel. ${cfg.telefono_display} · contacto@farmacapital.mx`, 14, y);
  y += 8;
  doc.setFont('times', 'bold');
  doc.setFontSize(13);
  doc.text(`Ticket ${folio}`, 14, y);
  y += 6;
  doc.setFont('times', 'normal');
  doc.setFontSize(10);
  const fecha = ahora.toLocaleString('es-MX', {
    timeZone: 'America/Mexico_City',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
  doc.text(`Fecha: ${fecha}`, 14, y);
  y += 5;
  if (String(nombre || '').trim()) {
    doc.text(`Cliente: ${String(nombre).trim()}`, 14, y);
    y += 5;
  }
  doc.text('Pagado', 14, y);
  y += 8;
  doc.setDrawColor(180);
  doc.line(14, y, 134, y);
  y += 6;
  const lineas = Array.isArray(items) ? items : [];
  doc.setFontSize(10);
  lineas.forEach((l) => {
    const label = `${l.nombre} ×${l.qty}`;
    const monto = dinero(l.importe);
    const cortado = doc.splitTextToSize(label, 90);
    doc.text(cortado, 14, y);
    doc.text(monto, 134, y, { align: 'right' });
    y += 5 * cortado.length;
  });
  y += 2;
  doc.line(14, y, 134, y);
  y += 6;
  if (productos != null) {
    doc.text('Productos', 14, y);
    doc.text(dinero(productos), 134, y, { align: 'right' });
    y += 5;
  }
  const envioN = Number(envio);
  if (Number.isFinite(envioN) && envioN > 0) {
    doc.text('Envío a domicilio', 14, y);
    doc.text(dinero(envioN), 134, y, { align: 'right' });
    y += 5;
  }
  y += 2;
  doc.setFont('times', 'bold');
  doc.setFontSize(13);
  doc.text('Total pagado', 14, y);
  doc.text(dinero(total), 134, y, { align: 'right' });
  y += 10;
  doc.setFont('times', 'normal');
  doc.setFontSize(9);
  const nota = doc.splitTextToSize(
    `Gracias por tu compra. Tu ticket también está en ${url}`,
    120,
  );
  doc.text(nota, 14, y);
  const raw = doc.output('arraybuffer');
  return Buffer.from(raw).toString('base64');
}

/** Adjunto del correo de pago. Null si el ticket público todavía no existe. */
function ticketPagoAdjunto({ pedidoId, nombre, items, productos, envio, total, ticketUrl, ahora } = {}) {
  const url = String(ticketUrl || '').trim();
  if (!url) return null;
  const content = ticketCompraPdfBase64({
    pedidoId,
    nombre,
    items,
    productos,
    envio,
    total,
    ticketUrl: url,
    ahora,
  });
  if (!content) return null;
  return {
    url,
    filename: nombreArchivoTicket(pedidoId),
    content,
  };
}

module.exports = {
  ticketCompraPdfBase64,
  ticketPagoAdjunto,
  nombreArchivoTicket,
};
