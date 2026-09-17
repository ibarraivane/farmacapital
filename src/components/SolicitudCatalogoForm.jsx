import { useEffect, useState } from "react";
import { MessageCircle, PackageSearch, Truck } from "lucide-react";
import { Btn, showToast } from "../ui";
import { BRAND } from "../constants";
import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";
import { flyerWhatsAppFarmaciaUrl } from "../lib/flyerFarmaCapital";
import { SOLICITUD_API_PATH, normalizarTelefonoPedido, validarSolicitudTienda } from "../lib/solicitudTienda";

/** Otra pantalla pide abrir /conseguir directo en el formulario (p. ej. «Cotizar»). */
export const CONSEGUIR_FORM_FLAG = "farmacapital_conseguir_form";

const inp = {
  width: "100%",
  marginTop: 4,
  padding: "12px 14px",
  borderRadius: 10,
  border: "1px solid #cbd5e1",
  fontSize: 16,
  boxSizing: "border-box",
  fontFamily: "inherit",
  background: "#ffffff",
  color: "#0f172a",
  WebkitTextFillColor: "#0f172a",
  caretColor: "#0f172a",
  colorScheme: "light",
};

const labelTxt = { fontSize: 13, fontWeight: 800, color: "#0f172a", display: "block" };
const hintTxt = { fontSize: 12, fontWeight: 500, color: "#64748b", display: "block", marginTop: 2 };

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
        background: "#fff",
        border: "1px solid #e2e8f0",
        borderRadius: 16,
        padding: "28px 20px",
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
          background: BRAND.primary + "14",
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 12,
        }}
      >
        <PackageSearch size={24} color={BRAND.primary} />
      </div>
      <div style={{ fontWeight: 800, fontSize: 18, color: "#0f172a", marginBottom: 6 }}>
        {q ? `Sin resultados para “${q}”` : "No hay productos disponibles por el momento."}
      </div>
      <p style={{ margin: "0 0 16px", color: "#475569", fontSize: 14, lineHeight: 1.5 }}>
        ¿No lo encuentras en el catálogo? Te lo conseguimos. Te escribimos por WhatsApp con el precio y la liga de pago. El envío a domicilio se cobra aparte.
      </p>
      <Btn
        col={BRAND.primary}
        onClick={() => {
          try {
            if (q) sessionStorage.setItem("farmacapital_busq", q);
          } catch { /* ignore */ }
          setPage("conseguir");
        }}
      >
        Te lo conseguimos
      </Btn>
    </div>
  );
}

export default function SolicitudCatalogoForm({ setPage, textoInicial, user, bajoVitrina = false }) {
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
          document.getElementById("conseguir-form")?.scrollIntoView({ behavior: "smooth", block: "start" });
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

  return (
    <div id="conseguir-form" style={{ maxWidth: 560, margin: "0 auto", padding: "28px 20px 48px", scrollMarginTop: 90 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
        <div
          style={{
            width: 40,
            height: 40,
            borderRadius: 12,
            background: BRAND.gradient,
            display: "grid",
            placeItems: "center",
            color: "#fff",
          }}
        >
          <Truck size={20} />
        </div>
        {bajoVitrina ? (
          <h2 style={{ margin: 0, fontSize: 22, fontWeight: 800, color: "#0f172a" }}>
            ¿No lo encuentras? Te lo conseguimos
          </h2>
        ) : (
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 800, color: "#0f172a" }}>
            ¿No lo encuentras? Te lo conseguimos
          </h1>
        )}
      </div>
      <p style={{ margin: "0 0 20px", color: "#475569", fontSize: 15, lineHeight: 1.6 }}>
        Escribe el producto. Te decimos el precio por WhatsApp y, si te late, te mandamos la liga para pagar. El envío a domicilio se cobra aparte.
      </p>

      <label style={{ display: "block", marginBottom: 14 }}>
        <span style={labelTxt}>Producto que buscas</span>
        <span style={hintTxt}>Nombre, marca y presentación. Ej. Losartan 50 mg, 30 tabletas.</span>
        <input
          className="farmacapital-field-input"
          value={texto}
          onChange={(e) => setTexto(e.target.value)}
          placeholder="Losartan 50 mg, 30 tabletas"
          autoComplete="off"
          style={inp}
        />
      </label>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 14 }}>
        <label>
          <span style={labelTxt}>¿Cuántas piezas?</span>
          <input
            className="farmacapital-field-input"
            type="number"
            min={1}
            max={999}
            value={cantidad}
            onChange={(e) => setCantidad(e.target.value)}
            inputMode="numeric"
            style={inp}
          />
        </label>
        <label>
          <span style={labelTxt}>¿Para cuándo lo necesitas?</span>
          <select className="farmacapital-field-input farmacapital-field-select" value={urgencia} onChange={(e) => setUrgencia(e.target.value)} style={inp}>
            <option value="sin_prisa">Esta semana está bien</option>
            <option value="manana">Mañana</option>
            <option value="hoy">Hoy, si se puede</option>
          </select>
        </label>
      </div>

      <label style={{ display: "block", marginBottom: 14 }}>
        <span style={labelTxt}>Tu nombre</span>
        <span style={hintTxt}>Como quieres que te hablemos.</span>
        <input className="farmacapital-field-input" value={nombre} onChange={(e) => setNombre(e.target.value)} placeholder="Iván Ibarra" autoComplete="name" style={inp} />
      </label>

      <label style={{ display: "block", marginBottom: 14 }}>
        <span style={labelTxt}>WhatsApp</span>
        <span style={hintTxt}>10 dígitos, sin 52. Ahí te escribimos el precio.</span>
        <input
          className="farmacapital-field-input"
          value={telefono}
          onChange={(e) => setTelefono(e.target.value)}
          onBlur={() => {
            const d = normalizarTelefonoPedido(telefono);
            if (d.length === 10 && d !== telefono) setTelefono(d);
          }}
          placeholder="55 1234 5678"
          inputMode="tel"
          autoComplete="tel"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 14 }}>
        <span style={labelTxt}>Correo</span>
        <span style={hintTxt}>Opcional. Para mandarte la liga de pago.</span>
        <input
          className="farmacapital-field-input"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="ivan@correo.com"
          type="email"
          autoComplete="email"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 14 }}>
        <span style={labelTxt}>Dirección de envío</span>
        <span style={hintTxt}>Opcional. Si lo quieres a domicilio: calle, número, colonia y CP.</span>
        <input
          className="farmacapital-field-input"
          value={direccion}
          onChange={(e) => setDireccion(e.target.value)}
          placeholder="Calle 12 #45, Roma Norte, 06700"
          autoComplete="street-address"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 16 }}>
        <span style={labelTxt}>Algo más que debamos saber</span>
        <span style={hintTxt}>Opcional. Marca exacta, si traes receta, sabor o talla.</span>
        <input className="farmacapital-field-input" value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Receta, marca o presentación" style={inp} />
      </label>

      <label style={{ position: "absolute", left: -9999, width: 1, height: 1, overflow: "hidden" }} aria-hidden>
        Sitio web
        <input tabIndex={-1} autoComplete="off" value={website} onChange={(e) => setWebsite(e.target.value)} />
      </label>

      <Btn col={BRAND.primary} onClick={enviar} disabled={enviando} full>
        {enviando ? "Enviando…" : "Enviar pedido"}
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
  );
}
