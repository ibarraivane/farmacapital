import { useEffect, useState } from "react";
import { MessageCircle, PackageSearch } from "lucide-react";
import { Btn, showToast } from "../ui";
import { BRAND } from "../constants";
import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";
import { flyerWhatsAppFarmaciaUrl } from "../lib/flyerFarmaCapital";
import { SOLICITUD_API_PATH, normalizarTelefonoPedido, validarSolicitudTienda } from "../lib/solicitudTienda";
import { TEXTO_AVISO_RECETA, TEXTO_BUSQUEDA_VACIA, TEXTO_RESERVA } from "../lib/bajoPedido";
import { TOKENS as T } from "../theme/tokens";

/** Otra pantalla pide abrir Pedidos especiales directo en el formulario (p. ej. «Solicitar precio»). */
export const CONSEGUIR_FORM_FLAG = "farmacapital_conseguir_form";

const inp = {
  width: "100%",
  marginTop: 4,
  padding: "12px 14px",
  borderRadius: 10,
  border: `1px solid ${T.border}`,
  fontSize: 15,
  boxSizing: "border-box",
  fontFamily: "inherit",
  background: "#ffffff",
  color: T.ink,
  WebkitTextFillColor: T.ink,
  caretColor: T.ink,
  colorScheme: "light",
};

function queryInicial(textoInicial) {
  if (textoInicial) return String(textoInicial).trim();
  try {
    const q = new URLSearchParams(window.location.search).get("q");
    if (q) return q.trim();
    return sessionStorage.getItem("farmacapital_busq") || "";
  } catch {
    return "";
  }
}

export function CatalogoVacioConseguir({ busq, setPage }) {
  const q = String(busq || "").trim();
  return (
    <div
      style={{
        gridColumn: "1 / -1",
        background: T.surface,
        border: `1px solid ${T.border}`,
        borderRadius: 16,
        padding: "32px 22px",
        textAlign: "center",
        maxWidth: 520,
        margin: "0 auto",
      }}
    >
      <div
        style={{
          width: 48,
          height: 48,
          borderRadius: 14,
          background: T.canvas,
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 12,
        }}
      >
        <PackageSearch size={24} color={T.ink} />
      </div>
      <div style={{ fontWeight: 800, fontSize: 18, color: T.ink, marginBottom: 6, fontFamily: "var(--fc-body)" }}>
        {q ? `Sin resultados para “${q}”` : "No hay productos disponibles por el momento."}
      </div>
      <p style={{ margin: "0 0 16px", color: "#475569", fontSize: 14, lineHeight: 1.5 }}>
        {TEXTO_BUSQUEDA_VACIA}
      </p>
      <Btn
        col={BRAND.primary}
        onClick={() => {
          try {
            if (q) sessionStorage.setItem("farmacapital_busq", q);
            sessionStorage.setItem(CONSEGUIR_FORM_FLAG, "1");
          } catch { /* ignore */ }
          setPage("pedidos-especiales", { search: q });
        }}
      >
        Solicitarlo
      </Btn>
    </div>
  );
}

