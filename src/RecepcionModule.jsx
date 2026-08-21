import { useState, useEffect, useCallback, useRef } from "react";
import { ScanLine } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import { useMediaQuery } from "./hooks/useMediaQuery";
import {
  barcodeDigitsMatch,
  findProductExactScan,
  looksLikeBarcodeInput,
  looksLikeInternalSku,
  normalizeBarcodeRaw,
} from "./utils/barcodeProductLookup";
import { etiquetaCaducidadMMAA, formatCaducidadMesAnio, parseCaducidadMMAA } from "./lib/caducidad";
import { fetchProductosPaginados } from "./lib/inventarioHubData";
import { parseTicketCsv } from "./lib/recepcionTicketCsv";

const fmt = (n) =>
  `$${parseFloat(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

function unwrapJson(data) {
  if (data == null) return null;
  if (typeof data === "string") {
    try { return JSON.parse(data); } catch { return null; }
  }
  return data;
}

function itemMatchScan(it, codigo) {
  if (!it || !codigo) return false;
  if (it.codigo_escaneado && barcodeDigitsMatch(codigo, it.codigo_escaneado)) return true;
  if (it.sku && String(it.sku).toUpperCase() === String(codigo).toUpperCase()) return true;
  return false;
}

const inpBase = (C, extra = {}) => ({
  width: "100%",
  boxSizing: "border-box",
  padding: "12px 14px",
  borderRadius: 10,
  border: `1px solid ${C.border}`,
  background: C.card,
  color: C.text,
  fontSize: 16,
  outline: "none",
  ...extra,
});

const labelS = (C) => ({
  color: C.textMid,
  fontSize: 11,
  fontWeight: 700,
  letterSpacing: 0.4,
  textTransform: "uppercase",
  display: "block",
  marginBottom: 6,
});

export default function RecepcionModule() {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const scanRef = useRef(null);
  const qtyRef = useRef(null);
  const cadRef = useRef(null);
  const pdfRef = useRef(null);
  const csvRef = useRef(null);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [doc, setDoc] = useState(null);
  const [proveedores, setProveedores] = useState([]);
  const [productos, setProductos] = useState([]);

  const [proveedor, setProveedor] = useState("");
  const [folio, setFolio] = useState("");
  const [totalTicket, setTotalTicket] = useState("");

  const [scan, setScan] = useState("");
  const [qty, setQty] = useState("");
  const [cad, setCad] = useState("");
  const [pendiente, setPendiente] = useState(null);
  const [errorLinea, setErrorLinea] = useState("");
  const [subiendo, setSubiendo] = useState(false);

  const aplicarDoc = useCallback((raw) => {
    const d = unwrapJson(raw);
    const rec = d?.recepcion ?? (d?.id ? d : null);
    setDoc(rec);
    if (rec) {
      setProveedor(rec.proveedor || "");
      setFolio(rec.folio || "");
      setTotalTicket(rec.total_ticket != null ? String(rec.total_ticket) : "");
    }
    return rec;
  }, []);

  const cargar = useCallback(async () => {
    setLoading(true);
    const tok = sessionTok();
    if (!tok) {
      setLoading(false);
      showToast("Sesión expirada.", "error");
      return;
    }
    const [borradorRes, provRes, prodRes] = await Promise.all([
      supabase.rpc("recepcion_borrador_abierto", { p_session_token: tok }),
      supabase.rpc("empleado_listar_proveedores_catalogo", { p_session_token: tok }),
      fetchProductosPaginados({
        select: "id,nombre,sku,codigo_barras,activo",
        activosSolo: true,
        order: "nombre",
      }),
    ]);
    if (borradorRes.error) {
      const msg = borradorRes.error.message || "";
      if (/does not exist|schema cache|recepcion_borrador/i.test(msg)) {
        showToast("Falta correr sql/patch_recepcion_fefo_caducidad_20260821.sql en Supabase.", "error");
      } else {
        showToast("No se pudo abrir recepción: " + msg, "error");
      }
    } else {
      aplicarDoc(borradorRes.data);
    }
    const prov = unwrapJson(provRes.data);
    setProveedores(Array.isArray(prov) ? prov : []);
    if (prodRes.error) {
      showToast("Catálogo no cargó: " + prodRes.error.message, "warning");
      setProductos([]);
    } else {
      setProductos(prodRes.data || []);
    }
    setLoading(false);
  }, [aplicarDoc]);

  useEffect(() => { cargar(); }, [cargar]);

  useEffect(() => {
    if (!loading && doc && !pendiente) {
      scanRef.current?.focus();
    }
  }, [loading, doc, pendiente]);

  const rpcError = (err, fallback) => {
    const msg = err?.message || fallback;
    if (/does not exist|schema cache|cargar_renglones|confirmar_item/i.test(msg)) {
      showToast("Falta correr sql/patch_recepcion_pdf_confirmar_20260821.sql en Supabase.", "error");
      return;
    }
    showToast(msg, "error");
  };

  const empezar = async (e) => {
    e?.preventDefault();
    const tok = sessionTok();
    if (!tok) return;
    setSaving(true);
    const total = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
    const { data, error } = await supabase.rpc("recepcion_abrir", {
      p_session_token: tok,
      p_proveedor: proveedor.trim() || null,
      p_folio: folio.trim() || null,
      p_total_ticket: Number.isFinite(total) ? total : null,
    });
    setSaving(false);
    if (error) { rpcError(error, "No se pudo empezar la recepción"); return; }
    aplicarDoc(data);
    setTimeout(() => scanRef.current?.focus(), 40);
  };

  const cargarRenglones = async (renglones, meta = {}) => {
    if (!renglones?.length) {
      showToast("El ticket no trajo renglones.", "warning");
      return;
    }
    const tok = sessionTok();
    if (!tok) return;
    setSubiendo(true);
    let recId = doc?.id;
    if (!recId) {
      const total = meta.total != null ? Number(meta.total) : (totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, "")));
      const { data, error } = await supabase.rpc("recepcion_abrir", {
        p_session_token: tok,
        p_proveedor: (meta.proveedor || proveedor).trim() || null,
        p_folio: (meta.folio || folio).trim() || null,
        p_total_ticket: Number.isFinite(total) ? total : null,
      });
      if (error) {
        setSubiendo(false);
        rpcError(error, "No se pudo abrir la recepción");
        return;
      }
      const rec = aplicarDoc(data);
      recId = rec?.id;
    } else if (meta.folio || meta.proveedor || meta.total != null) {
      await supabase.rpc("recepcion_guardar_cabecera", {
        p_session_token: tok,
        p_recepcion_id: recId,
        p_proveedor: (meta.proveedor || proveedor).trim() || null,
        p_folio: (meta.folio || folio).trim() || null,
        p_total_ticket: meta.total != null ? Number(meta.total) : (totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""))),
      });
    }
    const { data, error } = await supabase.rpc("recepcion_cargar_renglones", {
      p_session_token: tok,
      p_recepcion_id: recId,
      p_items: renglones,
    });
    setSubiendo(false);
    if (error) {
      rpcError(error, "No se cargó el ticket");
      return;
    }
    aplicarDoc(data);
    const n = renglones.length;
    showToast(`${n} renglón${n === 1 ? "" : "es"} del ticket. Escanea cada caja y pon MMAA.`, "success");
    setTimeout(() => scanRef.current?.focus(), 40);
  };

  const onCsvFile = async (file) => {
    if (!file) return;
    const text = await file.text();
    const parsed = parseTicketCsv(text);
    if (parsed.proveedor) setProveedor(parsed.proveedor);
    if (parsed.folio) setFolio(parsed.folio);
    if (parsed.total != null) setTotalTicket(String(parsed.total));
    await cargarRenglones(parsed.renglones, parsed);
  };

  const onPdfFile = async (file) => {
    if (!file) return;
    setSubiendo(true);
    const buf = await file.arrayBuffer();
    const bytes = new Uint8Array(buf);
    let binary = "";
    for (let i = 0; i < bytes.length; i += 1) binary += String.fromCharCode(bytes[i]);
    const b64 = btoa(binary);
    const tok = sessionTok();
    try {
      const resp = await fetch("/api/inventarioProcesarPdf", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          session_token: tok,
          archivo_base64: b64,
          solo_extraer: true,
          proveedor: proveedor.trim() || undefined,
        }),
      });
      const json = await resp.json().catch(() => ({}));
      if (!resp.ok) {
        setSubiendo(false);
        showToast(json.error || "No se pudo leer el PDF", "error");
        return;
      }
      if (json.proveedor) setProveedor(json.proveedor);
      if (json.folio) setFolio(String(json.folio));
      if (json.total != null) setTotalTicket(String(json.total));
      await cargarRenglones(json.renglones || [], {
        folio: json.folio,
        proveedor: json.proveedor,
        total: json.total,
      });
    } catch (e) {
      setSubiendo(false);
      showToast(e.message || "Error leyendo PDF", "error");
    }
  };

  const guardarCabecera = async () => {
    if (!doc?.id) return;
    const tok = sessionTok();
    const total = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
    const { data, error } = await supabase.rpc("recepcion_guardar_cabecera", {
      p_session_token: tok,
      p_recepcion_id: doc.id,
      p_proveedor: proveedor.trim() || null,
      p_folio: folio.trim() || null,
      p_total_ticket: Number.isFinite(total) ? total : null,
    });
    if (error) rpcError(error, "No se guardó la cabecera");
    else aplicarDoc(data);
  };

  const resetLinea = () => {
    setScan("");
    setQty("");
    setCad("");
    setPendiente(null);
    setErrorLinea("");
    setTimeout(() => scanRef.current?.focus(), 30);
  };

  const resolverScan = (raw) => {
    const codigo = normalizeBarcodeRaw(raw) || String(raw || "").trim();
    if (!codigo) return null;
    const exact = findProductExactScan(productos, codigo);
    if (exact) {
      return { codigo, producto: exact, pendienteAlta: false };
    }
    if (looksLikeBarcodeInput(codigo) || /^\d{8,}$/.test(codigo)) {
      return { codigo, producto: null, pendienteAlta: true };
    }
    return { codigo, producto: null, pendienteAlta: false, noEncontrado: !looksLikeInternalSku(codigo) };
  };

  const tomarScan = (raw) => {
    const r = resolverScan(raw);
    if (!r) return;
    if (r.noEncontrado && !r.pendienteAlta) {
      setErrorLinea("Producto no encontrado. Escanea el código de la caja.");
      setScan("");
      return;
    }
    const codigo = r.codigo;
    const gray = (doc?.items || []).find((it) => !it.confirmado && itemMatchScan(it, codigo));
    if (gray) {
      setErrorLinea("");
      setPendiente({
        codigo,
        producto: { nombre: gray.nombre, sku: gray.sku },
        pendienteAlta: gray.pendiente_alta,
        itemId: gray.id,
        loteDistinto: gray.lote_distinto,
        numeroLote: gray.numero_lote,
        lotesPiso: gray.lotes_piso,
      });
      setScan(codigo);
      setQty(String(gray.cantidad || 1));
      setTimeout(() => cadRef.current?.focus(), 30);
      return;
    }
    setErrorLinea("");
    setPendiente(r);
    setScan(codigo);
    setTimeout(() => qtyRef.current?.focus(), 30);
  };

  const onScanKey = (e) => {
    if (e.key !== "Enter") return;
    e.preventDefault();
    tomarScan(scan);
  };

  const onQtyKey = (e) => {
    if (e.key === "Escape") { e.preventDefault(); resetLinea(); return; }
    if (e.key !== "Enter") return;
    e.preventDefault();
    const n = parseInt(qty, 10);
    if (!n || n <= 0) { setErrorLinea("Cantidad"); return; }
    cadRef.current?.focus();
  };

  const onQtyChange = (val) => {
    if (looksLikeBarcodeInput(val)) {
      setQty("");
      tomarScan(val);
      return;
    }
    setQty(val.replace(/[^\d]/g, "").slice(0, 5));
  };

  const onCadChange = (val) => {
    if (looksLikeBarcodeInput(val)) {
      setCad("");
      tomarScan(val);
      return;
    }
    setCad(val.replace(/\D/g, "").slice(0, 6));
  };

  const guardarLinea = async () => {
    if (!doc?.id || !pendiente) return;
    const n = parseInt(qty, 10);
    if (!n || n <= 0) { setErrorLinea("Pon la cantidad"); qtyRef.current?.focus(); return; }
    const iso = parseCaducidadMMAA(cad);
    if (!iso) { setErrorLinea("Caducidad MMAA — ej. 0629"); cadRef.current?.focus(); return; }
    setSaving(true);
    setErrorLinea("");
    const tok = sessionTok();
    let data;
    let error;
    if (pendiente.itemId) {
      ({ data, error } = await supabase.rpc("recepcion_confirmar_item", {
        p_session_token: tok,
        p_item_id: pendiente.itemId,
        p_fecha_caducidad: iso,
        p_cantidad: n,
      }));
    } else {
      ({ data, error } = await supabase.rpc("recepcion_agregar_item", {
        p_session_token: tok,
        p_recepcion_id: doc.id,
        p_codigo: pendiente.codigo,
        p_cantidad: n,
        p_fecha_caducidad: iso,
      }));
    }
    setSaving(false);
    if (error) { setErrorLinea(error.message); return; }
    aplicarDoc(data);
    resetLinea();
  };

  const onCadKey = (e) => {
    if (e.key === "Escape") { e.preventDefault(); resetLinea(); return; }
    if (e.key !== "Enter") return;
    e.preventDefault();
    guardarLinea();
  };

  const quitar = async (itemId) => {
    const tok = sessionTok();
    const { data, error } = await supabase.rpc("recepcion_quitar_item", {
      p_session_token: tok,
      p_item_id: itemId,
    });
    if (error) rpcError(error, "No se pudo quitar");
    else aplicarDoc(data);
    scanRef.current?.focus();
  };

  const descartar = async () => {
    if (!doc?.id) return;
    if (!window.confirm("¿Borrar este borrador? No se crea stock.")) return;
    const tok = sessionTok();
    const { error } = await supabase.rpc("recepcion_descartar", {
      p_session_token: tok,
      p_recepcion_id: doc.id,
    });
    if (error) { rpcError(error, "No se pudo descartar"); return; }
    setDoc(null);
    setProveedor("");
    setFolio("");
    setTotalTicket("");
    resetLinea();
    showToast("Borrador descartado", "info");
  };

  const cerrar = async () => {
    if (!doc?.id) return;
    const n = Number(doc.renglones) || 0;
    if (n === 0) { showToast("Escanea al menos un producto", "warning"); return; }
    const yaEnAnaquel = (doc.items || []).some((i) => i.lote_id);
    const msg = yaEnAnaquel
      ? "¿Cerrar? Se guardan las caducidades de caja. No se vuelve a sumar lo que ya está en anaquel."
      : `¿Cerrar recepción de ${n} renglón${n === 1 ? "" : "es"}? El stock entra ahora.`;
    if (!window.confirm(msg)) return;
    const tok = sessionTok();
    setSaving(true);
    await guardarCabecera();
    const { data, error } = await supabase.rpc("recepcion_cerrar", {
      p_session_token: tok,
      p_recepcion_id: doc.id,
    });
    setSaving(false);
    if (error) { rpcError(error, "No se pudo cerrar"); return; }
    const rec = unwrapJson(data);
    const estado = rec?.estado;
    if (estado === "descuadre") {
      showToast(`Stock recibido, pero no cuadra con el ticket (${fmt(rec.subtotal_estimado)} vs ${fmt(rec.total_ticket)}). Avísale al dueño.`, "warning");
    } else if (estado === "pendiente_alta") {
      showToast(`Stock recibido. ${rec.pendientes_alta} código(s) no están en catálogo — quedan pendientes de alta.`, "warning");
    } else {
      showToast(`Recepción confirmada · ${rec?.piezas || 0} pzas`, "success");
    }
    setDoc(null);
    setProveedor("");
    setFolio("");
    setTotalTicket("");
    resetLinea();
  };

  const items = Array.isArray(doc?.items)
    ? [...doc.items].sort((a, b) => Number(!!a.confirmado) - Number(!!b.confirmado) || Number(b.id) - Number(a.id))
    : [];
  const cadPreview = etiquetaCaducidadMMAA(cad);
  const ticketNum = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
  const estimado = Number(doc?.subtotal_estimado) || 0;

  if (loading) {
    return (
      <div style={{ padding: 28, color: C.textMid }}>Cargando recepción…</div>
    );
  }

  return (
    <div style={{ padding: isMobile ? "12px 16px 32px" : "18px 24px 40px", maxWidth: 720 }}>
      <input ref={pdfRef} type="file" accept="application/pdf,.pdf" hidden onChange={(e) => { const f = e.target.files?.[0]; e.target.value = ""; if (f) onPdfFile(f); }} />
      <input ref={csvRef} type="file" accept=".csv,text/csv,.txt" hidden onChange={(e) => { const f = e.target.files?.[0]; e.target.value = ""; if (f) onCsvFile(f); }} />
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 12, marginBottom: 16, flexWrap: "wrap" }}>
        <div>
          <h2 style={{ margin: 0, color: C.text, fontSize: 20, fontWeight: 800, display: "flex", alignItems: "center", gap: 8 }}>
            <ScanLine size={22} strokeWidth={2.2} /> Recibir
          </h2>
          <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13 }}>
            Escanea, cantidad, caducidad MMAA. O sube el PDF/CSV y solo confirma cada caja.
          </p>
        </div>
        {doc && (
          <div style={{ textAlign: "right" }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 18, letterSpacing: -0.3 }}>
              {doc.renglones || 0} renglones · {(doc.items || []).filter((i) => i.confirmado).length} ok
              {(doc.sin_confirmar > 0) ? ` · ${doc.sin_confirmar} sin caducidad` : ""}
            </div>
            {ticketNum != null && Number.isFinite(ticketNum) && (
              <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>
                estimado {fmt(estimado)} de {fmt(ticketNum)} del ticket
              </div>
            )}
          </div>
        )}
      </div>

      {!doc && (
        <form onSubmit={empezar} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, padding: isMobile ? 16 : 22 }}>
          <div style={{ color: C.text, fontWeight: 800, marginBottom: 14, fontSize: 15 }}>Ticket del proveedor</div>
          <div style={{ display: "grid", gridTemplateColumns: isMobile ? "1fr" : "1fr 1fr 1fr", gap: 12 }}>
            <div>
              <label style={labelS(C)} htmlFor="rc-prov">Proveedor</label>
              <input
                id="rc-prov"
                list="rc-prov-list"
                value={proveedor}
                onChange={(e) => setProveedor(e.target.value)}
                placeholder="Nadro, Marzam…"
                autoComplete="off"
                style={inpBase(C)}
              />
              <datalist id="rc-prov-list">
                {proveedores.map((p) => (
                  <option key={p.id} value={p.nombre} />
                ))}
              </datalist>
            </div>
            <div>
              <label style={labelS(C)} htmlFor="rc-folio">Folio del ticket</label>
              <input id="rc-folio" value={folio} onChange={(e) => setFolio(e.target.value)} placeholder="440393" autoComplete="off" style={inpBase(C)} />
            </div>
            <div>
              <label style={labelS(C)} htmlFor="rc-total">Total del ticket</label>
              <input
                id="rc-total"
                inputMode="decimal"
                value={totalTicket}
                onChange={(e) => setTotalTicket(e.target.value)}
                placeholder="9120.00"
                autoComplete="off"
                style={inpBase(C)}
              />
            </div>
          </div>
          <button
            type="submit"
            disabled={saving || subiendo}
            style={{
              marginTop: 16, padding: "12px 20px", borderRadius: 10, border: "none",
              background: BRAND.gradient, color: "#fff", fontWeight: 800, fontSize: 14, cursor: "pointer",
              width: isMobile ? "100%" : "auto",
            }}
          >
            {saving ? "Abriendo…" : "Empezar a escanear"}
          </button>
          <div style={{ display: "flex", gap: 8, marginTop: 10, flexWrap: "wrap" }}>
            <button type="button" disabled={subiendo} onClick={() => pdfRef.current?.click()} style={{ padding: "10px 14px", borderRadius: 8, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontWeight: 700, fontSize: 13, cursor: "pointer" }}>
              {subiendo ? "Leyendo…" : "Subir PDF"}
            </button>
            <button type="button" disabled={subiendo} onClick={() => csvRef.current?.click()} style={{ padding: "10px 14px", borderRadius: 8, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontWeight: 700, fontSize: 13, cursor: "pointer" }}>
              Subir CSV
            </button>
          </div>
          <div style={{ color: C.textDim, fontSize: 12, marginTop: 8, lineHeight: 1.45 }}>
            El PDF/CSV arma la lista. La caducidad sale de la caja, no del papel.
          </div>
        </form>
      )}

      {doc && (
        <>
          <div style={{ display: "grid", gridTemplateColumns: isMobile ? "1fr" : "1fr 1fr 1fr auto", gap: 8, marginBottom: 16, alignItems: "end" }}>
            <div>
              <label style={labelS(C)}>Proveedor</label>
              <input value={proveedor} onChange={(e) => setProveedor(e.target.value)} onBlur={guardarCabecera} list="rc-prov-list" style={inpBase(C, { padding: "9px 12px", fontSize: 14 })} />
              <datalist id="rc-prov-list">
                {proveedores.map((p) => (
                  <option key={p.id} value={p.nombre} />
                ))}
              </datalist>
            </div>
            <div>
              <label style={labelS(C)}>Folio</label>
              <input value={folio} onChange={(e) => setFolio(e.target.value)} onBlur={guardarCabecera} style={inpBase(C, { padding: "9px 12px", fontSize: 14 })} />
            </div>
            <div>
              <label style={labelS(C)}>Total ticket</label>
              <input value={totalTicket} onChange={(e) => setTotalTicket(e.target.value)} onBlur={guardarCabecera} inputMode="decimal" style={inpBase(C, { padding: "9px 12px", fontSize: 14 })} />
            </div>
            <button type="button" onClick={descartar} style={{ padding: "9px 12px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer", height: 42 }}>
              Descartar
            </button>
            <button type="button" disabled={subiendo} onClick={() => pdfRef.current?.click()} style={{ padding: "9px 12px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer", height: 42 }}>
              PDF
            </button>
            <button type="button" disabled={subiendo} onClick={() => csvRef.current?.click()} style={{ padding: "9px 12px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer", height: 42 }}>
              CSV
            </button>
          </div>

          <div style={{ background: C.card, border: `1px solid ${pendiente ? C.blue : C.border}`, borderRadius: 14, padding: 16, marginBottom: 16 }}>
            <label style={labelS(C)} htmlFor="rc-scan">Código de barras</label>
            <input
              id="rc-scan"
              ref={scanRef}
              value={scan}
              onChange={(e) => { setScan(e.target.value); setErrorLinea(""); }}
              onKeyDown={onScanKey}
              placeholder="Pistola aquí"
              autoComplete="off"
              autoCapitalize="off"
              disabled={!!pendiente}
              style={inpBase(C, { fontFamily: "ui-monospace, monospace", fontWeight: 700, letterSpacing: 0.4 })}
            />

            {pendiente && (
              <div style={{ marginTop: 12 }}>
                <div style={{
                  background: pendiente.pendienteAlta ? C.amberDim : C.blueDim,
                  borderRadius: 10, padding: "10px 12px", marginBottom: 12,
                }}>
                  <div style={{ fontWeight: 800, color: C.text, fontSize: 15 }}>
                    {pendiente.producto?.nombre || "No está en el catálogo"}
                  </div>
                  <div style={{ color: C.textMid, fontSize: 12, marginTop: 2, fontFamily: "ui-monospace, monospace" }}>
                    {pendiente.codigo}
                    {pendiente.pendienteAlta ? " · queda pendiente de alta" : ""}
                    {pendiente.numeroLote ? ` · lote ticket ${pendiente.numeroLote}` : ""}
                  </div>
                  {pendiente.loteDistinto && (
                    <div style={{ color: "#b45309", fontSize: 12, fontWeight: 700, marginTop: 6 }}>
                      Lote distinto al de anaquel{Array.isArray(pendiente.lotesPiso) && pendiente.lotesPiso.length ? ` (piso: ${pendiente.lotesPiso.filter(Boolean).join(", ")})` : ""}. Confirma caducidad de esta caja.
                    </div>
                  )}
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
                  <div>
                    <label style={labelS(C)} htmlFor="rc-qty">Cantidad</label>
                    <input
                      id="rc-qty"
                      ref={qtyRef}
                      inputMode="numeric"
                      value={qty}
                      onChange={(e) => onQtyChange(e.target.value)}
                      onKeyDown={onQtyKey}
                      placeholder="12"
                      autoComplete="off"
                      style={inpBase(C)}
                    />
                  </div>
                  <div>
                    <label style={labelS(C)} htmlFor="rc-cad">Caducidad MMAA</label>
                    <input
                      id="rc-cad"
                      ref={cadRef}
                      inputMode="numeric"
                      value={cad}
                      onChange={(e) => onCadChange(e.target.value)}
                      onKeyDown={onCadKey}
                      placeholder="0629"
                      autoComplete="off"
                      style={inpBase(C, { fontFamily: "ui-monospace, monospace" })}
                    />
                    {cadPreview ? (
                      <div style={{ color: C.greenDark || C.green, fontSize: 12, fontWeight: 700, marginTop: 4 }}>{cadPreview}</div>
                    ) : (
                      <div style={{ color: C.textDim, fontSize: 11, marginTop: 4 }}>Cuatro dígitos: mes y año de la caja</div>
                    )}
                  </div>
                </div>
                <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
                  <button type="button" onClick={resetLinea} style={{ padding: "10px 14px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, fontWeight: 700, fontSize: 13, cursor: "pointer" }}>
                    Cancelar
                  </button>
                  <button
                    type="button"
                    onClick={guardarLinea}
                    disabled={saving}
                    style={{ flex: 1, padding: "10px 14px", borderRadius: 8, border: "none", background: BRAND.gradient, color: "#fff", fontWeight: 800, fontSize: 13, cursor: "pointer" }}
                  >
                    {saving ? "Guardando…" : "Guardar renglón"}
                  </button>
                </div>
              </div>
            )}
            {errorLinea && <div style={{ color: C.red, fontSize: 13, fontWeight: 700, marginTop: 10 }}>{errorLinea}</div>}
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 20 }}>
            {items.length === 0 && (
              <div style={{ color: C.textMid, fontSize: 13, padding: "20px 8px", textAlign: "center" }}>
                Todavía no hay renglones. Escanea o sube el PDF/CSV del ticket.
              </div>
            )}
            {items.map((it) => {
              const ok = it.confirmado && it.fecha_caducidad;
              const bg = it.pendiente_alta ? C.amberDim : ok ? C.greenDim : "#f1f5f9";
              const border = it.pendiente_alta ? "#f5d78a" : ok ? "#86efac" : C.border;
              return (
              <div
                key={it.id}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  background: bg,
                  border: `1px solid ${border}`,
                  borderRadius: 12,
                  padding: "10px 12px",
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ color: C.text, fontWeight: 700, fontSize: 14, lineHeight: 1.3 }}>{it.nombre}</div>
                  <div style={{ color: C.textMid, fontSize: 11, marginTop: 2 }}>
                    {it.pendiente_alta ? "Pendiente de alta" : (it.sku || "")}
                    {it.numero_lote ? ` · lote ${it.numero_lote}` : ""}
                    {ok ? ` · cad ${formatCaducidadMesAnio(it.fecha_caducidad)}` : " · falta caducidad"}
                    {it.lote_distinto && !ok ? " · lote distinto al piso" : ""}
                  </div>
                </div>
                <div style={{ fontWeight: 800, fontSize: 16, color: C.text, fontVariantNumeric: "tabular-nums" }}>
                  {it.cantidad}
                </div>
                <button
                  type="button"
                  aria-label={`Quitar ${it.nombre}`}
                  onClick={() => quitar(it.id)}
                  style={{ border: "none", background: "transparent", color: C.textDim, cursor: "pointer", fontSize: 18, padding: "4px 6px" }}
                >
                  ×
                </button>
              </div>
              );
            })}
          </div>

          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            <button
              type="button"
              onClick={cerrar}
              disabled={saving || !items.length}
              style={{
                flex: 1, minWidth: 200, padding: "14px 18px", borderRadius: 10, border: "none",
                background: items.length ? BRAND.gradient : C.border,
                color: "#fff", fontWeight: 800, fontSize: 15, cursor: items.length ? "pointer" : "not-allowed",
              }}
            >
              Cerrar recepción
            </button>
          </div>
        </>
      )}
    </div>
  );
}
