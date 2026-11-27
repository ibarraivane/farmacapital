import { useCallback, useEffect, useMemo, useState } from "react";
import { supabase } from "../../supabase";
import { parseRpcJsonObject } from "../../utils/rpcJson";
import {
  addDaysISO,
  calcularNominaSemanal,
  DIAS_NOMINA_SEMANA,
  esRpcRhPendiente,
  etiquetaDiaLaboral,
  etiquetaRangoSemana,
  hoyISOMexico,
  sabadoDeSemana,
  salarioSemanalDe,
  semanaNominaDesfasada,
  viernesDeSemana,
} from "../../lib/rhSemana";

const fmt = (n) =>
  new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n || 0);

const ESTADOS = [
  { id: "trabajo", label: "Trabajo" },
  { id: "falta", label: "Falta" },
  { id: "descanso", label: "Descanso" },
];

const SQL_SEMANAL = "sql/patch_rh_pago_semanal_20260822.sql";
const SQL_SEMANA_SABADO = "sql/patch_rh_semana_sabado_viernes_20260926.sql";

function tok() {
  try { return sessionStorage.getItem("farmacapital_session_token") || ""; }
  catch { return ""; }
}

function localPreview(emp, fechaRef, diasTrabajo) {
  const salario = salarioSemanalDe(emp);
  return {
    nombre: emp?.nombre || "",
    salario_semanal: salario,
    diario: calcularNominaSemanal({ salarioSemanal: salario, diasTrabajo: DIAS_NOMINA_SEMANA }).diario,
    semana_inicio: sabadoDeSemana(fechaRef),
    semana_fin: viernesDeSemana(fechaRef),
    dias: [],
    dias_trabajo: diasTrabajo,
    ...calcularNominaSemanal({ salarioSemanal: salario, diasTrabajo }),
    pago: null,
    local: true,
  };
}

