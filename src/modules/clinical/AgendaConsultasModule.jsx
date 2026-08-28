import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT, BRAND } from "../../constants";
import { supabase } from "../../supabase";
import { nombreCompletoPacienteValido, telefonoMxValido, normalizarTelefonoMxGuardar } from "../../utils";
import { Box, Tag, Btn, KPI, KPI_ROW, Modal, showToast, SkeletonKPIs, SkeletonTable, Inp } from "../../ui";
import { citaPagoPendiente, citaPagoOk, labelCanal, labelEstadoPagoCita, franjaAgendaStyle } from "../../utils/consultaConstants";
import { fetchProductosConsumiblesConsultorio } from "../../utils/consumiblesConsultorio";
import { CitaFichaModal } from "./CitaFichaDoctora";
import {
  TODOS_HORARIOS_CITA,
  horariosDisponiblesCita,
  formatFechaAgendaLargaEs,
  addDaysSv,
  puedeCancelarCitaCaja,
  esCitaNoShow,
} from "../../utils/citasAgenda";
import { addDaysISO, hoyISOMexico, ymdLocalDate } from "../../lib/fecha";

const C = C_LIGHT;

const WEEKDAYS_MON = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

/** Normaliza hora DB/UI a HH:MM (ej. 09:00:00 -> 09:00). */
function horaKey(h) {
  const s = String(h ?? "").trim();
  if (!s) return "";
  const m = s.match(/^(\d{1,2}):(\d{2})/);
  if (!m) return s;
  return `${String(parseInt(m[1], 10)).padStart(2, "0")}:${m[2]}`;
}

function monthRangeSv(year, month0) {
  const first = `${year}-${String(month0 + 1).padStart(2, "0")}-01`;
  const lastD = new Date(year, month0 + 1, 0).getDate();
  const last = `${year}-${String(month0 + 1).padStart(2, "0")}-${String(lastD).padStart(2, "0")}`;
  return { first, last };
}

function buildMonthCells(year, month0) {
  const hoy = hoyISOMexico();
  const first = new Date(year, month0, 1);
  const mondayFirst = (first.getDay() + 6) % 7;
  const cells = [];
  let i = 1 - mondayFirst;
  while (cells.length < 42) {
    const d = new Date(year, month0, i);
    const inMonth = d.getMonth() === month0;
    const sv = ymdLocalDate(d);
    cells.push({
      d,
      inMonth,
      sv,
      isToday: sv === hoy,
      /** Comparación YYYY-MM-DD (sv-SE): días de trabajo ya cerrados respecto a hoy. */
      isPast: sv < hoy,
    });
    i++;
  }
  return cells;
}

/** Etiqueta UX sobre estados reales en BD (citas.estado, pago_estado, pedido_consulta_id). */
function etiquetaEstadoVisual(cita) {
  if (!cita || cita.estado === "cancelada") return { key: "cancelada", label: "Cancelada", col: C.red };
  if (cita.estado === "no_asistio") return { key: "no_asistio", label: "No asistió", col: C.textDim };
  if (cita.estado === "completada" && citaPagoPendiente(cita)) {
    return { key: "pendiente_cobro", label: "Pendiente de cobro", col: C.amber };
  }
  if (cita.estado === "completada") return { key: "atendida", label: "Atendida", col: C.green };
  if (cita.estado === "en_consulta") return { key: "en_sala", label: "En consulta", col: C.amber };
  if (cita.estado === "agendada") {
    return { key: "agendada", label: "Agendada", col: C.blue };
  }
  if (cita.estado === "confirmada") return { key: "confirmada", label: "Confirmada", col: C.blue };
  if (cita.estado === "pagada") return { key: "pagada_legacy", label: "Pagada", col: C.green };
  return { key: "otro", label: cita.estado || "—", col: C.textDim };
}

/**
 * Calendario mensual + agenda por horas + detalle.
 * @param {{ usuario: object, onNavigate?: (id: string, opts?: { posTab?: string }) => void }} props
 */
