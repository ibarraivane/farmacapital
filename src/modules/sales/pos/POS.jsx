import React, { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { useMediaQuery } from "../../../hooks/useMediaQuery";
import TicketPreviewModal from "../../../components/tickets/TicketPreviewModal";
import MercadoPagoModal from "../../../components/MercadoPagoModal";
import BBVATerminalModal from "../../../components/BBVATerminalModal";
import { supabase } from "../../../supabase";
import { C_LIGHT, BRAND } from "../../../constants";
import { $, logAudit, soloDigitosTel, normalizeForSearch } from "../../../utils";
import { tiendaProductMatchesBusqueda, tiendaCatalogSearchSuggestions, tiendaSearchRelevanceRank } from "../../../utils/fuzzySearch";
import { findProductExactScan, looksLikeBarcodeInput, isAllDigitsInput, normalizeBarcodeRaw, shouldReplaceScanInput } from "../../../utils/barcodeProductLookup";
import { posTituloProducto, posSubtituloProducto } from "../../../utils/posProductDisplay";
import { precioUnidadParaVenta } from "../../../utils/precioUnidad";
import {
  suggestPosProductsLocal,
  posEsOtcConStock,
  describePosProductUseLocal,
  describePosProductUseFallback,
} from "../../../utils/posConocimientoFarmacia";
import { Box, Tag, Btn, Inp, Modal, showToast, SearchDropdown, SkeletonTable } from "../../../ui";
import {
  CONSULTA_PRECIO_DEFAULT,
  CONSULTA_PARTE_DOCTOR,
  citaPagoPendiente,
  citaEstaPagada,
  labelCanal,
  labelEstadoPagoCita,
  citaRelevanteParaResumenPOS,
} from "../../../utils/consultaConstants";
import { puedeCancelarCitaNoShow } from "../../../utils/citasAgenda";
import { esPedidoTiendaWebPendiente, fetchPedidosTiendaPendientesMerged } from "../../../utils/pedidosTiendaWeb";
import { desgloseCambioMN, sugerenciasPagoCliente } from "../../../utils/cambioCaja";
import { marcarMedicamentosRecetaFarmaCapitalSurtidos } from "../../../utils/recetaCitaSync";
import OnboardingTour from "../../../components/OnboardingTour";
import { TOURS } from "../../../utils/tours";
import { labelTipoEntregaPedido } from "../../../utils/orderChannels";
import PagoServiciosPanel, { rpcRegistrarPagoServicio } from "./PagoServiciosPanel";
import { buildOnlineOrderReceiptMessage, buildOnlineOrderReadyMessage, formatFolioOnline, openWhatsAppToCustomer } from "../../../utils/orderReceiptWhatsApp";
import { formatTelefonoDisplay } from "../../../utils/citaWhatsApp";
import { configRowsToMap, mergeFarmaciaConfig, FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";

const PEDIDOS_TIENDA_SELECT_POS = `
            id,total,created_at,tipo,metodo_pago,estado,tipo_entrega,direccion,
            guest_nombre,guest_telefono,guest_email,
            clientes(nombre,telefono),
            pedido_items(cantidad,precio_unitario,productos(nombre,sku,ubicacion_texto))
          `;

function ubicacionPedidoItem(item) {
  const raw = item?.productos?.ubicacion_texto;
  return String(raw || "").trim() || "Sin ubicación";
}

function posVariantesDeProducto(productos, item) {
  if (!item) return [];
  const pa = String(item.principio_activo || "").trim().toLowerCase();
  const dg = String(item.denominacion_generica || "").trim().toLowerCase();
  if (!pa && !dg) return [item];
  const matches = productos.filter((p) => {
    if (p.activo === false) return false;
    if (pa && String(p.principio_activo || "").trim().toLowerCase() === pa) return true;
    if (dg && String(p.denominacion_generica || "").trim().toLowerCase() === dg) return true;
    return false;
  });
  const list = matches.length > 1 ? matches : [item];
  return [...list].sort((a, b) =>
    String(a.concentracion || "").localeCompare(String(b.concentracion || ""), "es")
  );
}

function posFichaLinea(item) {
  return posSubtituloProducto(item) || [item.concentracion, item.presentacion, item.forma_farmaceutica].filter(Boolean).join(" · ");
}

const POS_USO_CACHE_KEY = "farmacapital_pos_uso_cache_v1";

function posDescripcionPareceTicket(text) {
  const d = String(text || "").trim();
  if (!d) return false;
  if (/\$|descto|ticket\s|lab\s+pisa|\|\s*lab|\d+\s*ml\s*\|/i.test(d)) return true;
  if (/\d+[.,]\d{2}/.test(d) && d.length > 40) return true;
  return false;
}

function posDescripcionEsUsoValido(item) {
  const d = String(item?.descripcion || "").trim();
  if (!d || posDescripcionPareceTicket(d)) return false;
  const nom = String(item?.nombre || "").trim().toLowerCase();
  if (nom && d.toLowerCase() === nom) return false;
  return true;
}

function posUsoFallback(item) {
  return describePosProductUseFallback(item);
}

function readPosUsoCache() {
  try {
    const raw = localStorage.getItem(POS_USO_CACHE_KEY);
    const parsed = raw ? JSON.parse(raw) : {};
    return parsed && typeof parsed === "object" ? parsed : {};
  } catch {
    return {};
  }
}

function writePosUsoCacheEntry(productId, texto) {
  try {
    const prev = readPosUsoCache();
    prev[String(productId)] = texto;
    localStorage.setItem(POS_USO_CACHE_KEY, JSON.stringify(prev));
  } catch {
    /* noop */
  }
}

function posEtiquetaForma(item) {
  const f = String(item?.forma_farmaceutica || "").trim();
  if (f) return f;
  const n = String(item?.nombre || "").toLowerCase();
  if (/\bcaps?\b|cápsula|capsula|\bcap\b/.test(n)) return "Cápsula";
  if (/\bcomp\b|comprimido|tablet/.test(n)) return "Comprimido";
  if (/jarabe|suspensi[oó]n|\bsusp\b/.test(n)) return "Jarabe / suspensión";
  if (/crema|gel|ung[uü]ento|loci[oó]n/.test(n)) return "Uso tópico";
  if (/soluci[oó]n|spray|gotas/.test(n)) return "Solución / gotas";
  return null;
}

function PosProductoFichaPanel({
  item,
  productos,
  onSelectVariante,
  onAddCaja,
  onAddUnidad,
  onAbrirCaja,
  getStockCajasPOS,
  productoSinLotesPEPS,
  usoTexto,
  usoLoading,
  C,
  isMobilePos,
  isNarrow,
  sticky = false,
}) {
  const panelShell = {
    marginBottom: 14,
    borderRadius: 16,
    border: `1px solid ${item ? C.blue + "35" : C.border}`,
    background: C.card,
    overflow: "hidden",
    boxShadow: item ? "0 8px 28px rgba(30,58,186,.08)" : "none",
    minHeight: isMobilePos ? 200 : 260,
    ...(sticky ? { position: "sticky", top: 0, zIndex: 25 } : {}),
  };

  if (!item) {
    return (
      <div style={{ ...panelShell, display: "flex", alignItems: "center", justifyContent: "center", padding: "28px 20px" }}>
        <div style={{ textAlign: "center", maxWidth: 420 }}>
          <div style={{ fontSize: isMobilePos ? 40 : 52, marginBottom: 10, lineHeight: 1 }} aria-hidden>💊</div>
          <div style={{ fontWeight: 900, fontSize: isMobilePos ? 16 : 18, color: C.text, marginBottom: 6 }}>
            Busca o escanea un producto
          </div>
          <p style={{ margin: 0, fontSize: 13, lineHeight: 1.55, color: C.textMid }}>
            La ficha aparece aquí: foto grande, presentación, forma farmacéutica y para qué se usa normalmente.
            Enter en el buscador agrega al carrito.
          </p>
        </div>
      </div>
    );
  }

  const thumb = item.imagen_url || item.imagen_mobile_url || "";
  const variantes = posVariantesDeProducto(productos, item);
  const stockCajas = getStockCajasPOS(item);
  const sinLotes = productoSinLotesPEPS(item);
  const agotado = stockCajas <= 0 && (!item.venta_unidad || item.stock_unidades === 0);
  const uso = usoLoading
    ? "Consultando uso con Claude…"
    : (usoTexto || posUsoFallback(item));
  const forma = posEtiquetaForma(item);
  const stack = isMobilePos || isNarrow;

  const metaCell = (label, value) => (
    <div style={{ background: C.bg, borderRadius: 10, padding: "10px 12px", minWidth: 0 }}>
      <div style={{ fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.4, marginBottom: 4, textTransform: "uppercase" }}>
        {label}
      </div>
      <div style={{ fontSize: 13, fontWeight: 700, color: value ? C.text : C.textDim, lineHeight: 1.35 }}>
        {value || "—"}
      </div>
    </div>
  );

  return (
    <div style={panelShell} data-tour="pos-ficha-producto">
      <div
        style={{
          display: "grid",
          gridTemplateColumns: stack ? "1fr" : "minmax(200px, 34%) 1fr",
          gap: stack ? 14 : 20,
          padding: stack ? 14 : "18px 20px",
          alignItems: stack ? "stretch" : "start",
        }}
      >
        <div
          style={{
            borderRadius: 14,
            overflow: "hidden",
            background: C.cardDark,
            minHeight: stack ? 180 : 240,
            maxHeight: stack ? 220 : 280,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {thumb ? (
            <img
              src={thumb}
              alt=""
              style={{ width: "100%", height: "100%", minHeight: stack ? 180 : 240, objectFit: "contain", display: "block" }}
            />
          ) : (
            <span style={{ fontSize: 72, opacity: 0.35 }} aria-hidden>💊</span>
          )}
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12, minWidth: 0 }}>
          <div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 6, alignItems: "center", marginBottom: 6 }}>
              <span style={{ color: C.textDim, fontSize: 10, fontWeight: 800, letterSpacing: 1 }}>{item.sku}</span>
              {item.requiere_receta && <Tag col={C.amber} sm>⚕ Receta</Tag>}
              {item.controlado && <Tag col={C.red} sm>Controlado</Tag>}
              {item.tipo === "generico" && <Tag col={C.teal} sm>Genérico</Tag>}
              {!item.requiere_receta && !item.controlado && <Tag col={C.blue} sm>Venta libre</Tag>}
              {sinLotes ? <Tag col={C.red} sm>Sin lotes</Tag> : agotado ? <Tag col={C.red} sm>Agotado</Tag> : <Tag col={C.green} sm>{stockCajas} en stock</Tag>}
            </div>
            <h2 style={{ margin: 0, fontSize: stack ? 17 : 20, fontWeight: 900, color: C.text, lineHeight: 1.25 }}>
              {posTituloProducto(item)}
            </h2>
            {posSubtituloProducto(item) && (
              <div style={{ fontSize: 12, color: C.textMid, marginTop: 6, lineHeight: 1.4 }}>
                {posSubtituloProducto(item)}
              </div>
            )}
          </div>

          <div style={{ display: "grid", gridTemplateColumns: stack ? "1fr 1fr" : "repeat(3, minmax(0, 1fr))", gap: 8 }}>
            {metaCell("Gramaje / dosis", item.concentracion || null)}
            {metaCell("Presentación", item.presentacion || null)}
            {metaCell("Forma", forma)}
          </div>

          <div style={{ background: C.blueDim, borderRadius: 12, padding: "12px 14px" }}>
            <div style={{ fontSize: 10, fontWeight: 800, color: C.blue, letterSpacing: 0.5, marginBottom: 6, textTransform: "uppercase" }}>
              Para qué se usa normalmente
            </div>
            <p style={{ margin: 0, fontSize: 13, lineHeight: 1.55, color: usoLoading ? C.textDim : C.textMid, fontStyle: usoLoading ? "italic" : "normal" }}>
              {uso}
            </p>
          </div>

          {variantes.length > 1 && (
            <div>
              <div style={{ fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.5, marginBottom: 8 }}>
                Otras presentaciones (mismo principio)
              </div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                {variantes.map((v) => {
                  const sel = v.id === item.id;
                  const label = posFichaLinea(v) || v.nombre;
                  return (
                    <button
                      key={v.id}
                      type="button"
                      onClick={() => onSelectVariante(v)}
                      style={{
                        padding: "8px 12px",
                        borderRadius: 8,
                        border: `2px solid ${sel ? C.blue : C.border}`,
                        background: sel ? C.blueDim : C.bg,
                        cursor: "pointer",
                        fontSize: 12,
                        fontWeight: sel ? 800 : 600,
                        color: sel ? C.blue : C.text,
                        textAlign: "left",
                      }}
                    >
                      <div>{label}</div>
                      <div style={{ fontSize: 11, color: C.textDim, marginTop: 2 }}>{$(v.precio)}</div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          <div style={{ display: "flex", flexWrap: "wrap", alignItems: "center", gap: 10, justifyContent: "space-between" }}>
            <div>
              <div style={{ fontSize: 11, color: C.textDim, marginBottom: 2 }}>Precio</div>
              <div style={{ fontSize: stack ? 22 : 26, fontWeight: 900, color: C.blue, lineHeight: 1 }}>
                {item.descuento_pct > 0 ? (
                  <>
                    <span style={{ fontSize: 14, color: C.textDim, textDecoration: "line-through", marginRight: 8 }}>{$(item.precio)}</span>
                    {$(Math.round((item.precio || 0) * (1 - item.descuento_pct / 100)))}
                  </>
                ) : (
                  $(item.precio)
                )}
              </div>
            </div>
            <span style={{ fontSize: 12, fontWeight: 700, color: item.ubicacion_texto ? C.blue : C.textDim }}>
              📍 {item.ubicacion_texto || "Sin ubicación"}
            </span>
          </div>

          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, paddingTop: 4 }}>
            {item.venta_unidad ? (
              <>
                <Btn col={C.blue} disabled={stockCajas <= 0} onClick={() => onAddCaja(item)} style={{ flex: "1 1 160px" }}>
                  📦 Caja · {$(item.precio)}
                </Btn>
                <Btn
                  outline
                  col={C.green}
                  disabled={stockCajas <= 0 && item.stock_unidades === 0}
                  onClick={() => {
                    if (item.stock_unidades > 0) onAddUnidad(item);
                    else if (stockCajas > 0) onAbrirCaja(item);
                    else showToast("Sin stock disponible.", "warning");
                  }}
                  style={{ flex: "1 1 160px" }}
                >
                  💊 1 unidad · {$(precioUnidadParaVenta(item))}
                </Btn>
              </>
            ) : (
              <Btn
                col={C.blue}
                full
                disabled={sinLotes || stockCajas <= 0}
                onClick={() => {
                  if (sinLotes) {
                    showToast("Sin lotes registrados. Ve a Inventario → Lotes.", "warning");
                    return;
                  }
                  onAddCaja(item);
                }}
              >
                Agregar al carrito · {$(item.precio)}
              </Btn>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function POS({negocio,usuario,initialTab="venta",onNavigate}){
  const C = C_LIGHT;
  /** Vista estrecha (tablet / ventana angosta): tipografía, grillas, cabecera. */
  const isNarrow = useMediaQuery("(max-width: 1100px)");
  /** Solo celular / pantalla muy estrecha: carrito en modal + barra Carrito/total/? (no afecta escritorio). */
  const isMobilePos = useMediaQuery("(max-width: 768px)");
  const [tab,setTab]         = useState(initialTab); // venta | online | consultas | servicios
  const [productos,setProds] = useState([]);
  const [cart,setCart]       = useState([]);
  const [srch,setSrch]       = useState("");
  const [srchFocus,setSrchFocus] = useState(false);
  const srchRef = useRef(null);
  const srchWrapRef = useRef(null);
  /** Tour POS: botón "?" va en la barra de carrito (no FAB esquina). */
  const posTourRef = useRef(null);
  // iOS Safari hace zoom al enfocar inputs si el tamaño es <16px o si el foco llega al cargar.
  // En ≤768px no autoenfocamos el buscador para que la vista entre completa sin pellizcar.
  useEffect(() => {
    if (tab !== "venta" || typeof window === "undefined") return;
    if (window.matchMedia("(max-width: 768px)").matches) return;
    srchRef.current?.focus();
  }, [tab]);
  const [favs,setFavs]       = useState(()=>{ try{ return JSON.parse(localStorage.getItem("farmacapital_pos_favs")||"[]"); }catch{ return []; } });
  const toggleFav = id => {
    setFavs(p=>{
      const n = p.includes(id)?p.filter(x=>x!==id):[...p,id].slice(0,8);
      localStorage.setItem("farmacapital_pos_favs", JSON.stringify(n));
      return n;
    });
  };
  const [pay,setPay]         = useState("efectivo");
  const [montoRecibido, setMontoRecibido] = useState("");
  const [tel,setTel]         = useState("");
  const [cli,setCli]         = useState(null);
  const [ticket,setTicket]   = useState(null);
  const ticketRef = useRef(null);
  const [rxM,setRxM]         = useState(null);
  const [rx,setRx]           = useState({receta:"",medico:"",cedula:"",paciente:"",indicaciones:""});
  const [pedOnline,setPedOn] = useState([]);
  const [pedOnlineHist,setPedOnHist] = useState([]);
  /** Todas las citas en ventana (para resumen de estado de pago). */
  const [citasVentana, setCitasVentana] = useState([]);
  /** Citas con consulta o consumibles pendientes de cobro en caja (agendadas en línea o en Agenda de consultas). */
  const [consxCobrar,setConsCobrar] = useState([]);
  const [consultaTelById, setConsultaTelById] = useState({});
  const [consultaCliById, setConsultaCliById] = useState({});
  const [consultaPayById, setConsultaPayById] = useState({});
  const [consultaMontoById, setConsultaMontoById] = useState({});
  const [cliSearchItems, setCliSearchItems] = useState([]);
  const [loading,setLoad]    = useState(false);
  const [guardando,setGuard] = useState(false);
  const [cartOpen, setCartOpen] = useState(() => {
    if (typeof window === "undefined") return true;
    return !window.matchMedia("(max-width: 768px)").matches;
  });
  useEffect(() => {
    if (!(isMobilePos && cartOpen)) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev || "auto";
    };
  }, [isMobilePos, cartOpen]);
  const [mpModal,setMpModal]     = useState(false);
  const [mpFolio,setMpFolio]     = useState("");
  const [bbvaModal,setBbvaModal] = useState(false);
  const [bbvaFolio,setBbvaFolio] = useState("");
  /** Tras elegir origen de receta, cobro con tarjeta (Point) usa este valor al confirmar el pago. */
  const recetaOrigenPendienteRef = useRef("no_aplica");
  const [modalRecetaVenta, setModalRecetaVenta] = useState(false);
  const [modalRecetaModo, setModalRecetaModo] = useState(null);
  const [recetaOrigenSel, setRecetaOrigenSel] = useState("no_aplica");
  /** Si no es null, el modal MP cobra esa cita (no venta de carrito). */
  const mpCitaRef = useRef(null);
  /** Pago de servicios pendiente de registrar tras cobro Point. */
  const mpServicioRef = useRef(null);
  const [serviciosRefresh, setServiciosRefresh] = useState(0);
  const bbvaCitaRef = useRef(null);
  const [ventasDia,setVentasDia] = useState({total:0,count:0});
  const [folioActual,setFolioActual] = useState("VTA-00000000");
  const [fichaProd, setFichaProd] = useState(null);
  const [usoByProdId, setUsoByProdId] = useState(() => readPosUsoCache());
  const [usoLoadingId, setUsoLoadingId] = useState(null);
  const usoFetchRef = useRef(0);
  const scanAddTimerRef = useRef(null);
  const lastScanBurstRef = useRef({ raw: "", ts: 0 });
  const scanLastKeyTsRef = useRef(0);
  const addRef = useRef(null);
  const [promoTicket,setPromoTicket] = useState(null);
  const [loadErr,setLoadErr] = useState("");
  const [config,setConfig]   = useState(mergeFarmaciaConfig({}, {
    precio_consulta: CONSULTA_PRECIO_DEFAULT,
    nombre_doctor: "Dra. Lourdes Lucio Falcón",
  }));

  useEffect(() => {
    try {
      const t = sessionStorage.getItem("farmacapital_pos_initial_tab");
      if (t === "consultas" || t === "online" || t === "venta") {
        setTab(t);
        sessionStorage.removeItem("farmacapital_pos_initial_tab");
        return;
      }
    } catch (_) { /* noop */ }
    setTab(initialTab);
  }, [initialTab]);

  useEffect(()=>{
    supabase.from("configuracion").select("*").then(({ data: cfg }) => {
      if (cfg && cfg.length) {
        const map = configRowsToMap(cfg);
        setConfig((p) => mergeFarmaciaConfig(map, {
          ...p,
          precio_consulta: parseFloat(map.precio_consulta) || CONSULTA_PRECIO_DEFAULT,
          nombre_doctor: map.nombre_doctor || p.nombre_doctor,
        }));
      }
    });
  }, []);

  const refrescarCitasPOS = useCallback(async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      setCitasVentana([]);
      setConsCobrar([]);
      return;
    }
    const hoy = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    const toSv = (dt) => `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())}`;
    const desdeDt = new Date(hoy);
    desdeDt.setDate(desdeDt.getDate() - 21);
    const hastaDt = new Date(hoy);
    hastaDt.setDate(hastaDt.getDate() + 45);
    const desde = toSv(desdeDt);
    const hasta = toSv(hastaDt);
    const { data, error } = await supabase.rpc("empleado_listar_citas_ventana_pos", {
      p_session_token: tok,
      p_desde: desde,
      p_hasta: hasta,
    });
    if (error) {
      console.error("[POS] Citas:", error);
      setCitasVentana([]);
      setConsCobrar([]);
      return;
    }
    const citas = Array.isArray(data) ? data : [];
    setCitasVentana(citas);
    setConsCobrar(
      citas.filter((c) => {
        const pendientePago = citaPagoPendiente(c);
        const consumiblesPend = (c.consumibles_consulta || []).some((x) => !x.cobrado);
        return pendientePago || consumiblesPend;
      })
    );
  }, []);

  const hoySvPos = useMemo(
    () => new Date().toLocaleDateString("sv-SE"),
    []
  );

  const citasResumenPos = useMemo(
    () =>
      (citasVentana || [])
        .filter((c) => citaRelevanteParaResumenPOS(c, { hoySv: hoySvPos }))
        .sort((a, b) => {
          const fa = `${a.fecha || ""} ${a.hora || ""}`;
          const fb = `${b.fecha || ""} ${b.hora || ""}`;
          return fa.localeCompare(fb);
        }),
    [citasVentana, hoySvPos]
  );

  const consPendientesCount = consxCobrar.length;
  const consPagadasCount = citasResumenPos.filter((c) => citaEstaPagada(c)).length;

  const recargarPedidosOnline = useCallback(async () => {
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const [pedsRes, histRes] = await Promise.all([
        fetchPedidosTiendaPendientesMerged(supabase, PEDIDOS_TIENDA_SELECT_POS, {
          perBranchLimit: 100,
          maxRows: 300,
          sessionToken: tok,
        }),
        tok
          ? supabase.rpc("empleado_listar_pedidos_online_historial", {
              p_session_token: tok,
              p_limite: 20,
            })
          : Promise.resolve({ data: [], error: null }),
      ]);
      if (pedsRes?.error) {
        console.warn("[POS] Pedidos online:", pedsRes.error.message);
      } else {
        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));
      }
      if (histRes?.error) {
        console.warn("[POS] Historial online:", histRes.error.message);
      } else {
        setPedOnHist(Array.isArray(histRes?.data) ? histRes.data : []);
      }
    } catch (e) {
      console.warn("[POS] recargarPedidosOnline:", e);
    }
  }, []);

  useEffect(() => {
    if (tab !== "online") return;
    recargarPedidosOnline();
  }, [tab, recargarPedidosOnline]);

  /** Actualización automática: citas siempre; pedidos online en su pestaña (cada 30 s). */
  useEffect(() => {
    const tick = () => {
      refrescarCitasPOS();
      if (tab === "online") recargarPedidosOnline();
    };
    tick();
    const iv = setInterval(tick, 30000);
    const onVis = () => {
      if (document.visibilityState === "visible") tick();
    };
    document.addEventListener("visibilitychange", onVis);
    return () => {
      clearInterval(iv);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, [tab, refrescarCitasPOS, recargarPedidosOnline]);

  /** Citas en línea ya traen teléfono: vincular cliente automáticamente para puntos/ticket. */
  useEffect(() => {
    const pendientes = (consxCobrar || []).filter((c) => String(c.telefono || "").trim());
    if (!pendientes.length) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) return;
    let cancelled = false;
    pendientes.forEach((cita) => {
      const key = String(cita.id);
      if (consultaCliById[key]) return;
      void (async () => {
        try {
          const { data, error } = await supabase.rpc("empleado_buscar_clientes_pos", {
            p_session_token: tok,
            p_busqueda: cita.telefono,
            p_limit: 5,
          });
          if (cancelled || error) return;
          const rows = Array.isArray(data) ? data : [];
          const match =
            rows.find((r) => soloDigitosTel(r.telefono) === soloDigitosTel(cita.telefono)) ||
            rows[0] ||
            null;
          if (match) {
            setConsultaCliById((prev) => ({ ...prev, [key]: match }));
            setConsultaTelById((prev) => ({ ...prev, [key]: match.telefono || cita.telefono }));
          } else {
            setConsultaTelById((prev) => ({ ...prev, [key]: cita.telefono }));
          }
        } catch (e) {
          console.warn("[POS] cliente cita:", e);
        }
      })();
    });
    return () => {
      cancelled = true;
    };
  }, [consxCobrar, consultaCliById]);

  useEffect(() => {
    const raw = (tel || "").trim();
    if (!raw) {
      setCliSearchItems([]);
      setCli(null);
      return;
    }
    const tmr = setTimeout(async () => {
      try {
        const tok = sessionStorage.getItem("farmacapital_session_token");
        if (!tok) {
          setCliSearchItems([]);
          return;
        }
        const digits = soloDigitosTel(tel);
        if (!(digits.length >= 4 || raw.length >= 2)) {
          setCliSearchItems([]);
          return;
        }
        const { data, error } = await supabase.rpc("empleado_buscar_clientes_pos", {
          p_session_token: tok,
          p_busqueda: raw,
          p_limit: 12,
        });
        if (error) throw error;
        const rows = Array.isArray(data) ? data : [];
        setCliSearchItems(rows);
        if (digits.length >= 10) {
          const exact = rows.find((r) => soloDigitosTel(r.telefono) === digits);
          setCli(exact || null);
        } else {
          setCli(null);
        }
      } catch (e) {
        console.error("[POS] Buscar clientes:", e);
        setCliSearchItems([]);
      }
    }, 320);
    return () => clearTimeout(tmr);
  }, [tel]);

  useEffect(()=>{
    const cargar = async () => {
      setLoad(true);
      if (typeof setLoadErr === "function") setLoadErr("");
      try {
        const tok = sessionStorage.getItem("farmacapital_session_token");
        const [prodsRes, pedsRes, histRes] = await Promise.all([
          tok
            ? supabase.rpc("empleado_listar_productos_con_lotes_pos", { p_session_token: tok })
            : Promise.resolve({ data: [], error: { message: "Sin sesión" } }),
          fetchPedidosTiendaPendientesMerged(supabase, PEDIDOS_TIENDA_SELECT_POS, {
            perBranchLimit: 100,
            maxRows: 300,
            sessionToken: tok,
          }),
          tok
            ? supabase.rpc("empleado_listar_pedidos_online_historial", {
                p_session_token: tok,
                p_limite: 20,
              })
            : Promise.resolve({ data: [], error: null }),
        ]);

        const errs = [];
        if (prodsRes?.error) errs.push(`Productos (${prodsRes.status||"?"}): ${prodsRes.error.message}`);
        if (pedsRes?.error)  errs.push(`Pedidos online (${pedsRes.status||"?"}): ${pedsRes.error.message}`);
        if (histRes?.error)  errs.push(`Historial online (${histRes.status||"?"}): ${histRes.error.message}`);

        if (errs.length) {
          console.error("[POS] Errores de carga:", { prodsRes, pedsRes });
          if (typeof setLoadErr === "function") setLoadErr(errs.join(" | "));
        }

        const prodsRaw = Array.isArray(prodsRes?.data) ? prodsRes.data : [];
        const prodsConCad = prodsRaw.map(p => {
          const activos = (p.lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
          const minCad = activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
          return { ...p, min_caducidad_lotes: minCad };
        });
        setProds(prodsConCad);
        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));
        setPedOnHist(Array.isArray(histRes?.data) ? histRes.data : []);

      } catch (e) {
        console.error("[POS] Excepción cargando datos:", e);
        if (typeof setLoadErr === "function") setLoadErr("Error inesperado cargando datos. Revisa consola.");
        setProds([]); setPedOn([]); setPedOnHist([]); setCitasVentana([]); setConsCobrar([]);
      } finally {
        setLoad(false);
      }
    };
    cargar();
  },[refrescarCitasPOS]);

  useEffect(() => {
    refrescarCitasPOS();
  }, [refrescarCitasPOS]);

  useEffect(() => {
    const ids = new Set((consxCobrar || []).map((c) => String(c.id)));
    setConsultaTelById((prev) => {
      const next = {};
      let changed = false;
      for (const [k, v] of Object.entries(prev || {})) {
        if (ids.has(String(k))) next[k] = v;
        else changed = true;
      }
      return changed ? next : prev;
    });
    setConsultaCliById((prev) => {
      const next = {};
      let changed = false;
      for (const [k, v] of Object.entries(prev || {})) {
        if (ids.has(String(k))) next[k] = v;
        else changed = true;
      }
      return changed ? next : prev;
    });
    setConsultaPayById((prev) => {
      const next = {};
      let changed = false;
      for (const [k, v] of Object.entries(prev || {})) {
        if (ids.has(String(k))) next[k] = v;
        else changed = true;
      }
      return changed ? next : prev;
    });
    setConsultaMontoById((prev) => {
      const next = {};
      let changed = false;
      for (const [k, v] of Object.entries(prev || {})) {
        if (ids.has(String(k))) next[k] = v;
        else changed = true;
      }
      return changed ? next : prev;
    });
  }, [consxCobrar]);


  const fil = React.useMemo(() => {
    const s = normalizeBarcodeRaw(srch) || srch.trim();
    if (!s) return [];
    const exact = findProductExactScan(productos, s);
    if (exact) return [exact];
    if (isAllDigitsInput(srch)) return [];
    const matched = productos.filter(p => tiendaProductMatchesBusqueda(p, s));
    return matched.sort((a, b) => tiendaSearchRelevanceRank(a, s) - tiendaSearchRelevanceRank(b, s));
  }, [productos, srch]);

  const srchEsEscaneo = isAllDigitsInput(srch);

  const clearPosSearch = useCallback(() => {
    setSrch("");
    setSrchFocus(false);
    setFichaProd(null);
    srchRef.current?.focus();
  }, []);

  useEffect(() => {
    if (tab !== "venta") return;
    const s = normalizeBarcodeRaw(srch) || srch.trim();
    if (!s) return;
    const exact = findProductExactScan(productos, s);
    if (exact) {
      setFichaProd(exact);
      return;
    }
    if (srchEsEscaneo) return;
    if (fil.length === 0) return;
    setFichaProd((prev) => (prev && fil.some((p) => p.id === prev.id) ? prev : fil[0]));
  }, [srch, fil, tab, productos, srchEsEscaneo]);

  useEffect(() => {
    if (tab !== "venta" || !fichaProd?.id) return;
    const id = fichaProd.id;
    if (posDescripcionEsUsoValido(fichaProd)) {
      setUsoByProdId((prev) => (prev[id] === fichaProd.descripcion ? prev : { ...prev, [id]: fichaProd.descripcion }));
      return;
    }
    const cached = usoByProdId[id];
    if (cached && !posDescripcionPareceTicket(cached)) return;

    const tok = sessionStorage.getItem("farmacapital_session_token");
    const localPreview = describePosProductUseLocal(fichaProd) || posUsoFallback(fichaProd);
    setUsoByProdId((prev) => (prev[id] === localPreview ? prev : { ...prev, [id]: localPreview }));

    if (!tok) return;

    const reqId = ++usoFetchRef.current;
    setUsoLoadingId(id);
    (async () => {
      try {
        const resp = await fetch("/api/ai/chat", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            session_token: tok,
            mode: "pos_uso",
            product: {
              nombre: fichaProd.nombre,
              marca: fichaProd.marca,
              principio_activo: fichaProd.principio_activo,
              concentracion: fichaProd.concentracion,
              presentacion: fichaProd.presentacion,
              forma_farmaceutica: fichaProd.forma_farmaceutica,
              categoria: fichaProd.categoria,
              tipo: fichaProd.tipo,
              requiere_receta: fichaProd.requiere_receta,
              controlado: fichaProd.controlado,
            },
          }),
        });
        const data = await resp.json().catch(() => ({}));
        if (reqId !== usoFetchRef.current) return;
        if (resp.ok && data?.uso) {
          const texto = String(data.uso).trim();
          writePosUsoCacheEntry(id, texto);
          setUsoByProdId((prev) => ({ ...prev, [id]: texto }));
        }
      } catch {
        /* mantiene respaldo local */
      } finally {
        if (reqId === usoFetchRef.current) setUsoLoadingId(null);
      }
    })();
  }, [fichaProd, tab, usoByProdId]);

  const srchSuggestions = React.useMemo(() => {
    const s = srch.trim();
    if (!srchFocus || s.length < 2) return [];
    if (srchEsEscaneo) return [];
    if (findProductExactScan(productos, normalizeBarcodeRaw(s) || s)) return [];
    return tiendaCatalogSearchSuggestions(productos.filter(p => p.activo !== false), s, { limit: 7 });
  }, [productos, srch, srchFocus, srchEsEscaneo]);

  const paymentLabel = (method) => ({
    efectivo:       "Efectivo",
    tarjeta:        "Tarjeta",
    spei:           "SPEI",
    mercadopago:    "Tarjeta MP",
    bbva_terminal:  "Tarjeta BBVA",
  }[method] || "Otro");

  const totalCobroConsulta = (cita) => {
    const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
    const yaPagoConsulta =
      cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
    const consumibles = (cita.consumibles_consulta || []).filter((c) => !c.cobrado);
    const totalCons = consumibles.reduce((a, c) => a + c.precio * c.cantidad, 0);
    return (yaPagoConsulta ? 0 : precioBase) + totalCons;
  };

  const add = (item, esUnidad=false) => {
    // Validar que el lote FEFO activo más próximo no esté vencido
    if(item.min_caducidad_lotes) {
      const hoy = new Date().toLocaleDateString("sv-SE");
      if(item.min_caducidad_lotes < hoy) {
        showToast(`⚠️ ${item.nombre} tiene lote VENCIDO (${item.min_caducidad_lotes}). No se puede vender.`, "error");
        return;
      }
    }
    if((item.requiere_receta || item.categoria==="Antibiótico") && !esUnidad) { setRxM(item); return; }
    if (esUnidad) {
      if ((item.stock_unidades || 0) <= 0) {
        showToast("Sin unidades disponibles para venta suelta.", "warning");
        return;
      }
      const keyU = item.id+"_unit";
      setCart(p=>{
        const ex = p.find(c=>c.id===keyU);
        if (ex && ex.qty >= (item.stock_unidades || 0)) {
          showToast(`Máx unidades sueltas: ${item.stock_unidades || 0}`, "warning");
          return p;
        }
        return ex
          ? p.map(c=>c.id===keyU?{...c,qty:c.qty+1}:c)
          : [...p,{...item,id:keyU,producto_id:item.id,qty:1,rxI:null,esUnidad:true,precio:precioUnidadParaVenta(item),nombre:`${posTituloProducto(item)} (unidad)`}];
      });
    } else {
      if (!validarProductoParaCarrito(item, 1, false)) {
        return;
      }

      setCart(p=>{
        const disponibleFifo = getStockFifoDisponible(item);
        const ex=p.find(c=>c.id===item.id);
        const qtyActual = Number(ex?.qty || 0);

        if(qtyActual + 1 > disponibleFifo){
          showToast(`Stock FIFO insuficiente. Disponible por lotes: ${disponibleFifo}, en carrito: ${qtyActual}.`, "warning");
          return p;
        }

        if(ex){
          return p.map(c=>c.id===item.id?{...c,qty:c.qty+1}:c);
        }

        return [...p,{...item,producto_id:item.id,qty:1,rxI:null,esUnidad:false,nombre:posTituloProducto(item)}];
      });
    }
  };
  addRef.current = add;

  const finalizarEscaneoExitoso = useCallback((exact, raw) => {
    const now = Date.now();
    const prev = lastScanBurstRef.current;
    // Evitar doble add solo cuando timer + Enter disparan el mismo escaneo
    const mismoEscaneo = prev.raw === raw && now - prev.ts < 400;
    setFichaProd(exact);
    setSrch("");
    setSrchFocus(false);
    srchRef.current?.focus();
    if (mismoEscaneo) return;
    lastScanBurstRef.current = { raw, ts: now };
    add(exact, false);
  }, [add]);

  useEffect(() => {
    if (tab !== "venta") return;
    clearTimeout(scanAddTimerRef.current);
    const raw = normalizeBarcodeRaw(srch);
    if (!raw || !looksLikeBarcodeInput(raw)) return;

    scanAddTimerRef.current = setTimeout(() => {
      const exact = findProductExactScan(productos, raw);
      if (!exact) {
        if (raw.length >= 12) {
          showToast("Código de barras no encontrado en inventario.", "warning");
          setSrch("");
        }
        return;
      }
      finalizarEscaneoExitoso(exact, raw);
    }, 180);

    return () => clearTimeout(scanAddTimerRef.current);
  }, [srch, productos, tab, finalizarEscaneoExitoso]);


  const getLoteCantidadDisponible = (lote) => {
    return Number(
      lote?.cantidad_disponible ??
      lote?.stock_disponible ??
      lote?.cantidad_actual ??
      lote?.existencia ??
      lote?.stock ??
      lote?.cantidad ??
      0
    ) || 0;
  };

  const getStockFifoDisponible = (producto) => {
    if (!producto) return 0;

    const directo = Number(
      producto.stock_lotes_disponible ??
      producto.stock_fifo_disponible ??
      producto.stock_disponible_lotes ??
      producto.stock_disponible ??
      producto.disponible_fifo
    );

    if (Number.isFinite(directo)) {
      return Math.max(0, directo);
    }

    const lotes = Array.isArray(producto.lotes) ? producto.lotes : [];

    if (lotes.length > 0) {
      return Math.max(
        0,
        lotes.reduce((sum, lote) => {
          if (lote?.activo === false) return sum;
          return sum + getLoteCantidadDisponible(lote);
        }, 0)
      );
    }

    // Importante:
    // Si no hay lotes, no vender por POS FIFO aunque productos.stock diga otra cosa.
    return 0;
  };

  /** ¿Hay filas de lote activas con existencia? (PEPS — fuente de verdad en POS) */
  const productoTieneLotesActivos = (producto) => {
    const lotes = Array.isArray(producto?.lotes) ? producto.lotes : [];
    return lotes.some(
      (l) => l?.activo !== false && getLoteCantidadDisponible(l) > 0
    );
  };

  /**
   * Stock vendible en caja alineado con Inventario → Lotes:
   * - Con lotes: suma cantidad_actual de lotes activos
   * - Sin lotes (legacy): productos.stock
   */
  const getStockCajasPOS = (producto) => {
    const lotes = Array.isArray(producto?.lotes) ? producto.lotes : [];
    if (lotes.length > 0) return getStockFifoDisponible(producto);
    return Math.max(0, Number(producto?.stock || 0));
  };

  const productoSinLotesPEPS = (producto) => {
    if (producto?.venta_unidad) return false;
    const lotes = Array.isArray(producto?.lotes) ? producto.lotes : [];
    return lotes.length === 0;
  };

  const getCantidadEnCarrito = (cartActual, productoId, esUnidad = false) => {
    return (cartActual || []).reduce((sum, item) => {
      const itemId = String(item.producto_id ?? item.id ?? "");
      const baseId = String(productoId ?? "");
      if (item.esUnidad !== esUnidad) return sum;
      return itemId === baseId ? sum + (Number(item.qty) || 0) : sum;
    }, 0);
  };

  const validarProductoParaCarrito = (item, cantidadNueva = 1, esUnidad = false, cartActual = cart) => {
    if (!item) {
      showToast("Producto inválido.", "warning");
      return false;
    }

    if (esUnidad) {
      const disponibleUnidades = Number(item.stock_unidades || 0);
      const enCarritoUnidades = getCantidadEnCarrito(cartActual, item.id, true);

      if (disponibleUnidades <= 0) {
        showToast("Sin unidades disponibles para venta suelta.", "warning");
        return false;
      }

      if (enCarritoUnidades + cantidadNueva > disponibleUnidades) {
        showToast(`Máx unidades sueltas: ${disponibleUnidades}`, "warning");
        return false;
      }

      return true;
    }

    const disponibleFifo = getStockFifoDisponible(item);
    const enCarrito = getCantidadEnCarrito(cartActual, item.id, false);

    if (disponibleFifo <= 0) {
      showToast("Este producto no tiene lotes disponibles para venta. Revisa inventario/lotes antes de venderlo.", "warning");
      return false;
    }

    if (enCarrito + cantidadNueva > disponibleFifo) {
      showToast(`Stock FIFO insuficiente. Disponible por lotes: ${disponibleFifo}, en carrito: ${enCarrito}.`, "warning");
      return false;
    }

    return true;
  };

  const abrirCaja = async (item) => {
    if (item.stock <= 0) { showToast("Sin stock de cajas disponibles.", "warning"); return; }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada.", "error"); return; }
    const { data, error } = await supabase.rpc("abrir_caja_secure", {
      p_session_token: tok,
      p_producto_id: item.id,
    });
    if (error) {
      showToast(`Error al abrir caja: ${error.message}`, "error");
      return;
    }
    const nuevasUnidades =
      data?.[0]?.stock_unidades_nuevo ??
      ((item.stock_unidades || 0) + (item.unidades_por_caja || 0));
    showToast(`Caja abierta. Unidades disponibles: ${nuevasUnidades}`, "success");
  };

  const RX_IND_PRESETS = ["Cada 8 hrs con alimentos","Cada 12 hrs, completar tratamiento","En ayunas, 30 min antes de desayuno","Solo por la noche antes de dormir","No exceder dosis indicada por médico"];

  const toggleRxIndicacion = (t) => {
    setRx((p) => {
      const parts = (p.indicaciones || "").split(/\s*;\s*/).map((s) => s.trim()).filter(Boolean);
      const i = parts.indexOf(t);
      if (i >= 0) parts.splice(i, 1);
      else parts.push(t);
      return { ...p, indicaciones: parts.join("; ") };
    });
  };

  const rxPresetActiva = (t) =>
    (rx.indicaciones || "")
      .split(/\s*;\s*/)
      .map((s) => s.trim())
      .filter(Boolean)
      .includes(t);

  const confRx = () => {
    if(!rx.receta||!rx.medico||!rx.cedula||!rx.paciente) return;
    if (!validarProductoParaCarrito(rxM, 1, false)) return;

    setCart(p=>{
      const disponibleFifo = getStockFifoDisponible(rxM);
      const ex = p.find(c=>c.id===rxM.id);
      const qtyActual = Number(ex?.qty || 0);

      if (qtyActual + 1 > disponibleFifo) {
        showToast(`Stock FIFO insuficiente. Disponible por lotes: ${disponibleFifo}, en carrito: ${qtyActual}.`, "warning");
        return p;
      }

      return ex
        ? p.map(c=>c.id===rxM.id?{...c,qty:c.qty+1,rxI:{...rx}}:c)
        : [...p,{...rxM,producto_id:rxM.id,qty:1,rxI:{...rx},esUnidad:false}];
    });

    setRxM(null); setRx({receta:"",medico:"",cedula:"",paciente:"",indicaciones:""});
  };

  // P2.2: Calcular total con promociones activas aplicadas
  const calcularTotalConPromos = () => {
    return cart.reduce((a,c) => {
      let precio = c.precio;
      // Si el producto tiene descuento_pct, aplicarlo
      if(c.descuento_pct>0) {
        precio = precio * (1 - c.descuento_pct/100);
      }
      return a + precio * c.qty;
    }, 0);
  };
  const sub   = calcularTotalConPromos();
  const ptsG  = Math.floor(sub/10);
  const total = sub;

  const parseMontoEfectivo = (s) => {
    const x = String(s ?? "").replace(/,/g, "").trim().replace(/^\$/, "");
    const n = parseFloat(x);
    return Number.isFinite(n) ? Math.round(n * 100) / 100 : NaN;
  };
  const recibidoNum = parseMontoEfectivo(montoRecibido);
  const cambioNum = pay === "efectivo" && Number.isFinite(recibidoNum) ? Math.round(Math.max(0, recibidoNum - total) * 100) / 100 : null;

  const abrirModalRecetaVenta = (modo) => {
    if (!cart.length) return;
    if (modo === "efectivo") {
      const rec = parseMontoEfectivo(montoRecibido);
      if (!Number.isFinite(rec) || rec < total) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(total)}).`, "warning");
        return;
      }
    }
    setRecetaOrigenSel("no_aplica");
    setModalRecetaModo(modo);
    setModalRecetaVenta(true);
  };

  const ejecutarCobrar = async (recetaOrigen = "no_aplica", metodoPagoOverride = null) => {
    if(!cart.length) return;
    // Prevalidación rápida para evitar mandar una venta imposible al RPC.
    const faltantes = cart
      .map((c) => {
        const pid = c.producto_id ?? c.id;
        const p = productos.find((x) => String(x.id) === String(pid));
        const requested = Number(c.qty) || 0;
        const available = c.esUnidad ? (Number(p?.stock_unidades) || 0) : getStockFifoDisponible(p);
        if (!p || requested <= available) return null;
        return {
          nombre: p.nombre || c.nombre || `Producto ${pid}`,
          requested,
          available,
          unidad: c.esUnidad ? "unidad(es)" : "caja(s)",
        };
      })
      .filter(Boolean);
    if (faltantes.length) {
      const top = faltantes
        .slice(0, 3)
        .map((f) => `• ${f.nombre}: solicitadas ${f.requested} ${f.unidad}, disponibles ${f.available}`)
        .join("\n");
      showToast(`Stock insuficiente para completar la venta:\n${top}`, "warning");
      return;
    }
    const metodoPagoInterno = metodoPagoOverride || pay;
    // El DB solo acepta los valores clásicos del constraint chk_metodo_pago.
    // bbva_terminal y mercadopago (Point MP) se registran como "tarjeta".
    const DB_METODO_MAP = { bbva_terminal: "tarjeta", mercadopago_point: "tarjeta" };
    const metodoPagoFinal = DB_METODO_MAP[metodoPagoInterno] ?? metodoPagoInterno;
    if (metodoPagoFinal === "efectivo") {
      const rec = parseMontoEfectivo(montoRecibido);
      if (!Number.isFinite(rec) || rec < total) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(total)}).`, "warning");
        return;
      }
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) {
        showToast("Sesión expirada. Inicia sesión de nuevo.", "error");
        setGuard(false);
        return;
      }

      const cartItemsMapped = cart.map(c=>({
        producto_id: c.producto_id ?? c.id,
        cantidad: c.qty,
        precio_unitario: c.precio,
        modo_venta: c.esUnidad ? "unidad" : "caja",
      }));

      const { data: rpcData, error: rpcError } = await supabase.rpc("create_sale_transaction_secure", {
        p_session_token: tok,
        p_metodo_pago: metodoPagoFinal,
        p_total: total,
        p_cart_items: cartItemsMapped,
        p_cliente_id: cli?.id ?? null,
        p_tipo: "pos",
        p_tipo_entrega: null,
        p_direccion: null,
      });

      if (rpcError) throw rpcError;

      const rpcRow = Array.isArray(rpcData) ? rpcData[0] : rpcData;
      const pedidoId = rpcRow?.pedido_id;
      const ok = rpcRow?.success === true;
      if (!pedidoId || !ok) {
        throw new Error("RPC create_sale_transaction_secure devolvió una respuesta inválida");
      }

      const ro = recetaOrigen === "medico_farmacapital" || recetaOrigen === "medico_externo" ? recetaOrigen : "no_aplica";
      const tokRo = sessionStorage.getItem("farmacapital_session_token");
      if (tokRo) {
        const { error: uErr } = await supabase.rpc("admin_set_receta_origen_pedido", {
          p_session_token: tokRo, p_pedido_id: pedidoId, p_receta_origen: ro,
        });
        if (uErr) console.warn("[POS] receta_origen:", uErr);
      }

      if (ro === "medico_farmacapital") {
        const fechaSv = new Date().toLocaleDateString("sv-SE");
        try {
          await marcarMedicamentosRecetaFarmaCapitalSurtidos(supabase, {
            p_session_token: tokRo,
            fechaCitaLocal: fechaSv,
            telefonoCliente: cli?.telefono,
            clienteId: cli?.id ?? null,
            pedidoId,
            items: cart.map((c) => ({ producto_id: c.producto_id ?? c.id, qty: c.qty })),
          });
        } catch (e) {
          console.warn("[POS] sync receta-cita:", e);
        }
      }

      setFolioActual(`VTA-${String(pedidoId).padStart(8,"0")}`);

      const { data: pedidoItemsRaw, error: pedidoItemsError } = await supabase.rpc(
        "empleado_obtener_pedido_items_ticket",
        { p_session_token: tokRo, p_pedido_id: pedidoId }
      );
      if (pedidoItemsError) throw pedidoItemsError;
      const pedidoItems = Array.isArray(pedidoItemsRaw) ? pedidoItemsRaw : [];

      const rxItems = cart.filter(c=>c.rxI);
      if(rxItems.length) {
        const loteByProd = new Map();
        (pedidoItems || []).forEach((it) => {
          if (it.producto_id && it.lotes?.numero_lote && !loteByProd.has(it.producto_id)) {
            loteByProd.set(it.producto_id, {
              numero: it.lotes.numero_lote,
              caducidad: it.lotes.fecha_caducidad || null,
            });
          }
        });
        const tokCof = sessionStorage.getItem("farmacapital_session_token");
        if (tokCof) {
          await supabase.rpc("admin_registrar_bitacora_cofepris", {
            p_session_token: tokCof,
            p_items: rxItems.map(c => {
              const loteInfo = loteByProd.get(c.producto_id ?? c.id) || {};
              return {
                medicamento: c.nombre,
                lote:        loteInfo.numero || "",
                caducidad:   loteInfo.caducidad || null,
                cantidad:    c.qty,
                receta:      c.rxI.receta,
                medico:      c.rxI.medico,
                cedula_medico: c.rxI.cedula,
                paciente:    c.rxI.paciente,
              };
            }),
          });
        }
      }

      const ticketItems = (pedidoItems || []).map((it) => ({
        nombre: it.productos?.nombre || "Producto",
        sku: it.productos?.sku || "",
        qty: it.cantidad || 1,
        precio: it.precio_unitario || 0,
        lote: it.lotes?.numero_lote || null,
        caducidad: it.lotes?.fecha_caducidad || null,
      }));

      const ivaAmt = parseFloat((total * 0.16 / 1.16).toFixed(2));
      const netoAmt = parseFloat((total - ivaAmt).toFixed(2));
      const folioVenta = `VTA-${String(pedidoId).padStart(8,"0")}`;
      const recEf = metodoPagoFinal === "efectivo" ? parseMontoEfectivo(montoRecibido) : null;
      const cambioEf = metodoPagoFinal === "efectivo" && Number.isFinite(recEf) ? Math.round(Math.max(0, recEf - total) * 100) / 100 : null;
      const desgloseEf = metodoPagoFinal === "efectivo" && cambioEf != null && cambioEf > 0 ? desgloseCambioMN(cambioEf) : "";
      setTicket({
        id:pedidoId,
        folio:folioVenta,
        items:ticketItems.length ? ticketItems : [...cart],
        sub,
        total,
        neto:netoAmt,
        iva:ivaAmt,
        pay:paymentLabel(metodoPagoFinal),
        cli,
        ptsG,
        origen: "tienda",
        ...(pay === "efectivo" && Number.isFinite(recEf)
          ? { recibido: recEf, cambio: cambioEf, cambioDesglose: desgloseEf }
          : {}),
      });
      setVentasDia(p=>({total:p.total+total, count:p.count+1}));
      logAudit(usuario, "VENTA", "pedidos", pedidoId, {
        total, metodo_pago: metodoPagoFinal, items: cart.length,
        ...(metodoPagoFinal === "efectivo" && Number.isFinite(recEf) ? { efectivo_recibido: recEf, cambio: cambioEf } : {}),
      });
      showToast("Venta registrada correctamente", "success");
      setCart([]); setTel(""); setCli(null);
      setMontoRecibido("");
    } catch(e) {
      console.error(e);
      const msg = e?.message || e?.details || String(e);
      const lower = msg.toLowerCase();
      if (lower.includes("stock") || lower.includes("insuficiente")) {
        showToast(`Stock insuficiente o no se pudo completar el descuento de inventario.\n${msg}`, "error");
        // Sincroniza existencias visibles con BD tras un rechazo por stock.
        try {
          const tokRf = sessionStorage.getItem("farmacapital_session_token");
          const { data } = tokRf
            ? await supabase.rpc("empleado_listar_productos_con_lotes_pos", { p_session_token: tokRf })
            : { data: [] };
          const prodsArr = Array.isArray(data) ? data : [];
          const prodsConCad = prodsArr.map((p) => {
            const activos = (p.lotes || []).filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
            const minCad = activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
            return { ...p, min_caducidad_lotes: minCad };
          });
          setProds(prodsConCad);
        } catch (_) {
          // noop: no bloquear el flujo por un refresh fallido
        }
      } else {
        showToast(`No se pudo completar la venta.\n${msg}`, "error");
      }
    }
    setGuard(false);
  };

  const cobrar = () => abrirModalRecetaVenta("efectivo");

  const confirmarRecetaVentaYContinuar = () => {
    const ro = recetaOrigenSel === "medico_farmacapital" || recetaOrigenSel === "medico_externo" ? recetaOrigenSel : "no_aplica";
    setModalRecetaVenta(false);
    const modo = modalRecetaModo;
    setModalRecetaModo(null);
    if (modo === "tarjeta") {
      mpCitaRef.current = null;
      recetaOrigenPendienteRef.current = ro;
      setMpFolio(folioActual || "VTA-PENDIENTE");
      setMpModal(true);
    } else if (modo === "bbva_terminal") {
      recetaOrigenPendienteRef.current = ro;
      setBbvaFolio(folioActual || "VTA-PENDIENTE");
      setBbvaModal(true);
    } else if (modo === "efectivo") {
      ejecutarCobrar(ro);
    }
  };

  const surtirOnline = async (pedido) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) { showToast("Sesión expirada.", "error"); setGuard(false); return; }
      // F6b: marcar_pedido_listo ya descuenta stock FEFO internamente
      const { data: resp, error: rpcErr } = await supabase.rpc("marcar_pedido_listo", {
        p_session_token: tok, p_pedido_id: pedido.id,
      });
      if (rpcErr) throw rpcErr;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo surtir");
      setPedOn(p=>p.filter(x=>x.id!==pedido.id));
      setPedOnHist((prev) => [{ ...pedido, estado: "listo" }, ...prev.filter((x) => x.id !== pedido.id)].slice(0, 20));
      // Notificar al cliente por WhatsApp al marcar listo (pagó en línea)
      const telCli = pedido.clientes?.telefono || pedido.guest_telefono;
      if (telCli) {
        const msg = buildOnlineOrderReadyMessage({
          pedidoId: pedido.id,
          items: (pedido.pedido_items || []).map((i) => ({
            nombre: i.productos?.nombre,
            qty: i.cantidad,
            precio: i.precio_unitario,
          })),
          total: pedido.total,
          tipoEntrega: pedido.tipo_entrega,
          metodoPago: pedido.metodo_pago,
        });
        if (openWhatsAppToCustomer(telCli, msg)) {
          showToast("Pedido listo · WhatsApp abierto para el cliente", "success");
        } else {
          showToast("Pedido listo (revisa el teléfono del cliente)", "success");
        }
      } else {
        showToast("Pedido marcado como listo", "success");
      }
    } catch(e) { console.error(e); }
    setGuard(false);
  };

  const cancelarCitaPorNoShow = async (cita) => {
    if (!puedeCancelarCitaNoShow(cita)) return;
    if (!window.confirm(`¿Cancelar la cita de ${cita.nombre} (${cita.hora}) y liberar el horario? Solo aplica si pasaron 10 min del inicio sin pago en caja.`)) return;
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data: resp, error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok, p_cita_id: cita.id, p_estado: "cancelada",
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cancelar");
      showToast("Cita cancelada. El horario queda libre.", "info");
      await refrescarCitasPOS();
    } catch (e) {
      console.error(e);
      showToast("No se pudo cancelar: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  const mapMetodoPagoConsulta = (raw) => {
    const DB_METODO_MAP = { bbva_terminal: "tarjeta", mercadopago_point: "tarjeta" };
    return DB_METODO_MAP[raw] ?? raw ?? "efectivo";
  };

  const cobrarConsulta = async (cita, opts = {}) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const metodoPagoRaw = opts.metodoPago || "efectivo";
      const metodoPago = mapMetodoPagoConsulta(metodoPagoRaw);
      const clienteSel = opts.clienteSel || null;
      const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
      const yaPagoConsulta =
        cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
      const parteDoctor = Number(((yaPagoConsulta ? 0 : precioBase) * CONSULTA_PARTE_DOCTOR).toFixed(2));
      const parteFarmacia = Number(((yaPagoConsulta ? 0 : precioBase) - parteDoctor).toFixed(2));
      const { data: resp, error } = await supabase.rpc("cobrar_consulta", {
        p_session_token: tok,
        p_cita_id:       cita.id,
        p_metodo_pago:   metodoPago,
        p_precio_consulta: precioBase,
        p_ya_pago_consulta: yaPagoConsulta,
        p_parte_doctor: parteDoctor,
        p_parte_farmacia: parteFarmacia,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cobrar");
      const consumibles = (cita.consumibles_consulta || []).filter((c) => !c.cobrado);
      const baseCobrar = yaPagoConsulta ? 0 : precioBase;
      const totalFinal = Number(resp.total_final ?? resp.total ?? 0);
      const recEf =
        metodoPago === "efectivo" && opts.montoRecibido != null
          ? parseFloat(opts.montoRecibido)
          : null;
      const cambioEf =
        metodoPago === "efectivo" && Number.isFinite(recEf)
          ? Math.round(Math.max(0, recEf - totalFinal) * 100) / 100
          : null;
      const desgloseEf =
        metodoPago === "efectivo" && cambioEf != null && cambioEf > 0
          ? desgloseCambioMN(cambioEf)
          : "";

      await refrescarCitasPOS();
      const itemsConsulta =
        baseCobrar > 0
          ? [{ nombre: "Consulta médica", qty: 1, precio: precioBase }]
          : [];
      const pedidoId = resp.pedido_id || Date.now();
      setTicket({
        id: pedidoId,
        folio: `VTA-${String(pedidoId).padStart(8, "0")}`,
        items: [
          ...itemsConsulta,
          ...consumibles.map((c) => ({
            nombre: c.productos?.nombre || c.nombre || "Consumible",
            qty: c.cantidad,
            precio: c.precio,
          })),
        ],
        sub: totalFinal,
        total: totalFinal,
        pay: paymentLabel(metodoPagoRaw),
        cli: clienteSel,
        ptsG: Math.floor(totalFinal / 10),
        origen: "consulta",
        ...(metodoPago === "efectivo" && Number.isFinite(recEf)
          ? { recibido: recEf, cambio: cambioEf, cambioDesglose: desgloseEf }
          : {}),
      });
      setConsultaMontoById((prev) => {
        const next = { ...prev };
        delete next[String(cita.id)];
        return next;
      });
      showToast("Consulta cobrada correctamente", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo cobrar la consulta: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  const iniciarCobroConsulta = (cita, payConsulta, cliConsulta, totalCobro) => {
    const citaKey = String(cita.id);
    if (payConsulta === "efectivo") {
      const rec = parseMontoEfectivo(consultaMontoById[citaKey] || "");
      if (!Number.isFinite(rec) || rec < totalCobro) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(totalCobro)}).`, "warning");
        return;
      }
      cobrarConsulta(cita, {
        metodoPago: payConsulta,
        clienteSel: cliConsulta,
        montoRecibido: rec,
      });
      return;
    }
    if (payConsulta === "tarjeta") {
      mpCitaRef.current = cita;
      setMpFolio(`CONS-${cita.id}`);
      setMpModal(true);
      return;
    }
    if (payConsulta === "bbva_terminal") {
      bbvaCitaRef.current = cita;
      setBbvaFolio(`CONS-${cita.id}`);
      setBbvaModal(true);
    }
  };

  const renderPosCarritoVentaInner = () => (
    <>
      <Box style={{padding:16,marginBottom:12}}>
        <div style={{color:C.text,fontWeight:800,fontSize:16,marginBottom:12}}>🛒 Carrito {cart.length>0&&<span style={{color:BRAND.primary,fontWeight:700,fontSize:13}}>({cart.length})</span>}</div>
        <div data-tour="pos-cliente">
        <SearchDropdown
          value={tel}
          onChange={setTel}
          onSelect={(c)=>{ setTel(c.telefono||""); setCli(c); }}
          placeholder="📱 Teléfono o nombre del cliente"
          items={cliSearchItems}
          labelKey="nombre"
          subKey="telefono"
          badgeKey="puntos"
          badgeCol="#7c3aed"
          style={{marginBottom:8}}
          emptyMsg="Sin coincidencias · prueba más dígitos del teléfono o el nombre"
        />
        </div>
        {cli&&<div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:8,padding:"8px 10px",marginBottom:10}}>
          <div style={{color:C.purple,fontWeight:700,fontSize:12}}>{cli.nombre}</div>
          <div style={{color:C.textMid,fontSize:10}}>⭐ {cli.puntos||0} puntos FarmaCapital</div>
        </div>}
        {!cart.length?<div style={{color:C.textMid,fontSize:13,textAlign:"center",padding:"24px 0"}}>Agrega productos</div>:
         cart.map(item=>(
          <div key={item.id} style={{marginBottom:12,paddingBottom:12,borderBottom:`1px solid ${C.border}`}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:6,marginBottom:8}}>
              <div style={{color:C.text,fontSize:14,fontWeight:700,flex:1,lineHeight:1.3}}>{item.nombre}</div>
              <button onClick={()=>setCart(p=>p.filter(c=>c.id!==item.id))} style={{background:"none",border:"none",color:C.red,cursor:"pointer",fontSize:18,lineHeight:1,padding:"0 2px",flexShrink:0}}>×</button>
            </div>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
              <div style={{display:"flex",alignItems:"center",gap:8}}>
                <button onClick={()=>setCart(p=>p.map(c=>c.id===item.id?{...c,qty:Math.max(1,c.qty-1)}:c))} style={{width:28,height:28,borderRadius:6,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:16,fontWeight:700}}>−</button>
                <span style={{color:C.text,fontSize:15,fontWeight:800,minWidth:20,textAlign:"center"}}>{item.qty}</span>
            <button onClick={()=>setCart(p=>p.map(c=>{
              if(c.id!==item.id) return c;
              if(c.esUnidad){
                const maxU = item.stock_unidades||0;
                if(c.qty>=maxU){ showToast(`Máx unidades: ${maxU}`,"warning"); return c; }
                return {...c,qty:c.qty+1};
              }
              const prod = productos.find(x=>String(x.id)===String(item.producto_id??item.id));
              const maxF = prod ? getStockFifoDisponible(prod) : 0;
              if(c.qty>=maxF){ showToast(`Stock FIFO insuficiente. Disponible: ${maxF}`,"warning"); return c; }
              return {...c,qty:c.qty+1};
            }))} style={{width:28,height:28,borderRadius:6,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:16,fontWeight:700}}>+</button>
              </div>
              <span style={{color:C.blue,fontWeight:800,fontSize:16}}>{$(item.precio*item.qty)}</span>
            </div>
          </div>
        ))}
      </Box>
      {/* Sugerencias */}
      {cart.length>0&&(()=>{
        const cats = [...new Set(cart.map(i=>i.categoria).filter(Boolean))];
        const idsEnCart = new Set(cart.map(i=>typeof i.id==="string"?i.id:String(i.id)));
        const sugs = productos.filter(p=>
          cats.includes(p.categoria) &&
          !idsEnCart.has(String(p.id)) &&
          p.activo && p.stock>0
        ).slice(0,4);
        if(!sugs.length) return null;
        return (
          <Box style={{padding:12,marginBottom:12}}>
            <div style={{color:C.textMid,fontSize:10,fontWeight:700,letterSpacing:1,textTransform:"uppercase",marginBottom:8}}>💡 Sugeridos</div>
            <div style={{display:"flex",flexDirection:"column",gap:6}}>
              {sugs.map(p=>(
                <div key={p.id} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"6px 8px",borderRadius:7,background:C.bg,cursor:"pointer"}}
                  onClick={()=>add(p,false)}
                  onMouseEnter={e=>e.currentTarget.style.background=C.blueDim}
                  onMouseLeave={e=>e.currentTarget.style.background=C.bg}>
                  <div style={{flex:1}}>
                    <div style={{color:C.text,fontSize:11,fontWeight:600,lineHeight:1.3}}>{p.nombre}</div>
                    <div style={{color:C.textDim,fontSize:9}}>{p.categoria}</div>
                  </div>
                  <div style={{display:"flex",alignItems:"center",gap:6,flexShrink:0}}>
                    <span style={{color:C.blue,fontWeight:700,fontSize:11}}>{$(p.precio||p.precio||0)}</span>
                    <span style={{color:C.green,fontSize:14,fontWeight:700}}>+</span>
                  </div>
                </div>
              ))}
            </div>
          </Box>
        );
      })()}

      {/* Método pago */}
      <Box style={{padding:14,marginBottom:12}}>
        <div style={{color:C.textDim,fontSize:10,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>Método de pago</div>
        <div style={{display:"flex",gap:5,flexWrap:"wrap"}}>
          {[
            ["efectivo","💵 Efectivo"],
            ["tarjeta","💳 Point MP"],
            ["bbva_terminal","🏦 Terminal BBVA"],
          ].map(([v,l])=>(
            <button key={v} type="button" onClick={()=>{ setPay(v); if(v!=="efectivo") setMontoRecibido(""); }} style={{padding:isMobilePos?"8px 14px":"4px 10px",borderRadius:20,border:`1px solid ${pay===v?C.blue:C.border}`,background:pay===v?C.blueDim:"transparent",color:pay===v?C.blue:C.textMid,fontSize:isMobilePos?13:10,fontWeight:700,cursor:"pointer",minHeight:isMobilePos?40:undefined}}>{l}</button>
          ))}
        </div>
      </Box>
      {pay==="efectivo"&&cart.length>0&&(
        <Box style={{padding:14,marginBottom:12,background:C.greenDim,border:`1px solid ${C.green}25`}}>
          <div style={{color:C.textDim,fontSize:10,letterSpacing:1.2,textTransform:"uppercase",marginBottom:8}}>Efectivo</div>
          <div style={{color:C.textMid,fontSize:11,marginBottom:8}}>¿Cuánto te entregó el cliente?</div>
          <Inp
            value={montoRecibido}
            onChange={(e)=>setMontoRecibido(e.target.value)}
            placeholder={`Mínimo ${$(total)}`}
            inputMode="decimal"
            style={{width:"100%",boxSizing:"border-box",marginBottom:8,fontSize:16,fontWeight:700}}
          />
          <div style={{display:"flex",gap:6,flexWrap:"wrap",marginBottom:10}}>
            <button type="button" onClick={()=>setMontoRecibido(String(total))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.green}`,background:"#fff",color:C.green,fontSize:10,fontWeight:700,cursor:"pointer"}}>Exacto {$(total)}</button>
            {sugerenciasPagoCliente(total).map(({billete,cambio})=>(
              <button key={billete} type="button" onClick={()=>setMontoRecibido(String(billete))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,fontSize:10,fontWeight:600,cursor:"pointer",color:C.text}}>
                ${billete} → cambio {$(cambio)}
              </button>
            ))}
          </div>
          {Number.isFinite(recibidoNum)&&recibidoNum>=total&&(
            <div style={{marginBottom:8}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline"}}>
                <span style={{color:C.textMid,fontSize:12}}>Cambio a entregar</span>
                <span style={{color:C.green,fontWeight:900,fontSize:22}}>{$(cambioNum)}</span>
              </div>
              {cambioNum>0&&desgloseCambioMN(cambioNum)&&(
                <div style={{color:C.textMid,fontSize:10,marginTop:4,lineHeight:1.4}}>
                  <strong style={{color:C.text}}>Sugerido:</strong> {desgloseCambioMN(cambioNum)}
                </div>
              )}
            </div>
          )}
          {Number.isFinite(recibidoNum)&&recibidoNum>0&&recibidoNum<total&&(
            <div style={{color:C.red,fontSize:11,fontWeight:700}}>Falta ${(total-recibidoNum).toFixed(2)}</div>
          )}
          <div style={{color:C.textDim,fontSize:9,marginTop:6,lineHeight:1.35}}>
            Consejo caja: si te quedas sin billetes chicos, pide al cliente pagar con el monto exacto o con billetes que dejen un cambio “redondo” (usa los botones de arriba). Para control fino por denominación usa el corte de caja al cerrar turno.
          </div>
        </Box>
      )}
      {/* Total */}
      <div data-tour="pos-cobrar">
      <Box style={{padding:16}}>
        <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
          <span style={{color:C.textMid,fontSize:13}}>Total</span>
          <span style={{color:C.blue,fontWeight:900,fontSize:20}}>{$(total)}</span>
        </div>
        {cli&&<div style={{color:C.purple,fontSize:11,fontWeight:700,marginBottom:10}}>+{ptsG} puntos → {cli.nombre}</div>}
        {pay==="efectivo" ? (
          <Btn onClick={cobrar} full col={C.green} dis={!cart.length||guardando||(!Number.isFinite(recibidoNum)||recibidoNum<total)}
            onKeyDown={e=>e.key==="Enter"&&!guardando&&cart.length&&Number.isFinite(recibidoNum)&&recibidoNum>=total&&cobrar()}
          >{guardando?"Procesando...":"✅ Cobrar "+$(total)}</Btn>
        ) : pay==="tarjeta" ? (
          <div>
            <Btn onClick={()=>abrirModalRecetaVenta("tarjeta")}
              full col="#009ee3" dis={!cart.length||guardando}
            >💳 Cobrar con Point MP</Btn>
            <div style={{color:C.textDim,fontSize:10,marginTop:10,lineHeight:1.45}}>
              La app <strong>espera</strong> a que el Point Smart 2 confirme el pago. Recién entonces se registra la venta y se imprime el ticket.
            </div>
          </div>
        ) : pay==="bbva_terminal" ? (
          <div>
            <Btn onClick={()=>abrirModalRecetaVenta("bbva_terminal")}
              full col="#1a237e" dis={!cart.length||guardando}
            >🏦 Cobrar con terminal BBVA</Btn>
            <div style={{color:C.textDim,fontSize:10,marginTop:10,lineHeight:1.45}}>
              Procesa el pago en la terminal física BBVA y confirma el resultado aquí. La venta se registra solo cuando indicas que fue <strong>aprobado</strong>.
            </div>
          </div>
        ) : null}
      </Box>
      </div>

    </>
  );

  return(
    <div className="farmacapital-pos-root" style={{
      width:"100%",
      maxWidth:"100%",
      minWidth:0,
      boxSizing:"border-box",
      overflowX:"hidden",
      paddingBottom:"max(8px, env(safe-area-inset-bottom, 0px))",
      touchAction:"pan-y",
    }}>
      <style>{`
        .farmacapital-pos-root input.farmacapital-pos-srch,
        .farmacapital-pos-root input.farmacapital-field-input {
          color-scheme: light;
          background: #ffffff !important;
          color: #0f172a;
          -webkit-text-fill-color: #0f172a;
          caret-color: #0f172a;
        }
        .farmacapital-pos-root input.farmacapital-pos-srch::placeholder,
        .farmacapital-pos-root input.farmacapital-field-input::placeholder {
          color: #94a3b8;
          opacity: 1;
        }
        .farmacapital-pos-root input.farmacapital-pos-srch:-webkit-autofill,
        .farmacapital-pos-root input.farmacapital-field-input:-webkit-autofill {
          -webkit-box-shadow: 0 0 0 1000px #ffffff inset !important;
          box-shadow: 0 0 0 1000px #ffffff inset !important;
          -webkit-text-fill-color: #0f172a !important;
        }
        @media (max-width: 1100px) {
          .farmacapital-pos-root { overflow-x: hidden; max-width: 100%; }
        }
        /* Solo ≤768px: marco alto fijo + scroll de productos (carrito en modal por JS). */
        @media (max-width: 768px) {
          input.farmacapital-pos-srch {
            font-size: 16px !important;
          }
          .farmacapital-pos-venta-grid.farmacapital-pos-venta-narrow {
            display: flex !important;
            flex-direction: column !important;
            align-items: stretch !important;
            gap: 0 !important;
            /* Evitar viewport fijo + scroll anidado en móvil. */
            height: auto !important;
            min-height: 280px !important;
            max-height: none !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
          }
          .farmacapital-pos-venta-grid.farmacapital-pos-venta-narrow .farmacapital-pos-products-col {
            flex: 1 1 auto !important;
            min-height: auto !important;
            overflow-x: hidden !important;
            overflow-y: visible !important;
            -webkit-overflow-scrolling: touch !important;
            padding-bottom: 4px !important;
          }
        }
      `}</style>
      <div style={{ marginBottom: isNarrow ? 12 : 20 }}>
        {loadErr && (
        <div style={{
          background:"#ff000022",
          border:"1px solid #ff4444",
          borderRadius:8,
          padding:"10px 16px",
          marginBottom:12,
          color:"#ff6666",
          fontSize:12,
          fontWeight:600,
          display:"flex",
          justifyContent:"space-between",
          alignItems:"center",
          gap:8,
        }}>
          <span style={{wordBreak:"break-word"}}>⚠️ {loadErr}</span>
          <button type="button" onClick={()=>setLoadErr("")} style={{background:"transparent",border:"none",color:"#ff6666",cursor:"pointer",fontSize:14,flexShrink:0}}>✕</button>
        </div>
      )}
      <div style={{
        display:"flex",
        flexDirection: isMobilePos ? "column" : isNarrow ? "column" : "row",
        alignItems: isNarrow ? "stretch" : "flex-start",
        justifyContent:"space-between",
        gap: isMobilePos ? 8 : 12,
        flexWrap:"wrap",
      }}>
        <div style={{ display: "flex", flexDirection: "column", gap: isMobilePos ? 6 : 10, minWidth: 0, flex: !isMobilePos && !isNarrow ? "1 1 280px" : "none" }}>
          <div style={{display:"flex",alignItems:"center",gap:10,flexWrap:"wrap"}}>
            <h1 style={{color:C.text,fontSize: isNarrow ? "clamp(16px, 4.5vw, 20px)" : 20,fontWeight:800,margin:0,lineHeight:1.2}}>
              ⊡ Punto de Venta
              {initialTab==="consultas"&&(
                <span style={{fontWeight:700,fontSize: isNarrow ? 12 : 14,color:C.purple}}> · Cobro de consultas</span>
              )}
            </h1>
            {folioActual!=="VTA-00000000"&&(
              <span style={{padding:"3px 10px",borderRadius:20,fontSize:10,fontWeight:700,background:C.blueDim,color:C.blue}}>
                Último folio: {folioActual}
              </span>
            )}
          </div>
          {ventasDia.count>0&&(
            <div style={{display:"flex",gap:12,alignItems:"center",background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:10,padding:"6px 14px",flexWrap:"wrap"}}>
              <div style={{textAlign:"center"}}>
                <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Mi día</div>
                <div style={{color:C.green,fontWeight:900,fontSize:16}}>{$(ventasDia.total)}</div>
              </div>
              <div style={{width:1,height:28,background:C.border}}/>
              <div style={{textAlign:"center"}}>
                <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Ventas</div>
                <div style={{color:C.green,fontWeight:900,fontSize:16}}>{ventasDia.count}</div>
              </div>
              <div style={{width:1,height:28,background:C.border}}/>
              <div style={{textAlign:"center"}}>
                <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Ticket prom.</div>
                <div style={{color:C.blue,fontWeight:900,fontSize:16}}>{$(ventasDia.count?ventasDia.total/ventasDia.count:0)}</div>
              </div>
              <div style={{width:1,height:28,background:C.border}}/>
              <div style={{textAlign:"center"}}>
                <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>En carrito</div>
                <div style={{color:C.amber,fontWeight:900,fontSize:16}}>{cart.length}</div>
              </div>
            </div>
          )}
        </div>
        <div style={{
          display:"flex",
          gap:6,
          alignItems:"center",
          flexWrap: isMobilePos ? "nowrap" : "wrap",
          flexShrink:0,
          overflowX: isMobilePos ? "auto" : "visible",
          WebkitOverflowScrolling: isMobilePos ? "touch" : undefined,
          paddingBottom: isMobilePos ? 2 : 0,
          marginRight: isMobilePos ? -4 : 0,
          width: isMobilePos ? "100%" : undefined,
        }}>
          {[["venta","Venta"],["online",`Online (${pedOnline.length})`],["consultas",`Consultas${consPendientesCount ? ` (${consPendientesCount})` : ""}`],["servicios","Servicios"]].map(([v,l])=>(
            <button key={v} type="button" onClick={()=>setTab(v)} style={{
              padding:isMobilePos ? "8px 12px" : "6px 12px",
              borderRadius:8,
              border:`1px solid ${tab===v?BRAND.primary:C.border}`,
              background:tab===v?BRAND.primary+"18":"transparent",
              color:tab===v?BRAND.secondary:C.textMid,
              fontSize: isMobilePos ? 12 : isNarrow ? 11 : 12,
              fontWeight:700,
              cursor:"pointer",
              whiteSpace:"nowrap",
              flexShrink:0,
            }}>
              {l}
            </button>
          ))}
          <button type="button" onClick={()=>onNavigate?.("caja")} style={{
            padding:isMobilePos ? "8px 12px" : "6px 12px",
            borderRadius:8,
            border:`1px solid ${C.amber}`,
            background:C.amberDim,color:C.amber,
            fontSize: isMobilePos ? 12 : isNarrow ? 11 : 12,
            fontWeight:700,
            cursor:"pointer",
            whiteSpace:"nowrap",
            flexShrink:0,
          }}>⊞ Cerrar turno</button>
        </div>
      </div>
      </div>

      {/* Modal RX */}
      <Modal open={!!rxM} onClose={()=>setRxM(null)} title="⚕ Medicamento con Receta — COFEPRIS" ac={C.amber}>
        <div style={{color:C.textMid,fontSize:13,marginBottom:14}}><strong style={{color:C.text}}>{rxM?.nombre}</strong> — se registrará en bitácora COFEPRIS/SICAD</div>
        {[["Número de receta","receta","RX-2024-XXX"],["Médico prescriptor","medico","Dr. Nombre Completo"],["Cédula profesional","cedula","Número cédula SEP"],["Nombre del paciente","paciente","Nombre completo"]].map(([l,k,ph])=>(
          <div key={k} style={{marginBottom:12}}>
            <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>{l} *</div>
            <Inp value={rx[k]} onChange={e=>setRx(p=>({...p,[k]:e.target.value}))} placeholder={ph} style={{width:"100%",boxSizing:"border-box"}}/>
          </div>
        ))}
        {/* Indicaciones */}
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:6}}>Indicaciones / Precauciones (opcional)</div>
          <div style={{color:C.textDim,fontSize:10,marginBottom:6}}>Toca varias opciones para combinarlas (se unen con «;»). Puedes editar el texto abajo.</div>
          <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:6}}>
            {RX_IND_PRESETS.map((t)=>(
              <button key={t} type="button" onClick={()=>toggleRxIndicacion(t)}
                style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:600,cursor:"pointer",
                  background:rxPresetActiva(t)?C.amberDim:"#f8fafc",
                  border:`1px solid ${rxPresetActiva(t)?C.amber:C.border}`,
                  color:rxPresetActiva(t)?C.amber:C.textMid}}>{t}</button>
            ))}
          </div>
          <textarea value={rx.indicaciones} onChange={e=>setRx(p=>({...p,indicaciones:e.target.value}))}
            rows={3} maxLength={500} placeholder="Texto final (editable): combina frases de arriba o escribe libremente..."
            style={{width:"100%",boxSizing:"border-box",padding:"8px 10px",borderRadius:8,
              border:`1px solid ${C.border}`,background:C.card,color:C.text,
              fontSize:12,outline:"none",resize:"vertical",fontFamily:"inherit"}}/>
        </div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={()=>setRxM(null)} ol col={C.textMid} sm>Cancelar</Btn>
          <Btn onClick={confRx} col={C.amber} dis={!rx.receta||!rx.medico||!rx.cedula||!rx.paciente}>✓ Registrar y agregar</Btn>
        </div>
      </Modal>

      {/* Origen de receta (POS) — antes de registrar la venta */}
      <Modal
        open={modalRecetaVenta}
        onClose={()=>{ setModalRecetaVenta(false); setModalRecetaModo(null); }}
        title="¿La receta es de un médico de FarmaCapital?"
        ac={C.blue}
      >
        <div style={{color:C.textMid,fontSize:13,marginBottom:14,lineHeight:1.45}}>
          Indica si el medicamento surtido corresponde a receta prescrita por algún médico o médica que atiende en el consultorio FarmaCapital. Así medimos ventas ligadas a consultas y estimamos oportunidad cuando el paciente surte fuera.
        </div>
        <div style={{display:"flex",flexDirection:"column",gap:8,marginBottom:16}}>
          {[
            ["no_aplica", "No aplica / venta sin receta de consultorio"],
            ["medico_farmacapital", "Sí — receta de doctor(a) de FarmaCapital"],
            ["medico_externo", "Receta de otro médico (externo)"],
          ].map(([val, lab])=>(
            <label key={val} style={{display:"flex",alignItems:"flex-start",gap:10,cursor:"pointer",padding:"8px 10px",borderRadius:8,border:`1px solid ${recetaOrigenSel===val?C.blue:C.border}`,background:recetaOrigenSel===val?C.blueDim:C.card}}>
              <input type="radio" name="recetaOrigenPos" checked={recetaOrigenSel===val} onChange={()=>setRecetaOrigenSel(val)} style={{marginTop:3}} />
              <span style={{color:C.text,fontSize:13,fontWeight:600}}>{lab}</span>
            </label>
          ))}
        </div>
        <div style={{display:"flex",gap:8,justifyContent:"flex-end"}}>
          <Btn ol col={C.textMid} sm onClick={()=>{ setModalRecetaVenta(false); setModalRecetaModo(null); }}>Cancelar</Btn>
          <Btn col={C.green} onClick={confirmarRecetaVentaYContinuar} dis={guardando}>Continuar</Btn>
        </div>
      </Modal>

      {/* Modal ticket — TicketPreviewModal (aparece automáticamente después de venta) */}
      {/* Mercado Pago Point Smart 2 Modal */}
      <MercadoPagoModal
        open={mpModal}
        total={
          mpCitaRef.current
            ? totalCobroConsulta(mpCitaRef.current)
            : mpServicioRef.current
              ? mpServicioRef.current.total
              : total
        }
        folio={
          mpCitaRef.current
            ? `CONS-${mpCitaRef.current.id}`
            : mpServicioRef.current?.folio || mpFolio
        }
        hint={
          mpServicioRef.current
            ? "Cobra al cliente servicio + comisión en la Point. Después liquida el recibo en Smart Launcher → Pago de servicios."
            : "El terminal recibe el monto; al aprobarse se registra la venta y podrás imprimir o enviar el ticket por WhatsApp."
        }
        onSuccess={async ()=>{
          setMpModal(false);
          const citaMp = mpCitaRef.current;
          const servMp = mpServicioRef.current;
          mpCitaRef.current = null;
          mpServicioRef.current = null;
          if (servMp) {
            try {
              const data = await rpcRegistrarPagoServicio(servMp);
              showToast(`Servicio registrado · ${data.folio} · ${$(data.total_cobrado)}`, "success");
              setServiciosRefresh((n) => n + 1);
            } catch (e) {
              showToast(e?.message || "Tarjeta cobrada pero no se registró el servicio. Regístralo manualmente.", "error");
            }
            return;
          }
          if (citaMp) {
            const citaKey = String(citaMp.id);
            await cobrarConsulta(citaMp, {
              metodoPago: "tarjeta",
              clienteSel: consultaCliById[citaKey] || null,
            });
          }
          else {
            const ro = recetaOrigenPendienteRef.current || "no_aplica";
            recetaOrigenPendienteRef.current = "no_aplica";
            await ejecutarCobrar(ro);
          }
        }}
        onCancel={()=>{ setMpModal(false); mpCitaRef.current = null; mpServicioRef.current = null; recetaOrigenPendienteRef.current = "no_aplica"; }}
      />

      {/* Terminal BBVA Modal */}
      <BBVATerminalModal
        open={bbvaModal}
        total={bbvaCitaRef.current ? totalCobroConsulta(bbvaCitaRef.current) : total}
        folio={bbvaCitaRef.current ? `CONS-${bbvaCitaRef.current.id}` : bbvaFolio}
        hint="Ingresa el monto en la terminal física BBVA, procesa la tarjeta del cliente y confirma aquí el resultado del voucher."
        onSuccess={async () => {
          setBbvaModal(false);
          const citaBbva = bbvaCitaRef.current;
          bbvaCitaRef.current = null;
          if (citaBbva) {
            const citaKey = String(citaBbva.id);
            await cobrarConsulta(citaBbva, {
              metodoPago: "bbva_terminal",
              clienteSel: consultaCliById[citaKey] || null,
            });
          } else {
            const ro = recetaOrigenPendienteRef.current || "no_aplica";
            recetaOrigenPendienteRef.current = "no_aplica";
            await ejecutarCobrar(ro, "bbva_terminal");
          }
        }}
        onCancel={() => {
          setBbvaModal(false);
          bbvaCitaRef.current = null;
          recetaOrigenPendienteRef.current = "no_aplica";
        }}
      />

      {ticket&&<TicketPreviewModal
        open={!!ticket}
        venta={{id:ticket.id, folio:ticket.folio, total:ticket.total, created_at:new Date().toISOString(), metodo_pago:ticket.pay, neto:ticket.neto, iva:ticket.iva}}
        productos={ticket.items}
        cliente={ticket.cli}
        metodoPago={ticket.pay}
        config={config}
        promoMsg={promoTicket}
        origen={ticket.origen || "tienda"}
        autoWhatsApp={ticket.autoWhatsApp === true}
        onClose={()=>setTicket(null)}
        onNuevaVenta={()=>{ setTicket(null); setCart([]); setTel(""); setCli(null); }}
      />}
      

      {/* TAB: VENTA NORMAL */}
      {tab==="venta"&&(
        <>
        <div
          className={`farmacapital-pos-venta-grid${isMobilePos ? " farmacapital-pos-venta-narrow" : ""}`}
          style={{
          display: isMobilePos ? "flex" : "grid",
          flexDirection: isMobilePos ? "column" : undefined,
          gridTemplateColumns: isMobilePos
            ? undefined
            : (cartOpen ? "1fr minmax(260px, 320px)" : "1fr"),
          gap: isMobilePos ? 0 : 16,
          alignItems: isMobilePos ? "stretch" : "start",
          position:"relative",
          minWidth:0,
          width:"100%",
          maxWidth:"100%",
        }}>
          <div className="farmacapital-pos-products-col" style={{ minWidth: 0, touchAction: "pan-y" }}>
            {isMobilePos && (
            <div
              className="farmacapital-pos-venta-toolbar"
              style={{
                position: "sticky",
                top: 0,
                zIndex: 8,
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "6px 0 8px",
                marginBottom: 8,
                background: C.card,
                borderBottom: `1px solid ${C.border}`,
                boxShadow: "0 2px 10px rgba(15,50,70,.05)",
              }}
            >
              <button
                type="button"
                data-tour="pos-toolbar-carrito"
                onClick={() => setCartOpen(true)}
                aria-expanded={cartOpen}
                aria-label="Abrir carrito y cobrar"
                style={{
                  flex: 1,
                  minWidth: 0,
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  padding: "8px 10px",
                  borderRadius: 10,
                  border: `1px solid ${cart.length ? BRAND.primary : C.border}`,
                  background: cart.length ? BRAND.primary + "12" : C.bg,
                  cursor: "pointer",
                  fontFamily: "inherit",
                  textAlign: "left",
                }}
              >
                <span
                  style={{
                    fontSize: 22,
                    lineHeight: 1,
                    flexShrink: 0,
                  }}
                  aria-hidden
                >
                  🛒
                </span>
                <div style={{ display: "flex", flexDirection: "column", gap: 1, minWidth: 0 }}>
                  <span style={{ fontWeight: 800, fontSize: 12, color: C.text }}>
                    Carrito
                    {cart.length > 0 ? (
                      <span style={{ fontWeight: 700, color: C.textDim }}>
                        {" "}
                        · {cart.length} {cart.length === 1 ? "ítem" : "ítems"}
                      </span>
                    ) : null}
                  </span>
                  <span
                    style={{
                      fontSize: 10,
                      fontWeight: 700,
                      color: C.textDim,
                      letterSpacing: 0.3,
                      textTransform: "uppercase",
                    }}
                  >
                    Total
                  </span>
                </div>
                <div
                  style={{
                    marginLeft: "auto",
                    flex: "1 1 120px",
                    minWidth: 96,
                    maxWidth: "48%",
                    padding: "6px 10px",
                    borderRadius: 10,
                    background: C.blueDim,
                    border: `1px solid ${C.blue}35`,
                    textAlign: "center",
                  }}
                >
                  <span
                    style={{
                      fontWeight: 900,
                      fontSize: 16,
                      color: C.blue,
                      fontVariantNumeric: "tabular-nums",
                    }}
                  >
                    {$(total)}
                  </span>
                </div>
              </button>
              {!isMobilePos && (
              <button
                type="button"
                onClick={() => posTourRef.current?.startTour()}
                aria-label={TOURS.pos?.label || "Tour del Punto de Venta"}
                title={TOURS.pos?.label || "Tour del Punto de Venta"}
                style={{
                  width: 36,
                  height: 36,
                  borderRadius: 18,
                  flexShrink: 0,
                  border: "none",
                  background: "linear-gradient(135deg,#1E3ABA,#1E3ABA)",
                  color: "#fff",
                  fontWeight: 800,
                  fontSize: 16,
                  lineHeight: 1,
                  cursor: "pointer",
                  boxShadow: "0 4px 12px rgba(0, 82, 204, 0.28)",
                }}
              >
                ?
              </button>
              )}
            </div>
            )}
            <div style={{display:"flex",gap:8,marginBottom:12,alignItems:"center",flexWrap: isNarrow ? "wrap" : "nowrap"}}>
              <div ref={srchWrapRef} style={{flex:1,minWidth:0,position:"relative"}}>
              <input ref={srchRef} className="farmacapital-pos-srch farmacapital-field-input" value={srch}
                data-tour="pos-buscador"
                onChange={e=>{
                  const v = e.target.value;
                  setSrch(v);
                  if (!v.trim()) {
                    setFichaProd(null);
                    setSrchFocus(false);
                    return;
                  }
                  const scanKey = normalizeBarcodeRaw(v) || v.trim();
                  const exact = findProductExactScan(productos, scanKey);
                  if (exact) {
                    setFichaProd(exact);
                    setSrchFocus(false);
                  } else {
                    setSrchFocus(!isAllDigitsInput(v));
                  }
                }}
                onFocus={(e)=>{
                  if (isAllDigitsInput(srch)) e.target.select();
                  else if (!isAllDigitsInput(srch)) setSrchFocus(true);
                }}
                onBlur={()=>setTimeout(()=>setSrchFocus(false),200)}
                onKeyDown={e=>{
                  if (e.key.length === 1 && /\d/.test(e.key)) {
                    const now = Date.now();
                    if (shouldReplaceScanInput(srch, scanLastKeyTsRef.current, now)) {
                      e.preventDefault();
                      setSrch(e.key);
                      setFichaProd(null);
                      setSrchFocus(false);
                      scanLastKeyTsRef.current = now;
                      return;
                    }
                    scanLastKeyTsRef.current = now;
                  }
                  if(e.key==="Enter"){
                    const raw = normalizeBarcodeRaw(srch) || srch.trim();
                    const exact = findProductExactScan(productos, raw);
                    if(exact){
                      finalizarEscaneoExitoso(exact, raw);
                      e.preventDefault();
                    }
                    else if(looksLikeBarcodeInput(raw)){
                      showToast("Código de barras no encontrado en inventario.","warning");
                      setSrch("");
                      e.preventDefault();
                    }
                    else if(srchSuggestions.length>0){
                      const hit=productos.find(x=>x.id===srchSuggestions[0].id);
                      if(hit){
                        setFichaProd(hit);
                        const fifo=getStockFifoDisponible(hit);
                        if(!hit.venta_unidad&&fifo<=0){showToast(`"${hit.nombre}" no tiene lotes registrados. Ve a Inventario → Lotes para agregarlo.`,"warning");}
                        else{add(hit,false);setSrch("");setFichaProd(null);setSrchFocus(false);}
                        e.preventDefault();
                      }
                    }
                    else if(fil.length>0){
                      setFichaProd(fil[0]);
                      e.preventDefault();
                    }
                  }
                  if(e.key==="Escape"){setSrchFocus(false);}
                }}
                placeholder="🔫 Código de barras, SKU o nombre · Enter agrega · flechas en resultados"
                style={{width:"100%",boxSizing:"border-box",padding: srch.trim() ? "9px 38px 9px 13px" : "9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:"#ffffff",color:C.text,WebkitTextFillColor:C.text,caretColor:C.text,colorScheme:"light",fontSize:isMobilePos?16:13,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
              {srch.trim() && (
                <button
                  type="button"
                  onClick={clearPosSearch}
                  aria-label="Borrar búsqueda"
                  title="Borrar búsqueda"
                  style={{
                    position: "absolute",
                    right: 8,
                    top: "50%",
                    transform: "translateY(-50%)",
                    width: 28,
                    height: 28,
                    borderRadius: 14,
                    border: "none",
                    background: "transparent",
                    color: C.textDim,
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 18,
                    lineHeight: 1,
                    padding: 0,
                  }}
                >
                  ×
                </button>
              )}
              {srchSuggestions.length>0&&srchFocus&&!srchEsEscaneo&&(
                <div style={{position:"absolute",top:"calc(100% + 4px)",left:0,right:0,zIndex:7000,background:"#fff",border:"1px solid #e2e8f0",borderRadius:10,boxShadow:"0 8px 32px rgba(15,45,110,.14)",overflow:"hidden",maxHeight:280,overflowY:"auto"}}>
                  {srchSuggestions.map((s,i)=>{
                    const row=productos.find(x=>x.id===s.id);
                    const rowFifo = row ? getStockFifoDisponible(row) : 0;
                    const rowSinLotes = row && !row.venta_unidad && rowFifo <= 0;
                    return(
                        <div key={s.id} onMouseDown={e=>{
                            e.preventDefault();
                            if(row){
                              setFichaProd(row);
                              if(rowSinLotes){showToast(`"${row.nombre}" no tiene lotes. Ve a Inventario → Lotes.`,"warning");}
                            }
                            setSrchFocus(false);
                          }}
                          style={{padding:"9px 13px",cursor:"pointer",borderBottom:"1px solid #f0f4f9",background:rowSinLotes?"#fef2f2":"#fff",display:"flex",alignItems:"center",gap:10,opacity:rowSinLotes?0.75:1}}
                          onMouseEnter={e=>e.currentTarget.style.background=rowSinLotes?"#fee2e2":"#eff6ff"}
                          onMouseLeave={e=>e.currentTarget.style.background=rowSinLotes?"#fef2f2":"#fff"}>
                          <div style={{flex:1,minWidth:0}}>
                            <div style={{color:"#1e293b",fontWeight:600,fontSize:13,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{posTituloProducto(row || s)}</div>
                            <div style={{color:rowSinLotes?"#ef4444":"#94a3b8",fontSize:11,marginTop:1,fontWeight:rowSinLotes?700:400}}>
                              {rowSinLotes?"⚠ Sin lotes disponibles":(posSubtituloProducto(row) || (s.sku?`SKU ${s.sku}`:"")+(Number(s.stock)<=0?" · Agotado":""))}
                            </div>
                          </div>
                          <span style={{fontSize:11,fontWeight:700,color:rowSinLotes?"#ef4444":BRAND.accent,flexShrink:0}}>{row?.precio!=null?`$${Number(row.precio).toFixed(0)}`:""}</span>
                        </div>
                    );
                  })}
                </div>
              )}
              </div>
              {!isMobilePos && (
              <button onClick={()=>setCartOpen(p=>!p)} style={{
                padding:"9px 14px",borderRadius:8,border:`1px solid ${C.border}`,
                background:cart.length?BRAND.primary+"18":"transparent",
                color:cart.length?BRAND.primary:C.textMid,
                fontWeight:700,fontSize:12,cursor:"pointer",whiteSpace:"nowrap",flexShrink:0,
              }}>🛒{cart.length>0?` (${cart.length})`:""} {cartOpen?"▶":"◀"}</button>
              )}
            </div>
            <PosProductoFichaPanel
              item={fichaProd}
              productos={productos}
              usoTexto={fichaProd ? (usoByProdId[fichaProd.id] || (posDescripcionEsUsoValido(fichaProd) ? fichaProd.descripcion : null)) : null}
              usoLoading={!!fichaProd && usoLoadingId === fichaProd.id}
              onSelectVariante={setFichaProd}
              onAddCaja={(it) => add(it, false)}
              onAddUnidad={(it) => add(it, true)}
              onAbrirCaja={abrirCaja}
              getStockCajasPOS={getStockCajasPOS}
              productoSinLotesPEPS={productoSinLotesPEPS}
              C={C}
              isMobilePos={isMobilePos}
              isNarrow={isNarrow}
              sticky={!!srch.trim() || !!fichaProd}
            />

            {favs.length>0&&(
              <div data-tour="pos-favoritos" style={{marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>⭐ Favoritos</div>
                <div style={{display:"flex",gap:6,flexWrap:"wrap"}}>
                  {productos.filter(p=>favs.includes(p.id)&&p.activo).map(p=>(
                    <button key={p.id} onClick={()=>setFichaProd(p)}
                      style={{padding:"5px 10px",borderRadius:8,border:`1px solid ${C.amber}`,background:C.amberDim,color:"#92400e",fontSize:11,fontWeight:700,cursor:"pointer",maxWidth:130,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>
                      ⭐ {p.nombre.split(" ").slice(0,3).join(" ")}
                    </button>
                  ))}
                </div>
              </div>
            )}
            {srch.trim() && !srchEsEscaneo && (
              <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:4,padding:"2px 0"}}>
                <span style={{fontSize:11,color:C.textDim}}>
                  {fil.length === 0
                    ? "Sin resultados para esta búsqueda"
                    : `${fil.length} resultado${fil.length!==1?"s":""} · mejores primero`}
                </span>
                <button type="button" onClick={clearPosSearch} style={{fontSize:11,color:C.textDim,background:"none",border:"none",cursor:"pointer",padding:"0 4px",lineHeight:1}}>✕ Limpiar</button>
              </div>
            )}
            {srch.trim() && fil.length === 0 && (
              <div style={{textAlign:"center",padding:"32px 16px",color:C.textDim,fontSize:13}}>
                {looksLikeBarcodeInput(normalizeBarcodeRaw(srch) || srch)
                  ? <>Código de barras no registrado: <strong style={{color:C.text}}>{srch.trim()}</strong></>
                  : <>No se encontró ningún producto con "<strong style={{color:C.text}}>{srch}</strong>".</>}
                <br/>
                <span style={{fontSize:11}}>
                  {looksLikeBarcodeInput(normalizeBarcodeRaw(srch) || srch)
                    ? "Verifica el código o captúralo en Inventario."
                    : "Intenta con otro nombre, SKU o código de barras."}
                </span>
              </div>
            )}
            {srch.trim() && fil.length > 0 && !srchEsEscaneo && !looksLikeBarcodeInput(normalizeBarcodeRaw(srch) || srch) && (
              <div style={{ border: `1px solid ${C.border}`, borderRadius: 12, overflow: "hidden", background: C.card, maxHeight: 320, overflowY: "auto" }}>
                <div style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.5, textTransform: "uppercase", position: "sticky", top: 0, background: C.card, zIndex: 1 }}>
                  Resultados ({Math.min(fil.length, 60)}{fil.length > 60 ? "+" : ""})
                </div>
                {fil.slice(0, 60).map((item) => {
                  const sel = fichaProd?.id === item.id;
                  const thumb = item.imagen_url || item.imagen_mobile_url || "";
                  const stockCajas = getStockCajasPOS(item);
                  const sinLotes = productoSinLotesPEPS(item);
                  const agotado = stockCajas <= 0 && (!item.venta_unidad || item.stock_unidades === 0);
                  const noDisp = sinLotes || agotado;
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => setFichaProd(item)}
                      style={{
                        width: "100%",
                        display: "flex",
                        alignItems: "center",
                        gap: 12,
                        padding: "10px 12px",
                        border: "none",
                        borderBottom: `1px solid ${C.border}`,
                        background: sel ? C.blueDim : C.card,
                        cursor: "pointer",
                        textAlign: "left",
                        opacity: noDisp ? 0.72 : 1,
                      }}
                    >
                      <div style={{ width: 44, height: 44, borderRadius: 8, overflow: "hidden", background: C.cardDark, flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
                        {thumb ? (
                          <img src={thumb} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                        ) : (
                          <span style={{ fontSize: 20 }}>💊</span>
                        )}
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontWeight: sel ? 800 : 600, fontSize: 13, color: C.text, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                          {posTituloProducto(item)}
                        </div>
                        <div style={{ fontSize: 11, color: C.textDim, marginTop: 2 }}>
                          {posSubtituloProducto(item) || item.sku}
                          {sinLotes ? " · Sin lotes" : agotado ? " · Agotado" : ` · ${stockCajas} disp.`}
                        </div>
                      </div>
                      <div style={{ fontWeight: 800, fontSize: 14, color: C.blue, flexShrink: 0 }}>{$(item.precio)}</div>
                    </button>
                  );
                })}
                {fil.length > 60 && (
                  <div style={{ padding: "10px 12px", fontSize: 11, color: C.textDim, textAlign: "center" }}>
                    Hay {fil.length - 60} resultados más — afina la búsqueda
                  </div>
                )}
              </div>
            )}
          </div>
          {/* Carrito: escritorio = columna; móvil = modal (barra compacta arriba). */}
          {!isMobilePos && cartOpen ? (
          <div
            id="farmacapital-pos-cart"
            className="farmacapital-pos-cart-col"
            data-tour="pos-carrito"
            style={{
            position: "sticky",
            top: 12,
            alignSelf: "start",
            minWidth: 0,
            maxWidth: "100%",
            maxHeight: "calc(100dvh - 120px)",
            overflowY: "auto",
            WebkitOverflowScrolling: "touch",
          }}>
            {renderPosCarritoVentaInner()}
          </div>
          ) : null}
        </div>
        {isMobilePos && cartOpen && (
          <div
            className="farmacapital-pos-cart-sheet-root"
            role="dialog"
            aria-modal="true"
            aria-label="Carrito de venta"
            style={{
              position: "fixed",
              inset: 0,
              zIndex: 1100,
              display: "flex",
              flexDirection: "column",
              justifyContent: "flex-end",
              pointerEvents: "auto",
              overscrollBehavior: "contain",
            }}
          >
            <button
              type="button"
              aria-label="Cerrar carrito"
              onClick={() => setCartOpen(false)}
              style={{
                position: "absolute",
                inset: 0,
                border: "none",
                padding: 0,
                margin: 0,
                background: "rgba(15,23,42,.48)",
                cursor: "pointer",
              }}
            />
            <div
              className="farmacapital-pos-cart-sheet-panel"
              style={{
                position: "relative",
                zIndex: 1,
                display: "flex",
                flexDirection: "column",
                maxHeight: "96dvh",
                height: "96dvh",
                background: C.card,
                borderTopLeftRadius: 18,
                borderTopRightRadius: 18,
                boxShadow: "0 -16px 48px rgba(15,23,42,.28)",
                paddingBottom: "max(12px, env(safe-area-inset-bottom, 0px))",
                overflow: "hidden",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div
                style={{
                  flexShrink: 0,
                  padding: "8px 12px 10px",
                  borderBottom: `1px solid ${C.border}`,
                }}
              >
                <div
                  style={{
                    width: 36,
                    height: 4,
                    borderRadius: 2,
                    background: C.border,
                    margin: "0 auto 10px",
                  }}
                  aria-hidden
                />
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                  }}
                >
                  <div style={{ width: 40, flexShrink: 0 }} aria-hidden />
                  <span
                    style={{
                      fontWeight: 900,
                      fontSize: 16,
                      color: C.text,
                      flex: 1,
                      textAlign: "center",
                    }}
                  >
                    Carrito · {$(total)}
                  </span>
                  <button
                    type="button"
                    onClick={() => setCartOpen(false)}
                    aria-label="Cerrar"
                    style={{
                      flexShrink: 0,
                      width: 40,
                      height: 40,
                      borderRadius: 10,
                      border: `1px solid ${C.border}`,
                      background: C.bg,
                      color: C.textMid,
                      fontSize: 18,
                      lineHeight: 1,
                      cursor: "pointer",
                    }}
                  >
                    ✕
                  </button>
                </div>
              </div>
              <div
                id="farmacapital-pos-cart"
                data-tour="pos-carrito"
                style={{
                  flex: 1,
                  minHeight: 0,
                  overflowY: "auto",
                  WebkitOverflowScrolling: "touch",
                  padding: "8px 14px 4px",
                  overscrollBehavior: "contain",
                }}
              >
                {renderPosCarritoVentaInner()}
              </div>
            </div>
          </div>
        )}
        </>
      )}

      {/* TAB: PEDIDOS ONLINE */}
      {tab==="online"&&(
        <div>
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:10,padding:"10px 14px",marginBottom:14,fontSize:12,color:C.blue,lineHeight:1.45}}>
            <strong>Operación:</strong> aquí solo aparecen pedidos con <strong>pago aprobado</strong> en Mercado Pago. Surtir y marcar listo cuando el producto esté preparado.
          </div>
          {loading ? <SkeletonTable rows={3} cols={4}/> : (
            <>
              {!pedOnline.length ? (
                <div style={{color:C.textMid,padding:40,textAlign:"center"}}>✓ Sin pedidos online pendientes</div>
              ) : pedOnline.map(p=>{
            const clienteNombre = p.clientes?.nombre || p.guest_nombre || "—";
            const clienteTel    = p.clientes?.telefono || p.guest_telefono || "";
            const folioPOS      = formatFolioOnline(p.id);
            const enviarWhatsApp = ()=>{
              if(!clienteTel){ showToast("Este pedido no tiene teléfono registrado","warning"); return; }
              const msg = buildOnlineOrderReceiptMessage({
                pedidoId: p.id,
                items: (p.pedido_items||[]).map(i=>({
                  nombre: i.productos?.nombre,
                  qty: i.cantidad,
                  precio: i.precio_unitario,
                })),
                total: p.total,
                tipoEntrega: p.tipo_entrega,
                metodoPago: p.metodo_pago,
              });
              if (!openWhatsAppToCustomer(clienteTel, msg)) {
                showToast("No se pudo abrir WhatsApp","warning");
              }
            };
            return(
            <Box key={p.id} style={{padding: isNarrow ? 14 : 20,marginBottom:12,minWidth:0}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:12,flexWrap:"wrap",gap:10}}>
                <div>
                  <div style={{display:"flex",alignItems:"center",gap:10,flexWrap:"wrap"}}>
                    <div style={{color:C.text,fontWeight:800,fontSize:15}}>Pedido #{p.id}</div>
                    <div style={{background:BRAND.primary,color:"#fff",fontWeight:900,fontSize:13,padding:"2px 10px",borderRadius:20}}>{folioPOS}</div>
                  </div>
                  <div style={{display:"flex",gap:6,flexWrap:"wrap",marginTop:6}}>
                    <Tag col={p.tipo_entrega==="envio"?C.teal:C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
                    {(p.guest_nombre||p.guest_telefono)&&<Tag col={C.amber} sm>Invitado</Tag>}
                  </div>
                  <div style={{color:C.text,fontSize:13,fontWeight:700,marginTop:6}}>{clienteNombre}</div>
                  {clienteTel&&<div style={{color:C.textMid,fontSize:12,marginTop:1}}>📱 {clienteTel}</div>}
                  {p.tipo_entrega==="envio"&&p.direccion&&(
                    <div style={{color:C.textDim,fontSize:11,marginTop:4,maxWidth:480,lineHeight:1.35}}>📍 {p.direccion}</div>
                  )}
                  <div style={{color:C.textDim,fontSize:11,marginTop:2}}>{new Date(p.created_at).toLocaleString("es-MX")}</div>
                </div>
                <div style={{textAlign:"right"}}>
                  <div style={{color:C.blue,fontWeight:900,fontSize:18}}>{$(p.total)}</div>
                  <Tag col={C.green} sm>Pago aprobado</Tag>
                </div>
              </div>
              <div style={{background:C.bg,borderRadius:8,padding:"10px 14px",marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>Productos</div>
                {(p.pedido_items||[]).map((item,i)=>(
                  <div key={i} style={{display:"flex",justifyContent:"space-between",gap:10,marginBottom:6}}>
                    <div style={{minWidth:0}}>
                      <div style={{color:C.text,fontSize:12}}>{item.productos?.nombre} ×{item.cantidad}</div>
                      <div style={{color:ubicacionPedidoItem(item)==="Sin ubicación"?C.textDim:C.blue,fontSize:11,fontWeight:700}}>
                        📍 {ubicacionPedidoItem(item)}
                      </div>
                    </div>
                    <span style={{color:C.blue,fontSize:12,fontWeight:700,flexShrink:0}}>{$(item.precio_unitario*item.cantidad)}</span>
                  </div>
                ))}
              </div>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                <Btn onClick={()=>surtirOnline(p)} col={C.green} dis={guardando}>✓ Surtir y marcar listo</Btn>
                <button onClick={enviarWhatsApp} style={{display:"flex",alignItems:"center",gap:6,padding:"7px 14px",borderRadius:8,border:"none",background:"#25D366",color:"#fff",fontWeight:700,fontSize:12,cursor:"pointer"}}>
                  💬 WhatsApp cliente
                </button>
                <Btn ol col={C.red} sm onClick={async()=>{
                  const tok = sessionStorage.getItem("farmacapital_session_token");
                  const { error } = await supabase.rpc("admin_cancelar_pedido", {
                    p_session_token: tok, p_pedido_id: p.id,
                  });
                  if (error) showToast("Error: "+error.message, "error");
                  setPedOn(x=>x.filter(z=>z.id!==p.id));
                }}>Cancelar</Btn>
              </div>
            </Box>
          );})}
              <div style={{marginTop:18}}>
                <div style={{color:C.text,fontWeight:800,fontSize:13,marginBottom:8}}>Historial reciente (surtidos)</div>
                {pedOnlineHist.length === 0 ? (
                  <div style={{color:C.textDim,fontSize:12,padding:"8px 0"}}>Sin pedidos surtidos recientes</div>
                ) : pedOnlineHist.map((p)=>(
                  <Box key={`hist-${p.id}`} style={{padding:12,marginBottom:10,minWidth:0,opacity:.95}}>
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:8,flexWrap:"wrap"}}>
                      <div>
                        <div style={{color:C.text,fontWeight:700,fontSize:13}}>Pedido #{p.id} · {formatFolioOnline(p.id)}</div>
                        <div style={{color:C.textMid,fontSize:11,marginTop:2}}>{p.clientes?.nombre} · {new Date(p.created_at).toLocaleString("es-MX")}</div>
                      </div>
                      <div style={{display:"flex",gap:6,alignItems:"center"}}>
                        <Tag col={p.estado==="completado"?C.green:BRAND.accent} sm>{p.estado==="completado"?"Entregado":"Listo"}</Tag>
                        <span style={{color:C.blue,fontWeight:800,fontSize:13}}>{$(p.total)}</span>
                      </div>
                    </div>
                  </Box>
                ))}
              </div>
            </>
          )}
        </div>
      )}

      {/* TAB: COBRAR CONSULTAS */}
      {tab==="consultas"&&(
        <div>
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:10,padding:"12px 16px",marginBottom:16}}>
            <div style={{color:C.blue,fontSize:13,fontWeight:700,lineHeight:1.45}}>
              ℹ <strong>Solo cobro en caja.</strong> Las citas se crean en <strong>Agenda de consultas</strong> o en la <strong>tienda en línea</strong>. Las reservas web quedan <strong>pendientes de pago</strong> hasta cobrar aquí; al pagar, la doctora ve <strong>Pagado</strong>. Consulta {$(parseFloat(config?.precio_consulta)||CONSULTA_PRECIO_DEFAULT)}.
              {usuario?.rol==="admin" && (
                <span style={{display:"block",marginTop:8,fontSize:11,color:C.textMid,fontWeight:600}}>
                  Reparto interno (solo admin): 70% médico / 30% farmacia sobre el monto de la consulta.
                </span>
              )}
            </div>
          </div>

          <div style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:10,padding:"12px 14px",marginBottom:16,display:"flex",flexWrap:"wrap",alignItems:"center",gap:10,justifyContent:"space-between"}}>
            <div style={{color:C.textMid,fontSize:12,lineHeight:1.45,maxWidth:560}}>
              Para <strong style={{color:C.text}}>agendar</strong> o ver el calendario completo usa <strong style={{color:C.text}}>Agenda de consultas</strong>. En esta pestaña no se dan de alta citas nuevas.
            </div>
            <Btn sm col={BRAND.primary} onClick={()=>onNavigate?.("agenda")}>Ir a agenda →</Btn>
          </div>

          <div style={{display:"flex",gap:10,marginBottom:16,flexWrap:"wrap"}}>
            {[["⏳ Por cobrar", consPendientesCount, C.amber], ["✅ Pagadas (ventana)", consPagadasCount, C.green]].map(([lbl, val, col]) => (
              <div key={lbl} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:10,padding:"10px 16px",minWidth:120}}>
                <div style={{color:col,fontWeight:900,fontSize:22}}>{val}</div>
                <div style={{color:C.textMid,fontSize:11}}>{lbl}</div>
              </div>
            ))}
          </div>

          <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:10}}>💳 Cobrar en caja</div>
          <div style={{color:C.textMid,fontSize:12,marginBottom:14}}>Citas con consulta o consumibles pendientes de cobro. Al pagar, el estado cambia a <strong style={{color:C.green}}>Pagada</strong> en la lista de abajo. Si pasaron 10 min del inicio sin pago, puedes usar <em>Cancelar (no asistió)</em>.</div>

          {!consxCobrar.length?<div style={{color:C.textMid,padding:24,textAlign:"center",background:C.bg,borderRadius:10,border:`1px solid ${C.border}`,marginBottom:20}}>✓ Nada pendiente de cobro en caja</div>:
           consxCobrar.map(cita=>{
            const citaKey = String(cita.id);
            const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
            const yaPagoConsulta =
              cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
            const consumibles=(cita.consumibles_consulta||[]).filter(c=>!c.cobrado);
            const totalCons=consumibles.reduce((a,c)=>a+c.precio*c.cantidad,0);
            const totalCobro = (yaPagoConsulta ? 0 : precioBase) + totalCons;
            const telConsulta = consultaTelById[citaKey] ?? "";
            const cliConsulta = consultaCliById[citaKey] ?? null;
            const payConsulta = consultaPayById[citaKey] ?? "efectivo";
            const montoConsulta = consultaMontoById[citaKey] ?? "";
            const recConsultaNum = parseMontoEfectivo(montoConsulta);
            const cambioConsultaNum =
              payConsulta === "efectivo" && Number.isFinite(recConsultaNum)
                ? Math.round(Math.max(0, recConsultaNum - totalCobro) * 100) / 100
                : null;
            const pagoTag = labelEstadoPagoCita(cita);
            return(
              <Box key={cita.id} style={{padding: isNarrow ? 14 : 20,marginBottom:12,minWidth:0}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:12,flexWrap:"wrap",gap:10}}>
                  <div>
                    <div style={{display:"flex",alignItems:"center",gap:8,flexWrap:"wrap"}}>
                      <div style={{color:C.text,fontWeight:800,fontSize:15}}>Consulta — {cita.nombre}</div>
                      <Tag col={pagoTag.col} sm>{pagoTag.label}</Tag>
                      {cita.canal && <Tag col={C.blue} sm>{labelCanal(cita)}</Tag>}
                    </div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:2}}>
                      {cita.fecha ? `${cita.fecha} · ` : ""}{cita.hora} hrs · {cita.motivo||"Consulta general"}
                    </div>
                  </div>
                  <div style={{textAlign: isNarrow ? "left" : "right",minWidth:0,flex:"1 1 140px"}}>
                    <div style={{color:C.green,fontWeight:900,fontSize:18}}>{$(totalCobro)}</div>
                    <div style={{color:C.textDim,fontSize:10}}>
                      {yaPagoConsulta ? `Solo consumibles · ` : `Consulta ${$(precioBase)} + consumibles · `}
                      {totalCons>0?$(totalCons):"$0.00"}
                    </div>
                  </div>
                </div>
                {consumibles.length>0&&(
                  <div style={{background:C.bg,borderRadius:8,padding:"10px 14px",marginBottom:12}}>
                    <div style={{color:C.textDim,fontSize:10,letterSpacing:1,marginBottom:6}}>CONSUMIBLES USADOS</div>
                    {consumibles.map((c,i)=>(
                      <div key={i} style={{display:"flex",justifyContent:"space-between",marginBottom:3}}>
                        <span style={{color:C.text,fontSize:12}}>{c.productos?.nombre || c.nombre} ×{c.cantidad}</span>
                        <span style={{color:C.amber,fontSize:12,fontWeight:700}}>{$(c.precio*c.cantidad)}</span>
                      </div>
                    ))}
                  </div>
                )}
                {String(cita.telefono || "").trim() ? (
                  <div
                    style={{
                      background: C.blueDim,
                      border: `1px solid ${C.blue}25`,
                      borderRadius: 8,
                      padding: "10px 12px",
                      marginBottom: 8,
                    }}
                  >
                    <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, marginBottom: 4 }}>
                      PACIENTE (CITA EN LÍNEA)
                    </div>
                    <div style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>{cita.nombre}</div>
                    <div style={{ color: C.blue, fontWeight: 700, fontSize: 13, marginTop: 4 }}>
                      📱 {formatTelefonoDisplay(cita.telefono)}
                    </div>
                    {cliConsulta ? (
                      <div style={{ color: C.purple, fontSize: 11, fontWeight: 700, marginTop: 6 }}>
                        ⭐ {cliConsulta.puntos || 0} puntos FarmaCapital
                      </div>
                    ) : (
                      <div style={{ color: C.textMid, fontSize: 11, marginTop: 6 }}>
                        Cliente registrado en la cita — no hace falta buscar teléfono.
                      </div>
                    )}
                  </div>
                ) : (
                  <>
                    <SearchDropdown
                      value={telConsulta}
                      onChange={(v)=>setConsultaTelById((prev)=>({ ...prev, [citaKey]: v }))}
                      onSelect={(c)=>{
                        setConsultaTelById((prev)=>({ ...prev, [citaKey]: c.telefono || "" }));
                        setConsultaCliById((prev)=>({ ...prev, [citaKey]: c }));
                      }}
                      placeholder="Teléfono o nombre (solo citas de mostrador sin teléfono)"
                      items={cliSearchItems}
                      labelKey="nombre"
                      subKey="telefono"
                      badgeKey="puntos"
                      badgeCol="#7c3aed"
                      style={{width:"100%",boxSizing:"border-box",marginBottom:8}}
                      emptyMsg="Sin coincidencias · prueba más dígitos o el nombre"
                    />
                    {cliConsulta&&<div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:6,padding:"6px 10px",marginBottom:8}}><span style={{color:C.purple,fontSize:11,fontWeight:700}}>{cliConsulta.nombre} · {cliConsulta.puntos||0} pts</span></div>}
                  </>
                )}
                <Box style={{padding:14,marginBottom:12}}>
                  <div style={{color:C.textDim,fontSize:10,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>Método de pago</div>
                  <div style={{display:"flex",gap:5,flexWrap:"wrap",marginBottom:payConsulta==="efectivo"?12:0}}>
                    {[
                      ["efectivo","💵 Efectivo"],
                      ["tarjeta","💳 Point MP"],
                      ["bbva_terminal","🏦 Terminal BBVA"],
                    ].map(([v,l])=>(
                      <button
                        key={v}
                        type="button"
                        onClick={()=>{
                          setConsultaPayById((prev)=>({ ...prev, [citaKey]: v }));
                          if (v !== "efectivo") {
                            setConsultaMontoById((prev)=>({ ...prev, [citaKey]: "" }));
                          }
                        }}
                        style={{
                          padding:"4px 10px",borderRadius:20,
                          border:`1px solid ${payConsulta===v?C.blue:C.border}`,
                          background:payConsulta===v?C.blueDim:"transparent",
                          color:payConsulta===v?C.blue:C.textMid,
                          fontSize:10,fontWeight:700,cursor:"pointer",
                        }}
                      >{l}</button>
                    ))}
                  </div>
                  {payConsulta==="efectivo"&&(
                    <>
                      <div style={{color:C.textMid,fontSize:11,marginBottom:8}}>¿Cuánto te entregó el cliente?</div>
                      <Inp
                        value={montoConsulta}
                        onChange={(e)=>setConsultaMontoById((prev)=>({ ...prev, [citaKey]: e.target.value }))}
                        placeholder={`Mínimo ${$(totalCobro)}`}
                        inputMode="decimal"
                        style={{width:"100%",boxSizing:"border-box",marginBottom:8,fontSize:16,fontWeight:700}}
                      />
                      <div style={{display:"flex",gap:6,flexWrap:"wrap",marginBottom:10}}>
                        <button type="button" onClick={()=>setConsultaMontoById((prev)=>({ ...prev, [citaKey]: String(totalCobro) }))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.green}`,background:"#fff",color:C.green,fontSize:10,fontWeight:700,cursor:"pointer"}}>Exacto {$(totalCobro)}</button>
                        {sugerenciasPagoCliente(totalCobro).map(({billete,cambio})=>(
                          <button key={billete} type="button" onClick={()=>setConsultaMontoById((prev)=>({ ...prev, [citaKey]: String(billete) }))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,fontSize:10,fontWeight:600,cursor:"pointer",color:C.text}}>
                            ${billete} → cambio {$(cambio)}
                          </button>
                        ))}
                      </div>
                      {Number.isFinite(recConsultaNum)&&recConsultaNum>=totalCobro&&(
                        <div style={{marginBottom:4}}>
                          <div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline"}}>
                            <span style={{color:C.textMid,fontSize:12}}>Cambio a entregar</span>
                            <span style={{color:C.green,fontWeight:900,fontSize:20}}>{$(cambioConsultaNum)}</span>
                          </div>
                          {cambioConsultaNum>0&&desgloseCambioMN(cambioConsultaNum)&&(
                            <div style={{color:C.textMid,fontSize:10,marginTop:4,lineHeight:1.4}}>
                              <strong style={{color:C.text}}>Sugerido:</strong> {desgloseCambioMN(cambioConsultaNum)}
                            </div>
                          )}
                        </div>
                      )}
                      {Number.isFinite(recConsultaNum)&&recConsultaNum>0&&recConsultaNum<totalCobro&&(
                        <div style={{color:C.red,fontSize:11,fontWeight:700}}>Falta ${(totalCobro-recConsultaNum).toFixed(2)}</div>
                      )}
                    </>
                  )}
                </Box>
                <div style={{display:"flex",gap:8,flexWrap:"wrap",alignItems:"center"}}>
                  {payConsulta==="efectivo" ? (
                    <Btn
                      onClick={()=>iniciarCobroConsulta(cita, payConsulta, cliConsulta, totalCobro)}
                      col={C.green}
                      dis={guardando||!Number.isFinite(recConsultaNum)||recConsultaNum<totalCobro}
                      style={{flex:"1 1 200px"}}
                    >{guardando?"Procesando…":`✅ Cobrar ${$(totalCobro)}`}</Btn>
                  ) : payConsulta==="tarjeta" ? (
                    <div style={{flex:"1 1 200px",minWidth:0}}>
                      <Btn
                        onClick={()=>iniciarCobroConsulta(cita, payConsulta, cliConsulta, totalCobro)}
                        col="#009ee3"
                        dis={guardando||totalCobro<=0}
                        full
                      >💳 Cobrar con Point MP</Btn>
                      <div style={{color:C.textDim,fontSize:10,marginTop:8,lineHeight:1.4}}>
                        La app espera la aprobación en el Point Smart 2; al confirmarse se registra el cobro y se imprime el ticket.
                      </div>
                    </div>
                  ) : (
                    <div style={{flex:"1 1 200px",minWidth:0}}>
                      <Btn
                        onClick={()=>iniciarCobroConsulta(cita, payConsulta, cliConsulta, totalCobro)}
                        col="#1a237e"
                        dis={guardando||totalCobro<=0}
                        full
                      >🏦 Cobrar con terminal BBVA</Btn>
                      <div style={{color:C.textDim,fontSize:10,marginTop:8,lineHeight:1.4}}>
                        Procesa el pago en la terminal física BBVA y confirma aquí. El ticket se imprime solo cuando indicas que fue aprobado.
                      </div>
                    </div>
                  )}
                  {puedeCancelarCitaNoShow(cita) && (
                    <Btn sm ol col={C.red} onClick={()=>cancelarCitaPorNoShow(cita)} dis={guardando}>
                      Cancelar (no asistió)
                    </Btn>
                  )}
                </div>
              </Box>
            );
          })}

          <div style={{color:C.text,fontWeight:800,fontSize:14,margin:"28px 0 10px"}}>📋 Estado de consultas</div>
          <div style={{color:C.textMid,fontSize:12,marginBottom:12}}>Todas las citas cercanas con su estado de pago. Las <strong style={{color:"#d97706"}}>pendientes</strong> aparecen arriba para cobrar; al pagar pasan a <strong style={{color:C.green}}>Pagada</strong>.</div>
          {!citasResumenPos.length ? (
            <div style={{color:C.textMid,padding:20,textAlign:"center",background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>Sin consultas en la ventana de fechas</div>
          ) : (
            <div style={{borderRadius:12,border:`1px solid ${C.border}`,overflow:"hidden"}}>
              {citasResumenPos.map((cita, i) => {
                const pagoTag = labelEstadoPagoCita(cita);
                const enCobro = consxCobrar.some((x) => String(x.id) === String(cita.id));
                const estadoTxt = {
                  agendada: "Agendada",
                  confirmada: "Confirmada",
                  en_consulta: "En consulta",
                  completada: "Atendida",
                  pagada: "Pagada",
                  no_asistio: "No asistió",
                }[cita.estado] || cita.estado || "—";
                return (
                  <div
                    key={cita.id}
                    style={{
                      display:"flex",
                      alignItems:"center",
                      justifyContent:"space-between",
                      gap:10,
                      flexWrap:"wrap",
                      padding:"12px 16px",
                      background: i % 2 === 0 ? C.card : C.bg,
                      borderBottom: i < citasResumenPos.length - 1 ? `1px solid ${C.border}` : "none",
                    }}
                  >
                    <div style={{minWidth:0,flex:"1 1 200px"}}>
                      <div style={{color:C.text,fontWeight:700,fontSize:13}}>{cita.nombre}</div>
                      <div style={{color:C.textMid,fontSize:11,marginTop:2}}>
                        {cita.fecha} · {cita.hora} hrs · {estadoTxt}
                        {enCobro ? " · en cola de cobro" : ""}
                      </div>
                    </div>
                    <div style={{display:"flex",gap:6,alignItems:"center",flexWrap:"wrap"}}>
                      {cita.canal && <Tag col={C.blue} sm>{labelCanal(cita)}</Tag>}
                      <Tag col={pagoTag.col} sm>{pagoTag.label}</Tag>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {tab==="servicios"&&(
        <PagoServiciosPanel
          isNarrow={isNarrow}
          refreshToken={serviciosRefresh}
          onCobrarPoint={(payload) => {
            mpCitaRef.current = null;
            mpServicioRef.current = payload;
            setMpFolio(payload.folio);
            setMpModal(true);
          }}
        />
      )}
      <OnboardingTour ref={posTourRef} tourId="pos" usuario={usuario} showFab={!isMobilePos} />
    </div>
  );
}
