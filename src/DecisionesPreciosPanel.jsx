import { useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";
import {
  DECISION_META,
  TIPO_DECISION,
  filtrarDecisiones,
  resumenDecisiones,
  textoConfirmacionAplicar,
} from "./lib/decisionesPrecios";
import { CANALES_VENTA, labelCanales } from "./lib/canalesVenta";
import { fmtPrecioRef, fmtPrecioVenta } from "./lib/preciosReferencia";

const C = C_LIGHT;

function fmtImpactoSafe(n) {
  if (n == null || !Number.isFinite(Number(n)) || Number(n) === 0) return "—";
  return fmtPrecioRef(n);
}

function haceCuanto(ts) {
  if (!ts) return "sin revisar";
  const min = Math.max(0, Math.round((Date.now() - ts) / 60000));
  if (min < 1) return "ahora";
  if (min === 1) return "hace 1 min";
  return `hace ${min} min`;
}

function toneColors(tone) {
  if (tone === "critica") return { bg: C.redDim, fg: C.red };
  if (tone === "caro") return { bg: C.redDim, fg: C.red };
  if (tone === "piso") return { bg: C.amberDim, fg: C.amber };
  if (tone === "subir") return { bg: C.blueDim, fg: C.blue };
  if (tone === "compra") return { bg: C.blueDim, fg: C.blue };
  if (tone === "rappi") return { bg: C.tealDim, fg: C.teal };
  return { bg: C.cardDark, fg: C.textMid };
}

async function aplicarDecision(d) {
  const ok = window.confirm(textoConfirmacionAplicar(d));
  if (!ok) return null;
  const tok = sessionStorage.getItem("farmacapital_session_token");
  const { error } = await supabase.rpc("admin_editar_producto", {
    p_session_token: tok,
    p_producto_id: d.producto_id,
    p_patch: { precio: d.sugerido },
  });
  if (error) throw error;
  return d.sugerido;
}

/**
 * Bandeja del agente de precios. Presentacional + aplicar/posponer.
 * variant: "referencias" | "rappi" | "marketplace"
 */
export default function DecisionesPreciosPanel({
  decisiones,
  loading,
  revisadoAt,
  onRefresh,
  onPosponer,
  onApplied,
  applyingId,
  setApplyingId,
  variant = "referencias",
  filtroInicial,
}) {
  const esApps = variant === "rappi" || variant === "marketplace";
  const [filtro, setFiltro] = useState(filtroInicial || (esApps ? "rappi" : "todas"));
  const [busq, setBusq] = useState("");
  const [busyId, setBusyId] = useState(null);

  const visibles = useMemo(() => {
    const scoped = filtrarDecisiones(decisiones, esApps && filtro === "todas" ? "rappi" : filtro);
    if (!busq.trim()) return scoped;
    return scoped.filter((d) => inventarioProductMatchesBusqueda({
      nombre: d.nombre,
      sku: d.sku,
    }, busq));
  }, [decisiones, filtro, busq, esApps]);

  const resumen = useMemo(() => resumenDecisiones(decisiones), [decisiones]);

  const aplicar = async (d) => {
    if (!d.puede_aplicar || d.sugerido == null) return;
    const setBusy = setApplyingId || setBusyId;
    setBusy(d.producto_id);
    try {
      const precio = await aplicarDecision(d);
      if (precio == null) return;
      showToast(`Precio ${fmtPrecioVenta(precio)} en «${d.nombre}»`, "success");
      if (onApplied) onApplied(d.producto_id, precio);
    } catch (err) {
      showToast(err.message || "No se pudo aplicar", "error");
    } finally {
      setBusy(null);
    }
  };

  const pills = esApps
    ? [
      ["rappi", `Rappi ${resumen.rappi}`],
      ["uber", `Uber ${resumen.uber}${CANALES_VENTA.uber.activo ? "" : " · pronto"}`],
      ["didi", `DiDi ${resumen.didi}${CANALES_VENTA.didi.activo ? "" : " · pronto"}`],
      ["caro", `Caro vs mercado ${resumen.caro}`],
      ["margen", `Margen ${resumen.margen}`],
      ["criticas", `Críticas ${resumen.criticas}`],
    ]
    : [
      ["todas", `Todas ${resumen.total}`],
      ["caro", `Caro vs mercado ${resumen.caro}`],
      ["margen", `Margen ${resumen.margen}`],
      ["compra", `Compra ${resumen.compra}`],
      ["rappi", `Rappi ${resumen.rappi}`],
      ["uber", `Uber ${resumen.uber}`],
      ["didi", `DiDi ${resumen.didi}`],
      ["criticas", `Críticas ${resumen.criticas}`],
    ];

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 12, flexWrap: "wrap", marginBottom: 12 }}>
        <p style={{ margin: 0, color: C.textMid, fontSize: 12, maxWidth: 640, lineHeight: 1.45 }}>
          {esApps
            ? "Mismas referencias de compra y venta que el catálogo. Rappi está vivo (stock, no precio). Uber y DiDi usarán este mismo precio cuando se conecten."
            : "Revisa compra y venta de Referencias. El precio de mostrador es el de Rappi y, más adelante, Uber y DiDi. No aplica solo: tú confirmas."}
        </p>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ fontSize: 11, color: C.textDim }}>
            Revisado {haceCuanto(revisadoAt)} · cada 3 min
          </span>
          <button
            type="button"
            onClick={() => onRefresh && onRefresh()}
            style={{
              padding: "6px 12px", borderRadius: 8, border: `1px solid ${C.border}`,
              background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
            }}
          >
            ↻ Revisar ahora
          </button>
        </div>
      </div>

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
        {pills.map(([id, label]) => {
          const on = filtro === id;
          return (
            <button
              key={id}
              type="button"
              onClick={() => setFiltro(id)}
              style={{
                padding: "4px 12px",
                borderRadius: 20,
                border: "none",
                cursor: "pointer",
                fontSize: 11,
                fontWeight: 700,
                background: on ? C.blueDim : C.cardDark,
                color: on ? C.blue : C.textMid,
              }}
            >
              {label}
            </button>
          );
        })}
      </div>

      <input
        placeholder="🔍 Buscar en la bandeja…"
        value={busq}
        onChange={(e) => setBusq(e.target.value)}
        style={{
          padding: "8px 12px",
          borderRadius: 8,
          border: `1px solid ${C.border}`,
          fontSize: 13,
          outline: "none",
          background: C.card,
          color: C.text,
          maxWidth: 280,
          marginBottom: 12,
          width: "100%",
        }}
      />

      {loading && !decisiones.length ? (
        <div style={{ padding: 28, color: C.textMid, fontSize: 13 }}>Revisando referencias…</div>
      ) : !visibles.length ? (
        <div style={{
          padding: 22, borderRadius: 10, background: C.greenDim, color: C.greenDark,
          fontSize: 13, fontWeight: 600,
        }}>
          {esApps
            ? "Nada pendiente en este canal con las referencias de hoy."
            : "Sin decisiones pendientes. El agente sigue revisando cada 3 minutos."}
        </div>
      ) : (
        <div style={{ overflowX: "auto" }}>
          <table className="fc-tabla-cards" style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
            <thead>
              <tr style={{ background: C.cardDark, textAlign: "left", color: C.textDim }}>
                <th style={th}>Producto</th>
                <th style={th}>Decisión</th>
                <th style={{ ...th, textAlign: "right" }}>Actual</th>
                <th style={{ ...th, textAlign: "right" }}>Sugerido / lista</th>
                <th style={{ ...th, textAlign: "right" }}>Impacto</th>
                <th style={th}>Nota</th>
                <th style={th}>Acción</th>
              </tr>
            </thead>
            <tbody>
              {visibles.map((d) => {
                const meta = DECISION_META[d.tipo] || { label: d.tipo, tone: "neutral" };
                const col = toneColors(meta.tone);
                const busy = (applyingId ?? busyId) === d.producto_id;
                const valorLista = d.ambito === "compra"
                  ? `${d.mejor_label || ""} ${fmtPrecioRef(d.mejor_precio)}`
                  : (d.sugerido != null ? fmtPrecioVenta(d.sugerido) : "—");
                return (
                  <tr key={d.clave} style={{ borderTop: `1px solid ${C.border}` }}>
                    <td data-label="Producto" data-primary style={td}>
                      <div style={{ fontWeight: 700, color: C.text }}>{d.nombre}</div>
                      <div style={{ fontSize: 10, color: C.textDim }}>{d.sku}</div>
                    </td>
                    <td data-label="Decisión" style={td}>
                      <span style={{
                        display: "inline-block",
                        padding: "2px 8px",
                        borderRadius: 999,
                        background: col.bg,
                        color: col.fg,
                        fontWeight: 800,
                        fontSize: 10,
                      }}>
                        {meta.chip}
                      </span>
                      {d.rappi && d.tipo !== TIPO_DECISION.RAPPI_SIN_REF ? (
                        <div style={{ fontSize: 10, color: C.teal, fontWeight: 700, marginTop: 4 }}>También Rappi</div>
                      ) : null}
                      {(d.canales_futuros || []).length ? (
                        <div style={{ fontSize: 10, color: C.textDim, fontWeight: 700, marginTop: 2 }}>
                          Luego {labelCanales(d.canales_futuros).join(" · ")}
                        </div>
                      ) : null}
                    </td>
                    <td data-label="Actual" style={{ ...td, textAlign: "right", fontWeight: 700, color: BRAND.primary }}>
                      {d.precio_actual != null ? fmtPrecioVenta(d.precio_actual) : "—"}
                    </td>
                    <td data-label="Sugerido / lista" style={{ ...td, textAlign: "right", fontWeight: 800 }}>
                      {valorLista}
                    </td>
                    <td data-label="Impacto" style={{ ...td, textAlign: "right" }}>
                      {fmtImpactoSafe(d.impacto)}
                    </td>
                    <td data-label="Nota" data-wide style={{ ...td, fontSize: 11, color: C.textMid, maxWidth: 360 }}>
                      {d.detalle}
                    </td>
                    <td data-label="Acción" style={td}>
                      <div style={{ display: "flex", flexDirection: "column", gap: 4, alignItems: "flex-start" }}>
                        {d.puede_aplicar ? (
                          <button
                            type="button"
                            disabled={busy}
                            onClick={() => aplicar(d)}
                            style={{
                              padding: "4px 10px",
                              borderRadius: 6,
                              border: "none",
                              background: BRAND.gradient,
                              color: "#fff",
                              cursor: "pointer",
                              fontSize: 11,
                              fontWeight: 700,
                              opacity: busy ? 0.6 : 1,
                            }}
                          >
                            {busy ? "…" : "Aplicar"}
                          </button>
                        ) : (
                          <span style={{ color: C.textDim, fontSize: 10 }}>
                            {d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO ? "Revisar a mano" : "—"}
                          </span>
                        )}
                        <button
                          type="button"
                          onClick={() => onPosponer && onPosponer(d.clave)}
                          style={{
                            padding: "2px 6px",
                            borderRadius: 5,
                            border: `1px solid ${C.border}`,
                            background: C.card,
                            color: C.textMid,
                            cursor: "pointer",
                            fontSize: 9,
                            fontWeight: 700,
                          }}
                        >
                          Posponer 24 h
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

const th = {
  padding: "9px 12px",
  fontWeight: 700,
  whiteSpace: "nowrap",
};

const td = {
  padding: "8px 12px",
  verticalAlign: "top",
  color: C.text,
};
