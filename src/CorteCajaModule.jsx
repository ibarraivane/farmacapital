import { useState, useEffect, useCallback, useRef } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import OnboardingTour from "./components/OnboardingTour";
import { TURNOS, TURNOS_LISTA, rangoTurno, inferirTurno, turnoDePerfil } from "./constants/turnos";
import { esVendedor, fetchSesionCajaAbierta, fetchJornadaHoy } from "./utils/cajaSesion";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { GRID_STACK_2COL } from "./constants/layout";
import {
  snapshotFromCorte,
  snapshotFromHistorialRow,
  printCorteTicket,
  printCorteHojaA4,
  corteTicketPdfBlob,
  uploadCorteTicketPdf,
  abrirOCrearTicketCorte,
  cargarVentasDetalleTurno,
} from "./utils/corteTicket";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const fmt  = (n) => `$${parseFloat(n||0).toFixed(2)}`;

// Billetes y monedas en circulación. Contar por denominación obliga a contar
// de verdad, en vez de teclear una cifra global de memoria.
const DENOMINACIONES = [1000, 500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5];

const mkInputStyle = (C) => ({
  width: "100%",
  padding: "9px 12px",
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  background: "#ffffff",
  color: C.text,
  WebkitTextFillColor: C.text,
  caretColor: C.text,
  colorScheme: "light",
  fontSize: 13,
  outline: "none",
  boxSizing: "border-box",
});
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, marginBottom:4, display:"block", letterSpacing:.5 });
const mkBtnSecondary = (C) => ({ padding:"10px 22px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:13, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });

const getRango = (turno) => {
  const { inicio, fin } = rangoTurno(new Date(), turno);
  return { inicio: inicio.toISOString(), fin: fin.toISOString() };
};

const getRangoFiltro = (filtro) => {
  const hoy = new Date();
  const y = hoy.getFullYear(), mo = hoy.getMonth(), d = hoy.getDate();
  if (filtro === "hoy")    return { desde: new Date(y,mo,d,0,0,0).toISOString(),  hasta: new Date(y,mo,d,23,59,59).toISOString() };
  if (filtro === "semana") { const l=new Date(hoy); l.setDate(d-hoy.getDay()); l.setHours(0,0,0); return { desde:l.toISOString(), hasta:hoy.toISOString() }; }
  if (filtro === "mes")    return { desde: new Date(y,mo,1).toISOString(), hasta: hoy.toISOString() };
  return null;
};

export default function CorteCajaModule({usuario }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 900px)");
  const inputStyle = { ...mkInputStyle(C), fontSize: isMobile ? 16 : 13 };
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const [tab, setTab] = useState("nuevo");

  // Nuevo corte
  const turnoPerfil = turnoDePerfil(usuario);
  const vendedorFijo = esVendedor(usuario);
  const [turno,              setTurno]   = useState(() => turnoDePerfil(usuario) || inferirTurno());
  const [efectivo_declarado, setEfDec]   = useState("");
  const [tarjeta,            setTarjeta] = useState("");
  const [mercadopago,        setMp]      = useState("");
  const [notas,              setNotas]   = useState("");
  const [saving,             setSaving]  = useState(false);
  const [resumenServicios,   setResumenServicios] = useState(null);
  const [fondo,              setFondo]   = useState("");
  const [contadoPor,         setContadoPor] = useState("");
  const [denoms,             setDenoms]  = useState({});
  const [sesionAbierta,      setSesionAbierta] = useState(null);
  const [jornada,            setJornada] = useState(null);
  const [corteHoy,           setCorteHoy] = useState(null);
  const [anulando,           setAnulando] = useState(false);
  const [electronicosError,  setElectronicosError] = useState(null);
  const [desgloseTarjeta,    setDesgloseTarjeta]   = useState(null);

  // El corte es a ciegas: mientras se captura no se muestra ni lo que el
  // sistema espera ni la diferencia. Un conteo que se puede copiar deja de ser
  // un conteo. `resultado` se llena hasta que la base responde al guardar.
  const [resultado,   setResultado]   = useState(null);
  const [zTransac,    setZTransac]    = useState(null);
  const [cargandoZ,   setCargandoZ]   = useState(false);

  // Historial
  const [cortes,      setCortes]      = useState([]);
  const [loadingHist, setLoadingHist] = useState(false);
  const [filtroTurno, setFiltroTurno] = useState("todos");
  const [filtroFecha, setFiltroFecha] = useState("todos");
  const [ticketAbriendo, setTicketAbriendo] = useState(null);

  // Calculados
  const totalDenoms = DENOMINACIONES.reduce(
    (a,d) => a + d * (parseInt(denoms[d],10) || 0), 0);
  const usaDenoms   = DENOMINACIONES.some(d => (parseInt(denoms[d],10) || 0) > 0);
  // Si contó por denominación, ese total manda: evita que el desglose y la
  // cifra global se contradigan.
  const efDec   = usaDenoms ? totalDenoms : parseFloat(efectivo_declarado||0);
  const fondoNum= parseFloat(fondo||0);
  const tar     = parseFloat(tarjeta||0);
  const mp      = parseFloat(mercadopago||0);
  // El fondo no es venta, por eso se descuenta del total del turno.
  const total_general = (efDec - fondoNum) + tar + mp;
  // Un vendedor sólo cierra la caja que abrió. Antes bastaba con tener turno
  // en el perfil, y así se guardó el corte fantasma del 24-ago a las 15:19:
  // cerró un turno que nadie había abierto y dejó a Erika fuera siete horas.
  const puedeGuardar  = (usaDenoms || efectivo_declarado !== "")
    && (!vendedorFijo || !!sesionAbierta)
    && !corteHoy;

  // Sólo se muestran tarjeta y MercadoPago. El efectivo esperado NO se pide:
  // si viajara al navegador, bastaría con abrir la pestaña de red para verlo
  // antes de declarar, y el conteo a ciegas dejaría de serlo. Lo calcula la
  // base al guardar.
  //
  // Estas cifras son informativas: quien manda es lo que recalcula
  // registrar_corte_caja en el momento de guardar. Antes se guardaba este
  // valor tal cual, y como se pedía al ABRIR la pantalla, toda venta con
  // tarjeta hecha mientras el cajero contaba el cajón se perdía.
  const fetchTotalesElectronicos = useCallback(async () => {
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data, error } = await supabase.rpc("empleado_totales_electronicos_turno", {
        p_session_token: tok,
        p_turno: turno,
        p_fecha: new Date().toLocaleDateString("sv-SE"),
      });
      // Un fallo silencioso aquí dejaba tarjeta en $0.00 sin que nadie
      // se enterara, y así quedaba guardado el corte.
      if (error) {
        setElectronicosError(error.message || "No se pudieron leer los cobros electrónicos.");
        return;
      }
      setElectronicosError(null);
      if (data?.tarjeta != null)     setTarjeta(String(data.tarjeta));
      if (data?.mercadopago != null) setMp(String(data.mercadopago));
      setDesgloseTarjeta(
        data?.tarjeta_servicios != null || data?.tarjeta_pedidos != null
          ? { pedidos: data.tarjeta_pedidos, servicios: data.tarjeta_servicios }
          : null
      );
    } catch(e) {
      console.error("[CorteCaja]", e);
      setElectronicosError("No se pudieron leer los cobros electrónicos.");
    }
  }, [turno]);

  useEffect(() => { fetchTotalesElectronicos(); }, [fetchTotalesElectronicos]);

  // Se refrescan justo antes de guardar para que lo que ve el cajero coincida
  // con lo que va a quedar registrado. Aun así, el número que se guarda lo
  // recalcula la base: esto es sólo para que la pantalla no mienta.
  useEffect(() => {
    if (resultado) return;
    const id = setInterval(fetchTotalesElectronicos, 60000);
    return () => clearInterval(id);
  }, [fetchTotalesElectronicos, resultado]);

  useEffect(() => {
    if (sesionAbierta?.turno) return;
    if (turnoPerfil) setTurno(turnoPerfil);
  }, [turnoPerfil, sesionAbierta]);

  useEffect(() => {
    (async () => {
      const [{ sesion }, { jornada: j }] = await Promise.all([
        fetchSesionCajaAbierta(),
        fetchJornadaHoy(),
      ]);
      if (j) setJornada(j);
      if (sesion) {
        setSesionAbierta(sesion);
        if (sesion.turno) setTurno(sesion.turno);
        if (sesion.fondo_contado != null) setFondo(String(sesion.fondo_contado));
        return;
      }
      if (j?.turno_abrir) setTurno(j.turno_abrir);
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data } = await supabase.rpc("empleado_ultimo_fondo_caja", { p_session_token: tok });
      if (data?.fondo > 0) setFondo(String(data.fondo));
    })();
  }, []);

  const fetchResumenServicios = useCallback(async () => {
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { inicio, fin } = getRango(turno);
      const { data, error } = tok
        ? await supabase.rpc("empleado_resumen_pagos_servicio_rango", {
            p_session_token: tok,
            p_desde: inicio,
            p_hasta: fin,
          })
        : { data: null, error: null };
      if (!error && data) setResumenServicios(data);
    } catch (e) {
      console.error("[CorteCaja servicios]", e);
    }
  }, [turno]);

  useEffect(() => { fetchResumenServicios(); }, [fetchResumenServicios]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data } = await supabase.rpc("empleado_corte_turno_en_fecha", {
        p_session_token: tok,
        p_fecha: new Date().toLocaleDateString("sv-SE"),
        p_turno: turno,
      });
      if (!cancelled) setCorteHoy(data?.existe ? data : null);
    })();
    return () => { cancelled = true; };
  }, [turno]);

  // Gerencia puede deshacer un corte del mismo día. Sin esto, un clic
  // equivocado cierra el turno de alguien hasta mañana y sólo se arregla
  // entrando a Supabase: el 24-ago costó siete horas de caja parada.
  const puedeAnular = ["admin", "gerente"].includes(usuario?.rol || "");

  const anularCorte = async () => {
    if (!corteHoy?.id) return;
    const motivo = window.prompt(
      `Vas a anular el corte #${corteHoy.id} (${TURNOS[turno]?.label || turno}).\n` +
      "La caja se reabre y quien lo hizo puede volver a su turno hoy.\n\n" +
      "¿Por qué se anula? Queda en la bitácora."
    );
    if (motivo === null) return;
    if (!motivo.trim()) {
      showToast("Hace falta el motivo para anular.", "warning");
      return;
    }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada. Entra de nuevo.", "error"); return; }
    setAnulando(true);
    const { data, error } = await supabase.rpc("anular_corte_caja", {
      p_session_token: tok,
      p_corte_id: corteHoy.id,
      p_motivo: motivo.trim(),
    });
    setAnulando(false);
    if (error) {
      showToast(
        /function .*anular_corte_caja/i.test(error.message || "")
          ? "Falta actualizar la base. Ejecuta sql/patch_caja_cadena_continua_20260824.sql en Supabase."
          : "No se pudo anular: " + (error.message || ""),
        "error"
      );
      return;
    }
    if (data?.success === false) {
      showToast(data.error || "No se pudo anular el corte.", "error");
      return;
    }
    setCorteHoy(null);
    setResultado(null);
    showToast(data?.mensaje || "Corte anulado.", "success");
    fetchTotalesElectronicos();
  };

  const fetchCortes = useCallback(async () => {
    setLoadingHist(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const rango = getRangoFiltro(filtroFecha);
    const fd = rango ? rango.desde.slice(0, 10) : null;
    const fh = rango ? rango.hasta.slice(0, 10) : null;
    const { data: rows, error } = tok
      ? await supabase.rpc("empleado_listar_cortes_caja", {
          p_session_token: tok,
          p_limite: 30,
          p_fecha_desde: fd,
          p_fecha_hasta: fh,
          p_turno: filtroTurno,
        })
      : { data: [], error: null };
    if (!error) setCortes(Array.isArray(rows) ? rows : []);
    setLoadingHist(false);
  }, [filtroFecha, filtroTurno]);

  useEffect(() => { if (tab==="historial") fetchCortes(); }, [tab, fetchCortes]);

  const [revisandoDif, setRevisandoDif] = useState(null);
  const [diferenciasRevisadas, setDiferenciasRevisadas] = useState(() => new Set());

  const marcarDiferenciaEnterada = async (corteId) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada. Inicia sesión de nuevo.", "warning");
      return;
    }
    setRevisandoDif(corteId);
    try {
      const { error } = await supabase.rpc("empleado_marcar_corte_diferencia_revisada", {
        p_session_token: tok,
        p_corte_id: Number(corteId),
      });
      if (error) throw error;
      setDiferenciasRevisadas((prev) => new Set(prev).add(Number(corteId)));
      showToast("Diferencia marcada como enterada — ya no cuenta en el badge.", "success");
      fetchCortes();
    } catch (e) {
      showToast("No se pudo marcar: " + (e.message || e), "error");
    }
    setRevisandoDif(null);
  };

  const fetchVentasDeCorte = async (corte) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) throw new Error("Sesión expirada. Inicia sesión de nuevo.");
    const fecha = corte.fecha ? new Date(corte.fecha) : new Date();
    const { inicio, fin } = rangoTurno(fecha, corte.turno);
    return cargarVentasDetalleTurno(supabase, tok, inicio.toISOString(), fin.toISOString());
  };

  const abrirTicketHistorial = async (c) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada. Inicia sesión de nuevo.", "warning"); return; }
    setTicketAbriendo(c.id);
    try {
      await abrirOCrearTicketCorte({
        corte: c,
        sessionToken: tok,
        fetchVentas: fetchVentasDeCorte,
      });
    } catch (e) {
      showToast("No se pudo abrir el ticket: " + (e.message || e), "error");
    } finally {
      setTicketAbriendo(null);
    }
  };

  const imprimirEpsonHistorial = async (c) => {
    setTicketAbriendo(c.id);
    try {
      const ventas = await fetchVentasDeCorte(c);
      if (!printCorteTicket(snapshotFromHistorialRow({ ...c, ventas }))) {
        showToast("El navegador bloqueó la ventana de impresión", "warning");
      }
    } catch (e) {
      showToast("No se pudo imprimir: " + (e.message || e), "error");
    } finally {
      setTicketAbriendo(null);
    }
  };

  // P3.4: Función para verificar si hay turno activo (usada desde POS)
  // Esta función se puede llamar externamente via ref o contexto
  const verificarTurnoActivo = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const hoy = new Date().toLocaleDateString("sv-SE");
    const { data } = tok
      ? await supabase.rpc("empleado_corte_turno_en_fecha", {
          p_session_token: tok,
          p_fecha: hoy,
          p_turno: turno,
        })
      : { data: null };
    return !!(data?.existe);
  };

  // Detalle de las ventas del turno. Se carga DESPUÉS de guardar: si estuviera
  // disponible antes, el cajero podría sumar las ventas en efectivo y deducir
  // el número que se supone que debe descubrir contando.
  const cargarReporteZ = useCallback(async () => {
    setCargandoZ(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { inicio, fin } = getRango(turno);
      const ventas = tok
        ? await cargarVentasDetalleTurno(supabase, tok, inicio, fin)
        : [];
      setZTransac(ventas);
    } catch (e) {
      console.error("[CorteCaja Z]", e);
      setZTransac([]);
    }
    setCargandoZ(false);
  }, [turno]);

  const nuevoCorte = () => {
    setResultado(null); setZTransac(null);
    setEfDec(""); setNotas(""); setDenoms({}); setContadoPor("");
    fetchTotalesElectronicos();
  };

  const guardarCorte = async () => {
    if (vendedorFijo && !sesionAbierta) {
      showToast(
        turnoPerfil
          ? "No tienes caja abierta, así que no hay turno que cortar."
          : "RH debe asignarte un turno antes de cerrar caja.",
        "warning"
      );
      return;
    }
    if (corteHoy) {
      showToast("Ya hay un corte de este turno hoy. No se guarda otro.", "warning");
      return;
    }
    if (!puedeGuardar) { showToast("Captura el efectivo contado", "warning"); return; }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { alert("Sesión expirada. Inicia sesión de nuevo."); return; }
    setSaving(true);
    const denomsLimpios = Object.fromEntries(
      DENOMINACIONES.map(d => [d, parseInt(denoms[d],10) || 0]).filter(([,n]) => n > 0));
    const pedirCorte = (confirmar) => supabase.rpc("registrar_corte_caja", {
      p_session_token: tok,
      p_turno: turno,
      p_efectivo_declarado: efDec,
      p_efectivo_sistema: 0,   // lo calcula la base; el cliente no lo conoce
      p_tarjeta: tar,
      p_mercadopago: mp,
      p_diferencia: 0,      // los calcula la base; aquí no se conocen todavía
      p_total_general: 0,
      p_notas: notas.trim() || null,
      p_fondo_inicial: fondoNum,
      p_contado_por: contadoPor.trim() || null,
      p_denominaciones: usaDenoms ? denomsLimpios : null,
      p_confirmar: confirmar,
    });

    let { data, error } = await pedirCorte(false);

    // El corte es de ida: cerrado el turno, no se reabre en el día. Cuando la
    // base detecta que es casi seguro un clic equivocado — caja recién
    // abierta, o sin una sola venta en el periodo — no guarda: devuelve
    // confirmable y deja que la persona decida con el dato enfrente.
    if (!error && data?.success === false && data?.confirmable) {
      if (!window.confirm(data.error)) {
        setSaving(false);
        return;
      }
      ({ data, error } = await pedirCorte(true));
    }

    setSaving(false);
    if (error) {
      const raw = error.message || "";
      const msg = /empleado_id_fkey|foreign key/i.test(raw)
        ? "Falta actualizar la base. Ejecuta sql/patch_cortes_caja_fk_usuarios.sql en Supabase."
        : /ya existe un corte/i.test(raw)
          ? "Ya existe un corte de este turno hoy. No se puede guardar otro."
          : "Error al guardar corte: " + raw;
      showToast(msg, "error");
      return;
    }
    if (data?.success === false) {
      showToast(data.error || "No se pudo guardar el corte.", "error");
      return;
    }
    setCorteHoy({ existe: true, id: data?.corte_id });

    // Recién ahora se destapa: el cajero ya se comprometió con su conteo.
    // El RPC a veces no devuelve tarjeta/MP; se conservan los del turno para el PDF.
    setResultado({
      ...data,
      tarjeta: data?.tarjeta ?? tar,
      mercadopago: data?.mercadopago ?? mp,
      denominaciones: usaDenoms ? denomsLimpios : data?.denominaciones,
    });
    cargarReporteZ();
    try {
      const { data: ns } = await supabase.rpc("empleado_marcar_citas_no_show_corte", {
        p_session_token: tok,
      });
      const n = Number(ns?.marcadas || 0);
      if (n > 0) {
        showToast(
          n === 1
            ? "1 consulta sin pago se marcó como no se presentó."
            : `${n} consultas sin pago se marcaron como no se presentó.`,
          "info"
        );
      }
    } catch {
      /* Si falta el SQL, el corte igual ya quedó guardado. */
    }
  };

  // La diferencia sólo existe una vez que la base respondió al guardar.
  const dif    = parseFloat(resultado?.diferencia ?? 0);
  const difCol = dif===0 ? C.green : dif>0 ? C.amber : C.red;
  const difTxt = dif===0 ? "✓ Cuadrado" : dif>0 ? `▲ Sobrante: +${fmt(dif)}` : `▼ Faltante: ${fmt(dif)}`;
  const difBg  = dif===0 ? C.greenDim : dif>0 ? C.amberDim : C.redDim;

  // El efectivo del resumen es VENTA, no el contenido del cajón: hay que
  // restar el fondo, que es cambio que ya estaba ahí. Sumar efectivo_declarado
  // a secas inflaba el tile con la suma de todos los fondos y dejaba de cuadrar
  // con el gran total, que sí descuenta el fondo (total_general es GENERATED).
  const sumFondo = cortes.reduce((a,c)=>a+parseFloat(c.fondo_inicial||0),0);
  const sumEf  = cortes.reduce(
    (a,c)=>a+(parseFloat(c.efectivo_declarado||0)-parseFloat(c.fondo_inicial||0)),0);
  const sumTar = cortes.reduce((a,c)=>a+parseFloat(c.tarjeta||0),0);
  const sumMp  = cortes.reduce((a,c)=>a+parseFloat(c.mercadopago||0),0);
  const sumTot = cortes.reduce((a,c)=>a+parseFloat(c.total_general||0),0);

  return (
    <div style={{padding:isMobile?0:24,background:C.bg,minHeight:"100dvh",fontFamily:"var(--fc-body)",maxWidth:"100%",colorScheme:"light"}}>

      <div style={{marginBottom:24}}>
        <h1 className="fc-page-hero" style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>⊞ Corte de Caja</h1>
        <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Control de turnos · FarmaCapital</p>
      </div>

      {/* Tabs */}
      <div style={{display:"flex",gap:4,marginBottom:24,borderBottom:`1px solid ${C.border}`}}>
        {(esVendedor(usuario) ? [["nuevo","➕ Cerrar turno"]] : [["nuevo","➕ Nuevo Corte"],["historial","📋 Historial"]]).map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"9px 20px",border:"none",cursor:"pointer",fontWeight:700,fontSize:13,
            borderRadius:"8px 8px 0 0", background:tab===id?C.card:"transparent",
            color:tab===id?C.blue:C.textMid,
            borderBottom:tab===id?`2px solid ${C.blue}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {/* ══ NUEVO CORTE ══ */}
      {tab==="nuevo" && resultado && (
        <ResultadoCorte
          C={C} resultado={resultado} turno={turno} dif={dif} difCol={difCol} difBg={difBg}
          difTxt={difTxt} zTransac={zTransac} cargandoZ={cargandoZ}
          btnSecondary={btnSecondary} onNuevo={nuevoCorte} cajero={usuario?.nombre}
          denominaciones={resultado?.denominaciones}
          permitirOtro={!esVendedor(usuario)}
          cierreHint={jornada?.cubre_ambos
            ? "Hoy cubres ambos. Abre el siguiente turno en el POS."
            : "Turno cerrado. El otro turno lo abre tu compañera."}
        />
      )}

      {tab==="nuevo" && !resultado && (
        <div>
          {!sesionAbierta && esVendedor(usuario) && (
            <div style={{
              marginBottom: 16, padding: "12px 14px", borderRadius: 10,
              background: C.amberDim, border: `1px solid ${C.amber}50`,
              color: C.text, fontSize: 13, lineHeight: 1.45,
            }}>
              Aún no hay caja abierta en este turno. Ábrela en el POS (conteo de billetes) para que la hora de entrada y el fondo queden registrados. Si cierras ahora, el fondo se captura aquí y la hora de apertura será la del turno, no la real.
            </div>
          )}
          {/* Turno: el vendedor no elige; lo asigna RH. Admin sí puede cubrir. */}
          <div data-tour="caja-turno" style={{marginBottom:24}}>
            <label style={labelStyle}>TURNO</label>
            {vendedorFijo ? (
              <div style={{
                padding: "14px 18px",
                borderRadius: 10,
                border: `2px solid ${TURNOS[turno] ? C.blue : C.amber}`,
                background: TURNOS[turno] ? C.blueDim : C.amberDim,
                color: TURNOS[turno] ? C.blue : C.text,
              }}>
                <div style={{fontWeight:800, fontSize:14}}>
                  {TURNOS[turno]
                    ? `${TURNOS[turno].emoji} ${TURNOS[turno].label}`
                    : "Sin turno asignado"}
                </div>
                <div style={{fontSize:11, marginTop:2, opacity:.75}}>
                  {TURNOS[turno]
                    ? (jornada?.cubre_ambos
                      ? `${TURNOS[turno].horario} · hoy cubres ambos; cierra este y abre el siguiente.`
                      : `${TURNOS[turno].horario} · lo asigna RH; no puedes cerrar el otro turno.`)
                    : "Pide a RH que te asigne matutino o vespertino."}
                </div>
              </div>
            ) : (
            <div style={{display:"flex",gap:10,flexWrap:"wrap"}}>
              {TURNOS_LISTA.map(val=>[val,`${TURNOS[val].emoji} ${TURNOS[val].label}`,TURNOS[val].horario]).map(([val,label,hora])=>(
                <button key={val} type="button" onClick={()=>!sesionAbierta && setTurno(val)} style={{
                  flex: isMobile ? "1 1 140px" : 1,padding:isMobile?"12px 14px":"14px 20px",borderRadius:10,cursor:sesionAbierta?"default":"pointer",textAlign:"left",
                  minWidth: isMobile ? 0 : undefined,
                  border:turno===val?`2px solid ${C.blue}`:`2px solid ${C.border}`,
                  background:turno===val?C.blueDim:C.card,
                  color:turno===val?C.blue:C.textMid,transition:"all .15s",
                  opacity: sesionAbierta && turno!==val ? 0.5 : 1,
                }}>
                  <div style={{fontWeight:800,fontSize:14}}>{label}</div>
                  <div style={{fontSize:11,marginTop:2,opacity:.7}}>{hora}</div>
                </button>
              ))}
            </div>
            )}
          </div>

          {corteHoy && (
            <div style={{
              marginBottom: 16, padding: "12px 14px", borderRadius: 10,
              background: C.amberDim, border: `1px solid ${C.amber}50`,
              color: C.text, fontSize: 13, lineHeight: 1.45,
            }}>
              Ya hay un corte {TURNOS[turno]?.label || turno} de hoy. No se
              guarda otro.
              {jornada?.cubre_ambos
                ? " Si hoy cubres ambos, abre el siguiente turno en el POS."
                : " Mary cierra el matutino y Erika el vespertino."}
              {esVendedor(usuario)
                ? ""
                : <> Ábrelo en <button type="button" onClick={() => setTab("historial")}
                    style={{ background: "none", border: "none", padding: 0, color: C.blue, fontWeight: 800, cursor: "pointer", fontSize: "inherit" }}>
                    Historial
                  </button>.</>}
              {puedeAnular && corteHoy?.id && (
                <div style={{ marginTop: 10, paddingTop: 10, borderTop: `1px solid ${C.amber}40` }}>
                  <div style={{ color: C.textMid, fontSize: 12, marginBottom: 8 }}>
                    ¿Se guardó por error? Anularlo reabre la caja y quien lo hizo
                    vuelve a su turno hoy mismo.
                  </div>
                  <button
                    type="button"
                    onClick={anularCorte}
                    disabled={anulando}
                    style={{
                      padding: "8px 16px", borderRadius: 8,
                      border: `1px solid ${C.border}`, background: C.card,
                      color: C.text, fontSize: 12, fontWeight: 800,
                      cursor: anulando ? "default" : "pointer",
                      opacity: anulando ? 0.6 : 1,
                    }}
                  >
                    {anulando ? "Anulando…" : `Anular corte #${corteHoy.id}`}
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Grid */}
          <div style={{display:"grid",gridTemplateColumns:GRID_STACK_2COL,gap:16,minWidth:0}}>

            {/* Inputs */}
            <div data-tour="caja-declarado" style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:isMobile?14:20,minWidth:0}}>
              <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:16}}>💵 Ingresos del turno</div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>FONDO INICIAL</label>
                <input type="number" value={fondo} onChange={e=>!sesionAbierta && setFondo(e.target.value)}
                  placeholder="0.00" readOnly={!!sesionAbierta}
                  style={{...inputStyle, cursor: sesionAbierta ? "not-allowed" : undefined}}/>
                <div style={{color:C.textDim,fontSize:10,marginTop:4}}>
                  {sesionAbierta
                    ? `El cambio con el que abriste a las ${new Date(sesionAbierta.abierta_at).toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" })}. Ya no se edita.`
                    : "El cambio con el que abrió el turno. Cuéntalo también: va incluido abajo."}
                </div>
              </div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>CONTEO POR DENOMINACIÓN</label>
                <div style={{display:"grid",gridTemplateColumns:isMobile?"1fr":"repeat(2,1fr)",gap:6}}>
                  {DENOMINACIONES.map(d=>{
                    const piezas = parseInt(denoms[d],10) || 0;
                    return (
                      <div key={d} style={{display:"flex",alignItems:"center",gap:8,minWidth:0}}>
                        <span style={{color:C.textMid,fontSize:12,fontWeight:700,width:52,flexShrink:0,textAlign:"right"}}>
                          {d>=1?`$${d}`:"$0.50"}
                        </span>
                        <input type="number" min="0" inputMode="numeric" value={denoms[d] ?? ""}
                          onChange={e=>setDenoms(p=>({...p,[d]:e.target.value}))}
                          placeholder="0"
                          style={{...inputStyle,padding:"8px 10px",fontSize:isMobile?16:12,width:72,flex:"0 0 72px"}}/>
                        <span style={{color:piezas?C.text:C.textDim,fontSize:12,flex:1,minWidth:0}}>
                          {piezas?fmt(d*piezas):""}
                        </span>
                      </div>
                    );
                  })}
                </div>
              </div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>EFECTIVO CONTADO</label>
                <input type="number" value={usaDenoms?totalDenoms.toFixed(2):efectivo_declarado}
                  onChange={e=>setEfDec(e.target.value)} readOnly={usaDenoms}
                  placeholder="0.00"
                  style={{...inputStyle,fontSize:18,fontWeight:700,color:C.green,
                          WebkitTextFillColor:C.green,cursor:usaDenoms?"not-allowed":undefined}}/>
                <div style={{color:C.textDim,fontSize:10,marginTop:4}}>
                  {usaDenoms
                    ? "Sale de tu conteo por denominación. Borra el desglose para capturarlo a mano."
                    : "Todo lo que hay en el cajón, fondo incluido."}
                </div>
              </div>

              {/* Tarjeta y MP no se cuentan a mano: los liquida el banco y los
                  calcula la base al guardar. Se muestran para que el cajero
                  sepa qué va a quedar registrado, pero no se teclean. */}
              <div style={{marginBottom:14}}>
                <label style={labelStyle}>TARJETA</label>
                <input type="number" value={tarjeta} readOnly placeholder="0.00"
                  style={{...inputStyle, cursor:"not-allowed", background:C.bg}}/>
                <div style={{color:C.textDim,fontSize:10,marginTop:4,lineHeight:1.45}}>
                  {desgloseTarjeta && (desgloseTarjeta.servicios > 0)
                    ? `Ventas ${fmt(desgloseTarjeta.pedidos)} + pagos de servicio ${fmt(desgloseTarjeta.servicios)}. Se vuelve a calcular al guardar.`
                    : "Lo calcula el sistema al guardar, con lo cobrado hasta ese momento."}
                </div>
              </div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>MERCADOPAGO</label>
                <input type="number" value={mercadopago} readOnly placeholder="0.00"
                  style={{...inputStyle, cursor:"not-allowed", background:C.bg}}/>
                <div style={{color:C.textDim,fontSize:10,marginTop:4,lineHeight:1.45}}>
                  Sólo pedidos de la tienda web. Los cobros con la terminal Point
                  se registran como tarjeta.
                </div>
              </div>

              {electronicosError && (
                <div style={{
                  marginBottom:14, padding:"10px 12px", borderRadius:8,
                  background:C.redDim, border:`1px solid ${C.red}40`,
                  color:C.text, fontSize:12, lineHeight:1.45,
                }}>
                  No se pudieron leer los cobros con tarjeta ({electronicosError}).
                  Puedes cerrar el corte de todas formas: la base los recalcula al
                  guardar. Verifica el resultado contra la terminal.
                </div>
              )}

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>CONTADO POR (OPCIONAL)</label>
                <input type="text" value={contadoPor} onChange={e=>setContadoPor(e.target.value)}
                  placeholder="Quién contó el dinero, si no fuiste tú" style={inputStyle}/>
              </div>

              <div>
                <label style={labelStyle}>NOTAS</label>
                <textarea value={notas} onChange={e=>setNotas(e.target.value)}
                  placeholder="Observaciones del turno, incidencias, etc."
                  rows={3} style={{...inputStyle,resize:"vertical",lineHeight:1.5}}/>
              </div>
            </div>

            {/* Resumen */}
            <div style={{display:"flex",flexDirection:"column",gap:12}}>

              <div style={{background:C.blueDim,borderRadius:12,border:`1px solid ${C.blue}30`,padding:20}}>
                <div style={{color:C.blue,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:8}}>
                  🔒 CONTEO A CIEGAS
                </div>
                <div style={{color:C.text,fontSize:12.5,lineHeight:1.55}}>
                  Cuenta el cajón y captura lo que encuentres. Lo que el sistema
                  espera y la diferencia se destapan <strong>al guardar</strong>.
                </div>
                <div style={{color:C.textDim,fontSize:11,marginTop:8,lineHeight:1.5}}>
                  Si vieras el número esperado antes, bastaría con copiarlo y el
                  conteo dejaría de detectar faltantes.
                </div>
              </div>

              {resumenServicios?.operaciones > 0 && (
                <div style={{background:C.amberDim,borderRadius:12,border:`1px solid ${C.amber}35`,padding:16}}>
                  <div style={{color:C.amber,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:6}}>PAGOS DE SERVICIO (POS)</div>
                  <div style={{color:C.text,fontSize:12,lineHeight:1.45}}>
                    {resumenServicios.operaciones} operación(es) · cobrado {fmt(resumenServicios.total_cobrado)} · recargo farmacia {fmt(resumenServicios.total_comision)}
                    {resumenServicios.total_compensacion_mp != null && (
                      <> · compensación MP {fmt(resumenServicios.total_compensacion_mp)} · utilidad {fmt(resumenServicios.total_utilidad ?? (Number(resumenServicios.total_comision || 0) + Number(resumenServicios.total_compensacion_mp || 0)))}</>
                    )}
                  </div>
                  <div style={{color:C.textDim,fontSize:10,marginTop:6,lineHeight:1.45}}>
                    Efectivo {fmt(resumenServicios.efectivo)} · Tarjeta Point {fmt(resumenServicios.tarjeta)} — ya entran solos al corte, no los captures a mano. La compensación MP (1%) vive en el saldo de Mercado Pago, no en el cajón. El efectivo de recargas hay que reponerlo en ese saldo.
                  </div>
                </div>
              )}

              <div data-tour="caja-diferencia" style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
                <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:12}}>LO QUE CAPTURASTE</div>
                {[["Efectivo contado",efDec,C.green],
                  ["— del cual, fondo",fondoNum,C.textMid],
                  ["Tarjeta",tar,C.blue],
                  ["MercadoPago",mp,C.amber]].map(([lbl,val,col])=>(
                  <div key={lbl} style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:8}}>
                    <span style={{color:C.textMid,fontSize:12}}>{lbl}</span>
                    <span style={{color:col,fontWeight:700,fontSize:13}}>{fmt(val)}</span>
                  </div>
                ))}
                <div style={{borderTop:`1px solid ${C.border}`,marginTop:8,paddingTop:10,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                  <span style={{color:C.text,fontWeight:800,fontSize:13}}>TU DECLARACIÓN</span>
                  <span style={{fontWeight:800,fontSize:22,background:BRAND.gradient,WebkitBackgroundClip:"text",WebkitTextFillColor:"transparent"}}>
                    {fmt(total_general)}
                  </span>
                </div>
                <div style={{color:C.textDim,fontSize:10,marginTop:6,lineHeight:1.45}}>
                  Sin el fondo, que no es venta. Tarjeta y MercadoPago los
                  recalcula la base al guardar, así que el total definitivo
                  puede subir si entra un cobro mientras cuentas.
                </div>
              </div>

              <button data-tour="caja-guardar" onClick={guardarCorte} disabled={saving||!puedeGuardar} style={{
                width:"100%",padding:"14px",borderRadius:10,border:"none",
                cursor:saving||!puedeGuardar?"not-allowed":"pointer",
                background:saving||!puedeGuardar?C.border:C.green,
                color:"#fff",fontWeight:800,fontSize:15,transition:"all .2s",
                opacity:saving||!puedeGuardar?.5:1,
              }}>
                {saving?"Guardando…":"🔒 Cerrar corte y ver resultado"}
              </button>
              {!puedeGuardar && (
                <div style={{color:C.textDim,fontSize:11,textAlign:"center",marginTop:-4}}>
                  {corteHoy
                    ? "Este turno ya tiene corte. No se guarda otro."
                    : "Captura el efectivo contado para poder cerrar."}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ══ HISTORIAL ══ */}
      {tab==="historial" && !esVendedor(usuario) && (
        <div>
          <div style={{display:"flex",gap:10,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
            <select value={filtroTurno} onChange={e=>setFiltroTurno(e.target.value)} style={{...inputStyle,maxWidth:160}}>
              <option value="todos">Todos los turnos</option>
              <option value="matutino">🌅 Matutino</option>
              <option value="vespertino">🌆 Vespertino</option>
            </select>
            <select value={filtroFecha} onChange={e=>setFiltroFecha(e.target.value)} style={{...inputStyle,maxWidth:160}}>
              <option value="todos">Todo el período</option>
              <option value="hoy">Hoy</option>
              <option value="semana">Esta semana</option>
              <option value="mes">Este mes</option>
            </select>
            <button onClick={fetchCortes} style={{...btnSecondary,padding:"8px 14px",fontSize:12}}>🔄 Actualizar</button>
            <span style={{color:C.textMid,fontSize:11,marginLeft:"auto"}}>{cortes.length} corte{cortes.length!==1?"s":""}</span>
          </div>

          {loadingHist ? (
            <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando historial…</div>
          ) : (
            <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
              <table className="fc-tabla-cards" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.card}}>
                    {["Fecha/Hora","Turno","Cajero","Contó","Fondo","Ef. Declarado","Ef. Sistema","Diferencia","Revisión","Tarjeta","MP","Total","Notas","Ticket"].map(h=>(
                      <th key={h} style={{padding:"10px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {cortes.length===0&&(
                    <tr><td colSpan={14} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin cortes en este período</td></tr>
                  )}
                  {cortes.map((c,i)=>{
                    const dif    = parseFloat(c.diferencia||0);
                    const dc     = dif===0?C.green:dif>0?C.amber:C.red;
                    const dt     = dif===0?"✓":dif>0?`▲ +${fmt(dif)}`:`▼ ${fmt(dif)}`;
                    const fecha  = new Date(c.fecha);
                    return (
                      <tr key={c.id||i} style={{background:i%2===0?"transparent":C.card+"80"}}>
                        <td data-label="Fecha" data-primary style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                          <div style={{fontWeight:600,color:C.text}}>{fecha.toLocaleDateString("es-MX")}</div>
                          <div style={{color:C.textMid,fontSize:10}}>{fecha.toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"})}</div>
                        </td>
                        <td data-label="Turno" style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                            background:c.turno==="matutino"?C.blueDim:C.amberDim,
                            color:c.turno==="matutino"?C.blue:C.amber}}>
                            {c.turno==="matutino"?"🌅 Mat":"🌆 Vesp"}
                          </span>
                        </td>
                        <td data-label="Cajero" style={{padding:"9px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{c.cajero||"—"}</td>
                        <td data-label="Contó" style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{c.contado_por||"—"}</td>
                        <td data-label="Fondo" style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(c.fondo_inicial)}</td>
                        <td data-label="Ef. declarado" style={{padding:"9px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(c.efectivo_declarado)}</td>
                        <td data-label="Ef. sistema" style={{padding:"9px 12px",color:C.blue,borderBottom:`1px solid ${C.border}`}}>{fmt(c.efectivo_sistema)}</td>
                        <td data-label="Diferencia" style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}><span style={{color:dc,fontWeight:700}}>{dt}</span></td>
                        <td data-label="Revisión" style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                          {dif === 0 ? (
                            <span style={{ color: C.textMid, fontSize: 11 }}>—</span>
                          ) : (c.diferencia_revisada || diferenciasRevisadas.has(Number(c.id))) ? (
                            <span style={{ color: C.green, fontSize: 11, fontWeight: 700 }}>✓ Enterado</span>
                          ) : (
                            <button
                              type="button"
                              onClick={() => marcarDiferenciaEnterada(c.id)}
                              disabled={revisandoDif === c.id}
                              style={{ ...btnSecondary, padding: "4px 8px", fontSize: 10 }}
                            >
                              {revisandoDif === c.id ? "…" : "Enterado"}
                            </button>
                          )}
                        </td>
                        <td data-label="Tarjeta" style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(c.tarjeta)}</td>
                        <td data-label="MP" style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(c.mercadopago)}</td>
                        <td data-label="Total" style={{padding:"9px 12px",color:C.text,fontWeight:800,borderBottom:`1px solid ${C.border}`}}>{fmt(c.total_general)}</td>
                        <td data-label="Notas" data-wide style={{padding:"9px 12px",color:C.textDim,fontSize:11,borderBottom:`1px solid ${C.border}`,maxWidth:130,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{c.notas||"—"}</td>
                        <td data-label="Ticket" data-actions style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                          <div style={{display:"flex",gap:6}}>
                            <button
                              onClick={() => imprimirEpsonHistorial(c)}
                              disabled={ticketAbriendo === c.id}
                              style={{...btnSecondary,padding:"5px 10px",fontSize:11}}
                            >
                              {ticketAbriendo === c.id ? "…" : "Epson"}
                            </button>
                            <button
                              onClick={() => abrirTicketHistorial(c)}
                              disabled={ticketAbriendo === c.id}
                              style={{...btnSecondary,padding:"5px 10px",fontSize:11}}
                            >
                              {ticketAbriendo === c.id ? "…" : "PDF"}
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

          {cortes.length>0&&(
            <div style={{marginTop:16,background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
              <div style={{color:C.text,fontWeight:800,fontSize:13,marginBottom:14}}>
                📊 Resumen del período — {cortes.length} corte{cortes.length!==1?"s":""}
              </div>
              <div style={{display:"flex",gap:12,flexWrap:"wrap"}}>
                {[["Efectivo (venta)",sumEf,C.green],["Tarjeta",sumTar,C.blue],["MercadoPago",sumMp,C.amber],["Gran total",sumTot,C.text]].map(([lbl,val,col])=>(
                  <div key={lbl} style={{background:C.bg,borderRadius:10,padding:"12px 18px",minWidth:130,border:`1px solid ${C.border}`}}>
                    <div style={{color:C.textMid,fontSize:10,fontWeight:700,marginBottom:4}}>{lbl.toUpperCase()}</div>
                    <div style={{color:col,fontWeight:800,fontSize:18}}>{fmt(val)}</div>
                  </div>
                ))}
              </div>
              <div style={{color:C.textDim,fontSize:11,marginTop:10,lineHeight:1.5}}>
                El efectivo es venta: ya se le descontaron {fmt(sumFondo)} de fondos,
                que son cambio y no ingreso. Por eso {fmt(sumEf)} + {fmt(sumTar)} + {fmt(sumMp)} = {fmt(sumTot)}.
              </div>
            </div>
          )}
        </div>
      )}
      <OnboardingTour tourId="caja" usuario={usuario} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// RESULTADO DEL CORTE — se muestra sólo después de guardar
//
// Aquí se destapa lo que estuvo oculto durante la captura: lo que el sistema
// esperaba y la diferencia contra lo contado. Debajo va el reporte Z, el
// detalle de todas las ventas del turno, que sirve para investigar cuando la
// diferencia no es cero y como comprobante del relevo.
// ══════════════════════════════════════════════════════════════
function ResultadoCorte({ C, resultado, turno, dif, difCol, difBg, difTxt,
                          zTransac, cargandoZ, btnSecondary, onNuevo, cajero,
                          denominaciones, permitirOtro, cierreHint }) {
  const esperado  = parseFloat(resultado?.esperado ?? 0);
  const sistema   = parseFloat(resultado?.efectivo_sistema ?? 0);
  const fondoRes  = parseFloat(resultado?.fondo_inicial ?? 0);
  const declarado = esperado + dif;
  // Los electrónicos que realmente quedaron guardados, recalculados por la
  // base al guardar. Si el RPC todavía no los devuelve, se ocultan en 0.
  const tarjetaRes = parseFloat(resultado?.tarjeta ?? 0);
  const mpRes      = parseFloat(resultado?.mercadopago ?? 0);
  const speiRes    = parseFloat(resultado?.spei ?? 0);
  const detalle    = resultado?.detalle_metodos ?? null;
  const [ticketEstado, setTicketEstado] = useState("idle");
  const subidoRef = useRef(false);

  const snap = snapshotFromCorte({
    resultado: {
      ...resultado,
      diferencia: dif,
      efectivo_declarado: declarado,
      tarjeta: tarjetaRes,
      mercadopago: mpRes,
      spei: speiRes,
    },
    turno,
    zTransac,
    cajero,
    denominaciones: denominaciones || resultado?.denominaciones,
  });

  const guardarPdf = async () => {
    const id = resultado?.corte_id ?? resultado?.id;
    if (!id) return null;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) throw new Error("Sesión expirada");
    const blob = corteTicketPdfBlob(snap);
    return uploadCorteTicketPdf(id, blob, tok);
  };

  useEffect(() => {
    if (cargandoZ || zTransac === null) return;
    const id = resultado?.corte_id ?? resultado?.id;
    if (!id || subidoRef.current) return;
    subidoRef.current = true;
    setTicketEstado("guardando");
    guardarPdf()
      .then(() => setTicketEstado("listo"))
      .catch((e) => {
        subidoRef.current = false;
        setTicketEstado("error");
        console.error("[corte ticket]", e);
      });
    // El PDF se arma con el reporte Z; sólo una vez por corte.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cargandoZ, zTransac, resultado?.corte_id]);

  const imprimir = async () => {
    if (!printCorteTicket(snap)) {
      showToast("El navegador bloqueó la ventana de impresión", "warning");
      return;
    }
    try {
      await guardarPdf();
      setTicketEstado("listo");
    } catch (e) {
      console.error("[corte ticket]", e);
      showToast("Se imprimió, pero no se pudo guardar el PDF: " + (e.message || e), "warning");
    }
  };

  const totalZ = (zTransac || []).reduce((a,t)=>a+parseFloat(t.total||0),0);

  return (
    <div style={{display:"flex",flexDirection:"column",gap:16,maxWidth:820}}>
      <div style={{background:difBg,borderRadius:12,border:`1px solid ${difCol}40`,padding:24}}>
        <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:6}}>
          CORTE CERRADO · TURNO {turno.toUpperCase()}
        </div>
        <div style={{color:difCol,fontWeight:800,fontSize:30,marginBottom:14}}>{difTxt}</div>
        {[["Fondo inicial",fondoRes],["Ventas en efectivo (sistema)",sistema],
          ["Esperado en el cajón",esperado],["Contado por el cajero",declarado]].map(([l,v])=>(
          <div key={l} style={{display:"flex",justifyContent:"space-between",padding:"3px 0"}}>
            <span style={{color:C.textMid,fontSize:12.5}}>{l}</span>
            <span style={{color:C.text,fontSize:13,fontWeight:600}}>{fmt(v)}</span>
          </div>
        ))}
        {detalle && parseFloat(detalle.efectivo_devoluciones || 0) > 0 && (
          <div style={{color:C.textDim,fontSize:11,marginTop:4,lineHeight:1.4}}>
            El efectivo del sistema ya restó {fmt(detalle.efectivo_devoluciones)} de devoluciones
            {parseFloat(detalle.efectivo_cambios_ingreso || 0) > 0
              ? ` y sumó ${fmt(detalle.efectivo_cambios_ingreso)} de diferencias cobradas en cambios`
              : ""}.
          </div>
        )}
        {detalle && parseFloat(detalle.credito_otorgado || 0) > 0 && (
          <div style={{color:C.textDim,fontSize:11,marginTop:4}}>
            Crédito otorgado en el turno: {fmt(detalle.credito_otorgado)} (no sale del cajón).
          </div>
        )}

        {/* Los electrónicos: lo que la base calculó al guardar, no lo que
            traía la pantalla. Sirve para cotejar contra la terminal. */}
        <div style={{borderTop:`1px solid ${C.border}`,marginTop:10,paddingTop:8}}>
          {[["Tarjeta (BBVA + Point)",tarjetaRes],["MercadoPago (tienda web)",mpRes],
            ...(speiRes > 0 ? [["SPEI",speiRes]] : [])].map(([l,v])=>(
            <div key={l} style={{display:"flex",justifyContent:"space-between",padding:"3px 0"}}>
              <span style={{color:C.textMid,fontSize:12.5}}>{l}</span>
              <span style={{color:C.text,fontSize:13,fontWeight:600}}>{fmt(v)}</span>
            </div>
          ))}
          {detalle && (detalle.tarjeta_servicios > 0) && (
            <div style={{color:C.textDim,fontSize:11,marginTop:4}}>
              De la tarjeta, {fmt(detalle.tarjeta_servicios)} son pagos de servicio.
            </div>
          )}
          <div style={{display:"flex",justifyContent:"space-between",paddingTop:8,marginTop:6,
                       borderTop:`1px solid ${C.border}`}}>
            <span style={{color:C.text,fontSize:13,fontWeight:800}}>TOTAL DEL TURNO</span>
            <span style={{color:C.text,fontSize:15,fontWeight:800}}>
              {fmt(resultado?.total_general ?? 0)}
            </span>
          </div>
        </div>
        {dif !== 0 && (
          <div style={{color:C.textDim,fontSize:11.5,marginTop:12,lineHeight:1.5}}>
            {dif > 0
              ? "Hay más dinero del esperado. Suele ser una venta cobrada de más, un cambio mal dado a favor, o una venta que no se registró en el sistema."
              : "Falta dinero. Revisa el detalle de abajo: puede ser un cambio mal dado, una venta cobrada de menos, o un retiro que no se anotó."}
          </div>
        )}
      </div>

      <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
        <div style={{display:"flex",alignItems:"center",marginBottom:12}}>
          <div style={{color:C.text,fontWeight:800,fontSize:14,flex:1}}>
            🧾 Detalle del turno {cargandoZ ? "" : `· ${(zTransac||[]).length} venta(s) · ${fmt(totalZ)}`}
          </div>
          <div style={{display:"flex",flexDirection:"column",alignItems:"flex-end",gap:4}}>
          <div style={{display:"flex",alignItems:"center",gap:8,flexWrap:"wrap",justifyContent:"flex-end"}}>
            <span style={{color:C.textDim,fontSize:11}}>
              {ticketEstado === "guardando" ? "Guardando PDF…"
                : ticketEstado === "listo" ? "PDF en historial"
                : ticketEstado === "error" ? "PDF no se guardó"
                : ""}
            </span>
            <button onClick={imprimir} disabled={cargandoZ} style={{...btnSecondary,padding:"8px 16px",fontSize:12}}>
              Imprimir Epson
            </button>
            <button onClick={() => {
              if (!printCorteHojaA4(snap)) showToast("El navegador bloqueó la ventana", "warning");
            }} disabled={cargandoZ} style={{...btnSecondary,padding:"8px 16px",fontSize:12}}>
              Hoja A4
            </button>
          </div>
          <div style={{color:C.textDim,fontSize:10,lineHeight:1.35,maxWidth:320,textAlign:"right"}}>
            Epson: mismo diálogo que el ticket de venta (TM-T20, 80 mm). El PDF del historial queda en hoja completa.
          </div>
          </div>
        </div>
        {cargandoZ ? (
          <div style={{color:C.textMid,padding:20,textAlign:"center",fontSize:12}}>Cargando el detalle…</div>
        ) : (zTransac||[]).length === 0 ? (
          <div style={{color:C.textMid,padding:20,textAlign:"center",fontSize:12}}>Sin ventas en este turno</div>
        ) : (
          <div style={{maxHeight:300,overflowY:"auto",border:`1px solid ${C.border}`,borderRadius:8}}>
            <table className="fc-tabla-cards" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
              <thead><tr style={{background:C.bg}}>
                {["Folio","Hora","Método","Producto","Importe"].map(h=>(
                  <th key={h} style={{padding:"7px 10px",textAlign:h==="Importe"?"right":"left",
                    color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>
                ))}
              </tr></thead>
              <tbody>
                {(zTransac||[]).flatMap(t=>{
                  const items = t.items || [];
                  if (!items.length) {
                    return [(
                      <tr key={t.id}>
                        <td data-label="Folio" data-primary style={{padding:"6px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>#{t.id}</td>
                        <td data-label="Hora" style={{padding:"6px 10px",color:C.text,borderBottom:`1px solid ${C.border}`}}>
                          {new Date(t.created_at).toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"})}
                        </td>
                        <td data-label="Método" style={{padding:"6px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{t.metodo_pago||"—"}</td>
                        <td data-label="Producto" data-wide style={{padding:"6px 10px",color:C.textDim,borderBottom:`1px solid ${C.border}`}}>—</td>
                        <td data-label="Importe" style={{padding:"6px 10px",textAlign:"right",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>
                          {fmt(t.total)}
                        </td>
                      </tr>
                    )];
                  }
                  return items.map((it, idx) => (
                    <tr key={`${t.id}-${idx}`}>
                      <td data-label="Folio" data-primary style={{padding:"6px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{idx===0?`#${t.id}`:`#${t.id}`}</td>
                      <td data-label="Hora" style={{padding:"6px 10px",color:C.text,borderBottom:`1px solid ${C.border}`}}>
                        {new Date(t.created_at).toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"})}
                      </td>
                      <td data-label="Método" style={{padding:"6px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{t.metodo_pago||"—"}</td>
                      <td data-label="Producto" data-wide style={{padding:"6px 10px",color:C.text,borderBottom:`1px solid ${C.border}`}}>
                        {it.cantidad} × {it.nombre}{it.sku?` · ${it.sku}`:""}
                      </td>
                      <td data-label="Importe" style={{padding:"6px 10px",textAlign:"right",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>
                        {fmt(it.subtotal ?? it.precio_unitario)}
                      </td>
                    </tr>
                  ));
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {permitirOtro ? (
        <button onClick={onNuevo} style={{...btnSecondary,alignSelf:"flex-start"}}>
          Hacer otro corte
        </button>
      ) : (
        <div style={{color:C.textMid,fontSize:13,lineHeight:1.45}}>
          {cierreHint || "Turno cerrado. El otro turno lo abre tu compañera."}
        </div>
      )}
    </div>
  );
}
