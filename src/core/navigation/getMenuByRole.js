import { menuConfig } from "./menuConfig";

export function getMenuByRole(role) {
  return menuConfig[role] || [];
}
