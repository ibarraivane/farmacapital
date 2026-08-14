import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync, SkeletonTable } from "./ui";
import {
  FUENTES_COMPRA,
  FUENTES_VENTA,
  FUENTE_META,
  buildReferenciasPorProducto,
  dedupeReferenciasActuales,
  diffPctCompra,
  diffPctVenta,
  calcMejorCompra,
  calcPrecioSugeridoVenta,
  colorDiffCompra,
  colorDiffVenta,
  fmtPrecioRef,
} from "./lib/preciosReferencia";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";
import ImportReferenciaPrecios from "./components/ImportReferenciaPrecios";

const BRAND = { primary: "#0D1B2A", gradient: "linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const COL_DEFAULTS_COMPRA = {
  producto: 220,
  sku: 108,
  costo: 88,
  exprezo: 96,
  marzam: 96,
  nadro: 96,
  levic: 96,
  mejor: 150,
};

const COL_DEFAULTS_VENTA = {
  producto: 220,
  tuVenta: 92,
  fahorro: 96,
  similares: 96,
  refMin: 88,
  sugerido: 92,
  nota: 150,
  accion: 88,
};

const COL_LABELS_COMPRA = {
  producto: "Producto",
  sku: "SKU",
  costo: "Tu costo",
  exprezo: "Exprezo",
  marzam: "Marzam",
  nadro: "Nadro",
  levic: "Levic",
  mejor: "Mejor proveedor",
};

const COL_LABELS_VENTA = {
  producto: "Producto",
  tuVenta: "Tu venta",
  fahorro: "Del Ahorro",
  similares: "Similares",
  refMin: "Ref. mín.",
  sugerido: "Sugerido",
  nota: "Nota",
  accion: "Acción",
};

function loadColWidths(tab) {
  const defaults = tab === "compra" ? COL_DEFAULTS_COMPRA : COL_DEFAULTS_VENTA;
  try {
    const raw = JSON.parse(localStorage.getItem(`farmacapital_precios_ref_cols_${tab}`) || "{}");
    return { ...defaults, ...raw };
  } catch {
    return { ...defaults };
  }
}

function colStyle(colWidths, colId) {
  const w = Math.max(60, Number(colWidths[colId]) || 80);
  return { width: w, minWidth: w, maxWidth: w };
}

function DiffBadge({ pct, mode, C }) {
  if (pct == null) return <span style={{ color: C.textDim }}>—</span>;
  const tone = mode === "compra" ? colorDiffCompra(pct) : colorDiffVenta(pct);
  const col =
    tone === "oportunidad" || tone === "ok" ? C.green :
    tone === "caro" ? C.red : C.textMid;
  const bg =
    tone === "oportunidad" || tone === "ok" ? C.greenDim :
    tone === "caro" ? C.redDim : C.cardDark;
  const prefix = parseFloat(pct) > 0 ? "+" : "";
  return (
    <span style={{ padding: "2px 7px", borderRadius: 20, fontSize: 10, fontWeight: 700, color: col, background: bg }}>
      {prefix}{pct}%
    </span>
  );
}

function EditablePrecioCell({
  C,
  cellKey,
  value,
  display,
  align = "left",
  inlineEdit,
  saving,
  onStart,
  onDraft,
  onCommit,
  onCancel,
  tdStyle,
}) {
  const isEditing = inlineEdit?.key === cellKey;
  const rowBg = tdStyle?.background;

  if (isEditing) {
    return (
      <td style={{ ...tdStyle, textAlign: align }}>
        <input
          type="number"
          step="0.01"
          min="0"
          autoFocus
          disabled={saving}
          value={inlineEdit.draft}
          onChange={(e) => onDraft(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") { e.preventDefault(); onCommit(); }
            if (e.key === "Escape") { e.preventDefault(); onCancel(); }
          }}
          onBlur={() => { if (!saving) onCommit(); }}
          style={{
            width: "100%",
            padding: "4px 6px",
            fontSize: 11,
            boxSizing: "border-box",
            border: `1px solid ${C.blue}`,
            borderRadius: 4,
            textAlign: align === "right" ? "right" : "left",
          }}
        />
      </td>
    );
  }

  return (
    <td
      style={{ ...tdStyle, textAlign: align, cursor: "pointer" }}
      title="Clic para editar"
      onMouseDown={(e) => e.preventDefault()}
      onClick={(e) => {
        e.stopPropagation();
        onStart(cellKey, value);
      }}
      onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(30, 58, 138, 0.07)"; }}
      onMouseLeave={(e) => { e.currentTarget.style.background = rowBg || ""; }}
    >
      {display}
    </td>
  );
}

