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

export default function App() {
  useEffect(() => {
    try {
      sessionStorage.removeItem("farmacapital_chunk_retries");
    } catch (_) { /* noop */ }
    try {
      const u = new URL(window.location.href);
      if (u.searchParams.has("_farmacapital_v")) {
        u.searchParams.delete("_farmacapital_v");
        const qs = u.searchParams.toString();
        const next = u.pathname + (qs ? `?${qs}` : "") + u.hash;
        window.history.replaceState(null, "", next);
      }
    } catch (_) { /* noop */ }
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
  return <Tienda />;
}