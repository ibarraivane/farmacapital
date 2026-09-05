/**
 * Catálogo canónico de `gastos.categoria`.
 * El select de captura y los RPCs tienen que usar las mismas claves.
 * `compra_inventario` sale en Flujo y NUNCA en P&L (el servidor fuerza afecta_pl = false).
 */

export const CATEGORIAS_GASTO = Object.freeze([
  "renta",
  "nomina",
  "servicios",
  "comisiones",
  "mermas",
  "mantenimiento",
  "publicidad",
  "insumos",
  "seguros",
  "licencias",
  "impuestos",
  "financieros",
  "ajuste_redondeo",
  "compra_inventario",
  "otros",
]);

export const GASTO_FIJO = Object.freeze([
  "renta",
  "nomina",
  "servicios",
  "seguros",
  "licencias",
  "mantenimiento",
]);

export const GASTO_VARIABLE = Object.freeze([
  "comisiones",
  "mermas",
  "insumos",
  "publicidad",
  "ajuste_redondeo",
]);

export const CATEGORIA_GASTO_LABELS = Object.freeze({
  renta: "Renta",
  nomina: "Nómina",
  servicios: "Servicios (luz, agua, internet)",
  comisiones: "Comisiones",
  mermas: "Mermas",
  mantenimiento: "Mantenimiento",
  publicidad: "Publicidad",
  insumos: "Insumos",
  seguros: "Seguros",
  licencias: "Licencias",
  impuestos: "Impuestos",
  financieros: "Financieros",
  ajuste_redondeo: "Ajuste por redondeo",
  compra_inventario: "Compra de medicamento",
  otros: "Otros",
});

export const CATEGORIA_COMPRA_INVENTARIO = "compra_inventario";

export function esCompraInventario(categoria) {
  return String(categoria || "") === CATEGORIA_COMPRA_INVENTARIO;
}

/** Vista previa en cliente. El servidor vuelve a forzar esto. */
export function gastoAfectaPl(categoria, afectaPl) {
  if (esCompraInventario(categoria)) return false;
  return afectaPl !== false;
}

export function etiquetaCategoriaGasto(categoria) {
  const k = String(categoria || "");
  return CATEGORIA_GASTO_LABELS[k] || k || "—";
}

export function opcionesCategoriaGasto() {
  return CATEGORIAS_GASTO.map((id) => ({
    id,
    label: CATEGORIA_GASTO_LABELS[id] || id,
  }));
}
