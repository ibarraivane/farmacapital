/**
 * Disponibilidad al recetar (doctora) y al surtir (mostrador).
 * Verde = lo tenemos · ámbar = lo vendemos pero hay poco · rojo = lo vendemos sin piezas · gris = no está en catálogo.
 */
import { C_LIGHT } from "../constants";
import { stockBadgeLabel, detallePosologia } from "./recetaPrint";

const TONE_COL = {
  green: C_LIGHT.green,
  amber: C_LIGHT.amber,
  red: C_LIGHT.red,
  mid: C_LIGHT.textMid,
};

export function disponibilidadDeStock(stock) {
  const badge = stockBadgeLabel(stock);
  const n = Number(stock);
  if (!Number.isFinite(n)) {
    return {
      tone: "mid",
      col: TONE_COL.mid,
      label: "Sin dato de stock",
      short: "?",
      vendemos: true,
      hay: false,
    };
  }
  if (n <= 0) {
    return {
      tone: "red",
      col: TONE_COL.red,
      label: "Lo vendemos · sin piezas",
      short: "Sin stock",
      vendemos: true,
      hay: false,
    };
  }
  if (n <= 3) {
    return {
      tone: "amber",
      col: TONE_COL.amber,
      label: `Lo vendemos · bajo (${n})`,
      short: `Bajo (${n})`,
      vendemos: true,
      hay: true,
    };
  }
  return {
    tone: badge.tone,
    col: TONE_COL.green,
    label: `En mostrador · ${n}`,
    short: badge.label,
    vendemos: true,
    hay: true,
  };
}

export function disponibilidadLineaReceta(row, catalogById) {
  const pid = row?.producto_id;
  if (pid == null || pid === "") {
    return {
      tone: "mid",
      col: TONE_COL.mid,
      label: "No está en catálogo",
      short: "Libre",
      vendemos: false,
      hay: false,
    };
  }
  let live = null;
  if (catalogById && typeof catalogById.get === "function") {
    live = catalogById.get(Number(pid)) || catalogById.get(String(pid));
  } else if (catalogById && typeof catalogById === "object") {
    live = catalogById[pid] || catalogById[Number(pid)] || catalogById[String(pid)];
  }
  const stock = live?.stock ?? row.stock_snapshot ?? row.stock;
  return disponibilidadDeStock(stock);
}

export function lineasRecetaParaMostrador(medicamentos) {
  return (Array.isArray(medicamentos) ? medicamentos : [])
    .map((m, idx) => {
      const nombre = String(m.medicamento || m.nombre || "").trim();
      if (!nombre && m.producto_id == null) return null;
      return {
        key: `${m.producto_id || "libre"}-${idx}`,
        producto_id: m.producto_id != null ? Number(m.producto_id) : null,
        nombre: nombre || `Producto #${m.producto_id}`,
        cantidad: Math.max(1, Number(m.cantidad) || 1),
        posologia: detallePosologia(m),
        libre: m.producto_id == null,
        stock_snapshot: m.stock_snapshot != null ? Number(m.stock_snapshot) : null,
      };
    })
    .filter(Boolean);
}

/**
 * Plan para cargar la receta al carrito POS.
 * No muta estado: el POS aplica `lineas` y avisa `libres` / `sinPiezas`.
 */
export function planSurtirReceta({ medicamentos, productos = [], cart = [] } = {}) {
  const byId = new Map((productos || []).map((p) => [Number(p.id), p]));
  const qtyEnCarrito = new Map();
  for (const c of cart || []) {
    if (c.esUnidad) continue;
    const id = Number(c.producto_id ?? c.id);
    if (!Number.isFinite(id)) continue;
    qtyEnCarrito.set(id, (qtyEnCarrito.get(id) || 0) + (Number(c.qty) || 0));
  }

  const lineas = [];
  const libres = [];
  const sinPiezas = [];

  for (const m of Array.isArray(medicamentos) ? medicamentos : []) {
    const nombre = String(m.medicamento || m.nombre || "").trim();
    const qtyWanted = Math.max(1, Number(m.cantidad) || 1);
    const pid = m.producto_id != null ? Number(m.producto_id) : null;
    if (pid == null || !Number.isFinite(pid)) {
      if (nombre) libres.push(nombre);
      continue;
    }
    const prod = byId.get(pid);
    if (!prod) {
      libres.push(nombre || `#${pid}`);
      continue;
    }
    const stock = Number(prod.stock);
    const ya = qtyEnCarrito.get(pid) || 0;
    const disponible = Number.isFinite(stock) ? Math.max(0, stock - ya) : qtyWanted;
    const canAdd = Math.min(qtyWanted, disponible);
    if (canAdd <= 0) {
      sinPiezas.push(prod.nombre || nombre || `#${pid}`);
      continue;
    }
    lineas.push({ producto: prod, qty: canAdd, qtyPedida: qtyWanted });
    qtyEnCarrito.set(pid, ya + canAdd);
    if (canAdd < qtyWanted) {
      sinPiezas.push(`${prod.nombre || nombre} (solo ${canAdd} de ${qtyWanted})`);
    }
  }

  return { lineas, libres, sinPiezas };
}
