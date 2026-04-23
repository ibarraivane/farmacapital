import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT, BRAND } from "../../constants";
import { supabase } from "../../supabase";
import { $, nombreCompletoPacienteValido, telefonoMxValido } from "../../utils";
import { Box, Tag, Btn, KPI, Modal, showToast, SkeletonKPIs, SkeletonTable, Inp } from "../../ui";
import {
  CONSULTA_PRECIO_DEFAULT,
  CONSULTA_PARTE_DOCTOR,
  citaPagoPendiente,
  citaPagoOk,
  labelCanal,
} from "../../utils/consultaConstants";
import { resumenLineasReceta } from "../../utils/recetaLineas";
import { fetchProductosConsumiblesConsultorio } from "../../utils/consumiblesConsultorio";
import { CitaFichaModal } from "./CitaFichaDoctora";
import {
  TODOS_HORARIOS_CITA,
  horariosDisponiblesCita,
  formatFechaAgendaLargaEs,
  addDaysSv,
} from "../../utils/citasAgenda";

const C = C_LIGHT;

const WEEKDAYS_MON = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

function monthRangeSv(year, month0) {
  const first = `${year}-${String(month0 + 1).padStart(2, "0")}-01`;
  const lastD = new Date(year, month0 + 1, 0).getDate();
  const last = `${year}-${String(month0 + 1).padStart(2, "0")}-${String(lastD).padStart(2, "0")}`;
  return { first, last };
}

function buildMonthCells(year, month0) {
  const first = new Date(year, month0, 1);
  const mondayFirst = (first.getDay() + 6) % 7;
  const cells = [];
  let i = 1 - mondayFirst;
  while (cells.length < 42) {
    const d = new Date(year, month0, i);
    const inMonth = d.getMonth() === month0;
    const sv = d.toLocaleDateString("sv-SE");
    cells.push({ d, inMonth, sv, isToday: sv === new Date().toLocaleDateString("sv-SE") });
    i++;
  }
  return cells;
}

/** Etiqueta UX sobre estados reales en BD (citas.estado, pago_estado, pedido_consulta_id). */
function etiquetaEstadoVisual(cita) {
  if (!cita || cita.estado === "cancelada") return { key: "cancelada", label: "Cancelada", col: C.red };
  if (cita.estado === "pagada" || cita.pago_estado === "pagada") return { key: "pagada", label: "Pagada", col: C.purple };
  if (cita.estado === "completada" && citaPagoPendiente(cita)) {
    return { key: "pendiente_cobro", label: "Pendiente de cobro", col: C.amber };
  }
  if (cita.estado === "completada") return { key: "atendida", label: "Atendida", col: C.green };
  if (cita.estado === "en_consulta") return { key: "en_sala", label: "En consulta", col: C.amber };
  if (cita.estado === "confirmada" && citaPagoOk(cita)) return { key: "confirmada", label: "Confirmada · pagada", col: C.blue };
  if (cita.estado === "confirmada") return { key: "agendada", label: "Agendada (sin pago)", col: C.textMid };
  return { key: "otro", label: cita.estado || "—", col: C.textDim };
}

/**
 * Calendario mensual + agenda por horas + detalle.
 * @param {{ usuario: object, onNavigate?: (id: string) => void }} props
 */
