import { useCallback, useEffect, useMemo, useState } from "react";
import { RefreshCw } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { AyudaDesplegable, Btn, HorizontalScrollSync, SkeletonTable, showToast } from "./ui";
import {
  FUENTE_META,
  REFERENCIA_ANULADA_NOTA,
  buildReferenciasPorProducto,
  calcMargenVenta,
  colorDiffVenta,
  dedupeReferenciasActuales,
  diffPctVenta,
  fechasActualizacionPorFuente,
  fmtBotCuando,
  fmtPrecioRef,
  fmtPrecioVenta,
  instanteBotVentaDe,
  margenToneColors,
  productoSubtituloReferencia,
  roundPrecioVenta,
} from "./lib/preciosReferencia";
import {
  COL_LABELS_RAPPI,
  FUENTES_RAPPI,
  calcPrecioSugeridoRappi,
  diagnosticoCeldaRappi,
  idsEnCatalogoRappi,
  listarSubidasRappi,
  instanteBotRappiDe,
  instanteBotRappiGlobal,
  mensajeVacioListaRappi,
  parseProgresoBackfill,
  pasaFiltroListaRappi,
  precioCalleDe,
  precioFarmaciaRappiMin,
  tienePackRappiDistinto,
  tieneRefRappi,
  tieneRefRappiComparable,
} from "./lib/rappiPrecios";
import {
  accionesRevisionFila,
  botTsMasReciente,
  cargarRevisionPrecios,
  esPendienteRevision,
  guardarRevisionPrecios,
  huellaMercado,
  marcarRevisados,
} from "./lib/preciosRevision";
import AccionesPrecioRevision from "./components/AccionesPrecioRevision";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";

function botTsFilaRappi(refs) {
  return botTsMasReciente(instanteBotRappiDe(refs), instanteBotVentaDe(refs));
}

async function cargarFilasCatalogoRappi() {
  const tries = [
    "producto_id,ean,sku_local,nombre_rappi",
    "producto_id,ean,nombre_rappi",
    "producto_id,ean",
    "producto_id",
  ];
  for (const select of tries) {
    const res = await supabase.from("catalogo_imagenes_rappi").select(select);
    if (!res.error) return res.data || [];
  }
  return [];
}

const C = C_LIGHT;
const CLAVE_PROGRESO = "rappi_precios_backfill";
const COLS_PRECIO = [
  "rappi_gdl",
  "rappi_farmatodo",
  "rappi_benavides",
  "rappi_otros",
  "rappi_super",
];

function ProductoCell({ p }) {
  const { principioActivo, detalle } = productoSubtituloReferencia(p);
  return (
    <td style={{ ...td, minWidth: 160 }}>
      <div style={{ fontWeight: 600, lineHeight: 1.25 }}>{p.nombre}</div>
      {principioActivo ? (
        <div style={{ fontSize: 10, color: C.blue, fontWeight: 700, marginTop: 3 }}>PA: {principioActivo}</div>
      ) : null}
      {detalle ? (
        <div style={{ fontSize: 10, color: C.textMid, marginTop: 2 }}>{detalle}</div>
      ) : null}
    </td>
  );
}

function DiffBadge({ pct }) {
  if (pct == null) return null;
  const tone = colorDiffVenta(pct);
  const col = tone === "ok" ? C.green : tone === "barato" ? C.amber : tone === "caro" ? C.red : C.textMid;
  const bg = tone === "ok" ? C.greenDim : tone === "barato" ? C.amberDim : tone === "caro" ? C.redDim : C.cardDark;
  const prefix = parseFloat(pct) > 0 ? "+" : "";
  return (
    <div style={{ padding: "1px 5px", borderRadius: 20, fontSize: 9, fontWeight: 700, color: col, background: bg, marginTop: 2, display: "inline-block" }}>
      {prefix}{pct}%
    </div>
  );
}

function EmpaqueBadge({ diag }) {
  if (!diag || diag.ok) return null;
  return (
    <div style={{
      padding: "1px 5px", borderRadius: 20, fontSize: 9, fontWeight: 700,
      color: C.amber, background: C.amberDim, marginTop: 2, display: "inline-block",
    }}>
      otro empaque
    </div>
  );
}


