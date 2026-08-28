import { useCallback, useEffect, useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import { formatCaducidadMesAnio } from "./lib/caducidad";
import { textoEtiquetaPrecioEspecial } from "./lib/descuentoCaducidad";
import { fechaLocalMexico } from "./lib/pagoServicio";

const C = C_LIGHT;
const money = (n) =>
  `$${Number(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const pct = (n) => {
  const x = Number(n);
  if (!Number.isFinite(x)) return "—";
  return `${(x <= 1 ? x * 100 : x).toFixed(1)}%`;
};

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

export default function DescuentoCaducidadModule() {
  const [estado, setEstado] = useState("PENDIENTE");
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sel, setSel] = useState(() => new Set());
  const [editId, setEditId] = useState(null);
  const [editPrecio, setEditPrecio] = useState("");
  const [etiqueta, setEtiqueta] = useState(null);
  const [busy, setBusy] = useState(false);
  const [promosByProducto, setPromosByProducto] = useState({});

  const cargar = useCallback(async (est = estado) => {
    setLoading(true);
    const tok = sessionTok();
    if (!tok) {
      setRows([]);
      setLoading(false);
      return;
    }
    const { data, error } = await supabase.rpc("admin_listar_propuestas_caducidad", {
      p_session_token: tok,
      p_estado: est,
    });
    if (error) {
      showToast(error.message || "No se pudieron cargar las propuestas", "error");
      setRows([]);
    } else {
      setRows(Array.isArray(data) ? data : []);
    }
    setSel(new Set());
    setLoading(false);
  }, [estado]);

  useEffect(() => { cargar(estado); }, [cargar, estado]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const hoy = fechaLocalMexico();
      const { data: promos } = await supabase
        .from("promociones")
        .select("id,nombre,activa,fecha_inicio,fecha_fin");
      if (cancelled) return;
      const activas = (promos || []).filter((p) => {
        if (p.activa === false) return false;
        const a = p.fecha_inicio ? String(p.fecha_inicio).slice(0, 10) : null;
        const b = p.fecha_fin ? String(p.fecha_fin).slice(0, 10) : null;
        if (a && hoy < a) return false;
        if (b && hoy > b) return false;
        return true;
      });
      if (!activas.length) {
        setPromosByProducto({});
        return;
      }
      const { data: links } = await supabase
        .from("promocion_productos")
        .select("promocion_id,producto_id")
        .in("promocion_id", activas.map((p) => p.id));
      if (cancelled) return;
      const names = Object.fromEntries(activas.map((p) => [p.id, p.nombre]));
      const map = {};
      for (const l of links || []) {
        const n = names[l.promocion_id];
        if (!n || l.producto_id == null) continue;
        if (!map[l.producto_id]) map[l.producto_id] = [];
        map[l.producto_id].push(n);
      }
      setPromosByProducto(map);
    })();
    return () => { cancelled = true; };
  }, []);

  const pendientes = estado === "PENDIENTE";
  const totalRiesgo = useMemo(
    () => rows.reduce((s, r) => s + (Number(r.capital_en_riesgo) || 0), 0),
    [rows]
  );
  const totalRecup = useMemo(
    () => rows.reduce((s, r) => s + (Number(r.capital_recuperable) || 0), 0),
    [rows]
  );

  const toggle = (id) => {
    setSel((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const toggleAll = () => {
    if (sel.size === rows.length) setSel(new Set());
    else setSel(new Set(rows.map((r) => r.id)));
  };

  const aprobar = async (ids, precio) => {
    if (!ids.length) return;
    setBusy(true);
    try {
      const tok = sessionTok();
      const { data, error } = await supabase.rpc("admin_aprobar_propuestas_caducidad", {
        p_session_token: tok,
        p_ids: ids,
        p_precio: precio == null || precio === "" ? null : Number(precio),
      });
      if (error) {
        showToast(error.message || "No se pudo aprobar", "error");
        return;
      }
      showToast(`Aprobadas: ${data?.aprobadas ?? ids.length}. El POS aún cobra el PVP.`, "success");
      setEditId(null);
      cargar();
    } catch (e) {
      showToast(e?.message || "Se cayó la conexión. Intenta de nuevo.", "error");
    } finally {
      setBusy(false);
    }
  };

  const rechazar = async (ids) => {
    if (!ids.length) return;
    setBusy(true);
    try {
      const tok = sessionTok();
      const { data, error } = await supabase.rpc("admin_rechazar_propuestas_caducidad", {
        p_session_token: tok,
        p_ids: ids,
      });
      if (error) {
        showToast(error.message || "No se pudo rechazar", "error");
        return;
      }
      showToast(`Rechazadas: ${data?.rechazadas ?? ids.length}`, "info");
      cargar();
    } catch (e) {
      showToast(e?.message || "Se cayó la conexión. Intenta de nuevo.", "error");
    } finally {
      setBusy(false);
    }
  };

  const verEtiqueta = (r) => {
    const txt = r.texto_etiqueta || textoEtiquetaPrecioEspecial({
      descripcion: r.nombre,
      pvp: r.pvp,
      precio_propuesto: r.precio_propuesto,
      descuento_efectivo: r.descuento_efectivo,
      fecha_caducidad: r.fecha_caducidad,
    });
    setEtiqueta(txt);
  };

  const copiarEtiqueta = async () => {
    if (!etiqueta) return;
    try {
      await navigator.clipboard.writeText(etiqueta);
      showToast("Etiqueta copiada", "success");
    } catch {
      showToast("No se pudo copiar", "error");
    }
  };

  return (
    <div style={{ padding: 20, maxWidth: 1200 }}>
      <h2 style={{ margin: "0 0 6px", fontSize: 18, color: C.text }}>
        Precio especial por caducidad
      </h2>
      <p style={{ margin: "0 0 16px", fontSize: 13, color: C.textMid, lineHeight: 1.45, maxWidth: 720 }}>
        El job diario propone. Nada baja de precio en el mostrador hasta que
        el POS lea estas aprobaciones (otra tarea). Orden: más capital en riesgo primero.
      </p>

      <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
        <Stat label="Filas" value={String(rows.length)} />
        <Stat label="Capital en riesgo" value={money(totalRiesgo)} />
        <Stat label="Si se vende al propuesto" value={money(totalRecup)} />
      </div>

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
        {["PENDIENTE", "APROBADA", "RECHAZADA", "RETIRAR", "DATO_FALTANTE", "TODAS"].map((e) => (
          <button
            key={e}
            type="button"
            onClick={() => setEstado(e)}
            style={{
              padding: "6px 12px",
              borderRadius: 8,
              border: `1px solid ${estado === e ? BRAND.primary : C.border}`,
              background: estado === e ? C.blueDim : C.card,
              color: estado === e ? BRAND.primary : C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {e === "DATO_FALTANTE" ? "SIN COSTO" : e}
          </button>
        ))}
      </div>

      {pendientes && (
        <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
          <button
            type="button"
            onClick={() => aprobar([...sel])}
            style={btnPrimary}
          >
            Aprobar seleccionadas ({sel.size})
          </button>
          <button
            type="button"
            onClick={() => rechazar([...sel])}
            style={btnGhost}
          >
            Rechazar seleccionadas
          </button>
        </div>
      )}

      {loading ? (
        <p style={{ color: C.textMid }}>Cargando…</p>
      ) : rows.length === 0 ? (
        <p style={{ color: C.textMid, fontSize: 13 }}>
          No hay propuestas en este filtro. Corre el SQL del motor y el job
          <code style={{ marginLeft: 6 }}>/api/caducidad/job</code>.
        </p>
      ) : (
        <div style={{ overflowX: "auto", border: `1px solid ${C.border}`, borderRadius: 10, background: C.card }}>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
            <thead>
              <tr style={{ background: C.cardDark, textAlign: "left" }}>
                {pendientes && (
                  <th style={th}>
                    <input type="checkbox" checked={sel.size === rows.length} onChange={toggleAll} />
                  </th>
                )}
                <th style={th}>Producto / lote</th>
                <th style={th}>Caduca</th>
                <th style={{ ...th, textAlign: "right" }}>Pz</th>
                <th style={{ ...th, textAlign: "right" }}>Costo</th>
                <th style={{ ...th, textAlign: "right" }}>PVP</th>
                <th style={{ ...th, textAlign: "right" }}>Propuesto</th>
                <th style={{ ...th, textAlign: "right" }}>Desc.</th>
                <th style={{ ...th, textAlign: "right" }}>En riesgo</th>
                <th style={th}></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id} style={{ borderTop: `1px solid ${C.border}` }}>
                  {pendientes && (
                    <td style={td}>
                      <input
                        type="checkbox"
                        checked={sel.has(r.id)}
                        onChange={() => toggle(r.id)}
                      />
                    </td>
                  )}
                  <td style={td}>
                    <div style={{ fontWeight: 700 }}>{r.nombre || "—"}</div>
                    <div style={{ color: C.textDim, fontSize: 11 }}>
                      {r.sku} · lote {r.numero_lote || r.lote_id}
                      {r.fase ? ` · fase ${r.fase}` : ""}
                      {r.motivo === "SELLTHROUGH_INSUFICIENTE" ? " · poco sell-through" : ""}
                    </div>
                    {(promosByProducto[r.producto_id] || promosByProducto[String(r.producto_id)]) && (
                      <div style={{ color: C.amber, fontSize: 11, fontWeight: 700, marginTop: 4 }}>
                        Este SKU tiene promo ({(promosByProducto[r.producto_id] || promosByProducto[String(r.producto_id)]).join(", ")}). Esta caja no la usará.
                      </div>
                    )}
                  </td>
                  <td style={td}>
                    {formatCaducidadMesAnio(r.fecha_caducidad) || "—"}
                    <div style={{ color: Number(r.dias_restantes) <= 30 ? C.red : C.textDim, fontSize: 11 }}>
                      {r.dias_restantes != null ? `${r.dias_restantes} d` : ""}
                    </div>
                  </td>
                  <td style={{ ...td, textAlign: "right" }}>{r.existencia}</td>
                  <td style={{ ...td, textAlign: "right" }}>{money(r.costo_unitario)}</td>
                  <td style={{ ...td, textAlign: "right" }}>{money(r.pvp)}</td>
                  <td style={{ ...td, textAlign: "right", fontWeight: 800 }}>
                    {r.precio_propuesto != null ? money(r.precio_propuesto) : "—"}
                    {r.perdida_pieza > 0 && (
                      <div style={{ color: C.red, fontSize: 10 }}>
                        −{money(r.perdida_pieza)}/pz
                      </div>
                    )}
                  </td>
                  <td style={{ ...td, textAlign: "right" }}>{pct(r.descuento_efectivo)}</td>
                  <td style={{ ...td, textAlign: "right", fontWeight: 700 }}>{money(r.capital_en_riesgo)}</td>
                  <td style={td}>
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap", justifyContent: "flex-end" }}>
                      <button type="button" style={btnTiny} onClick={() => verEtiqueta(r)}>Etiqueta</button>
                      {pendientes && (
                        <>
                          <button type="button" style={btnTiny} onClick={() => aprobar([r.id])} disabled={busy}>
                            Aprobar
                          </button>
                          <button
                            type="button"
                            style={btnTiny}
                            onClick={() => {
                              setEditId(r.id);
                              setEditPrecio(String(r.precio_propuesto ?? ""));
                            }}
                          >
                            Editar
                          </button>
                          <button type="button" style={btnTiny} onClick={() => rechazar([r.id])} disabled={busy}>
                            Rechazar
                          </button>
                        </>
                      )}
                    </div>
                    {editId === r.id && (
                      <div style={{ marginTop: 8, display: "flex", gap: 6, justifyContent: "flex-end" }}>
                        <input
                          type="number"
                          step="0.5"
                          min={r.precio_piso || 0}
                          value={editPrecio}
                          onChange={(e) => setEditPrecio(e.target.value)}
                          style={{
                            width: 88,
                            padding: "6px 8px",
                            borderRadius: 6,
                            border: `1px solid ${C.border}`,
                            fontSize: 12,
                          }}
                        />
                        <button
                          type="button"
                          style={btnTiny}
                          onClick={() => aprobar([r.id], editPrecio)}
                        >
                          Guardar y aprobar
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {etiqueta && (
        <div
          role="dialog"
          style={{
            position: "fixed",
            inset: 0,
            background: "rgba(15,23,42,0.35)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            zIndex: 40,
            padding: 16,
          }}
          onClick={() => setEtiqueta(null)}
        >
          <div
            style={{
              background: C.card,
              borderRadius: 12,
              padding: 20,
              width: "min(420px, 100%)",
              border: `1px solid ${C.border}`,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ fontWeight: 800, marginBottom: 10 }}>Etiqueta de anaquel</div>
            <pre style={{
              whiteSpace: "pre-wrap",
              fontFamily: "ui-monospace, Menlo, monospace",
              fontSize: 13,
              background: C.cardDark,
              padding: 12,
              borderRadius: 8,
              margin: 0,
            }}
            >
              {etiqueta}
            </pre>
            <div style={{ display: "flex", gap: 8, marginTop: 12, justifyContent: "flex-end" }}>
              <button type="button" style={btnGhost} onClick={() => setEtiqueta(null)}>Cerrar</button>
              <button type="button" style={btnPrimary} onClick={copiarEtiqueta}>Copiar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function Stat({ label, value }) {
  return (
    <div style={{
      background: C.card,
      border: `1px solid ${C.border}`,
      borderRadius: 10,
      padding: "10px 14px",
      minWidth: 140,
    }}
    >
      <div style={{ fontSize: 16, fontWeight: 800, color: C.text }}>{value}</div>
      <div style={{ fontSize: 11, color: C.textDim }}>{label}</div>
    </div>
  );
}

const th = { padding: "8px 10px", fontSize: 10, textTransform: "uppercase", letterSpacing: "0.04em", color: C.textDim };
const td = { padding: "8px 10px", verticalAlign: "top" };
const btnPrimary = {
  padding: "8px 14px",
  borderRadius: 8,
  border: "none",
  background: BRAND.primary,
  color: "#fff",
  fontWeight: 700,
  fontSize: 12,
  cursor: "pointer",
};
const btnGhost = {
  padding: "8px 14px",
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  background: C.card,
  color: C.textMid,
  fontWeight: 700,
  fontSize: 12,
  cursor: "pointer",
};
const btnTiny = {
  padding: "4px 8px",
  borderRadius: 6,
  border: `1px solid ${C.border}`,
  background: C.card,
  color: C.text,
  fontWeight: 700,
  fontSize: 11,
  cursor: "pointer",
};
