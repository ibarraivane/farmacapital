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
  REFERENCIA_ANULADA_NOTA,
  diffPctCompra,
  diffPctVenta,
  calcMejorCompra,
  calcPrecioSugeridoVenta,
  calcMargenVenta,
  precioDesdeMargen,
  margenToneColors,
  colorDiffCompra,
  colorDiffVenta,
  labelDiffCompra,
  fmtPrecioRef,
  fmtPrecioVenta,
  roundPrecioVenta,
  productoSubtituloReferencia,
} from "./lib/preciosReferencia";
import { costoComparacionDe, compraVigenteDe } from "./lib/ultimaCompra";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";
import ImportReferenciaPrecios from "./components/ImportReferenciaPrecios";
import DecisionesPreciosPanel from "./DecisionesPreciosPanel";
import {
  clasificarDecisiones,
  dismissDecision,
  loadDismissed,
  resumenDecisiones,
} from "./lib/decisionesPrecios";

const BRAND = { primary: "#0D1B2A", gradient: "linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const COL_DEFAULTS_COMPRA = {
  producto: 160,
  sku: 72,
  costo: 88,
  exprezo: 68,
  marzam: 68,
  nadro: 68,
  levic: 68,
  farmalive: 76,
  scorpion: 68,
  abarrotero: 76,
  mayoreototal: 84,
  otros_compra: 68,
  mejor: 100,
};

const COL_DEFAULTS_VENTA = {
  producto: 150,
  tuVenta: 62,
  margen: 54,
  fahorro: 68,
  similares: 68,
  otros_venta: 68,
  refMin: 58,
  sugerido: 62,
  margenEst: 54,
  nota: 92,
  accion: 68,
};

const COL_STORAGE_V = "v7";
const TAB_STORAGE_KEY = "farmacapital_precios_ref_tab";
const SUGERIDO_OVERRIDES_KEY = "farmacapital_precios_sugerido_overrides";

function loadPreciosRefTab() {
  try {
    const saved = sessionStorage.getItem(TAB_STORAGE_KEY);
    return saved === "venta" || saved === "compra" || saved === "decisiones" ? saved : "venta";
  } catch {
    return "venta";
  }
}

function loadSugeridoOverrides() {
  try {
    return JSON.parse(sessionStorage.getItem(SUGERIDO_OVERRIDES_KEY) || "{}");
  } catch {
    return {};
  }
}

function ProductoCell({ p, tdStyle, C }) {
  const { principioActivo, detalle } = productoSubtituloReferencia(p);
  return (
    <td style={tdStyle}>
      <div style={{ fontWeight: 600, lineHeight: 1.25, wordBreak: "break-word" }}>{p.nombre}</div>
      {principioActivo ? (
        <div style={{
          fontSize: 10,
          color: C.blue,
          fontWeight: 700,
          marginTop: 3,
          lineHeight: 1.3,
          wordBreak: "break-word",
        }}>
          PA: {principioActivo}
        </div>
      ) : null}
      {detalle ? (
        <div style={{ fontSize: 10, color: C.textMid, marginTop: principioActivo ? 2 : 3, lineHeight: 1.3, wordBreak: "break-word" }}>
          {detalle}
        </div>
      ) : null}
    </td>
  );
}

const COL_LABELS_COMPRA = {
  producto: "Producto",
  sku: "SKU",
  costo: "Costo / quién",
  exprezo: "Exprezo",
  marzam: "Marzam",
  nadro: "Nadro",
  levic: "Levic",
  farmalive: "Farmalive",
  otros_compra: "Otros",
  mejor: "Mejor opción",
};

const COL_LABELS_VENTA = {
  producto: "Producto",
  tuVenta: "Tu venta",
  margen: "Margen %",
  fahorro: "Del Ahorro",
  similares: "Similares",
  otros_venta: "Otros",
  refMin: "Ref. mín.",
  sugerido: "Sugerido",
  margenEst: "Marg. est.",
  nota: "Nota",
  accion: "Acción",
};

