import { useState, useEffect, useCallback } from "react";
import { obtenerEstadoSync } from "./db.js";

// ═══════════════════════════════════════════════════════════════
// ECOSISTEMA VENTURA — PWA HOOKS & COMPONENTES
// Hook usePWA + indicador offline + banner instalación
// ═══════════════════════════════════════════════════════════════

// ── HOOK PRINCIPAL usePWA ─────────────────────────────────────
export function usePWA() {
  const [online, setOnline]         = useState(navigator.onLine);
  const [swActivo, setSwActivo]     = useState(false);
  const [syncPendiente, setSyncPend] = useState(0);
  const [instalable, setInstalable] = useState(false);
  const [installPrompt, setPrompt]  = useState(null);
  const [instalada, setInstalada]   = useState(false);
  const [ultimaSync, setUltimaSync] = useState(null);

  // ── Registrar Service Worker ──────────────────────────────
  useEffect(() => {
    if (!("serviceWorker" in navigator)) {
      console.warn("[PWA] Service Worker no soportado en este navegador");
      return;
    }

    // Registrar SW
    navigator.serviceWorker
      .register("/service-worker.js", { scope: "/" })
      .then(registration => {
        console.log("[PWA] Service Worker registrado:", registration.scope);
        setSwActivo(true);

        // Detectar actualizaciones
        registration.addEventListener("updatefound", () => {
          const newWorker = registration.installing;
          newWorker.addEventListener("statechange", () => {
            if (newWorker.state === "installed" && navigator.serviceWorker.controller) {
              console.log("[PWA] Nueva versión disponible");
              // Podrías mostrar un banner de "actualizar"
            }
          });
        });
      })
      .catch(err => console.error("[PWA] Error registrando SW:", err));

    // Escuchar mensajes del SW (sync completada, etc.)
    navigator.serviceWorker.addEventListener("message", event => {
      const { type, entity, count } = event.data;
      if (type === "SYNC_COMPLETE") {
        console.log(`[PWA] Sync completada: ${count} ${entity}`);
        setUltimaSync(new Date());
        actualizarContadorSync();
      }
    });
  }, []);

  // ── Detectar estado de red ────────────────────────────────
  useEffect(() => {
    const goOnline = () => {
      console.log("[PWA] Conexión restaurada — iniciando sync...");
      setOnline(true);

      // Disparar sincronización cuando regresa internet
      if ("serviceWorker" in navigator && "SyncManager" in window) {
        navigator.serviceWorker.ready.then(sw => {
          sw.sync.register("sync-ventas");
          sw.sync.register("sync-inventario");
          sw.sync.register("sync-clientes");
        });
      }
    };

    const goOffline = () => {
      console.log("[PWA] Conexión perdida — modo offline activo");
      setOnline(false);
    };

    window.addEventListener("online", goOnline);
    window.addEventListener("offline", goOffline);

    return () => {
      window.removeEventListener("online", goOnline);
      window.removeEventListener("offline", goOffline);
    };
  }, []);

  // ── Detectar prompt de instalación ───────────────────────
  useEffect(() => {
    const handleInstall = (e) => {
      e.preventDefault();
      console.log("[PWA] App instalable detectada");
      setPrompt(e);
      setInstalable(true);
    };

    window.addEventListener("beforeinstallprompt", handleInstall);

    // Detectar si ya está instalada
    if (window.matchMedia("(display-mode: standalone)").matches) {
      setInstalada(true);
    }

    return () => window.removeEventListener("beforeinstallprompt", handleInstall);
  }, []);

  // ── Monitorear pendientes de sync ─────────────────────────
  const actualizarContadorSync = useCallback(async () => {
    try {
      const estado = await obtenerEstadoSync();
      setSyncPend(estado.total);
    } catch (e) {
      // DB puede no estar disponible aún
    }
  }, []);

  useEffect(() => {
    actualizarContadorSync();
    const intervalo = setInterval(actualizarContadorSync, 30000); // cada 30 seg
    return () => clearInterval(intervalo);
  }, [actualizarContadorSync]);

  // ── Función instalar app ──────────────────────────────────
  const instalarApp = useCallback(async () => {
    if (!installPrompt) return;
    installPrompt.prompt();
    const { outcome } = await installPrompt.userChoice;
    if (outcome === "accepted") {
      setInstalada(true);
      setInstalable(false);
      setPrompt(null);
      console.log("[PWA] App instalada correctamente");
    }
  }, [installPrompt]);

  return {
    online,           // true/false — hay internet
    swActivo,         // true/false — service worker activo
    syncPendiente,    // número de registros sin sincronizar
    instalable,       // se puede instalar como app
    instalada,        // ya está instalada como app
    instalarApp,      // función para disparar instalación
    ultimaSync,       // Date de la última sync exitosa
    actualizarSync: actualizarContadorSync,
  };
}