function BarraProgresoRappi({ progreso }) {
  if (!progreso || !(progreso.total > 0)) return null;
  const pct = progreso.pct;
  const vivo = progreso.running;
  return (
    <div style={{
      marginBottom: 16,
      padding: 16,
      borderRadius: 12,
      border: `1px solid ${vivo ? C.blue : C.border}`,
      background: vivo ? "#eff6ff" : C.card,
    }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 12, flexWrap: "wrap" }}>
        <div style={{ fontSize: 13, fontWeight: 800, color: C.text }}>
          {vivo ? "Llenando precios de Rappi" : "Última pasada"}
        </div>
        <div style={{ fontSize: 32, fontWeight: 800, color: BRAND.primary, lineHeight: 1, fontVariantNumeric: "tabular-nums" }}>
          {pct}%
        </div>
      </div>
      <div style={{
        marginTop: 10, height: 14, borderRadius: 999, background: "#dbeafe", overflow: "hidden",
      }}>
        <div style={{
          width: `${pct}%`,
          height: "100%",
          background: BRAND.gradient,
          transition: "width .4s ease",
        }}
        />
      </div>
      <div style={{ marginTop: 8, fontSize: 12, color: C.textMid, display: "flex", flexWrap: "wrap", gap: 10 }}>
        <span><strong style={{ color: C.text }}>{progreso.done}</strong> / {progreso.total} revisados</span>
        <span>con precio: <strong style={{ color: C.green }}>{progreso.actualizados}</strong></span>
        <span>sin match: <strong>{progreso.errores}</strong></span>
      </div>
      {vivo && (progreso.nombre || progreso.sku) ? (
        <div style={{ marginTop: 6, fontSize: 12, color: C.blue, fontWeight: 700 }}>
          Ahora: {progreso.nombre || progreso.sku}
          {progreso.ultimo ? ` · ${progreso.ultimo}` : ""}
        </div>
      ) : null}
    </div>
  );
}

function EditableCell({ cellKey, value, display, inlineEdit, saving, onStart, onDraft, onCommit, onCancel, title }) {
  const editing = inlineEdit?.key === cellKey;
  if (editing) {
    return (
      <td style={{ ...td, textAlign: "right" }}>
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
            width: "100%", padding: "4px 6px", fontSize: 11, boxSizing: "border-box",
            border: `1px solid ${C.blue}`, borderRadius: 4, textAlign: "right",
          }}
        />
      </td>
    );
  }
  return (
    <td
      style={{ ...td, textAlign: "right", cursor: "pointer" }}
      title={title || "Clic para editar"}
      onMouseDown={(e) => e.preventDefault()}
      onClick={(e) => { e.stopPropagation(); onStart(cellKey, value); }}
    >
      {display}
    </td>
  );
}

