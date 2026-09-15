/**
 * Encargo de medicamentos (Caso A avisos + Caso B cotización).
 * Enums y reglas alineados a docs/claude_encargo-medicamentos.md + E.1–E.11.
 */

import {
  CONFIG_CLAVE_VIGENCIA_COTIZACION_DIAS,
  ENCARGO_TZ,
  REQUIERE_TELEFONO_OBLIGATORIO,
  TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT,
  tiempoVigenciaCotizacionDiasFromEnv,
} from "../config/encargo";

export {
  CONFIG_CLAVE_VIGENCIA_COTIZACION_DIAS,
  ENCARGO_TZ,
  REQUIERE_TELEFONO_OBLIGATORIO,
  TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT,
  tiempoVigenciaCotizacionDiasFromEnv,
};

/** Caso A — cola manual wa.me; modelo listo para WhatsApp Business API después. */
export const AVISO_ESTADOS_UI = {
  pendiente: "pendiente",
  listo_avisar: "listo_avisar",
  avisado: "avisado",
};

export const ENCARGO_ESTADOS = [
  "pendiente_cotizacion",
  "cotizado",
  "aceptado",
  "rechazado",
  "expirado",
  "pagado",
  "consiguiendo",
  "listo_para_entrega",
  "entregado",
  "cancelado",
];

/** Estados operativos que vendedor y admin pueden marcar (E.11 / spec §5). */
export const ENCARGO_ESTADOS_OPERATIVOS_VENDEDOR = [
  "consiguiendo",
  "listo_para_entrega",
  "entregado",
];

export const COTIZACION_ESTADOS = ["enviada", "aceptada", "rechazada", "expirada"];

/** Alineado a check SQL cotizacion_encargo_disponibilidad_chk. */
export const COTIZACION_DISPONIBILIDAD = [
  "disponible",
  "sujeto_a_confirmacion",
  "no_disponible",
];

/**
 * metodo_entrega:
 * - domicilio / recoger_en_tienda — flujo normal (§4)
 * - entrega_personalizada — solo cadena fría (§4.1); nunca Uber/DiDi/propio auto
 */
export const ENCARGO_METODOS_ENTREGA = [
  "domicilio",
  "recoger_en_tienda",
  "entrega_personalizada",
];

export const ENCARGO_METODOS_ENTREGA_CADENA_FRIA = [
  "recoger_en_tienda",
  "entrega_personalizada",
];

export const ENCARGO_METODOS_ENTREGA_NORMAL = ["domicilio", "recoger_en_tienda"];

export function normalizarTelefonoEncargo(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.length >= 10) return digits.slice(-10);
  return digits;
}

export function normalizarNombreEncargo(raw) {
  return String(raw || "")
    .trim()
    .replace(/\s+/g, " ")
    .slice(0, 120);
}

export function normalizarNombreMedicamento(raw) {
  return String(raw || "")
    .trim()
    .replace(/\s+/g, " ")
    .slice(0, 200);
}

export function normalizarPresentacion(raw) {
  const t = String(raw || "")
    .trim()
    .replace(/\s+/g, " ")
    .slice(0, 120);
  return t || null;
}

export function normalizarComentarioCliente(raw) {
  const t = String(raw || "")
    .trim()
    .replace(/\s+/g, " ")
    .slice(0, 500);
  return t || null;
}

/**
 * Vigencia: now + N días (spec: vigencia_hasta = now + TIEMPO_VIGENCIA_COTIZACION_DIAS).
 * Zona documentada: America/Mexico_City (ENCARGO_TZ).
 */
export function calcularVigenciaHasta(
  fromDate = new Date(),
  dias = tiempoVigenciaCotizacionDiasFromEnv(),
) {
  const n = Number(dias);
  const days =
    Number.isFinite(n) && n >= 1 ? Math.round(n) : TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT;
  return new Date(fromDate.getTime() + days * 24 * 60 * 60 * 1000);
}

export function cotizacionVigente({ vigencia_hasta, estado, now = new Date() } = {}) {
  if (estado && estado !== "enviada") return false;
  if (!vigencia_hasta) return false;
  const until = new Date(vigencia_hasta);
  if (Number.isNaN(until.getTime())) return false;
  return until.getTime() > now.getTime();
}