function resolveSugeridoFila(producto, refs, overrides) {
  const base = calcPrecioSugeridoVenta(producto, refs);
  const ov = overrides[producto.id];
  const sugerido = ov?.precio ?? base.sugeridoCompetitivo ?? base.sugerido;
  const esAjusteManual = ov != null && sugerido != null;
  const margenSugerido = sugerido != null
    ? calcMargenVenta(sugerido, producto)
    : base.margenSugerido;

  let alerta = null;
  if (margenSugerido.tone === "debajo_costo") alerta = "debajo_costo";
  else if (margenSugerido.tone === "debajo_piso") alerta = "debajo_piso";

  let nota = base.nota;
  if (esAjusteManual) {
    nota = `Ajuste manual · competir: ${base.sugeridoCompetitivo != null ? fmtPrecioVenta(base.sugeridoCompetitivo) : "—"}`;
    if (alerta === "debajo_costo") {
      nota = `Manual ${fmtPrecioVenta(sugerido)} no cubre costo. Competir: ${fmtPrecioVenta(base.sugeridoCompetitivo)}`;
    } else if (alerta === "debajo_piso") {
      nota = `Manual bajo piso habitual. Competir: ${fmtPrecioVenta(base.sugeridoCompetitivo)}`;
    }
  }

  return {
    ...base,
    sugerido,
    margenSugerido,
    alerta,
    nota,
    esAjusteManual,
  };
}

function loadColWidths(tab) {
  const defaults = tab === "compra" ? COL_DEFAULTS_COMPRA : COL_DEFAULTS_VENTA;
  try {
    const raw = JSON.parse(
      localStorage.getItem(`farmacapital_precios_ref_cols_${COL_STORAGE_V}_${tab}`) || "{}"
    );
    return { ...defaults, ...raw };
  } catch {
    return { ...defaults };
  }
}

function colStyle(colWidths, colId) {
  const w = Math.max(48, Number(colWidths[colId]) || 64);
  return { width: w, minWidth: w, maxWidth: w };
}

function EditableMargenCell({
  C,
  cellKey,
  margen,
  inlineEdit,
  saving,
  onStart,
  onDraft,
  onCommit,
  onCancel,
  tdStyle,
  disabled = false,
}) {
  const isEditing = inlineEdit?.key === cellKey;
  const rowBg = tdStyle?.background;
  const toneStyle = margen?.pct != null ? margenToneColors(margen.tone, C) : null;

  if (disabled || margen?.pct == null) {
    return (
      <td style={{ ...tdStyle, textAlign: "right", color: C.textDim, fontSize: 11 }}>
        —
      </td>
    );
  }

  if (isEditing) {
    return (
      <td style={{ ...tdStyle, textAlign: "right" }}>
        <input
          type="number"
          step="0.1"
          min="0"
          max="99.9"
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
            textAlign: "right",
          }}
        />
      </td>
    );
  }

  return (
    <td
      style={{ ...tdStyle, textAlign: "right", cursor: "pointer" }}
      title="Clic para editar margen %"
      onMouseDown={(e) => e.preventDefault()}
      onClick={(e) => {
        e.stopPropagation();
        onStart(cellKey, String(margen.pct));
      }}
      onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(30, 58, 138, 0.07)"; }}
      onMouseLeave={(e) => { e.currentTarget.style.background = rowBg || ""; }}
    >
      <span style={{
        padding: "2px 6px",
        borderRadius: 10,
        fontSize: 10,
        fontWeight: 700,
        color: toneStyle.color,
        background: toneStyle.bg,
      }}>
        {margen.pct}%
      </span>
    </td>
  );
}