function ColumnSizer({ tab, colWidths, setColWidths, C }) {
  const labels = tab === "compra" ? COL_LABELS_COMPRA : COL_LABELS_VENTA;
  const defaults = tab === "compra" ? COL_DEFAULTS_COMPRA : COL_DEFAULTS_VENTA;
  const ranges = {
    producto: [140, 420],
    sku: [80, 180],
    costo: [70, 140],
    tuVenta: [70, 140],
    exprezo: [70, 160],
    marzam: [70, 160],
    nadro: [70, 160],
    levic: [70, 160],
    fahorro: [70, 160],
    similares: [70, 160],
    refMin: [70, 140],
    sugerido: [70, 140],
    nota: [100, 280],
    accion: [70, 140],
    mejor: [100, 260],
  };

  return (
    <div style={{
      marginBottom: 12, padding: "10px 12px", borderRadius: 10,
      background: C.card, border: `1px solid ${C.border}`,
    }}>
      <div style={{ fontSize: 11, color: C.textMid, marginBottom: 10 }}>
        Ancho de columnas (se guarda en este navegador). Clic en un precio de la tabla para editarlo.
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))", gap: 10 }}>
        {Object.keys(defaults).map((key) => {
          const [min, max] = ranges[key] || [60, 320];
          return (
            <label key={key} style={{ display: "block", fontSize: 11, color: C.textMid }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                <span>{labels[key] || key}</span>
                <strong style={{ color: C.text }}>{colWidths[key]}px</strong>
              </div>
              <input
                type="range"
                min={min}
                max={max}
                step={2}
                value={colWidths[key]}
                onChange={(e) => setColWidths((p) => ({ ...p, [key]: Number(e.target.value) }))}
                style={{ width: "100%" }}
              />
            </label>
          );
        })}
      </div>
      <button
        type="button"
        onClick={() => setColWidths({ ...defaults })}
        style={{
          marginTop: 10, padding: "5px 10px", borderRadius: 6, border: `1px solid ${C.border}`,
          background: C.cardDark, color: C.textMid, fontSize: 11, cursor: "pointer",
        }}
      >
        Restablecer anchos
      </button>
    </div>
  );
}

function TablaCompra({
  productos, refsByProduct, C, busq, colWidths,
  inlineEdit, savingKey, onStartEdit, onDraft, onCommit, onCancel,
}) {
  const fil = productos.filter((p) => inventarioProductMatchesBusqueda(p, busq));
  const thS = (colId) => ({ ...th(C), ...colStyle(colWidths, colId) });
  const tdS = (colId, extra = {}) => ({ ...td(C), ...colStyle(colWidths, colId), ...extra });

  return (
    <HorizontalScrollSync>
      <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12, tableLayout: "fixed" }}>
        <thead>
          <tr style={{ background: C.cardDark }}>
            <th style={thS("producto")}>Producto</th>
            <th style={thS("sku")}>SKU</th>
            <th style={{ ...thS("costo"), textAlign: "right" }}>Tu costo</th>
            {FUENTES_COMPRA.map((id) => (
              <th key={id} style={{ ...thS(id), textAlign: "right" }} title={FUENTE_META[id]?.listaDistribuidor ? "Precio lista distribuidor" : ""}>
                {FUENTE_META[id]?.label}
              </th>
            ))}
            <th style={thS("mejor")}>Mejor proveedor</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={4 + FUENTES_COMPRA.length} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const mejor = calcMejorCompra(p.costo, refs);
            const rowBg = i % 2 ? "#f8fafc" : "transparent";

            return (
              <tr key={p.id} style={{ background: rowBg }}>
                <td style={{ ...tdS("producto"), background: rowBg }}>{p.nombre}</td>
                <td style={{ ...tdS("sku", { fontFamily: "monospace", fontSize: 10, color: C.textMid, background: rowBg }) }}>{p.sku || "—"}</td>
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:costo`}
                  value={p.costo != null ? String(p.costo) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:costo`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("costo", { fontWeight: 700, background: rowBg }) }}
                  display={fmtPrecioRef(p.costo)}
                />
                {FUENTES_COMPRA.map((id) => {
                  const precio = refs[id]?.precio;
                  const pct = diffPctCompra(p.costo, precio);
                  const tone = colorDiffCompra(pct);
                  const col =
                    tone === "oportunidad" ? C.blue :
                    tone === "caro" ? C.red : C.textMid;
                  return (
                    <EditablePrecioCell
                      key={id}
                      C={C}
                      cellKey={`${p.id}:ref:${id}`}
                      value={precio != null ? String(precio) : ""}
                      align="right"
                      inlineEdit={inlineEdit}
                      saving={savingKey === `${p.id}:ref:${id}`}
                      onStart={onStartEdit}
                      onDraft={onDraft}
                      onCommit={onCommit}
                      onCancel={onCancel}
                      tdStyle={{ ...tdS(id, { background: rowBg }) }}
                      display={precio != null ? (
                        <div>
                          <span style={{ color: col, fontWeight: 600 }}>{fmtPrecioRef(precio)}</span>
                          <div><DiffBadge pct={pct} mode="compra" C={C} /></div>
                        </div>
                      ) : "—"}
                    />
                  );
                })}
                <td style={{ ...tdS("mejor", { background: rowBg }) }}>
                  {mejor ? (
                    <span style={{ fontWeight: 700, color: mejor.masBaratoQueTuCosto ? C.blue : C.text }}>
                      {mejor.label}
                      {mejor.masBaratoQueTuCosto && mejor.ahorro != null ? (
                        <span style={{ fontSize: 10, color: C.blue, marginLeft: 4 }}>
                          (−{fmtPrecioRef(mejor.ahorro)})
                        </span>
                      ) : null}
                    </span>
                  ) : (
                    <span style={{ color: C.textDim, fontSize: 11 }}>Sin datos</span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </HorizontalScrollSync>
  );
}

