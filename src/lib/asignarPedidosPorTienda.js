/**
 * Agrupa el resurtido en pedidos por tienda real.
 *
 * El destino es dónde pides (Levic, Exprezo, Scorpion…), no «tu último costo».
 * Medicamento cae en Levic y abarrotes en Exprezo, salvo que otra tienda de la
 * misma familia ahorre lo suficiente para pagar el viaje extra.
 */

import { FUENTE_META } from "./preciosReferencia";

export const AHORRO_MIN_LINEA_MXN = 8;
export const AHORRO_MIN_LINEA_PCT = 0.04;
export const VIAJE_MIN_AHORRO_MXN = 80;
export const VIAJE_MIN_LINEAS = 5;

export const SIN_TIENDA_ID = "_sin_tienda";
export const SIN_TIENDA_LABEL = "Sin coincidencia de tienda";

export const FAMILIA = {
  levic: "farma",
  nadro: "farma",
  marzam: "farma",
  fanasa: "farma",
  saba: "farma",
  exprezo: "abarrotes",
  scorpion: "abarrotes",
  abarrotero: "abarrotes",
  mayoreototal: "abarrotes",
  otros_compra: "abarrotes",
};

/** Tienda habitual de cada familia: portal Levic (llega mañana) y Exprezo. */
export const HUB_FAMILIA = {
  farma: "levic",
  abarrotes: "exprezo",
};

export function familiaDeFuente(fuenteId) {
  if (!fuenteId || fuenteId === SIN_TIENDA_ID) return "otro";
  return FAMILIA[fuenteId] || "otro";
}

export function lineaValeLaPena(ahorroMxn, costoUnit, qty) {
  if (!(ahorroMxn > 0)) return false;
  const base = (Number(costoUnit) || 0) * (Number(qty) || 1);
  const pct = base > 0 ? ahorroMxn / base : 0;
  return ahorroMxn >= AHORRO_MIN_LINEA_MXN || pct >= AHORRO_MIN_LINEA_PCT;
}

function labelDe(fuenteId) {
  if (fuenteId === SIN_TIENDA_ID) return SIN_TIENDA_LABEL;
  return FUENTE_META[fuenteId]?.label || fuenteId;
}

export function tiendasDeProducto(producto) {
  const fromMejor = producto?.mejorTienda?.opciones;
  if (Array.isArray(fromMejor) && fromMejor.length) {
    return fromMejor.filter((t) => t?.fuente && Number(t.precio) > 0);
  }
  if (producto?.mejorTienda?.fuente && Number(producto.mejorTienda.precio) > 0) {
    return [producto.mejorTienda];
  }
  return [];
}

/**
 * Elige tienda para una línea. Nunca usa «tu costo» como destino.
 */
export function elegirDestinoLinea(producto, cantidad) {
  const qty = Math.max(1, parseInt(cantidad, 10) || 1);
  const tiendas = tiendasDeProducto(producto).slice().sort((a, b) => a.precio - b.precio);

  if (!tiendas.length) {
    return {
      destId: SIN_TIENDA_ID,
      destLabel: SIN_TIENDA_LABEL,
      destFuente: SIN_TIENDA_ID,
      familia: "otro",
      precioUnit: Number(producto?.costo) || 0,
      ahorroLinea: 0,
      motivoAgrupado: "No hay precio de Levic, Exprezo, Scorpion u otra tienda de compra",
    };
  }

  const cheapest = tiendas[0];
  const familia = familiaDeFuente(cheapest.fuente);
  const hubId = HUB_FAMILIA[familia];
  const hub = hubId ? tiendas.find((t) => t.fuente === hubId) : null;

  let elegido = cheapest;
  let motivoAgrupado = null;
  let ahorroLinea = 0;

  if (hub && cheapest.fuente !== hub.fuente) {
    ahorroLinea = (hub.precio - cheapest.precio) * qty;
    if (!lineaValeLaPena(ahorroLinea, hub.precio, qty)) {
      elegido = hub;
      motivoAgrupado = `Ahorro $${ahorroLinea.toFixed(2)} vs ${hub.label}: no vale ir a ${cheapest.label}`;
      ahorroLinea = 0;
    }
  }

  return {
    destId: elegido.fuente,
    destLabel: labelDe(elegido.fuente),
    destFuente: elegido.fuente,
    familia: familiaDeFuente(elegido.fuente),
    precioUnit: elegido.precio,
    ahorroLinea,
    motivoAgrupado,
  };
}

function esHub(fuente) {
  return Object.values(HUB_FAMILIA).includes(fuente);
}

/**
 * @param {Array<{ producto: object, cantidad: number }>} items
 */
export function asignarPedidosPorTienda(items) {
  const lineas = (items || []).map(({ producto, cantidad }) => {
    const qty = Math.max(1, parseInt(cantidad, 10) || 1);
    const dest = elegirDestinoLinea(producto, qty);
    return {
      ...producto,
      cantidadPedida: qty,
      ...dest,
      proveedor: dest.destLabel,
    };
  });

  const porDestino = new Map();
  for (const linea of lineas) {
    if (!porDestino.has(linea.destId)) {
      porDestino.set(linea.destId, {
        id: linea.destId,
        label: linea.destLabel,
        fuente: linea.destFuente,
        familia: linea.familia,
        productos: [],
      });
    }
    porDestino.get(linea.destId).productos.push(linea);
  }

  const destinos = [...porDestino.values()];

  const valeViaje = (d) => {
    if (esHub(d.fuente) || d.fuente === SIN_TIENDA_ID) return true;
    const ahorro = d.productos.reduce((a, p) => a + (p.ahorroLinea || 0), 0);
    return d.productos.length >= VIAJE_MIN_LINEAS || ahorro >= VIAJE_MIN_AHORRO_MXN;
  };

  const absorber = (chico) => {
    const hubId = HUB_FAMILIA[chico.familia];
    let host = destinos.find((d) => d.fuente === hubId);
    const movibles = [];
    const seQuedan = [];
    for (const p of chico.productos) {
      const hubPrecio = tiendasDeProducto(p).find((t) => t.fuente === hubId);
      if (host && hubPrecio) {
        movibles.push({
          ...p,
          destId: host.id,
          destLabel: host.label,
          destFuente: host.fuente,
          familia: host.familia,
          precioUnit: hubPrecio.precio,
          proveedor: host.label,
          agrupado: true,
          destIdOriginal: chico.id,
          destLabelOriginal: chico.label,
          motivoAgrupado: `El grupo ${chico.label} no paga el viaje → va en ${host.label}`,
        });
      } else {
        seQuedan.push(p);
      }
    }
    if (host) {
      host.productos.push(...movibles);
    }
    chico.productos = seQuedan;
  };

  destinos.filter((d) => !valeViaje(d)).forEach(absorber);

  return destinos
    .filter((d) => d.productos.length)
    .map((d) => {
      const total = d.productos.reduce((a, p) => a + (p.precioUnit || 0) * p.cantidadPedida, 0);
      const ahorroVsHabitual = d.productos.reduce((a, p) => a + (p.ahorroLinea || 0), 0);
      return {
        proveedor: d.label,
        proveedorId: d.id,
        fuente: d.fuente,
        familia: d.familia,
        productos: d.productos,
        total,
        ahorroVsHabitual,
        fecha: new Date().toLocaleDateString("es-MX"),
      };
    })
    .sort((a, b) => {
      if (a.fuente === SIN_TIENDA_ID) return 1;
      if (b.fuente === SIN_TIENDA_ID) return -1;
      return b.productos.length - a.productos.length;
    });
}
