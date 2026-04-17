// ═══════════════════════════════════════════════════════════════
// ECOSISTEMA VENTURA — BASE DE DATOS LOCAL (IndexedDB)
// Almacena datos offline + cola de sincronización con Supabase
// ═══════════════════════════════════════════════════════════════

const DB_NAME    = "VenturaDB";
const DB_VERSION = 1;

// ── ESQUEMA DE LA BASE DE DATOS ───────────────────────────────
/*
  Stores (tablas locales):

  ventas           → Todas las ventas (sincronizadas y pendientes)
  ventas_pendientes→ Solo las que aún no se subieron a Supabase
  inventario       → Copia local del inventario con stock actual
  inventario_pend  → Cambios de stock sin sincronizar
  clientes         → Clientes registrados (por teléfono)
  clientes_pend    → Clientes/puntos nuevos sin sincronizar
  bitacora_cofepris→ Registros SICAD locales
  bitacora_pend    → Bitácora sin sincronizar
  config           → Configuración local (negocio activo, etc.)
*/

// ── INICIALIZACIÓN ────────────────────────────────────────────
export function abrirDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);

    request.onerror = () => {
      console.error("[DB] Error abriendo base de datos:", request.error);
      reject(request.error);
    };

    request.onsuccess = () => {
      console.log("[DB] Base de datos abierta correctamente");
      resolve(request.result);
    };

    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      console.log("[DB] Creando/actualizando esquema de base de datos...");

      const crearStore = (nombre, keyPath, indices = []) => {
        if (!db.objectStoreNames.contains(nombre)) {
          const store = db.createObjectStore(nombre, { keyPath });
          indices.forEach(([campo, unico]) => {
            store.createIndex(campo, campo, { unique: unico || false });
          });
          console.log("[DB] Store creado:", nombre);
          return store;
        }
        return event.target.transaction.objectStore(nombre);
      };

      // Ventas completadas
      crearStore("ventas", "id_local", [
        ["fecha", false],
        ["empleado", false],
        ["negocio", false],
        ["sincronizado", false],
      ]);

      // Cola de ventas pendientes de subir
      crearStore("ventas_pendientes", "id_local", [
        ["fecha", false],
        ["negocio", false],
      ]);

      // Inventario local
      crearStore("inventario", "sku", [
        ["negocio", false],
        ["cat", false],
        ["stock", false],
      ]);

      // Cambios de inventario pendientes
      crearStore("inventario_pendiente", "id_local", [
        ["sku", false],
        ["tipo_cambio", false], // "venta", "ajuste", "recepcion"
      ]);

      // Clientes registrados
      crearStore("clientes", "tel", [
        ["nombre", false],
        ["nivel", false],
      ]);

      // Clientes/puntos pendientes de sync
      crearStore("clientes_pendientes", "id_local", [
        ["tel", false],
      ]);

      // Bitácora COFEPRIS local
      crearStore("bitacora_cofepris", "id_local", [
        ["fecha", false],
        ["med", false],
        ["sincronizado", false],
      ]);

      // Bitácora COFEPRIS pendiente
      crearStore("bitacora_pendiente", "id_local", [
        ["fecha", false],
      ]);

      // Configuración
      crearStore("config", "clave");

      // Cortes de caja
      crearStore("cortes_caja", "id_local", [
        ["fecha", false],
        ["turno", false],
        ["empleado", false],
        ["sincronizado", false],
      ]);

      console.log("[DB] Esquema listo");
    };
  });
}

// ── VENTAS ────────────────────────────────────────────────────

// Guardar una venta (siempre local primero)
export async function guardarVenta(venta) {
  const db = await abrirDB();
  const ventaLocal = {
    ...venta,
    id_local: `venta_${Date.now()}_${Math.random().toString(36).slice(2)}`,
    fecha: new Date().toISOString(),
    sincronizado: false,
  };

  return new Promise((resolve, reject) => {
    const tx = db.transaction(["ventas", "ventas_pendientes"], "readwrite");

    // Guardar en ventas (historial completo)
    tx.objectStore("ventas").add(ventaLocal);

    // Agregar a cola de pendientes para sincronizar
    tx.objectStore("ventas_pendientes").add(ventaLocal);

    tx.oncomplete = () => {
      console.log("[DB] Venta guardada localmente:", ventaLocal.id_local);

      // Solicitar sync cuando haya internet
      if ("serviceWorker" in navigator && "SyncManager" in window) {
        navigator.serviceWorker.ready.then(sw => {
          sw.sync.register("sync-ventas");
        });
      }

      resolve(ventaLocal);
    };

    tx.onerror = () => reject(tx.error);
  });
}

