import { useState } from "react";
import { ArrowRight } from "lucide-react";
import { SOLICITUD_API_PATH, validarSolicitudTienda } from "../../../lib/solicitudTienda";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";
import { flyerWhatsAppFarmaciaUrl } from "../../../lib/flyerFarmaCapital";

const ENTREGAS = [
  { id: "recoger", label: "Recoger en sucursal" },
  { id: "envio", label: "Envío en CDMX (cotizado)" },
];

export function folioCotizacion(id) {
  const n = Number(id);
  if (!Number.isFinite(n) || n <= 0) return "";
  return `COT-${String(n).padStart(4, "0")}`;
}

/** Notas para el equipo: presentación y forma de entrega, sin datos de receta. */
export function notasCotizacion({ presentacion, entrega }) {
  const partes = [];
  if (String(presentacion || "").trim()) partes.push(`Presentación: ${String(presentacion).trim()}`);
  const e = ENTREGAS.find((x) => x.id === entrega);
  if (e) partes.push(`Entrega: ${e.label}`);
  partes.push("Solicitud de medicamento especializado (tienda)");
  return partes.join(" · ");
}

/**
 * Cotizar medicamento especializado (Fase C).
 * Usa el mismo camino que «Te lo conseguimos»: POST /api/solicitudes → «Lo que buscan».
 * No pide foto de receta: ese dato es sensible y va en una fase aparte con bucket privado.
 */
export default function CotizarV2({ setPage, user, textoInicial = "" }) {
  const [medicamento, setMedicamento] = useState(textoInicial || "");
  const [presentacion, setPresentacion] = useState("");
  const [cantidad, setCantidad] = useState("1");
  const [nombre, setNombre] = useState(user?.nombre || "");
  const [telefono, setTelefono] = useState(user?.telefono || "");
  const [email, setEmail] = useState(user?.email || "");
  const [entrega, setEntrega] = useState("recoger");
  const [consiente, setConsiente] = useState(false);
  const [enviando, setEnviando] = useState(false);
  const [error, setError] = useState("");
  const [folio, setFolio] = useState(null);

  const enviar = async () => {
    setError("");
    const parsed = validarSolicitudTienda({
      texto: medicamento,
      cantidad,
      nombre,
      telefono,
      email,
      notas: notasCotizacion({ presentacion, entrega }),
    });
    if (!parsed.ok) { setError(parsed.errors[0]); return; }
    setEnviando(true);
    try {
      const resp = await fetch(SOLICITUD_API_PATH, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(parsed.value),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        setError("No se pudo enviar. Escríbenos por WhatsApp y con gusto te cotizamos.");
        setEnviando(false);
        return;
      }
      setFolio(folioCotizacion(data.id) || "");
    } catch {
      setError("No se pudo enviar. Escríbenos por WhatsApp y con gusto te cotizamos.");
    }
    setEnviando(false);
  };

  if (folio !== null) {
    return (
      <div className="fc-body">
        <div className="fc-quote-ok">
          <span className="fc-state fc-in-stock">Solicitud recibida</span>
          <h1>Recibimos tu solicitud.</h1>
          <p className="fc-description">
            {folio ? <>Folio <strong className="fc-mono">{folio}</strong>. </> : null}
            Te escribimos por WhatsApp con el precio, la disponibilidad y la fecha de entrega.
          </p>
          <table className="fc-spec">
            <tbody>
              <tr><th>Medicamento</th><td>{medicamento}</td></tr>
              <tr><th>Estado</th><td>Cotizando</td></tr>
              <tr><th>Cobro</th><td>Solo si aceptas</td></tr>
            </tbody>
          </table>
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginTop: 18 }}>
            <button type="button" className="fc-primary" onClick={() => setPage?.("home")}>Volver al inicio</button>
            <a
              className="fc-secondary"
              href={flyerWhatsAppFarmaciaUrl(FARMACIA_FISCAL.telefono)}
              target="_blank"
              rel="noopener noreferrer"
            >
              Escribir por WhatsApp
            </a>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="fc-body">
      <div className="fc-page-top">
        <h1>Cotiza tu medicamento especializado</h1>
        <button type="button" className="fc-textbtn" onClick={() => setPage?.("home")}>Inicio</button>
      </div>
      <p className="fc-description">
        Te respondemos con precio, disponibilidad y fecha. No se cobra nada hasta que aceptes.
      </p>

      <form
        className="fc-form"
        onSubmit={(e) => { e.preventDefault(); if (consiente && !enviando) enviar(); }}
      >
        <label className="fc-field">
          <span>Medicamento o sustancia activa</span>
          <input
            className="farmacapital-field-input"
            value={medicamento}
            onChange={(e) => setMedicamento(e.target.value)}
            placeholder="Nombre comercial o sustancia"
            autoComplete="off"
          />
        </label>

        <div className="fc-field-row">
          <label className="fc-field">
            <span>Presentación</span>
            <input
              className="farmacapital-field-input"
              value={presentacion}
              onChange={(e) => setPresentacion(e.target.value)}
              placeholder="Ej. 150 mg, 1 frasco"
            />
          </label>
          <label className="fc-field">
            <span>Cantidad</span>
            <input className="farmacapital-field-input" inputMode="numeric" value={cantidad} onChange={(e) => setCantidad(e.target.value)} />
          </label>
        </div>

        <label className="fc-field">
          <span>Tu nombre</span>
          <input className="farmacapital-field-input" value={nombre} onChange={(e) => setNombre(e.target.value)} autoComplete="name" />
        </label>

        <label className="fc-field">
          <span>WhatsApp para enviarte la cotización</span>
          <input
            className="farmacapital-field-input"
            inputMode="tel"
            value={telefono}
            onChange={(e) => setTelefono(e.target.value)}
            placeholder="10 dígitos"
            autoComplete="tel"
          />
        </label>

        <label className="fc-field">
          <span>Correo (opcional)</span>
          <input
            className="farmacapital-field-input"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="tucorreo@ejemplo.com"
            autoComplete="email"
          />
        </label>

        <label className="fc-field">
          <span>¿Cómo lo quieres recibir?</span>
          <select
            className="fc-filter-select farmacapital-field-input farmacapital-field-select"
            style={{ margin: 0, maxWidth: "none", fontSize: 15 }}
            value={entrega}
            onChange={(e) => setEntrega(e.target.value)}
          >
            {ENTREGAS.map((e) => <option key={e.id} value={e.id}>{e.label}</option>)}
            <option disabled>Resto del país (próximamente)</option>
          </select>
        </label>

        <label className="fc-check">
          <input
            type="checkbox"
            checked={consiente}
            onChange={(e) => setConsiente(e.target.checked)}
          />
          <span>
            Acepto que FarmaCapital use estos datos solo para cotizar y surtir mi pedido, conforme al{" "}
            <button type="button" className="fc-textbtn" onClick={() => setPage?.("privacidad")}>
              aviso de privacidad
            </button>.
          </span>
        </label>

        {error ? <p className="fc-small" style={{ color: "var(--fc-red, #B42318)" }} role="alert">{error}</p> : null}

        <button type="submit" className="fc-primary" disabled={!consiente || enviando}>
          {enviando ? "Enviando…" : <>Enviar solicitud <ArrowRight aria-hidden="true" /></>}
        </button>

        <p className="fc-small">
          Los medicamentos que requieren receta se entregan solo con receta vigente. El precio queda
          sujeto a la confirmación del proveedor. No nos mandes la foto de tu receta por aquí: te la
          pedimos por WhatsApp cuando haga falta.
        </p>
      </form>
    </div>
  );
}
