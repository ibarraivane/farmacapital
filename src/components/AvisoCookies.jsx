import { useEffect, useState } from "react";
import { BRAND } from "../constants";
import { guardarConsentimientoCookies, leerConsentimientoCookies } from "../lib/cookieConsent";

function almacenamiento() {
  try {
    return window.localStorage;
  } catch (_) {
    return null;
  }
}

export default function AvisoCookies() {
  const [visible, setVisible] = useState(() => leerConsentimientoCookies(almacenamiento()) == null);

  useEffect(() => {
    if (!visible || typeof document === "undefined") return undefined;
    const prev = document.body.style.paddingBottom;
    document.body.style.paddingBottom = "88px";
    return () => {
      document.body.style.paddingBottom = prev;
    };
  }, [visible]);

  if (!visible) return null;

  const elegir = (valor) => {
    const store = almacenamiento();
    if (store) guardarConsentimientoCookies(store, valor);
    setVisible(false);
  };

  return (
    <div
      role="dialog"
      aria-label="Aviso de cookies"
      style={{
        position: "fixed",
        left: 12,
        right: 12,
        bottom: "calc(12px + env(safe-area-inset-bottom, 0px))",
        maxWidth: 720,
        margin: "0 auto",
        background: "#ffffff",
        color: "#0f172a",
        border: "1px solid #e2e8f0",
        borderRadius: 14,
        boxShadow: "0 8px 30px rgba(15,23,42,.12)",
        padding: "10px 14px",
        maxHeight: 80,
        zIndex: 40,
        colorScheme: "light",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 10, flexWrap: "nowrap" }}>
        <p style={{ margin: 0, fontSize: 13, lineHeight: 1.35, color: "#0f172a", flex: "1 1 auto", minWidth: 0 }}>
          Cookies para el carrito y tu cuenta.{" "}
          <a href="/privacidad" style={{ color: BRAND.primary, fontWeight: 700 }}>
            Aviso de privacidad
          </a>
        </p>
        <div style={{ display: "flex", flexWrap: "nowrap", gap: 8, flex: "0 0 auto" }}>
        <button
          type="button"
          onClick={() => elegir("aceptadas")}
          style={{
            background: BRAND.primary,
            color: "#ffffff",
            border: "none",
            borderRadius: 999,
            padding: "10px 14px",
            minHeight: 44,
            fontWeight: 700,
            fontSize: 14,
            cursor: "pointer",
            colorScheme: "light",
          }}
        >
          Aceptar
        </button>
        <button
          type="button"
          onClick={() => elegir("rechazadas")}
          style={{
            background: "#ffffff",
            color: "#0f172a",
            border: "1px solid #cbd5e1",
            borderRadius: 999,
            padding: "10px 14px",
            minHeight: 44,
            fontWeight: 700,
            fontSize: 14,
            cursor: "pointer",
            colorScheme: "light",
          }}
        >
          Solo necesarias
        </button>
        </div>
      </div>
    </div>
  );
}
