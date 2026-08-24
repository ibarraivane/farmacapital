/**
 * Interfaz común de colector.
 * obtener() → RegistroCrudo[]
 * Un adaptador que falle no tumba el pipeline.
 */

"use strict";

const { crearRegistroCrudo } = require("../registroCrudo");

function validarAdaptador(adapter) {
  if (!adapter || typeof adapter.id !== "string" || !adapter.id) {
    throw new Error("adaptador_sin_id");
  }
  if (typeof adapter.obtener !== "function") {
    throw new Error("adaptador_sin_obtener");
  }
  if (adapter.tipo !== "compra" && adapter.tipo !== "venta") {
    throw new Error("adaptador_tipo_invalido");
  }
  return true;
}

async function recolectarFuente(adapter, ctx) {
  validarAdaptador(adapter);
  const filas = await adapter.obtener(ctx || {});
  if (!Array.isArray(filas)) throw new Error("adaptador_no_devolvio_lista");
  return filas.map((f) => crearRegistroCrudo({
    ...f,
    fuente: f.fuente || adapter.id,
    tipo: f.tipo || adapter.tipo,
  }));
}

async function recolectarTodas(adaptadores, ctx) {
  const ok = [];
  const errores = [];
  for (const adapter of adaptadores || []) {
    try {
      const filas = await recolectarFuente(adapter, ctx);
      ok.push(...filas);
    } catch (err) {
      errores.push({
        fuente: adapter && adapter.id,
        error: (err && err.message) || String(err),
      });
    }
  }
  return { registros: ok, errores };
}

module.exports = {
  validarAdaptador,
  recolectarFuente,
  recolectarTodas,
};