// Obtener todas las ventas del día
export async function obtenerVentasHoy() {
  const db = await abrirDB();
  const hoy = new Date().toISOString().split("T")[0];

  return new Promise((resolve, reject) => {
    const tx = db.transaction("ventas", "readonly");
    const store = tx.objectStore("ventas");
    const indice = store.index("fecha");
    const rango = IDBKeyRange.bound(`${hoy}T00:00:00`, `${hoy}T23:59:59`);
    const request = indice.getAll(rango);

    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// Obtener ventas pendientes de sincronizar
export async function obtenerVentasPendientes() {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("ventas_pendientes", "readonly");
    const request = tx.objectStore("ventas_pendientes").getAll();
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// ── INVENTARIO ────────────────────────────────────────────────

// Guardar inventario completo (al cargar desde Supabase)
export async function guardarInventario(productos) {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("inventario", "readwrite");
    const store = tx.objectStore("inventario");

    // Limpiar y recargar
    store.clear();
    productos.forEach(p => store.add(p));

    tx.oncomplete = () => {
      console.log("[DB] Inventario guardado localmente:", productos.length, "productos");
      resolve(productos.length);
    };
    tx.onerror = () => reject(tx.error);
  });
}

// Obtener inventario local (funciona offline)
export async function obtenerInventario(negocio) {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("inventario", "readonly");
    const store = tx.objectStore("inventario");

    if (negocio) {
      const indice = store.index("negocio");
      const request = indice.getAll(IDBKeyRange.only(negocio));
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    } else {
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    }
  });
}

// Actualizar stock de un producto (local + cola sync)
export async function actualizarStock(sku, cantidadVendida, tipoCambio = "venta") {
  const db = await abrirDB();

  return new Promise((resolve, reject) => {
    const tx = db.transaction(["inventario", "inventario_pendiente"], "readwrite");

    const invStore = tx.objectStore("inventario");
    const pendStore = tx.objectStore("inventario_pendiente");

    // Obtener producto actual
    const getRequest = invStore.get(sku);

    getRequest.onsuccess = () => {
      const producto = getRequest.result;
      if (!producto) {
        reject(new Error(`Producto ${sku} no encontrado en inventario local`));
        return;
      }

      const stockAnterior = producto.stock;
      const nuevoStock = Math.max(0, stockAnterior - cantidadVendida);

      // Actualizar stock local
      producto.stock = nuevoStock;
      invStore.put(producto);

      // Agregar a cola de pendientes
      const cambio = {
        id_local: `inv_${Date.now()}_${sku}`,
        sku,
        stock_anterior: stockAnterior,
        nuevo_stock: nuevoStock,
        cantidad_cambio: cantidadVendida,
        tipo_cambio: tipoCambio,
        fecha: new Date().toISOString(),
      };
      pendStore.add(cambio);

      tx.oncomplete = () => {
        console.log(`[DB] Stock ${sku}: ${stockAnterior} → ${nuevoStock}`);

        // Solicitar sync
        if ("serviceWorker" in navigator && "SyncManager" in window) {
          navigator.serviceWorker.ready.then(sw => {
            sw.sync.register("sync-inventario");
          });
        }

        resolve({ sku, stockAnterior, nuevoStock });
      };
    };

    tx.onerror = () => reject(tx.error);
  });
}

// ── CLIENTES ──────────────────────────────────────────────────

// Buscar cliente por teléfono (offline)
export async function buscarCliente(tel) {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("clientes", "readonly");
    const request = tx.objectStore("clientes").get(tel);
    request.onsuccess = () => resolve(request.result || null);
    request.onerror = () => reject(request.error);
  });
}

// Guardar/actualizar cliente con puntos
export async function actualizarCliente(cliente) {
  const db = await abrirDB();

  return new Promise((resolve, reject) => {
    const tx = db.transaction(["clientes", "clientes_pendientes"], "readwrite");

    tx.objectStore("clientes").put(cliente);

    const pendiente = {
      ...cliente,
      id_local: `cli_${Date.now()}_${cliente.tel}`,
      fecha_cambio: new Date().toISOString(),
    };
    tx.objectStore("clientes_pendientes").add(pendiente);

    tx.oncomplete = () => {
      console.log("[DB] Cliente actualizado:", cliente.tel);

      if ("serviceWorker" in navigator && "SyncManager" in window) {
        navigator.serviceWorker.ready.then(sw => {
          sw.sync.register("sync-clientes");
        });
      }

      resolve(cliente);
    };

    tx.onerror = () => reject(tx.error);
  });
}

// Acumular puntos a un cliente
export async function acumularPuntos(tel, puntosNuevos) {
  const cliente = await buscarCliente(tel);
  if (!cliente) return null;

  const clienteActualizado = {
    ...cliente,
    puntos: cliente.puntos + puntosNuevos,
    ultima_compra: new Date().toISOString(),
  };

  // Recalcular nivel
  clienteActualizado.nivel = calcularNivel(clienteActualizado.puntos);

  return actualizarCliente(clienteActualizado);
}

// Canjear puntos
export async function canjearPuntos(tel, puntosACanjear) {
  const cliente = await buscarCliente(tel);
  if (!cliente) return null;
  if (cliente.puntos < puntosACanjear) throw new Error("Puntos insuficientes");

  const clienteActualizado = {
    ...cliente,
    puntos: cliente.puntos - puntosACanjear,
    ultima_actividad: new Date().toISOString(),
  };

  clienteActualizado.nivel = calcularNivel(clienteActualizado.puntos);
  return actualizarCliente(clienteActualizado);
}