export default function NominaSemanalPanel({ empleados, S, C, isMobile }) {
  const activos = useMemo(
    () => (empleados || []).filter((e) => e.estado !== false),
    [empleados],
  );
  const [selEmpId, setSelEmpId] = useState("");
  const [fechaRef, setFechaRef] = useState(() => hoyISOMexico());
  const [semana, setSemana] = useState(null);
  const [loading, setLoading] = useState(false);
  const [sqlPendiente, setSqlPendiente] = useState(false);
  const [msg, setMsg] = useState(null);
  const [folio, setFolio] = useState("");
  const [aplicarImss, setAplicarImss] = useState(false);
  const [diasLocal, setDiasLocal] = useState(DIAS_NOMINA_SEMANA);
  const [salarioDraft, setSalarioDraft] = useState("");
  const [saving, setSaving] = useState(false);

  const selEmp = activos.find((e) => String(e.id) === String(selEmpId));
  const rango = etiquetaRangoSemana(fechaRef);
  const hoy = hoyISOMexico();
  const viernes = viernesDeSemana(fechaRef);
  const midWeek = hoy < viernes && sabadoDeSemana(hoy) === sabadoDeSemana(fechaRef);
  const semanaDesfasada = semanaNominaDesfasada(semana, fechaRef);

  const cargar = useCallback(async () => {
    if (!selEmpId) {
      setSemana(null);
      setSqlPendiente(false);
      return;
    }
    const session = tok();
    if (!session) {
      setMsg({ ok: false, text: "Sesión expirada." });
      return;
    }
    setLoading(true);
    setMsg(null);
    setSemana(null);
    const { data, error } = await supabase.rpc("rh_semana_empleado", {
      p_session_token: session,
      p_empleado_id: Number(selEmpId),
      p_fecha: fechaRef,
    });
    setLoading(false);
    if (error) {
      if (esRpcRhPendiente(error)) {
        setSqlPendiente(true);
        setSemana(null);
        return;
      }
      setSqlPendiente(false);
      setMsg({ ok: false, text: error.message || "No se pudo cargar la semana." });
      setSemana(null);
      return;
    }
    setSqlPendiente(false);
    setSemana(parseRpcJsonObject(data));
  }, [selEmpId, fechaRef]);

  useEffect(() => { cargar(); }, [cargar]);

  useEffect(() => {
    if (!selEmp) {
      setSalarioDraft("");
      setDiasLocal(DIAS_NOMINA_SEMANA);
      return;
    }
    const n = salarioSemanalDe(selEmp);
    setSalarioDraft(n ? String(n) : "");
    setDiasLocal(DIAS_NOMINA_SEMANA);
    setFolio("");
    setAplicarImss(false);
  }, [selEmpId]);

  const vista = semana || (sqlPendiente && selEmp ? localPreview(selEmp, fechaRef, diasLocal) : null);
  const calc = vista
    ? calcularNominaSemanal({
        salarioSemanal: vista.salario_semanal,
        diasTrabajo: semana ? (semana.dias_trabajo || 0) : diasLocal,
        aplicarImss,
      })
    : null;
  const pagado = Boolean(semana?.pago?.id || semana?.pago?.pagado_en);

  const irSemana = (delta) => setFechaRef(addDaysISO(sabadoDeSemana(fechaRef), delta * 7));

  const marcar = async (fecha, estado) => {
    const session = tok();
    if (!session || !selEmpId) return;
    setSaving(true);
    const { data, error } = await supabase.rpc("rh_marcar_dia", {
      p_session_token: session,
      p_empleado_id: Number(selEmpId),
      p_fecha: fecha,
      p_estado: estado,
    });
    setSaving(false);
    if (error) {
      setMsg({ ok: false, text: error.message || "No se pudo marcar el día." });
      return;
    }
    setSemana(parseRpcJsonObject(data));
  };

  const guardarSalario = async () => {
    const session = tok();
    const n = parseFloat(String(salarioDraft).replace(",", "."));
    if (!session || !selEmpId) return;
    if (!Number.isFinite(n) || n < 0) {
      setMsg({ ok: false, text: "Salario semanal inválido." });
      return;
    }
    setSaving(true);
    const { error } = await supabase.rpc("rh_set_salario_semanal", {
      p_session_token: session,
      p_empleado_id: Number(selEmpId),
      p_salario_semanal: n,
    });
    setSaving(false);
    if (error) {
      setMsg({
        ok: false,
        text: esRpcRhPendiente(error)
          ? `Falta actualizar la base. Ejecuta ${SQL_SEMANAL} en Supabase.`
          : error.message,
      });
      return;
    }
    setMsg({ ok: true, text: "Salario semanal guardado." });
    cargar();
  };

  const registrarPago = async (hasta) => {
    if (!selEmp) {
      setMsg({ ok: false, text: "Selecciona un empleado." });
      return;
    }
    const session = tok();
    if (!session) {
      setMsg({ ok: false, text: "Sesión expirada." });
      return;
    }
    setSaving(true);
    if (sqlPendiente) {
      const { error } = await supabase.rpc("registrar_nomina", {
        p_session_token: session,
        p_empleado_id: selEmp.id,
        p_periodo_inicio: sabadoDeSemana(fechaRef),
        p_periodo_fin: viernesDeSemana(fechaRef),
        p_salario_base: calc?.bruto || 0,
        p_horas_extra: 0,
        p_prima_dominical: 0,
        p_bono: 0,
        p_total_percepciones: calc?.bruto || 0,
        p_imss_obrero: calc?.imss || 0,
        p_isr: 0,
        p_total_deducciones: calc?.imss || 0,
        p_neto_pagar: calc?.neto || 0,
      });
      setSaving(false);
      if (error) {
        setMsg({ ok: false, text: error.message || "No se pudo guardar." });
        return;
      }
      setMsg({
        ok: true,
        text: `Nómina de ${selEmp.nombre} guardada. Anótala también en Flujo de caja → Gastos (categoría Nómina) si aún no está.`,
      });
      return;
    }
    const { data, error } = await supabase.rpc("rh_registrar_pago", {
      p_session_token: session,
      p_empleado_id: Number(selEmpId),
      p_fecha: fechaRef,
      p_hasta: hasta,
      p_aplicar_imss: aplicarImss,
      p_folio_spei: folio.trim() || null,
    });
    setSaving(false);
    if (error) {
      setMsg({
        ok: false,
        text: esRpcRhPendiente(error)
          ? `Falta actualizar la base. Ejecuta ${SQL_SEMANAL} en Supabase.`
          : error.message,
      });
      return;
    }
    setSemana(parseRpcJsonObject(data));
    setFolio("");
    setMsg({
      ok: true,
      text: `Pago del viernes registrado. Si ya lo anotaste en Flujo de caja, no lo captures otra vez.`,
    });
  };

  const exportarTXT = () => {
    if (!selEmp || !calc) return;
    const inicio = sabadoDeSemana(fechaRef);
    const fin = viernesDeSemana(fechaRef);
    const L = "─".repeat(44);
    const txt = [
      "╔══════════════════════════════════════════╗",
      "║      FARMACAPITAL — NÓMINA SEMANAL       ║",
      "╚══════════════════════════════════════════╝",
      "",
      `Empleado : ${selEmp.nombre}`,
      `Rol      : ${selEmp.rol}`,
      `Turno    : ${selEmp.turno}`,
      `Periodo  : ${inicio}  →  ${fin}  (pago viernes)`,
      "",
      L, "PERCEPCIONES", L,
      `  Salario semanal       : ${fmt(vista.salario_semanal)}`,
      `  Diario                : ${fmt(calc.diario)}`,
      `  Días pagados          : ${calc.dias}`,
      `  TOTAL PERCEPCIONES    : ${fmt(calc.bruto)}`,
      "",
      L, "DEDUCCIONES", L,
      `  IMSS obrero           : ${fmt(calc.imss)}`,
      `  ISR                   : ${fmt(0)}`,
      "",
      L, `  NETO A PAGAR          : ${fmt(calc.neto)}`, L,
      "",
      `Generado: ${new Date().toLocaleString("es-MX")}`,
      "FarmaCapital · Chinampac de Juárez · CDMX",
    ].join("\n");
    const blob = new Blob([txt], { type: "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `nomina_${selEmp.nombre.replace(/ /g, "_")}_${inicio}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div style={S.section}>
      <div style={S.h2}>💰 Nómina semanal · se paga el viernes</div>
      <p style={{ color: C.textMid, fontSize: 13, margin: "0 0 16px", lineHeight: 1.45 }}>
        Semana de pago: sábado a viernes. El depósito es el viernes.
        El diario es el salario entre 7; al neto solo entra un día marcado en Trabajo.
        Esta pantalla solo arma ese pago. Los horarios y abrir o cerrar caja siguen en su lugar.
        IMSS e ISR van apagados. Esto no se copia solo al flujo de caja: si ya anotaste el SPEI en Gastos, no lo vuelvas a capturar.
      </p>

      <div style={{ display: "flex", flexWrap: "wrap", gap: 10, alignItems: "end", marginBottom: 16 }}>
        <div style={{ minWidth: 200, flex: "1 1 200px" }}>
          <label style={S.label} htmlFor="rh-nomina-empleado">Empleado</label>
          <select
            id="rh-nomina-empleado"
            style={S.select}
            value={selEmpId}
            onChange={(e) => setSelEmpId(e.target.value)}
          >
            <option value="">— Seleccionar —</option>
            {activos.map((e) => (
              <option key={e.id} value={e.id}>{e.nombre}</option>
            ))}
          </select>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
          <button type="button" style={{ ...S.btnBlue, background: "transparent", color: C.text, border: `1px solid ${C.border}` }} onClick={() => irSemana(-1)} aria-label="Semana anterior">←</button>
          <div style={{ fontWeight: 800, color: C.text, minWidth: 140, textAlign: "center" }}>{rango}</div>
          <button type="button" style={{ ...S.btnBlue, background: "transparent", color: C.text, border: `1px solid ${C.border}` }} onClick={() => irSemana(1)} aria-label="Semana siguiente">→</button>
        </div>
      </div>

      {sqlPendiente && (
        <p style={{ color: C.amber, fontSize: 13, fontWeight: 700, margin: "0 0 14px" }}>
          Falta actualizar la base. Ejecuta {SQL_SEMANAL} y después {SQL_SEMANA_SABADO} en Supabase para marcar días y registrar el SPEI del viernes. Mientras tanto puedes calcular y guardar el recibo.
        </p>
      )}

      {semanaDesfasada && (
        <p style={{ color: C.amber, fontSize: 13, fontWeight: 700, margin: "0 0 14px" }}>
          Falta actualizar la base para listar sábado a viernes. Ejecuta {SQL_SEMANA_SABADO} en Supabase. El pago del viernes espera a esa actualización.
        </p>
      )}

      {!selEmp ? (
        <p style={{ color: C.textMid, fontSize: 13 }}>Elige a quién le toca el viernes.</p>
      ) : loading && !vista ? (
        <p style={{ color: C.textMid }}>Cargando semana…</p>
      ) : (
        <>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 160px), 1fr))", gap: 14, marginBottom: 16 }}>
            <div>
              <label style={S.label} htmlFor="rh-salario-semanal">Salario semanal (viernes)</label>
              <input
                id="rh-salario-semanal"
                style={S.input}
                type="number"
                min="0"
                step="0.01"
                value={salarioDraft}
                onChange={(e) => setSalarioDraft(e.target.value)}
                placeholder="1133.32"
              />
            </div>
            <div style={{ display: "flex", alignItems: "end" }}>
              <button type="button" style={S.btnBlue} onClick={guardarSalario} disabled={saving}>
                Guardar salario
              </button>
            </div>
            {sqlPendiente && (
              <div>
                <label style={S.label} htmlFor="rh-dias-local">Días a pagar</label>
                <input
                  id="rh-dias-local"
                  style={S.input}
                  type="number"
                  min="0"
                  max={DIAS_NOMINA_SEMANA}
                  step="1"
                  value={diasLocal}
                  onChange={(e) => setDiasLocal(Math.max(0, Math.min(DIAS_NOMINA_SEMANA, parseInt(e.target.value, 10) || 0)))}
                />
              </div>
            )}
          </div>

          {semana?.dias?.length ? (
            <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
              {semana.dias.map((d) => (
                <div
                  key={d.fecha}
                  style={{
                    display: "flex",
                    flexWrap: "wrap",
                    alignItems: "center",
                    justifyContent: "space-between",
                    gap: 8,
                    padding: "10px 12px",
                    border: `1px solid ${C.border}`,
                    borderRadius: 10,
                    background: C.bg,
                  }}
                >
                  <div>
                    <div style={{ fontWeight: 700, color: C.text, textTransform: "capitalize" }}>{etiquetaDiaLaboral(d.fecha)}</div>
                    {d.abrio_caja ? <div style={{ fontSize: 11, color: C.textMid }}>Abrió caja</div> : null}
                  </div>
                  <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                    {ESTADOS.map((est) => {
                      const on = d.estado === est.id;
                      return (
                        <button
                          key={est.id}
                          type="button"
                          disabled={saving || pagado}
                          onClick={() => marcar(d.fecha, est.id)}
                          style={{
                            padding: "6px 10px",
                            borderRadius: 20,
                            border: `1px solid ${on ? C.blue : C.border}`,
                            background: on ? C.blueDim : "transparent",
                            color: on ? C.blue : C.textMid,
                            fontSize: 11,
                            fontWeight: 700,
                            cursor: pagado ? "not-allowed" : "pointer",
                          }}
                        >
                          {est.label}
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          ) : null}

          {calc && (
            <div style={{ background: C.bg, border: `1px solid ${C.border}`, borderRadius: 10, padding: 20, marginBottom: 16 }}>
              <div style={{
                display: isMobile ? "flex" : "grid",
                flexDirection: isMobile ? "column" : undefined,
                gridTemplateColumns: isMobile ? undefined : "1fr 1fr",
                gap: isMobile ? 20 : "0 32px",
              }}>
                <div>
                  <p style={{ fontSize: 11, color: C.textMid, fontWeight: 700, textTransform: "uppercase", marginBottom: 12 }}>📈 Percepciones</p>
                  {[
                    ["Salario semanal", fmt(vista.salario_semanal)],
                    [`Diario (÷ ${DIAS_NOMINA_SEMANA})`, fmt(calc.diario)],
                    [`Días pagados`, String(calc.dias)],
                  ].map(([lbl, val]) => (
                    <div key={lbl} style={{ display: "flex", justifyContent: "space-between", gap: 10, padding: "5px 0", borderBottom: `1px solid ${C.border}` }}>
                      <span style={{ fontSize: 12, color: C.textMid }}>{lbl}</span>
                      <span style={{ fontSize: 12, color: C.text, fontWeight: 600 }}>{val}</span>
                    </div>
                  ))}
                  <div style={{ display: "flex", justifyContent: "space-between", padding: "10px 0 0" }}>
                    <span style={{ fontWeight: 700, color: C.green, fontSize: 13 }}>Total percepciones</span>
                    <span style={{ fontWeight: 800, color: C.green, fontSize: 15 }}>{fmt(calc.bruto)}</span>
                  </div>
                </div>
                <div style={{ paddingTop: isMobile ? 4 : 0, borderTop: isMobile ? `1px solid ${C.border}` : "none" }}>
                  <p style={{ fontSize: 11, color: C.textMid, fontWeight: 700, textTransform: "uppercase", marginBottom: 12, marginTop: isMobile ? 4 : 0 }}>📉 Deducciones</p>
                  <label style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12, color: C.text, marginBottom: 10 }}>
                    <input
                      type="checkbox"
                      checked={aplicarImss}
                      onChange={(e) => setAplicarImss(e.target.checked)}
                      disabled={pagado}
                    />
                    Aplicar IMSS obrero (2.375%) — apagado
                  </label>
                  <div style={{ display: "flex", justifyContent: "space-between", gap: 10, padding: "5px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ fontSize: 12, color: C.textMid }}>IMSS obrero</span>
                    <span style={{ fontSize: 12, color: C.red, fontWeight: 600 }}>{fmt(calc.imss)}</span>
                  </div>
                  <div style={{ display: "flex", justifyContent: "space-between", gap: 10, padding: "5px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ fontSize: 12, color: C.textMid }}>ISR</span>
                    <span style={{ fontSize: 12, color: C.red, fontWeight: 600 }}>{fmt(0)}</span>
                  </div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 10, padding: "14px 0 0" }}>
                    <span style={{ fontWeight: 800, fontSize: 15, color: C.text }}>💵 Neto a pagar el viernes</span>
                    <span style={{ fontWeight: 900, fontSize: isMobile ? 18 : 20, color: C.green }}>{fmt(calc.neto)}</span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {pagado ? (
            <p style={{ color: C.green, fontSize: 13, fontWeight: 700, margin: "0 0 12px" }}>
              Ya está pagada esta semana{semana.pago?.folio_spei ? ` · folio ${semana.pago.folio_spei}` : ""} · {fmt(semana.pago?.neto)}.
            </p>
          ) : (
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 180px), 1fr))", gap: 12, marginBottom: 12 }}>
              <div>
                <label style={S.label} htmlFor="rh-folio-spei">Folio SPEI (opcional)</label>
                <input
                  id="rh-folio-spei"
                  style={S.input}
                  value={folio}
                  onChange={(e) => setFolio(e.target.value)}
                  placeholder="6349011488"
                />
              </div>
            </div>
          )}

          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            {!pagado && (
              <button type="button" style={S.btnBlue} onClick={() => registrarPago(viernes)} disabled={saving || !calc || calc.dias <= 0 || semanaDesfasada}>
                Registrar pago del viernes
              </button>
            )}
            {!pagado && midWeek && !sqlPendiente && (
              <button
                type="button"
                style={{ ...S.btnBlue, background: "transparent", color: C.text, border: `1px solid ${C.border}` }}
                onClick={() => registrarPago(hoy)}
                disabled={saving}
              >
                Liquidar a hoy
              </button>
            )}
            <button
              type="button"
              style={{ ...S.btnGreen, opacity: selEmp && calc ? 1 : 0.5, cursor: selEmp && calc ? "pointer" : "not-allowed" }}
              onClick={exportarTXT}
              disabled={!selEmp || !calc}
            >
              📥 Exportar TXT
            </button>
          </div>
          {msg && (
            <p style={{ marginTop: 10, color: msg.ok ? C.green : C.red, fontSize: 13, fontWeight: 700 }}>{msg.text}</p>
          )}
        </>
      )}
    </div>
  );
}
