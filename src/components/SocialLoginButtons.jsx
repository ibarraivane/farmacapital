import React, { useState } from "react";
import { supabase } from "../supabase";
import { enabledSocialProviders, startClienteOAuth } from "../utils/clienteOAuth";

const ICONS = {
  google: (
    <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden="true">
      <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3 0 5.8 1.1 7.9 3l5.7-5.7C34.2 6.1 29.4 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.5-.4-3.5z"/>
      <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 16.1 19 14 24 14c3 0 5.8 1.1 7.9 3l5.7-5.7C34.2 6.1 29.4 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/>
      <path fill="#4CAF50" d="M24 44c5.2 0 10-2 13.6-5.2l-6.3-5.2C29.3 35.3 26.8 36 24 36c-5.3 0-9.7-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z"/>
      <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.3 4.1-4.1 5.5l.1.1 6.3 5.2C39.2 36.3 44 32 44 24c0-1.3-.1-2.5-.4-3.5z"/>
    </svg>
  ),
  facebook: (
    <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
      <path fill="#1877F2" d="M24 12.07C24 5.41 18.63 0 12 0S0 5.41 0 12.07C0 18.1 4.39 23.09 10.13 24v-8.44H7.08v-3.49h3.05V9.41c0-3.02 1.8-4.7 4.56-4.7 1.32 0 2.7.24 2.7.24v2.97h-1.52c-1.5 0-1.97.93-1.97 1.89v2.27h3.34l-.53 3.49h-2.81V24C19.61 23.09 24 18.1 24 12.07z"/>
    </svg>
  ),
  apple: (
    <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
      <path fill="currentColor" d="M16.37 12.63c.03-2.25 1.84-3.34 1.92-3.39-1.05-1.53-2.68-1.74-3.26-1.76-1.39-.14-2.71.82-3.41.82-.7 0-1.79-.8-2.94-.78-1.51.02-2.9.88-3.67 2.23-1.57 2.72-.4 6.75 1.12 8.96.75 1.08 1.64 2.29 2.81 2.25 1.13-.05 1.56-.73 2.93-.73 1.36 0 1.76.73 2.96.71 1.22-.02 2-1.1 2.74-2.19.86-1.26 1.21-2.48 1.23-2.54-.03-.01-2.36-.9-2.33-3.58zM14.1 5.52c.62-.75 1.04-1.8.92-2.84-.89.04-1.97.59-2.61 1.34-.57.66-1.07 1.72-.94 2.73 1 .08 2.02-.51 2.63-1.23z"/>
    </svg>
  ),
};

/**
 * Botones OAuth para login/registro de la tienda.
 * @param {{ colors: object, onError?: (msg: string) => void, disabled?: boolean }} props
 */
export default function SocialLoginButtons({ colors, onError, disabled = false }) {
  const providers = enabledSocialProviders();
  const [busy, setBusy] = useState(null);
  const C = colors || {};

  if (!providers.length) return null;

  const click = async (providerId) => {
    if (disabled || busy) return;
    setBusy(providerId);
    const res = await startClienteOAuth(supabase, providerId);
    if (!res.ok) {
      onError?.(res.error || "No se pudo iniciar el login social.");
      setBusy(null);
    }
  };

  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {providers.map((p) => (
          <button
            key={p.id}
            type="button"
            disabled={disabled || Boolean(busy)}
            onClick={() => click(p.id)}
            aria-label={p.label}
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 10,
              width: "100%",
              padding: "12px 16px",
              borderRadius: 10,
              border: `1.5px solid ${
                p.id === "apple" ? "#111827" : C.border || "#e2e8f0"
              }`,
              background: p.id === "apple" ? "#111827" : C.white || "#fff",
              color: p.id === "apple" ? "#fff" : C.dark || "#0f172a",
              fontWeight: 700,
              fontSize: 14,
              fontFamily: "var(--fc-body)",
              cursor: disabled || busy ? "not-allowed" : "pointer",
              opacity: disabled || (busy && busy !== p.id) ? 0.55 : 1,
              transition: "border-color .15s, background .15s",
            }}
          >
            <span style={{ display: "inline-flex", width: 18, height: 18 }}>{ICONS[p.id]}</span>
            {busy === p.id ? "Redirigiendo…" : p.label}
          </button>
        ))}
      </div>
      <p
        style={{
          margin: "12px 0 0",
          color: C.mid || "#64748b",
          fontSize: 11,
          lineHeight: 1.45,
          textAlign: "center",
        }}
      >
        Al continuar aceptás el Aviso de Privacidad de FarmaCapital.
      </p>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 12,
          marginTop: 18,
          marginBottom: 4,
        }}
      >
        <div style={{ flex: 1, height: 1, background: C.border || "#e2e8f0" }} />
        <span style={{ color: C.mid || "#94a3b8", fontSize: 12, fontWeight: 600 }}>
          o con correo / teléfono
        </span>
        <div style={{ flex: 1, height: 1, background: C.border || "#e2e8f0" }} />
      </div>
    </div>
  );
}