// ── COMPONENTE: BARRA DE ESTADO OFFLINE ──────────────────────
export function BarraEstadoOffline({ online, syncPendiente, ultimaSync }) {
  if (online && syncPendiente === 0) return null; // Todo bien, no mostrar nada

  return (
    <div style={{
      position: "fixed",
      bottom: 16,
      left: "50%",
      transform: "translateX(-50%)",
      zIndex: 1000,
      display: "flex",
      flexDirection: "column",
      gap: 8,
      alignItems: "center",
      pointerEvents: "none",
    }}>
      {/* Sin internet */}
      {!online && (
        <div style={{
          background: "#ff3d5a",
          color: "#fff",
          borderRadius: 24,
          padding: "8px 20px",
          fontSize: 13,
          fontWeight: 700,
          fontFamily: "'Plus Jakarta Sans',sans-serif",
          display: "flex",
          alignItems: "center",
          gap: 8,
          boxShadow: "0 4px 20px rgba(255,61,90,.4)",
          pointerEvents: "auto",
        }}>
          <span style={{ fontSize: 16 }}>📡</span>
          Sin conexión — Modo offline activo
        </div>
      )}

      {/* Pendientes de sync */}
      {syncPendiente > 0 && (
        <div style={{
          background: online ? "#ffaa00" : "#334155",
          color: online ? "#fff" : "#94a3b8",
          borderRadius: 24,
          padding: "6px 16px",
          fontSize: 12,
          fontWeight: 700,
          fontFamily: "'Plus Jakarta Sans',sans-serif",
          display: "flex",
          alignItems: "center",
          gap: 6,
          boxShadow: online ? "0 4px 16px rgba(255,170,0,.3)" : "none",
          pointerEvents: "auto",
        }}>
          <span>{online ? "⏳" : "💾"}</span>
          {syncPendiente} registro{syncPendiente !== 1 ? "s" : ""} {online ? "sincronizando..." : "guardados local"}
        </div>
      )}

      {/* Sync completada */}
      {online && syncPendiente === 0 && ultimaSync && (
        <div style={{
          background: "#00d068",
          color: "#fff",
          borderRadius: 24,
          padding: "6px 16px",
          fontSize: 12,
          fontWeight: 700,
          fontFamily: "'Plus Jakarta Sans',sans-serif",
          display: "flex",
          alignItems: "center",
          gap: 6,
          animation: "fadeOut 3s forwards",
          pointerEvents: "auto",
        }}>
          ✅ Sincronizado con la nube
        </div>
      )}
    </div>
  );
}

// ── COMPONENTE: BANNER DE INSTALACIÓN ────────────────────────
export function BannerInstalacion({ instalable, instalada, instalarApp }) {
  const [visible, setVisible] = useState(true);

  if (!instalable || instalada || !visible) return null;

  return (
    <div style={{
      position: "fixed",
      bottom: 80,
      left: "50%",
      transform: "translateX(-50%)",
      zIndex: 999,
      background: "#0c1824",
      border: "1px solid #1f3347",
      borderRadius: 16,
      padding: "16px 20px",
      display: "flex",
      alignItems: "center",
      gap: 14,
      boxShadow: "0 8px 32px rgba(0,0,0,.4)",
      maxWidth: 420,
      width: "calc(100% - 48px)",
      fontFamily: "'Plus Jakarta Sans',sans-serif",
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: 10,
        background: "linear-gradient(135deg,#0099ff,#00d068)",
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 22, flexShrink: 0,
      }}>✚</div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ color: "#e4eef8", fontWeight: 700, fontSize: 14 }}>
          Instalar Ecosistema Ventura
        </div>
        <div style={{ color: "#6a8eaa", fontSize: 12, marginTop: 2 }}>
          Funciona sin internet · Acceso rápido desde escritorio
        </div>
      </div>

      <div style={{ display: "flex", gap: 8, flexShrink: 0 }}>
        <button onClick={() => setVisible(false)} style={{
          background: "none", border: "1px solid #2d4560",
          borderRadius: 8, color: "#6a8eaa", cursor: "pointer",
          padding: "6px 10px", fontSize: 12, fontWeight: 700,
        }}>No, gracias</button>
        <button onClick={instalarApp} style={{
          background: "#0099ff", border: "none",
          borderRadius: 8, color: "#fff", cursor: "pointer",
          padding: "6px 14px", fontSize: 12, fontWeight: 700,
        }}>Instalar</button>
      </div>
    </div>
  );
}

// ── COMPONENTE: INDICADOR MINI DE ESTADO ─────────────────────
export function IndicadorRed({ online, syncPendiente }) {
  return (
    <div style={{
      display: "flex",
      alignItems: "center",
      gap: 6,
      padding: "4px 10px",
      borderRadius: 20,
      background: online ? "#00d06818" : "#ff3d5a18",
      border: `1px solid ${online ? "#00d06840" : "#ff3d5a40"}`,
      fontSize: 11,
      fontWeight: 700,
      color: online ? "#00d068" : "#ff3d5a",
      fontFamily: "'Plus Jakarta Sans',sans-serif",
    }}>
      <div style={{
        width: 6, height: 6, borderRadius: "50%",
        background: online ? "#00d068" : "#ff3d5a",
        animation: online ? "none" : "pulse 1.5s infinite",
      }} />
      {online ? "En línea" : "Offline"}
      {syncPendiente > 0 && (
        <span style={{
          background: "#ffaa00",
          color: "#fff",
          borderRadius: 10,
          padding: "1px 6px",
          fontSize: 10,
          marginLeft: 2,
        }}>{syncPendiente}</span>
      )}
    </div>
  );
}

// ── ESTILOS GLOBALES PWA ──────────────────────────────────────
export const PWAStyles = `
  @keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: .5; transform: scale(.8); }
  }
  @keyframes fadeOut {
    0%, 70% { opacity: 1; }
    100% { opacity: 0; pointer-events: none; }
  }
  @keyframes slideUp {
    from { transform: translateX(-50%) translateY(20px); opacity: 0; }
    to { transform: translateX(-50%) translateY(0); opacity: 1; }
  }

  /* Scroll suave en toda la app */
  * { -webkit-overflow-scrolling: touch; }

  /* Evitar selección de texto en botones y navegación */
  button, nav { user-select: none; -webkit-user-select: none; }

  /* Cursor táctil en elementos interactivos */
  button, [role="button"] { -webkit-tap-highlight-color: transparent; }

  /* Safe area para tablets con notch */
  body {
    padding-top: env(safe-area-inset-top);
    padding-bottom: env(safe-area-inset-bottom);
    padding-left: env(safe-area-inset-left);
    padding-right: env(safe-area-inset-right);
  }
`;
