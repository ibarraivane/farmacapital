import { idEmpleadoUsuarios, parseUsuariosBigintId } from "./usuarioId";

// ═══════════════════════════════════════════════════════════
// FARMAX — Offline Sale Queue
// Guarda ventas en IndexedDB cuando no hay internet
// Sincroniza automáticamente al reconectarse
// ═══════════════════════════════════════════════════════════

const DB_NAME    = "FarmaxDB";
const DB_VERSION = 1;
const STORE_NAME = "ventas_pendientes";

// ── Abrir IndexedDB ───────────────────────────────────────
function abrirDB() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onerror   = () => reject(req.error);
    req.onsuccess = () => resolve(req.result);
    req.onupgradeneeded = e => {
      const db = e.target.result;
      if(!db.objectStoreNames.contains(STORE_NAME)) {
        const store = db.createObjectStore(STORE_NAME, { keyPath:"id_local" });
        store.createIndex("created_at", "created_at");
      }
    };
  });
}

// ── Guardar venta pendiente ───────────────────────────────
export async function guardarVentaPendiente(ventaData) {
  try {
    const db = await abrirDB();
    const id_local = `VTA_LOCAL_${Date.now()}_${Math.random().toString(36).slice(2)}`;
    const registro = {
      id_local,
      created_at: new Date().toISOString(),
      intentos:   0,
      estado:     "pendiente",
      datos:      ventaData,
    };
    await new Promise((res, rej) => {
      const tx  = db.transaction(STORE_NAME, "readwrite");
      const req = tx.objectStore(STORE_NAME).add(registro);
      req.onsuccess = () => res(id_local);
      req.onerror   = () => rej(req.error);
    });
    console.log("[Farmax Offline] Venta guardada localmente:", id_local);
    return id_local;
  } catch(e) {
    console.error("[Farmax Offline] Error guardando venta:", e);
    throw e;
  }
}

// ── Obtener ventas pendientes ─────────────────────────────
export async function obtenerVentasPendientes() {
  try {
    const db = await abrirDB();
    return new Promise((res, rej) => {
      const tx  = db.transaction(STORE_NAME, "readonly");
      const req = tx.objectStore(STORE_NAME).getAll();
      req.onsuccess = () => res(req.result || []);
      req.onerror   = () => rej(req.error);
    });
  } catch(e) {
    console.error("[Farmax Offline] Error leyendo pendientes:", e);
    return [];
  }
}

// ── Eliminar venta sincronizada ───────────────────────────
export async function eliminarVentaPendiente(id_local) {
  try {
    const db = await abrirDB();
    await new Promise((res, rej) => {
      const tx  = db.transaction(STORE_NAME, "readwrite");
      const req = tx.objectStore(STORE_NAME).delete(id_local);
      req.onsuccess = () => res();
      req.onerror   = () => rej(req.error);
    });
  } catch(e) {
    console.error("[Farmax Offline] Error eliminando:", e);
  }
}

// ── Contar ventas pendientes ──────────────────────────────
export async function contarVentasPendientes() {
  try {
    const db = await abrirDB();
    return new Promise((res, rej) => {
      const tx  = db.transaction(STORE_NAME, "readonly");
      const req = tx.objectStore(STORE_NAME).count();
      req.onsuccess = () => res(req.result || 0);
      req.onerror   = () => rej(req.error);
    });
  } catch(e) { return 0; }
}

// ── Sincronizar ventas pendientes con Supabase ────────────
export async function sincronizarVentasPendientes(supabase, usuario) {
  const pendientes = await obtenerVentasPendientes();
  if(!pendientes.length) return { ok:0, err:0 };
  let ok = 0, err = 0;
  for(const venta of pendientes) {
    try {
      const d = venta.datos;
      const cartItemsMapped = (d.items || []).map((i) => ({
        producto_id: i.producto_id ?? i.id,
        cantidad: i.cantidad ?? i.qty ?? 1,
        precio_unitario: i.precio_unitario ?? i.precio_venta ?? i.precio ?? 0,
        modo_venta: i.esUnidad ? "unidad" : "caja",
      }));

      if (!cartItemsMapped.length) {
        throw new Error("Venta offline sin items");
      }

      const pUserId = parseUsuariosBigintId(d.atendido_por) ?? (await idEmpleadoUsuarios(usuario));
      if (pUserId == null) {
        throw new Error("Usuario no vinculado: no hay id de empleado para sincronizar la venta offline");
      }

      const { data: rpcData, error: rpcError } = await supabase.rpc("create_sale_transaction_v2", {
        p_user_id: pUserId,
        p_metodo_pago: d.metodo_pago || "efectivo",
        p_total: d.total || 0,
        p_cart_items: cartItemsMapped,
        p_cliente_id: d.cliente_id || null,
        p_tipo: d.tipo === "online" ? "online" : "pos",
        p_tipo_entrega: d.tipo_entrega || null,
        p_direccion: d.direccion || null,
      });

      if (rpcError) throw rpcError;
      const rpcRow = Array.isArray(rpcData) ? rpcData[0] : rpcData;
      if (!rpcRow?.pedido_id || rpcRow?.success !== true) {
        throw new Error("RPC create_sale_transaction_v2 devolvió respuesta inválida");
      }

      await eliminarVentaPendiente(venta.id_local);
      ok++;
    } catch(e) {
      err++;
      try {
        const db = await abrirDB();
        const tx = db.transaction(STORE_NAME, "readwrite");
        const store = tx.objectStore(STORE_NAME);
        const getReq = store.get(venta.id_local);
        getReq.onsuccess = () => {
          const item = getReq.result;
          if(item) {
            item.intentos = (item.intentos || 0) + 1;
            item.ultimo_error = e.message;
            if(item.intentos >= 5) item.estado = "error";
            store.put(item);
          }
        };
      } catch(_) {}
    }
  }
  return { ok, err, total: pendientes.length };
}