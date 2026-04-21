import { flows } from "../productFlow/flows";

export function getUserFlow(role) {
  return flows[role] || [];
}
