import React, { useEffect } from "react";
import FarmaCapitalAdmin from "./Admin";
import Tienda from "./Tienda";
import AdminDashboard from "./AdminDashboard";
import { adminPathnameToPageId } from "./shared/adminRoutes";
import { attachPwaManifestHistorySync } from "./syncPwaManifest";

class AdminRouteBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error) {
    // eslint-disable-next-line no-console
    console.error("[FarmaCapital Admin] Runtime crash detected:", error);
  }

  render() {
    if (this.state.hasError) {
      return <AdminDashboard />;
    }
    return this.props.children;
  }
}

class TiendaRouteBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, errMsg: "" };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, errMsg: String(error?.message || error || "") };
  }

  componentDidCatch(error) {
    // eslint-disable-next-line no-console
    console.error("[FarmaCapital Tienda] Runtime crash detected:", error);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          minHeight: "100dvh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          padding: 24,
          fontFamily: "'Poppins', sans-serif",
          background: "#f7f9fc",
        }}>
          <div style={{
            maxWidth: 440,
            width: "100%",
            background: "#fff",
            border: "1px solid #e2e8f0",
            borderRadius: 16,
            padding: "28px 24px",
            textAlign: "center",
            boxShadow: "0 8px 30px rgba(15,23,42,.08)",
          }}>
            <div style={{ fontSize: 40, marginBottom: 12 }}>⚠️</div>
            <h1 style={{ margin: "0 0 10px", color: "#0f172a", fontSize: 20, fontWeight: 800 }}>
              No pudimos cargar la tienda
            </h1>
            <p style={{ margin: "0 0 18px", color: "#475569", fontSize: 14, lineHeight: 1.55 }}>
              Hubo un error al iniciar la farmacia en línea. Probá recargar la página; si acabas de un deploy, espera un minuto y vuelve a intentar.
            </p>
            {this.state.errMsg ? (
              <p style={{
                margin: "0 0 18px",
                color: "#94a3b8",
                fontSize: 11,
                lineHeight: 1.4,
                wordBreak: "break-word",
              }}>
                {this.state.errMsg}
              </p>
            ) : null}
            <button
              type="button"
              onClick={() => {
                try {
                  const u = new URL(window.location.href);
                  u.searchParams.set("_farmacapital_v", String(Date.now()));
                  window.location.replace(u.toString());
                } catch {
                  window.location.reload();
                }
              }}
              style={{
                width: "100%",
                padding: "12px 16px",
                borderRadius: 10,
                border: "none",
                background: "linear-gradient(135deg,#0D1B2A,#1E3ABA)",
                color: "#fff",
                fontWeight: 700,
                fontSize: 14,
                cursor: "pointer",
              }}
            >
              Recargar tienda
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

export default function App() {
  useEffect(() => {
    // El contador se limpia solo si la app aguantó estable. Si lo borramos al
    // montar, el corta-circuitos de index.js nunca llega a 4 y un chunk roto
    // deja la PWA recargando para siempre.
    const t = setTimeout(() => {
      try {
        sessionStorage.removeItem("farmacapital_chunk_retries");
      } catch (_) { /* noop */ }
    }, 15000);
    try {
      const u = new URL(window.location.href);
      if (u.searchParams.has("_farmacapital_v")) {
        u.searchParams.delete("_farmacapital_v");
        const qs = u.searchParams.toString();
        const next = u.pathname + (qs ? `?${qs}` : "") + u.hash;
        window.history.replaceState(null, "", next);
      }
    } catch (_) { /* noop */ }
    return () => clearTimeout(t);
  }, []);

  /** Manifest PWA: Tienda (/) vs Admin (/admin…); el panel usa pushState sin re-render de App. */
  useEffect(() => attachPwaManifestHistorySync(), []);

  const path = window.location.pathname;
  const useAdminShell = path.startsWith("/admin") || adminPathnameToPageId(path) != null;
  if (useAdminShell) {
    return (
      <AdminRouteBoundary>
        <FarmaCapitalAdmin />
      </AdminRouteBoundary>
    );
  }
  return (
    <TiendaRouteBoundary>
      <Tienda />
    </TiendaRouteBoundary>
  );
}