function TablaVenta({
  productos, refsByProduct, C, busq, colWidths,
  inlineEdit, savingKey, onStartEdit, onDraft, onCommit, onCancel,
  onAplicar, applyingId,
}) {
  const fil = productos.filter((p) => inventarioProductMatchesBusqueda(p, busq));
  const thS = (colId) => ({ ...th(C), ...colStyle(colWidths, colId) });
  const tdS = (colId, extra = {}) => ({ ...td(C), ...colStyle(colWidths, colId), ...extra });

  return (
    <HorizontalScrollSync>
      <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12, tableLayout: "fixed" }}>
        <thead>
          <tr style={{ background: C.cardDark }}>
            <th style={thS("producto")}>Producto</th>
            <th style={{ ...thS("tuVenta"), textAlign: "right" }}>Tu venta</th>
            <th style={{ ...thS("fahorro"), textAlign: "right" }}>Del Ahorro</th>
            <th style={{ ...thS("similares"), textAlign: "right" }}>Similares</th>
            <th style={{ ...thS("refMin"), textAlign: "right" }}>Ref. mín.</th>
            <th style={{ ...thS("sugerido"), textAlign: "right" }}>Sugerido</th>
            <th style={thS("nota")}>Nota</th>
            <th style={thS("accion")}>Acción</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={8} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const fah = refs.fahorro?.precio;
            const sim = refs.similares?.precio;
            const dAho = diffPctVenta(p.precio, fah);
            const dSim = diffPctVenta(p.precio, sim);
            const { sugerido, refMin, nota } = calcPrecioSugeridoVenta(p, refs);
            const puedeAplicar = sugerido != null && Math.abs((parseFloat(p.precio) || 0) - sugerido) >= 0.01;
            const rowBg = i % 2 ? "#f8fafc" : "transparent";

            return (
              <tr key={p.id} style={{ background: rowBg }}>
                <td style={{ ...tdS("producto", { background: rowBg }) }}>{p.nombre}</td>
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:precio`}
                  value={p.precio != null ? String(p.precio) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:precio`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("tuVenta", { fontWeight: 700, color: BRAND.primary, background: rowBg }) }}
                  display={fmtPrecioRef(p.precio)}
                />
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:ref:fahorro`}
                  value={fah != null ? String(fah) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:ref:fahorro`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("fahorro", { background: rowBg }) }}
                  display={fah != null ? (
                    <>
                      <div>{fmtPrecioRef(fah)}</div>
                      <DiffBadge pct={dAho} mode="venta" C={C} />
                    </>
                  ) : "—"}
                />
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:ref:similares`}
                  value={sim != null ? String(sim) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:ref:similares`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("similares", { background: rowBg }) }}
                  display={sim != null ? (
                    <>
                      <div>{fmtPrecioRef(sim)}</div>
                      <DiffBadge pct={dSim} mode="venta" C={C} />
                    </>
                  ) : "—"}
                />
                <td style={{ ...tdS("refMin", { textAlign: "right", color: C.textMid, background: rowBg }) }}>
                  {refMin != null ? fmtPrecioRef(refMin) : "—"}
                </td>
                <td style={{ ...tdS("sugerido", { textAlign: "right", fontWeight: 800, color: sugerido != null ? C.green : C.textDim, background: rowBg }) }}>
                  {sugerido != null ? fmtPrecioRef(sugerido) : "—"}
                </td>
                <td style={{ ...tdS("nota", { fontSize: 10, color: C.textMid, background: rowBg }) }}>{nota}</td>
                <td style={{ ...tdS("accion", { background: rowBg }) }}>
                  {puedeAplicar ? (
                    <button
                      type="button"
                      disabled={applyingId === p.id}
                      onClick={() => onAplicar(p, sugerido)}
                      style={{
                        padding: "4px 10px", borderRadius: 6, border: "none",
                        background: BRAND.gradient, color: "#fff", cursor: "pointer",
                        fontSize: 11, fontWeight: 700, opacity: applyingId === p.id ? 0.6 : 1,
                      }}
                    >
                      {applyingId === p.id ? "…" : "Aplicar"}
                    </button>
                  ) : (
                    <span style={{ color: C.textDim, fontSize: 10 }}>—</span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </HorizontalScrollSync>
  );
}

