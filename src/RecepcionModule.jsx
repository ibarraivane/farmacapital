import { useState, useEffect, useCallback, useRef, useMemo } from "react";
import { ScanLine, History, AlertTriangle } from "lucide-react";
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
  splitBarcodeCandidates,
} from "./utils/barcodeProductLookup";
import { etiquetaCaducidadMMAA, formatCaducidadMesAnio, parseCaducidadMMAA } from "./lib/caducidad";
import {
  eanPistolaListo,
  itemMatchScan,
  matchScanEnTicket,
  MSG_SCAN_FUERA_TICKET,
  MSG_SCAN_YA_EN_TICKET,
  pedidoEsperaEntrada,
  recepcionEsTicket,
} from "./lib/recepcionScan";
import { fetchProductosPaginados } from "./lib/inventarioHubData";
import { parseTicketCsv } from "./lib/recepcionTicketCsv";
import { getSessionToken, esErrorSesionEmpleado } from "./utils";
import { notifySesionEmpleadoInvalida } from "./utils/sesionEmpleadoAuth";
import { setBloqueaReloadApp } from "./utils/appUpdate";
import RecepcionHistorial from "./components/RecepcionHistorial";

const fmt = (n) =>
  `$${parseFloat(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

const fmtFecha = (f) => {
  const s = String(f || "").slice(0, 10);
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  return m ? `${m[3]}/${m[2]}/${m[1]}` : "";
};

function sessionTok() {
  const tok = getSessionToken();
  if (!tok) notifySesionEmpleadoInvalida();
  return tok;
}

function unwrapJson(data) {
  if (data == null) return null;
  if (typeof data === "string") {
    try { return JSON.parse(data); } catch { return null; }
  }
  return data;
}

function etiquetaProveedorLista(nombre) {
  const n = String(nombre || "").trim();
  if (!n) return "Sin proveedor";
  if (/cityfarma/i.test(n)) return "Farma City";
  if (/farmalive|farmalife/i.test(n)) return "Farmalive";
  return n;
}

async function fetchPedidosVivosApi(tok, recepcionId) {
  const resp = await fetch("/api/inventarioProcesarPdf?type=recepcion-abiertas", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      session_token: tok,
      ...(recepcionId ? { recepcion_id: recepcionId } : {}),
    }),
  });
  const json = await resp.json().catch(() => null);
  if (!resp.ok) {
    throw new Error(json?.error || `HTTP ${resp.status}`);
  }
  return json;
}

function ticketMatchScan(t, raw) {
  const codigo = normalizeBarcodeRaw(raw) || String(raw || "").trim();
  if (!t || !codigo) return false;
  const codes = Array.isArray(t.codigos) ? t.codigos : [];
  if (codes.some((c) => c && barcodeDigitsMatch(codigo, c))) return true;
  if (t.folio && String(t.folio).replace(/\D/g, "") === codigo.replace(/\D/g, "") && codigo.length >= 4) return true;
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

function normProv(s) {
  return String(s || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function nombresProveedorUnicos(proveedores) {
  const seen = new Set();
  const out = [];
  for (const p of proveedores || []) {
    const n = String(p?.nombre || "").trim();
    if (!n) continue;
    const k = normProv(n);
    if (seen.has(k)) continue;
    seen.add(k);
    out.push(n);
  }
  return out.sort((a, b) => a.localeCompare(b, "es"));
}

/** Texto libre + sugerencias del catálogo. No usa datalist nativo (el globo negro del OS). */
function ProveedorCombo({ id, value, onChange, onCommit, proveedores, C, style }) {
  const [open, setOpen] = useState(false);
  const opts = useMemo(() => nombresProveedorUnicos(proveedores), [proveedores]);
  const q = normProv(value);
  const filtered = q ? opts.filter((n) => normProv(n).includes(q)) : opts;
  const exacto = q && opts.some((n) => normProv(n) === q);
  const show = open && filtered.length > 0 && !(exacto && filtered.length === 1);

  const elegir = (n) => {
    onChange(n);
    setOpen(false);
    onCommit?.(n);
  };

  return (
    <div style={{ position: "relative" }}>
      <input
        id={id}
        value={value}
        autoComplete="off"
        autoCorrect="off"
        spellCheck={false}
        placeholder="Nadro, Marzam…"
        onChange={(e) => { onChange(e.target.value); setOpen(true); }}
        onFocus={() => setOpen(true)}
        onBlur={() => {
          setTimeout(() => setOpen(false), 140);
        }}
        onKeyDown={(e) => {
          if (e.key === "Enter") {
            e.preventDefault();
            onCommit?.(value);
            setOpen(false);
          }
        }}
        style={style}
      />
      {show && (
        <div
          role="listbox"
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            top: "100%",
            marginTop: 4,
            zIndex: 30,
            background: C.card,
            border: `1px solid ${C.border}`,
            borderRadius: 10,
            boxShadow: "0 8px 24px rgba(15,23,42,0.10)",
            overflow: "hidden",
            maxHeight: 220,
          }}
        >
          {filtered.slice(0, 8).map((n) => (
            <button
              key={n}
              type="button"
              role="option"
              onMouseDown={(e) => { e.preventDefault(); elegir(n); }}
              style={{
                display: "block",
                width: "100%",
                textAlign: "left",
                border: "none",
                background: "transparent",
                padding: "10px 12px",
                color: C.text,
                fontWeight: 700,
                fontSize: 14,
                cursor: "pointer",
              }}
            >
              {n}
            </button>
          ))}
          {q && !exacto && (
            <div style={{ padding: "8px 12px", color: C.textDim, fontSize: 11, borderTop: `1px solid ${C.border}` }}>
              Enter deja “{value.trim()}” como proveedor nuevo
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default function RecepcionModule({ ocultarMontos = false }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const scanRef = useRef(null);
  const qtyRef = useRef(null);
  const cadRef = useRef(null);
  const pdfRef = useRef(null);
  const csvRef = useRef(null);
  const scanIdleRef = useRef(null);

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
  const [codigoCopiado, setCodigoCopiado] = useState("");
  const [errorLinea, setErrorLinea] = useState("");
  const [subiendo, setSubiendo] = useState(false);
  const [pendientes, setPendientes] = useState([]);
  const [vistaNuevo, setVistaNuevo] = useState(false);
  const [listaScan, setListaScan] = useState("");
  const listaScanRef = useRef(null);
  /** "recibir" captura el ticket; "historia" solo consulta lo ya comprado. */
  const [vista, setVista] = useState("recibir");

  useEffect(() => {
    setBloqueaReloadApp(!!doc || !!pendiente, "recibir");
    return () => setBloqueaReloadApp(false, "recibir");
  }, [doc, pendiente]);

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

  const cargarLista = useCallback(async () => {
    const tok = sessionTok();
    if (!tok) return { ok: false };
    const aplicarTickets = (rows) => {
      setPendientes((Array.isArray(rows) ? rows : []).filter(pedidoEsperaEntrada));
    };
    const { data, error } = await supabase.rpc("recepcion_listar_abiertas", { p_session_token: tok });
    if (!error) {
      aplicarTickets(unwrapJson(data));
      return { ok: true };
    }
    const msg = error.message || "";
    if (esErrorSesionEmpleado(msg)) return { ok: false };
    try {
      const api = await fetchPedidosVivosApi(tok);
      aplicarTickets(api?.tickets);
      return { ok: true, viaApi: true };
    } catch (apiErr) {
      if (/does not exist|schema cache|listar_abiertas/i.test(msg)) {
        showToast("No se pudieron listar los pedidos vivos: " + (apiErr.message || msg), "error");
        setPendientes([]);
        return { ok: false, missingRpc: true };
      }
      showToast("No se pudieron listar tickets: " + msg, "error");
      return { ok: false };
    }
  }, []);

  const cargar = useCallback(async () => {
    setLoading(true);
    const tok = sessionTok();
    if (!tok) {
      setLoading(false);
      showToast("Sesión expirada.", "error");
      return;
    }
    const [provRes, prodRes] = await Promise.all([
      supabase.rpc("empleado_listar_proveedores_catalogo", { p_session_token: tok }),
      fetchProductosPaginados({
        select: "id,nombre,sku,codigo_barras,activo",
        activosSolo: true,
        order: "nombre",
      }),
    ]);
    const lista = await cargarLista();
    if (lista?.missingRpc && !lista?.viaApi) {
      const { data: borrador } = await supabase.rpc("recepcion_borrador_abierto", { p_session_token: tok });
      const rec = aplicarDoc(borrador);
      if (rec?.id) {
        setPendientes([{
          id: rec.id,
          proveedor: rec.proveedor,
          folio: rec.folio,
          estado: rec.estado,
          renglones: rec.renglones || (rec.items || []).length,
          sin_confirmar: rec.sin_confirmar,
          sin_caducidad_anaquel: rec.sin_caducidad_anaquel,
        }].filter(pedidoEsperaEntrada));
        setDoc(null);
      }
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
  }, [aplicarDoc, cargarLista]);

  useEffect(() => { cargar(); }, [cargar]);

  useEffect(() => () => {
    if (scanIdleRef.current) {
      clearTimeout(scanIdleRef.current);
      scanIdleRef.current = null;
    }
  }, []);

  const focusSafe = (ref) => {
    requestAnimationFrame(() => {
      try { ref?.current?.focus?.(); } catch (_) { /* Safari: nodo ya no está */ }
    });
  };

  useEffect(() => {
    if (vista !== "recibir") return;
    if (!loading && doc && !pendiente) {
      focusSafe(scanRef);
    }
  }, [loading, doc, pendiente, vista]);

  const rpcError = (err, fallback) => {
    const msg = err?.message || fallback;
    if (/does not exist|schema cache|cargar_renglones|confirmar_item|listar_abiertas|abrir_existente/i.test(msg)) {
      showToast("Falta correr sql/patch_recepcion_lista_pendientes_20260821.sql en Supabase.", "error");
      return;
    }
    showToast(msg, "error");
  };

  const empezar = async (e) => {
    e?.preventDefault();
    const tok = sessionTok();
    if (!tok) return;
    const folioN = folio.trim();
    if (!proveedor.trim() || !folioN) {
      showToast("Pon la tienda y el folio del ticket.", "warning");
      return;
    }
    const ya = pendientes.find((t) => folioN && String(t.folio || "").trim() === folioN && (t.renglones || 0) > 0);
    if (ya) {
      await abrirPendiente(ya.id);
      return;
    }
    setSaving(true);
    const total = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
    const { data, error } = await supabase.rpc("recepcion_abrir", {
      p_session_token: tok,
      p_proveedor: proveedor.trim() || null,
      p_folio: folioN || null,
      p_total_ticket: Number.isFinite(total) ? total : null,
    });
    setSaving(false);
    if (error) { rpcError(error, "No se pudo empezar la recepción"); return; }
    setVistaNuevo(false);
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
    setVistaNuevo(false);
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

  const guardarCabecera = async (patch = {}) => {
    if (!doc?.id) return;
    const tok = sessionTok();
    const total = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
    const prov = patch.proveedor !== undefined ? patch.proveedor : proveedor;
    const { data, error } = await supabase.rpc("recepcion_guardar_cabecera", {
      p_session_token: tok,
      p_recepcion_id: doc.id,
      p_proveedor: String(prov || "").trim() || null,
      p_folio: folio.trim() || null,
      p_total_ticket: Number.isFinite(total) ? total : null,
    });
    if (error) rpcError(error, "No se guardó la cabecera");

    else aplicarDoc(data);
  };

  const copiarCodigo = async (codigo) => {
    try {
      await navigator.clipboard.writeText(String(codigo || ""));
      setCodigoCopiado(String(codigo || ""));
      setTimeout(() => setCodigoCopiado(""), 2000);
    } catch {
      showToast("Copia el código a mano: " + codigo, "info");
    }
  };

  const resetLinea = () => {
    setScan("");
    setQty("");
    setCad("");
    setPendiente(null);
    setErrorLinea("");
    setTimeout(() => scanRef.current?.focus(), 30);
  };

  const abrirPorCodigoLista = async (raw) => {
    const codigo = normalizeBarcodeRaw(raw) || String(raw || "").trim();
    setListaScan("");
    if (!codigo) return;
    const hits = pendientes.filter((t) => ticketMatchScan(t, codigo));
    if (hits.length === 1) {
      await abrirPendiente(hits[0].id);
      return;
    }
    if (hits.length > 1) {
      showToast("Ese código está en más de un ticket. Toca la tarjeta.", "warning");
      return;
    }
    showToast("Esa caja no está en un ticket pendiente. Toca la tarjeta o captura el ticket abajo.", "warning");
  };

  const abrirPendiente = async (id) => {
    const tok = sessionTok();
    if (!tok || !id) return;
    setSaving(true);
    const { data, error } = await supabase.rpc("recepcion_abrir_existente", {
      p_session_token: tok,
      p_recepcion_id: id,
    });
    if (!error) {
      setSaving(false);
      setVistaNuevo(false);
      aplicarDoc(data);
      setTimeout(() => scanRef.current?.focus(), 40);
      return;
    }
    try {
      const api = await fetchPedidosVivosApi(tok, id);
      setSaving(false);
      setVistaNuevo(false);
      aplicarDoc(api);
      setTimeout(() => scanRef.current?.focus(), 40);
    } catch {
      setSaving(false);
      rpcError(error, "No se pudo abrir el pedido");
    }
  };

  const elegirCarga = async (id) => {
    if (doc?.id === id) {
      setTimeout(() => scanRef.current?.focus(), 40);
      return;
    }
    resetLinea();
    await abrirPendiente(id);
  };

  const volverALista = async () => {
    setDoc(null);
    setVistaNuevo(false);
    setProveedor("");
    setFolio("");
    setTotalTicket("");
    resetLinea();
    await cargarLista();
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
    try { scanRef.current?.blur(); } catch (_) { /* Safari */ }
    const codigo = r.codigo;
    if (recepcionEsTicket(doc)) {
      const { gris, yaConfirmado } = matchScanEnTicket(doc.items, codigo);
      if (gris) {
        setErrorLinea("");
        setPendiente({
          codigo,
          producto: { nombre: gris.nombre, sku: gris.sku },
          pendienteAlta: gris.pendiente_alta,
          itemId: gris.id,
          loteDistinto: gris.lote_distinto,
          numeroLote: gris.numero_lote,
          lotesPiso: gris.lotes_piso,
        });
        setScan(codigo);
        setQty(String(gris.cantidad || 1));
        focusSafe(cadRef);
        return;
      }
      const msg = yaConfirmado ? MSG_SCAN_YA_EN_TICKET : MSG_SCAN_FUERA_TICKET;
      setPendiente(null);
      setScan("");
      setErrorLinea(msg);
      showToast(msg, "warning");
      return;
    }
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
      focusSafe(cadRef);
      return;
    }
    setErrorLinea("");
    setPendiente(r);
    setScan(codigo);
    focusSafe(qtyRef);
  };

  const cancelScanIdle = () => {
    if (scanIdleRef.current) {
      clearTimeout(scanIdleRef.current);
      scanIdleRef.current = null;
    }
  };

  const programarScanPistola = (raw) => {
    cancelScanIdle();
    const codigo = normalizeBarcodeRaw(raw);
    if (!eanPistolaListo(codigo)) return;
    scanIdleRef.current = setTimeout(() => {
      scanIdleRef.current = null;
      tomarScan(codigo);
    }, 140);
  };

  const onScanKey = (e) => {
    if (e.key !== "Enter" && e.key !== "Tab") return;
    e.preventDefault();
    cancelScanIdle();
    tomarScan(e.currentTarget.value);
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
    if (recepcionEsTicket(doc) && !pendiente.itemId) {
      setErrorLinea(MSG_SCAN_FUERA_TICKET);
      setSaving(false);
      return;
    }
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
    showToast("Borrador descartado", "info");
    await volverALista();
  };

  const cerrar = async () => {
    if (!doc?.id) return;
    const lista = Array.isArray(doc.items) ? doc.items : [];
    const anaquelSinCad = lista.filter((i) => i.lote_id && !i.fecha_caducidad).length;
    const grisPendiente = lista.filter((i) => !i.pendiente_alta && !i.confirmado).length;
    const confirmadosOk = lista.filter((i) => i.confirmado && i.fecha_caducidad).length;
    if (anaquelSinCad > 0) {
      showToast(`Faltan ${anaquelSinCad} caducidad(es) de cajas ya en anaquel. Escanea cada una y teclea MMAA (ej. 0629).`, "warning");
      return;
    }
    if (confirmadosOk === 0) {
      showToast("Escanea cada caja y teclea caducidad MMAA antes de cerrar.", "warning");
      return;
    }
    const noRegistrados = lista.filter((i) => i.pendiente_alta);
    if (noRegistrados.length > 0) {
      const detalle = noRegistrados.map((i) => `  · ${i.codigo_escaneado} × ${i.cantidad}`).join("\n");
      const seguir = window.confirm(
        `OJO: ${noRegistrados.length} producto(s) no están en catálogo y NO van a entrar a stock:\n\n${detalle}\n\n` +
        "Lo correcto es darlos de alta en Inventario → Catálogo → Nuevo producto y volver a escanear esas cajas.\n\n" +
        "¿Cerrar de todos modos y dejar esas piezas fuera del inventario?",
      );
      if (!seguir) return;
    }
    const yaEnAnaquel = lista.some((i) => i.lote_id);
    let msg;
    if (grisPendiente > 0) {
      msg = `Hay ${grisPendiente} sin escanear. ¿Recibir las ${confirmadosOk} confirmadas y dejar ${grisPendiente} pendiente${grisPendiente === 1 ? "" : "s"} en Recibir?`;
    } else if (yaEnAnaquel) {
      msg = "¿Cerrar? Se guardan las caducidades de caja. No se vuelve a sumar lo que ya está en anaquel.";
    } else {
      msg = `¿Cerrar recepción de ${confirmadosOk} renglón${confirmadosOk === 1 ? "" : "es"}? El stock entra ahora.`;
    }
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
    try {
      await fetch("/api/inventarioProcesarPdf?type=ultima-compra", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ session_token: tok, recepcion_id: rec?.id || doc.id }),
      });
    } catch {
      /* la columna se puede rellenar después; el stock ya entró */
    }
    const estado = rec?.estado;
    const siguenPendientes = (rec?.sin_confirmar || 0) > 0 && estado === "borrador";
    if (siguenPendientes) {
      aplicarDoc(rec);
      showToast(`Entró lo confirmado. Quedan ${rec.sin_confirmar} pendiente${rec.sin_confirmar === 1 ? "" : "s"} en Recibir.`, "warning");
      return;
    }
    if (estado === "pendiente_alta") {
      showToast(`Stock recibido. ${rec.pendientes_alta} código(s) no están en catálogo — quedan pendientes de alta.`, "warning");
    } else {
      const quedan = pendientes.filter((t) => t.id !== doc.id).length;
      showToast(
        quedan > 0
          ? "Guardado. Toca el siguiente proveedor."
          : `Recepción confirmada · ${rec?.piezas || 0} pzas`,
        "success",
      );
    }
    setDoc(null);
    setProveedor("");
    setFolio("");
    setTotalTicket("");
    resetLinea();
    await cargarLista();
  };

  const items = Array.isArray(doc?.items)
    ? [...doc.items].sort((a, b) => Number(!!a.confirmado) - Number(!!b.confirmado) || Number(b.id) - Number(a.id))
    : [];
  const anaquelSinCad = items.filter((i) => i.lote_id && !i.fecha_caducidad).length;
  const sinRegistrar = items.filter((i) => i.pendiente_alta);
  const grisPendiente = items.filter((i) => !i.pendiente_alta && !i.confirmado).length;
  const confirmadosOk = items.filter((i) => i.confirmado && i.fecha_caducidad).length;
  const puedeCerrar = confirmadosOk > 0 && anaquelSinCad === 0;
  const cadPreview = etiquetaCaducidadMMAA(cad);
  const ticketNum = totalTicket.trim() === "" ? null : Number(String(totalTicket).replace(/,/g, ""));
  const estimado = Number(doc?.subtotal_estimado) || 0;

  const tabBar = (
    <div style={{ display: "flex", gap: 6, borderBottom: `1px solid ${C.border}`, marginBottom: 16 }}>
      {[
        { id: "recibir", label: "Recibir", Icon: ScanLine },
        { id: "historia", label: "Historia", Icon: History },
      ].map(({ id, label, Icon }) => {
        const activo = vista === id;
        return (
          <button
            key={id}
            type="button"
            onClick={() => setVista(id)}
            style={{
              display: "inline-flex", alignItems: "center", gap: 6,
              padding: "9px 14px", marginBottom: -1,
              background: "transparent", border: "none",
              borderBottom: `2px solid ${activo ? BRAND.primary : "transparent"}`,
              color: activo ? BRAND.primary : C.textMid,
              fontWeight: 700, fontSize: 13, cursor: "pointer",
            }}
          >
            <Icon size={15} strokeWidth={2.1} />
            {label}
          </button>
        );
      })}
    </div>
  );

  if (vista === "historia") {
    return (
      <div style={{ padding: isMobile ? "12px 16px 32px" : "18px 24px 40px", maxWidth: 1180 }}>
        <div style={{ marginBottom: 16 }}>
          <h2 style={{ margin: 0, color: C.text, fontSize: 20, fontWeight: 800, display: "flex", alignItems: "center", gap: 8 }}>
            <ScanLine size={22} strokeWidth={2.2} /> Recibir
          </h2>
          <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13 }}>
            Todo lo que has comprado, ticket por ticket. Cada columna es una entrada; el color dice si esa vez salió más barato o más caro que la compra anterior.
          </p>
        </div>
        {tabBar}
        <RecepcionHistorial ocultarMontos={ocultarMontos} />
      </div>
    );
  }

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
            Si hay un pedido vivo, tócalo (sale el nombre de la tienda). Si son pocas piezas, llena el ticket abajo y escanea.
          </p>
        </div>
        {doc && (
          <div style={{ textAlign: "right" }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 18, letterSpacing: -0.3 }}>
              {doc.renglones || 0} renglones · {(doc.items || []).filter((i) => i.confirmado).length} ok
              {(doc.sin_confirmar > 0) ? ` · ${doc.sin_confirmar} sin caducidad` : ""}
            </div>
            {ticketNum != null && Number.isFinite(ticketNum) && !ocultarMontos && (
              <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>
                estimado {fmt(estimado)} de {fmt(ticketNum)} del ticket
              </div>
            )}
          </div>
        )}
      </div>

      {tabBar}

      {pendientes.length > 0 && (
        <div style={{ marginBottom: 16 }}>
          <div style={{ color: C.textMid, fontSize: 11, fontWeight: 800, letterSpacing: 0.5, textTransform: "uppercase", marginBottom: 8 }}>
            Pedidos vivos · esperando entrada
          </div>
          {!doc && (
            <input
              ref={listaScanRef}
              value={listaScan}
              onChange={(e) => {
                const v = e.target.value;
                setListaScan(v);
                cancelScanIdle();
                const codigo = normalizeBarcodeRaw(v);
                if (looksLikeBarcodeInput(codigo) && [8, 12, 13, 14].includes(codigo.length)) {
                  scanIdleRef.current = setTimeout(() => {
                    scanIdleRef.current = null;
                    abrirPorCodigoLista(codigo);
                  }, 140);
                }
              }}
              onKeyDown={(e) => {
                if (e.key !== "Enter" && e.key !== "Tab") return;
                e.preventDefault();
                cancelScanIdle();
                abrirPorCodigoLista(e.currentTarget.value);
              }}
              placeholder="O pistola aquí: abre el ticket de esa caja"
              autoComplete="off"
              autoCapitalize="off"
              style={inpBase(C, { fontFamily: "ui-monospace, monospace", fontWeight: 700, marginBottom: 10 })}
            />
          )}
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
            {pendientes.map((t) => {
              const activo = doc?.id === t.id;
              const cajas = t.renglones || 0;
              const porEntrar = Number(t.sin_confirmar || 0) || Number(t.sin_caducidad_anaquel || 0);
              return (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => elegirCarga(t.id)}
                  disabled={saving}
                  style={{
                    flex: "1 1 160px",
                    textAlign: "left",
                    background: activo ? `${BRAND.primary}14` : C.card,
                    border: `2px solid ${activo ? BRAND.primary : C.border}`,
                    borderRadius: 14,
                    padding: "14px 16px",
                    cursor: "pointer",
                  }}
                >
                  <div style={{ color: activo ? BRAND.primary : C.text, fontWeight: 800, fontSize: 17 }}>
                    {etiquetaProveedorLista(t.proveedor)}
                  </div>
                  <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>
                    {cajas} {cajas === 1 ? "caja" : "cajas"}
                    {porEntrar > 0 ? ` · ${porEntrar} por entrar` : ""}
                    {activo ? " · abierto" : ""}
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      )}

      {!doc && pendientes.length === 0 && (
        <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, padding: isMobile ? 20 : 24, color: C.textMid, fontSize: 13, lineHeight: 1.5, marginBottom: 16 }}>
          No hay pedidos vivos esperando entrada. Para un ticket chico, captura proveedor y folio abajo.
        </div>
      )}

      {!doc && (
        <form onSubmit={empezar} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, padding: isMobile ? 16 : 22 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 800, letterSpacing: 1, textTransform: "uppercase", marginBottom: 6 }}>
            Ticket que no está en la lista
          </div>
          <div style={{ color: C.text, fontWeight: 800, marginBottom: 6, fontSize: 15 }}>Entrada manual</div>
          <p style={{ margin: "0 0 14px", color: C.textMid, fontSize: 13, lineHeight: 1.45 }}>
            Pocas piezas: pon la tienda, el folio y empieza a escanear. No hace falta PDF.
          </p>
          <div style={{ display: "grid", gridTemplateColumns: isMobile ? "1fr" : "1fr 1fr 1fr", gap: 12 }}>
            <div>
              <label style={labelS(C)} htmlFor="rc-prov">Proveedor</label>
              <ProveedorCombo
                id="rc-prov"
                value={proveedor}
                onChange={setProveedor}
                proveedores={proveedores}
                C={C}
                style={inpBase(C)}
              />
            </div>
            <div>
              <label style={labelS(C)} htmlFor="rc-folio">Folio del ticket</label>
              <input id="rc-folio" value={folio} onChange={(e) => setFolio(e.target.value)} placeholder="440393" autoComplete="off" style={inpBase(C)} />
            </div>
            {!ocultarMontos && (
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
            )}
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
            PDF/CSV es opcional (ticket largo). La caducidad siempre sale de la caja.
          </div>
        </form>
      )}

      {doc ? (
        <div>
          <div style={{ background: C.card, border: `1px solid ${pendiente ? C.blue : C.border}`, borderRadius: 14, padding: 16, marginBottom: 16 }}>
            <label style={labelS(C)} htmlFor="rc-scan">Código de barras</label>
            <input
              id="rc-scan"
              ref={scanRef}
              value={scan}
              onChange={(e) => {
                setScan(e.target.value);
                setErrorLinea("");
                programarScanPistola(e.target.value);
              }}
              onKeyDown={onScanKey}
              placeholder="Pistola aquí"
              autoComplete="off"
              autoCapitalize="off"
              readOnly={!!pendiente}
              style={inpBase(C, { fontFamily: "ui-monospace, monospace", fontWeight: 700, letterSpacing: 0.4 })}
            />

            {pendiente && (
              <div style={{ marginTop: 12 }}>
                {pendiente.pendienteAlta ? (
                  <div style={{
                    background: C.redDim, border: "2px solid #fca5a5",
                    borderRadius: 10, padding: "12px 14px", marginBottom: 12,
                  }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#b91c1c", fontWeight: 900, fontSize: 15 }}>
                      <AlertTriangle size={18} />
                      Este producto NO está registrado
                    </div>
                    <div style={{ color: C.text, fontSize: 13, lineHeight: 1.45, marginTop: 8 }}>
                      Hay que darlo de alta <strong>antes</strong> de recibirlo. Ve a <strong>Inventario → Catálogo → ➕ Nuevo producto</strong>,
                      pega este código de barras, pon nombre y costo de la factura, deja el stock en 0 y guarda. Luego vuelve aquí y escanea la caja otra vez.
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 10, flexWrap: "wrap" }}>
                      <code style={{
                        fontFamily: "ui-monospace, monospace", fontSize: 15, fontWeight: 800, letterSpacing: 0.5,
                        background: C.card, border: `1px solid ${C.border}`, borderRadius: 8, padding: "6px 10px", color: C.text,
                      }}>
                        {pendiente.codigo}
                      </code>
                      <button
                        type="button"
                        onClick={() => copiarCodigo(pendiente.codigo)}
                        style={{
                          padding: "7px 12px", borderRadius: 8, border: `1px solid ${C.border}`,
                          background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
                        }}
                      >
                        {codigoCopiado === pendiente.codigo ? "Copiado ✓" : "Copiar código"}
                      </button>
                    </div>
                    <div style={{ color: "#b91c1c", fontSize: 12, fontWeight: 700, marginTop: 10, lineHeight: 1.4 }}>
                      Si lo guardas así, la caja queda anotada pero <u>no entra a stock</u> y el sistema no la va a poder vender.
                    </div>
                  </div>
                ) : (
                  <div style={{ background: C.blueDim, borderRadius: 10, padding: "10px 12px", marginBottom: 12 }}>
                    <div style={{ fontWeight: 800, color: C.text, fontSize: 15 }}>
                      {pendiente.producto?.nombre || "No está en el catálogo"}
                    </div>
                    <div style={{ color: C.textMid, fontSize: 12, marginTop: 2, fontFamily: "ui-monospace, monospace" }}>
                      {pendiente.codigo}
                      {pendiente.numeroLote ? ` · lote ticket ${pendiente.numeroLote}` : ""}
                    </div>
                    {pendiente.loteDistinto && (
                      <div style={{ color: "#b45309", fontSize: 12, fontWeight: 700, marginTop: 6 }}>
                        Lote distinto al de anaquel{Array.isArray(pendiente.lotesPiso) && pendiente.lotesPiso.length ? ` (piso: ${pendiente.lotesPiso.filter(Boolean).join(", ")})` : ""}. Confirma caducidad de esta caja.
                      </div>
                    )}
                  </div>
                )}
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
                    style={{
                      flex: 1, padding: "10px 14px", borderRadius: 8,
                      border: pendiente.pendienteAlta ? "1px solid #fca5a5" : "none",
                      background: pendiente.pendienteAlta ? C.card : BRAND.gradient,
                      color: pendiente.pendienteAlta ? "#b91c1c" : "#fff",
                      fontWeight: 800, fontSize: 13, cursor: "pointer",
                    }}
                  >
                    {saving
                      ? "Guardando…"
                      : pendiente.pendienteAlta
                        ? "Anotar sin registrar (no entra a stock)"
                        : "Guardar renglón"}
                  </button>
                </div>
              </div>
            )}
            {errorLinea && <div style={{ color: C.red, fontSize: 13, fontWeight: 700, marginTop: 10 }}>{errorLinea}</div>}
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 20 }}>
            {items.length === 0 && (
              <div style={{ color: C.textMid, fontSize: 13, padding: "20px 8px", textAlign: "center" }}>
                Escanea cada caja. Pon cantidad y caducidad MMAA.
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

          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            {sinRegistrar.length > 0 && (
              <div style={{ background: C.redDim, border: "2px solid #fca5a5", borderRadius: 10, padding: "12px 14px", color: C.text, fontSize: 13, lineHeight: 1.45 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#b91c1c", fontWeight: 900, marginBottom: 6 }}>
                  <AlertTriangle size={16} />
                  {sinRegistrar.length} producto{sinRegistrar.length === 1 ? "" : "s"} sin registrar en catálogo
                </div>
                Dalos de alta en <strong>Inventario → Catálogo → ➕ Nuevo producto</strong> y vuelve a escanear esas cajas.
                Si cierras así, esas piezas <u>no entran a stock</u>:
                <div style={{ fontFamily: "ui-monospace, monospace", fontSize: 12, marginTop: 8, color: C.textMid }}>
                  {sinRegistrar.map((i) => `${i.codigo_escaneado} × ${i.cantidad}`).join("  ·  ")}
                </div>
              </div>
            )}
            {anaquelSinCad > 0 && (
              <div style={{ background: C.amberDim, border: `1px solid #f5d78a`, borderRadius: 10, padding: "12px 14px", color: C.text, fontSize: 13, lineHeight: 1.45 }}>
                {anaquelSinCad} caja{anaquelSinCad === 1 ? "" : "s"} ya en anaquel sin MMAA. Escanea cada una y teclea la caducidad (ej. 0629). No se puede cerrar hasta entonces: si no, el sistema no sabe qué caduca primero.
              </div>
            )}
            {anaquelSinCad === 0 && grisPendiente > 0 && confirmadosOk > 0 && (
              <div style={{ background: "#f1f5f9", border: `1px solid ${C.border}`, borderRadius: 10, padding: "12px 14px", color: C.textMid, fontSize: 13, lineHeight: 1.45 }}>
                {grisPendiente} sin pistola. Puedes recibir lo confirmado y dejar el resto pendiente aquí, o quitar con × lo que no llegó.
              </div>
            )}
            <button
              type="button"
              onClick={cerrar}
              disabled={saving || !puedeCerrar}
              style={{
                flex: 1, minWidth: 200, padding: "14px 18px", borderRadius: 10, border: "none",
                background: puedeCerrar ? BRAND.gradient : C.border,
                color: "#fff", fontWeight: 800, fontSize: 15, cursor: puedeCerrar ? "pointer" : "not-allowed",
              }}
            >
              {saving
                ? "Guardando…"
                : anaquelSinCad > 0
                  ? `Faltan ${anaquelSinCad} caducidad${anaquelSinCad === 1 ? "" : "es"}`
                  : confirmadosOk === 0
                    ? "Escanea para guardar"
                    : grisPendiente > 0
                      ? "Guardar lo confirmado"
                      : "Guardar"}
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
