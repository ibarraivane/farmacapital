import { useState, useRef, useEffect } from "react";
import { C_LIGHT } from "./constants";
import { useMediaQuery } from "./hooks/useMediaQuery";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const CHIPS = [
  "Resume el estado del inventario hoy",
  "¿Qué productos debo reordenar esta semana?",
  "Genera un reporte breve de ventas del mes",
  "Redacta un correo a Nadro pidiendo reabasto urgente",
  "¿Qué antibióticos requieren bitácora COFEPRIS?",
];

function readLegacyGeminiKey() {
  const k = (process.env.REACT_APP_GEMINI_API_KEY || process.env.REACT_APP_GEMINI_KEY || "").trim();
  return k || null;
}

function getSessionToken() {
  try {
    return sessionStorage.getItem("farmacapital_session_token") || "";
  } catch {
    return "";
  }
}

async function sendViaProxy(messages) {
  const session_token = getSessionToken();
  if (!session_token) throw new Error("Sesión expirada. Vuelve a iniciar sesión en Admin.");
  const resp = await fetch("/api/ai/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ session_token, messages, include_context: true }),
  });
  const data = await resp.json().catch(() => ({}));
  if (resp.status === 503 && data?.error === "gemini_not_configured") {
    return { configured: false };
  }
  if (!resp.ok) {
    if (data?.error === "invalid_session") {
      throw new Error("Sesión expirada. Cierra sesión en Admin e inicia de nuevo.");
    }
    throw new Error(data?.message || data?.error || `Error ${resp.status}`);
  }
  return { configured: true, reply: data.reply };
}

/** Fallback local dev — solo si hay REACT_APP_GEMINI_API_KEY (no usar en producción). */
async function sendViaLegacyClient(messages) {
  const apiKey = readLegacyGeminiKey();
  if (!apiKey) return { configured: false };

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      system_instruction: {
        parts: [{
          text: "Eres el asistente de administración de FarmaCapital en CDMX. Ayuda con inventario, reportes, COFEPRIS y correos a proveedores. Español México.",
        }],
      },
      contents: messages.map((m) => ({
        role: m.role === "assistant" ? "model" : "user",
        parts: [{ text: m.content }],
      })),
      generationConfig: { maxOutputTokens: 2048, temperature: 0.65 },
    }),
  });
  const data = await res.json();
  if (data?.error) {
    throw new Error(data.error.message || "Error Gemini");
  }
  return {
    configured: true,
    reply: data?.candidates?.[0]?.content?.parts?.[0]?.text || "Sin respuesta.",
  };
}