function calcularNivel(puntos) {
  if (puntos >= 500) return "Gold";
  if (puntos >= 200) return "Silver";
  return "Bronze";
}

// ── BITÁCORA COFEPRIS ─────────────────────────────────────────

export async function guardarRegistroCOFEPRIS(registro) {
  const db = await abrirDB();
  const registroLocal = {
    ...registro,
    id_local: `cofepris_${Date.now()}_${Math.random().toString(36).slice(2)}`,
    fecha: new Date().toISOString(),
    sincronizado: false,
  };

  return new Promise((resolve, reject) => {
    const tx = db.transaction(["bitacora_cofepris", "bitacora_pendiente"], "readwrite");
    tx.objectStore("bitacora_cofepris").add(registroLocal);
    tx.objectStore("bitacora_pendiente").add(registroLocal);

    tx.oncomplete = () => {
      console.log("[DB] Registro COFEPRIS guardado:", registroLocal.id_local);
      resolve(registroLocal);
    };
    tx.onerror = () => reject(tx.error);
  });
}

export async function obtenerBitacoraHoy() {
  const db = await abrirDB();
  const hoy = new Date().toISOString().split("T")[0];

  return new Promise((resolve, reject) => {
    const tx = db.transaction("bitacora_cofepris", "readonly");
    const store = tx.objectStore("bitacora_cofepris");
    const indice = store.index("fecha");
    const rango = IDBKeyRange.bound(`${hoy}T00:00:00`, `${hoy}T23:59:59`);
    const request = indice.getAll(rango);

    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// ── CORTES DE CAJA ────────────────────────────────────────────

export async function guardarCorteCaja(corte) {
  const db = await abrirDB();
  const corteLocal = {
    ...corte,
    id_local: `corte_${Date.now()}`,
    fecha: new Date().toISOString(),
    sincronizado: false,
  };

  return new Promise((resolve, reject) => {
    const tx = db.transaction("cortes_caja", "readwrite");
    tx.objectStore("cortes_caja").add(corteLocal);
    tx.oncomplete = () => resolve(corteLocal);
    tx.onerror = () => reject(tx.error);
  });
}

export async function obtenerCortesDia() {
  const db = await abrirDB();
  const hoy = new Date().toISOString().split("T")[0];

  return new Promise((resolve, reject) => {
    const tx = db.transaction("cortes_caja", "readonly");
    const store = tx.objectStore("cortes_caja");
    const indice = store.index("fecha");
    const rango = IDBKeyRange.bound(`${hoy}T00:00:00`, `${hoy}T23:59:59`);
    const request = indice.getAll(rango);

    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// ── CONFIGURACIÓN ─────────────────────────────────────────────

export async function guardarConfig(clave, valor) {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("config", "readwrite");
    tx.objectStore("config").put({ clave, valor, updated: new Date().toISOString() });
    tx.oncomplete = () => resolve({ clave, valor });
    tx.onerror = () => reject(tx.error);
  });
}

export async function obtenerConfig(clave) {
  const db = await abrirDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("config", "readonly");
    const request = tx.objectStore("config").get(clave);
    request.onsuccess = () => resolve(request.result?.valor ?? null);
    request.onerror = () => reject(request.error);
  });
}

// ── ESTADÍSTICAS DE SYNC ──────────────────────────────────────

export async function obtenerEstadoSync() {
  const db = await abrirDB();

  const [ventasPend, invPend, clientesPend] = await Promise.all([
    contarRegistros(db, "ventas_pendientes"),
    contarRegistros(db, "inventario_pendiente"),
    contarRegistros(db, "clientes_pendientes"),
  ]);

  return {
    ventasPendientes: ventasPend,
    inventarioPendiente: invPend,
    clientesPendientes: clientesPend,
    total: ventasPend + invPend + clientesPend,
    hayPendientes: (ventasPend + invPend + clientesPend) > 0,
  };
}

function contarRegistros(db, storeName) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, "readonly");
    const request = tx.objectStore(storeName).count();
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// ── LIMPIAR DATOS ─────────────────────────────────────────────

// Eliminar todos los datos (para logout o reset)
export async function limpiarTodoLocal() {
  const db = await abrirDB();
  const stores = ["ventas", "ventas_pendientes", "inventario", "inventario_pendiente",
    "clientes", "clientes_pendientes", "bitacora_cofepris", "bitacora_pendiente",
    "cortes_caja", "config"];

  return new Promise((resolve, reject) => {
    const tx = db.transaction(stores, "readwrite");
    stores.forEach(s => tx.objectStore(s).clear());
    tx.oncomplete = () => {
      console.log("[DB] Base de datos local limpiada");
      resolve();
    };
    tx.onerror = () => reject(tx.error);
  });
}
