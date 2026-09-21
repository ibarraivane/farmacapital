import { categoriaCanon } from "../../../constants/categoriasProducto";
import { esBajoPedido } from "../../../lib/bajoPedido";

export const ESTADOS_DISPONIBILIDAD = Object.freeze({
  SUCURSAL: "sucursal",
  ENCARGO: "encargo",
  COTIZACION: "cotizacion",
  AGOTADO: "agotado",
});

export function stockEfectivoProducto(prod) {
  const n = Number(prod?.stock);
  return Number.isFinite(n) ? n : 0;
}

export function esEquipoMedicoSinCatalogo(prod) {
  return categoriaCanon(prod?.categoria) === "Dispositivo médico";
}

const LABELS = {
  sucursal: { corto: "En sucursal", largo: "En sucursal · recoge hoy" },
  encargo: { corto: "Por encargo", largo: "Por encargo · te confirmamos la fecha" },
  cotizacion: { corto: "Cotización", largo: "Cotización" },
  agotado: { corto: "Agotado", largo: "Agotado" },
};

const MARK = {
  sucursal: "on",
  encargo: "order",
  cotizacion: "quote",
  agotado: "",
};

const COLOR = {
  sucursal: "var(--jade-txt)",
  encargo: "var(--blue)",
  cotizacion: "var(--muted)",
  agotado: "var(--muted)",
};

/**
 * Un solo mapa de disponibilidad para tarjetas, ficha, carrito y categorías.
 * "En sucursal" solo con inventario confirmado y no bajo pedido.
 */
export function clasificarDisponibilidad(prod, opts = {}) {
  const { recolectaHoy = false, confirmarFecha = false, estado } = opts;
  let key = estado;

  if (!key) {
    if (prod == null) {
      key = ESTADOS_DISPONIBILIDAD.COTIZACION;
    } else if (esBajoPedido(prod)) {
      key = ESTADOS_DISPONIBILIDAD.ENCARGO;
    } else if (stockEfectivoProducto(prod) > 0) {
      key = ESTADOS_DISPONIBILIDAD.SUCURSAL;
    } else if (esEquipoMedicoSinCatalogo(prod)) {
      key = ESTADOS_DISPONIBILIDAD.COTIZACION;
    } else {
      key = ESTADOS_DISPONIBILIDAD.AGOTADO;
    }
  }

  const labels = LABELS[key] || LABELS.cotizacion;
  const largo = key === "sucursal" ? recolectaHoy : key === "encargo" ? confirmarFecha : false;
  return {
    estado: key,
    label: largo ? labels.largo : labels.corto,
    mark: MARK[key] || "",
    color: COLOR[key] || COLOR.cotizacion,
  };
}