export default function AsistenteIA() {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [configState, setConfigState] = useState("unknown");
  const bottomRef = useRef(null);
  const textareaRef = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior:"smooth" }); }, [messages, loading]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      if (!getSessionToken()) {
        if (!cancelled) setConfigState("no_session");
        return;
      }
      try {
        const tok = encodeURIComponent(getSessionToken());
        const resp = await fetch(`/api/ai/chat?session_token=${tok}`);
        const data = await resp.json().catch(() => ({}));
        if (!cancelled) {
          if (data?.configured && data?.session) setConfigState("ready");
          else if (data?.configured && data?.session === false) setConfigState("session_expired");
          else if (data?.configured === false && readLegacyGeminiKey()) setConfigState("legacy");
          else if (data?.configured === false) setConfigState("needs_key");
          else setConfigState("ready");
        }
      } catch {
        if (readLegacyGeminiKey() && !cancelled) setConfigState("legacy");
        else if (!cancelled) setConfigState("needs_key");
      }
    })();
    return () => { cancelled = true; };
  }, []);

  const sendMessage = async (text) => {
    const msg = (text || input).trim();
    if (!msg || loading) return;
    setInput("");
    const newMessages = [...messages, { role: "user", content: msg }];
    setMessages(newMessages);
    setLoading(true);
    try {
      let result;
      try {
        result = await sendViaProxy(newMessages);
        if (!result.configured && readLegacyGeminiKey()) {
          result = await sendViaLegacyClient(newMessages);
        }
      } catch (proxyErr) {
        if (readLegacyGeminiKey()) {
          result = await sendViaLegacyClient(newMessages);
        } else {
          throw proxyErr;
        }
      }
      if (!result?.configured) {
        setMessages((m) => [...m, {
          role: "assistant",
          content: "⚠️ Falta configurar GEMINI_API_KEY en Vercel (Production). Ver instrucciones abajo.",
        }]);
        setConfigState("needs_key");
        return;
      }
      setConfigState("ready");
      setMessages((m) => [...m, { role: "assistant", content: result.reply }]);
    } catch (err) {
      setMessages((m) => [...m, { role: "assistant", content: `Error: ${err.message}` }]);
    }
    setLoading(false);
  };

  const handleKey = (e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); } };

  if (configState === "session_expired") {
    return (
      <div style={{ padding: 24, background: C.bg, minHeight: "100dvh", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 16, padding: 32, maxWidth: 420, textAlign: "center" }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>⏱</div>
          <h2 style={{ margin: "0 0 8px", color: C.text, fontSize: 18 }}>Sesión expirada</h2>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.6, margin: 0 }}>
            Vuelve a iniciar sesión en Admin y abre de nuevo el asistente IA.
          </p>
        </div>
      </div>
    );
  }

  if (configState === "no_session") {
    return (
      <div style={{ padding: 24, background: C.bg, minHeight: "100dvh", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 16, padding: 32, maxWidth: 420, textAlign: "center" }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>🔐</div>
          <h2 style={{ margin: "0 0 8px", color: C.text, fontSize: 18 }}>Inicia sesión en Admin</h2>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.6, margin: 0 }}>El asistente IA solo está disponible para empleados autenticados.</p>
        </div>
      </div>
    );
  }

  if (configState === "needs_key") {
    return (
      <div style={{ padding: 24, background: C.bg, minHeight: "100dvh", fontFamily: "'Plus Jakarta Sans',sans-serif", display: "flex", alignItems: "center", justifyContent: "center", boxSizing: "border-box" }}>
        <div style={{ background: C.card, border: `1px solid ${C.amber}40`, borderRadius: 16, padding: 32, maxWidth: 520, width: "100%" }}>
          <div style={{ fontSize: 40, marginBottom: 16, textAlign: "center" }}>✦</div>
          <h2 style={{ margin: "0 0 12px", color: C.text, fontSize: 18, fontWeight: 800, textAlign: "center" }}>Activa Gemini en Vercel</h2>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.6, marginBottom: 20 }}>
            Recomendado: <strong>Google Gemini 2.0 Flash</strong> — capa gratuita generosa, excelente en español, ideal para reportes, inventario y redacción de correos a proveedores.
          </p>
          <div style={{ background: C.bg, borderRadius: 10, padding: 16, fontSize: 12, color: C.textMid, lineHeight: 1.85 }}>
            <div style={{ color: C.amber, fontWeight: 700, marginBottom: 8 }}>Pasos (5 min):</div>
            <div>1. Entra a <strong>aistudio.google.com</strong> → Get API key (gratis)</div>
            <div>2. Vercel → farmacapital → Settings → Environment Variables</div>
            <div>3. Agrega <code style={{ color: C.blue }}>GEMINI_API_KEY</code> = tu clave (solo Production)</div>
            <div>4. Redeploy el último deployment</div>
            <div style={{ marginTop: 10, padding: "8px 10px", background: C.card, borderRadius: 6, fontFamily: "monospace", fontSize: 11, wordBreak: "break-all" }}>
              GEMINI_API_KEY=AIza...
            </div>
            <div style={{ marginTop: 10, color: C.textDim, fontSize: 11 }}>
              La clave queda en el servidor (no se expone en el navegador). Para desarrollo local puedes usar <code>REACT_APP_GEMINI_API_KEY</code> en <code>.env</code>.
            </div>
          </div>
        </div>
      </div>
    );
  }

  const inputFont = isMobile ? 16 : 13;

  return (
    <div style={{
      display: "flex",
      flexDirection: "column",
      minHeight: "100dvh",
      background: C.bg,
      fontFamily: "'Plus Jakarta Sans',sans-serif",
      boxSizing: "border-box",
    }}>
      <div style={{ padding: "16px 24px", borderBottom: `1px solid ${C.border}`, background: C.card, display: "flex", justifyContent: "space-between", alignItems: "center", flexShrink: 0, gap: 12 }}>
        <div style={{ minWidth: 0 }}>
          <h1 style={{ margin: 0, color: C.text, fontSize: 18, fontWeight: 800 }}>✦ Asistente FarmaCapital</h1>
          <p style={{ margin: "2px 0 0", color: C.textMid, fontSize: 11 }}>
            Gemini 2.0 Flash · Inventario, reportes y correos
            {configState === "legacy" ? " · modo dev local" : ""}
          </p>
        </div>
        {messages.length > 0 && (
          <button type="button" onClick={() => setMessages([])} style={{ padding: "6px 14px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, cursor: "pointer", fontWeight: 700, fontSize: 11, flexShrink: 0 }}>
            🗑 Limpiar
          </button>
        )}
      </div>
      <div style={{ display: "flex", gap: 8, padding: "10px 16px", overflowX: "auto", borderBottom: `1px solid ${C.border}`, flexShrink: 0, WebkitOverflowScrolling: "touch" }}>
        {CHIPS.map((chip, i) => (
          <button key={i} type="button" onClick={() => sendMessage(chip)} disabled={loading} style={{
            padding: "5px 14px", borderRadius: 20, border: `1px solid ${C.blue}40`,
            background: C.blueDim, color: C.blue, cursor: "pointer", fontWeight: 600, fontSize: 11,
            whiteSpace: "nowrap", flexShrink: 0, opacity: loading ? 0.6 : 1,
          }}>{chip}</button>
        ))}
      </div>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 24px", display: "flex", flexDirection: "column", gap: 14 }}>
        {messages.length === 0 && (
          <div style={{ textAlign: "center", margin: "auto", color: C.textMid, padding: "8px 0" }}>
            <div style={{ fontSize: 40, marginBottom: 12 }}>✦</div>
            <div style={{ fontSize: 15, fontWeight: 700, color: C.text, marginBottom: 8 }}>¿En qué te puedo ayudar?</div>
            <div style={{ fontSize: 12, lineHeight: 1.6, maxWidth: 360, margin: "0 auto" }}>
              Pregunta por stock bajo, pide un reporte de ventas o un borrador de correo a proveedores. Uso datos en vivo de tu inventario cuando están disponibles.
            </div>
          </div>
        )}
        {messages.map((m, i) => (
          <div key={i} style={{ display: "flex", justifyContent: m.role === "user" ? "flex-end" : "flex-start", alignItems: "flex-start" }}>
            {m.role === "assistant" && (
              <div style={{ width: 28, height: 28, borderRadius: "50%", background: BRAND.gradient, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, marginRight: 8, flexShrink: 0, marginTop: 2 }}>✦</div>
            )}
            <div style={{
              maxWidth: isMobile ? "88%" : "72%", padding: "10px 14px",
              borderRadius: m.role === "user" ? "14px 14px 4px 14px" : "14px 14px 14px 4px",
              background: m.role === "user" ? BRAND.gradient : C.card,
              color: m.role === "user" ? "#fff" : C.text, fontSize: 13, lineHeight: 1.6,
              border: m.role === "assistant" ? `1px solid ${C.border}` : "none",
              whiteSpace: "pre-wrap", wordBreak: "break-word",
            }}>{m.content}</div>
          </div>
        ))}
        {loading && (
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: "50%", background: BRAND.gradient, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, flexShrink: 0 }}>✦</div>
            <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: "14px 14px 14px 4px", padding: "12px 16px", display: "flex", gap: 5, alignItems: "center" }}>
              {[0, 1, 2].map((j) => (
                <div key={j} style={{ width: 7, height: 7, borderRadius: "50%", background: C.blue, opacity: 0.7 }} />
              ))}
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>
      <div style={{
        padding: "12px 20px",
        paddingBottom: "max(12px, env(safe-area-inset-bottom, 0px))",
        borderTop: `1px solid ${C.border}`,
        background: C.card,
        flexShrink: 0,
        position: "sticky",
        bottom: 0,
        zIndex: 3,
      }}>
        <div style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
          <textarea ref={textareaRef} value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={handleKey}
            placeholder="Ej: redacta correo a Marzam por reabasto de amoxicilina…"
            rows={1} style={{
              flex: 1, minWidth: 0, padding: "10px 14px", borderRadius: 10, border: `1px solid ${C.border}`,
              background: C.bg, color: C.text, fontSize: inputFont, outline: "none",
              resize: "none", lineHeight: 1.5, fontFamily: "inherit", maxHeight: 120, overflowY: "auto",
            }} />
          <button type="button" onClick={() => sendMessage()} disabled={!input.trim() || loading} style={{
            padding: "10px 20px", borderRadius: 10, border: "none", cursor: "pointer",
            background: !input.trim() || loading ? C.border : BRAND.gradient,
            color: "#fff", fontWeight: 700, fontSize: 13, flexShrink: 0,
            opacity: !input.trim() || loading ? 0.5 : 1,
          }}>{loading ? "…" : "Enviar"}</button>
        </div>
      </div>
    </div>
  );
}
