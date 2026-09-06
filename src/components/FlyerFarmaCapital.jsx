import { useMemo, useRef, useState } from "react";
import { QRCodeSVG } from "qrcode.react";
import { Download, Link2, Mail, MessageCircle, QrCode } from "lucide-react";
import { Logo, showToast } from "../ui";
import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";
import { HORARIO_FARMACIA } from "../constants/turnos";
import {
  flyerHomeUrl,
  flyerMailtoShareUrl,
  flyerWhatsAppShareUrl,
  flyerShareCaption,
} from "../lib/flyerFarmaCapital";

const NAVY = "#0D1B2A";
const BLUE = "#1E3ABA";
const JADE = "#22C55E";
const WA = "#25D366";

function siteOrigin() {
  if (typeof window === "undefined") return "https://www.farmacapital.mx";
  return window.location.origin || "https://www.farmacapital.mx";
}

async function canvasFromNode(node) {
  const html2canvas = (await import("html2canvas")).default;
  return html2canvas(node, {
    backgroundColor: NAVY,
    scale: 2,
    useCORS: true,
    logging: false,
  });
}

export function FlyerCard({ qrUrl }) {
  return (
    <article
      data-flyer-card="1"
      style={{
        width: "100%",
        maxWidth: 420,
        margin: "0 auto",
        background: `linear-gradient(165deg, ${NAVY} 0%, #102a4a 52%, ${BLUE} 100%)`,
        color: "#fff",
        borderRadius: 28,
        padding: "32px 22px 26px",
        boxShadow: "0 24px 60px rgba(13,27,42,0.35)",
        fontFamily: "var(--fc-body), 'Plus Jakarta Sans', system-ui, sans-serif",
        position: "relative",
        overflow: "hidden",
        textAlign: "center",
      }}
    >
      <div
        aria-hidden
        style={{
          position: "absolute",
          width: 220,
          height: 220,
          borderRadius: "50%",
          background: "rgba(34,197,94,0.12)",
          top: -80,
          right: -60,
        }}
      />
      <div
        aria-hidden
        style={{
          position: "absolute",
          width: 160,
          height: 160,
          borderRadius: "50%",
          background: "rgba(30,58,186,0.35)",
          bottom: 40,
          left: -70,
        }}
      />

      <div style={{ position: "relative" }}>
        <div data-brand-surface="dark" style={{ display: "flex", justifyContent: "center", marginBottom: 14 }}>
          <Logo size={28} light iconOnly />
        </div>
        <div
          style={{
            fontSize: 11,
            letterSpacing: 2.4,
            textTransform: "uppercase",
            fontWeight: 700,
            color: "rgba(255,255,255,0.62)",
            marginBottom: 8,
          }}
        >
          Farmacia · Consulta · Envío
        </div>
        <h1
          style={{
            margin: 0,
            fontSize: "clamp(34px, 9vw, 44px)",
            fontWeight: 800,
            lineHeight: 1.05,
            letterSpacing: -1.2,
          }}
        >
          FarmaCapital
        </h1>
        <p style={{ margin: "12px auto 0", maxWidth: 320, fontSize: 14, lineHeight: 1.5, color: "rgba(255,255,255,0.82)" }}>
          Entra, busca lo que necesitas y compra. Si no está en el catálogo, te lo conseguimos a domicilio.
        </p>

        <a
          href={qrUrl}
          style={{
            display: "block",
            margin: "22px auto 8px",
            width: 196,
            background: "#fff",
            borderRadius: 20,
            padding: 12,
            textDecoration: "none",
            boxShadow: "0 10px 28px rgba(0,0,0,0.22)",
          }}
          aria-label="Abrir farmacapital.mx"
        >
          <QRCodeSVG
            value={qrUrl}
            size={172}
            bgColor="#ffffff"
            fgColor={NAVY}
            level="M"
            includeMargin={false}
          />
        </a>
        <div style={{ fontSize: 12, fontWeight: 700, color: JADE, marginBottom: 16 }}>
          Escanea · farmacapital.mx
        </div>

        <div
          style={{
            margin: "0 auto",
            maxWidth: 280,
            fontSize: 13,
            lineHeight: 1.5,
            color: "rgba(255,255,255,0.86)",
          }}
        >
          <div>{FARMACIA_FISCAL.direccion_comercial}</div>
          <div style={{ marginTop: 6 }}>
            Todos los días {HORARIO_FARMACIA.apertura}–{HORARIO_FARMACIA.cierre}
          </div>
          <div style={{ marginTop: 6 }}>WhatsApp {FARMACIA_FISCAL.telefono_display}</div>
        </div>
      </div>
    </article>
  );
}