export default function SolicitudCatalogoForm({ setPage, textoInicial, user, bajoVitrina = false, variante = "" }) {
  const [texto, setTexto] = useState(() => queryInicial(textoInicial));
  const [cantidad, setCantidad] = useState(1);
  const [urgencia, setUrgencia] = useState("sin_prisa");
  const [nombre, setNombre] = useState(user?.nombre || "");
  const [telefono, setTelefono] = useState(user?.telefono || "");
  const [email, setEmail] = useState(user?.email || "");
  const [direccion, setDireccion] = useState("");
  const [notas, setNotas] = useState("");
  const [website, setWebsite] = useState("");
  const [enviando, setEnviando] = useState(false);
  const [listo, setListo] = useState(false);

  useEffect(() => {
    if (!texto) setTexto(queryInicial(textoInicial));
  }, [textoInicial]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    try {
      if (sessionStorage.getItem(CONSEGUIR_FORM_FLAG) === "1") {
        sessionStorage.removeItem(CONSEGUIR_FORM_FLAG);
        const t = setTimeout(() => {
          (document.getElementById("pedido-especial-form") || document.getElementById("conseguir-form"))
            ?.scrollIntoView({ behavior: "smooth", block: "start" });
        }, 150);
        return () => clearTimeout(t);
      }
    } catch { /* noop */ }
    return undefined;
  }, []);

  const enviar = async () => {
    const parsed = validarSolicitudTienda({
      texto,
      cantidad,
      urgencia,
      nombre,
      telefono,
      email,
      direccion,
      notas,
    });
    if (!parsed.ok) {
      showToast(parsed.errors[0], "warning");
      return;
    }
    setEnviando(true);
    try {
      const resp = await fetch(SOLICITUD_API_PATH, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...parsed.value, website }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        showToast("No se pudo enviar. Escríbenos por WhatsApp.", "error");
        setEnviando(false);
        return;
      }
      setListo(true);
      showToast("Listo. Te escribimos con el costo.", "success");
    } catch {
      showToast("No se pudo enviar. Escríbenos por WhatsApp.", "error");
    }
    setEnviando(false);
  };

  if (listo) {
    return (
      <div style={{ maxWidth: 560, margin: "0 auto", padding: "36px 20px" }}>
        <h1 style={{ margin: "0 0 10px", fontSize: 26, fontWeight: 800, color: "#0f172a" }}>
          Ya estamos en eso
        </h1>
        <p style={{ margin: "0 0 18px", color: "#475569", fontSize: 15, lineHeight: 1.6 }}>
          Recibimos tu pedido de <strong>{texto}</strong>. Te escribimos por WhatsApp
          {telefono ? ` al ${telefono}` : ""} con el costo y la liga de pago. El envío a domicilio se cobra aparte.
        </p>
        <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
          <Btn col={BRAND.primary} onClick={() => setPage("catalogo")}>Seguir buscando</Btn>
          <Btn
            outline
            col="#25D366"
            onClick={() => window.open(flyerWhatsAppFarmaciaUrl(FARMACIA_FISCAL.telefono), "_blank", "noopener,noreferrer")}
          >
            Escribir por WhatsApp
          </Btn>
        </div>
      </div>
    );
  }

  const enCategoria = bajoVitrina || variante === "categoria";
  return (
    <div
      id="pedido-especial-form"
      className="farmacapital-solicitud-form"
      style={{
        maxWidth: 560,
        margin: "0 auto",
        padding: enCategoria ? "0 0 8px" : "8px 0 24px",
        scrollMarginTop: 90,
        colorScheme: "light",
        background: "#ffffff",
      }}
    >
      <div id="conseguir-form" style={{ scrollMarginTop: 90 }}>
      {variante !== "pagina" ? (
      <div style={{ marginBottom: 8 }}>
        {enCategoria ? (
          <h2
            style={{
              margin: 0,
              fontSize: 18,
              fontWeight: 800,
              color: T.ink,
              fontFamily: "var(--fc-body)",
            }}
          >
            ¿No está en la lista? Pídelo aquí
          </h2>
        ) : (
          <h1
            style={{
              margin: 0,
              fontSize: "clamp(22px, 5vw, 28px)",
              fontWeight: 800,
              color: T.ink,
              fontFamily: "var(--fc-body)",
            }}
          >
            Pedidos especiales
          </h1>
        )}
      </div>
      ) : null}
      {variante !== "pagina" ? (
      <p style={{ margin: "0 0 12px", color: T.textMid, fontSize: 14, lineHeight: 1.6 }}>
        {TEXTO_RESERVA} El envío a domicilio tiene costo.
      </p>
      ) : (
      <p style={{ margin: "0 0 12px", color: T.textMid, fontSize: 14, lineHeight: 1.6 }}>
        Anota lo que buscas. Te escribimos por WhatsApp o correo con el costo.
      </p>
      )}
      {variante !== "pagina" ? (
      <p style={{ margin: "0 0 20px", color: T.inkSoft, fontSize: 13, lineHeight: 1.55 }}>
        {TEXTO_AVISO_RECETA}
      </p>
      ) : null}

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>¿Qué buscas?</span>
        <input
          className="farmacapital-field-input"
          value={texto}
          onChange={(e) => setTexto(e.target.value)}
          placeholder="Ej. Losartan 50 mg, 30 tabletas"
          style={inp}
        />
      </label>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 12 }}>
        <label>
          <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>Cantidad</span>
          <input
            className="farmacapital-field-input"
            type="number"
            min={1}
            max={999}
            value={cantidad}
            onChange={(e) => setCantidad(e.target.value)}
            style={inp}
          />
        </label>
        <label>
          <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>¿Para cuándo?</span>
          <select className="farmacapital-field-select" value={urgencia} onChange={(e) => setUrgencia(e.target.value)} style={inp}>
            <option value="sin_prisa">Sin prisa</option>
            <option value="manana">Mañana</option>
            <option value="hoy">Hoy</option>
          </select>
        </label>
      </div>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>Tu nombre</span>
        <input className="farmacapital-field-input" value={nombre} onChange={(e) => setNombre(e.target.value)} placeholder="Cómo te llamas" style={inp} />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>WhatsApp (10 dígitos)</span>
        <input
          className="farmacapital-field-input"
          value={telefono}
          onChange={(e) => setTelefono(e.target.value)}
          onBlur={() => {
            // Si pegan +52 / 52 al inicio, dejar los 10 dígitos que pide la etiqueta.
            const d = normalizarTelefonoPedido(telefono);
            if (d.length === 10 && d !== telefono) setTelefono(d);
          }}
          placeholder="55 1234 5678"
          inputMode="tel"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>Correo (opcional)</span>
        <input
          className="farmacapital-field-input"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="para mandarte la liga de pago"
          type="email"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>Dirección de envío (opcional)</span>
        <input
          className="farmacapital-field-input"
          value={direccion}
          onChange={(e) => setDireccion(e.target.value)}
          placeholder="Calle, número, colonia, CP"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: T.textMid }}>Notas (marca, receta, presentación)</span>
        <input className="farmacapital-field-input" value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Opcional" style={inp} />
      </label>

      <label style={{ position: "absolute", left: -9999, width: 1, height: 1, overflow: "hidden" }} aria-hidden>
        Sitio web
        <input tabIndex={-1} autoComplete="off" value={website} onChange={(e) => setWebsite(e.target.value)} />
      </label>

      <Btn col={BRAND.primary} onClick={enviar} disabled={enviando} full>
        {enviando ? "Enviando…" : "Levantar pedido"}
      </Btn>

      <button
        type="button"
        onClick={() => window.open(flyerWhatsAppFarmaciaUrl(FARMACIA_FISCAL.telefono), "_blank", "noopener,noreferrer")}
        style={{
          marginTop: 14,
          width: "100%",
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 8,
          background: "none",
          border: "none",
          color: "#16a34a",
          fontWeight: 700,
          cursor: "pointer",
          fontSize: 14,
        }}
      >
        <MessageCircle size={16} /> Prefiero escribir por WhatsApp
      </button>
      </div>
    </div>
  );
}
