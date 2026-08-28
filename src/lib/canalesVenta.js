/**
 * Canales donde se vende el mismo precio de mostrador.
 * Rappi está vivo (sync de stock, no de precio). Uber y DiDi se enganchan
 * después sin cambiar el motor de referencias ni de alertas.
 */

export const CANALES_VENTA = {
  mostrador: {
    id: "mostrador",
    label: "Mostrador",
    activo: true,
    marketplace: false,
    syncPrecio: true,
    notaSync: null,
  },
  rappi: {
    id: "rappi",
    label: "Rappi",
    activo: true,
    marketplace: true,
    syncPrecio: false,
    notaSync: "El sync solo publica stock. El precio del catálogo Rappi se actualiza a mano.",
  },
  uber: {
    id: "uber",
    label: "Uber",
    activo: false,
    marketplace: true,
    syncPrecio: false,
    notaSync: "Aún no conectado. Cuando se active usará el mismo precio de mostrador y estas referencias.",
  },
  didi: {
    id: "didi",
    label: "DiDi",
    activo: false,
    marketplace: true,
    syncPrecio: false,
    notaSync: "Aún no conectado. Cuando se active usará el mismo precio de mostrador y estas referencias.",
  },
};

export const CANAL_IDS = Object.keys(CANALES_VENTA);

function eligibleMarketplace(producto) {
  if (!producto) return false;
  if (producto.activo === false) return false;
  if (producto.requiere_receta) return false;
  if (producto.controlado) return false;
  return true;
}

export function esElegibleCanal(canalId, producto) {
  const canal = CANALES_VENTA[canalId];
  if (!canal) return false;
  if (!canal.marketplace) return producto ? producto.activo !== false : false;
  return eligibleMarketplace(producto);
}

export function canalesDeProducto(producto) {
  return CANAL_IDS.filter((id) => esElegibleCanal(id, producto)).map((id) => CANALES_VENTA[id]);
}

export function canalesActivosDeProducto(producto) {
  return canalesDeProducto(producto).filter((c) => c.activo);
}

export function canalesFuturosDeProducto(producto) {
  return canalesDeProducto(producto).filter((c) => !c.activo && c.marketplace);
}

export function marketplacesActivosDeProducto(producto) {
  return canalesActivosDeProducto(producto).filter((c) => c.marketplace);
}

export function labelCanales(ids) {
  return (ids || []).map((id) => CANALES_VENTA[id]?.label || id);
}
