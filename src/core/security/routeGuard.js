export function canAccessRoute(role, route) {
  const permissions = {
    doctora: ["/", "/patients", "/consultas", "/citas", "/expedientes", "/config"],
    vendedor: ["/", "/pos", "/ventas", "/cobros"],
    admin: "*",
  };

  const allowed = permissions[role];

  if (allowed === "*") return true;
  if (!Array.isArray(allowed)) return false;

  return allowed.includes(route);
}
