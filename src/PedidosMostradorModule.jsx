import { useCallback, useEffect, useState } from "react";
import { ClipboardList, Plus, RefreshCw, Search, X } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import { rolEsAdmin } from "./utils/permissions";
import {
  ESTADOS_SOLICITUD,
  FILTROS_LISTA,
  PAGOS,
  URGENCIAS,
  etiquetaEstado,
  etiquetaPago,
  etiquetaTipo,
  etiquetaUrgencia,
  normalizarTextoSolicitud,
  puedeGuardarSolicitud,
  siguientesEstados,
} from "./lib/pedidosMostrador";

const C = C_LIGHT;

const inpBase = {
  width: "100%",
  marginTop: 4,
  padding: "10px 12px",
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  fontSize: 14,
  boxSizing: "border-box",
  background: C.card,
  color: C.text,
};

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

function fmtCuando(iso) {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("es-MX", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
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
    case "pendiente":
      return { bg: C.amberDim, color: C.amber };
    case "pedir":
      return { bg: C.blueDim, color: C.blue };
    case "pedido":
      return { bg: C.purpleDim, color: C.purple };
    case "llego":
      return { bg: C.greenDim, color: C.greenDark };
    default:
      return { bg: C.cardDark, color: C.textMid };
  }
}

function colorUrgencia(u) {
  if (u === "hoy") return { bg: C.redDim, color: C.red };
  if (u === "manana") return { bg: C.amberDim, color: C.amber };
  return { bg: C.cardDark, color: C.textMid };
}

