export function resolveRoute(_role, module) {
  const map = {
    clinical: "/consultorio",
    sales: "/ventas",
    billing: "/facturacion",
    inventory: "/inventario",
    pos: "/punto-venta",
    replay: "/auditoria",
  };

  return map[module];
}