/**
 * Backend: método de entrega permitido según cadena fría.
 * Nunca domicilio automático (Uber/DiDi/propio) si requiere_cadena_fria.
 */
export function metodoEntregaPermitido({ requiere_cadena_fria, metodo_entrega } = {}) {
  const m = String(metodo_entrega || "").trim();
  if (!ENCARGO_METODOS_ENTREGA.includes(m)) {
    return { ok: false, error: "metodo_entrega_invalido" };
  }
  if (requiere_cadena_fria) {
    if (!ENCARGO_METODOS_ENTREGA_CADENA_FRIA.includes(m)) {
      return { ok: false, error: "cadena_fria_bloquea_domicilio_automatico" };
    }
    return { ok: true };
  }
  if (m === "entrega_personalizada") {
    return { ok: false, error: "entrega_personalizada_solo_cadena_fria" };
  }
  return { ok: true };
}

/** Caso A: alta de aviso (solo teléfono; sin login). */
export function validarAvisoDisponibilidad(raw = {}) {
  const cliente_nombre = normalizarNombreEncargo(raw.cliente_nombre || raw.nombre);
  const cliente_telefono = normalizarTelefonoEncargo(raw.cliente_telefono || raw.telefono);
  const producto_id = Number(raw.producto_id);
  const errors = [];
  if (!Number.isFinite(producto_id) || producto_id < 1) {
    errors.push("Falta el producto del catálogo.");
  }
  if (REQUIERE_TELEFONO_OBLIGATORIO && cliente_telefono.length !== 10) {
    errors.push("Teléfono de 10 dígitos para WhatsApp.");
  }
  if (cliente_nombre && cliente_nombre.length < 2) {
    errors.push("Nombre demasiado corto.");
  }
  return {
    ok: errors.length === 0,
    errors,
    value: {
      producto_id: Number.isFinite(producto_id) ? producto_id : null,
      cliente_nombre: cliente_nombre || null,
      cliente_telefono,
    },
  };
}

/** Caso B: formulario público de encargo. */
export function validarEncargoPublico(raw = {}) {
  const cliente_nombre = normalizarNombreEncargo(raw.cliente_nombre || raw.nombre);
  const cliente_telefono = normalizarTelefonoEncargo(raw.cliente_telefono || raw.telefono);
  const nombre_medicamento = normalizarNombreMedicamento(
    raw.nombre_medicamento || raw.texto || raw.medicamento,
  );
  const presentacion = normalizarPresentacion(raw.presentacion);
  const comentario_cliente = normalizarComentarioCliente(
    raw.comentario_cliente || raw.notas || raw.comentario,
  );
  const cantidad = Number(raw.cantidad);
  const requiere_receta = raw.requiere_receta === true || raw.requiere_receta === "true";
  const receta_url = String(raw.receta_url || "").trim().slice(0, 500) || null;

  const errors = [];
  if (nombre_medicamento.length < 2) {
    errors.push("Escribe el nombre del medicamento.");
  }
  if (!Number.isFinite(cantidad) || cantidad < 1 || cantidad > 999) {
    errors.push("La cantidad debe ser entre 1 y 999.");
  }
  if (cliente_nombre.length < 2) {
    errors.push("Escribe tu nombre.");
  }
  if (REQUIERE_TELEFONO_OBLIGATORIO && cliente_telefono.length !== 10) {
    errors.push("Teléfono de 10 dígitos para WhatsApp.");
  }
  if (requiere_receta && !receta_url) {
    errors.push("Sube la foto o PDF de la receta antes de continuar.");
  }

  return {
    ok: errors.length === 0,
    errors,
    value: {
      cliente_nombre,
      cliente_telefono,
      nombre_medicamento,
      presentacion,
      cantidad: Number.isFinite(cantidad)
        ? Math.max(1, Math.min(999, Math.round(cantidad)))
        : 1,
      requiere_receta,
      receta_url: requiere_receta ? receta_url : null,
      comentario_cliente,
    },
  };
}