export default function PedidosMostradorModule({ usuario }) {
  const esAdmin = rolEsAdmin(usuario?.rol);
  const [filtro, setFiltro] = useState("abiertas");
  const [lista, setLista] = useState([]);
  const [ranking, setRanking] = useState([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("lista");
  const [formOpen, setFormOpen] = useState(true);

  const [texto, setTexto] = useState("");
  const [cantidad, setCantidad] = useState(1);
  const [urgencia, setUrgencia] = useState("sin_prisa");
  const [notas, setNotas] = useState("");
  const [clienteNombre, setClienteNombre] = useState("");
  const [clienteTel, setClienteTel] = useState("");
  const [pagoTipo, setPagoTipo] = useState("nada");
  const [pagoMonto, setPagoMonto] = useState("");
  const [producto, setProducto] = useState(null);
  const [busq, setBusq] = useState("");
  const [hits, setHits] = useState([]);
  const [buscando, setBuscando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [actualizandoId, setActualizandoId] = useState(null);

  const cargar = useCallback(async () => {
    const tok = sessionTok();
    if (!tok) {
      showToast("Sesión expirada. Vuelve a entrar.", "error");
      return;
    }
    setLoading(true);
    const [listRes, rankRes] = await Promise.all([
      supabase.rpc("empleado_listar_solicitudes_mostrador", {
        p_session_token: tok,
        p_estado: filtro === "" ? null : filtro,
        p_limite: 150,
      }),
      supabase.rpc("empleado_ranking_solicitudes_mostrador", {
        p_session_token: tok,
        p_dias: 30,
        p_limite: 25,
      }),
    ]);
    if (listRes.error) {
      console.warn("[PedidosMostrador]", listRes.error.message);
      showToast(
        /empleado_listar_solicitudes_mostrador|schema cache|does not exist/i.test(listRes.error.message || "")
          ? "Falta aplicar sql/patch_pedidos_mostrador_20260904.sql en Supabase."
          : "No se pudo cargar la lista",
        "error",
      );
      setLista([]);
    } else {
      setLista(Array.isArray(listRes.data) ? listRes.data : []);
    }
    if (!rankRes.error) setRanking(Array.isArray(rankRes.data) ? rankRes.data : []);
    setLoading(false);
  }, [filtro]);

  useEffect(() => {
    cargar();
  }, [cargar]);

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
      setBuscando(true);
      const { data, error } = await supabase.rpc("empleado_buscar_productos_venta", {
        p_session_token: tok,
        p_busqueda: q,
        p_limite: 8,
      });
      if (cancel) return;
      setBuscando(false);
      setHits(error ? [] : Array.isArray(data) ? data : []);
    }, 220);
    return () => {
      cancel = true;
      clearTimeout(t);
    };
  }, [busq]);

  const resetForm = () => {
    setTexto("");
    setCantidad(1);
    setUrgencia("sin_prisa");
    setNotas("");
    setClienteNombre("");
    setClienteTel("");
    setPagoTipo("nada");
    setPagoMonto("");
    setProducto(null);
    setBusq("");
    setHits([]);
  };

  const guardar = async () => {
    const textoFinal = normalizarTextoSolicitud(producto?.nombre || texto);
    if (!puedeGuardarSolicitud({ texto: textoFinal, cantidad })) {
      showToast("Escribe qué buscan (mín. 2 caracteres)", "warning");
      return;
    }
    const tok = sessionTok();
    if (!tok) return;
    const montoNum = pagoTipo === "nada" || pagoMonto === "" ? null : Number(pagoMonto);
    if (montoNum != null && (!Number.isFinite(montoNum) || montoNum < 0)) {
      showToast("Monto de pago inválido", "warning");
      return;
    }
    setGuardando(true);
    const { error } = await supabase.rpc("empleado_crear_solicitud_mostrador", {
      p_session_token: tok,
      p_texto: textoFinal,
      p_producto_id: producto?.id ?? null,
      p_cantidad: Number(cantidad) || 1,
      p_urgencia: urgencia,
      p_notas: notas.trim() || null,
      p_cliente_nombre: clienteNombre.trim() || null,
      p_cliente_telefono: clienteTel.trim() || null,
      p_pago_tipo: pagoTipo,
      p_pago_monto: montoNum,
    });
    setGuardando(false);
    if (error) {
      showToast(error.message || "No se pudo anotar", "error");
      return;
    }
    showToast("Anotado en la lista", "success");
    resetForm();
    setFiltro("abiertas");
    cargar();
  };

  const cambiarEstado = async (id, estado) => {
    const tok = sessionTok();
    if (!tok) return;
    setActualizandoId(id);
    const { error } = await supabase.rpc("empleado_actualizar_estado_solicitud_mostrador", {
      p_session_token: tok,
      p_id: id,
      p_estado: estado,
    });
    setActualizandoId(null);
    if (error) {
      showToast(error.message || "No se pudo actualizar", "error");
      return;
    }
    showToast(`Marcado: ${etiquetaEstado(estado)}`, "success");
    cargar();
  };

  const vacia = !loading && lista.length === 0;

  return (
    <div style={{ padding: "18px 16px 40px", maxWidth: 920, margin: "0 auto" }}>
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
            <ClipboardList size={20} />
          </div>
          <div>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, color: C.text }}>Lo que buscan</h1>
            <p style={{ margin: "2px 0 0", color: C.textMid, fontSize: 13 }}>
              Anota lo que piden y no hay. Incluye cliente y si dejaron depósito.
            </p>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button
            type="button"
            onClick={() => cargar()}
            style={{
              padding: "8px 12px",
              borderRadius: 8,
              border: `1px solid ${C.border}`,
              background: C.card,
              color: C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              gap: 6,
            }}
          >
            <RefreshCw size={14} /> Actualizar
          </button>
          <button
            type="button"
            onClick={() => setFormOpen((v) => !v)}
            style={{
              padding: "8px 14px",
              borderRadius: 8,
              border: "none",
              background: BRAND.gradient,
              color: "#fff",
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              gap: 6,
            }}
          >
            <Plus size={14} /> {formOpen ? "Ocultar alta" : "Anotar"}
          </button>
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
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 10 }}>
            NUEVA ANOTACIÓN · te registra a ti como vendedor ({usuario?.nombre || "sesión"})
          </div>

          <label style={{ display: "block", marginBottom: 10 }}>
            <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>¿Qué buscan?</span>
            <input
              value={producto ? producto.nombre : texto}
              onChange={(e) => {
                if (producto) setProducto(null);
                setTexto(e.target.value);
              }}
              placeholder="Ej. Bumetadina, Clonazepam, papilla Heinz…"
              style={inpBase}
            />
          </label>

          <div style={{ marginBottom: 10 }}>
            <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>
              ¿Está en el catálogo? (opcional)
            </span>
            <div style={{ position: "relative", marginTop: 4 }}>
              <Search size={14} style={{ position: "absolute", left: 10, top: 12, color: C.textDim }} />
              <input
                value={busq}
                onChange={(e) => setBusq(e.target.value)}
                placeholder="Buscar nombre o código…"
                style={{ ...inpBase, marginTop: 0, paddingLeft: 32 }}
              />
              {producto && (
                <button
                  type="button"
                  onClick={() => setProducto(null)}
                  title="Quitar vínculo"
                  style={{
                    position: "absolute",
                    right: 8,
                    top: 8,
                    border: "none",
                    background: C.cardDark,
                    borderRadius: 6,
                    padding: 4,
                    cursor: "pointer",
                  }}
                >
                  <X size={14} />
                </button>
              )}
            </div>
            {buscando && <div style={{ color: C.textDim, fontSize: 11, marginTop: 4 }}>Buscando…</div>}
            {hits.length > 0 && !producto && (
              <div
                style={{
                  marginTop: 6,
                  border: `1px solid ${C.border}`,
                  borderRadius: 8,
                  overflow: "hidden",
                }}
              >
                {hits.map((h) => (
                  <button
                    key={h.id}
                    type="button"
                    onClick={() => {
                      setProducto(h);
                      setTexto(h.nombre || "");
                      setBusq("");
                      setHits([]);
                    }}
                    style={{
                      display: "block",
                      width: "100%",
                      textAlign: "left",
                      padding: "10px 12px",
                      border: "none",
                      borderBottom: `1px solid ${C.border}`,
                      background: "transparent",
                      cursor: "pointer",
                      font: "inherit",
                    }}
                  >
                    <div style={{ fontWeight: 700, fontSize: 13, color: C.text }}>{h.nombre}</div>
                    <div style={{ fontSize: 11, color: C.textMid }}>
                      Stock: {h.stock ?? 0}
                      {Number(h.stock) <= 0 ? " · agotado" : ""}
                    </div>
                  </button>
                ))}
              </div>
            )}
            {producto && (
              <div style={{ marginTop: 6, fontSize: 12, color: C.textMid }}>
                Vinculado: <strong style={{ color: C.text }}>{producto.nombre}</strong>
                {" · "}
                {Number(producto.stock) <= 0 ? "agotado en tienda" : `stock ${producto.stock}`}
              </div>
            )}
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
              gap: 10,
              marginBottom: 10,
            }}
          >
            <label>
              <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Cantidad</span>
              <input
                type="number"
                min={1}
                max={999}
                value={cantidad}
                onChange={(e) => setCantidad(e.target.value)}
                style={inpBase}
              />
            </label>
            <label>
              <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>¿Para cuándo?</span>
              <select value={urgencia} onChange={(e) => setUrgencia(e.target.value)} style={inpBase}>
                {URGENCIAS.map((u) => (
                  <option key={u.id} value={u.id}>
                    {u.label}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))",
              gap: 10,
              marginBottom: 10,
            }}
          >
            <label>
              <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Cliente</span>
              <input
                value={clienteNombre}
                onChange={(e) => setClienteNombre(e.target.value)}
                placeholder="Nombre (opcional)"
                style={inpBase}
              />
            </label>
            <label>
              <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Teléfono</span>
              <input
                value={clienteTel}
                onChange={(e) => setClienteTel(e.target.value)}
                placeholder="10 dígitos"
                inputMode="tel"
                style={inpBase}
              />
            </label>
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))",
              gap: 10,
              marginBottom: 10,
            }}
          >
            <label>
              <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Anticipo / pago</span>
              <select value={pagoTipo} onChange={(e) => setPagoTipo(e.target.value)} style={inpBase}>
                {PAGOS.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.label}
                  </option>
                ))}
              </select>
            </label>
            {pagoTipo !== "nada" && (
              <label>
                <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Monto ($)</span>
                <input
                  type="number"
                  min={0}
                  step="0.01"
                  value={pagoMonto}
                  onChange={(e) => setPagoMonto(e.target.value)}
                  placeholder="Opcional"
                  style={inpBase}
                />
              </label>
            )}
          </div>

          <label style={{ display: "block", marginBottom: 12 }}>
            <span style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>Nota (opcional)</span>
            <input
              value={notas}
              onChange={(e) => setNotas(e.target.value)}
              placeholder="Controlado, marca, receta, etc."
              style={inpBase}
            />
          </label>

          <button
            type="button"
            disabled={guardando}
            onClick={guardar}
            style={{
              padding: "11px 18px",
              borderRadius: 8,
              border: "none",
              background: BRAND.gradient,
              color: "#fff",
              fontWeight: 800,
              fontSize: 14,
              cursor: guardando ? "wait" : "pointer",
              opacity: guardando ? 0.7 : 1,
            }}
          >
            {guardando ? "Guardando…" : "Anotar en la lista"}
          </button>
        </section>
      )}

      <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
        {[
          { id: "lista", label: "Lista" },
          { id: "ranking", label: "Más pedidos (30 días)" },
        ].map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => setTab(t.id)}
            style={{
              padding: "7px 12px",
              borderRadius: 8,
              border: tab === t.id ? `1.5px solid ${C.blue}` : `1px solid ${C.border}`,
              background: tab === t.id ? C.blueDim : C.card,
              color: tab === t.id ? C.blue : C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === "lista" && (
        <>
          <div style={{ display: "flex", gap: 6, marginBottom: 12, flexWrap: "wrap" }}>
            {FILTROS_LISTA.map((f) => (
              <button
                key={f.id || "todas"}
                type="button"
                onClick={() => setFiltro(f.id)}
                style={{
                  padding: "6px 10px",
                  borderRadius: 999,
                  border: filtro === f.id ? `1.5px solid ${C.blue}` : `1px solid ${C.border}`,
                  background: filtro === f.id ? C.blueDim : C.card,
                  color: filtro === f.id ? C.blue : C.textMid,
                  fontWeight: 700,
                  fontSize: 11,
                  cursor: "pointer",
                }}
              >
                {f.label}
              </button>
            ))}
          </div>

          {loading && (
            <div style={{ color: C.textMid, padding: 24, textAlign: "center" }}>Cargando lista…</div>
          )}
          {vacia && (
            <div
              style={{
                background: C.card,
                border: `1px dashed ${C.border}`,
                borderRadius: 14,
                padding: 28,
                textAlign: "center",
                color: C.textMid,
              }}
            >
              Nadie ha anotado nada con este filtro.
              <div style={{ fontSize: 12, marginTop: 6 }}>
                Cuando un cliente pida algo que no hay, anótalo arriba.
              </div>
            </div>
          )}

          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            {lista.map((s) => {
              const est = colorEstado(s.estado);
              const urg = colorUrgencia(s.urgencia);
              const next = siguientesEstados(s.estado);
              return (
                <article
                  key={s.id}
                  style={{
                    background: C.card,
                    border: `1px solid ${C.border}`,
                    borderRadius: 12,
                    padding: "12px 14px",
                  }}
                >
                  <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap" }}>
                    <div style={{ flex: 1, minWidth: 180 }}>
                      <div style={{ fontWeight: 800, fontSize: 15, color: C.text, marginBottom: 4 }}>
                        {s.texto}
                        {s.cantidad > 1 ? (
                          <span style={{ color: C.textMid, fontWeight: 700 }}> ×{s.cantidad}</span>
                        ) : null}
                      </div>
                      <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 6 }}>
                        {chip(est.bg, est.color, etiquetaEstado(s.estado))}
                        {chip(urg.bg, urg.color, etiquetaUrgencia(s.urgencia))}
                        {chip(C.cardDark, C.textMid, etiquetaTipo(s.tipo))}
                        {s.pago_tipo && s.pago_tipo !== "nada"
                          ? chip(C.greenDim, C.greenDark, etiquetaPago(s.pago_tipo, s.pago_monto))
                          : null}
                      </div>
                      <div style={{ fontSize: 12, color: C.textMid }}>
                        Vendedor: {s.anotado_por_nombre || "—"} · {fmtCuando(s.created_at)}
                        {s.producto_nombre ? ` · Catálogo: ${s.producto_nombre}` : ""}
                      </div>
                      {(s.cliente_nombre || s.cliente_telefono) && (
                        <div style={{ fontSize: 12, color: C.text, marginTop: 4 }}>
                          Cliente: {s.cliente_nombre || "—"}
                          {s.cliente_telefono ? ` · ${s.cliente_telefono}` : ""}
                        </div>
                      )}
                      {s.notas ? (
                        <div style={{ fontSize: 12, color: C.text, marginTop: 4 }}>Nota: {s.notas}</div>
                      ) : null}
                    </div>
                    <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
                      {next.map((e) => (
                        <button
                          key={e}
                          type="button"
                          disabled={actualizandoId === s.id}
                          onClick={() => cambiarEstado(s.id, e)}
                          style={{
                            padding: "6px 10px",
                            borderRadius: 7,
                            border: `1px solid ${C.border}`,
                            background: C.cardDark,
                            color: C.text,
                            fontWeight: 700,
                            fontSize: 11,
                            cursor: "pointer",
                            whiteSpace: "nowrap",
                            opacity: actualizandoId === s.id ? 0.6 : 1,
                          }}
                        >
                          → {etiquetaEstado(e)}
                        </button>
                      ))}
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        </>
      )}

      {tab === "ranking" && (
        <section
          style={{
            background: C.card,
            border: `1px solid ${C.border}`,
            borderRadius: 14,
            padding: 14,
          }}
        >
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 10 }}>
            LO MÁS PEDIDO · ÚLTIMOS 30 DÍAS
          </div>
          {ranking.length === 0 && !loading && (
            <div style={{ color: C.textMid, fontSize: 13 }}>Aún no hay suficientes anotaciones.</div>
          )}
          <ol style={{ margin: 0, paddingLeft: 18 }}>
            {ranking.map((r, i) => (
              <li key={`${r.clave}-${r.producto_id || i}`} style={{ marginBottom: 10 }}>
                <div style={{ fontWeight: 800, color: C.text, fontSize: 14 }}>
                  {r.texto}
                  {r.producto_nombre && r.producto_nombre !== r.texto ? (
                    <span style={{ fontWeight: 600, color: C.textMid }}> ({r.producto_nombre})</span>
                  ) : null}
                </div>
                <div style={{ fontSize: 12, color: C.textMid }}>
                  {r.veces} vez{r.veces === 1 ? "" : "es"} · {r.unidades} unidad{r.unidades === 1 ? "" : "es"}
                  {r.alguna_sin_catalogo ? " · sin catálogo" : ""}
                  {r.alguna_agotada ? " · agotado" : ""}
                  {" · última "}
                  {fmtCuando(r.ultima_vez)}
                </div>
              </li>
            ))}
          </ol>
          {!esAdmin && (
            <div style={{ marginTop: 8, fontSize: 11, color: C.textDim }}>
              El ranking también lo ve gerencia para armar compras.
            </div>
          )}
        </section>
      )}

      {esAdmin && tab === "lista" && (
        <p style={{ marginTop: 16, fontSize: 12, color: C.textDim }}>
          Estados: {ESTADOS_SOLICITUD.map((e) => e.label).join(" → ")}. Usa «Pedir» / «Pedido» al comprar y «Llegó»
          al recibir.
        </p>
      )}
    </div>
  );
}