function DiffBadge({ pct, mode, C, vsLabel }) {
  if (pct == null) return <span style={{ color: C.textDim }}>—</span>;

  if (mode === "compra") {
    const tone = colorDiffCompra(pct);
    const label = labelDiffCompra(pct, vsLabel);
    const col =
      tone === "tu_costo_mejor" ? C.green :
      tone === "proveedor_mas_barato" ? C.blue : C.textMid;
    const bg =
      tone === "tu_costo_mejor" ? C.greenDim :
      tone === "proveedor_mas_barato" ? "#dbeafe" : C.cardDark;
    return (
      <span style={{ padding: "2px 6px", borderRadius: 20, fontSize: 9, fontWeight: 700, color: col, background: bg }}>
        {label}
      </span>
    );
  }

  const tone = colorDiffVenta(pct);
  const col =
    tone === "ok" ? C.green :
    tone === "caro" ? C.red : C.textMid;
  const bg =
    tone === "ok" ? C.greenDim :
    tone === "caro" ? C.redDim : C.cardDark;
  const prefix = parseFloat(pct) > 0 ? "+" : "";
  return (
    <span style={{ padding: "2px 6px", borderRadius: 20, fontSize: 9, fontWeight: 700, color: col, background: bg }}>
      {prefix}{pct}% vs ref.
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
  editTitle = "Clic para editar",
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
      title={editTitle}
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
    producto: [120, 320],
    sku: [56, 140],
    costo: [64, 160],
    tuVenta: [52, 100],
    margen: [48, 90],
    margenEst: [48, 90],
    exprezo: [52, 120],
    marzam: [52, 120],
    nadro: [52, 120],
    levic: [52, 120],
    farmalive: [52, 120],
    otros_compra: [52, 120],
    fahorro: [52, 120],
    similares: [52, 120],
    otros_venta: [52, 120],
    refMin: [52, 100],
    sugerido: [52, 100],
    nota: [80, 220],
    accion: [52, 100],
    mejor: [80, 180],
  };

  return (
    <div style={{
      marginBottom: 12, padding: "10px 12px", borderRadius: 10,
      background: C.card, border: `1px solid ${C.border}`,
    }}>
      <div style={{ fontSize: 11, color: C.textMid, marginBottom: 10 }}>
        Ancho de columnas (se guarda en este navegador). Clic en precio o margen % para editar.
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
            <th style={{ ...thS("costo"), textAlign: "right" }} title="Primera compra (quién y precio). Se reemplaza solo si Recibir trae uno más barato.">
              Costo
            </th>
            {FUENTES_COMPRA.map((id) => (
              <th
                key={id}
                style={{ ...thS(id), textAlign: "right" }}
                title={
                  FUENTE_META[id]?.hint
                  || (FUENTE_META[id]?.listaDistribuidor ? "Precio lista distribuidor" : "")
                }
              >
                {FUENTE_META[id]?.label}
              </th>
            ))}
            <th style={thS("mejor")}>Mejor opción</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={4 + FUENTES_COMPRA.length} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const vigente = compraVigenteDe(p, refs);
            const costoBase = costoComparacionDe(p, refs);
            const mejor = calcMejorCompra(costoBase, refs, vigente || {});
            const vsLabel = vigente?.proveedor ? `compra ${vigente.proveedor}` : "tu costo";
            const rowBg = i % 2 ? "#f8fafc" : "transparent";

            return (
              <tr key={p.id} style={{ background: rowBg }}>
                <ProductoCell p={p} tdStyle={{ ...tdS("producto"), background: rowBg }} C={C} />
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
                  display={vigente ? (
                    <div>
                      <div>{fmtPrecioRef(vigente.precio)}</div>
                      {vigente.proveedor ? (
                        <div style={{ fontSize: 10, color: C.blue, fontWeight: 700 }}>{vigente.proveedor}</div>
                      ) : (
                        <div style={{ fontSize: 10, color: C.textMid }}>sin proveedor</div>
                      )}
                    </div>
                  ) : "—"}
                />
                {FUENTES_COMPRA.map((id) => {
                  const precio = refs[id]?.precio;
                  const pct = diffPctCompra(costoBase, precio);
                  const tone = colorDiffCompra(pct);
                  const col =
                    tone === "tu_costo_mejor" ? C.green :
                    tone === "proveedor_mas_barato" ? C.blue : C.textMid;
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
                      editTitle="Clic para editar. Deja vacío para quitar la referencia."
                      tdStyle={{ ...tdS(id, { background: rowBg }) }}
                      display={precio != null ? (
                        <div>
                          <span style={{ color: col, fontWeight: 600 }}>{fmtPrecioRef(precio)}</span>
                          <div><DiffBadge pct={pct} mode="compra" C={C} vsLabel={vsLabel} /></div>
                        </div>
                      ) : "—"}
                    />
                  );
                })}
                <td style={{ ...tdS("mejor", { background: rowBg }) }}>
                  {mejor ? (
                    <span style={{
                      fontWeight: 700,
                      color: mejor.esTuCosto ? C.green : C.blue,
                    }}>
                      {mejor.label}
                      {!mejor.esTuCosto && mejor.ahorroVsTuCosto != null && mejor.ahorroVsTuCosto > 0.01 ? (
                        <span style={{ fontSize: 10, marginLeft: 4 }}>
                          (−{fmtPrecioRef(mejor.ahorroVsTuCosto)})
                        </span>
                      ) : null}
                      {mejor.esTuCosto ? (
                        <span style={{ fontSize: 10, marginLeft: 4, color: C.green }}>✓</span>
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
  onAplicar, applyingId, sugeridoOverrides, onResetCompetir,
}) {
  const fil = productos.filter((p) => inventarioProductMatchesBusqueda(p, busq));
  const thS = (colId) => ({ ...th(C), ...colStyle(colWidths, colId) });
  const tdS = (colId, extra = {}) => ({ ...td(C), ...colStyle(colWidths, colId), ...extra });
  const colSpan = 11;

  return (
    <HorizontalScrollSync>
      <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12, tableLayout: "fixed" }}>
        <thead>
          <tr style={{ background: C.cardDark }}>
            <th style={thS("producto")}>Producto</th>
            <th style={{ ...thS("tuVenta"), textAlign: "right" }}>Tu venta</th>
            <th style={{ ...thS("margen"), textAlign: "right" }}>Margen %</th>
            <th style={{ ...thS("fahorro"), textAlign: "right" }}>Del Ahorro</th>
            <th style={{ ...thS("similares"), textAlign: "right" }}>Similares</th>
            <th
              style={{ ...thS("otros_venta"), textAlign: "right" }}
              title={FUENTE_META.otros_venta?.hint}
            >
              Otros
            </th>
            <th style={{ ...thS("refMin"), textAlign: "right" }}>Ref. mín.</th>
            <th style={{ ...thS("sugerido"), textAlign: "right" }}>Sugerido</th>
            <th style={{ ...thS("margenEst"), textAlign: "right" }} title="Margen estimado del sugerido">Marg. est.</th>
            <th style={thS("nota")}>Nota</th>
            <th style={thS("accion")}>Acción</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={colSpan} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const fah = refs.fahorro?.precio;
            const sim = refs.similares?.precio;
            const otr = refs.otros_venta?.precio;
            const dAho = diffPctVenta(p.precio, fah);
            const dSim = diffPctVenta(p.precio, sim);
            const dOtr = diffPctVenta(p.precio, otr);
            const {
              sugerido, refMin, nota, alerta, margenActual, margenSugerido, esAjusteManual,
            } = resolveSugeridoFila(p, refs, sugeridoOverrides);
            const puedeAplicar = sugerido != null && roundPrecioVenta(p.precio) !== sugerido;
            const sugeridoCol =
              alerta === "debajo_costo" ? C.red :
              alerta === "debajo_piso" ? C.amber :
              esAjusteManual ? C.blue : C.green;
            const rowBg = i % 2 ? "#f8fafc" : "transparent";
            const sinCosto = !(parseFloat(p.costo) > 0);

            return (
              <tr key={p.id} style={{ background: rowBg }}>
                <ProductoCell p={p} tdStyle={{ ...tdS("producto", { background: rowBg }) }} C={C} />
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
                  display={fmtPrecioVenta(p.precio)}
                />
                <EditableMargenCell
                  C={C}
                  cellKey={`${p.id}:margen`}
                  margen={margenActual}
                  disabled={sinCosto}
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:margen`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("margen", { background: rowBg }) }}
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
                  editTitle="Clic para editar. Deja vacío para quitar la referencia."
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
                  editTitle="Clic para editar. Deja vacío para quitar la referencia."
                  tdStyle={{ ...tdS("similares", { background: rowBg }) }}
                  display={sim != null ? (
                    <>
                      <div>{fmtPrecioRef(sim)}</div>
                      <DiffBadge pct={dSim} mode="venta" C={C} />
                    </>
                  ) : "—"}
                />
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:ref:otros_venta`}
                  value={otr != null ? String(otr) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:ref:otros_venta`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  editTitle="Promedio de mercado o consulta manual. Vacío = quitar."
                  tdStyle={{ ...tdS("otros_venta", { background: rowBg }) }}
                  display={otr != null ? (
                    <>
                      <div>{fmtPrecioRef(otr)}</div>
                      <DiffBadge pct={dOtr} mode="venta" C={C} />
                    </>
                  ) : "—"}
                />
                <td style={{ ...tdS("refMin", { textAlign: "right", color: C.textMid, background: rowBg }) }}>
                  {refMin != null ? fmtPrecioRef(refMin) : "—"}
                </td>
                <EditablePrecioCell
                  C={C}
                  cellKey={`${p.id}:sugerido:precio`}
                  value={sugerido != null ? String(sugerido) : ""}
                  align="right"
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:sugerido:precio`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{
                    ...tdS("sugerido", {
                      textAlign: "right",
                      fontWeight: 800,
                      color: sugerido != null ? sugeridoCol : C.textDim,
                      background: rowBg,
                    }),
                  }}
                  display={sugerido != null ? fmtPrecioVenta(sugerido) : "—"}
                />
                <EditableMargenCell
                  C={C}
                  cellKey={`${p.id}:sugerido:margen`}
                  margen={margenSugerido}
                  disabled={sinCosto || sugerido == null}
                  inlineEdit={inlineEdit}
                  saving={savingKey === `${p.id}:sugerido:margen`}
                  onStart={onStartEdit}
                  onDraft={onDraft}
                  onCommit={onCommit}
                  onCancel={onCancel}
                  tdStyle={{ ...tdS("margenEst", { background: rowBg }) }}
                />
                <td style={{ ...tdS("nota", { fontSize: 10, color: C.textMid, background: rowBg }) }}>{nota}</td>
                <td style={{ ...tdS("accion", { background: rowBg }) }}>
                  <div style={{ display: "flex", flexDirection: "column", gap: 4, alignItems: "flex-start" }}>
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
                    {esAjusteManual && sugerido != null ? (
                      <button
                        type="button"
                        onClick={() => onResetCompetir(p.id)}
                        title="Volver al precio competitivo de mercado"
                        style={{
                          padding: "2px 6px", borderRadius: 5, border: `1px solid ${C.border}`,
                          background: C.card, color: C.blue, cursor: "pointer",
                          fontSize: 9, fontWeight: 700,
                        }}
                      >
                        ↺ Competir
                      </button>
                    ) : null}
                  </div>
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
  const [tab, setTab] = useState(loadPreciosRefTab);
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
  const [sugeridoOverrides, setSugeridoOverrides] = useState(() => loadSugeridoOverrides());
  const [dismissed, setDismissed] = useState(() => loadDismissed());
  const [revisadoAt, setRevisadoAt] = useState(null);

  const colWidths = tab === "compra" ? colWidthsCompra : colWidthsVenta;
  const setColWidths = tab === "compra" ? setColWidthsCompra : setColWidthsVenta;

  useEffect(() => {
    try {
      sessionStorage.setItem(SUGERIDO_OVERRIDES_KEY, JSON.stringify(sugeridoOverrides));
    } catch { /* noop */ }
  }, [sugeridoOverrides]);

  useEffect(() => {
    try {
      sessionStorage.setItem(TAB_STORAGE_KEY, tab);
    } catch { /* noop */ }
  }, [tab]);

  useEffect(() => {
    try {
      localStorage.setItem(`farmacapital_precios_ref_cols_${COL_STORAGE_V}_compra`, JSON.stringify(colWidthsCompra));
    } catch { /* noop */ }
  }, [colWidthsCompra]);

  useEffect(() => {
    try {
      localStorage.setItem(`farmacapital_precios_ref_cols_${COL_STORAGE_V}_venta`, JSON.stringify(colWidthsVenta));
    } catch { /* noop */ }
  }, [colWidthsVenta]);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const prodRes = await supabase
      .from("productos")
      .select("id,sku,nombre,categoria,tipo,costo,precio,stock,principio_activo,concentracion,presentacion,forma_farmaceutica,requiere_receta,marca,denominacion_generica,denominacion_distintiva")
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
        .select("producto_id,fuente,tipo,precio,fecha,origen,confianza,created_at,nombre_fuente,notas")
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
    setDismissed(loadDismissed());
    setRevisadoAt(Date.now());
    setLoading(false);
  }, []);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  useEffect(() => {
    const t = setInterval(() => fetchAll(), 3 * 60 * 1000);
    const onVis = () => {
      if (document.visibilityState === "visible") fetchAll();
    };
    document.addEventListener("visibilitychange", onVis);
    return () => {
      clearInterval(t);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, [fetchAll]);

  const stats = useMemo(() => {
    let compraOportunidad = 0;
    let ventaCaro = 0;
    let sinRefCompra = 0;
    let sinRefVenta = 0;

    for (const p of productos) {
      const refs = refsByProduct[p.id] || {};
      const vigente = compraVigenteDe(p, refs);
      const mejor = calcMejorCompra(costoComparacionDe(p, refs), refs, vigente || {});
      if (mejor?.masBaratoQueTuCosto) compraOportunidad += 1;
      if (!FUENTES_COMPRA.some((f) => refs[f]?.precio != null)) sinRefCompra += 1;

      const { refMin } = calcPrecioSugeridoVenta(p, refs);
      if (refMin == null) sinRefVenta += 1;
      else if ((parseFloat(p.precio) || 0) > refMin) ventaCaro += 1;
    }

    return { compraOportunidad, ventaCaro, sinRefCompra, sinRefVenta };
  }, [productos, refsByProduct]);

  const decisiones = useMemo(
    () => clasificarDecisiones(productos, refsByProduct, {
      dismissedKeys: Object.keys(dismissed),
    }),
    [productos, refsByProduct, dismissed]
  );
  const resumenDec = useMemo(() => resumenDecisiones(decisiones), [decisiones]);

  const startEdit = useCallback((key, value) => {
    setInlineEdit({ key, draft: value ?? "" });
  }, []);

  const cancelEdit = useCallback(() => setInlineEdit(null), []);

  const setSugeridoOverride = useCallback((productoId, precio) => {
    setSugeridoOverrides((prev) => ({
      ...prev,
      [productoId]: { precio },
    }));
  }, []);

  const resetSugeridoCompetir = useCallback((productoId) => {
    setSugeridoOverrides((prev) => {
      if (!prev[productoId]) return prev;
      const next = { ...prev };
      delete next[productoId];
      return next;
    });
    showToast("Sugerido restaurado a precio competitivo", "success");
  }, []);

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

    // Ajustes locales del sugerido (no persisten hasta Aplicar)
    if (parts[1] === "sugerido") {
      if (parts[2] === "margen") {
        if (isEmpty || !Number.isFinite(num) || num < 0 || num >= 100) {
          showToast("Margen inválido (0–99.9%)", "error");
          cancelEdit();
          return;
        }
        const precioVenta = precioDesdeMargen(producto.costo, num);
        if (!precioVenta) {
          showToast("Necesitas costo para calcular precio desde margen", "error");
          cancelEdit();
          return;
        }
        setSugeridoOverride(productoId, precioVenta);
        cancelEdit();
        return;
      }
      if (parts[2] === "precio") {
        if (isEmpty || !Number.isFinite(num) || num < 0) {
          showToast("Precio sugerido inválido", "error");
          cancelEdit();
          return;
        }
        const precioVenta = roundPrecioVenta(num);
        setSugeridoOverride(productoId, precioVenta);
        cancelEdit();
        return;
      }
    }

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
        const precioVenta = num != null ? roundPrecioVenta(num) : null;
        const { error } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: productoId,
          p_patch: { precio: precioVenta },
        });
        if (error) throw error;
        setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, precio: precioVenta } : x)));
        showToast("Precio de venta actualizado", "success");
      } else if (parts[1] === "margen") {
        if (isEmpty || !Number.isFinite(num) || num < 0 || num >= 100) {
          showToast("Margen inválido (0–99.9%)", "error");
          return;
        }
        const precioVenta = precioDesdeMargen(producto.costo, num);
        if (!precioVenta) {
          showToast("Necesitas costo para calcular precio desde margen", "error");
          return;
        }
        const { error } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: productoId,
          p_patch: { precio: precioVenta },
        });
        if (error) throw error;
        setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, precio: precioVenta } : x)));
        showToast(`Precio ${fmtPrecioVenta(precioVenta)} (${num}% margen)`, "success");
      } else if (parts[1] === "ref") {
        const fuente = parts[2];
        const meta = FUENTE_META[fuente];
        if (!meta) throw new Error("Fuente desconocida");

        // Vacío o 0 = quitar referencia (tombstone en historial)
        if (isEmpty || num === 0) {
          const { error } = await supabase.from("producto_precios_referencia").insert({
            producto_id: productoId,
            fuente,
            tipo: meta.tipo,
            precio: 0,
            fecha,
            origen: "manual",
            confianza: 0,
            notas: REFERENCIA_ANULADA_NOTA,
          });
          if (error) throw error;
          setRefsByProduct((prev) => {
            const next = { ...(prev[productoId] || {}) };
            delete next[fuente];
            return { ...prev, [productoId]: next };
          });
          showToast(`Referencia ${meta.label} eliminada`, "success");
          return;
        }

        if (!Number.isFinite(num) || num <= 0) {
          showToast("Precio de referencia inválido", "error");
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
      const msg = e.message || "Error al guardar";
      if (/fuentes_precio|foreign key/i.test(msg) && /^otros_/.test(parts[2] || "")) {
        showToast("Falta SQL: ejecuta sql/patch_fuentes_otros_precio.sql en Supabase", "error");
      } else if (/fuentes_precio|foreign key/i.test(msg) && parts[2] === "farmalive") {
        showToast("Falta SQL: ejecuta sql/patch_fuentes_farmalive.sql en Supabase", "error");
      } else {
        showToast(msg, "error");
      }
    } finally {
      setSavingKey(null);
      cancelEdit();
    }
  }, [inlineEdit, productos, cancelEdit, setSugeridoOverride]);

  const aplicarPrecio = async (producto, sugerido) => {
    const margen = calcMargenVenta(sugerido, producto);
    const margenTxt = margen.pct != null ? ` · margen ${margen.pct}%` : "";
    const ok = window.confirm(
      `¿Aplicar precio sugerido ${fmtPrecioVenta(sugerido)}${margenTxt} a «${producto.nombre}»?\n\nTu precio actual: ${fmtPrecioVenta(producto.precio)}`
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
    setSugeridoOverrides((prev) => {
      if (!prev[producto.id]) return prev;
      const next = { ...prev };
      delete next[producto.id];
      return next;
    });
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
            Precios de mercado (compra y venta). El agente revisa la bandeja cada 3 min. Clic en un precio para editarlo. Tu <strong>costo</strong> y <strong>venta</strong> usan el mismo guardado que Inventario.
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <ImportReferenciaPrecios productos={productos} onImported={fetchAll} />
          {tab !== "decisiones" && (
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
          )}
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
          Lista más barata que tu compra: {stats.compraOportunidad}
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
        <button
          type="button"
          onClick={() => { setTab("decisiones"); cancelEdit(); }}
          style={{
            padding: "4px 12px",
            borderRadius: 20,
            fontSize: 11,
            fontWeight: 700,
            border: "none",
            cursor: "pointer",
            background: resumenDec.total ? C.amberDim : C.greenDim,
            color: resumenDec.total ? C.amber : C.greenDark,
          }}
        >
          Decisiones pendientes: {resumenDec.total}
        </button>
      </div>

      <div style={{ display: "flex", gap: 4, marginBottom: 16, borderBottom: `1px solid ${C.border}` }}>
        {[["decisiones", `⚡ Decisiones${resumenDec.total ? ` (${resumenDec.total})` : ""}`], ["compra", "🛒 Compra (proveedores)"], ["venta", "🏪 Venta (competencia)"]].map(([id, label]) => (
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

      {tab !== "decisiones" && (
        <div style={{ marginBottom: 12, display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
          <input
            placeholder="🔍 Buscar nombre, PA, SKU…"
            value={busq}
            onChange={(e) => setBusq(e.target.value)}
            style={{ ...inpS, maxWidth: 280 }}
          />
        </div>
      )}

      {showColSizer && tab !== "decisiones" && (
        <ColumnSizer tab={tab} colWidths={colWidths} setColWidths={setColWidths} C={C} />
      )}

      {tab === "decisiones" && (
        <p style={{ fontSize: 11, color: C.textDim, marginBottom: 10 }}>
          Bandeja del agente: qué aplicar en venta, dónde hay lista más barata, y qué SKU de Rappi hay que alinear.
          El cron de Similares/PROFECO sigue llenando referencias; esto solo decide sobre lo que ya está cargado.
        </p>
      )}

      {tab === "compra" && (
        <p style={{ fontSize: 11, color: C.textDim, marginBottom: 10 }}>
          <strong>Costo</strong> es con quién lo compraste y a qué precio. Empieza en la primera compra;
          Recibir solo lo reemplaza si el ticket nuevo es <strong>más barato</strong>.
          Las demás columnas son listas. <strong style={{ color: C.green }}>Verde</strong> = más cara que tu compra.
          <strong style={{ color: C.blue }}>Azul</strong> = más barata.
          {" "}Las columnas <strong>Margen %</strong>, <strong>Sugerido</strong> y <strong>Marg. est.</strong> están en la pestaña{" "}
          <button
            type="button"
            onClick={() => { setTab("venta"); cancelEdit(); }}
            style={{
              padding: 0, border: "none", background: "none", cursor: "pointer",
              color: BRAND.primary, fontWeight: 700, fontSize: 11, textDecoration: "underline",
            }}
          >
            Venta (competencia)
          </button>.
        </p>
      )}

      {tab === "venta" && (
        <p style={{ fontSize: 11, color: C.textDim, marginBottom: 10 }}>
          Precios en <strong>pesos enteros</strong>. <strong>Otros</strong> = promedio de mercado manual (Claude, Google…).
          Sugerido usa la ref. más barata (FDA, Similares u Otros). Edita margen % o sugerido; <strong>↺ Competir</strong> restaura mercado.
          Margen: <strong style={{ color: C.green }}>verde</strong> ok,
          <strong style={{ color: C.amber }}> ámbar</strong> bajo piso,
          <strong style={{ color: C.red }}> rojo</strong> bajo costo.
        </p>
      )}

      {tab === "decisiones" ? (
        <DecisionesPreciosPanel
          decisiones={decisiones}
          loading={loading}
          revisadoAt={revisadoAt}
          onRefresh={fetchAll}
          onPosponer={(clave) => setDismissed(dismissDecision(clave))}
          onApplied={(productoId, precio) => {
            setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, precio } : x)));
            setSugeridoOverrides((prev) => {
              if (!prev[productoId]) return prev;
              const next = { ...prev };
              delete next[productoId];
              return next;
            });
          }}
          applyingId={applyingId}
          setApplyingId={setApplyingId}
        />
      ) : loading ? (
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
          sugeridoOverrides={sugeridoOverrides}
          onResetCompetir={resetSugeridoCompetir}
        />
      )}
    </div>
  );
}
