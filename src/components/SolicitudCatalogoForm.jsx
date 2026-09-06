import { useEffect, useState } from "react";
import { MessageCircle, PackageSearch, Truck } from "lucide-react";
import { Btn, showToast } from "../ui";
import { BRAND } from "../constants";
import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";
import { flyerWhatsAppFarmaciaUrl } from "../lib/flyerFarmaCapital";
import { SOLICITUD_API_PATH, validarSolicitudTienda } from "../lib/solicitudTienda";

const inp = {
  width: "100%",
  marginTop: 4,
  padding: "11px 12px",
  borderRadius: 10,
  border: "1px solid #e2e8f0",
  fontSize: 15,
  boxSizing: "border-box",
  fontFamily: "inherit",
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
        ¿No lo encuentras en el catálogo? Te lo conseguimos. El envío a domicilio tiene costo. Te escribimos por WhatsApp o correo con el precio y la liga de pago.
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

export default function SolicitudCatalogoForm({ setPage, textoInicial, user }) {
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
    <div style={{ maxWidth: 560, margin: "0 auto", padding: "28px 20px 48px" }}>
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
        <h1 style={{ margin: 0, fontSize: 24, fontWeight: 800, color: "#0f172a" }}>
          ¿No lo encuentras? Te lo conseguimos
        </h1>
      </div>
      <p style={{ margin: "0 0 20px", color: "#475569", fontSize: 14, lineHeight: 1.6 }}>
        Anota el medicamento. Lo vemos en mayorista, te pasamos el costo por WhatsApp o correo y, si te late, pagas con la liga. El envío a domicilio tiene costo.
      </p>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>¿Qué buscas?</span>
        <input
          value={texto}
          onChange={(e) => setTexto(e.target.value)}
          placeholder="Ej. Losartan 50 mg, 30 tabletas"
          style={inp}
        />
      </label>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 12 }}>
        <label>
          <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>Cantidad</span>
          <input
            type="number"
            min={1}
            max={999}
            value={cantidad}
            onChange={(e) => setCantidad(e.target.value)}
            style={inp}
          />
        </label>
        <label>
          <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>¿Para cuándo?</span>
          <select value={urgencia} onChange={(e) => setUrgencia(e.target.value)} style={inp}>
            <option value="sin_prisa">Sin prisa</option>
            <option value="manana">Mañana</option>
            <option value="hoy">Hoy</option>
          </select>
        </label>
      </div>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>Tu nombre</span>
        <input value={nombre} onChange={(e) => setNombre(e.target.value)} placeholder="Cómo te llamas" style={inp} />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>WhatsApp (10 dígitos)</span>
        <input
          value={telefono}
          onChange={(e) => setTelefono(e.target.value)}
          placeholder="55 1234 5678"
          inputMode="tel"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>Correo (opcional)</span>
        <input
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="para mandarte la liga de pago"
          type="email"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>Dirección de envío (opcional)</span>
        <input
          value={direccion}
          onChange={(e) => setDireccion(e.target.value)}
          placeholder="Calle, número, colonia, CP"
          style={inp}
        />
      </label>

      <label style={{ display: "block", marginBottom: 12 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#475569" }}>Notas (marca, receta, presentación)</span>
        <input value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Opcional" style={inp} />
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
  );
}
