import { useState, useEffect, useMemo } from "react";
import { C_LIGHT } from "./constants";
import { isAdminWebAppShell } from "./syncPwaManifest";

const BRAND = { primary: "#0052cc", gradient: "linear-gradient(135deg,#0052cc,#0099e6)" };

function qrSrc(url) {
  return `https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${encodeURIComponent(url)}&bgcolor=ffffff&color=0052cc&margin=10`;
}

export default function InstalarPWA() {
  const C = C_LIGHT;
  const { origin, urlTienda, urlAdmin } = useMemo(() => {
    if (typeof window === "undefined") {
      return { origin: "", urlTienda: "/", urlAdmin: "/admin" };
    }
    const o = window.location.origin;
    return { origin: o, urlTienda: `${o}/`, urlAdmin: `${o}/admin` };
  }, []);

  const [yaInstalada, setYaInstalada] = useState(false);
  const [deferredPrompt, setDeferredPrompt] = useState(null);
  const [instalando, setInstalando] = useState(false);
  const [instalada, setInstalada] = useState(false);
  const [tab, setTab] = useState("android");
  const enPanelAdmin = typeof window !== "undefined" && isAdminWebAppShell();

  useEffect(() => {
    if (window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone) {
      setYaInstalada(true);
    }
    const handler = (e) => {
      e.preventDefault();
      setDeferredPrompt(e);
    };
    window.addEventListener("beforeinstallprompt", handler);
    return () => window.removeEventListener("beforeinstallprompt", handler);
  }, []);

  const instalarAhora = async () => {
    if (!deferredPrompt) return;
    setInstalando(true);
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") setInstalada(true);
    setDeferredPrompt(null);
    setInstalando(false);
  };

  const pasos = {
    android: {
      tienda: [
        { n: 1, icon: "🔗", txt: `Abre Chrome y entra a la tienda: ${urlTienda}` },
        { n: 2, icon: "⋮", txt: "Menú (tres puntos) → Instalar app o Agregar a la pantalla de inicio" },
        { n: 3, icon: "✅", txt: "Confirma. El acceso directo abre la tienda en /" },
      ],
      admin: [
        { n: 1, icon: "🔗", txt: `Abre Chrome y entra al panel: ${urlAdmin}` },
        { n: 2, icon: "⋮", txt: "Menú → Instalar app o Agregar a la pantalla de inicio" },
        { n: 3, icon: "✅", txt: "Confirma. El acceso directo abre el administrador en /admin" },
      ],
    },
    iphone: {
      tienda: [
        { n: 1, icon: "🌐", txt: "Abre Safari (recomendado en iPhone)" },
        { n: 2, icon: "🔗", txt: `Visita primero la tienda: ${urlTienda}` },
        { n: 3, icon: "📤", txt: "Compartir → Añadir a pantalla de inicio" },
        { n: 4, icon: "✅", txt: "Safari usa la página abierta: debe ser la tienda para que el icono abra /" },
      ],
      admin: [
        { n: 1, icon: "🌐", txt: "Abre Safari" },
        { n: 2, icon: "🔗", txt: `Visita primero el panel: ${urlAdmin}` },
        { n: 3, icon: "📤", txt: "Compartir → Añadir a pantalla de inicio" },
        { n: 4, icon: "✅", txt: "El acceso directo abrirá la URL que tenías abierta (/admin)" },
      ],
    },
    windows: {
      tienda: [
        { n: 1, icon: "🌐", txt: `Chrome o Edge: abre ${urlTienda}` },
        { n: 2, icon: "💻", txt: "Icono de instalar en la barra de direcciones (⊕ o Monitor+descarga)" },
        { n: 3, icon: "✅", txt: "Confirma. La app abre la tienda" },
      ],
      admin: [
        { n: 1, icon: "🌐", txt: `Chrome o Edge: abre ${urlAdmin}` },
        { n: 2, icon: "💻", txt: "Instalar desde la barra de direcciones" },
        { n: 3, icon: "✅", txt: "La app abre el panel administrativo" },
      ],
    },
  };

  const cardBase = {
    borderRadius: 14,
    padding: 20,
    border: `1px solid ${C.border}`,
    background: C.card,
    boxSizing: "border-box",
  };

  return (
    <div style={{ maxWidth: 900, margin: "0 auto" }}>
      <h1 style={{ color: C.text, fontSize: 22, fontWeight: 800, marginBottom: 8 }}>
        Instalar FarmaCapital como app
      </h1>
      <p style={{ color: C.textMid, fontSize: 14, marginBottom: 16, lineHeight: 1.6 }}>
        Hay <strong style={{ color: C.text }}>dos aplicaciones web</strong> en este mismo sitio: la{" "}
        <strong>Tienda</strong> (público, inicio en <code style={{ fontSize: 12 }}>/</code>) y el{" "}
        <strong>Admin</strong> (panel interno, inicio en <code style={{ fontSize: 12 }}>/admin</code>).
        Cada una tiene su propio manifest; en Chrome puedes instalar ambas con iconos y nombres distintos.
      </p>

      <div
        style={{
          background: "#eff6ff",
          border: "1px solid #bfdbfe",
          borderRadius: 12,
          padding: 14,
          marginBottom: 20,
          fontSize: 13,
          color: "#1e40af",
          lineHeight: 1.55,
        }}
      >
        <strong>Importante:</strong> El navegador instala la app asociada a la{" "}
        <strong>URL que tienes abierta</strong> y al manifest enlazado en esa vista. Desde esta pantalla
        (panel) el manifest activo es <strong>FarmaCapital Admin</strong>. Para instalar solo la tienda, abre la
        tienda en una pestaña nueva y usa instalar allí.
        <div style={{ marginTop: 10, fontSize: 12, color: C.textMid }}>
          <strong>iPhone/Safari:</strong> no usa el manifest como Chrome; el acceso directo abre la página que
          estaba visible al pulsar &quot;Añadir a pantalla de inicio&quot;. Abre primero <code>/</code> o{" "}
          <code>/admin</code> según lo que quieras fijar.
        </div>
      </div>

      {yaInstalada ? (
        <div
          style={{
            background: C.greenDim,
            border: `1px solid ${C.green}30`,
            borderRadius: 12,
            padding: 16,
            marginBottom: 24,
            display: "flex",
            alignItems: "center",
            gap: 12,
          }}
        >
          <span style={{ fontSize: 28 }}>✅</span>
          <div>
            <div style={{ color: "#16a34a", fontWeight: 700, fontSize: 14 }}>
              Esta sesión está en modo app (PWA / pantalla completa)
            </div>
            <div style={{ color: "#16a34a", fontSize: 12, marginTop: 2 }}>
              Si necesitas la otra app (tienda vs admin), instálala por separado desde la URL correspondiente.
            </div>
          </div>
        </div>
      ) : deferredPrompt ? (
        <div
          style={{
            background: "#eff6ff",
            border: `1px solid #bfdbfe`,
            borderRadius: 12,
            padding: 16,
            marginBottom: 24,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexWrap: "wrap",
            gap: 12,
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <span style={{ fontSize: 28 }}>🔔</span>
            <div>
              <div style={{ color: BRAND.primary, fontWeight: 700, fontSize: 14 }}>
                Instalación disponible ({enPanelAdmin ? "FarmaCapital Admin" : "FarmaCapital Tienda"})
              </div>
              <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>
                El navegador ofrece instalar la app que corresponde a esta URL y al manifest actual.
              </div>
            </div>
          </div>
          <button
            type="button"
            onClick={instalarAhora}
            disabled={instalando || instalada}
            style={{
              padding: "10px 20px",
              borderRadius: 8,
              border: "none",
              background: BRAND.gradient,
              color: "#fff",
              fontWeight: 700,
              fontSize: 13,
              cursor: "pointer",
            }}
          >
            {instalada ? "✅ Instalada" : instalando ? "Instalando…" : "⬇️ Instalar ahora"}
          </button>
        </div>
      ) : (
        <div
          style={{
            background: "#fef3c7",
            border: "1px solid #f59e0b30",
            borderRadius: 12,
            padding: 14,
            marginBottom: 20,
            fontSize: 13,
            color: "#92400e",
          }}
        >
          Si no aparece el botón de instalar, usa el menú del navegador en la URL correcta (tienda o admin)
          o sigue los pasos por dispositivo más abajo.
        </div>
      )}

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 280px), 1fr))",
          gap: 16,
          marginBottom: 28,
        }}
      >
        <div style={{ ...cardBase }}>
          <div style={{ fontSize: 28, marginBottom: 8 }}>🛒</div>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 6 }}>FarmaCapital Tienda</div>
          <div style={{ color: C.textMid, fontSize: 12, lineHeight: 1.5, marginBottom: 12 }}>
            Acceso directo al catálogo y compra en línea. <strong>Start URL:</strong>{" "}
            <code style={{ fontSize: 11 }}>/</code>
          </div>
          <a
            href={urlTienda}
            target="_blank"
            rel="noopener noreferrer"
            style={{
              display: "inline-block",
              marginBottom: 10,
              color: BRAND.primary,
              fontWeight: 700,
              fontSize: 13,
            }}
          >
            Abrir tienda en pestaña nueva →
          </a>
          <div style={{ color: C.textDim, fontSize: 11, fontFamily: "monospace", wordBreak: "break-all" }}>
            {urlTienda}
          </div>
        </div>

        <div style={{ ...cardBase, borderColor: BRAND.primary + "55", background: "#f8fafc" }}>
          <div style={{ fontSize: 28, marginBottom: 8 }}>⚙️</div>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 6 }}>FarmaCapital Admin</div>
          <div style={{ color: C.textMid, fontSize: 12, lineHeight: 1.5, marginBottom: 12 }}>
            Panel interno (POS, inventario, consultorio). <strong>Start URL:</strong>{" "}
            <code style={{ fontSize: 11 }}>/admin</code>
          </div>
          <a
            href={urlAdmin}
            target="_blank"
            rel="noopener noreferrer"
            style={{
              display: "inline-block",
              marginBottom: 10,
              color: BRAND.primary,
              fontWeight: 700,
              fontSize: 13,
            }}
          >
            Abrir admin en pestaña nueva →
          </a>
          <div style={{ color: C.textDim, fontSize: 11, fontFamily: "monospace", wordBreak: "break-all" }}>
            {urlAdmin}
          </div>
        </div>
      </div>

      <div style={{ ...cardBase, marginBottom: 24, padding: 0, overflow: "hidden" }}>
        <div style={{ display: "flex", borderBottom: `1px solid ${C.border}` }}>
          {[
            ["android", "Android"],
            ["iphone", "iPhone / iPad"],
            ["windows", "Windows"],
          ].map(([id, label]) => (
            <button
              key={id}
              type="button"
              onClick={() => setTab(id)}
              style={{
                flex: 1,
                padding: "12px 8px",
                border: "none",
                cursor: "pointer",
                fontWeight: 700,
                fontSize: 12,
                background: tab === id ? "#eff6ff" : "transparent",
                color: tab === id ? BRAND.primary : C.textMid,
                borderBottom: tab === id ? `2px solid ${BRAND.primary}` : "2px solid transparent",
              }}
            >
              {label}
            </button>
          ))}
        </div>
        <div style={{ padding: 20 }}>
          {(["tienda", "admin"] ).map((which) => (
            <div key={which} style={{ marginBottom: which === "tienda" ? 24 : 0 }}>
              <div
                style={{
                  color: C.text,
                  fontWeight: 800,
                  fontSize: 13,
                  marginBottom: 12,
                  display: "flex",
                  alignItems: "center",
                  gap: 8,
                }}
              >
                {which === "tienda" ? "🛒 Tienda" : "⚙️ Admin"}
              </div>
              {pasos[tab][which].map((p) => (
                <div key={p.n} style={{ display: "flex", alignItems: "flex-start", gap: 14, marginBottom: 14 }}>
                  <div
                    style={{
                      width: 30,
                      height: 30,
                      borderRadius: "50%",
                      background: BRAND.gradient,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      color: "#fff",
                      fontWeight: 800,
                      fontSize: 13,
                      flexShrink: 0,
                    }}
                  >
                    {p.n}
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 10, flex: 1, minWidth: 0 }}>
                    <span style={{ fontSize: 18 }}>{p.icon}</span>
                    <span style={{ color: C.text, fontSize: 13, lineHeight: 1.5 }}>{p.txt}</span>
                  </div>
                </div>
              ))}
            </div>
          ))}
        </div>
      </div>

      <div style={{ ...cardBase, marginBottom: 24, textAlign: "center" }}>
        <div style={{ color: C.text, fontWeight: 700, fontSize: 15, marginBottom: 6 }}>Códigos QR</div>
        <div style={{ color: C.textMid, fontSize: 12, marginBottom: 20, lineHeight: 1.5 }}>
          Escanea con la cámara del celular para abrir la URL correcta antes de instalar.
        </div>
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "center",
            gap: 28,
            alignItems: "flex-start",
          }}
        >
          <div>
            <div style={{ fontWeight: 700, fontSize: 12, marginBottom: 8, color: C.text }}>Tienda</div>
            <img
              src={qrSrc(urlTienda)}
              alt="QR Tienda FarmaCapital"
              style={{ width: 160, height: 160, borderRadius: 12, border: `1px solid ${C.border}` }}
            />
          </div>
          <div>
            <div style={{ fontWeight: 700, fontSize: 12, marginBottom: 8, color: C.text }}>Admin</div>
            <img
              src={qrSrc(urlAdmin)}
              alt="QR Admin FarmaCapital"
              style={{ width: 160, height: 160, borderRadius: 12, border: `1px solid ${C.border}` }}
            />
          </div>
        </div>
      </div>

      <div style={{ ...cardBase }}>
        <div style={{ color: C.text, fontWeight: 700, fontSize: 14, marginBottom: 12 }}>Notas por navegador</div>
        <ul style={{ margin: 0, paddingLeft: 18, color: C.textMid, fontSize: 12, lineHeight: 1.65 }}>
          <li>
            <strong>Chrome / Edge (Android y escritorio):</strong> pueden convivir dos instalaciones (Tienda y
            Admin) porque los manifests tienen <code>id</code> y <code>start_url</code> distintos.
          </li>
          <li>
            <strong>Safari (iOS):</strong> el acceso directo es un marcador a la URL actual; no depende del
            archivo manifest igual que en Chrome. Instala cada uno con la página correspondiente abierta.
          </li>
          <li>
            <strong>Mismo origen:</strong> el service worker registrado en <code>/</code> sigue aplicando a
            ambas rutas; no se duplica la lógica offline.
          </li>
        </ul>
      </div>
    </div>
  );
}
