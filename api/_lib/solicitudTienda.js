'use strict';

const STAFF_EMAILS = [
  'contacto@farmacapital.mx',
  'farmacapital@outlook.com',
];

function normalizarTexto(raw, max) {
  return String(raw || '').trim().replace(/\s+/g, ' ').slice(0, max);
}

function normalizarEmail(raw) {
  const e = String(raw || '').trim().toLowerCase();
  if (!e) return '';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e)) return '';
  return e.slice(0, 120);
}

function normalizarTelefono(raw) {
  const digits = String(raw || '').replace(/\D/g, '');
  if (digits.length >= 10) return digits.slice(-10);
  return digits;
}

function validarSolicitudTienda(raw) {
  const body = raw && typeof raw === 'object' ? raw : {};
  const texto = normalizarTexto(body.texto, 200);
  const cantidad = Number(body.cantidad);
  const nombre = normalizarTexto(body.nombre || body.cliente_nombre, 120);
  const telefono = normalizarTelefono(body.telefono || body.cliente_telefono);
  const email = normalizarEmail(body.email || body.cliente_email);
  const direccion = normalizarTexto(body.direccion, 240);
  const notas = normalizarTexto(body.notas, 500);
  let urgencia = String(body.urgencia || 'sin_prisa').trim();
  if (!['hoy', 'manana', 'sin_prisa'].includes(urgencia)) urgencia = 'sin_prisa';

  const errors = [];
  if (texto.length < 2) errors.push('texto');
  if (!Number.isFinite(cantidad) || cantidad < 1 || cantidad > 999) errors.push('cantidad');
  if (nombre.length < 2) errors.push('nombre');
  if (telefono.length !== 10) errors.push('telefono');

  return {
    ok: errors.length === 0,
    errors,
    honeypot: Boolean(String(body.website || body.company || '').trim()),
    value: {
      texto,
      cantidad: Number.isFinite(cantidad) ? Math.max(1, Math.min(999, Math.round(cantidad))) : 1,
      urgencia,
      notas: notas || null,
      cliente_nombre: nombre,
      cliente_telefono: telefono,
      cliente_email: email || null,
      direccion: direccion || null,
    },
  };
}

function buildStaffEmail({ value, id }) {
  const v = value || {};
  const folio = id != null ? `#LQ-${id}` : 'nueva';
  const subject = `Lo que buscan (tienda) ${folio}: ${v.texto || 'solicitud'}`;
  const lines = [
    'Nueva solicitud desde farmacapital.mx — Te lo conseguimos.',
    '',
    `Folio: ${folio}`,
    `Qué buscan: ${v.texto || '—'}`,
    `Cantidad: ${v.cantidad || 1}`,
    `Urgencia: ${v.urgencia || 'sin_prisa'}`,
    `Cliente: ${v.cliente_nombre || '—'}`,
    `WhatsApp: ${v.cliente_telefono || '—'}`,
    `Correo: ${v.cliente_email || '—'}`,
    `Dirección: ${v.direccion || '—'}`,
    `Notas: ${v.notas || '—'}`,
    '',
    'Ya está (o debería estar) en Admin → Lo que buscan.',
    'Escríbele por WhatsApp o correo con el costo y la liga de pago.',
    'El envío a domicilio se cotiza aparte.',
  ];
  return { subject, text: lines.join('\n'), to: STAFF_EMAILS.slice() };
}

module.exports = {
  STAFF_EMAILS,
  validarSolicitudTienda,
  buildStaffEmail,
};
