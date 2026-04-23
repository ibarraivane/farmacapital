import React, { useEffect } from "react";
import FarmaxAdmin from "./Admin";
import Tienda from "./Tienda";
import AdminDashboard from "./AdminDashboard";
import { adminPathnameToPageId } from "./shared/adminRoutes";

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
    console.error("[Farmax Admin] Runtime crash detected:", error);
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
      sessionStorage.removeItem("farmax_chunk_reload_once");
    } catch (_) { /* noop */ }
  }, []);

  const path = window.location.pathname;
  const useAdminShell = path.startsWith("/admin") || adminPathnameToPageId(path) != null;
  if (useAdminShell) {
    return (
      <AdminRouteBoundary>
        <FarmaxAdmin />
      </AdminRouteBoundary>
    );
  }
  return <Tienda />;
}