const th = (C) => ({
  padding: "9px 12px",
  textAlign: "left",
  color: C.textMid,
  fontWeight: 700,
  borderBottom: `1px solid ${C.border}`,
  whiteSpace: "nowrap",
  overflow: "hidden",
  textOverflow: "ellipsis",
});

const td = (C) => ({
  padding: "8px 12px",
  borderBottom: `1px solid ${C.border}`,
  color: C.text,
  verticalAlign: "top",
  overflow: "hidden",
});

export default function PreciosReferenciaModule() {
  const C = C_LIGHT;
  const [tab, setTab] = useState("compra");
  const [productos, setProductos] = useState([]);
  const [refsByProduct, setRefsByProduct] = useState({});
  const [loading, setLoading] = useState(true);
  const [schemaOk, setSchemaOk] = useState(true);
  const [busq, setBusq] = useState("");
  const [applyingId, setApplyingId] = useState(null);
  const [showColSizer, setShowColSizer] = useState(false);
  const [colWidthsCompra, setColWidthsCompra] = useState(() => loadColWidths("compra"));
  const [colWidthsVenta, setColWidthsVenta] = useState(() => loadColWidths("venta"));
  const [inlineEdit, setInlineEdit] = useState(null);
  const [savingKey, setSavingKey] = useState(null);

  const colWidths = tab === "compra" ? colWidthsCompra : colWidthsVenta;
  const setColWidths = tab === "compra" ? setColWidthsCompra : setColWidthsVenta;

  useEffect(() => {
    try {
      localStorage.setItem("farmacapital_precios_ref_cols_compra", JSON.stringify(colWidthsCompra));
    } catch { /* noop */ }
  }, [colWidthsCompra]);

  useEffect(() => {
    try {
      localStorage.setItem("farmacapital_precios_ref_cols_venta", JSON.stringify(colWidthsVenta));
    } catch { /* noop */ }
  }, [colWidthsVenta]);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const prodRes = await supabase
      .from("productos")
      .select("id,sku,nombre,categoria,tipo,costo,precio,principio_activo,forma_farmaceutica,requiere_receta,marca")
      .eq("activo", true)
      .order("nombre");

    if (prodRes.error) {
      showToast("Error cargando productos: " + prodRes.error.message, "error");
      setLoading(false);
      return;
    }
    setProductos(prodRes.data || []);

    let refRows = [];
    const viewRes = await supabase.from("producto_precios_referencia_actual").select("*");
    if (viewRes.error) {
      const rawRes = await supabase
        .from("producto_precios_referencia")
        .select("producto_id,fuente,tipo,precio,fecha,origen,confianza,created_at,nombre_fuente")
        .order("fecha", { ascending: false })
        .limit(10000);
      if (rawRes.error) {
        setSchemaOk(false);
        setRefsByProduct({});
        setLoading(false);
        return;
      }
      refRows = dedupeReferenciasActuales(rawRes.data);
    } else {
      refRows = viewRes.data || [];
    }

    setSchemaOk(true);
    setRefsByProduct(buildReferenciasPorProducto(refRows));
    setLoading(false);
  }, []);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  const stats = useMemo(() => {
    let compraOportunidad = 0;
    let ventaCaro = 0;
    let sinRefCompra = 0;
    let sinRefVenta = 0;

    for (const p of productos) {
      const refs = refsByProduct[p.id] || {};
      const mejor = calcMejorCompra(p.costo, refs);
      if (mejor?.masBaratoQueTuCosto) compraOportunidad += 1;
      if (!FUENTES_COMPRA.some((f) => refs[f]?.precio != null)) sinRefCompra += 1;

      const { refMin } = calcPrecioSugeridoVenta(p, refs);
      if (refMin == null) sinRefVenta += 1;
      else if ((parseFloat(p.precio) || 0) > refMin) ventaCaro += 1;
    }

    return { compraOportunidad, ventaCaro, sinRefCompra, sinRefVenta };
  }, [productos, refsByProduct]);

  const startEdit = useCallback((key, value) => {
    setInlineEdit({ key, draft: value ?? "" });
  }, []);

  const cancelEdit = useCallback(() => setInlineEdit(null), []);

  const commitEdit = useCallback(async () => {
    if (!inlineEdit?.key) return;
    const { key, draft } = inlineEdit;
    const parts = key.split(":");
    const productoId = Number(parts[0]);
    const producto = productos.find((p) => p.id === productoId);
    if (!producto) {
      cancelEdit();
      return;
    }

    const trimmed = String(draft ?? "").trim();
    const isEmpty = trimmed === "";
    const num = isEmpty ? null : parseFloat(trimmed);
    if (!isEmpty && (!Number.isFinite(num) || num < 0)) {
      showToast("Precio inválido", "error");
      return;
    }

    setSavingKey(key);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const fecha = new Date().toISOString().slice(0, 10);

    try {
      if (parts[1] === "costo") {
        const { error } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: productoId,
          p_patch: { costo: num },
        });
        if (error) throw error;
        setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, costo: num } : x)));
        showToast("Costo actualizado", "success");
      } else if (parts[1] === "precio") {
        const { error } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: productoId,
          p_patch: { precio: num },
        });
        if (error) throw error;
        setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, precio: num } : x)));
        showToast("Precio de venta actualizado", "success");
      } else if (parts[1] === "ref") {
        const fuente = parts[2];
        const meta = FUENTE_META[fuente];
        if (!meta) throw new Error("Fuente desconocida");
        if (num == null) {
          showToast("Indica un precio de referencia", "error");
          return;
        }
        const { error } = await supabase.from("producto_precios_referencia").insert({
          producto_id: productoId,
          fuente,
          tipo: meta.tipo,
          precio: num,
          fecha,
          origen: "manual",
          confianza: 100,
        });
        if (error) throw error;
        setRefsByProduct((prev) => ({
          ...prev,
          [productoId]: {
            ...(prev[productoId] || {}),
            [fuente]: { precio: num, fuente, tipo: meta.tipo },
          },
        }));
        showToast(`Referencia ${meta.label} guardada`, "success");
      }
    } catch (e) {
      showToast(e.message || "Error al guardar", "error");
    } finally {
      setSavingKey(null);
      cancelEdit();
    }
  }, [inlineEdit, productos, cancelEdit]);

  const aplicarPrecio = async (producto, sugerido) => {
    const ok = window.confirm(
      `¿Aplicar precio sugerido ${fmtPrecioRef(sugerido)} a «${producto.nombre}»?\n\nTu precio actual: ${fmtPrecioRef(producto.precio)}`
    );
    if (!ok) return;

    setApplyingId(producto.id);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_editar_producto", {
      p_session_token: tok,
      p_producto_id: producto.id,
      p_patch: { precio: sugerido },
    });
    setApplyingId(null);

    if (error) {
      showToast("Error: " + error.message, "error");
      return;
    }
    showToast("Precio actualizado", "success");
    setProductos((prev) =>
      prev.map((x) => (x.id === producto.id ? { ...x, precio: sugerido } : x))
    );
  };

  const inpS = {
    padding: "8px 12px",
    borderRadius: 8,
    border: `1px solid ${C.border}`,
    fontSize: 13,
    outline: "none",
    background: C.card,
    color: C.text,
  };

  return (
    <div style={{ padding: "0 24px 24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 12, marginBottom: 16 }}>
        <div>
          <h2 style={{ margin: 0, color: C.text, fontSize: 18, fontWeight: 800 }}>Referencias de precio</h2>
          <p style={{ margin: "6px 0 0", color: C.textMid, fontSize: 12, maxWidth: 640, lineHeight: 1.45 }}>
            Precios de mercado (compra y venta). Clic en un precio para editarlo. Tu <strong>costo</strong> y <strong>venta</strong> usan el mismo guardado que Inventario.
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <ImportReferenciaPrecios productos={productos} onImported={fetchAll} />
          <button
            type="button"
            onClick={() => setShowColSizer((v) => !v)}
            style={{
              padding: "8px 14px", borderRadius: 8, border: `1px solid ${C.border}`,
              background: showColSizer ? C.cardDark : C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
            }}
          >
            ↔ Columnas
          </button>
          <button type="button" onClick={fetchAll} style={{
            padding: "8px 14px", borderRadius: 8, border: `1px solid ${C.border}`,
            background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
          }}>
            ↻ Actualizar
          </button>
        </div>
      </div>

      {!schemaOk && (
        <div style={{
          marginBottom: 16, padding: 14, borderRadius: 10,
          background: C.amberDim, border: `1px solid ${C.amber}`, color: C.amber, fontSize: 12,
        }}>
          ⚠️ Falta ejecutar el SQL de referencias en Supabase:{" "}
          <code style={{ fontSize: 11 }}>sql/patch_producto_precios_referencia.sql</code>
          {" "}y la carga inicial{" "}
          <code style={{ fontSize: 11 }}>sql/pricing/generated/carga_inicial_referencias_20260814.sql</code>
        </div>
      )}

      <div style={{ display: "flex", gap: 8, marginBottom: 16, flexWrap: "wrap" }}>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: "#dbeafe", color: C.blue }}>
          Compra más barata disponible: {stats.compraOportunidad}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.redDim, color: C.red }}>
          Venta más cara que ref.: {stats.ventaCaro}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.cardDark, color: C.textMid }}>
          Sin ref. compra: {stats.sinRefCompra}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.cardDark, color: C.textMid }}>
          Sin ref. venta: {stats.sinRefVenta}
        </span>
      </div>

      <div style={{ display: "flex", gap: 4, marginBottom: 16, borderBottom: `1px solid ${C.border}` }}>
        {[["compra", "🛒 Compra (proveedores)"], ["venta", "🏪 Venta (competencia)"]].map(([id, label]) => (
          <button
            key={id}
            type="button"
            onClick={() => { setTab(id); cancelEdit(); }}
            style={{
              padding: "8px 18px", border: "none", cursor: "pointer", fontWeight: 700, fontSize: 12,
              borderRadius: "8px 8px 0 0", background: "transparent",
              color: tab === id ? BRAND.primary : C.textMid,
              borderBottom: tab === id ? `2px solid ${BRAND.primary}` : "2px solid transparent",
            }}
          >
            {label}
          </button>
        ))}
      </div>

      <div style={{ marginBottom: 12, display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
        <input
          placeholder="🔍 Buscar producto…"
          value={busq}
          onChange={(e) => setBusq(e.target.value)}
          style={{ ...inpS, maxWidth: 280 }}
        />
      </div>

      {showColSizer && (
        <ColumnSizer tab={tab} colWidths={colWidths} setColWidths={setColWidths} C={C} />
      )}

      {tab === "compra" && (
        <p style={{ fontSize: 11, color: C.textDim, marginBottom: 10 }}>
          Azul = proveedor más barato que tu costo · Rojo = más caro · Clic en celda de precio para editar.
        </p>
      )}

      {loading ? (
        <SkeletonTable rows={8} cols={8} />
      ) : tab === "compra" ? (
        <TablaCompra
          productos={productos}
          refsByProduct={refsByProduct}
          C={C}
          busq={busq}
          colWidths={colWidthsCompra}
          inlineEdit={inlineEdit}
          savingKey={savingKey}
          onStartEdit={startEdit}
          onDraft={(v) => setInlineEdit((e) => (e ? { ...e, draft: v } : e))}
          onCommit={commitEdit}
          onCancel={cancelEdit}
        />
      ) : (
        <TablaVenta
          productos={productos}
          refsByProduct={refsByProduct}
          C={C}
          busq={busq}
          colWidths={colWidthsVenta}
          inlineEdit={inlineEdit}
          savingKey={savingKey}
          onStartEdit={startEdit}
          onDraft={(v) => setInlineEdit((e) => (e ? { ...e, draft: v } : e))}
          onCommit={commitEdit}
          onCancel={cancelEdit}
          onAplicar={aplicarPrecio}
          applyingId={applyingId}
        />
      )}
    </div>
  );
}
