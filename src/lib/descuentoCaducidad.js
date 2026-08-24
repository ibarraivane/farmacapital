/**
 * Motor puro de descuento por caducidad.
 * Recibe un objeto, no toca base de datos.
 */

const { CADUCIDAD_CONFIG } = require("../config/caducidad");

function formatCaducidadMesAnio(iso) {
  if (!iso) return "";
  const s = String(iso).slice(0, 10);
  const m = /^(\d{4})-(\d{2})/.exec(s);
  if (!m) return s;
  return `${m[2]}/${m[1]}`;
}

const MS_DIA = 86400000;

function parseFechaSolo(value) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return new Date(value.getFullYear(), value.getMonth(), value.getDate());
  }
  const s = String(value || "").slice(0, 10);
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
  if (!m) return null;
  return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
}

function diasEntre(hasta, desde) {
  const a = parseFechaSolo(hasta);
  const b = parseFechaSolo(desde);
  if (!a || !b) return null;
  return Math.round((a.getTime() - b.getTime()) / MS_DIA);
}

function addDays(fecha, n) {
  const d = parseFechaSolo(fecha);
  if (!d) return null;
  d.setDate(d.getDate() + n);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function ymdDe(fecha) {
  const d = parseFechaSolo(fecha);
  if (!d) return null;
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function floorToHalf(n) {
  return Math.floor(Number(n) * 2) / 2;
}

function ceilToHalf(n) {
  return Math.ceil(Number(n) * 2) / 2;
}

/** Abajo al 0.50. Si queda bajo el piso, arriba al 0.50. El piso no se viola. */
function redondearPrecio(valor, piso) {
  const v = Number(valor);
  const p = Number(piso);
  let r = floorToHalf(v);
  if (r + 1e-9 < p) r = ceilToHalf(v);
  if (r + 1e-9 < p) r = ceilToHalf(p);
  return Math.round(r * 100) / 100;
}

function fasePorDias(dias, config = CADUCIDAD_CONFIG) {
  const d = Number(dias);
  if (!Number.isFinite(d) || d <= 0) return null;
  const entries = Object.entries(config.fases).sort((a, b) => Number(a[0]) - Number(b[0]));
  for (const [k, fase] of entries) {
    if (d <= fase.max_dias && d > fase.min_dias) return Number(k);
  }
  return null;
}

function round1(n) {
  return Math.round(Number(n) * 10) / 10;
}

function money2(n) {
  return Math.round(Number(n) * 100) / 100;
}

function vigenciaHasta(fechaCaducidad, fase, config = CADUCIDAD_CONFIG) {
  const cad = ymdDe(fechaCaducidad);
  if (!cad) return null;
  const cadMinus1 = addDays(cad, -1);
  const next = config.fases[Number(fase) + 1];
  if (!next) return cadMinus1;
  const inicioSiguiente = addDays(cad, -next.max_dias);
  if (!inicioSiguiente) return cadMinus1;
  return inicioSiguiente < cadMinus1 ? inicioSiguiente : cadMinus1;
}

function textoEtiquetaPrecioEspecial({
  descripcion,
  pvp,
  precio_propuesto,
  descuento_efectivo,
  fecha_caducidad,
}) {
  const frac = Number(descuento_efectivo);
  const pct = frac <= 1 ? round1(frac * 100) : round1(frac);
  const cad = formatCaducidadMesAnio(fecha_caducidad) || String(fecha_caducidad || "").slice(0, 10);
  const antes = money2(pvp).toFixed(2);
  const ahora = money2(precio_propuesto).toFixed(2);
  return [
    "PRECIO ESPECIAL",
    String(descripcion || "").trim(),
    `Antes $${antes}  →  Ahora $${ahora}`,
    `Ahorra ${pct}%`,
    `Caduca: ${cad}`,
  ].join("\n");
}

function debeAdelantarFase(aplicada, config = CADUCIDAD_CONFIG) {
  if (!aplicada) return false;
  const dias = Number(aplicada.dias_aplicada);
  if (!Number.isFinite(dias) || dias < config.DIAS_EVALUACION) return false;
  const exist = Number(aplicada.existencia_al_aplicar);
  if (!(exist > 0)) return false;
  const vendidas = Number(aplicada.piezas_vendidas_desde_aplicacion) || 0;
  return vendidas / exist < config.UMBRAL_SELLTHROUGH;
}

function propuestaPendienteDuplicada(existentes, loteId, fechaJob) {
  const lid = String(loteId);
  const dia = String(fechaJob).slice(0, 10);
  return (existentes || []).some(
    (e) =>
      String(e.lote_id) === lid &&
      e.estado === "PENDIENTE" &&
      String(e.fecha_job).slice(0, 10) === dia
  );
}

function loteTienePendiente(existentes, loteId) {
  const lid = String(loteId);
  return (existentes || []).some((e) => String(e.lote_id) === lid && e.estado === "PENDIENTE");
}

function loteEnSilencio(rechazadas, loteId, fase, hoy, config = CADUCIDAD_CONFIG) {
  const lid = String(loteId);
  return (rechazadas || []).some((r) => {
    if (String(r.lote_id) !== lid) return false;
    if (Number(r.fase) !== Number(fase)) return false;
    const dias = diasEntre(hoy, r.rechazada_en || r.updated_at || r.created_at);
    return dias != null && dias >= 0 && dias < config.DIAS_SILENCIO;
  });
}

/**
 * @param {object} input
 * @returns {object} decisión
 */
function evaluarDescuentoCaducidad(input, config = CADUCIDAD_CONFIG) {
  const hoy = input?.hoy;
  if (!input?.fecha_caducidad) {
    return { estado: "SIN_CADUCIDAD", propuesta: false };
  }

  const dias = diasEntre(input.fecha_caducidad, hoy);
  if (dias == null) {
    return { estado: "SIN_CADUCIDAD", propuesta: false };
  }

  if (dias <= 0) {
    return { estado: "RETIRAR", dias_restantes: dias, propuesta: false, alerta: true };
  }

  const existencia = Number(input.existencia_lote);
  if (!Number.isFinite(existencia) || existencia <= 0) {
    return { estado: "SIN_STOCK", dias_restantes: dias, propuesta: false };
  }

  const costo = input.costo_unitario;
  if (costo == null || costo === "" || Number(costo) <= 0) {
    return {
      estado: "DATO_FALTANTE",
      dias_restantes: dias,
      propuesta: false,
      alerta: true,
    };
  }
  const costoN = Number(costo);
  const pvp = Number(input.pvp);
  if (!Number.isFinite(pvp) || pvp <= costoN) {
    return {
      estado: "DATO_SOSPECHOSO",
      dias_restantes: dias,
      propuesta: false,
      alerta: true,
    };
  }

  if (input.controlado) {
    return {
      estado: "REVISION_MANUAL",
      dias_restantes: dias,
      propuesta: false,
      motivo_exclusion: "CONTROLADO",
    };
  }
  if (input.refrigerado) {
    return {
      estado: "REVISION_MANUAL",
      dias_restantes: dias,
      propuesta: false,
      motivo_exclusion: "REFRIGERADO",
    };
  }

  const ventana = Number(input.canje_ventana_dias ?? config.canje_ventana_dias);
  if (input.canje_elegible === true && dias >= ventana) {
    return { estado: "CANJE", dias_restantes: dias, propuesta: false };
  }

  const rot = Number(input.rotacion_mensual) || 0;
  const mesesRestantes = dias / 30;
  const cobertura = rot <= 0 ? Number.POSITIVE_INFINITY : existencia / rot;
  const forzar = input.forzar_fase != null ? Number(input.forzar_fase) : null;

  if (!forzar && cobertura <= mesesRestantes * config.FACTOR_SEGURIDAD) {
    return {
      estado: "SIN_ACCION",
      dias_restantes: dias,
      cobertura_meses: cobertura,
      meses_restantes: mesesRestantes,
      propuesta: false,
    };
  }

  let fase = forzar;
  if (!fase) fase = fasePorDias(dias, config);
  if (!fase || !config.fases[fase]) {
    return {
      estado: "SIN_ACCION",
      dias_restantes: dias,
      cobertura_meses: cobertura,
      meses_restantes: mesesRestantes,
      propuesta: false,
    };
  }
  if (forzar && forzar > 5) fase = 5;

  const escalon = config.fases[fase];
  const precioCalculado = pvp * (1 - escalon.descuento);
  const precioPiso = costoN * (1 - escalon.perdida_maxima);
  let propuesto = Math.max(precioCalculado, precioPiso);
  const techos = [pvp];
  if (input.pmvp != null && Number(input.pmvp) > 0) techos.push(Number(input.pmvp));
  propuesto = Math.min(propuesto, ...techos);
  propuesto = redondearPrecio(propuesto, precioPiso);
  propuesto = Math.min(propuesto, ...techos);
  if (propuesto + 1e-9 < precioPiso) propuesto = redondearPrecio(precioPiso, precioPiso);

  const descuentoEfectivo = 1 - propuesto / pvp;
  const margen = propuesto > 0 ? (propuesto - costoN) / propuesto : 0;
  const perdidaPieza = money2(Math.max(0, costoN - propuesto));

  return {
    estado: "PROPONER",
    propuesta: true,
    fase,
    dias_restantes: dias,
    descuento_escalon: escalon.descuento,
    precio_calculado: money2(precioCalculado),
    precio_piso: money2(precioPiso),
    precio_propuesto: money2(propuesto),
    descuento_efectivo: descuentoEfectivo,
    descuento_efectivo_pct: round1(descuentoEfectivo * 100),
    margen_resultante: margen,
    perdida_pieza: perdidaPieza,
    capital_en_riesgo: money2(existencia * costoN),
    capital_recuperable: money2(existencia * propuesto),
    cobertura_meses: cobertura,
    meses_restantes: mesesRestantes,
    motivo: input.motivo || (forzar ? "SELLTHROUGH_INSUFICIENTE" : "CALENDARIO"),
    vigencia_hasta: vigenciaHasta(input.fecha_caducidad, fase, config),
  };
}

/**
 * A partir de lotes + rotación + filas ya guardadas, qué insertar hoy.
 * Puro: el job llama esto y luego escribe. Correrlo dos veces con las
 * mismas existentes no duplica.
 */
function planificarPropuestas({
  hoy,
  lotes,
  rotacionPorProducto,
  existentes,
  rechazadas,
  config = CADUCIDAD_CONFIG,
}) {
  const inserts = [];
  const alertas = [];
  const rotMap = rotacionPorProducto || {};
  const ya = existentes || [];
  const silencio = rechazadas || [];

  for (const lote of lotes || []) {
    const productoId = lote.producto_id;
    const rot = Number(rotMap[productoId] ?? rotMap[String(productoId)] ?? 0);
    const decision = evaluarDescuentoCaducidad(
      {
        hoy,
        fecha_caducidad: lote.fecha_caducidad,
        existencia_lote: lote.cantidad_actual ?? lote.existencia_lote,
        costo_unitario: lote.costo_unitario,
        pvp: lote.pvp ?? lote.precio,
        pmvp: lote.pmvp,
        rotacion_mensual: rot,
        canje_elegible: lote.canje_elegible === true,
        canje_ventana_dias: lote.canje_ventana_dias,
        controlado: lote.controlado === true,
        refrigerado: lote.refrigerado === true,
        forzar_fase: lote.forzar_fase,
        motivo: lote.motivo,
      },
      config
    );

    if (!decision.propuesta) {
      if (decision.alerta || decision.estado === "CANJE" || decision.estado === "REVISION_MANUAL") {
        alertas.push({ lote_id: lote.id, producto_id: productoId, ...decision });
      }
      continue;
    }

    if (loteTienePendiente(ya, lote.id)) continue;
    if (propuestaPendienteDuplicada(ya, lote.id, hoy)) continue;
    if (loteEnSilencio(silencio, lote.id, decision.fase, hoy, config)) continue;

    inserts.push({
      lote_id: lote.id,
      producto_id: productoId,
      fecha_job: String(hoy).slice(0, 10),
      ...decision,
    });
  }

  return { inserts, alertas };
}

module.exports = {
  parseFechaSolo,
  diasEntre,
  addDays,
  ymdDe,
  floorToHalf,
  ceilToHalf,
  redondearPrecio,
  fasePorDias,
  round1,
  money2,
  vigenciaHasta,
  textoEtiquetaPrecioEspecial,
  debeAdelantarFase,
  propuestaPendienteDuplicada,
  loteTienePendiente,
  loteEnSilencio,
  evaluarDescuentoCaducidad,
  planificarPropuestas,
};
