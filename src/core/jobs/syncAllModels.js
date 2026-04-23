import { syncSalesModel } from "../readModels/syncSalesModel";

/**
 * Job legado para read models. En producción en browser no hace persistencia
 * (syncSalesModel retorna temprano). Para backfill, ejecutar server-side.
 */
export async function syncAllModels(opts) {
  try {
    await syncSalesModel(opts);
  } catch (e) {
    console.error("Sync error", e);
  }
}