export default function FlyerFarmaCapital({ setPage }) {
  const origin = useMemo(() => siteOrigin(), []);
  const qrUrl = flyerHomeUrl(origin);
  const cardRef = useRef(null);
  const [busy, setBusy] = useState("");

  const guardarPng = async () => {
    const node = cardRef.current?.querySelector("[data-flyer-card]");
    if (!node) return;
    setBusy("png");
    try {
      const canvas = await canvasFromNode(node);
      const a = document.createElement("a");
      a.href = canvas.toDataURL("image/png");
      a.download = "farmacapital-flyer.png";
      a.click();
      showToast("Flyer guardado. Ya lo puedes mandar por WhatsApp.", "success");
    } catch (e) {
      showToast("No se pudo guardar la imagen. Usa Compartir por WhatsApp.", "error");
      console.warn("[Flyer] png:", e);
    }
    setBusy("");
  };

  const compartirWhatsApp = async () => {
    const node = cardRef.current?.querySelector("[data-flyer-card]");
    const caption = flyerShareCaption(origin);
    setBusy("wa");
    try {
      if (node && navigator.share) {
        const canvas = await canvasFromNode(node);
        const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
        if (blob) {
          const file = new File([blob], "farmacapital-flyer.png", { type: "image/png" });
          if (navigator.canShare?.({ files: [file] })) {
            await navigator.share({ files: [file], title: "FarmaCapital", text: caption });
            setBusy("");
            return;
          }
          if (navigator.canShare?.({ text: caption })) {
            await navigator.share({ title: "FarmaCapital", text: caption, url: qrUrl });
            setBusy("");
            return;
          }
        }
      }
    } catch (e) {
      if (e?.name === "AbortError") {
        setBusy("");
        return;
      }
      console.warn("[Flyer] share:", e);
    }
    window.open(flyerWhatsAppShareUrl(origin), "_blank", "noopener,noreferrer");
    setBusy("");
  };

  const copiarLink = async () => {
    try {
      await navigator.clipboard.writeText(qrUrl);
      showToast("Link copiado", "success");
    } catch {
      showToast(qrUrl, "info");
    }
  };

  const btn = (label, onClick, bg, Icon, disabled) => (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      style={{
        flex: "1 1 160px",
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 8,
        padding: "12px 14px",
        borderRadius: 12,
        border: "none",
        background: bg,
        color: "#fff",
        fontWeight: 800,
        fontSize: 14,
        cursor: disabled ? "wait" : "pointer",
        opacity: disabled ? 0.7 : 1,
        fontFamily: "inherit",
      }}
    >
      <Icon size={16} />
      {label}
    </button>
  );

  return (
    <div style={{ maxWidth: 720, margin: "0 auto", padding: "28px 16px 48px" }}>
      <div style={{ textAlign: "center", marginBottom: 20 }}>
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            color: BLUE,
            fontWeight: 800,
            fontSize: 12,
            letterSpacing: 1.2,
            textTransform: "uppercase",
          }}
        >
          <QrCode size={16} /> Flyer para WhatsApp
        </div>
        <h2 style={{ margin: "8px 0 6px", fontSize: 22, fontWeight: 800, color: NAVY }}>
          Compártelo con tus contactos
        </h2>
        <p style={{ margin: 0, color: "#475569", fontSize: 14, lineHeight: 1.5 }}>
          WhatsApp: foto + link. Correo: ligas para entrar a la tienda. Si no está, levantan el pedido y tú pasas el costo.
        </p>
      </div>

      <div ref={cardRef}>
        <FlyerCard qrUrl={qrUrl} />
      </div>

      <p style={{ margin: "16px 0 0", color: "#64748b", fontSize: 13, lineHeight: 1.5, textAlign: "center" }}>
        WhatsApp: manda la imagen (sin botones; el QR y el link hacen el trabajo). Correo: van ligas clicables, no botones pintados.
      </p>

      <div style={{ display: "flex", flexWrap: "wrap", gap: 10, marginTop: 14 }}>
        {btn(busy === "wa" ? "Preparando…" : "WhatsApp (imagen)", compartirWhatsApp, WA, MessageCircle, busy === "wa")}
        {btn("Enviar por correo", () => { window.location.href = flyerMailtoShareUrl(origin); }, BLUE, Mail, false)}
        {btn(busy === "png" ? "Guardando…" : "Guardar imagen", guardarPng, NAVY, Download, busy === "png")}
        {btn("Copiar link", copiarLink, "#334155", Link2, false)}
      </div>

      <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginTop: 12, justifyContent: "center" }}>
        <button
          type="button"
          onClick={() => setPage?.("catalogo")}
          style={{ background: "none", border: "none", color: BLUE, fontWeight: 700, cursor: "pointer", fontSize: 13 }}
        >
          Ir al catálogo
        </button>
        <button
          type="button"
          onClick={() => setPage?.("conseguir")}
          style={{ background: "none", border: "none", color: BLUE, fontWeight: 700, cursor: "pointer", fontSize: 13 }}
        >
          ¿No lo encuentras? Te lo conseguimos
        </button>
      </div>
    </div>
  );
}