export default function AgendaConsultasModule({ usuario, onNavigate }) {
  const mode = usuario?.rol === "doctora" ? "doctora" : usuario?.rol === "vendedor" ? "vendedor" : "admin";
  const titulo = mode === "doctora" ? "Agenda médica" : "Agenda de consultas";

  const now = new Date();
  const [y, setY] = useState(now.getFullYear());
  const [m, setM] = useState(now.getMonth());
  const [vista, setVista] = useState("mes"); // mes | dia
  const [diaSel, setDiaSel] = useState(() => new Date().toLocaleDateString("sv-SE"));
  const [citasMes, setCitasMes] = useState([]);
  const [loadMes, setLoadMes] = useState(true);
  const [fichaCita, setFichaCita] = useState(null);
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
    completadas: 0,
    ingresoDoctorSum: 0,
    procedimientosCount: 0,
    tiempoPromMin: null,
    ventasRecetaFarmax: 0,
    nRecetasExternas: 0,
    oportunidadEst: 0,
    estimadoUnit: 350,
    lineas: { farmax: 0, externa: 0, pend: 0, conProductoId: 0 },
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

  const citaPorHora = useMemo(() => {
    const map = {};
    for (const c of citasDelDia) {
      if (c.hora) map[c.hora] = c;
    }
    return map;
  }, [citasDelDia]);

  useEffect(() => {
    if (mode !== "vendedor") return;
    setVista("dia");
    const h = new Date().toLocaleDateString("sv-SE");
    setDiaSel(h);
    const d = new Date();
    setY(d.getFullYear());
    setM(d.getMonth());
  }, [mode]);

  const cargarMes = useCallback(async () => {
    setLoadMes(true);
    try {
      const { data, error } = await supabase
        .from("citas")
        .select(
          "id,nombre,telefono,hora,fecha,motivo,estado,pago_estado,cliente_id,canal,diagnostico,observaciones,pedido_consulta_id,confirmada_inicio_at"
        )
        .gte("fecha", mesDesde)
        .lte("fecha", mesHasta)
        .neq("estado", "cancelada");
      if (error) throw error;
      setCitasMes(data || []);
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
      const dias = kpiPer === "dia" ? 1 : kpiPer === "semana" ? 7 : 30;
      const desdeFecha = new Date(Date.now() - dias * 86400000).toISOString().split("T")[0];
      const desdeIso = new Date(Date.now() - dias * 86400000).toISOString();
      try {
        const [citasRes, cfgRes, extRes, pedRec] = await Promise.all([
          supabase
            .from("citas")
            .select("id,estado,ingreso_doctor,duracion_consulta_segundos,procedimientos_realizados,medicamentos_prescritos")
            .gte("fecha", desdeFecha)
            .neq("estado", "cancelada"),
          supabase.from("configuracion").select("valor").eq("clave", "estimado_receta_externa").maybeSingle(),
          supabase
            .from("citas")
            .select("id", { count: "exact", head: true })
            .gte("fecha", desdeFecha)
            .eq("receta_surtido_en", "externa")
            .neq("estado", "cancelada")
            .or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
          supabase
            .from("pedidos")
            .select("total")
            .gte("created_at", desdeIso)
            .eq("estado", "completado")
            .eq("receta_origen", "medico_farmax"),
        ]);
        if (cancel) return;
        const rows = citasRes.data || [];
        const completadas = rows.filter((c) => c.estado === "completada" || c.estado === "pagada");
        const ingresoDoctorSum = completadas.reduce((a, c) => {
          const v = parseFloat(c.ingreso_doctor);
          if (Number.isFinite(v)) return a + v;
          return a + CONSULTA_PRECIO_DEFAULT * CONSULTA_PARTE_DOCTOR;
        }, 0);
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
        const lineas = resumenLineasReceta(rows);
        const estRaw = parseFloat(cfgRes.data?.valor);
        const estimadoUnit = Number.isFinite(estRaw) && estRaw >= 0 ? estRaw : 350;
        const nRecetasExternas = extRes.count ?? 0;
        const ventasRecetaFarmax = (pedRec.data || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        setKpi({
          completadas: completadas.length,
          ingresoDoctorSum,
          procedimientosCount,
          tiempoPromMin,
          ventasRecetaFarmax,
          nRecetasExternas,
          oportunidadEst: nRecetasExternas * estimadoUnit,
          estimadoUnit,
          lineas,
        });
      } catch (e) {
        console.error("[Agenda] kpi:", e);
      } finally {
        if (!cancel) setKpiLoad(false);
      }
    })();
    return () => {
      cancel = true;
    };
  }, [kpiPer, mode]);

  const prepararFicha = useCallback(async () => {
    const [consumibles, procRes] = await Promise.all([
      fetchProductosConsumiblesConsultorio(supabase),
      supabase.from("procedimientos_medicos").select("*").eq("activo", true).order("nombre"),
    ]);
    setProdList(consumibles || []);
    setProcsList(procRes?.data || []);
  }, []);

  useEffect(() => {
    if (fichaCita && (mode === "doctora" || mode === "admin")) prepararFicha();
  }, [mode, fichaCita, prepararFicha]);

  const abrirCita = (cita) => {
    if (mode === "vendedor") {
      setDetalleSimple(cita);
      return;
    }
    setFichaCita(cita);
    if (mode === "doctora") prepararFicha();
  };

  const guardarNuevaCita = async () => {
    if (!slotNuevo || !formNueva.nombre?.trim() || !formNueva.telefono?.trim()) {
      showToast("Nombre y teléfono son obligatorios.", "warning");
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
      const { data: ocupado } = await supabase
        .from("citas")
        .select("id")
        .eq("fecha", diaSel)
        .eq("hora", slotNuevo)
        .neq("estado", "cancelada");
      if (ocupado?.length >= 1) {
        showToast("Ese horario ya está ocupado.", "warning");
        setGuard(false);
        return;
      }
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const canal = "mostrador";
      const { data: resp, error } = await supabase.rpc("crear_cita", {
        p_session_token: tok,
        p_nombre: formNueva.nombre.trim(),
        p_telefono: formNueva.telefono.trim(),
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
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, flexWrap: "wrap", marginBottom: 18 }}>
        <div>
          <h1 style={{ color: C.text, fontSize: 22, fontWeight: 800, margin: 0 }}>{titulo}</h1>
          <p style={{ color: C.textMid, fontSize: 13, margin: "6px 0 0" }}>
            {mode === "vendedor"
              ? "Consultas del día y cobros en mostrador; sin detalle clínico completo."
              : mode === "doctora"
                ? "Calendario y citas; el cobro lo realiza caja en POS / Cobrar consulta."
                : "Vista completa del consultorio: calendario, horarios y expediente."}
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <button
            type="button"
            onClick={() => setVista(vista === "mes" ? "dia" : "mes")}
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
            {vista === "mes" ? "Ver día seleccionado" : "Ver mes"}
          </button>
        </div>
      </div>

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
            <SkeletonKPIs count={4} />
          ) : (
            <div style={{ display: "flex", gap: 12, marginBottom: 18, flexWrap: "wrap" }}>
              <KPI label="Consultas cerradas" value={kpi.completadas} col={C.green} icon="🏥" sub={kpiPer === "dia" ? "hoy" : kpiPer === "semana" ? "7 días" : "30 días"} />
              <KPI label="Ingresos (consulta)" value={$(kpi.ingresoDoctorSum)} col={C.purple} icon="💰" sub="parte médico" />
              <KPI label="Procedimientos" value={kpi.procedimientosCount} col={C.blue} icon="🩺" />
              <KPI label="Tiempo prom." value={kpi.tiempoPromMin != null ? `${kpi.tiempoPromMin.toFixed(1)} min` : "—"} col={C.amber} icon="⏱️" />
            </div>
          )}
        </>
      )}

      <CitaFichaModal
        cita={fichaCita}
        open={!!fichaCita}
        onClose={() => setFichaCita(null)}
        prodList={prodList}
        procsList={procsList}
        onSaved={cargarMes}
        readOnly={false}
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
              <Btn
                col={BRAND.primary}
                onClick={() => {
                  setDetalleSimple(null);
                  onNavigate?.("cons_cobro");
                }}
              >
                Ir a cobrar consulta
              </Btn>
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
                  return (
                    <button
                      key={idx}
                      type="button"
                      disabled={!cell.inMonth}
                      onClick={() => elegirDia(cell.sv, cell.inMonth)}
                      style={{
                        minHeight: 52,
                        borderRadius: 8,
                        border: cell.isToday ? `2px solid ${BRAND.primary}` : `1px solid ${cell.inMonth ? C.border : "transparent"}`,
                        background: cell.inMonth ? (n ? BRAND.primary + "14" : C.bg) : "transparent",
                        color: cell.inMonth ? C.text : C.textDim,
                        cursor: cell.inMonth ? "pointer" : "default",
                        fontSize: 13,
                        fontWeight: cell.isToday ? 800 : 600,
                        position: "relative",
                        opacity: cell.inMonth ? 1 : 0.35,
                      }}
                    >
                      <div>{cell.d.getDate()}</div>
                      {n > 0 && cell.inMonth && (
                        <div style={{ fontSize: 9, fontWeight: 800, color: BRAND.primary, marginTop: 2 }}>{n} cita{n > 1 ? "s" : ""}</div>
                      )}
                    </button>
                  );
                })}
              </div>
              <p style={{ fontSize: 11, color: C.textDim, marginTop: 12 }}>
                Toca un día para ver la agenda por horas. Los días con citas aparecen resaltados.
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
          <div style={{ display: "grid", gap: 8 }}>
            {TODOS_HORARIOS_CITA.map((hora) => {
              const ocupada = citaPorHora[hora];
              const disponibles = horariosDisponiblesCita(diaSel);
              const libre = !ocupada && disponibles.includes(hora);
              const ev = etiquetaEstadoVisual(ocupada);
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
                    border: `1px solid ${ocupada ? ev.col + "55" : C.border}`,
                    background: ocupada ? C.card : libre ? C.greenDim : C.bg,
                  }}
                >
                  <div style={{ fontWeight: 800, color: BRAND.primary, fontSize: 15 }}>{hora}</div>
                  <div>
                    {ocupada ? (
                      <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", alignItems: "flex-start" }}>
                        <div style={{ minWidth: 0 }}>
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
                          <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>{ocupada.motivo || "Consulta"}</div>
                          <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 8 }}>
                            <Tag col={ev.col} sm>
                              {ev.label}
                            </Tag>
                            {ocupada.canal && (
                              <Tag col={C.blue} sm>
                                {labelCanal(ocupada)}
                              </Tag>
                            )}
                          </div>
                        </div>
                      </div>
                    ) : libre ? (
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
                        <span style={{ color: C.green, fontWeight: 700, fontSize: 13 }}>Disponible</span>
                        {(mode === "doctora" || mode === "admin" || mode === "vendedor") && (
                          <Btn sm col={BRAND.primary} onClick={() => setSlotNuevo(hora)}>
                            Agendar
                          </Btn>
                        )}
                      </div>
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
              <div style={{ fontSize: 11, fontWeight: 800, color: C.textDim, marginBottom: 8 }}>LISTA DEL DÍA</div>
              <div style={{ display: "grid", gap: 8 }}>
                {citasDelDia
                  .slice()
                  .sort((a, b) => String(a.hora).localeCompare(String(b.hora)))
                  .map((c) => (
                    <div key={c.id} style={{ display: "flex", justifyContent: "space-between", gap: 8, flexWrap: "wrap" }}>
                      <span style={{ fontWeight: 700 }}>{c.hora}</span>
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
