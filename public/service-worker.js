// ═══════════════════════════════════════════════════════════════
// FARMAX — SERVICE WORKER
// Caché offline · Cola de sincronización · Push notifications
// ═══════════════════════════════════════════════════════════════

const VERSION       = "farmax-v1.0.0";
const CACHE_STATIC  = `${VERSION}-static`;
const CACHE_DYNAMIC = `${VERSION}-dynamic`;

const STATIC_ASSETS = [
  "/", "/index.html", "/farmax-manifest.json",
  "/static/js/main.chunk.js", "/static/js/bundle.js", "/static/css/main.chunk.css",
  "https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap",
];

const NO_CACHE = [
  "api.anthropic.com", "supabase.co",
  "conekta.com", "mercadopago.com", "skydropx.com",
];

self.addEventListener("install", event => {
  console.log("[Farmax SW] Instalando versión:", VERSION);
  event.waitUntil(
    caches.open(CACHE_STATIC).then(cache =>
      Promise.allSettled(STATIC_ASSETS.map(url =>
        cache.add(url).catch(e => console.warn("[Farmax SW] No cacheado:", url))
      ))
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", event => {
  console.log("[Farmax SW] Activando...");
  event.waitUntil(
    caches.keys().then(names => Promise.all(
      names.filter(n => n.startsWith("farmax-") && n !== CACHE_STATIC && n !== CACHE_DYNAMIC)
        .map(n => { console.log("[Farmax SW] Eliminando caché antigua:", n); return caches.delete(n); })
    )).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  const url = new URL(event.request.url);
  if (NO_CACHE.some(d => url.hostname.includes(d))) {
    event.respondWith(fetch(event.request).catch(() =>
      new Response(JSON.stringify({ error: "Sin conexión", offline: true }), { headers: { "Content-Type": "application/json" } })
    ));
    return;
  }
  if (isStaticAsset(event.request)) {
    event.respondWith(cacheFirst(event.request));
    return;
  }
  event.respondWith(networkFirst(event.request));
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  try {
    const response = await fetch(request);
    if (response.ok) (await caches.open(CACHE_STATIC)).put(request, response.clone());
    return response;
  } catch { return offlineFallback(request); }
}

async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) (await caches.open(CACHE_DYNAMIC)).put(request, response.clone());
    return response;
  } catch {
    const cached = await caches.match(request);
    return cached || offlineFallback(request);
  }
}

function offlineFallback(request) {
  if (request.headers.get("Accept")?.includes("text/html")) {
    return caches.match("/") || new Response(`<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Farmax — Sin conexión</title>
      <style>body{font-family:sans-serif;background:#07111a;color:#e4eef8;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;text-align:center;padding:20px;}.card{background:#0c1824;border-radius:16px;padding:40px;max-width:400px;}h1{color:#0099e6;margin-bottom:12px;}p{color:#6a8eaa;line-height:1.6;margin-bottom:20px;}.capsule{width:24px;height:40px;border-radius:12px;overflow:hidden;display:flex;flex-direction:column;margin:0 auto 16px;}.ct{flex:1;background:#0099e6;}.cb{flex:1;background:rgba(0,153,230,0.4);}</style>
      </head><body><div class="card"><div class="capsule"><div class="ct"></div><div class="cb"></div></div><h1>Farmax</h1><p>Sin conexión — El POS y el inventario siguen funcionando. Las ventas se sincronizan al reconectarse.</p><span style="background:#00c46a20;color:#00c46a;border:1px solid #00c46a40;border-radius:20px;padding:6px 16px;font-size:13px;font-weight:700;">✓ Modo offline activo</span></div></body></html>`,
      { headers: { "Content-Type": "text/html" } });
  }
  return new Response(JSON.stringify({ error: "Sin conexión", offline: true }), { headers: { "Content-Type": "application/json" } });
}

self.addEventListener("sync", event => {
  console.log("[Farmax SW] Background sync:", event.tag);
  if (event.tag === "sync-ventas")     event.waitUntil(sincronizarEntidad("ventas_pendientes",    "ventas",     "sync-ventas"));
  if (event.tag === "sync-inventario") event.waitUntil(sincronizarEntidad("inventario_pendiente", "inventario", "sync-inventario"));
  if (event.tag === "sync-clientes")   event.waitUntil(sincronizarEntidad("clientes_pendientes",  "clientes",   "sync-clientes"));
});

async function sincronizarEntidad(storeName, endpoint, tag) {
  try {
    const db = await abrirDB();
    const pendientes = await obtenerPendientes(db, storeName);
    if (!pendientes.length) return;
    console.log(`[Farmax SW] Sincronizando ${pendientes.length} registros de ${storeName}...`);
    for (const item of pendientes) {
      try {
        const res = await fetch(`${self.SUPABASE_URL}/rest/v1/${endpoint}`, {
          method: "POST",
          headers: { "Content-Type": "application/json", "apikey": self.SUPABASE_ANON_KEY, "Authorization": `Bearer ${self.SUPABASE_ANON_KEY}`, "Prefer": "return=minimal" },
          body: JSON.stringify(item),
        });
        if (res.ok) await eliminarPendiente(db, storeName, item.id_local);
      } catch (e) { console.warn("[Farmax SW] Error sync:", e); }
    }
    const clients = await self.clients.matchAll();
    clients.forEach(c => c.postMessage({ type: "SYNC_COMPLETE", entity: endpoint, count: pendientes.length }));
  } catch (err) { console.error("[Farmax SW] Error sync:", err); throw err; }
}

self.addEventListener("message", event => {
  if(event.data?.type==="SHOW_NOTIFICATION"){
    const { titulo, cuerpo, url } = event.data;
    self.registration.showNotification(titulo||"Farmax",{
      body: cuerpo||"",
      icon: "/icons/farmax-192.png",
      badge: "/icons/farmax-72.png",
      data: { url: url||"/" },
      vibrate: [100,50,100],
    });
  }
});

self.addEventListener("push", event => {
  if (!event.data) return;
  const data = event.data.json();
  event.waitUntil(self.registration.showNotification(data.title || "Farmax", {
    body: data.body || "Notificación de Farmax Farmacia",
    icon: "/icons/farmax-192.png",
    badge: "/icons/farmax-72.png",
    tag: data.tag || "farmax-notification",
    data: { url: data.url || "/" },
    vibrate: [100, 50, 100],
  }));
});

self.addEventListener("notificationclick", event => {
  event.notification.close();
  const url = event.notification.data?.url || "/";
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(list => {
      const existing = list.find(c => c.url === url && "focus" in c);
      return existing ? existing.focus() : clients.openWindow(url);
    })
  );
});

function abrirDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open("FarmaxDB", 1);
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    request.onupgradeneeded = e => {
      const db = e.target.result;
      ["ventas_pendientes","inventario_pendiente","clientes_pendientes","bitacora_pendiente"].forEach(store => {
        if (!db.objectStoreNames.contains(store)) db.createObjectStore(store, { keyPath: "id_local" });
      });
    };
  });
}

function obtenerPendientes(db, storeName) {
  return new Promise((resolve, reject) => {
    const req = db.transaction(storeName, "readonly").objectStore(storeName).getAll();
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

function eliminarPendiente(db, storeName, id) {
  return new Promise((resolve, reject) => {
    const req = db.transaction(storeName, "readwrite").objectStore(storeName).delete(id);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

function isStaticAsset(request) {
  const url = request.url;
  return ["/static/",".js",".css",".png",".jpg",".svg",".ico",".woff",".woff2","fonts.googleapis","fonts.gstatic"].some(s => url.includes(s));
}

console.log("[Farmax SW] Cargado:", VERSION);