export default function RappiPreciosPanel() {
  const [productos, setProductos] = useState([]);
  const [enRappi, setEnRappi] = useState(() => new Set());
  const [refsByProduct, setRefsByProduct] = useState({});
  const [fechasFuente, setFechasFuente] = useState({});
  const [loading, setLoading] = useState(true);
  const [schemaOk, setSchemaOk] = useState(true);
  const [busq, setBusq] = useState("");
  const [filtro, setFiltro] = useState("en_rappi");
  const [actualizando, setActualizando] = useState(false);
  const [applyingId, setApplyingId] = useState(null);
  const [inlineEdit, setInlineEdit] = useState(null);
  const [savingKey, setSavingKey] = useState(null);
  const [progreso, setProgreso] = useState(null);
  const [revision, setRevision] = useState({ epoch: null, porId: {} });

  const fetchAll = useCallback(async (opts = {}) => {
    const silent = opts.silent === true;
    if (!silent) setLoading(true);
    const [prodRes, filasCatalogo] = await Promise.all([
      supabase
        .from("productos")
        .select("id,sku,nombre,categoria,tipo,costo,precio,principio_activo,concentracion,presentacion,forma_farmaceutica,requiere_receta,codigo_barras")
        .eq("activo", true)
        .order("nombre"),
      cargarFilasCatalogoRappi(),
    ]);
    if (prodRes.error) {
      showToast("Error cargando productos: " + prodRes.error.message, "error");
      setLoading(false);
      return false;
    }
    const list = prodRes.data || [];
    setProductos(list);
    setEnRappi(idsEnCatalogoRappi(list, filasCatalogo));

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
        setFechasFuente({});
        setLoading(false);
        return false;
      }
      refRows = dedupeReferenciasActuales(rawRes.data);
    } else {
      refRows = viewRes.data || [];
    }
    setSchemaOk(true);
    setRefsByProduct(buildReferenciasPorProducto(refRows));
    setFechasFuente(fechasActualizacionPorFuente(refRows));
    const loaded = await cargarRevisionPrecios(supabase);
    setRevision(loaded.state);
    if (loaded.persistirEpoch) {
      await guardarRevisionPrecios(supabase, loaded.state);
    }
    setLoading(false);
    return true;
  }, []);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  useEffect(() => {
    let cancelled = false;
    let timer;
    let lastDone = -1;
    const tick = async () => {
      const { data } = await supabase
        .from("configuracion")
        .select("valor")
        .eq("clave", CLAVE_PROGRESO)
        .maybeSingle();
      if (cancelled) return;
      const next = parseProgresoBackfill(data?.valor);
      setProgreso(next);
      if (next?.running && next.done !== lastDone) {
        lastDone = next.done;
        await fetchAll({ silent: true });
      }
      timer = setTimeout(tick, next?.running ? 2000 : 8000);
    };
    tick();
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [fetchAll]);

  const startEdit = (key, draft) => setInlineEdit({ key, draft: draft == null ? "" : String(draft) });
  const cancelEdit = () => setInlineEdit(null);

  const commitEdit = async () => {
    if (!inlineEdit) return;
    const parts = inlineEdit.key.split(":");
    const productoId = Number(parts[0]);
    const raw = String(inlineEdit.draft || "").trim();
    const isEmpty = raw === "";
    const num = isEmpty ? null : parseFloat(raw.replace(",", "."));
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const fecha = new Date().toISOString().slice(0, 10);
    setSavingKey(inlineEdit.key);
    try {
      if (parts[1] === "precio") {
        const precioVenta = num != null ? roundPrecioVenta(num) : null;
        const { error } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: productoId,
          p_patch: { precio: precioVenta },
        });
        if (error) throw error;
        setProductos((prev) => prev.map((x) => (x.id === productoId ? { ...x, precio: precioVenta } : x)));
        showToast("Precio de venta actualizado", "success");
      } else if (parts[1] === "ref") {
        const fuente = parts[2];
        const meta = FUENTE_META[fuente];
        if (!meta) throw new Error("Fuente desconocida");
        if (isEmpty || num === 0) {
          const { error } = await supabase.from("producto_precios_referencia").insert({
            producto_id: productoId, fuente, tipo: "venta", precio: 0, fecha,
            origen: "manual", confianza: 0, notas: REFERENCIA_ANULADA_NOTA,
          });
          if (error) throw error;
          setRefsByProduct((prev) => {
            const next = { ...(prev[productoId] || {}) };
            delete next[fuente];
            return { ...prev, [productoId]: next };
          });
          showToast(`Referencia ${meta.label} eliminada`, "success");
        } else {
          if (!Number.isFinite(num) || num <= 0) {
            showToast("Precio de referencia inválido", "error");
            return;
          }
          const { error } = await supabase.from("producto_precios_referencia").insert({
            producto_id: productoId, fuente, tipo: "venta", precio: num, fecha,
            origen: "manual", confianza: 100,
          });
          if (error) throw error;
          setRefsByProduct((prev) => ({
            ...prev,
            [productoId]: { ...(prev[productoId] || {}), [fuente]: { precio: num, fuente, tipo: "venta" } },
          }));
          showToast(`Referencia ${meta.label} guardada`, "success");
        }
      }
    } catch (e) {
      const msg = e.message || "Error al guardar";
      if (/fuentes_precio|foreign key/i.test(msg)) {
        showToast("Falta SQL: sql/patch_fuentes_rappi_precios_20260826.sql", "error");
      } else {
        showToast(msg, "error");
      }
    } finally {
      setSavingKey(null);
      cancelEdit();
    }
  };

  const persistirRevision = async (next) => {
    setRevision(next);
    const { error } = await guardarRevisionPrecios(supabase, next);
    if (error) showToast(error.message || "No se guardó la revisión", "warning");
  };

  const marcarFilasRevisadas = async (items) => {
    const extra = {};
    const ids = [];
    for (const it of items) {
      ids.push(it.id);
      extra[it.id] = { huella: it.huella || "" };
    }
    await persistirRevision(marcarRevisados(revision, ids, extra));
  };

  const aplicarPrecio = async (producto, sugerido) => {
    const margen = calcMargenVenta(sugerido, producto);
    const margenTxt = margen.pct != null ? ` · margen ${margen.pct}%` : "";
    const ok = window.confirm(
      `¿Aplicar ${fmtPrecioVenta(sugerido)}${margenTxt} a «${producto.nombre}»?\n\nHoy: ${fmtPrecioVenta(producto.precio)}\nEste precio es el de mostrador y el de venta en línea.`
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
    const calc = calcPrecioSugeridoRappi(producto, refsByProduct[producto.id] || {});
    await marcarFilasRevisadas([{ id: producto.id, huella: huellaMercado(calc) }]);
    showToast("Precio actualizado", "success");
    setProductos((prev) => prev.map((x) => (x.id === producto.id ? { ...x, precio: sugerido } : x)));
  };

  const aceptarPrecio = async (producto, calc) => {
    await marcarFilasRevisadas([{ id: producto.id, huella: huellaMercado(calc) }]);
    showToast("Listo. Si el bot cambia el mercado, vuelven los botones.", "success");
  };

  const subidas = useMemo(
    () => listarSubidasRappi(productos, refsByProduct),
    [productos, refsByProduct]
  );

  const aplicarSubidas = async () => {
    if (!subidas.length) return;
    const preview = subidas.slice(0, 12).map((s) => `${s.producto.nombre}: ${fmtPrecioVenta(s.de)} → ${fmtPrecioVenta(s.a)}`).join("\n");
    const extra = subidas.length > 12 ? `\n… y ${subidas.length - 12} más` : "";
    const ok = window.confirm(
      `¿Subir ${subidas.length} precio${subidas.length === 1 ? "" : "s"}?\nSolo subidas. Las bajadas las aceptas tú, una por una.\n\n${preview}${extra}`
    );
    if (!ok) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada", "error"); return; }
    setApplyingId("subidas");
    const okItems = [];
    let errN = 0;
    for (const s of subidas) {
      const { error } = await supabase.rpc("admin_editar_producto", {
        p_session_token: tok,
        p_producto_id: s.producto.id,
        p_patch: { precio: s.a },
      });
      if (error) errN += 1;
      else {
        okItems.push({ id: s.producto.id, huella: huellaMercado({ refMin: s.refMin, sugerido: s.a }) });
        setProductos((prev) => prev.map((x) => (x.id === s.producto.id ? { ...x, precio: s.a } : x)));
      }
    }
    setApplyingId(null);
    if (okItems.length) await marcarFilasRevisadas(okItems);
    if (errN) showToast(`Se subieron ${okItems.length}. Fallaron ${errN}.`, "warning");
    else showToast(`Se subieron ${okItems.length} precio${okItems.length === 1 ? "" : "s"}. Las bajadas no se tocaron.`, "success");
  };

  const actualizarRappi = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada", "error"); return; }
    setActualizando(true);
    try {
      const r = await fetch("/api/precios/buscar-rappi", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ session_token: tok }),
      });
      const data = await r.json().catch(() => ({}));
      await fetchAll();
      if (!r.ok || !data.ok) {
        showToast(data.error || "No se pudo buscar en Rappi. Se recargó lo guardado.", "warning");
      } else {
        showToast(data.message || `Actualizados: ${data.actualizados || 0}`, "success");
      }
    } catch {
      await fetchAll();
      showToast("Sin red al buscar. Se recargó lo guardado.", "warning");
    }
    setActualizando(false);
  };

  const stats = useMemo(() => {
    let conRef = 0;
    let caro = 0;
    let sinRef = 0;
    let packs = 0;
    let pendientes = 0;
    for (const p of productos) {
      const refs = refsByProduct[p.id] || {};
      const calc = calcPrecioSugeridoRappi(p, refs);
      if (esPendienteRevision({
        botTs: botTsFilaRappi(refs),
        revisado: revision.porId[p.id],
        epoch: revision.epoch,
      }) && calc.sugerido != null) pendientes += 1;
      if (tienePackRappiDistinto(p, refs)) packs += 1;
      if (tieneRefRappiComparable(p, refs)) {
        conRef += 1;
        const minFarm = precioFarmaciaRappiMin(p, refs);
        if (minFarm != null && (parseFloat(p.precio) || 0) > minFarm + 0.5) caro += 1;
      } else if (enRappi.has(p.id) && !tieneRefRappi(refs)) {
        sinRef += 1;
      }
    }
    return { conRef, caro, sinRef, packs, pendientes };
  }, [productos, refsByProduct, enRappi, revision]);

  const filas = useMemo(() => {
    return productos.filter((p) => {
      if (!inventarioProductMatchesBusqueda(p, busq)) return false;
      const refs = refsByProduct[p.id] || {};
      const linked = enRappi.has(p.id);
      const hasRef = tieneRefRappi(refs);
      if (filtro === "en_rappi") return pasaFiltroListaRappi({ filtro, busq, linked, hasRef });
      if (filtro === "con_ref") return tieneRefRappiComparable(p, refs);
      if (filtro === "packs") return tienePackRappiDistinto(p, refs);
      if (filtro === "caro") {
        const minFarm = precioFarmaciaRappiMin(p, refs);
        return minFarm != null && (parseFloat(p.precio) || 0) > minFarm + 0.5;
      }
      if (filtro === "sin_ref") return linked && !tieneRefRappi(refs);
      if (filtro === "pendientes") {
        const calc = calcPrecioSugeridoRappi(p, refs);
        return esPendienteRevision({
          botTs: botTsFilaRappi(refs),
          revisado: revision.porId[p.id],
          epoch: revision.epoch,
        }) && calc.sugerido != null;
      }
      return true;
    });
  }, [productos, refsByProduct, enRappi, busq, filtro, revision]);

  const botCuando = fmtBotCuando(instanteBotRappiGlobal(refsByProduct));
  const chipsFuente = FUENTES_RAPPI.filter((f) => fechasFuente[f]);

  return (
    <div style={{ padding: "0 24px 32px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, flexWrap: "wrap", marginBottom: 14 }}>
        <div>
          <h2 style={{ margin: 0, fontSize: 16, fontWeight: 800, color: C.text }}>Precios en línea</h2>
          <AyudaDesplegable>
            Qué cobran otras tiendas en Rappi, mezclado con Del Ahorro / Similares (columna <strong>Calle</strong>).
            El <strong>sugerido</strong> es el mismo de Referencias: ~2% bajo la farmacia o calle más barata.
            Un <strong>pack</strong>, el polvo o otra línea (Advance / Plus) no se compara con la botella suelta.
            El <strong>súper</strong> (Chedraui, Soriana) se ve y no mueve el precio: envío otro y piso otro.
            <strong>En Rappi</strong> no es tu tienda Partner (los 68). Son los que ya tienen foto o un precio scrapeado. Si lo ves en Partner y aquí no, busca el nombre o cambia a <strong>Todos</strong>.
            Clic en un precio para editarlo. <strong>Aplicar subidas</strong> solo sube. Las bajadas las aceptas tú, con el botón Bajar de cada fila.
            El bot compara sin packs. Si después actualiza una referencia, vuelven Subir / Bajar / Aceptar.
            {" "}<strong>Descargar CSV Rappi</strong> arma el archivo de Partner (SKU, EAN, stock − 2, AVAILABLE y PRICE) para Subir plantilla.
          </AyudaDesplegable>
          {chipsFuente.length > 0 && (
            <div style={{ marginTop: 8, display: "flex", flexWrap: "wrap", gap: 6 }}>
              {chipsFuente.map((f) => {
                const iso = fechasFuente[f];
                const [y, m, d] = String(iso).slice(0, 10).split("-");
                return (
                  <span key={f} style={{
                    fontSize: 10, fontWeight: 700, color: C.textMid, background: C.cardDark,
                    border: `1px solid ${C.border}`, borderRadius: 20, padding: "3px 8px",
                  }}>
                    {FUENTE_META[f]?.label || f} {d && m && y ? `${d}/${m}/${y}` : iso}
                  </span>
                );
              })}
              {botCuando ? (
                <span style={{ fontSize: 10, fontWeight: 700, color: C.blue }}>Última corrida {botCuando}</span>
              ) : null}
            </div>
          )}
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <Btn
            sm
            col={C.green}
            onClick={aplicarSubidas}
            dis={actualizando || applyingId != null || !subidas.length}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            {applyingId === "subidas" ? "Subiendo…" : `Aplicar ${subidas.length} subida${subidas.length === 1 ? "" : "s"}`}
          </Btn>
          <Btn
            sm
            col={BRAND.primary}
            onClick={actualizarRappi}
            dis={actualizando}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            <RefreshCw size={14} aria-hidden />
            {actualizando ? "Buscando…" : "Actualizar Rappi"}
          </Btn>
        </div>
      </div>

      <BarraProgresoRappi progreso={progreso} />

      {!schemaOk && (
        <div style={{ marginBottom: 12, padding: 12, borderRadius: 10, background: C.amberDim, color: C.amber, fontSize: 12 }}>
          Falta el SQL de referencias o de fuentes Rappi: <code>sql/patch_fuentes_rappi_precios_20260826.sql</code>
        </div>
      )}

      <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
        <span style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: "#dbeafe", color: C.blue }}>
          Con precio Rappi: {stats.conRef}
        </span>
        <span style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.redDim, color: C.red }}>
          Más caro que farmacia: {stats.caro}
        </span>
        <span style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.amberDim, color: C.amber }}>
          Otro empaque: {stats.packs}
        </span>
        <span style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.cardDark, color: C.textMid }}>
          En Rappi sin precio: {stats.sinRef}
        </span>
        <span style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: "#dbeafe", color: C.blue }}>
          Por revisar: {stats.pendientes}
        </span>
      </div>

      <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap", alignItems: "center" }}>
        <input
          placeholder="Buscar nombre, PA, SKU…"
          value={busq}
          onChange={(e) => setBusq(e.target.value)}
          style={{
            padding: "8px 12px", borderRadius: 8, border: `1px solid ${C.border}`,
            fontSize: 13, outline: "none", background: C.card, color: C.text, maxWidth: 280,
          }}
        />
        {[
          ["en_rappi", "En Rappi"],
          ["pendientes", "Por revisar"],
          ["con_ref", "Con precio"],
          ["packs", "Otro empaque"],
          ["caro", "Más caro"],
          ["sin_ref", "Sin precio"],
          ["todos", "Todos"],
        ].map(([id, label]) => (
          <button
            key={id}
            type="button"
            onClick={() => setFiltro(id)}
            style={{
              padding: "6px 10px", borderRadius: 16, fontSize: 11, fontWeight: 700, cursor: "pointer",
              border: `1px solid ${filtro === id ? BRAND.primary : C.border}`,
              background: filtro === id ? "#dbeafe" : C.card,
              color: filtro === id ? BRAND.primary : C.textMid,
            }}
          >
            {label}
          </button>
        ))}
      </div>

      {loading ? (
        <SkeletonTable rows={8} cols={8} />
      ) : (
        <HorizontalScrollSync bodyMaxHeight="70vh">
          <table style={{ width: "100%", borderCollapse: "separate", borderSpacing: 0, fontSize: 12 }}>
            <thead>
              <tr style={{ background: C.cardDark }}>
                {["producto", "tuVenta", "margen", ...COLS_PRECIO, "calle", "sugerido", "nota", "accion"].map((id) => (
                  <th
                    key={id}
                    style={{ ...th, textAlign: id === "producto" || id === "nota" || id === "accion" ? "left" : "right" }}
                    title={FUENTE_META[id]?.hint}
                  >
                    {COL_LABELS_RAPPI[id]}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!filas.length && (
                <tr>
                  <td colSpan={12} style={{ textAlign: "center", padding: 32, color: C.textMid }}>
                    {mensajeVacioListaRappi({ filtro, busq })}
                  </td>
                </tr>
              )}
              {filas.map((p, i) => {
                const refs = refsByProduct[p.id] || {};
                const margen = calcMargenVenta(p.precio, p);
                const calc = calcPrecioSugeridoRappi(p, refs);
                const { sugerido, nota, alerta, accion } = calc;
                const calle = precioCalleDe(p, refs);
                const botLabel = fmtBotCuando(instanteBotRappiDe(refs));
                const rowBg = i % 2 ? "#f8fafc" : "transparent";
                const pendiente = esPendienteRevision({
                  botTs: botTsFilaRappi(refs),
                  revisado: revision.porId[p.id],
                  epoch: revision.epoch,
                });
                const botones = accionesRevisionFila({ pendiente, accion, sugerido });
                const toneM = margen.pct != null ? margenToneColors(margen.tone, C) : null;
                const sugeridoCol =
                  alerta === "debajo_costo" ? C.red :
                  alerta === "debajo_piso" ? C.amber :
                  accion === "bajar" ? C.amber :
                  C.green;

                return (
                  <tr key={p.id} style={{ background: rowBg }}>
                    <ProductoCell p={p} />
                    <EditableCell
                      cellKey={`${p.id}:precio`}
                      value={p.precio != null ? String(p.precio) : ""}
                      inlineEdit={inlineEdit}
                      saving={savingKey === `${p.id}:precio`}
                      onStart={startEdit}
                      onDraft={(v) => setInlineEdit((e) => (e ? { ...e, draft: v } : e))}
                      onCommit={commitEdit}
                      onCancel={cancelEdit}
                      display={(
                        <div>
                          <div style={{ fontWeight: 700, color: BRAND.primary }}>{fmtPrecioVenta(p.precio)}</div>
                          <div style={{ fontSize: 10, color: botLabel ? C.blue : C.textDim }}>{botLabel ? `Bot ${botLabel}` : "Bot —"}</div>
                        </div>
                      )}
                    />
                    <td style={{ ...td, textAlign: "right" }}>
                      {toneM ? (
                        <span style={{ padding: "2px 6px", borderRadius: 10, fontSize: 10, fontWeight: 700, color: toneM.color, background: toneM.bg }}>
                          {margen.pct}%
                        </span>
                      ) : <span style={{ color: C.textDim }}>—</span>}
                    </td>
                    {COLS_PRECIO.map((id) => {
                      const row = refs[id];
                      const precio = row?.precio;
                      const diag = diagnosticoCeldaRappi(p, row);
                      const d = (!diag || diag.ok) ? diffPctVenta(p.precio, precio) : null;
                      const nombreHit = (row?.nombre_fuente || "").trim();
                      return (
                        <EditableCell
                          key={id}
                          cellKey={`${p.id}:ref:${id}`}
                          value={precio != null ? String(precio) : ""}
                          inlineEdit={inlineEdit}
                          saving={savingKey === `${p.id}:ref:${id}`}
                          onStart={startEdit}
                          onDraft={(v) => setInlineEdit((e) => (e ? { ...e, draft: v } : e))}
                          onCommit={commitEdit}
                          onCancel={cancelEdit}
                          title={nombreHit || FUENTE_META[id]?.hint || "Clic para editar"}
                          display={precio != null ? (
                            <div>
                              <div style={{ color: diag && !diag.ok ? C.textDim : C.text }}>{fmtPrecioRef(precio)}</div>
                              {diag && !diag.ok ? <EmpaqueBadge diag={diag} /> : <DiffBadge pct={d} />}
                              {nombreHit ? (
                                <div style={{ fontSize: 9, color: C.textDim, marginTop: 2, lineHeight: 1.25, maxWidth: 92 }}>
                                  {nombreHit}
                                </div>
                              ) : null}
                            </div>
                          ) : <span style={{ color: C.textDim }}>—</span>}
                        />
                      );
                    })}
                    <td style={{ ...td, textAlign: "right", color: C.textMid }}>
                      {calle != null ? fmtPrecioRef(calle) : "—"}
                    </td>
                    <td style={{ ...td, textAlign: "right", fontWeight: 800, color: sugerido != null ? sugeridoCol : C.textDim }}>
                      {sugerido != null ? fmtPrecioVenta(sugerido) : "—"}
                    </td>
                    <td style={{ ...td, fontSize: 10, color: C.textMid, maxWidth: 220 }}>{nota}</td>
                    <td style={td}>
                      <AccionesPrecioRevision
                        botones={botones}
                        applying={applyingId != null}
                        onSubir={() => aplicarPrecio(p, sugerido)}
                        onBajar={() => aplicarPrecio(p, sugerido)}
                        onAceptar={() => aceptarPrecio(p, calc)}
                      />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </HorizontalScrollSync>
      )}
    </div>
  );
}

const th = {
  padding: "8px 8px 8px 0",
  fontWeight: 700,
  fontSize: 11,
  letterSpacing: 0.3,
  textTransform: "uppercase",
  color: C.textDim,
  position: "sticky",
  top: 0,
  background: C.cardDark,
  zIndex: 1,
};
const td = { padding: "8px 8px 8px 0", color: C.text, verticalAlign: "top" };