/** Cotización: solo admin (validación de forma; el rol se exige en RPC). */
export function validarCotizacionAdmin(raw = {}) {
  const precio_unitario = Number(raw.precio_unitario);
  const tiempo_estimado_dias = Number(raw.tiempo_estimado_dias);
  const disponibilidad = String(raw.disponibilidad || "").trim();
  const nota_disponibilidad =
    String(raw.nota_disponibilidad || "")
      .trim()
      .slice(0, 240) || null;
  const tiempo_estimado_nota =
    String(raw.tiempo_estimado_nota || "")
      .trim()
      .slice(0, 240) || null;
  const requiere_cadena_fria =
    raw.requiere_cadena_fria === true || raw.requiere_cadena_fria === "true";
  const cantidad = Number(raw.cantidad);

  const errors = [];
  if (!Number.isFinite(precio_unitario) || precio_unitario <= 0) {
    errors.push("Precio unitario inválido.");
  }
  if (
    !Number.isFinite(tiempo_estimado_dias) ||
    tiempo_estimado_dias < 0 ||
    tiempo_estimado_dias > 365
  ) {
    errors.push("Tiempo estimado en días inválido.");
  }
  if (!COTIZACION_DISPONIBILIDAD.includes(disponibilidad)) {
    errors.push("Disponibilidad inválida.");
  }
  if (!Number.isFinite(cantidad) || cantidad < 1) {
    errors.push("Cantidad de cotización inválida.");
  }

  const precio_total =
    Number.isFinite(precio_unitario) && Number.isFinite(cantidad)
      ? Math.round(precio_unitario * cantidad * 100) / 100
      : null;

  return {
    ok: errors.length === 0,
    errors,
    value: {
      precio_unitario: Number.isFinite(precio_unitario)
        ? Math.round(precio_unitario * 100) / 100
        : null,
      cantidad: Number.isFinite(cantidad) ? Math.round(cantidad) : null,
      precio_total,
      disponibilidad,
      nota_disponibilidad,
      tiempo_estimado_dias: Number.isFinite(tiempo_estimado_dias)
        ? Math.round(tiempo_estimado_dias)
        : null,
      tiempo_estimado_nota,
      requiere_cadena_fria,
    },
  };
}

/** Restricción spec: no aceptar encargo sin cotización aceptada. */
export function puedeMarcarEncargoAceptado({ cotizacion_estado } = {}) {
  return cotizacion_estado === "aceptada";
}

export function buildAvisoDisponibilidadWhatsApp({
  telefono,
  nombre,
  producto_nombre,
} = {}) {
  const digits = normalizarTelefonoEncargo(telefono);
  if (digits.length !== 10) return "";
  const quien = nombre ? ` ${nombre}` : "";
  const prod = producto_nombre ? String(producto_nombre).trim() : "tu producto";
  const msg =
    `Hola${quien}, soy FarmaCapital. Ya llegó tu ${prod}, ya está disponible. ` +
    `Te esperamos en la farmacia o puedes pedirlo en farmacapital.mx.`;
  return `https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`;
}

export function buildCotizacionWhatsApp({
  telefono,
  nombre,
  nombre_medicamento,
  precio_total,
  tiempo_estimado_dias,
  vigencia_hasta,
  accept_url,
} = {}) {
  const digits = normalizarTelefonoEncargo(telefono);
  if (digits.length !== 10) return "";
  const quien = nombre ? ` ${nombre}` : "";
  const med = nombre_medicamento ? String(nombre_medicamento).trim() : "el medicamento";
  const precio =
    precio_total != null && Number.isFinite(Number(precio_total))
      ? `$${Number(precio_total).toFixed(2)}`
      : "el precio cotizado";
  const dias =
    tiempo_estimado_dias != null
      ? `${tiempo_estimado_dias} día(s) hábiles aprox.`
      : "el tiempo estimado";
  const hasta = vigencia_hasta
    ? new Date(vigencia_hasta).toLocaleString("es-MX", { timeZone: ENCARGO_TZ })
    : "la fecha límite";
  const link = accept_url ? `\n\nPara aceptar o rechazar: ${accept_url}` : "";
  const msg =
    `Hola${quien}, soy FarmaCapital. Cotización de *${med}*: ${precio}. ` +
    `Tiempo estimado: ${dias}. Vigente hasta ${hasta}.${link}`;
  return `https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`;
}