export default function AgendaConsultasModule({ usuario, onNavigate }) {
  const mode = usuario?.rol === "doctora" ? "doctora" : usuario?.rol === "vendedor" ? "vendedor" : "admin";
  const titulo = mode === "doctora" ? "Agenda médica" : "Agenda de consultas";

  const now = new Date();
  const [y, setY] = useState(now.getFullYear());
  const [m, setM] = useState(now.getMonth());
  const [vista, setVista] = useState(() => (usuario?.rol === "doctora" ? "dia" : "mes")); // mes | dia
  const [diaSel, setDiaSel] = useState(() => hoyISOMexico());
  const [citasMes, setCitasMes] = useState([]);
  const [loadMes, setLoadMes] = useState(true);
  const [fichaCita, setFichaCita] = useState(null);
  const [fichaSoloLectura, setFichaSoloLectura] = useState(false);
  const [iniciandoCitaId, setIniciandoCitaId] = useState(null);
  const [detalleSimple, setDetalleSimple] = useState(null);
  const [prodList, setProdList] = useState([]);
  const [procsList, setProcsList] = useState([]);
  const [slotNuevo, setSlotNuevo] = useState(null);
  const [formNueva, setFormNueva] = useState({
    nombre: "",
    telefono: "",
    motivo: "",
  });
  const [guardando, setGuard] = useState(false);

  const [kpiPer, setKpiPer] = useState("semana");
  const [kpiLoad, setKpiLoad] = useState(true);
  const [kpi, setKpi] = useState({
    kpiPeriodoSub: "hoy (fecha local)",
    completadas: 0,
    ingresoDoctorSum: 0,
    procedimientosCount: 0,
    tiempoPromMin: null,
    ventasRecetaFarmaCapital: 0,
    nRecetasExternas: 0,
    oportunidadEst: 0,
    estimadoUnit: 350,
    lineas: { farmacapital: 0, externa: 0, pend: 0, conProductoId: 0 },
  });

  const { first: mesDesde, last: mesHasta } = useMemo(() => monthRangeSv(y, m), [y, m]);
  const cells = useMemo(() => buildMonthCells(y, m), [y, m]);

  const citasPorDia = useMemo(() => {
    const map = {};
    for (const c of citasMes) {
      if (!c.fecha || c.estado === "cancelada") continue;
      map[c.fecha] = (map[c.fecha] || 0) + 1;
    }
    return map;
  }, [citasMes]);

  const citasDelDia = useMemo(() => {
    return citasMes.filter((c) => c.fecha === diaSel && c.estado !== "cancelada");
  }, [citasMes, diaSel]);

  /** Citas del día en orden de hora (flujo clínico). */
  const citasDiaOrdenadas = useMemo(() => {
    return [...citasDelDia].sort(
      (a, b) => horaKey(a.hora).localeCompare(horaKey(b.hora)) || Number(a.id) - Number(b.id)
    );
  }, [citasDelDia]);

  /**
   * Próxima acción lógica: consulta en curso → continuar; si no, primera pagada lista;
   * si toca turno sin pago, mostrar bloqueo; si nada operativo, mensaje informativo.
   */
  const accionPrincipalDoctora = useMemo(() => {
    if (mode !== "doctora") return null;
    const list = citasDiaOrdenadas;
    const enCurso = list.find((c) => c.estado === "en_consulta");
    if (enCurso) return { tipo: "continuar", cita: enCurso };

    const entradas = list.filter(
      (c) =>
        citaPagoOk(c) &&
        c.estado !== "completada" &&
        c.estado !== "no_asistio" &&
        c.estado !== "en_consulta"
    );
    if (entradas.length) return { tipo: "entrar", cita: entradas[0] };

    const sinPago = list.find(
      (c) =>
        !citaPagoOk(c) &&
        c.estado !== "completada" &&
        c.estado !== "cancelada" &&
        c.estado !== "no_asistio" &&
        c.estado !== "en_consulta"
    );
    if (sinPago) return { tipo: "pago", cita: sinPago };

    if (list.length) return { tipo: "todo_ok", cita: null };
    return { tipo: "vacio", cita: null };
  }, [mode, citasDiaOrdenadas]);

  const citaPorHora = useMemo(() => {
    const map = {};
    for (const c of citasDelDia) {
      const hk = horaKey(c.hora);
      if (hk) map[hk] = c;
    }
    return map;
  }, [citasDelDia]);

  const cargarMes = useCallback(async () => {
    setLoadMes(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) {
        setCitasMes([]);
        return;
      }
      const { data, error } = await supabase.rpc("empleado_agenda_listar_citas_rango_fecha", {
        p_session_token: tok,
        p_fecha_desde: mesDesde,
        p_fecha_hasta: mesHasta,
      });
      if (error) throw error;
      setCitasMes(Array.isArray(data) ? data : []);
    } catch (e) {
      console.error("[Agenda] mes:", e);
      setCitasMes([]);
    } finally {
      setLoadMes(false);
    }
  }, [mesDesde, mesHasta]);

  useEffect(() => {
    cargarMes();
  }, [cargarMes]);

  useEffect(() => {
    if (mode !== "doctora") return;
    let cancel = false;
    (async () => {
      setKpiLoad(true);
      const hoy = hoyISOMexico();
      const nowD = new Date();
      let desdeFecha;
      let hastaFecha;
      let periodoSub;
      if (kpiPer === "dia") {
        desdeFecha = hoy;
        hastaFecha = hoy;
        periodoSub = "hoy (fecha local)";
      } else if (kpiPer === "semana") {
        desdeFecha = addDaysISO(hoy, -6);
        hastaFecha = hoy;
        periodoSub = "últimos 7 días";
      } else {
        const y = nowD.getFullYear();
        const m0 = nowD.getMonth();
        const lastD = new Date(y, m0 + 1, 0).getDate();
        desdeFecha = `${y}-${String(m0 + 1).padStart(2, "0")}-01`;
        hastaFecha = `${y}-${String(m0 + 1).padStart(2, "0")}-${String(lastD).padStart(2, "0")}`;
        periodoSub = "mes en curso";
      }
      try {
        const tok = sessionStorage.getItem("farmacapital_session_token");
        if (!tok) return;
        const { data, error } = await supabase.rpc("empleado_agenda_kpi_citas_periodo", {
          p_session_token: tok,
          p_fecha_desde: desdeFecha,
          p_fecha_hasta: hastaFecha,
        });
        if (error) throw error;
        if (cancel) return;
        const rows = Array.isArray(data) ? data : [];
        const completadas = rows.filter((c) => c.estado === "completada" || c.estado === "pagada");
        const procedimientosCount = completadas.reduce((a, c) => {
          try {
            const procs = c.procedimientos_realizados;
            if (Array.isArray(procs)) return a + procs.length;
            if (typeof procs === "string") {
              const parsed = JSON.parse(procs || "[]");
              return a + (Array.isArray(parsed) ? parsed.length : 0);
            }
          } catch { /* noop */ }
          return a;
        }, 0);
        const tiemposValidos = completadas
          .map((c) => parseFloat(c.duracion_consulta_segundos))
          .filter((d) => Number.isFinite(d) && d > 0);
        const tiempoPromMin = tiemposValidos.length
          ? tiemposValidos.reduce((a, b) => a + b, 0) / tiemposValidos.length / 60
          : null;
        setKpi((prev) => ({
          ...prev,
          kpiPeriodoSub: periodoSub,
          completadas: completadas.length,
          procedimientosCount,
          tiempoPromMin,
        }));
      } catch (e) {
        console.error("[Agenda] kpi doctora:", e);
      } finally {
        if (!cancel) setKpiLoad(false);
      }
    })();
    return () => {
      cancel = true;
    };
  }, [kpiPer, mode]);

  const prepararFicha = useCallback(async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const [consumibles, procRes] = await Promise.all([
      fetchProductosConsumiblesConsultorio(supabase),
      tok
        ? supabase.rpc("empleado_listar_procedimientos_medicos", {
            p_session_token: tok,
            p_solo_activos: true,
          })
        : Promise.resolve({ data: [] }),
    ]);
    setProdList(consumibles || []);
    const pr = procRes?.data;
    setProcsList(Array.isArray(pr) ? pr : []);
  }, []);

  useEffect(() => {
    if (fichaCita && (mode === "doctora" || mode === "admin")) prepararFicha();
  }, [mode, fichaCita, prepararFicha]);

  const abrirCita = (cita) => {
    if (mode === "vendedor") {
      setDetalleSimple(cita);
      return;
    }
    if (mode === "doctora") {
      // La doctora abre ficha solo con los botones (iniciar / continuar / resumen).
      return;
    }
    setFichaSoloLectura(false);
    setFichaCita(cita);
  };

  const cerrarFicha = () => {
    setFichaCita(null);
    setFichaSoloLectura(false);
  };

  const continuarConsultaDoctora = (cita) => {
    setFichaSoloLectura(false);
    setFichaCita(cita);
    prepararFicha();
  };

  const verResumenConsultaDoctora = (cita) => {
    setFichaSoloLectura(true);
    setFichaCita(cita);
    prepararFicha();
  };

  const iniciarConsultaDoctora = async (cita) => {
    if (!citaPagoOk(cita)) {
      showToast("La consulta debe estar pagada en caja antes de iniciar la atención.", "warning");
      return;
    }
    if (cita.estado === "completada" || cita.estado === "cancelada" || cita.estado === "no_asistio" || cita.estado === "en_consulta") {
      return;
    }
    setIniciandoCitaId(cita.id);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { error: rpcErr } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_estado: "en_consulta",
      });
      if (rpcErr) throw rpcErr;
      const { error: upErr } = await supabase
        .from("citas")
        .update({ confirmada_inicio_at: new Date().toISOString() })
        .eq("id", cita.id)
        .is("confirmada_inicio_at", null);
      if (upErr) console.warn("[Agenda] confirmada_inicio_at:", upErr);
      await cargarMes();
      const { data: fresh } = await supabase.rpc("empleado_obtener_cita_agenda_por_id", {
        p_session_token: tok,
        p_cita_id: cita.id,
      });
      setFichaSoloLectura(false);
      setFichaCita(fresh || { ...cita, estado: "en_consulta" });
      prepararFicha();
    } catch (e) {
      showToast(String(e.message || e), "error");
    } finally {
      setIniciandoCitaId(null);
    }
  };

  const cancelarCitaAgenda = async (cita) => {
    if (mode === "doctora") {
      showToast("Quien anula citas es mostrador o administración.", "info");
      return;
    }
    if (!puedeCancelarCitaCaja(cita)) return;
    const noShow = esCitaNoShow(cita);
    const ok = window.confirm(
      noShow
        ? `¿Marcar que ${cita.nombre} no se presentó (${cita.fecha || ""} ${cita.hora})?`
        : `¿Cancelar la cita de ${cita.nombre} (${cita.fecha || ""} ${cita.hora})?`
    );
    if (!ok) return;
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_estado: noShow ? "no_asistio" : "cancelada",
      });
      if (error) throw error;
      if (resp && resp.success === false) throw new Error(resp.error || "No se pudo cancelar");
      showToast(noShow ? "Marcada: no se presentó." : "Cita cancelada.", "info");
      setDetalleSimple(null);
      await cargarMes();
    } catch (e) {
      showToast(String(e.message || e), "error");
    } finally {
      setGuard(false);
    }
  };

  const guardarNuevaCita = async () => {
    if (mode === "doctora") {
      showToast("Quien agenda citas es mostrador o administración. Vos atendés desde «Entrar a consulta» y expediente.", "info");
      return;
    }
    const hoy = hoyISOMexico();
    if (diaSel < hoy) {
      showToast("No se pueden agendar citas en fechas pasadas.", "warning");
      return;
    }
    if (!slotNuevo || !formNueva.nombre?.trim() || !formNueva.telefono?.trim()) {
      showToast("Nombre y teléfono son obligatorios.", "warning");
      return;
    }
    if (diaSel === hoy && !horariosDisponiblesCita(diaSel).includes(slotNuevo)) {
      showToast("Ese horario ya no está disponible (hora pasada).", "warning");
      return;
    }
    if (!nombreCompletoPacienteValido(formNueva.nombre)) {
      showToast("Indica nombre y apellido (al menos dos palabras).", "warning");
      return;
    }
    if (!telefonoMxValido(formNueva.telefono)) {
      showToast("Teléfono: al menos 10 dígitos.", "warning");
      return;
    }
    setGuard(true);
    try {
      const { data: ocupadoCount } = await supabase.rpc("empleado_agenda_contar_slot_ocupado", {
        p_session_token: tok,
        p_fecha: diaSel,
        p_hora: slotNuevo,
      });
      if ((ocupadoCount ?? 0) >= 1) {
        showToast("Ese horario ya está ocupado.", "warning");
        setGuard(false);
        return;
      }
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const canal = "mostrador";
      const { data: resp, error } = await supabase.rpc("crear_cita", {
        p_session_token: tok,
        p_nombre: formNueva.nombre.trim(),
        p_telefono: normalizarTelefonoMxGuardar(formNueva.telefono),
        p_fecha: diaSel,
        p_hora: slotNuevo,
        p_motivo: formNueva.motivo.trim() || null,
        p_canal: canal,
        p_paciente_id: null,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo crear la cita");
      showToast("Cita agendada.", "success");
      setSlotNuevo(null);
      setFormNueva({ nombre: "", telefono: "", motivo: "" });
      await cargarMes();
    } catch (e) {
      console.error(e);
      showToast(String(e.message || e), "error");
    }
    setGuard(false);
  };

  const irMes = (delta) => {
    const d = new Date(y, m + delta, 1);
    setY(d.getFullYear());
    setM(d.getMonth());
  };

  const elegirDia = (sv, inMonth) => {
    if (!inMonth) return;
    setDiaSel(sv);
    setVista("dia");
  };

  return (
    <div style={{ maxWidth: 1100, margin: "0 auto" }}>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: 12,
          flexWrap: "wrap",
          marginBottom: 18,
          padding: "14px 16px",
          borderRadius: 12,
          border: `1px solid ${C.border}`,
          background: `linear-gradient(135deg, ${BRAND.primary}10, ${BRAND.secondary}08)`,
        }}
      >
        <div>
          <h1 style={{ color: C.text, fontSize: 22, fontWeight: 800, margin: 0 }}>{titulo}</h1>
          <p style={{ color: C.textMid, fontSize: 13, margin: "6px 0 0" }}>
            {mode === "vendedor"
              ? "Consultas del día y cobros en mostrador; sin detalle clínico completo."
              : mode === "doctora"
                ? vista === "mes"
                  ? "Citas las agenda el equipo. Para atender, usá «Ver mi día (hoy)» o elegí un día con citas. Sin cobro ni POS desde acá: solo cita paga, ficha y expediente."
                  : "Hoy: consultas ordenadas por hora, próxima acción arriba. Entrás a la ficha con «Entrar a consulta»; sin pago, bloqueo claro."
                : "Vista completa del consultorio: calendario, horarios y expediente."}
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          {mode === "doctora" && diaSel !== hoyISOMexico() && (
            <button
              type="button"
              onClick={() => {
                const h = hoyISOMexico();
                setDiaSel(h);
                const d = new Date();
                setY(d.getFullYear());
                setM(d.getMonth());
                setVista("dia");
              }}
              style={{
                padding: "8px 14px",
                borderRadius: 8,
                border: `1px solid ${BRAND.primary}`,
                background: BRAND.primary + "14",
                color: BRAND.secondary,
                fontWeight: 800,
                fontSize: 12,
                cursor: "pointer",
              }}
            >
              Ir a hoy
            </button>
          )}
          <button
            type="button"
            onClick={() => {
              if (vista === "mes") {
                if (mode === "doctora") {
                  const h = hoyISOMexico();
                  setDiaSel(h);
                  const d = new Date();
                  setY(d.getFullYear());
                  setM(d.getMonth());
                }
                setVista("dia");
              } else {
                setVista("mes");
              }
            }}
            style={{
              padding: "8px 14px",
              borderRadius: 8,
              border: `1px solid ${C.border}`,
              background: C.card,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {vista === "mes" ? (mode === "doctora" ? "Ver mi día (hoy)" : "Ver día seleccionado") : "Ver calendario (mes)"}
          </button>
        </div>
      </div>

      {mode === "doctora" && vista === "dia" && (
        <Box
          style={{
            marginBottom: 18,
            padding: 18,
            border: `2px solid ${BRAND.primary}50`,
            background: `linear-gradient(180deg, ${BRAND.primary}16, ${C.card} 100%)`,
            borderRadius: 12,
            boxShadow: "0 8px 24px rgba(0,82,204,0.08)",
          }}
        >
          <div
            style={{
              fontSize: 11,
              fontWeight: 800,
              color: C.textDim,
              textTransform: "uppercase",
              letterSpacing: 0.6,
              marginBottom: 10,
            }}
          >
            {diaSel === hoyISOMexico() ? "Próxima acción" : "Acción (día que estás viendo)"}
          </div>
          {loadMes && <div style={{ color: C.textMid, fontSize: 13 }}>Cargando citas del día…</div>}
          {!loadMes && accionPrincipalDoctora?.tipo === "vacio" && (
            <p style={{ color: C.textMid, fontSize: 14, margin: 0 }}>No hay citas este día. Elegí otro en el calendario o en «Día anterior / siguiente».</p>
          )}
          {!loadMes && accionPrincipalDoctora?.tipo === "todo_ok" && (
            <p style={{ color: C.green, fontSize: 14, fontWeight: 700, margin: 0 }}>
              No quedan consultas por atender este día. Podés pasar a otro día o revisar expedientes.
            </p>
          )}
          {!loadMes && accionPrincipalDoctora?.tipo === "continuar" && accionPrincipalDoctora.cita && (
            <div>
              <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center", marginBottom: 6 }}>
                <span style={{ fontSize: 18, fontWeight: 800, color: C.text }}>Consulta en curso</span>
                <Tag col={C.amber} sm>
                  En consulta
                </Tag>
              </div>
              <div style={{ fontSize: 16, fontWeight: 800, color: BRAND.primary, marginBottom: 4 }}>{accionPrincipalDoctora.cita.nombre}</div>
              <div style={{ fontSize: 13, color: C.textMid, marginBottom: 12 }}>
                {horaKey(accionPrincipalDoctora.cita.hora)} · {accionPrincipalDoctora.cita.motivo || "Consulta general"}
              </div>
              <Btn col={BRAND.primary} onClick={() => continuarConsultaDoctora(accionPrincipalDoctora.cita)}>
                Continuar consulta
              </Btn>
            </div>
          )}
          {!loadMes && accionPrincipalDoctora?.tipo === "entrar" && accionPrincipalDoctora.cita && (
            <div>
              <div style={{ fontSize: 18, fontWeight: 800, color: C.text, marginBottom: 6 }}>Próxima consulta a atender</div>
              <div style={{ fontSize: 16, fontWeight: 800, color: BRAND.primary, marginBottom: 4 }}>{accionPrincipalDoctora.cita.nombre}</div>
              <div style={{ fontSize: 13, color: C.textMid, marginBottom: 8 }}>
                {horaKey(accionPrincipalDoctora.cita.hora)} · {accionPrincipalDoctora.cita.motivo || "Consulta general"}
              </div>
              <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center", marginBottom: 12 }}>
                <Tag col={etiquetaEstadoVisual(accionPrincipalDoctora.cita).col} sm>
                  {etiquetaEstadoVisual(accionPrincipalDoctora.cita).label}
                </Tag>
                {accionPrincipalDoctora.cita.canal && (
                  <Tag col={C.blue} sm>
                    {labelCanal(accionPrincipalDoctora.cita)}
                  </Tag>
                )}
              </div>
              <Btn
                col={BRAND.primary}
                dis={iniciandoCitaId === accionPrincipalDoctora.cita.id}
                onClick={() => iniciarConsultaDoctora(accionPrincipalDoctora.cita)}
              >
                {iniciandoCitaId === accionPrincipalDoctora.cita.id ? "Abriendo ficha…" : "Entrar a consulta"}
              </Btn>
              <p style={{ fontSize: 12, color: C.textDim, marginTop: 10, marginBottom: 0, lineHeight: 1.4 }}>
                Se abre la ficha con motivo, signos vitales, diagnóstico, receta y notas. Abajo seguís el mismo turno con el mismo horario.
              </p>
            </div>
          )}
          {!loadMes && accionPrincipalDoctora?.tipo === "pago" && accionPrincipalDoctora.cita && (
            <div>
              <div style={{ fontSize: 18, fontWeight: 800, color: C.text, marginBottom: 6 }}>Siguiente en agenda (hoy)</div>
              <div style={{ fontSize: 16, fontWeight: 800, color: BRAND.primary, marginBottom: 4 }}>{accionPrincipalDoctora.cita.nombre}</div>
              <div style={{ fontSize: 13, color: C.textMid, marginBottom: 10 }}>
                {horaKey(accionPrincipalDoctora.cita.hora)} · {accionPrincipalDoctora.cita.motivo || "Consulta"}
              </div>
              <div
                style={{
                  padding: 12,
                  background: C.amberDim,
                  borderRadius: 8,
                  border: `1px solid ${C.amber}55`,
                }}
              >
                <div style={{ fontWeight: 800, color: C.amber, fontSize: 13 }}>Pendiente de pago en caja o tienda</div>
                <p style={{ fontSize: 12, color: C.textMid, margin: "6px 0 0", lineHeight: 1.45 }}>
                  No se puede avanzar a la ficha clínica hasta que la consulta esté pagada. Si hay otras horas con pago, podés atender esas abajo. El cobro no lo hacés desde esta pantalla.
                </p>
              </div>
            </div>
          )}
        </Box>
      )}

      {mode === "doctora" && (
        <>
          <div style={{ display: "flex", justifyContent: "flex-end", alignItems: "center", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
            <span style={{ color: C.textDim, fontSize: 11, fontWeight: 700 }}>Indicadores</span>
            {[
              ["dia", "Hoy"],
              ["semana", "7 días"],
              ["mes", "Mes"],
            ].map(([v, lab]) => (
              <button
                key={v}
                type="button"
                onClick={() => setKpiPer(v)}
                style={{
                  padding: "6px 12px",
                  borderRadius: 8,
                  border: `1px solid ${kpiPer === v ? BRAND.primary : C.border}`,
                  background: kpiPer === v ? BRAND.primary + "18" : "transparent",
                  color: kpiPer === v ? BRAND.secondary : C.textMid,
                  fontSize: 12,
                  fontWeight: 700,
                  cursor: "pointer",
                }}
              >
                {lab}
              </button>
            ))}
          </div>
          {kpiLoad ? (
            <SkeletonKPIs count={3} />
          ) : (
            <div style={KPI_ROW}>
              <KPI
                label="Consultas cerradas"
                value={kpi.completadas}
                col={C.green}
                icon="🏥"
                sub={kpi.kpiPeriodoSub || "—"}
              />
              <KPI label="Procedimientos" value={kpi.procedimientosCount} col={C.blue} icon="🩺" sub="en consultas cerradas" />
              <KPI
                label="Tiempo prom."
                value={kpi.tiempoPromMin != null ? `${kpi.tiempoPromMin.toFixed(1)} min` : "—"}
                col={C.amber}
                icon="⏱️"
                sub={kpi.kpiPeriodoSub || "—"}
              />
            </div>
          )}
        </>
      )}

      <CitaFichaModal
        cita={fichaCita}
        open={!!fichaCita}
        onClose={cerrarFicha}
        prodList={prodList}
        procsList={procsList}
        onSaved={cargarMes}
        readOnly={fichaSoloLectura}
      />

      <Modal open={!!detalleSimple} onClose={() => setDetalleSimple(null)} title="Consulta" ac={C.blue}>
        {detalleSimple && (
          <div style={{ fontSize: 13, color: C.textMid, lineHeight: 1.5 }}>
            <div>
              <strong style={{ color: C.text }}>{detalleSimple.nombre}</strong>
            </div>
            <div>
              {detalleSimple.fecha} · {detalleSimple.hora}
            </div>
            <div style={{ marginTop: 8 }}>Motivo: {detalleSimple.motivo || "—"}</div>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 10 }}>
              <Tag col={etiquetaEstadoVisual(detalleSimple).col} sm>
                {etiquetaEstadoVisual(detalleSimple).label}
              </Tag>
              {(() => {
                const ep = labelEstadoPagoCita(detalleSimple);
                return <Tag col={ep.col} sm>{ep.label}</Tag>;
              })()}
              {detalleSimple.canal && (
                <Tag col={C.blue} sm>
                  {labelCanal(detalleSimple)}
                </Tag>
              )}
            </div>
            {citaPagoPendiente(detalleSimple) && detalleSimple.estado === "completada" && (
              <div style={{ marginTop: 12, padding: 10, background: C.amberDim, borderRadius: 8, fontWeight: 700, color: C.amber }}>
                Pendiente de cobro en caja
              </div>
            )}
            <div style={{ marginTop: 16, display: "flex", gap: 8, flexWrap: "wrap" }}>
              {citaPagoPendiente(detalleSimple) && (
                <Btn
                  col={BRAND.primary}
                  onClick={() => {
                    setDetalleSimple(null);
                    onNavigate?.("pos", { posTab: "consultas" });
                  }}
                >
                  Ir a POS (cobrar consulta)
                </Btn>
              )}
              {puedeCancelarCitaCaja(detalleSimple) && (
                <Btn ol col={C.red} onClick={() => cancelarCitaAgenda(detalleSimple)} dis={guardando}>
                  {esCitaNoShow(detalleSimple) ? "No se presentó" : "Cancelar cita"}
                </Btn>
              )}
              <Btn ol col={C.textMid} onClick={() => setDetalleSimple(null)}>
                Cerrar
              </Btn>
            </div>
          </div>
        )}
      </Modal>

      <Modal open={!!slotNuevo} onClose={() => setSlotNuevo(null)} title={`Nueva cita · ${slotNuevo || ""}`} ac={C.green}>
        <div style={{ display: "grid", gap: 10 }}>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 4 }}>Paciente</div>
            <Inp value={formNueva.nombre} onChange={(e) => setFormNueva((p) => ({ ...p, nombre: e.target.value }))} placeholder="Nombre y apellido" />
          </div>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 4 }}>Teléfono</div>
            <Inp value={formNueva.telefono} onChange={(e) => setFormNueva((p) => ({ ...p, telefono: e.target.value }))} placeholder="10+ dígitos" />
          </div>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 4 }}>Motivo (opcional)</div>
            <Inp value={formNueva.motivo} onChange={(e) => setFormNueva((p) => ({ ...p, motivo: e.target.value }))} placeholder="Motivo de consulta" />
          </div>
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
            <Btn ol col={C.textMid} onClick={() => setSlotNuevo(null)}>
              Cancelar
            </Btn>
            <Btn col={C.green} onClick={guardarNuevaCita} dis={guardando}>
              Guardar
            </Btn>
          </div>
        </div>
      </Modal>

      {vista === "mes" && (
        <Box style={{ padding: 16 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14, flexWrap: "wrap", gap: 8 }}>
            <button
              type="button"
              onClick={() => irMes(-1)}
              style={{ border: `1px solid ${C.border}`, background: C.card, borderRadius: 8, padding: "6px 12px", cursor: "pointer", fontWeight: 700 }}
            >
              ←
            </button>
            <div style={{ fontWeight: 800, fontSize: 16, color: C.text }}>
              {new Date(y, m, 1).toLocaleDateString("es-MX", { month: "long", year: "numeric" })}
            </div>
            <button
              type="button"
              onClick={() => irMes(1)}
              style={{ border: `1px solid ${C.border}`, background: C.card, borderRadius: 8, padding: "6px 12px", cursor: "pointer", fontWeight: 700 }}
            >
              →
            </button>
          </div>
          {loadMes ? (
            <SkeletonTable rows={4} cols={7} />
          ) : (
            <>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(7, minmax(0, 1fr))",
                  gap: 4,
                  marginBottom: 6,
                }}
              >
                {WEEKDAYS_MON.map((w) => (
                  <div key={w} style={{ textAlign: "center", fontSize: 10, fontWeight: 800, color: C.textDim }}>
                    {w}
                  </div>
                ))}
              </div>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(7, minmax(0, 1fr))",
                  gap: 4,
                }}
              >
                {cells.map((cell, idx) => {
                  const n = citasPorDia[cell.sv] || 0;
                  const pasadoEnMes = cell.inMonth && cell.isPast && !cell.isToday;
                  let borderSt = `1px solid ${cell.inMonth ? C.border : "transparent"}`;
                  let bg = "transparent";
                  let color = cell.inMonth ? C.text : C.textDim;
                  let fw = 600;
                  let countCol = BRAND.primary;
                  if (cell.inMonth) {
                    if (cell.isToday) {
                      borderSt = `2px solid ${BRAND.primary}`;
                      bg = n ? BRAND.primary + "1c" : C.card;
                      fw = 800;
                    } else if (pasadoEnMes) {
                      bg = n ? "rgba(148,163,184,0.22)" : "#e8ecf1";
                      color = C.textMid;
                      countCol = C.textMid;
                    } else {
                      bg = n ? BRAND.primary + "14" : C.bg;
                    }
                  }
                  return (
                    <button
                      key={idx}
                      type="button"
                      disabled={!cell.inMonth}
                      onClick={() => elegirDia(cell.sv, cell.inMonth)}
                      style={{
                        minHeight: 52,
                        borderRadius: 8,
                        border: borderSt,
                        background: bg,
                        color,
                        cursor: cell.inMonth ? "pointer" : "default",
                        fontSize: 13,
                        fontWeight: fw,
                        position: "relative",
                        opacity: cell.inMonth ? 1 : 0.35,
                      }}
                    >
                      <div>{cell.d.getDate()}</div>
                      {n > 0 && cell.inMonth && (
                        <div style={{ fontSize: 9, fontWeight: 800, color: countCol, marginTop: 2 }}>{n} cita{n > 1 ? "s" : ""}</div>
                      )}
                    </button>
                  );
                })}
              </div>
              <p style={{ fontSize: 11, color: C.textDim, marginTop: 12, lineHeight: 1.45 }}>
                Toca un día para ver la agenda por horas.{" "}
                <strong style={{ color: C.textMid }}>Hoy</strong> lleva borde azul;{" "}
                <strong style={{ color: C.textMid }}>días pasados</strong> van en gris (historial); el resto es futuro próximo.
                Los días con citas muestran el conteo.
              </p>
            </>
          )}
        </Box>
      )}

      {vista === "dia" && (
        <Box style={{ padding: 16 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 10, marginBottom: 14 }}>
            <div style={{ fontWeight: 800, color: C.text }}>{formatFechaAgendaLargaEs(diaSel)}</div>
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
              <Btn
                sm
                ol
                col={C.textMid}
                onClick={() => {
                  const p = addDaysSv(diaSel, -1);
                  setDiaSel(p);
                  const d = new Date(p + "T12:00:00");
                  setY(d.getFullYear());
                  setM(d.getMonth());
                }}
              >
                Día anterior
              </Btn>
              <Btn
                sm
                ol
                col={C.textMid}
                onClick={() => {
                  const p = addDaysSv(diaSel, 1);
                  setDiaSel(p);
                  const d = new Date(p + "T12:00:00");
                  setY(d.getFullYear());
                  setM(d.getMonth());
                }}
              >
                Día siguiente
              </Btn>
            </div>
          </div>
          {diaSel < hoyISOMexico() && (
            <div
              style={{
                marginBottom: 12,
                padding: "8px 12px",
                borderRadius: 8,
                background: "#e8ecf1",
                border: `1px solid ${C.border}`,
                fontSize: 12,
                color: C.textMid,
                fontWeight: 600,
              }}
            >
              Día pasado — historial de consultas; no se pueden agendar citas nuevas.
            </div>
          )}
          <div style={{ display: "grid", gap: 8 }}>
            {TODOS_HORARIOS_CITA.map((hora) => {
              const ocupada = citaPorHora[hora];
              const disponibles = horariosDisponiblesCita(diaSel);
              const libre = !ocupada && disponibles.includes(hora);
              const esDiaPasado = diaSel < hoyISOMexico();
              const ev = etiquetaEstadoVisual(ocupada);
              const focoAccion =
                mode === "doctora" &&
                ocupada &&
                accionPrincipalDoctora?.cita?.id != null &&
                Number(accionPrincipalDoctora.cita.id) === Number(ocupada.id);
              const franja = franjaAgendaStyle(ocupada, { libre, focoAccion, C, BRAND });
              return (
                <div
                  key={hora}
                  style={{
                    display: "grid",
                    gridTemplateColumns: "minmax(0, 72px) 1fr",
                    gap: 10,
                    alignItems: "stretch",
                    padding: 10,
                    borderRadius: 10,
                    background: franja.background,
                    border: franja.border,
                    boxShadow: franja.boxShadow,
                  }}
                >
                  <div style={{ fontWeight: 800, color: BRAND.primary, fontSize: 15 }}>{hora}</div>
                  <div>
                    {ocupada ? (
                      <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", alignItems: "flex-start" }}>
                        <div style={{ minWidth: 0, flex: 1 }}>
                          {mode === "doctora" ? (
                            <div style={{ color: BRAND.primary, fontWeight: 700, fontSize: 15 }}>{ocupada.nombre}</div>
                          ) : (
                            <button
                              type="button"
                              onClick={() => abrirCita(ocupada)}
                              style={{
                                background: "none",
                                border: "none",
                                padding: 0,
                                cursor: "pointer",
                                color: BRAND.primary,
                                fontWeight: 700,
                                fontSize: 15,
                                textDecoration: "underline",
                                textAlign: "left",
                              }}
                            >
                              {ocupada.nombre}
                            </button>
                          )}
                          <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>{ocupada.motivo || "Consulta"}</div>
                          <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 8 }}>
                            <Tag col={ev.col} sm>
                              {ev.label}
                            </Tag>
                            {(() => {
                              const ep = labelEstadoPagoCita(ocupada);
                              return <Tag col={ep.col} sm>{ep.label}</Tag>;
                            })()}
                            {ocupada.canal && (
                              <Tag col={C.blue} sm>
                                {labelCanal(ocupada)}
                              </Tag>
                            )}
                          </div>
                          {(mode === "admin" || mode === "vendedor") && puedeCancelarCitaCaja(ocupada) && (
                            <div style={{ marginTop: 10 }}>
                              <Btn sm ol col={C.red} onClick={() => cancelarCitaAgenda(ocupada)} dis={guardando}>
                                {esCitaNoShow(ocupada) ? "No se presentó" : "Cancelar cita"}
                              </Btn>
                            </div>
                          )}
                          {mode === "doctora" && (
                            <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginTop: 12, alignItems: "center" }}>
                              {citaPagoOk(ocupada) &&
                                ocupada.estado !== "completada" &&
                                ocupada.estado !== "cancelada" &&
                                ocupada.estado !== "no_asistio" &&
                                ocupada.estado !== "en_consulta" && (
                                  <Btn
                                    sm
                                    col={BRAND.primary}
                                    dis={iniciandoCitaId === ocupada.id}
                                    onClick={() => iniciarConsultaDoctora(ocupada)}
                                  >
                                    {iniciandoCitaId === ocupada.id ? "Abriendo…" : "Entrar a consulta"}
                                  </Btn>
                                )}
                              {ocupada.estado === "en_consulta" && (
                                <Btn sm col={BRAND.primary} onClick={() => continuarConsultaDoctora(ocupada)}>
                                  Continuar consulta
                                </Btn>
                              )}
                              {(ocupada.estado === "completada" || ocupada.estado === "no_asistio") && (
                                <Btn sm ol col={C.textMid} onClick={() => verResumenConsultaDoctora(ocupada)}>
                                  Ver resumen
                                </Btn>
                              )}
                              {!citaPagoOk(ocupada) && ocupada.estado !== "completada" && ocupada.estado !== "cancelada" && (
                                <span style={{ fontSize: 12, color: C.amber, fontWeight: 600 }}>Pendiente de pago en caja</span>
                              )}
                            </div>
                          )}
                        </div>
                      </div>
                    ) : libre ? (
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
                        <span style={{ color: C.green, fontWeight: 700, fontSize: 13 }}>Disponible</span>
                        {(mode === "admin" || mode === "vendedor") && (
                          <Btn sm col={BRAND.primary} onClick={() => setSlotNuevo(hora)}>
                            Agendar
                          </Btn>
                        )}
                      </div>
                    ) : esDiaPasado ? (
                      <span style={{ color: C.textDim, fontSize: 13 }}>Sin cita · día pasado (solo lectura)</span>
                    ) : (
                      <span style={{ color: C.textDim, fontSize: 13 }}>No disponible (horario pasado)</span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
          {!!citasDelDia.length && (
            <Box style={{ marginTop: 16, padding: 12, background: C.bg }}>
              <div style={{ fontSize: 11, fontWeight: 800, color: C.textDim, marginBottom: 4 }}>LISTA DEL DÍA</div>
              {mode === "doctora" && (
                <div style={{ fontSize: 10, color: C.textDim, marginBottom: 8 }}>Orden por hora · estado en cada turno</div>
              )}
              <div style={{ display: "grid", gap: 8 }}>
                {citasDelDia
                  .slice()
                  .sort((a, b) => horaKey(a.hora).localeCompare(horaKey(b.hora)))
                  .map((c) => (
                    <div key={c.id} style={{ display: "flex", justifyContent: "space-between", gap: 8, flexWrap: "wrap" }}>
                      <span style={{ fontWeight: 700 }}>{horaKey(c.hora) || "—"}</span>
                      <span style={{ flex: 1, minWidth: 120 }}>{c.nombre}</span>
                      <Tag col={etiquetaEstadoVisual(c).col} sm>
                        {etiquetaEstadoVisual(c).label}
                      </Tag>
                    </div>
                  ))}
              </div>
            </Box>
          )}
        </Box>
      )}
    </div>
  );
}
