/**
 * Permisos por dominio (clinical | sales | billing | inventory).
 * Complementa la lista fina de `puedeVerModulo` en `utils/permissions.js`.
 *
 * inventory para vendedor = consulta de existencias, no costos ni compras.
 *
 * @param {{ rol?: string, role?: string }} user
 * @param {"clinical"|"sales"|"billing"|"inventory"} module
 */
export function canAccess(user, module) {
  const role = user?.role || user?.rol;

  const permissions = {
    admin: ["clinical", "sales", "billing", "inventory"],
    doctor: ["clinical"],
    doctora: ["clinical"],
    vendedor: ["sales", "inventory"],
  };

  return permissions[role]?.includes(module);
}
