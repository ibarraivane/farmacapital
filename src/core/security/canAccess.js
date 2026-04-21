export function canAccess(role, module) {
  const rules = {
    admin: "*",
    doctora: ["clinical"],
    vendedor: ["sales", "billing", "pos"],
  };

  const allowed = rules[role];

  if (allowed === "*") return true;
  if (!Array.isArray(allowed)) return false;

  return allowed.includes(module);
}
