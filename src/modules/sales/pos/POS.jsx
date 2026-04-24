import React, { useState, useEffect, useRef, useCallback } from "react";
import { useMediaQuery } from "../../../hooks/useMediaQuery";
import TicketPreviewModal from "../../../components/tickets/TicketPreviewModal";
import MercadoPagoModal from "../../../components/MercadoPagoModal";
import { printTicket } from "../../../utils/printTicket";
import { supabase } from "../../../supabase";
import { C_LIGHT, BRAND } from "../../../constants";
import { $, logAudit, soloDigitosTel, normalizeForSearch } from "../../../utils";
import { inventarioProductMatchesBusqueda } from "../../../utils/fuzzySearch";
import { Box, Tag, Btn, Inp, Modal, showToast, SearchDropdown, SkeletonTable } from "../../../ui";
import { CONSULTA_PRECIO_DEFAULT, citaPagoPendiente, labelCanal } from "../../../utils/consultaConstants";
import { puedeCancelarCitaNoShow } from "../../../utils/citasAgenda";
import { esPedidoTiendaWebPendiente, fetchPedidosTiendaPendientesMerged } from "../../../utils/pedidosTiendaWeb";
import { desgloseCambioMN, sugerenciasPagoCliente } from "../../../utils/cambioCaja";
import { marcarMedicamentosRecetaFarmaxSurtidos } from "../../../utils/recetaCitaSync";
import OnboardingTour from "../../../components/OnboardingTour";
import { TOURS } from "../../../utils/tours";
import { labelTipoEntregaPedido, resumenLogisticsMeta } from "../../../utils/orderChannels";

const PEDIDOS_TIENDA_SELECT_POS = `
            id,total,created_at,tipo,metodo_pago,estado,tipo_entrega,direccion,
            clientes(nombre,telefono),
            pedido_items(cantidad,precio_unitario,productos(nombre,sku))
          `;

