import { useCallback, useEffect, useState } from "react";
import {
  ArrowLeft,
  Calculator,
  ChevronDown,
  ChevronRight,
  ExternalLink,
  Mail,
  MessageCircle,
  Plus,
  Printer,
  RefreshCw,
  Search,
  Trash2,
} from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { FARMACIA_FISCAL } from "./constants/farmaciaFiscal";
import { urlImagenPublicaTienda } from "./lib/imagenCompetencia";
import { ETIQUETA_ENCARGOS } from "./lib/pedidosMostrador";
import { supabase } from "./supabase";
import { Inp, showToast } from "./ui";
import {
  FILTROS_COTIZACION,
  FUENTES_ATAJO_COTIZACION,
  ORIGENES_COTIZACION,
  TIPOS_MARGEN_COTIZACION,
  URGENCIAS_COTIZACION,
  buildCotizacionWhatsAppCliente,
  escaparHtmlCotizacion,
  etiquetaEstadoCotizacion,
  etiquetaEstadoItemCotizacion,
  etiquetaLugarCotizacion,
  etiquetaOrigenCotizacion,
  etiquetaUrgenciaCotizacion,
  folioCotizacion,
  fmtDineroCotiz,
  haceCuanto,
  importeDocumentoCliente,
  itemCotizacionValido,
  itemConfirmadoDocumento,
  numerosLineaCotizacion,
  puedeGuardarCotizacion,
  siguientesEstadosCotizacion,
  siguientesEstadosItemCotizacion,
  takeCotizacionAbierta,
  totalDocumentoCliente,
  totalesCotizacion,
  vigenciaDefaultTexto,
  vistaNumerosProducto,
} from "./lib/cotizaciones";

const C = C_LIGHT;

const fieldStyle = {
  background: "#ffffff",
  color: C.text,
  colorScheme: "light",
  WebkitTextFillColor: C.text,
  caretColor: C.text,
};

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

function asList(data) {
  if (Array.isArray(data)) return data;
  return [];
}

function sqlFalta(msg) {
  return /admin_listar_cotizaciones|admin_crear_cotizacion|admin_obtener_cotizacion|schema cache|does not exist/i.test(
    String(msg || ""),
  );
}

function avisoRpcCotizacion(error) {
  const msg = String(error?.message || "");
  if (/admin_ligar_producto_cotizacion|admin_buscar_productos_cotizacion|schema cache|does not exist/i.test(msg)) {
    return "Falta aplicar sql/patch_cotizaciones_producto_20260926.sql en Supabase.";
  }
  return msg || "No se pudo guardar";
}

function chip(bg, color, text) {
  return (
    <span
      style={{
        display: "inline-block",
        padding: "2px 8px",
        borderRadius: 999,
        background: bg,
        color,
        fontSize: 11,
        fontWeight: 700,
        whiteSpace: "nowrap",
      }}
    >
      {text}
    </span>
  );
}

function colorEstado(estado) {
  switch (estado) {
    case "nueva":
      return { bg: C.cardDark, color: C.textMid };
    case "buscando":
    case "pedir":
      return { bg: C.blueDim, color: C.blue };
    case "lista":
    case "elegido":
      return { bg: C.tealDim, color: C.teal };
    case "pedida":
    case "pedido":
      return { bg: C.purpleDim, color: C.purple };
    case "cerrada":
    case "llego":
      return { bg: C.greenDim, color: C.greenDark };
    case "perdida":
    case "no_se_consigue":
      return { bg: C.redDim, color: C.red };
    default:
      return { bg: C.amberDim, color: C.amber };
  }
}

function colorUrgencia(u) {
  if (u === "hoy") return { bg: C.redDim, color: C.red };
  if (u === "manana") return { bg: C.amberDim, color: C.amber };
  return { bg: C.cardDark, color: C.textMid };
}

function FieldLabel({ children }) {
  return (
    <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700, display: "block", marginBottom: 4 }}>
      {children}
    </span>
  );
}

function FieldSelect({ value, onChange, children, style }) {
  return (
    <select
      className="farmacapital-field-select"
      value={value}
      onChange={onChange}
      style={{
        width: "100%",
        padding: "10px 12px",
        borderRadius: 8,
        border: `1px solid ${C.border}`,
        fontSize: 14,
        boxSizing: "border-box",
        minHeight: 44,
        ...fieldStyle,
        ...style,
      }}
    >
      {children}
    </select>
  );
}

function FieldArea({ value, onChange, placeholder, rows = 3 }) {
  return (
    <textarea
      className="farmacapital-field-input"
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      rows={rows}
      style={{
        width: "100%",
        padding: "10px 12px",
        borderRadius: 8,
        border: `1px solid ${C.border}`,
        fontSize: 14,
        boxSizing: "border-box",
        resize: "vertical",
        fontFamily: "inherit",
        ...fieldStyle,
      }}
    />
  );
}

function Btn({ children, onClick, disabled, primary, danger, type = "button" }) {
  return (
    <button
      type={type}
      disabled={disabled}
      onClick={onClick}
      style={{
        padding: "8px 12px",
        borderRadius: 8,
        border: primary || danger ? "none" : `1px solid ${C.border}`,
        background: disabled
          ? C.border
          : danger
            ? C.red
            : primary
              ? BRAND.gradient
              : C.card,
        color: primary || danger ? "#fff" : C.text,
        fontWeight: 700,
        fontSize: 12,
        cursor: disabled ? "not-allowed" : "pointer",
        display: "inline-flex",
        alignItems: "center",
        gap: 6,
        opacity: disabled ? 0.55 : 1,
      }}
    >
      {children}
    </button>
  );
}

function lineaAltaVacia() {
  return { texto: "", cantidad: 1, tipo_margen: "marca" };
}

/**
 * Documento para el cliente: folio, items con precio de venta (nunca costo/margen),
 * vigencia y datos fiscales. Se abre en una pestaña aparte (igual que la receta médica
 * de Consultorio) para que Cmd/Ctrl+P → Guardar como PDF salga limpio, sin el admin
 * alrededor.
 */
