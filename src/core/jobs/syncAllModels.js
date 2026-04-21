import { syncSalesModel } from "../readModels/syncSalesModel";

export async function syncAllModels() {
  try {
    await syncSalesModel();
    console.log("Read models synced");
  } catch (e) {
    console.error("Sync error", e);
  }
}
