'use strict';

function normalizarTelefono(raw) {
  const digits = String(raw || '').replace(/\D/g, '');
  if (digits.length >= 10) return digits.slice(-10);
  return digits;
}

function normalizarNombre(raw) {
  return String(raw || '')
    .trim()
    .replace(/\s+/g, ' ')
    .slice(0, 120);
}

/** Validación pública Caso A (API). */
function validarAvisoDisponibilidadApi(raw) {
  const body = raw && typeof raw === 'object' ? raw : {};
  const producto_id = Number(body.producto_id || body.productoId);
  const cliente_telefono = normalizarTelefono(body.telefono || body.cliente_telefono);
  const cliente_nombre = normalizarNombre(body.nombre || body.cliente_nombre);
  const honeypot = Boolean(String(body.website || body.company || '').trim());

  const errors = [];
  if (!Number.isFinite(producto_id) || producto_id < 1) errors.push('producto_id');
  if (cliente_telefono.length !== 10) errors.push('telefono');
  if (cliente_nombre && cliente_nombre.length < 2) errors.push('nombre');

  return {
    ok: errors.length === 0,
    errors,
    honeypot,
    value: {
      producto_id: Number.isFinite(producto_id) ? producto_id : null,
      cliente_telefono,
      cliente_nombre: cliente_nombre || null,
    },
  };
}

module.exports = {
  normalizarTelefono,
  normalizarNombre,
  validarAvisoDisponibilidadApi,
};
