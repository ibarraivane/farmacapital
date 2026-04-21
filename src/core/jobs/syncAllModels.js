import { syncSalesModel } from "../readModels/syncSalesModel";

export async function syncAllModels() {
  try {
    await syncSalesModel();
  } catch (e) {
    console.error("Sync error", e);
  }
}
