import React from "react";
import FarmaxAdmin from "./Admin";
import Tienda from "./Tienda";
import AdminDashboard from "./AdminDashboard";

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
  const path = window.location.pathname;
  if (path.startsWith("/admin")) {
    return (
      <AdminRouteBoundary>
        <FarmaxAdmin />
      </AdminRouteBoundary>
    );
  }
  return <Tienda />;
}