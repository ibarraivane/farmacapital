'use strict';

const { jsPDF } = require('jspdf');
const { FARMACIA_FISCAL } = require('./farmaciaFiscal');

function dinero(n) {
  const v = Number(n);
  return `$${(Number.isFinite(v) ? v : 0).toFixed(2)}`;
}

/** Ticket de cobro pendiente, para adjuntar al correo del envío cotizado. */
function ticketEnvioPdfBase64({
  pedidoId,
  nombre,
  items,
  productos,
  envio,
  total,
  ahora = new Date(),
} = {}) {
  const folio = `#FC-${String(pedidoId).padStart(4, '0')}`;
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
  doc.text('Pendiente de pago · envío a domicilio', 14, y);
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
  doc.text('Productos', 14, y);
  doc.text(dinero(productos), 134, y, { align: 'right' });
  y += 5;
  doc.text('Envío a domicilio', 14, y);
  doc.text(dinero(envio), 134, y, { align: 'right' });
  y += 7;
  doc.setFont('times', 'bold');
  doc.setFontSize(13);
  doc.text('Total a pagar', 14, y);
  doc.text(dinero(total), 134, y, { align: 'right' });
  y += 10;
  doc.setFont('times', 'normal');
  doc.setFontSize(9);
  const nota = doc.splitTextToSize(
    'Para liquidar, abre tu carrito en farmacapital.mx/carrito con el teléfono del pedido y toca Pagar ahora.',
    120,
  );
  doc.text(nota, 14, y);
  const raw = doc.output('arraybuffer');
  return Buffer.from(raw).toString('base64');
}

module.exports = { ticketEnvioPdfBase64 };
