/**
 * Agrupa el resurtido en pocos pedidos: un viaje extra solo si el ahorro lo paga.
 *
 * Cada tercer día no quieres 6 archivos por 80 centavos. Si Scorpion gana $3
 * en una línea y ya vas a Exprezo, esa línea se queda en Exprezo.
 */

export const AHORRO_MIN_LINEA_MXN = 8;
export const AHORRO_MIN_LINEA_PCT = 0.04;
export const VIAJE_MIN_AHORRO_MXN = 80;
export const VIAJE_MIN_LINEAS = 5;

const FAMILIA = {
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

export const DESTINO_HABITUAL_ID = "_habitual";
export const DESTINO_HABITUAL_LABEL = "Pedido agrupado";

const slug = (s) =>
  String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/[^a-z0-9]+/g, "")
    .trim();

export function familiaDeFuente(fuenteId) {
  if (!fuenteId || fuenteId === "_tu_costo" || fuenteId === DESTINO_HABITUAL_ID) return "habitual";
  return FAMILIA[fuenteId] || "otro";
}

function lineaValeLaPena(ahorroMxn, costoUnit, qty) {
  if (!(ahorroMxn > 0)) return false;
  const base = (Number(costoUnit) || 0) * (Number(qty) || 1);
  const pct = base > 0 ? ahorroMxn / base : 0;
  return ahorroMxn >= AHORRO_MIN_LINEA_MXN || pct >= AHORRO_MIN_LINEA_PCT;
}

/**
 * @param {Array<{ producto: object, cantidad: number }>} items
 * @returns {Array<{
 *   id: string, label: string, familia: string, productos: object[],
 *   total: number, ahorroVsHabitual: number
 * }>}
 */
export function asignarPedidosPorTienda(items) {
  const lineas = (items || []).map(({ producto, cantidad }) => {
    const qty = Math.max(1, parseInt(cantidad, 10) || 1);
    const mejor = producto.mejorCompra;
    const costo = Number(producto.costo) || 0;
    const precioGanador = Number(mejor?.precio ?? costo) || 0;
    const ahorroLinea = mejor?.masBaratoQueTuCosto
      ? (costo - precioGanador) * qty
      : 0;
    const habitualLabel = (producto.proveedor || "").trim() || DESTINO_HABITUAL_LABEL;
    const habitualId = producto.proveedor ? `hab_${slug(producto.proveedor)}` : DESTINO_HABITUAL_ID;

    let destId = habitualId;
    let destLabel = habitualLabel;
    let destFuente = "_tu_costo";
    let agrupado = false;

    if (mejor && !mejor.esTuCosto && lineaValeLaPena(ahorroLinea, costo, qty)) {
      destId = mejor.fuente;
      destLabel = mejor.label;
      destFuente = mejor.fuente;
    } else if (mejor && !mejor.esTuCosto) {
      agrupado = true;
    }

    return {
      ...producto,
      cantidadPedida: qty,
      destId,
      destLabel,
      destFuente,
      familia: destFuente === "_tu_costo" ? "habitual" : familiaDeFuente(destFuente),
      precioUnit: precioGanador,
      ahorroLinea,
      agrupado,
      motivoAgrupado: agrupado
        ? `Ahorro ${ahorroLinea.toFixed(2)} vs tu costo: no vale un viaje aparte`
        : null,
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
    if (d.fuente === "_tu_costo" || String(d.id).startsWith("hab_")) return true;
    const ahorro = d.productos.reduce((a, p) => a + (p.ahorroLinea || 0), 0);
    return d.productos.length >= VIAJE_MIN_LINEAS || ahorro >= VIAJE_MIN_AHORRO_MXN;
  };

  const principales = destinos.filter(valeViaje);
  const chicos = destinos.filter((d) => !valeViaje(d));

  const absorber = (chico) => {
    const mismaFam = principales.filter((p) => p.familia === chico.familia);
    let host;
    if (mismaFam.length) {
      mismaFam.sort((a, b) => b.productos.length - a.productos.length);
      host = mismaFam[0];
    } else {
      // No mezclar medicamentos con abarrotes: el viaje chico se va al pedido agrupado.
      host = principales.find((p) => p.familia === "habitual");
      if (!host) {
        host = {
          id: DESTINO_HABITUAL_ID,
          label: DESTINO_HABITUAL_LABEL,
          fuente: "_tu_costo",
          familia: "habitual",
          productos: [],
        };
        principales.push(host);
      }
    }
    for (const p of chico.productos) {
      host.productos.push({
        ...p,
        agrupado: true,
        destIdOriginal: chico.id,
        destLabelOriginal: chico.label,
        motivoAgrupado: `Ahorro del grupo ${chico.label} no paga el viaje → va en ${host.label}`,
      });
    }
  };
  chicos.forEach(absorber);

  return principales
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
    .sort((a, b) => b.total - a.total);
}
