/** Historia de compras — pestaña dentro de Recibir.
 *  Filas = productos, columnas = tickets (del más nuevo al más viejo).
 *  Cada celda dice a qué costo entró y si esa compra salió más barata,
 *  más cara o igual que la compra anterior de ese mismo producto.
 */
import { useCallback, useEffect, useMemo, useState } from "react";
import { History, Search, Star } from "lucide-react";
import { C_LIGHT } from "../constants";
import { supabase } from "../supabase";
import { showToast, HorizontalScrollSync, SkeletonTable } from "../ui";
import { getSessionToken, esErrorSesionEmpleado } from "../utils";
import { notifySesionEmpleadoInvalida } from "../utils/sesionEmpleadoAuth";
import {
  construirHistorial,
  fechaCorta,
  filtrarFilas,
  soloConComparacion,
} from "../lib/recepcionHistorial";

const ANCHO_PRODUCTO = 210;
const ANCHO_TICKET = 104;
const SCROLL_MAX = "calc(100dvh - 320px)";

const fmtCosto = (n) =>
  n == null ? "—" : `$${Number(n).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

const TONOS = {
  baja:    { color: "#16a34a", bg: "#dcfce7", flecha: "▼" },
  sube:    { color: "#ef4444", bg: "#fee2e2", flecha: "▲" },
  igual:   { color: "#475569", bg: "transparent", flecha: "=" },
  primera: { color: "#1E3ABA", bg: "transparent", flecha: "" },
};

function Celda({ celda, C, ocultarMontos }) {
  if (!celda) {
    return <span style={{ color: C.textDim, fontSize: 11 }}>·</span>;
  }
  const tono = TONOS[celda.tendencia] || TONOS.primera;
  return (
    <div style={{
      background: tono.bg,
      borderRadius: 6,
      padding: "3px 6px",
      display: "inline-block",
      minWidth: 62,
      textAlign: "right",
    }}>
      <div style={{ color: tono.color, fontWeight: 800, fontSize: 12, fontVariantNumeric: "tabular-nums" }}>
        {tono.flecha ? <span style={{ fontSize: 9, marginRight: 2 }}>{tono.flecha}</span> : null}
        {ocultarMontos ? "—" : fmtCosto(celda.costo)}
        {celda.esBase ? (
          <Star size={9} strokeWidth={3} style={{ marginLeft: 3, verticalAlign: "middle" }} />
        ) : null}
      </div>
      <div style={{ color: C.textDim, fontSize: 9.5, fontWeight: 600 }}>
        {celda.cantidad} pz
      </div>
    </div>
  );
}

export default function RecepcionHistorial({ ocultarMontos = false }) {
  const C = C_LIGHT;
  const [loading, setLoading] = useState(true);
  const [payload, setPayload] = useState(null);
  const [q, setQ] = useState("");
  const [soloRepetidos, setSoloRepetidos] = useState(false);

  const cargar = useCallback(async () => {
    const tok = getSessionToken();
    if (!tok) {
      notifySesionEmpleadoInvalida();
      setLoading(false);
      return;
    }
    setLoading(true);
    const { data, error } = await supabase.rpc("recepcion_historial", {
      p_session_token: tok,
      p_limite: 40,
    });
    setLoading(false);
    if (error) {
      const msg = error.message || "";
      if (esErrorSesionEmpleado(msg)) return;
      if (/does not exist|schema cache|recepcion_historial/i.test(msg)) {
        showToast("Falta correr sql/patch_recepcion_historial_20260824.sql en Supabase.", "error");
      } else {
        showToast("No se pudo cargar la historia: " + msg, "error");
      }
      return;
    }
    const raw = typeof data === "string" ? JSON.parse(data || "null") : data;
    setPayload(raw);
  }, []);

  useEffect(() => { cargar(); }, [cargar]);

  const { tickets, filas } = useMemo(() => construirHistorial(payload), [payload]);
  const visibles = useMemo(() => {
    const base = soloRepetidos ? soloConComparacion(filas) : filas;
    return filtrarFilas(base, q);
  }, [filas, q, soloRepetidos]);

  if (loading) {
    return <div style={{ marginTop: 16 }}><SkeletonTable rows={6} cols={6} /></div>;
  }

  if (!tickets.length) {
    return (
      <div style={{
        background: C.card, border: `1px solid ${C.border}`, borderRadius: 14,
        padding: 24, color: C.textMid, fontSize: 13, lineHeight: 1.5, marginTop: 16,
      }}>
        Todavía no hay tickets recibidos. En cuanto cierres una entrada aparece aquí
        con su costo, y la siguiente compra del mismo producto se compara contra esta.
      </div>
    );
  }

  return (
    <div style={{ marginTop: 16 }}>
      <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", marginBottom: 12 }}>
        <div style={{ position: "relative", flex: "1 1 220px", minWidth: 180 }}>
          <Search size={15} style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: C.textDim }} />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Buscar producto o SKU"
            style={{
              width: "100%", boxSizing: "border-box",
              padding: "9px 12px 9px 32px",
              border: `1px solid ${C.border}`, borderRadius: 10,
              fontSize: 13, color: C.text, background: C.card,
            }}
          />
        </div>
        <label style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: 12, color: C.textMid, fontWeight: 600, cursor: "pointer" }}>
          <input
            type="checkbox"
            checked={soloRepetidos}
            onChange={(e) => setSoloRepetidos(e.target.checked)}
          />
          Solo lo comprado más de una vez
        </label>
        <span style={{ color: C.textDim, fontSize: 12 }}>
          {tickets.length} {tickets.length === 1 ? "ticket" : "tickets"} · {visibles.length} de {filas.length} productos
        </span>
      </div>

      <div style={{ display: "flex", gap: 14, flexWrap: "wrap", marginBottom: 10, fontSize: 11, color: C.textMid }}>
        <span><b style={{ color: TONOS.baja.color }}>▼</b> más barato que la compra anterior</span>
        <span><b style={{ color: TONOS.sube.color }}>▲</b> más caro</span>
        <span><b>=</b> igual</span>
        <span><Star size={10} strokeWidth={3} style={{ verticalAlign: "middle" }} /> la base: tu compra más barata</span>
      </div>

      <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, overflow: "hidden" }}>
        <HorizontalScrollSync bodyMaxHeight={SCROLL_MAX}>
          <table style={{
            borderCollapse: "separate", borderSpacing: 0, fontSize: 12,
            tableLayout: "fixed",
            width: ANCHO_PRODUCTO + tickets.length * ANCHO_TICKET,
          }}>
            <thead>
              <tr style={{ background: C.cardDark }}>
                <th style={{
                  width: ANCHO_PRODUCTO, minWidth: ANCHO_PRODUCTO,
                  padding: "8px 12px", textAlign: "left",
                  color: C.textMid, fontWeight: 700,
                  borderBottom: `1px solid ${C.border}`,
                  position: "sticky", left: 0, top: 0, zIndex: 6,
                  background: C.cardDark,
                  boxShadow: `1px 0 0 ${C.border}, 0 1px 0 ${C.border}`,
                }}>
                  Producto
                </th>
                {tickets.map((t) => (
                  <th key={t.id} style={{
                    width: ANCHO_TICKET, minWidth: ANCHO_TICKET,
                    padding: "8px 10px", textAlign: "right",
                    borderBottom: `1px solid ${C.border}`,
                    position: "sticky", top: 0, zIndex: 4,
                    background: C.cardDark,
                    boxShadow: `0 1px 0 ${C.border}`,
                  }} title={t.folio ? `Folio ${t.folio}` : ""}>
                    <div style={{ color: C.text, fontWeight: 800, fontSize: 11.5, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                      {t.quien}
                    </div>
                    <div style={{ color: C.textDim, fontSize: 10, fontWeight: 600 }}>
                      {fechaCorta(t.fecha)}{t.piezas ? ` · ${t.piezas} pz` : ""}
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!visibles.length && (
                <tr>
                  <td colSpan={tickets.length + 1} style={{ textAlign: "center", padding: 28, color: C.textMid }}>
                    Ningún producto coincide.
                  </td>
                </tr>
              )}
              {visibles.map((f, i) => {
                const rowBg = i % 2 ? "#f8fafc" : C.card;
                return (
                  <tr key={f.producto_id}>
                    <td style={{
                      width: ANCHO_PRODUCTO, minWidth: ANCHO_PRODUCTO,
                      padding: "7px 12px",
                      borderBottom: `1px solid ${C.border}`,
                      position: "sticky", left: 0, zIndex: 2,
                      background: rowBg,
                      boxShadow: `1px 0 0 ${C.border}`,
                    }}>
                      <div style={{ color: C.text, fontWeight: 700, fontSize: 12, lineHeight: 1.25 }}>
                        {f.nombre || "(sin nombre)"}
                      </div>
                      <div style={{ color: C.textDim, fontSize: 10, fontFamily: "monospace" }}>
                        {f.sku || "—"}
                      </div>
                      {f.compras > 1 && !ocultarMontos ? (
                        <div style={{ color: C.textMid, fontSize: 10, marginTop: 2 }}>
                          base {fmtCosto(f.minCosto)}
                          {f.tiendaBase ? ` · ${f.tiendaBase}` : ""}
                        </div>
                      ) : null}
                    </td>
                    {tickets.map((t, col) => (
                      <td key={t.id} style={{
                        width: ANCHO_TICKET, minWidth: ANCHO_TICKET,
                        padding: "6px 8px", textAlign: "right",
                        borderBottom: `1px solid ${C.border}`,
                        background: rowBg,
                      }}>
                        <Celda celda={f.celdas[col]} C={C} ocultarMontos={ocultarMontos} />
                      </td>
                    ))}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </HorizontalScrollSync>
      </div>

      <p style={{ color: C.textDim, fontSize: 11, marginTop: 10, lineHeight: 1.5 }}>
        <History size={11} style={{ verticalAlign: "middle", marginRight: 4 }} />
        La estrella marca tu compra más barata: ese es el costo que manda en Referencias de precio.
        Un ticket más caro se guarda aquí, pero no sube el costo.
      </p>
    </div>
  );
}