export default function POS({negocio,usuario,initialTab="venta",onNavigate}){
  const C = C_LIGHT;
  /** Vista estrecha (tablet / ventana angosta): tipografía, grillas, cabecera. */
  const isNarrow = useMediaQuery("(max-width: 1100px)");
  /** Solo celular / pantalla muy estrecha: carrito en modal + barra Carrito/total/? (no afecta escritorio). */
  const isMobilePos = useMediaQuery("(max-width: 768px)");
  const [tab,setTab]         = useState(initialTab); // venta | online | consultas
  const [productos,setProds] = useState([]);
  const [cart,setCart]       = useState([]);
  const [srch,setSrch]       = useState("");
  const srchRef = useRef(null);
  /** Tour POS: botón "?" va en la barra de carrito (no FAB esquina). */
  const posTourRef = useRef(null);
  // iOS Safari hace zoom al enfocar inputs si el tamaño es <16px o si el foco llega al cargar.
  // En ≤768px no autoenfocamos el buscador para que la vista entre completa sin pellizcar.
  useEffect(() => {
    if (tab !== "venta" || typeof window === "undefined") return;
    if (window.matchMedia("(max-width: 768px)").matches) return;
    srchRef.current?.focus();
  }, [tab]);
  const [favs,setFavs]       = useState(()=>{ try{ return JSON.parse(localStorage.getItem("farmax_pos_favs")||"[]"); }catch{ return []; } });
  const toggleFav = id => {
    setFavs(p=>{
      const n = p.includes(id)?p.filter(x=>x!==id):[...p,id].slice(0,8);
      localStorage.setItem("farmax_pos_favs", JSON.stringify(n));
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
  /** Citas con consulta o consumibles pendientes de cobro en caja (agendadas en línea o en Agenda de consultas). */
  const [consxCobrar,setConsCobrar] = useState([]);
  const [cliSearchItems, setCliSearchItems] = useState([]);
  const [loading,setLoad]    = useState(false);
  const [guardando,setGuard] = useState(false);
  const [cartOpen, setCartOpen] = useState(() => {
    if (typeof window === "undefined") return true;
    return !window.matchMedia("(max-width: 768px)").matches;
  });
  const [mpModal,setMpModal]     = useState(false);
  const [mpFolio,setMpFolio]     = useState("");
  /** Tras elegir origen de receta, cobro con tarjeta (Point) usa este valor al confirmar el pago. */
  const recetaOrigenPendienteRef = useRef("no_aplica");
  const [modalRecetaVenta, setModalRecetaVenta] = useState(false);
  const [modalRecetaModo, setModalRecetaModo] = useState(null);
  const [recetaOrigenSel, setRecetaOrigenSel] = useState("no_aplica");
  /** Si no es null, el modal MP cobra esa cita (no venta de carrito). */
  const mpCitaRef = useRef(null);
  const [ventasDia,setVentasDia] = useState({total:0,count:0});
  const [folioActual,setFolioActual] = useState("VTA-00000000");
  const [promoTicket,setPromoTicket] = useState(null);
  const [loadErr,setLoadErr] = useState("");
  const [config,setConfig]   = useState({precio_consulta:CONSULTA_PRECIO_DEFAULT,nombre_doctor:"Dra. Lourdes Lucio Falcón",nombre_farmacia:"Farmax",telefono_farmacia:"",direccion_farmacia:"Chinampac de Juárez, Iztapalapa, CDMX"});

  useEffect(() => {
    try {
      const t = sessionStorage.getItem("farmax_pos_initial_tab");
      if (t === "consultas" || t === "online" || t === "venta") {
        setTab(t);
        sessionStorage.removeItem("farmax_pos_initial_tab");
        return;
      }
    } catch (_) { /* noop */ }
    setTab(initialTab);
  }, [initialTab]);

  useEffect(()=>{
    supabase.from("configuracion").select("*").then(({ data: cfg }) => {
      if (cfg && cfg.length) {
        const map = {};
        cfg.forEach((r) => {
          map[r.clave] = r.valor;
        });
        setConfig((p) => ({
          ...p,
          precio_consulta: parseFloat(map.precio_consulta) || CONSULTA_PRECIO_DEFAULT,
          nombre_doctor: map.nombre_doctor || p.nombre_doctor,
          nombre_farmacia: map.nombre_farmacia || p.nombre_farmacia,
          telefono_farmacia: map.telefono_farmacia || "",
          direccion_farmacia: map.direccion_farmacia || p.direccion_farmacia,
        }));
      }
    });
  }, []);

  const refrescarCitasPOS = useCallback(async () => {
    const hoy = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    const toSv = (dt) => `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())}`;
    const desdeDt = new Date(hoy);
    desdeDt.setDate(desdeDt.getDate() - 21);
    const hastaDt = new Date(hoy);
    hastaDt.setDate(hastaDt.getDate() + 45);
    const desde = toSv(desdeDt);
    const hasta = toSv(hastaDt);
    const { data, error } = await supabase
      .from("citas")
      .select(`
        id,nombre,telefono,hora,fecha,motivo,estado,canal,pago_estado,pedido_consulta_id,precio_consulta_cobrado,ingreso_doctor,ingreso_farmacia,
        consumibles_consulta(id,cantidad,precio,cobrado,nombre,producto_id)
      `)
      .gte("fecha", desde)
      .lte("fecha", hasta)
      .not("estado", "eq", "cancelada");
    if (error) {
      console.error("[POS] Citas:", error);
      setConsCobrar([]);
      return;
    }
    const citas = data || [];
    setConsCobrar(
      citas.filter((c) => {
        const pendientePago = citaPagoPendiente(c);
        const consumiblesPend = (c.consumibles_consulta || []).some((x) => !x.cobrado);
        return pendientePago || consumiblesPend;
      })
    );
  }, []);

  const recargarPedidosOnline = useCallback(async () => {
    try {
      const pedsRes = await fetchPedidosTiendaPendientesMerged(supabase, PEDIDOS_TIENDA_SELECT_POS, {
        perBranchLimit: 100,
        maxRows: 300,
      });
      if (pedsRes?.error) {
        console.warn("[POS] Pedidos online:", pedsRes.error.message);
        return;
      }
      setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));
    } catch (e) {
      console.warn("[POS] recargarPedidosOnline:", e);
    }
  }, []);

  useEffect(() => {
    if (tab !== "online") return;
    recargarPedidosOnline();
  }, [tab, recargarPedidosOnline]);

  useEffect(() => {
    const raw = (tel || "").trim();
    if (!raw) {
      setCliSearchItems([]);
      setCli(null);
      return;
    }
    const tmr = setTimeout(async () => {
      try {
        const digits = soloDigitosTel(tel);
        let q = supabase.from("clientes").select("id,nombre,telefono,puntos").limit(12);
        if (digits.length >= 4) {
          const safeName = raw.replace(/%/g, "");
          q = q.or(`telefono.ilike.%${digits}%,nombre.ilike.%${safeName}%`);
        } else if (raw.length >= 2) {
          q = q.ilike("nombre", `%${raw}%`);
        } else {
          setCliSearchItems([]);
          return;
        }
        const { data, error } = await q;
        if (error) throw error;
        const rows = data || [];
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
        const [prodsRes, pedsRes] = await Promise.all([
          supabase.from("productos")
            .select("*, lotes(fecha_caducidad,cantidad_actual,activo)")
            .eq("activo",true).order("nombre"),
          fetchPedidosTiendaPendientesMerged(supabase, PEDIDOS_TIENDA_SELECT_POS, { perBranchLimit: 100, maxRows: 300 }),
        ]);

        const errs = [];
        if (prodsRes?.error) errs.push(`Productos (${prodsRes.status||"?"}): ${prodsRes.error.message}`);
        if (pedsRes?.error)  errs.push(`Pedidos online (${pedsRes.status||"?"}): ${pedsRes.error.message}`);

        if (errs.length) {
          console.error("[POS] Errores de carga:", { prodsRes, pedsRes });
          if (typeof setLoadErr === "function") setLoadErr(errs.join(" | "));
        }

        const prodsConCad = (prodsRes?.data || []).map(p => {
          const activos = (p.lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
          const minCad = activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
          return { ...p, min_caducidad_lotes: minCad };
        });
        setProds(prodsConCad);
        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));

      } catch (e) {
        console.error("[POS] Excepción cargando datos:", e);
        if (typeof setLoadErr === "function") setLoadErr("Error inesperado cargando datos. Revisa consola.");
        setProds([]); setPedOn([]); setConsCobrar([]);
      } finally {
        setLoad(false);
      }
    };
    cargar();
  },[refrescarCitasPOS]);

  useEffect(() => {
    refrescarCitasPOS();
  }, [refrescarCitasPOS]);


  const fil = productos.filter(p=>
    (negocio==="farmacia"?["Analgésico","Antiinflamatorio","Gastro","Antibiótico","Diabetes","Hipertensión","Alergia","Vitaminas","Hidratación","Cardiovascular","Respiratorio","Botiquín"].includes(p.categoria):true)&&
    inventarioProductMatchesBusqueda(p, srch)
  );

  const paymentLabel = (method) => ({
    efectivo: "Efectivo",
    tarjeta: "Tarjeta",
    spei: "SPEI",
    mercadopago: "Tarjeta",
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
          : [...p,{...item,id:keyU,producto_id:item.id,qty:1,rxI:null,esUnidad:true,precio:Math.ceil(item.precio_unidad||0),nombre:item.nombre+" (unidad)"}];
      });
    } else {
      if ((item.stock || 0) <= 0) {
        showToast("Producto agotado.", "warning");
        return;
      }
      setCart(p=>{
        const ex=p.find(c=>c.id===item.id);
        if(ex){
          if(ex.qty>=(item.stock||99)){ showToast(`Stock máximo: ${item.stock} unidades`,"warning"); return p; }
          return p.map(c=>c.id===item.id?{...c,qty:c.qty+1}:c);
        }
        return [...p,{...item,producto_id:item.id,qty:1,rxI:null,esUnidad:false}];
      });
    }
  };

  const abrirCaja = async (item) => {
    if (item.stock <= 0) { showToast("Sin stock de cajas disponibles.", "warning"); return; }
    const tok = sessionStorage.getItem("farmax_session_token");
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
    setCart(p=>[...p,{...rxM,qty:1,rxI:{...rx}}]);
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

  const ejecutarCobrar = async (recetaOrigen = "no_aplica") => {
    if(!cart.length) return;
    if (pay === "efectivo") {
      const rec = parseMontoEfectivo(montoRecibido);
      if (!Number.isFinite(rec) || rec < total) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(total)}).`, "warning");
        return;
      }
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) {
        alert("Sesión expirada. Inicia sesión de nuevo.");
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
        p_metodo_pago: pay,
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

      const ro = recetaOrigen === "medico_farmax" || recetaOrigen === "medico_externo" ? recetaOrigen : "no_aplica";
      const tokRo = sessionStorage.getItem("farmax_session_token");
      if (tokRo) {
        const { error: uErr } = await supabase.rpc("admin_set_receta_origen_pedido", {
          p_session_token: tokRo, p_pedido_id: pedidoId, p_receta_origen: ro,
        });
        if (uErr) console.warn("[POS] receta_origen:", uErr);
      }

      if (ro === "medico_farmax") {
        const fechaSv = new Date().toLocaleDateString("sv-SE");
        try {
          await marcarMedicamentosRecetaFarmaxSurtidos(supabase, {
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

      const { data: pedidoItems, error: pedidoItemsError } = await supabase
        .from("pedido_items")
        .select("producto_id,cantidad,precio_unitario,lote_id,productos(nombre,sku),lotes(numero_lote,fecha_caducidad)")
        .eq("pedido_id", pedidoId)
        .order("id", { ascending: true });
      if (pedidoItemsError) throw pedidoItemsError;

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
        const tokCof = sessionStorage.getItem("farmax_session_token");
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
      const recEf = pay === "efectivo" ? parseMontoEfectivo(montoRecibido) : null;
      const cambioEf = pay === "efectivo" && Number.isFinite(recEf) ? Math.round(Math.max(0, recEf - total) * 100) / 100 : null;
      const desgloseEf = pay === "efectivo" && cambioEf != null && cambioEf > 0 ? desgloseCambioMN(cambioEf) : "";
      setTicket({
        id:pedidoId,
        folio:folioVenta,
        items:ticketItems.length ? ticketItems : [...cart],
        sub,
        total,
        neto:netoAmt,
        iva:ivaAmt,
        pay:paymentLabel(pay),
        cli,
        ptsG,
        ...(pay === "efectivo" && Number.isFinite(recEf)
          ? { recibido: recEf, cambio: cambioEf, cambioDesglose: desgloseEf }
          : {}),
      });
      setVentasDia(p=>({total:p.total+total, count:p.count+1}));
      logAudit(usuario, "VENTA", "pedidos", pedidoId, {
        total, metodo_pago: pay, items: cart.length,
        ...(pay === "efectivo" && Number.isFinite(recEf) ? { efectivo_recibido: recEf, cambio: cambioEf } : {}),
      });
      showToast("Venta registrada correctamente", "success");
      setCart([]); setTel(""); setCli(null);
      setMontoRecibido("");
      setTimeout(() => printTicket("farmax-ticket"), 500);
    } catch(e) {
      console.error(e);
      const msg = e?.message || e?.details || String(e);
      const lower = msg.toLowerCase();
      if (lower.includes("stock") || lower.includes("insuficiente")) {
        alert("Stock insuficiente o no se pudo completar el descuento de inventario.");
      } else {
        alert(`No se pudo completar la venta.\n\n${msg}`);
      }
    }
    setGuard(false);
  };

  const cobrar = () => abrirModalRecetaVenta("efectivo");

  const confirmarRecetaVentaYContinuar = () => {
    const ro = recetaOrigenSel === "medico_farmax" || recetaOrigenSel === "medico_externo" ? recetaOrigenSel : "no_aplica";
    setModalRecetaVenta(false);
    const modo = modalRecetaModo;
    setModalRecetaModo(null);
    if (modo === "tarjeta") {
      mpCitaRef.current = null;
      recetaOrigenPendienteRef.current = ro;
      setMpFolio(folioActual || "VTA-PENDIENTE");
      setMpModal(true);
    } else if (modo === "efectivo") {
      ejecutarCobrar(ro);
    }
  };

  const surtirOnline = async (pedido) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) { alert("Sesión expirada."); setGuard(false); return; }
      // F6b: marcar_pedido_listo ya descuenta stock FEFO internamente
      const { data: resp, error: rpcErr } = await supabase.rpc("marcar_pedido_listo", {
        p_session_token: tok, p_pedido_id: pedido.id,
      });
      if (rpcErr) throw rpcErr;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo surtir");
      setPedOn(p=>p.filter(x=>x.id!==pedido.id));
      // L4: Notificar al cliente por WhatsApp cuando pedido está listo
      const telCli = pedido.clientes?.telefono;
      if(telCli) {
        const msg = `🏥 *Farmax Farmacia*\n\n✅ ¡Tu pedido #${pedido.id} está listo!\n\nPuedes pasar a recogerlo en:\n📍 Chinampac de Juárez, Iztapalapa, CDMX\n\n¡Te esperamos! 💊`;
        showToast(`Pedido listo. ${telCli?"Puedes notificar al cliente por WhatsApp":""}`, "success");
        // Botón manual para no abrir sin permiso
      }
    } catch(e) { console.error(e); }
    setGuard(false);
  };

  const cancelarCitaPorNoShow = async (cita) => {
    if (!puedeCancelarCitaNoShow(cita)) return;
    if (!window.confirm(`¿Cancelar la cita de ${cita.nombre} (${cita.hora}) y liberar el horario? Solo aplica si pasaron 10 min del inicio sin pago en caja.`)) return;
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data: resp, error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok, p_cita_id: cita.id, p_estado: "cancelada",
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cancelar");
      showToast("Cita cancelada. El horario queda libre.", "info");
      await refrescarCitasPOS();
    } catch (e) {
      console.error(e);
      alert("No se pudo cancelar: " + (e?.message || e));
    }
    setGuard(false);
  };

  const cobrarConsulta = async (cita) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("cobrar_consulta", {
        p_session_token: tok,
        p_cita_id:       cita.id,
        p_cliente_id:    cli?.id || null,
        p_metodo_pago:   pay,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cobrar");

      const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
      const yaPagoConsulta =
        cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
      const consumibles = (cita.consumibles_consulta || []).filter((c) => !c.cobrado);
      const baseCobrar = yaPagoConsulta ? 0 : precioBase;
      const totalFinal = resp.total || 0;

      await refrescarCitasPOS();
      const itemsConsulta =
        baseCobrar > 0
          ? [{ nombre: "Consulta médica", qty: 1, precio: precioBase }]
          : [];
      setTicket({
        id: resp.pedido_id || Date.now(),
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
        pay: paymentLabel(pay),
        cli,
        ptsG: Math.floor(totalFinal / 10),
      });
      setTimeout(() => printTicket("farmax-ticket"), 500);
    } catch (e) {
      console.error(e);
      alert("No se pudo cobrar la consulta: " + (e?.message || e));
    }
    setGuard(false);
  };

  const renderPosCarritoVentaInner = () => (
    <>
      <Box style={{padding:16,marginBottom:12}}>
        <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>🛒 Carrito</div>
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
          <div style={{color:C.textMid,fontSize:10}}>⭐ {cli.puntos||0} puntos Farmax</div>
        </div>}
        {!cart.length?<div style={{color:C.textMid,fontSize:12,textAlign:"center",padding:"20px 0"}}>Agrega productos</div>:
         cart.map(item=>(
          <div key={item.id} style={{marginBottom:10,paddingBottom:10,borderBottom:`1px solid ${C.border}`}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:6,marginBottom:6}}>
              <div style={{color:C.text,fontSize:11,fontWeight:700,flex:1}}>{item.nombre}</div>
              <button onClick={()=>setCart(p=>p.filter(c=>c.id!==item.id))} style={{background:"none",border:"none",color:C.red,cursor:"pointer",fontSize:14}}>×</button>
            </div>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
              <div style={{display:"flex",alignItems:"center",gap:6}}>
                <button onClick={()=>setCart(p=>p.map(c=>c.id===item.id?{...c,qty:Math.max(1,c.qty-1)}:c))} style={{width:22,height:22,borderRadius:4,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:13}}>−</button>
                <span style={{color:C.text,fontSize:12,fontWeight:700}}>{item.qty}</span>
            <button onClick={()=>setCart(p=>p.map(c=>c.id===item.id?((c.esUnidad&&c.qty>=(item.stock_unidades||0))?(showToast(`Máx unidades: ${item.stock_unidades||0}`,"warning"),c):(!c.esUnidad&&c.qty>=(item.stock||99)?(showToast(`Máx: ${item.stock}`,"warning"),c):{...c,qty:c.qty+1})):c))} style={{width:22,height:22,borderRadius:4,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:13}}>+</button>
              </div>
              <span style={{color:C.blue,fontWeight:700,fontSize:13}}>{$(item.precio*item.qty)}</span>
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
          {[["efectivo","Efectivo"],["tarjeta","Tarjeta (Point)"]].map(([v,l])=>(
            <button key={v} type="button" onClick={()=>{ setPay(v); if(v!=="efectivo") setMontoRecibido(""); }} style={{padding:"4px 10px",borderRadius:20,border:`1px solid ${pay===v?C.blue:C.border}`,background:pay===v?C.blueDim:"transparent",color:pay===v?C.blue:C.textMid,fontSize:10,fontWeight:700,cursor:"pointer"}}>{l}</button>
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
        ) : (
          <div>
            <Btn onClick={()=>abrirModalRecetaVenta("tarjeta")}
              full col="#009ee3" dis={!cart.length||guardando}
            >💳 Cobrar con tarjeta (terminal Point)</Btn>
            <div style={{color:C.textDim,fontSize:10,marginTop:10,lineHeight:1.45}}>
              La app <strong>espera</strong> a que el Point Smart 2 confirme el pago con tarjeta. Recién entonces se registra la venta y se envía el ticket a la impresora Epson (mismo flujo que al cobrar en efectivo).
            </div>
          </div>
        )}
      </Box>
      </div>

    </>
  );

  return(
    <div className="farmax-pos-root" style={{
      width:"100%",
      maxWidth:"100%",
      minWidth:0,
      boxSizing:"border-box",
      overflowX:"hidden",
      paddingBottom:"max(8px, env(safe-area-inset-bottom, 0px))",
    }}>
      <style>{`
        @media (max-width: 1100px) {
          .farmax-pos-root { overflow-x: hidden; max-width: 100%; }
        }
        /* Solo ≤768px: marco alto fijo + scroll de productos (carrito en modal por JS). */
        @media (max-width: 768px) {
          input.farmax-pos-srch {
            font-size: 16px !important;
          }
          .farmax-pos-venta-grid.farmax-pos-venta-narrow {
            display: flex !important;
            flex-direction: column !important;
            align-items: stretch !important;
            gap: 0 !important;
            /* Más alto útil para grilla de productos (menos “franja” vacía). */
            height: calc(100dvh - 120px) !important;
            min-height: 280px !important;
            max-height: calc(100dvh - 88px) !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
          }
          .farmax-pos-venta-grid.farmax-pos-venta-narrow .farmax-pos-products-col {
            flex: 1 1 auto !important;
            min-height: 0 !important;
            overflow-x: hidden !important;
            overflow-y: auto !important;
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
          {[["venta","Venta"],["online",`Online (${pedOnline.length})`],["consultas",`Consultas (${consxCobrar.length})`]].map(([v,l])=>(
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
        title="¿La receta es de un médico de Farmax?"
        ac={C.blue}
      >
        <div style={{color:C.textMid,fontSize:13,marginBottom:14,lineHeight:1.45}}>
          Indica si el medicamento surtido corresponde a receta prescrita por algún médico o médica que atiende en el consultorio Farmax. Así medimos ventas ligadas a consultas y estimamos oportunidad cuando el paciente surte fuera.
        </div>
        <div style={{display:"flex",flexDirection:"column",gap:8,marginBottom:16}}>
          {[
            ["no_aplica", "No aplica / venta sin receta de consultorio"],
            ["medico_farmax", "Sí — receta de doctor(a) de Farmax"],
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
        total={mpCitaRef.current ? totalCobroConsulta(mpCitaRef.current) : total}
        folio={mpCitaRef.current ? `CONS-${mpCitaRef.current.id}` : mpFolio}
        hint="El terminal recibe el monto; el cajero confirma en el Point; al aprobarse el pago se registra la operación y se imprime el ticket."
        onSuccess={async ()=>{
          setMpModal(false);
          const citaMp = mpCitaRef.current;
          mpCitaRef.current = null;
          if (citaMp) await cobrarConsulta(citaMp);
          else {
            const ro = recetaOrigenPendienteRef.current || "no_aplica";
            recetaOrigenPendienteRef.current = "no_aplica";
            await ejecutarCobrar(ro);
          }
        }}
        onCancel={()=>{ setMpModal(false); mpCitaRef.current = null; recetaOrigenPendienteRef.current = "no_aplica"; }}
      />

      {ticket&&<TicketPreviewModal
        open={!!ticket}
        venta={{id:ticket.id, folio:ticket.folio, total:ticket.total, created_at:new Date().toISOString(), metodo_pago:ticket.pay}}
        productos={ticket.items}
        cliente={ticket.cli}
        metodoPago={ticket.pay}
        config={config}
        promoMsg={promoTicket}
        onClose={()=>setTicket(null)}
        onNuevaVenta={()=>{ setTicket(null); setCart([]); setTel(""); setCli(null); }}
      />}
      

      {/* TAB: VENTA NORMAL */}
      {tab==="venta"&&(
        <>
        <div
          className={`farmax-pos-venta-grid${isMobilePos ? " farmax-pos-venta-narrow" : ""}`}
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
          <div className="farmax-pos-products-col" style={{ minWidth: 0 }}>
            {isMobilePos && (
            <div
              className="farmax-pos-venta-toolbar"
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
                  background: "linear-gradient(135deg,#0052CC,#0099e6)",
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
              <input ref={srchRef} className="farmax-pos-srch" value={srch} onChange={e=>setSrch(e.target.value)}
                data-tour="pos-buscador"
                onKeyDown={e=>{
                  if(e.key==="Enter"){
                    const raw = srch.trim();
                    const qN = normalizeForSearch(raw);
                    const exact = productos.find(p=>
                      (p.codigo_barras && String(p.codigo_barras).trim() === raw) ||
                      (p.sku && normalizeForSearch(p.sku) === qN)
                    );
                    if(exact){add(exact,false);setSrch("");e.preventDefault();}
                  }
                }}
                placeholder="🔍 Buscar por nombre o SKU · Enter para agregar"
                style={{flex:1,minWidth:0,boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.bg,color:C.text,fontSize:isMobilePos?16:13,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
              {!isMobilePos && (
              <button onClick={()=>setCartOpen(p=>!p)} style={{
                padding:"9px 14px",borderRadius:8,border:`1px solid ${C.border}`,
                background:cart.length?BRAND.primary+"18":"transparent",
                color:cart.length?BRAND.primary:C.textMid,
                fontWeight:700,fontSize:12,cursor:"pointer",whiteSpace:"nowrap",flexShrink:0,
              }}>🛒{cart.length>0?` (${cart.length})`:""} {cartOpen?"▶":"◀"}</button>
              )}
            </div>
            {favs.length>0&&(
              <div data-tour="pos-favoritos" style={{marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>⭐ Favoritos</div>
                <div style={{display:"flex",gap:6,flexWrap:"wrap"}}>
                  {productos.filter(p=>favs.includes(p.id)&&p.activo).map(p=>(
                    <button key={p.id} onClick={()=>add(p,false)}
                      style={{padding:"5px 10px",borderRadius:8,border:`1px solid ${C.amber}`,background:C.amberDim,color:"#92400e",fontSize:11,fontWeight:700,cursor:"pointer",maxWidth:130,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>
                      ⭐ {p.nombre.split(" ").slice(0,3).join(" ")}
                    </button>
                  ))}
                </div>
              </div>
            )}
            <div style={{display:"grid",gridTemplateColumns:`repeat(auto-fill,minmax(${isNarrow ? "min(100%, 132px)" : "140px"},1fr))`,gap:8}}>
              {fil.map(item=>{
                const posCardClick = (e)=>{
                  if(e.target.closest("button")) return;
                  if(item.stock===0&&(!item.venta_unidad||item.stock_unidades===0)){
                    showToast("Sin stock disponible.","warning"); return;
                  }
                  if(item.venta_unidad){
                    if(item.stock>0) add(item,false);
                    else if(item.stock_unidades>0) add(item,true);
                    else if(item.stock>0) abrirCaja(item);
                    else showToast("Sin stock disponible.","warning");
                  }else if(item.stock>0){
                    add(item,false);
                  }
                };
                return(
                <Box key={item.id} className="farmax-product-card"
                  onClick={posCardClick}
                  style={{padding:12,opacity:item.stock===0&&(!item.venta_unidad||item.stock_unidades===0)?.5:1}}>
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:3}}>
                    <div style={{color:C.textDim,fontSize:9,letterSpacing:1}}>{item.sku}</div>
                    <button type="button" onClick={e=>{e.stopPropagation();toggleFav(item.id);}} style={{background:"none",border:"none",cursor:"pointer",fontSize:12,padding:0,lineHeight:1}} title="Favorito">
                      {favs.includes(item.id)?"⭐":"☆"}
                    </button>
                  </div>
                  <div style={{color:C.text,fontSize:11,fontWeight:700,lineHeight:1.3,marginBottom:6,minHeight:28}}>{item.nombre}</div>
                  <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:6}}>
                    {item.requiere_receta&&<span style={{background:C.amber,color:"#fff",fontSize:9,fontWeight:800,borderRadius:4,padding:"2px 6px"}}>⚕ RX</span>}
                    {item.tipo==="generico"&&<Tag col={C.teal} sm>Gen</Tag>}
                  </div>
                  {item.venta_unidad?(
                    <div style={{display:"flex",flexDirection:"column",gap:4}}>
                      <button type="button"
                        disabled={item.stock===0}
                        onClick={e=>{e.stopPropagation();add(item,false);}}
                        style={{padding:"4px 6px",borderRadius:6,border:`1px solid ${C.blue}30`,background:"#eff6ff",color:C.blue,cursor:item.stock===0?"not-allowed":"pointer",fontSize:10,fontWeight:700,opacity:item.stock===0?.4:1}}>
                        📦 Caja {$(item.precio||item.precio)} · {item.stock} cajas
                      </button>
                      <button type="button"
                        disabled={item.stock_unidades===0&&item.stock===0}
                        onClick={e=>{e.stopPropagation();
                          if(item.stock_unidades>0){ add(item,true); }
                          else if(item.stock>0){ abrirCaja(item); }
                          else { showToast("Sin stock disponible.", "warning"); }
                        }}
                        style={{padding:"4px 6px",borderRadius:6,border:`1px solid ${C.green}30`,background:C.greenDim,color:C.greenDark,cursor:(item.stock_unidades===0&&item.stock===0)?"not-allowed":"pointer",fontSize:10,fontWeight:700,opacity:(item.stock_unidades===0&&item.stock===0)?.4:1}}>
                        💊 x1 {$(Math.ceil(item.precio_unidad||0))} · {item.stock_unidades} sueltas
                      </button>
                    </div>
                  ):(
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",pointerEvents:"none"}}>
                      <div>
                        {item.descuento_pct>0?(
                          <>
                            <span style={{color:C.textDim,fontSize:10,textDecoration:"line-through",display:"block"}}>{$(item.precio||item.precio)}</span>
                            <span style={{color:C.red,fontWeight:900,fontSize:15}}>{$(Math.round((item.precio||item.precio)*(1-item.descuento_pct/100)))}</span>
                            <span style={{background:C.red,color:"#fff",fontSize:8,fontWeight:700,borderRadius:4,padding:"1px 4px",marginLeft:4}}>-{item.descuento_pct}%</span>
                          </>
                        ):(
                          <span style={{color:C.blue,fontWeight:800,fontSize:15}}>{$(item.precio)}</span>
                        )}
                      </div>
                      <Tag col={item.stock===0?C.red:item.stock<item.stock_minimo?C.amber:C.green} sm>{item.stock===0?"Agotado":item.stock}</Tag>
                    </div>
                  )}
                </Box>
                );
              })}
            </div>
          </div>
          {/* Carrito: escritorio = columna; móvil = modal (barra compacta arriba). */}
          {!isMobilePos && cartOpen ? (
          <div
            id="farmax-pos-cart"
            className="farmax-pos-cart-col"
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
            className="farmax-pos-cart-sheet-root"
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
              className="farmax-pos-cart-sheet-panel"
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
                id="farmax-pos-cart"
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
            <strong>Operación:</strong> surte y marca listo (pick-up o envío según etiqueta). Pedidos marketplace / Uber Direct usarán <code style={{fontSize:11}}>logistics_meta</code> cuando apliques el patch SQL — ver <strong style={{color:C.text}}>docs/DELIVERY_MARKETPLACE_PREP.md</strong>.
          </div>
          {loading?<SkeletonTable rows={3} cols={4}/>:
           !pedOnline.length?<div style={{color:C.textMid,padding:40,textAlign:"center"}}>✓ Sin pedidos online pendientes</div>:
           pedOnline.map(p=>(
            <Box key={p.id} style={{padding: isNarrow ? 14 : 20,marginBottom:12,minWidth:0}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:12,flexWrap:"wrap",gap:10}}>
                <div>
                  <div style={{color:C.text,fontWeight:800,fontSize:15}}>Pedido #{p.id} — Online</div>
                  <div style={{display:"flex",gap:6,flexWrap:"wrap",marginTop:6}}>
                    <Tag col={p.tipo_entrega==="envio"?C.teal:C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
                    {resumenLogisticsMeta(p.logistics_meta) && (
                      <Tag col={C.purple} sm title={JSON.stringify(p.logistics_meta)}>{resumenLogisticsMeta(p.logistics_meta)}</Tag>
                    )}
                  </div>
                  <div style={{color:C.textMid,fontSize:12,marginTop:3}}>{p.clientes?.nombre} · {p.clientes?.telefono}</div>
                  {p.tipo_entrega==="envio"&&p.direccion&&(
                    <div style={{color:C.textDim,fontSize:11,marginTop:4,maxWidth:480,lineHeight:1.35}}>📍 {p.direccion}</div>
                  )}
                  <div style={{color:C.textDim,fontSize:11,marginTop:2}}>{new Date(p.created_at).toLocaleString("es-MX")}</div>
                </div>
                <div style={{textAlign:"right"}}>
                  <div style={{color:C.blue,fontWeight:900,fontSize:18}}>{$(p.total)}</div>
                  <Tag col={C.amber} sm>Pendiente</Tag>
                </div>
              </div>
              <div style={{background:C.bg,borderRadius:8,padding:"10px 14px",marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>Productos</div>
                {(p.pedido_items||[]).map((item,i)=>(
                  <div key={i} style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                    <span style={{color:C.text,fontSize:12}}>{item.productos?.nombre} ×{item.cantidad}</span>
                    <span style={{color:C.blue,fontSize:12,fontWeight:700}}>{$(item.precio_unitario*item.cantidad)}</span>
                  </div>
                ))}
              </div>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                <Btn onClick={()=>surtirOnline(p)} col={C.green} dis={guardando}>✓ Surtir y marcar listo</Btn>
                <Btn ol col={C.red} sm onClick={async()=>{
                  const tok = sessionStorage.getItem("farmax_session_token");
                  const { error } = await supabase.rpc("admin_cancelar_pedido", {
                    p_session_token: tok, p_pedido_id: p.id,
                  });
                  if (error) showToast("Error: "+error.message, "error");
                  setPedOn(x=>x.filter(z=>z.id!==p.id));
                }}>Cancelar</Btn>
              </div>
            </Box>
          ))}
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

          <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:10}}>💳 Cobrar en caja</div>
          <div style={{color:C.textMid,fontSize:12,marginBottom:14}}>Citas con consulta o consumibles pendientes de cobro (ventana de fechas cercana). Si pasaron 10 min del inicio sin pago, puedes usar <em>Cancelar (no asistió)</em> en la tarjeta.</div>

          {!consxCobrar.length?<div style={{color:C.textMid,padding:24,textAlign:"center"}}>✓ Nada pendiente de cobro en caja</div>:
           consxCobrar.map(cita=>{
            const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
            const yaPagoConsulta =
              cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
            const consumibles=(cita.consumibles_consulta||[]).filter(c=>!c.cobrado);
            const totalCons=consumibles.reduce((a,c)=>a+c.precio*c.cantidad,0);
            const totalCobro = (yaPagoConsulta ? 0 : precioBase) + totalCons;
            return(
              <Box key={cita.id} style={{padding: isNarrow ? 14 : 20,marginBottom:12,minWidth:0}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:12,flexWrap:"wrap",gap:10}}>
                  <div>
                    <div style={{display:"flex",alignItems:"center",gap:8,flexWrap:"wrap"}}>
                      <div style={{color:C.text,fontWeight:800,fontSize:15}}>Consulta — {cita.nombre}</div>
                      {citaPagoPendiente(cita) && <Tag col={C.amber} sm>Pendiente de pago</Tag>}
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
                  style={{width:"100%",boxSizing:"border-box",marginBottom:8}}
                  emptyMsg="Sin coincidencias · prueba más dígitos o el nombre"
                />
                {cli&&<div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:6,padding:"6px 10px",marginBottom:8}}><span style={{color:C.purple,fontSize:11,fontWeight:700}}>{cli.nombre} · {cli.puntos||0} pts</span></div>}
                <div style={{display:"flex",gap:6,marginBottom:10,flexWrap:"wrap"}}>
                  {[["efectivo","Efectivo"],["tarjeta","Tarjeta (Point)"]].map(([v,l])=>(
                    <button key={v} type="button" onClick={()=>setPay(v)} style={{padding:"4px 10px",borderRadius:20,border:`1px solid ${pay===v?C.green:C.border}`,background:pay===v?C.greenDim:"transparent",color:pay===v?C.green:C.textMid,fontSize:10,fontWeight:700,cursor:"pointer"}}>{l}</button>
                  ))}
                </div>
                <div style={{display:"flex",gap:8,flexWrap:"wrap",alignItems:"center"}}>
                  {pay==="efectivo" ? (
                    <Btn onClick={()=>cobrarConsulta(cita)} col={C.green} dis={guardando} style={{flex:"1 1 200px"}}>✅ Cobrar {$(totalCobro)}</Btn>
                  ) : (
                    <div style={{flex:"1 1 200px",minWidth:0}}>
                      <Btn
                        onClick={()=>{
                          setPay("tarjeta");
                          mpCitaRef.current = cita;
                          setMpFolio(`CONS-${cita.id}`);
                          setMpModal(true);
                        }}
                        col="#009ee3"
                        dis={guardando||totalCobro<=0}
                        full
                      >💳 Cobrar con tarjeta (terminal Point)</Btn>
                      <div style={{color:C.textDim,fontSize:10,marginTop:8,lineHeight:1.4}}>
                        Mismo flujo que en venta: se espera la aprobación en el Point; luego se marca pagada la consulta y se imprime el ticket.
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
        </div>
      )}
      <OnboardingTour ref={posTourRef} tourId="pos" usuario={usuario} showFab={!isMobilePos} />
    </div>
  );
}