function imprimirDocumentoCotizacion(detalle, vigenciaTexto) {
  const items = Array.isArray(detalle.items) ? detalle.items : [];
  const totalCliente = totalDocumentoCliente(items);
  const esc = escaparHtmlCotizacion;
  const filasHtml = items
    .map((it) => {
      const confirmado = itemConfirmadoDocumento(it);
      const importe = importeDocumentoCliente(it);
      return `
      <tr>
        <td style="padding:10px 12px;border-bottom:1px solid #e2e8f0;">
          ${esc(it.texto)}
          ${!confirmado ? '<div style="font-size:11px;color:#B45309;font-weight:700;margin-top:2px;">Por confirmar</div>' : ""}
        </td>
        <td style="padding:10px 12px;border-bottom:1px solid #e2e8f0;text-align:center;">${esc(it.cantidad || 1)}</td>
        <td style="padding:10px 12px;border-bottom:1px solid #e2e8f0;text-align:right;font-weight:700;">
          ${importe != null ? esc(fmtDineroCotiz(importe)) : "Pendiente"}
        </td>
      </tr>`;
    })
    .join("");

  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <title>${esc(detalle.folio || folioCotizacion(detalle.id))} — FarmaCapital</title>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { font-family: Arial, sans-serif; font-size: 13px; color: #001534; padding: 32px; max-width: 700px; margin: 0 auto; }
    .header { display:flex; justify-content:space-between; align-items:flex-start; border-bottom: 2px solid #001534; padding-bottom: 16px; margin-bottom: 20px; }
    .marca { font-size:20px; font-weight:800; color:#001534; }
    .folio { text-align:right; font-size:12px; color:#475569; }
    .cliente { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:20px; padding:14px 16px; border:1px solid #e2e8f0; border-radius:8px; }
    .field label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; }
    .field p { font-size:13px; color:#0f172a; font-weight:600; margin-top:2px; }
    h4 { color:#001534; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px; }
    table { width:100%; border-collapse:collapse; margin-bottom:16px; }
    thead tr { background:#f8fafc; }
    th { padding:8px 12px; text-align:left; font-size:11px; color:#475569; font-weight:700; border-bottom:1px solid #e2e8f0; }
    .total-row td { padding:12px; font-weight:800; font-size:16px; border-top:2px solid #001534; }
    .vigencia { background:#EAF0FB; border-left:4px solid #054ABC; border-radius:8px; padding:12px 16px; margin-bottom:20px; font-size:13px; }
    .footer { text-align:center; font-size:10px; color:#94a3b8; border-top:1px solid #e2e8f0; padding-top:12px; margin-top:24px; }
    @media print { body { padding:16px; } }
  </style>
</head>
<body>
  <div class="header">
    <div class="marca">FarmaCapital</div>
    <div class="folio">
      <div><strong>Cotización:</strong> ${esc(detalle.folio || folioCotizacion(detalle.id))}</div>
      <div>${new Date().toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" })}</div>
    </div>
  </div>

  <div class="cliente">
    <div class="field"><label>Cliente</label><p>${esc(detalle.cliente_nombre || "—")}</p></div>
    <div class="field"><label>Contacto</label><p>${esc(detalle.cliente_telefono || detalle.cliente_email || "—")}</p></div>
    ${detalle.direccion ? `<div class="field" style="grid-column:1/-1"><label>Entrega</label><p>${esc(detalle.direccion)}</p></div>` : ""}
  </div>

  <h4>Detalle</h4>
  <table>
    <thead><tr><th>Producto</th><th style="text-align:center;">Cant.</th><th style="text-align:right;">Importe</th></tr></thead>
    <tbody>${filasHtml}</tbody>
    <tfoot><tr class="total-row"><td colspan="2">Total</td><td style="text-align:right;">${esc(fmtDineroCotiz(totalCliente))}</td></tr></tfoot>
  </table>

  ${vigenciaTexto ? `<div class="vigencia"><strong>Precio válido hasta ${esc(vigenciaTexto)}.</strong> Si vence, te lo recotizamos sin costo.</div>` : ""}

  <div class="footer">
    Este documento es una cotización, no una factura fiscal.<br>
    ${FARMACIA_FISCAL.razon_social} · RFC ${FARMACIA_FISCAL.rfc}<br>
    ${FARMACIA_FISCAL.direccion_comercial}<br>
    farmacapital.mx · WhatsApp ${FARMACIA_FISCAL.telefono_display}
  </div>
</body>
</html>`;

  const win = window.open("", "_blank", "width=750,height=900");
  if (!win) {
    showToast("El navegador bloqueó la ventana. Permite pop-ups para imprimir.", "warning");
    return;
  }
  win.document.write(html);
  win.document.close();
  win.focus();
  setTimeout(() => win.print(), 500);
}

export default function CotizacionesModule({ usuario }) {
  const [filtro, setFiltro] = useState("abiertas");
  const [origenFiltro, setOrigenFiltro] = useState("");
  const [lista, setLista] = useState([]);
  const [loading, setLoading] = useState(true);
  const [formOpen, setFormOpen] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [fichaId, setFichaId] = useState(null);
  const [detalle, setDetalle] = useState(null);
  const [cargandoFicha, setCargandoFicha] = useState(false);

  const [cliNombre, setCliNombre] = useState("");
  const [cliTel, setCliTel] = useState("");
  const [cliEmail, setCliEmail] = useState("");
  const [cliDir, setCliDir] = useState("");
  const [origen, setOrigen] = useState("admin");
  const [urgencia, setUrgencia] = useState("sin_prisa");
  const [paraCuando, setParaCuando] = useState("");
  const [notas, setNotas] = useState("");
  const [lineas, setLineas] = useState([lineaAltaVacia()]);

  const cargarLista = useCallback(async () => {
    const tok = sessionTok();
    if (!tok) {
      showToast("Sesión expirada. Vuelve a entrar.", "error");
      return;
    }
    setLoading(true);
    const { data, error } = await supabase.rpc("admin_listar_cotizaciones", {
      p_session_token: tok,
      p_estado: filtro === "" ? null : filtro,
      p_origen: origenFiltro || null,
      p_limite: 150,
    });
    if (error) {
      console.warn("[Cotizaciones]", error.message);
      showToast(
        sqlFalta(error.message)
          ? "Falta aplicar sql/patch_cotizaciones_20260921.sql en Supabase."
          : "No se pudo cargar la lista",
        "error",
      );
      setLista([]);
    } else {
      setLista(asList(data));
    }
    setLoading(false);
  }, [filtro, origenFiltro]);

  const cargarFicha = useCallback(async (id) => {
    const tok = sessionTok();
    if (!tok || !id) return;
    setCargandoFicha(true);
    const { data, error } = await supabase.rpc("admin_obtener_cotizacion", {
      p_session_token: tok,
      p_id: id,
    });
    setCargandoFicha(false);
    if (error) {
      showToast(error.message || "No se pudo abrir la cotización", "error");
      return;
    }
    setDetalle(data || null);
    setFichaId(id);
  }, []);

  useEffect(() => {
    const openId = takeCotizacionAbierta();
    if (openId) {
      cargarFicha(openId);
    }
  }, [cargarFicha]);

  useEffect(() => {
    if (!fichaId) cargarLista();
  }, [cargarLista, fichaId]);

  const resetAlta = () => {
    setCliNombre("");
    setCliTel("");
    setCliEmail("");
    setCliDir("");
    setOrigen("admin");
    setUrgencia("sin_prisa");
    setParaCuando("");
    setNotas("");
    setLineas([lineaAltaVacia()]);
  };

  const crear = async () => {
    const items = lineas
      .filter((it) => itemCotizacionValido(it))
      .map((it) => ({
        texto: it.texto,
        cantidad: Number(it.cantidad) || 1,
        tipo_margen: it.tipo_margen === "generico" ? "generico" : "marca",
      }));
    if (!puedeGuardarCotizacion({ clienteNombre: cliNombre, clienteTelefono: cliTel, items })) {
      showToast("Pon quién pide (nombre o teléfono) y al menos un producto.", "warning");
      return;
    }
    const tok = sessionTok();
    if (!tok) return;
    setGuardando(true);
    const { data, error } = await supabase.rpc("admin_crear_cotizacion", {
      p_session_token: tok,
      p_cliente_nombre: cliNombre.trim() || null,
      p_cliente_telefono: cliTel.trim() || null,
      p_cliente_email: cliEmail.trim() || null,
      p_direccion: cliDir.trim() || null,
      p_origen: origen,
      p_para_cuando: paraCuando || null,
      p_urgencia: urgencia,
      p_notas: notas.trim() || null,
      p_items: items,
    });
    setGuardando(false);
    if (error) {
      showToast(
        sqlFalta(error.message)
          ? "Falta aplicar sql/patch_cotizaciones_20260921.sql en Supabase."
          : error.message || "No se pudo crear",
        "error",
      );
      return;
    }
    showToast("Cotización creada", "success");
    resetAlta();
    setFormOpen(false);
    if (data?.id) {
      setDetalle(data);
      setFichaId(data.id);
    } else {
      cargarLista();
    }
  };

  const aplicarDetalle = (data) => {
    if (data?.id) setDetalle(data);
  };

  const rpcFicha = async (nombre, args, okMsg) => {
    const tok = sessionTok();
    if (!tok) return;
    const { data, error } = await supabase.rpc(nombre, { p_session_token: tok, ...args });
    if (error) {
      showToast(avisoRpcCotizacion(error), "error");
      return null;
    }
    aplicarDetalle(data);
    if (okMsg) showToast(okMsg, "success");
    return data ?? true;
  };

  if (fichaId && detalle) {
    return (
      <FichaCotizacion
        detalle={detalle}
        loading={cargandoFicha}
        onVolver={() => {
          setFichaId(null);
          setDetalle(null);
          cargarLista();
        }}
        onRefresh={() => cargarFicha(fichaId)}
        rpc={rpcFicha}
      />
    );
  }

  const vacia = !loading && lista.length === 0;

  return (
    <div style={{ padding: "18px 16px 40px", maxWidth: 960, margin: "0 auto" }}>
      <div
        style={{
          display: "flex",
          alignItems: "flex-start",
          justifyContent: "space-between",
          gap: 12,
          marginBottom: 16,
          flexWrap: "wrap",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
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
            <Calculator size={20} />
          </div>
          <div>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, color: C.text }}>Cotizaciones</h1>
            <p style={{ margin: "2px 0 0", color: C.textMid, fontSize: 13 }}>
              Oficina del dueño: quién pide, dónde lo encontraste, a cuánto lo compras y cuánto se gana.
              El piso sigue en «{ETIQUETA_ENCARGOS}».
            </p>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <Btn onClick={() => cargarLista()}>
            <RefreshCw size={14} /> Actualizar
          </Btn>
          <Btn primary onClick={() => setFormOpen((v) => !v)}>
            <Plus size={14} /> {formOpen ? "Ocultar alta" : "Nueva cotización"}
          </Btn>
        </div>
      </div>

      {formOpen && (
        <section
          style={{
            background: C.card,
            border: `1px solid ${C.border}`,
            borderRadius: 14,
            padding: 16,
            marginBottom: 16,
          }}
        >
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 12 }}>
            NUEVA COTIZACIÓN · {usuario?.nombre || "sesión"}
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 10 }}>
            <label>
              <FieldLabel>Quién pide</FieldLabel>
              <Inp value={cliNombre} onChange={(e) => setCliNombre(e.target.value)} placeholder="Nombre" />
            </label>
            <label>
              <FieldLabel>Teléfono</FieldLabel>
              <Inp value={cliTel} onChange={(e) => setCliTel(e.target.value)} placeholder="10 dígitos" inputMode="tel" />
            </label>
            <label>
              <FieldLabel>Correo</FieldLabel>
              <Inp value={cliEmail} onChange={(e) => setCliEmail(e.target.value)} placeholder="opcional" type="email" />
            </label>
            <label>
              <FieldLabel>Origen</FieldLabel>
              <FieldSelect value={origen} onChange={(e) => setOrigen(e.target.value)}>
                {ORIGENES_COTIZACION.map((o) => (
                  <option key={o.id} value={o.id}>{o.label}</option>
                ))}
              </FieldSelect>
            </label>
            <label>
              <FieldLabel>Urgencia</FieldLabel>
              <FieldSelect value={urgencia} onChange={(e) => setUrgencia(e.target.value)}>
                {URGENCIAS_COTIZACION.map((u) => (
                  <option key={u.id} value={u.id}>{u.label}</option>
                ))}
              </FieldSelect>
            </label>
            <label>
              <FieldLabel>Para cuándo</FieldLabel>
              <Inp type="date" value={paraCuando} onChange={(e) => setParaCuando(e.target.value)} />
            </label>
          </div>
          <label style={{ display: "block", marginTop: 10 }}>
            <FieldLabel>Dirección / entrega</FieldLabel>
            <Inp value={cliDir} onChange={(e) => setCliDir(e.target.value)} placeholder="opcional" />
          </label>
          <label style={{ display: "block", marginTop: 10 }}>
            <FieldLabel>Notas</FieldLabel>
            <FieldArea value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Contexto, receta, marca preferida…" />
          </label>

          <div style={{ marginTop: 14, color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2 }}>
            QUÉ PIDE
          </div>
          {lineas.map((ln, i) => (
            <div
              key={i}
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
                gap: 8,
                marginTop: 8,
                alignItems: "end",
              }}
            >
              <label>
                {i === 0 ? <FieldLabel>Producto</FieldLabel> : null}
                <Inp
                  value={ln.texto}
                  onChange={(e) => {
                    const next = [...lineas];
                    next[i] = { ...ln, texto: e.target.value };
                    setLineas(next);
                  }}
                  placeholder="Nombre de mostrador (no el código del PDF)"
                />
              </label>
              <label>
                {i === 0 ? <FieldLabel>Cant.</FieldLabel> : null}
                <Inp
                  type="number"
                  min={1}
                  max={999}
                  value={ln.cantidad}
                  onChange={(e) => {
                    const next = [...lineas];
                    next[i] = { ...ln, cantidad: e.target.value };
                    setLineas(next);
                  }}
                />
              </label>
              <label>
                {i === 0 ? <FieldLabel>Recargo</FieldLabel> : null}
                <FieldSelect
                  value={ln.tipo_margen}
                  onChange={(e) => {
                    const next = [...lineas];
                    next[i] = { ...ln, tipo_margen: e.target.value };
                    setLineas(next);
                  }}
                >
                  {TIPOS_MARGEN_COTIZACION.map((t) => (
                    <option key={t.id} value={t.id}>{t.label}</option>
                  ))}
                </FieldSelect>
              </label>
              <Btn
                danger={lineas.length > 1}
                disabled={lineas.length <= 1}
                onClick={() => setLineas(lineas.filter((_, j) => j !== i))}
              >
                <Trash2 size={14} />
              </Btn>
            </div>
          ))}
          <div style={{ marginTop: 10, display: "flex", gap: 8, flexWrap: "wrap" }}>
            <Btn onClick={() => setLineas([...lineas, lineaAltaVacia()])}>
              <Plus size={14} /> Otro producto
            </Btn>
            <Btn primary disabled={guardando} onClick={crear}>
              Crear cotización
            </Btn>
          </div>
        </section>
      )}

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
        {FILTROS_COTIZACION.map((f) => (
          <button
            key={f.id || "todas"}
            type="button"
            onClick={() => setFiltro(f.id)}
            style={{
              padding: "6px 10px",
              borderRadius: 999,
              border: `1px solid ${filtro === f.id ? C.blue : C.border}`,
              background: filtro === f.id ? C.blueDim : C.card,
              color: filtro === f.id ? C.blue : C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {f.label}
          </button>
        ))}
        <FieldSelect
          value={origenFiltro}
          onChange={(e) => setOrigenFiltro(e.target.value)}
          style={{ width: "auto", minWidth: 160, minHeight: 34, padding: "4px 10px" }}
        >
          <option value="">Todo origen</option>
          {ORIGENES_COTIZACION.map((o) => (
            <option key={o.id} value={o.id}>{o.label}</option>
          ))}
        </FieldSelect>
      </div>

      {loading && <div style={{ color: C.textMid, fontSize: 13 }}>Cargando…</div>}
      {vacia && (
        <div style={{ textAlign: "center", color: C.textMid, padding: 28 }}>
          No hay cotizaciones con este filtro.
          <div style={{ fontSize: 12, marginTop: 6 }}>
            Crea una o ábrela desde «{ETIQUETA_ENCARGOS}» con Abrir cotización.
          </div>
        </div>
      )}

      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {lista.map((c) => {
          const est = colorEstado(c.estado);
          const urg = colorUrgencia(c.urgencia);
          const tot = c.totales || {};
          return (
            <article
              key={c.id}
              style={{
                background: C.card,
                border: `1px solid ${C.border}`,
                borderRadius: 12,
                padding: "12px 14px",
                cursor: "pointer",
              }}
              onClick={() => cargarFicha(c.id)}
            >
              <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap" }}>
                <div style={{ flex: 1, minWidth: 180 }}>
                  <div style={{ fontWeight: 800, fontSize: 15, color: C.text, marginBottom: 4 }}>
                    {folioCotizacion(c.id)} · {c.cliente_nombre || "Sin nombre"}
                  </div>
                  <div style={{ fontSize: 13, color: C.text, marginBottom: 6 }}>
                    {c.resumen || "Sin productos"}
                  </div>
                  <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                    {chip(est.bg, est.color, etiquetaEstadoCotizacion(c.estado))}
                    {chip(urg.bg, urg.color, etiquetaUrgenciaCotizacion(c.urgencia))}
                    {chip(C.cardDark, C.textMid, etiquetaOrigenCotizacion(c.origen))}
                    {c.solicitud_id ? chip(C.tealDim, C.teal, `LQ-${c.solicitud_id}`) : null}
                  </div>
                  <div style={{ fontSize: 12, color: C.textMid, marginTop: 6 }}>
                    {haceCuanto(c.created_at)}
                    {c.para_cuando ? ` · para ${c.para_cuando}` : ""}
                    {c.creado_por_nombre ? ` · ${c.creado_por_nombre}` : ""}
                  </div>
                </div>
                <div style={{ textAlign: "right", minWidth: 120 }}>
                  {tot.ganancia != null ? (
                    <>
                      <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Ganancia</div>
                      <div style={{ fontWeight: 800, color: C.greenDark }}>{fmtDineroCotiz(tot.ganancia)}</div>
                      <div style={{ fontSize: 11, color: C.textDim }}>
                        {fmtDineroCotiz(tot.costo)} → {fmtDineroCotiz(tot.venta)}
                      </div>
                    </>
                  ) : (
                    <div style={{ fontSize: 12, color: C.textDim }}>Sin precios aún</div>
                  )}
                </div>
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

/**
 * Documento para el cliente: solo lo que él debe ver (producto, cantidad, precio de
 * venta, total, vigencia). Nunca costo_elegido ni fuentes -- eso es interno.
 * Imprimir abre una pestaña aparte; WhatsApp y correo reusan los mismos datos de
 * contacto que ya tiene la cotización.
 */
function PanelDocumentoCotizacion({ detalle, rpc }) {
  const items = Array.isArray(detalle.items) ? detalle.items : [];
  const totalCliente = totalDocumentoCliente(items);
  const [vigencia, setVigencia] = useState(detalle.vigencia_texto || vigenciaDefaultTexto());
  const [guardandoVigencia, setGuardandoVigencia] = useState(false);
  const [enviandoCorreo, setEnviandoCorreo] = useState(false);

  useEffect(() => {
    setVigencia(detalle.vigencia_texto || vigenciaDefaultTexto());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [detalle.id, detalle.vigencia_texto]);

  const guardarVigencia = async () => {
    setGuardandoVigencia(true);
    await rpc(
      "admin_actualizar_cotizacion",
      { p_id: detalle.id, p_vigencia_texto: vigencia.trim() || null },
      "Vigencia guardada",
    );
    setGuardandoVigencia(false);
  };

  const marcarEnviada = (canal) => rpc("admin_marcar_cotizacion_enviada", { p_id: detalle.id, p_canal: canal });

  const enviarWhatsApp = () => {
    const link = buildCotizacionWhatsAppCliente({
      telefono: detalle.cliente_telefono,
      nombre: detalle.cliente_nombre,
      folio: detalle.folio || folioCotizacion(detalle.id),
      total: totalCliente,
      vigencia,
    });
    if (!link) {
      showToast("Falta el teléfono del cliente", "warning");
      return;
    }
    window.open(link, "_blank", "noopener,noreferrer");
    marcarEnviada("whatsapp");
  };

  const enviarCorreo = async () => {
    if (!detalle.cliente_email) {
      showToast("Falta el correo del cliente", "warning");
      return;
    }
    const tok = sessionTok();
    if (!tok) return;
    setEnviandoCorreo(true);
    try {
      const resp = await fetch("/api/notifications/send?type=cotizacion", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          employeeSessionToken: tok,
          cotizacion: { ...detalle, vigencia_texto: vigencia },
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        showToast(
          data?.error === "missing_email" ? "El cliente no tiene correo válido" : "No se pudo enviar el correo",
          "error",
        );
        return;
      }
      showToast(`Enviado a ${data.to}`, "success");
      marcarEnviada("correo");
    } catch {
      showToast("No se pudo enviar el correo", "error");
    } finally {
      setEnviandoCorreo(false);
    }
  };

  return (
    <section
      style={{
        background: C.card,
        border: `1px solid ${C.border}`,
        borderRadius: 14,
        padding: 16,
        marginBottom: 14,
      }}
    >
      <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 12 }}>
        DOCUMENTO PARA EL CLIENTE · sin costos ni márgenes
      </div>

      <div style={{ overflowX: "auto", marginBottom: 10 }}>
        <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: "left", color: C.textMid, fontSize: 11 }}>
              <th style={{ padding: "6px 8px" }}>Producto</th>
              <th style={{ padding: "6px 8px" }}>Cant.</th>
              <th style={{ padding: "6px 8px" }}>Importe</th>
            </tr>
          </thead>
          <tbody>
            {items.map((it) => {
              const confirmado = itemConfirmadoDocumento(it);
              const importe = importeDocumentoCliente(it);
              return (
                <tr key={it.id}>
                  <td style={{ padding: "8px" }}>
                    {it.texto}
                    {!confirmado ? (
                      <div style={{ fontSize: 11, color: C.amber, fontWeight: 700 }}>Por confirmar</div>
                    ) : null}
                  </td>
                  <td style={{ padding: "8px" }}>{it.cantidad || 1}</td>
                  <td style={{ padding: "8px", fontWeight: 700 }}>
                    {importe != null ? fmtDineroCotiz(importe) : "Pendiente"}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <div style={{ textAlign: "right", fontWeight: 800, fontSize: 15, color: C.text, marginBottom: 14 }}>
        Total: {fmtDineroCotiz(totalCliente)}
      </div>

      <label style={{ display: "block", marginBottom: 12, maxWidth: 360 }}>
        <FieldLabel>Precio válido hasta</FieldLabel>
        <div style={{ display: "flex", gap: 8 }}>
          <Inp value={vigencia} onChange={(e) => setVigencia(e.target.value)} placeholder="ej. 2 de octubre de 2026" />
          <Btn onClick={guardarVigencia} disabled={guardandoVigencia}>
            Guardar
          </Btn>
        </div>
      </label>

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        <Btn primary onClick={() => imprimirDocumentoCotizacion(detalle, vigencia)}>
          <Printer size={14} /> Imprimir / PDF
        </Btn>
        <Btn onClick={enviarWhatsApp} disabled={!detalle.cliente_telefono}>
          <MessageCircle size={14} /> WhatsApp
        </Btn>
        <Btn onClick={enviarCorreo} disabled={!detalle.cliente_email || enviandoCorreo}>
          <Mail size={14} /> {enviandoCorreo ? "Enviando…" : "Correo"}
        </Btn>
      </div>

      {detalle.enviada_at ? (
        <div style={{ marginTop: 10, fontSize: 12, color: C.textMid }}>
          Enviada {haceCuanto(detalle.enviada_at)} por {detalle.enviada_canal || "—"}.
        </div>
      ) : null}
    </section>
  );
}

function FichaCotizacion({ detalle, loading, onVolver, onRefresh, rpc }) {
  const [nuevoTexto, setNuevoTexto] = useState("");
  const [nuevoCant, setNuevoCant] = useState(1);
  const [nuevoTipo, setNuevoTipo] = useState("marca");
  const [mostrarDocumento, setMostrarDocumento] = useState(false);
  const items = Array.isArray(detalle.items) ? detalle.items : [];
  const tot = totalesCotizacion(items);
  const est = colorEstado(detalle.estado);
  const nextProyecto = siguientesEstadosCotizacion(detalle.estado);

  return (
    <div style={{ padding: "18px 16px 48px", maxWidth: 980, margin: "0 auto" }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
        <Btn onClick={onVolver}>
          <ArrowLeft size={14} /> Lista
        </Btn>
        <div style={{ display: "flex", gap: 8 }}>
          <Btn primary={mostrarDocumento} onClick={() => setMostrarDocumento((v) => !v)}>
            <Printer size={14} /> {mostrarDocumento ? "Ocultar documento" : "Documento para cliente"}
          </Btn>
          <Btn onClick={onRefresh}>
            <RefreshCw size={14} /> Actualizar
          </Btn>
        </div>
      </div>

      <header
        style={{
          background: C.card,
          border: `1px solid ${C.border}`,
          borderRadius: 14,
          padding: 16,
          marginBottom: 14,
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap" }}>
          <div>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, color: C.text }}>
              {detalle.folio || folioCotizacion(detalle.id)} · {detalle.cliente_nombre || "Sin nombre"}
            </h1>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 8 }}>
              {chip(est.bg, est.color, etiquetaEstadoCotizacion(detalle.estado))}
              {chip(colorUrgencia(detalle.urgencia).bg, colorUrgencia(detalle.urgencia).color, etiquetaUrgenciaCotizacion(detalle.urgencia))}
              {chip(C.cardDark, C.textMid, etiquetaOrigenCotizacion(detalle.origen))}
              {detalle.solicitud_id ? chip(C.tealDim, C.teal, `${ETIQUETA_ENCARGOS} LQ-${detalle.solicitud_id}`) : null}
            </div>
            <div style={{ fontSize: 13, color: C.text, marginTop: 8 }}>
              {detalle.cliente_telefono || "Sin teléfono"}
              {detalle.cliente_email ? ` · ${detalle.cliente_email}` : ""}
            </div>
            {detalle.direccion ? (
              <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>{detalle.direccion}</div>
            ) : null}
            {detalle.para_cuando ? (
              <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>Para el {detalle.para_cuando}</div>
            ) : null}
            {detalle.notas ? (
              <div style={{ fontSize: 12, color: C.text, marginTop: 6 }}>Nota: {detalle.notas}</div>
            ) : null}
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Proyecto</div>
            <div style={{ fontWeight: 800, color: C.text }}>{fmtDineroCotiz(tot.costo)} costo</div>
            <div style={{ fontWeight: 800, color: C.text }}>{fmtDineroCotiz(tot.venta)} venta</div>
            <div style={{ fontWeight: 800, color: C.greenDark }}>{fmtDineroCotiz(tot.ganancia)} ganancia</div>
          </div>
        </div>
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 12 }}>
          {nextProyecto.map((e) => (
            <Btn
              key={e}
              onClick={() => rpc("admin_actualizar_cotizacion", { p_id: detalle.id, p_estado: e }, `Marcado: ${etiquetaEstadoCotizacion(e)}`)}
            >
              → {etiquetaEstadoCotizacion(e)}
            </Btn>
          ))}
        </div>
      </header>

      {mostrarDocumento && <PanelDocumentoCotizacion detalle={detalle} rpc={rpc} />}

      {loading && <div style={{ color: C.textMid, fontSize: 13, marginBottom: 10 }}>Actualizando…</div>}

      {items.map((item) => (
        <ItemCotizacion key={item.id} item={item} rpc={rpc} />
      ))}

      <section
        style={{
          background: C.card,
          border: `1px solid ${C.border}`,
          borderRadius: 14,
          padding: 14,
          marginTop: 8,
        }}
      >
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 10 }}>
          AGREGAR PRODUCTO
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))", gap: 8, alignItems: "end" }}>
          <label>
            <FieldLabel>Producto</FieldLabel>
            <Inp value={nuevoTexto} onChange={(e) => setNuevoTexto(e.target.value)} placeholder="Nombre de mostrador" />
          </label>
          <label>
            <FieldLabel>Cant.</FieldLabel>
            <Inp type="number" min={1} max={999} value={nuevoCant} onChange={(e) => setNuevoCant(e.target.value)} />
          </label>
          <label>
            <FieldLabel>Recargo</FieldLabel>
            <FieldSelect value={nuevoTipo} onChange={(e) => setNuevoTipo(e.target.value)}>
              {TIPOS_MARGEN_COTIZACION.map((t) => (
                <option key={t.id} value={t.id}>{t.label}</option>
              ))}
            </FieldSelect>
          </label>
          <Btn
            primary
            onClick={async () => {
              if (!itemCotizacionValido({ texto: nuevoTexto, cantidad: nuevoCant })) {
                showToast("Escribe el producto", "warning");
                return;
              }
              const ok = await rpc("admin_agregar_cotizacion_item", {
                p_cotizacion_id: detalle.id,
                p_texto: nuevoTexto,
                p_cantidad: Number(nuevoCant) || 1,
                p_tipo_margen: nuevoTipo,
              }, "Producto agregado");
              if (ok) {
                setNuevoTexto("");
                setNuevoCant(1);
              }
            }}
          >
            <Plus size={14} /> Agregar
          </Btn>
        </div>
      </section>
    </div>
  );
}

function ItemCotizacion({ item, rpc }) {
  const [precioEdit, setPrecioEdit] = useState(
    item.precio_venta != null ? String(item.precio_venta) : "",
  );
  const [lugarClave, setLugarClave] = useState("nadro");
  const [lugarLibre, setLugarLibre] = useState("");
  const [precioFuente, setPrecioFuente] = useState("");
  const [urlFuente, setUrlFuente] = useState("");
  const [notasFuente, setNotasFuente] = useState("");
  const [disponible, setDisponible] = useState(true);
  const [busq, setBusq] = useState("");
  const [hits, setHits] = useState([]);
  const [guardando, setGuardando] = useState(false);
  const [abierto, setAbierto] = useState(false);

  useEffect(() => {
    setPrecioEdit(item.precio_venta != null ? String(item.precio_venta) : "");
  }, [item.precio_venta, item.id]);

  useEffect(() => {
    const q = busq.trim();
    if (q.length < 2) {
      setHits([]);
      return undefined;
    }
    let cancel = false;
    const t = setTimeout(async () => {
      const tok = sessionTok();
      if (!tok) return;
      let { data, error } = await supabase.rpc("admin_buscar_productos_cotizacion", {
        p_session_token: tok,
        p_busqueda: q,
        p_limite: 6,
      });
      if (error && /does not exist|schema cache/i.test(error.message || "")) {
        const fb = await supabase.rpc("empleado_buscar_productos_venta", {
          p_session_token: tok,
          p_busqueda: q,
          p_limite: 6,
        });
        data = fb.data;
        error = fb.error;
      }
      if (cancel) return;
      setHits(!error && Array.isArray(data) ? data : []);
    }, 220);
    return () => {
      cancel = true;
      clearTimeout(t);
    };
  }, [busq]);

  const fuentes = Array.isArray(item.fuentes) ? item.fuentes : [];
  const nums = vistaNumerosProducto({
    costoTexto: precioFuente,
    precioTexto: precioEdit,
    costoGuardado: item.costo_elegido,
    precioGuardado: item.precio_venta,
    cantidad: item.cantidad,
    tipoMargen: item.tipo_margen,
  });
  const costoSucio = precioFuente !== "" && Number(String(precioFuente).replace(",", ".")) !== Number(item.costo_elegido);
  const precioSucio = precioEdit !== "" && Number(String(precioEdit).replace(",", ".")) !== Number(item.precio_venta);
  const est = colorEstado(item.estado);
  const next = siguientesEstadosItemCotizacion(item.estado);
  const foto = urlImagenPublicaTienda(item.imagen_url);

  const elegirFuenteNueva = async (data, aviso) => {
    const line = (data?.items || []).find((i) => i.id === item.id);
    const prev = new Set(fuentes.map((f) => f.id));
    const nueva = (line?.fuentes || []).find((f) => !prev.has(f.id));
    if (!nueva) return data;
    if (item.fuente_elegida_id) return data;
    return rpc("admin_elegir_cotizacion_fuente", { p_id: nueva.id }, aviso);
  };

  const guardarPrecio = (valor) => {
    const n = Number(String(valor).replace(",", "."));
    if (!Number.isFinite(n) || n < 0) {
      showToast("Precio de venta inválido", "warning");
      return;
    }
    rpc("admin_actualizar_cotizacion_item", { p_id: item.id, p_precio_venta: n }, "Precio de venta guardado");
  };

  const guardarProducto = async () => {
    const precio = precioEdit === "" ? null : Number(String(precioEdit).replace(",", "."));
    const costo = precioFuente === "" ? null : Number(String(precioFuente).replace(",", "."));
    if (precio != null && (!Number.isFinite(precio) || precio < 0)) {
      showToast("Precio de venta inválido", "warning");
      return;
    }
    if (costo != null && (!Number.isFinite(costo) || costo <= 0)) {
      showToast("El costo tiene que ser mayor a cero", "warning");
      return;
    }
    if (precio == null && costo == null) {
      showToast("Escribe el costo y el precio de venta", "warning");
      return;
    }
    setGuardando(true);
    try {
      if (precio != null && precio !== Number(item.precio_venta)) {
        const okPrecio = await rpc(
          "admin_actualizar_cotizacion_item",
          { p_id: item.id, p_precio_venta: precio },
          null,
        );
        if (!okPrecio) return;
      }
      if (costo != null && costo !== Number(item.costo_elegido)) {
        if (item.fuente_elegida_id) {
          const okCosto = await rpc(
            "admin_actualizar_cotizacion_fuente",
            { p_id: item.fuente_elegida_id, p_precio: costo },
            "Producto guardado",
          );
          if (okCosto) setPrecioFuente("");
          return;
        }
        const lugar = lugarClave === "otro" ? lugarLibre : lugarClave;
        if (lugarClave === "otro" && String(lugarLibre).trim().length < 2) {
          showToast("Escribe el lugar", "warning");
          return;
        }
        const data = await rpc("admin_agregar_cotizacion_fuente", {
          p_item_id: item.id,
          p_lugar: lugar,
          p_precio: costo,
          p_url: urlFuente.trim() || null,
          p_notas: notasFuente.trim() || null,
          p_disponible: disponible,
        }, null);
        if (!data) return;
        await elegirFuenteNueva(data, "Producto guardado");
        setPrecioFuente("");
        setUrlFuente("");
        setNotasFuente("");
        return;
      }
      showToast("Producto guardado", "success");
    } finally {
      setGuardando(false);
    }
  };

  const agregarFuente = async () => {
    const lugar = lugarClave === "otro" ? lugarLibre : lugarClave;
    const precio = Number(String(precioFuente).replace(",", "."));
    if (lugarClave === "otro" && String(lugarLibre).trim().length < 2) {
      showToast("Escribe el lugar", "warning");
      return;
    }
    if (!Number.isFinite(precio) || precio <= 0) {
      showToast("Pon el costo de esa fuente", "warning");
      return;
    }
    const data = await rpc("admin_agregar_cotizacion_fuente", {
      p_item_id: item.id,
      p_lugar: lugar,
      p_precio: precio,
      p_url: urlFuente.trim() || null,
      p_notas: notasFuente.trim() || null,
      p_disponible: disponible,
    }, item.fuente_elegida_id ? "Fuente agregada" : null);
    if (!data) return;
    if (!item.fuente_elegida_id) await elegirFuenteNueva(data, "Costo guardado");
    setPrecioFuente("");
    setUrlFuente("");
    setNotasFuente("");
  };

  const ligarCatalogo = async (h) => {
    setBusq("");
    setHits([]);
    await rpc("admin_ligar_producto_cotizacion", {
      p_item_id: item.id,
      p_producto_id: h.id,
    }, "Foto del catálogo");
  };

  return (
    <section
      style={{
        background: C.card,
        border: `1px solid ${C.border}`,
        borderRadius: 14,
        padding: abierto ? 14 : "10px 12px",
        marginBottom: 8,
      }}
    >
      <button
        type="button"
        aria-expanded={abierto}
        onClick={() => setAbierto((v) => !v)}
        style={{
          display: "flex",
          alignItems: "center",
          gap: 10,
          width: "100%",
          border: "none",
          background: "transparent",
          cursor: "pointer",
          textAlign: "left",
          font: "inherit",
          padding: 0,
          color: C.text,
        }}
      >
        {abierto ? <ChevronDown size={16} color={C.textMid} /> : <ChevronRight size={16} color={C.textMid} />}
        <span
          style={{
            fontWeight: 800,
            flex: "1 1 auto",
            minWidth: 0,
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {item.texto}
          {item.cantidad > 1 ? <span style={{ color: C.textMid }}> ×{item.cantidad}</span> : null}
        </span>
        {chip(est.bg, est.color, etiquetaEstadoItemCotizacion(item.estado))}
        <span style={{ fontWeight: 800, whiteSpace: "nowrap" }}>{fmtDineroCotiz(nums.venta)}</span>
        <span style={{ color: C.greenDark, fontWeight: 700, fontSize: 12, whiteSpace: "nowrap" }}>
          {fmtDineroCotiz(nums.gananciaTotal)}
        </span>
      </button>
      {abierto ? (
      <div style={{ marginTop: 12 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap" }}>
        <div style={{ display: "flex", gap: 12, minWidth: 0, flex: 1 }}>
          <div
            style={{
              width: 64,
              height: 64,
              borderRadius: 10,
              background: C.cardDark,
              border: `1px solid ${C.border}`,
              overflow: "hidden",
              flexShrink: 0,
              display: "grid",
              placeItems: "center",
            }}
          >
            {foto ? (
              <img src={foto} alt="" style={{ width: "100%", height: "100%", objectFit: "contain" }} />
            ) : (
              <span style={{ fontSize: 10, color: C.textDim, textAlign: "center", padding: 4 }}>Sin foto</span>
            )}
          </div>
          <div style={{ minWidth: 0, flex: 1 }}>
            <div style={{ fontWeight: 800, fontSize: 16, color: C.text }}>
              {item.texto}
              {item.cantidad > 1 ? <span style={{ color: C.textMid }}> ×{item.cantidad}</span> : null}
            </div>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 6 }}>
              {chip(est.bg, est.color, etiquetaEstadoItemCotizacion(item.estado))}
              {item.producto_nombre ? chip(C.cardDark, C.textMid, item.producto_nombre) : null}
              {item.ean ? chip(C.cardDark, C.textMid, item.ean) : null}
            </div>
            <div style={{ position: "relative", marginTop: 8, maxWidth: 360 }}>
              <Search size={14} style={{ position: "absolute", left: 10, top: 11, color: C.textDim }} />
              <Inp
                value={busq}
                onChange={(e) => setBusq(e.target.value)}
                placeholder="Buscar en el catálogo para traer la foto"
                style={{ paddingLeft: 30 }}
              />
              {hits.length > 0 && (
                <div
                  style={{
                    position: "absolute",
                    zIndex: 5,
                    left: 0,
                    right: 0,
                    top: "100%",
                    marginTop: 4,
                    background: "#fff",
                    border: `1px solid ${C.border}`,
                    borderRadius: 8,
                    overflow: "hidden",
                  }}
                >
                  {hits.map((h) => {
                    const mini = urlImagenPublicaTienda(h.imagen_url);
                    return (
                      <button
                        key={h.id}
                        type="button"
                        onClick={() => ligarCatalogo(h)}
                        style={{
                          display: "flex",
                          gap: 8,
                          alignItems: "center",
                          width: "100%",
                          textAlign: "left",
                          padding: "8px 10px",
                          border: "none",
                          borderBottom: `1px solid ${C.border}`,
                          background: "#fff",
                          cursor: "pointer",
                          font: "inherit",
                        }}
                      >
                        <span
                          style={{
                            width: 36,
                            height: 36,
                            borderRadius: 6,
                            background: C.cardDark,
                            overflow: "hidden",
                            flexShrink: 0,
                          }}
                        >
                          {mini ? (
                            <img src={mini} alt="" style={{ width: "100%", height: "100%", objectFit: "contain" }} />
                          ) : null}
                        </span>
                        <span>
                          <span style={{ display: "block", fontWeight: 700, fontSize: 13, color: C.text }}>{h.nombre}</span>
                          <span style={{ display: "block", fontSize: 11, color: C.textMid }}>
                            {[h.marca, h.presentacion].filter(Boolean).join(" · ") || `Stock ${h.stock ?? 0}`}
                          </span>
                        </span>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, alignItems: "flex-end" }}>
          <Btn onClick={() => {
            if (window.confirm(`¿Quitar «${item.texto}» de esta cotización?`)) {
              rpc("admin_eliminar_cotizacion_item", { p_id: item.id }, "Producto quitado");
            }
          }}>
            <Trash2 size={14} /> Quitar
          </Btn>
        <label style={{ minWidth: 160 }}>
          <FieldLabel>Recargo sobre costo</FieldLabel>
          <FieldSelect
            value={item.tipo_margen === "generico" ? "generico" : "marca"}
            onChange={(e) => rpc("admin_actualizar_cotizacion_item", {
              p_id: item.id,
              p_tipo_margen: e.target.value,
            })}
          >
            {TIPOS_MARGEN_COTIZACION.map((t) => (
              <option key={t.id} value={t.id}>{t.label} (+{t.recargoPct}%)</option>
            ))}
          </FieldSelect>
        </label>
        </div>
      </div>

      <div style={{ overflowX: "auto", marginTop: 12 }}>
        <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: "left", color: C.textMid, fontSize: 11 }}>
              <th style={{ padding: "6px 8px" }}>Lugar</th>
              <th style={{ padding: "6px 8px" }}>Costo</th>
              <th style={{ padding: "6px 8px" }}>Link</th>
              <th style={{ padding: "6px 8px" }}>Disp.</th>
              <th style={{ padding: "6px 8px" }} />
            </tr>
          </thead>
          <tbody>
            {fuentes.length === 0 && (
              <tr>
                <td colSpan={5} style={{ padding: "10px 8px", color: C.textDim }}>
                  Aún no hay fuentes. Anota dónde lo viste y a qué precio.
                </td>
              </tr>
            )}
            {fuentes.map((f) => (
              <tr key={f.id} style={{ background: f.elegida ? C.greenDim : "transparent" }}>
                <td style={{ padding: "8px", fontWeight: 700, color: C.text }}>
                  {etiquetaLugarCotizacion(f.lugar)}
                  {f.elegida ? " · elegida" : ""}
                  {f.notas ? <div style={{ fontWeight: 500, color: C.textMid, fontSize: 11 }}>{f.notas}</div> : null}
                </td>
                <td style={{ padding: "8px", fontWeight: 800 }}>{fmtDineroCotiz(f.precio)}</td>
                <td style={{ padding: "8px" }}>
                  {f.url ? (
                    <a href={f.url} target="_blank" rel="noopener noreferrer" style={{ color: C.blue, fontWeight: 700 }}>
                      <ExternalLink size={13} /> abrir
                    </a>
                  ) : (
                    "—"
                  )}
                </td>
                <td style={{ padding: "8px" }}>{f.disponible === false ? "No" : "Sí"}</td>
                <td style={{ padding: "8px", whiteSpace: "nowrap" }}>
                  <Btn
                    primary={f.elegida}
                    onClick={() => rpc("admin_elegir_cotizacion_fuente", { p_id: f.id }, "Fuente elegida")}
                  >
                    {f.elegida ? "Elegida" : "Elegir"}
                  </Btn>{" "}
                  <Btn onClick={() => rpc("admin_eliminar_cotizacion_fuente", { p_id: f.id }, "Fuente quitada")}>
                    <Trash2 size={13} />
                  </Btn>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
          gap: 8,
          marginTop: 12,
        }}
      >
        <label>
          <FieldLabel>Lugar</FieldLabel>
          <FieldSelect value={lugarClave} onChange={(e) => setLugarClave(e.target.value)}>
            {FUENTES_ATAJO_COTIZACION.map((f) => (
              <option key={f.id} value={f.id}>{f.label}</option>
            ))}
          </FieldSelect>
        </label>
        {lugarClave === "otro" && (
          <label>
            <FieldLabel>Cuál</FieldLabel>
            <Inp value={lugarLibre} onChange={(e) => setLugarLibre(e.target.value)} placeholder="Nombre del lugar" />
          </label>
        )}
        <label>
          <FieldLabel>Costo</FieldLabel>
          <Inp
            type="number"
            inputMode="decimal"
            value={precioFuente}
            onChange={(e) => setPrecioFuente(e.target.value)}
            placeholder="Costo"
          />
        </label>
        <label>
          <FieldLabel>Link</FieldLabel>
          <Inp value={urlFuente} onChange={(e) => setUrlFuente(e.target.value)} placeholder="https://…" />
        </label>
        <label>
          <FieldLabel>Nota de la fuente</FieldLabel>
          <Inp value={notasFuente} onChange={(e) => setNotasFuente(e.target.value)} placeholder="pieza, caja, caducidad…" />
        </label>
        <label style={{ display: "flex", alignItems: "flex-end", gap: 8, paddingBottom: 10 }}>
          <input
            type="checkbox"
            checked={disponible}
            onChange={(e) => setDisponible(e.target.checked)}
          />
          <span style={{ fontSize: 12, fontWeight: 700, color: C.textMid }}>Disponible</span>
        </label>
      </div>
      <div style={{ marginTop: 8 }}>
        <Btn onClick={agregarFuente}>
          <Plus size={14} /> Agregar fuente
        </Btn>
      </div>

      <div
        style={{
          marginTop: 14,
          background: C.cardDark,
          borderRadius: 12,
          padding: 12,
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
          gap: 10,
        }}
      >
        <div>
          <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Costo elegido</div>
          <div style={{ fontWeight: 800, color: C.text }}>{fmtDineroCotiz(nums.costo)}</div>
        </div>
        <div>
          <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Sugerido</div>
          <div style={{ fontWeight: 800, color: C.text }}>{fmtDineroCotiz(nums.sugerido)}</div>
          {nums.sugerido != null && (
            <button
              type="button"
              onClick={() => {
                setPrecioEdit(String(nums.sugerido));
                guardarPrecio(nums.sugerido);
              }}
              style={{
                marginTop: 4,
                border: "none",
                background: "transparent",
                color: C.blue,
                fontWeight: 700,
                fontSize: 11,
                cursor: "pointer",
                padding: 0,
              }}
            >
              Usar sugerido
            </button>
          )}
        </div>
        <label>
          <FieldLabel>Precio de venta</FieldLabel>
          <Inp
            type="number"
            inputMode="decimal"
            value={precioEdit}
            onChange={(e) => setPrecioEdit(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                guardarProducto();
              }
            }}
          />
        </label>
        <div>
          <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Recargo / margen</div>
          <div style={{ fontWeight: 800, color: C.text }}>
            Recargo {nums.recargoPct != null ? `${nums.recargoPct}%` : "—"}
          </div>
          <div style={{ fontSize: 12, color: C.textMid }}>
            Margen {nums.margenPct != null ? `${nums.margenPct}%` : "—"} sobre venta
          </div>
        </div>
        <div>
          <div style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>Ganancia</div>
          <div style={{ fontWeight: 800, color: C.greenDark }}>{fmtDineroCotiz(nums.gananciaUnit)} / pza</div>
          <div style={{ fontSize: 12, color: C.textMid }}>{fmtDineroCotiz(nums.gananciaTotal)} del renglón</div>
          {(costoSucio || precioSucio) && (
            <div style={{ fontSize: 11, color: C.amber, fontWeight: 700, marginTop: 4 }}>Aún no está guardado</div>
          )}
        </div>
        <div style={{ display: "flex", alignItems: "flex-end" }}>
          <Btn primary onClick={guardarProducto}>
            {guardando ? "Guardando…" : "Guardar"}
          </Btn>
        </div>
      </div>

      <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 12 }}>
        {next.map((e) => (
          <Btn
            key={e}
            onClick={() => rpc("admin_actualizar_cotizacion_item", { p_id: item.id, p_estado: e }, `Línea: ${etiquetaEstadoItemCotizacion(e)}`)}
          >
            → {etiquetaEstadoItemCotizacion(e)}
          </Btn>
        ))}
      </div>
      </div>
      ) : null}
    </section>
  );
}
