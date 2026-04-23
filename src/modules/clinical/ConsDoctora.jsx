import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, BRAND } from "../../constants";
import { supabase } from "../../supabase";
import { $ } from "../../utils";
import { Box, Tag, Btn, KPI, Modal, showToast, SkeletonKPIs, SkeletonTable } from "../../ui";
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

const C = C_LIGHT;

/** Mi consultorio — agenda del día, KPIs, ficha y consumibles. */
export default function ConsDoctora() {
  const [citas, setCitas] = useState([]);
  const [loading, setLoad] = useState(true);
  const [citaSel, setCitaSel] = useState(null);
  const [prodList, setProdList] = useState([]);
  const [procsList, setProcsList] = useState([]);
  const [guardando, setGuard] = useState(false);
  const [fichaCita, setFichaCita] = useState(null);
  const hoyLocal = new Date().toLocaleDateString("sv-SE");
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

  useEffect(() => {
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
        if (citasRes.error) console.warn("[ConsDoctora] citas KPI:", citasRes.error.message);
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
          } catch { /* ignorar */ }
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
        console.error("[ConsDoctora] kpi:", e);
      } finally {
        if (!cancel) setKpiLoad(false);
      }
    })();
    return () => {
      cancel = true;
    };
  }, [kpiPer]);

  const recargar = useCallback(async () => {
    const [consumibles, citasRes, procRes] = await Promise.all([
      fetchProductosConsumiblesConsultorio(supabase),
      supabase.from("citas").select(`
          id,nombre,telefono,hora,fecha,motivo,estado,canal,pago_estado,cliente_id,
          confirmada_inicio_at,
          consumibles_consulta(id,cantidad,precio,cobrado,nombre,producto_id)
        `)
        .eq("fecha", hoyLocal)
        .in("estado", ["confirmada", "en_consulta", "completada", "pagada"]),
      supabase.from("procedimientos_medicos").select("*").eq("activo", true).order("nombre"),
    ]);
    if (citasRes?.error) console.error("[ConsDoctora] Citas:", citasRes.error);
    if (procRes?.error) console.error("[ConsDoctora] Procedimientos:", procRes.error);
    setProdList(consumibles || []);
    setCitas(citasRes?.data || []);
    setProcsList(procRes?.data || []);
  }, [hoyLocal]);

  useEffect(() => {
    (async () => {
      setLoad(true);
      try {
        await recargar();
      } catch (e) {
        console.error("[ConsDoctora] cargar:", e);
        setProdList([]);
        setCitas([]);
        setProcsList([]);
      } finally {
        setLoad(false);
      }
    })();
  }, [recargar]);

  const agregarConsumible = async (cita, prod, qty) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("agregar_consumible_cita", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_producto_id: prod.id,
        p_cantidad: qty,
        p_precio: prod.precio,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo agregar");
      await recargar();
      const { data: fresh } = await supabase
        .from("citas")
        .select(`*,consumibles_consulta(*)`)
        .eq("id", cita.id)
        .single();
      if (fresh) setCitaSel(fresh);
    } catch (e) {
      console.error(e);
    }
    setGuard(false);
  };

  const confirmarInicio = async (cita) => {
    if (!citaPagoOk(cita)) return;
    const otraEnConsulta = citas.some((x) => x.id !== cita.id && x.estado === "en_consulta");
    if (otraEnConsulta) {
      showToast("Termina la consulta en curso (o márcala como terminada) antes de iniciar otra.", "warning");
      return;
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok, p_cita_id: cita.id, p_estado: "en_consulta",
      });
      if (error) throw error;
      await recargar();
    } catch (e) {
      console.error(e);
      alert("No se pudo confirmar el inicio: " + (e?.message || e));
    }
    setGuard(false);
  };

  const completarCita = async (cita) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const diag = (cita.diagnostico && String(cita.diagnostico).trim())
        ? String(cita.diagnostico).trim()
        : "Consulta finalizada.";
      const meds = Array.isArray(cita.medicamentos_prescritos) ? cita.medicamentos_prescritos : [];
      const procs = Array.isArray(cita.procedimientos_realizados) ? cita.procedimientos_realizados : [];
      const { error } = await supabase.rpc("doctora_completar_consulta", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_diagnostico: diag,
        p_medicamentos: meds,
        p_procedimientos: procs,
        p_completar: true,
      });
      if (error) throw error;
      setCitaSel(null);
      await recargar();
      showToast("Consulta terminada.", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo terminar la consulta: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  const pagoEtiqueta = (c) => {
    if (citaPagoPendiente(c)) return { col: C.amber, txt: "Pendiente de pago" };
    if (citaPagoOk(c) || c.estado === "pagada") return { col: C.green, txt: "Pagada" };
    return { col: C.textDim, txt: "—" };
  };

  const puedeConsumibles = (c) =>
    c.estado !== "completada" && (c.estado === "en_consulta" || c.estado === "confirmada" || c.estado === "pagada");

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
        <div>
          <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: 0 }}>♥ Mi Consultorio</h1>
          <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>
            Dra. Lourdes Lucio Falcón · Médico General · {new Date().toLocaleDateString("es-MX")}
          </div>
        </div>
        <Tag col={C.green}>En turno</Tag>
      </div>

      <div style={{ display: "flex", justifyContent: "flex-end", alignItems: "center", gap: 8, marginBottom: 14, flexWrap: "wrap" }}>
        <span style={{ color: C.textDim, fontSize: 11, fontWeight: 700, letterSpacing: 0.5, marginRight: 4 }}>Indicadores</span>
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
        <>
          <div style={{ display: "flex", gap: 12, marginBottom: 14, flexWrap: "wrap" }}>
            <KPI label="Consultas cerradas" value={kpi.completadas} col={C.green} icon="🏥" sub={kpiPer === "dia" ? "hoy" : kpiPer === "semana" ? "últimos 7 días" : "últimos 30 días"} />
            <KPI label="Tus ingresos (consulta)" value={$(kpi.ingresoDoctorSum)} col={C.purple} icon="💰" sub="parte médico · cerradas" />
            <KPI label="Procedimientos" value={kpi.procedimientosCount} col={C.blue} icon="🩺" sub="en consultas cerradas" />
            <KPI label="Tiempo promedio" value={kpi.tiempoPromMin != null ? `${kpi.tiempoPromMin.toFixed(1)} min` : "—"} col={C.amber} icon="⏱️" sub="consultas con duración" />
          </div>
          <Box style={{ padding: 14, marginBottom: 20 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 8 }}>RECETAS Y FARMACIA (ALINEADO CON DASHBOARD)</div>
            <div style={{ color: C.textMid, fontSize: 12, lineHeight: 1.55 }}>
              <strong style={{ color: C.text }}>{$(kpi.ventasRecetaFarmax)}</strong> en ventas POS con receta del consultorio (origen médico) ·{" "}
              <strong style={{ color: C.text }}>{$(kpi.oportunidadEst)}</strong> oportunidad estimada (
              {kpi.nRecetasExternas} consultas surtidas fuera × {$(kpi.estimadoUnit)}) · renglones prescritos:{" "}
              <strong style={{ color: C.text }}>{kpi.lineas.farmax + kpi.lineas.externa + kpi.lineas.pend}</strong> (Farmax{" "}
              {kpi.lineas.farmax}, fuera/pend. {kpi.lineas.externa + kpi.lineas.pend}, catálogo {kpi.lineas.conProductoId}).
            </div>
          </Box>
        </>
      )}

      <CitaFichaModal
        cita={fichaCita}
        open={!!fichaCita}
        onClose={() => setFichaCita(null)}
        prodList={prodList}
        procsList={procsList}
        onSaved={recargar}
      />

      <Modal open={!!citaSel} onClose={() => setCitaSel(null)} title="➕ Registrar consumibles usados" ac={C.amber}>
        {citaSel && (
          <>
            <div style={{ color: C.textMid, fontSize: 13, marginBottom: 16 }}>
              Paciente:{" "}
              <strong style={{ color: C.text }}>{citaSel.nombre}</strong>
            </div>
            <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 8 }}>Seleccionar consumible</div>
            <div style={{ display: "grid", gap: 6, maxHeight: 300, overflowY: "auto" }}>
              {prodList.map((p) => (
                <div
                  key={p.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 12px",
                    background: C.bg,
                    borderRadius: 8,
                    border: `1px solid ${C.border}`,
                  }}
                >
                  <div>
                    <div style={{ color: C.text, fontSize: 12, fontWeight: 700 }}>{p.nombre}</div>
                    <div style={{ color: C.textMid, fontSize: 11 }}>
                      {$(p.precio)}/ud
                    </div>
                  </div>
                  <div style={{ display: "flex", gap: 4 }}>
                    {[1, 2, 3].map((qty) => (
                      <button
                        key={qty}
                        onClick={() => agregarConsumible(citaSel, p, qty)}
                        disabled={guardando}
                        style={{
                          padding: "4px 10px",
                          borderRadius: 6,
                          border: `1px solid ${C.blue}`,
                          background: C.blueDim,
                          color: C.blue,
                          fontSize: 11,
                          fontWeight: 700,
                          cursor: "pointer",
                        }}
                      >
                        +{qty}
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            {(citaSel.consumibles_consulta || []).length > 0 && (
              <div style={{ marginTop: 16 }}>
                <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 8 }}>Ya registrado</div>
                {citaSel.consumibles_consulta.map((c, i) => (
                  <div key={i} style={{ display: "flex", justifyContent: "space-between", padding: "5px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ color: C.text, fontSize: 12 }}>
                      {c.productos?.nombre || c.nombre} ×{c.cantidad}
                    </span>
                    <span style={{ color: C.amber, fontSize: 12, fontWeight: 700 }}>{$(c.precio * c.cantidad)}</span>
                  </div>
                ))}
              </div>
            )}
            <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
              <Btn onClick={() => setCitaSel(null)} ol col={C.textMid} sm>
                Cerrar
              </Btn>
              <Btn onClick={() => completarCita(citaSel)} col={C.green} dis={guardando}>
                ✓ Terminar consulta
              </Btn>
            </div>
          </>
        )}
      </Modal>

      {loading ? (
        <SkeletonTable rows={3} cols={3} />
      ) : !citas.length ? (
        <Box style={{ padding: 40, textAlign: "center" }}>
          <div style={{ color: C.textMid, fontSize: 14 }}>Sin citas para hoy</div>
        </Box>
      ) : (
        <div style={{ display: "grid", gap: 10 }}>
          {citas.map((c) => {
            const pe = pagoEtiqueta(c);
            return (
              <Box
                key={c.id}
                style={{
                  padding: 18,
                  borderColor:
                    c.estado === "en_consulta" ? C.amber + "60" : c.estado === "completada" ? C.green + "40" : C.border,
                }}
              >
                <div style={{ display: "flex", alignItems: "flex-start", gap: 14, flexWrap: "wrap" }}>
                  <div style={{ color: C.blue, fontWeight: 800, fontSize: 18, width: 55, flexShrink: 0 }}>{c.hora}</div>
                  <div style={{ flex: "1 1 200px", minWidth: 0 }}>
                    <button
                      type="button"
                      onClick={() => setFichaCita(c)}
                      style={{
                        background: "none",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textAlign: "left",
                      }}
                    >
                      <div style={{ color: BRAND.primary, fontWeight: 700, fontSize: 15, textDecoration: "underline" }}>{c.nombre}</div>
                    </button>
                    <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>{c.motivo || "Consulta general"}</div>
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 8 }}>
                      <Tag col={pe.col} sm>
                        {pe.txt}
                      </Tag>
                      {c.canal && (
                        <Tag col={C.blue} sm>
                          {labelCanal(c)}
                        </Tag>
                      )}
                      <Tag
                        col={
                          c.estado === "completada" ? C.green : c.estado === "en_consulta" ? C.amber : c.estado === "pagada" ? C.purple : C.blue
                        }
                        sm
                      >
                        {c.estado || "confirmada"}
                      </Tag>
                    </div>
                    {(c.consumibles_consulta || []).length > 0 && (
                      <div style={{ color: C.amber, fontSize: 11, marginTop: 4 }}>+ {(c.consumibles_consulta || []).length} consumibles registrados</div>
                    )}
                  </div>
                  <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
                    {citaPagoOk(c) && c.estado === "confirmada" && (
                      <Btn sm col={C.green} onClick={() => confirmarInicio(c)} dis={guardando}>
                        Confirmar inicio
                      </Btn>
                    )}
                    {c.estado === "en_consulta" && (
                      <Btn sm col={C.green} onClick={() => completarCita(c)} dis={guardando}>
                        Terminar consulta
                      </Btn>
                    )}
                    {puedeConsumibles(c) && c.estado !== "completada" && (
                      <Btn sm col={C.amber} onClick={() => setCitaSel(c)}>
                        + Consumibles
                      </Btn>
                    )}
                  </div>
                </div>
              </Box>
            );
          })}
        </div>
      )}
    </div>
  );
}
