import { useState, useEffect } from "react";
import { C_LIGHT, BRAND } from "../../../constants";
import { supabase } from "../../../supabase";
import { Box, Tag } from "../../../ui";

const C = C_LIGHT;

/** Expediente clínico agregado por teléfono (modal, solo lectura). */
export function ExpedientePaciente({ telefono, nombre, onVerCita }) {
  const [citas, setCitas] = useState([]);
  const [loading, setLoading] = useState(true);

  const normExpediente = (raw) => {
    if (raw && typeof raw === "object") return raw;
    if (typeof raw === "string") {
      try {
        const p = JSON.parse(raw);
        return typeof p === "object" && p !== null ? p : {};
      } catch {
        return {};
      }
    }
    return {};
  };

  const normSignos = (raw) => {
    if (raw && typeof raw === "object") return raw;
    if (typeof raw === "string") {
      try {
        const p = JSON.parse(raw);
        return typeof p === "object" && p !== null ? p : null;
      } catch {
        return null;
      }
    }
    return null;
  };

  useEffect(() => {
    (async () => {
      if (!telefono) {
        setLoading(false);
        return;
      }
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) {
        setCitas([]);
        setLoading(false);
        return;
      }
      const { data, error } = await supabase.rpc("empleado_listar_citas_expediente_paciente", {
        p_session_token: tok,
        p_telefono: telefono,
      });
      if (error) {
        console.error("[ExpedientePaciente]", error);
        const { data: fb } = await supabase
          .from("citas")
          .select(`
            id, nombre, telefono, fecha, hora, motivo, estado, pago_estado,
            diagnostico, notas_medico, medicamentos_prescritos,
            seguimiento_dias, seguimiento_fecha, seguimiento_nota,
            signos_vitales, expediente_json, procedimientos_realizados,
            duracion_consulta_segundos, confirmada_inicio_at, consulta_fin_at,
            ingreso_doctor, precio_consulta_cobrado,
            consumibles_consulta(precio, cantidad, cobrado, nombre, producto_id)
          `)
          .eq("telefono", telefono)
          .neq("estado", "cancelada")
          .order("fecha", { ascending: false })
          .order("hora", { ascending: false });
        setCitas(fb || []);
      } else {
        setCitas(Array.isArray(data) ? data : []);
      }
      setLoading(false);
    })();
  }, [telefono]);

  if (loading) {
    return <div style={{ color: C.textMid, padding: 30, textAlign: "center" }}>Cargando expediente…</div>;
  }

  if (!citas.length) {
    return (
      <div style={{ color: C.textMid, padding: 30, textAlign: "center" }}>
        Sin consultas previas{nombre ? ` para ${nombre}` : ""}.
      </div>
    );
  }

  const ultimaConExp = citas.find((c) => {
    const ej = c.expediente_json;
    return ej && (typeof ej === "object" || (typeof ej === "string" && ej.trim().startsWith("{")));
  });
  const exp = normExpediente(ultimaConExp?.expediente_json);
  const edad = exp.edad || "—";
  const sexo = exp.sexo || "—";
  const alergias = exp.alergias || "Sin registrar";
  const antecedentes = exp.antecedentes || "Sin registrar";

  const completadas = citas.filter((c) => c.estado === "completada" || c.estado === "pagada");
  const primera = citas[citas.length - 1];
  const ultima = citas[0];

  let frecuenciaTxt = "—";
  if (citas.length >= 2 && primera?.fecha && ultima?.fecha) {
    const diasEntre = Math.floor(
      (new Date(ultima.fecha) - new Date(primera.fecha)) / (1000 * 60 * 60 * 24)
    );
    const diasPorVisita = diasEntre / (citas.length - 1);
    if (diasPorVisita < 14) frecuenciaTxt = "semanal";
    else if (diasPorVisita < 45) frecuenciaTxt = "~1 vez al mes";
    else if (diasPorVisita < 120) frecuenciaTxt = "~cada 3 meses";
    else if (diasPorVisita < 200) frecuenciaTxt = "~cada 6 meses";
    else frecuenciaTxt = "ocasional";
  }

  const conVitalesRaw = completadas
    .map((c) => ({ c, sv: normSignos(c.signos_vitales) }))
    .filter((x) => x.sv)
    .slice(0, 5);
  const conVitales = conVitalesRaw.map((x) => ({ ...x.c, _sv: x.sv }));

  const calcPromNum = (campo) => {
    const valores = conVitales
      .map((c) => parseFloat(c._sv[campo]))
      .filter((v) => Number.isFinite(v));
    if (!valores.length) return null;
    return (valores.reduce((a, b) => a + b, 0) / valores.length).toFixed(1);
  };

  const promTA = (() => {
    const valores = conVitales.map((c) => c._sv.ta).filter(Boolean);
    if (!valores.length) return null;
    const sis = [];
    const dia = [];
    valores.forEach((v) => {
      const [s, d] = String(v).split("/").map((x) => parseFloat(x));
      if (Number.isFinite(s)) sis.push(s);
      if (Number.isFinite(d)) dia.push(d);
    });
    if (!sis.length) return null;
    const pSis = Math.round(sis.reduce((a, b) => a + b, 0) / sis.length);
    const pDia = dia.length ? Math.round(dia.reduce((a, b) => a + b, 0) / dia.length) : null;
    return pDia !== null ? `${pSis}/${pDia}` : String(pSis);
  })();

  const promFC = calcPromNum("fc");
  const promTemp = calcPromNum("temp");
  const promSat = calcPromNum("sat");
  const promPeso = calcPromNum("peso");

  let tendenciaPeso = null;
  if (conVitales.length >= 2) {
    const pesos = conVitales
      .map((c) => ({ fecha: c.fecha, peso: parseFloat(c._sv.peso) }))
      .filter((p) => Number.isFinite(p.peso));
    if (pesos.length >= 2) {
      const diffNum = pesos[0].peso - pesos[pesos.length - 1].peso;
      const diff = diffNum.toFixed(1);
      if (Math.abs(parseFloat(diff)) > 0.5) {
        tendenciaPeso = diffNum > 0
          ? `↑ ${diff} kg desde ${pesos[pesos.length - 1].fecha}`
          : `↓ ${Math.abs(parseFloat(diff))} kg desde ${pesos[pesos.length - 1].fecha}`;
      }
    }
  }

  const dxCount = {};
  completadas.forEach((c) => {
    if (c.diagnostico) {
      const dx = c.diagnostico.trim();
      if (dx) dxCount[dx] = (dxCount[dx] || 0) + 1;
    }
  });
  const topDx = Object.entries(dxCount)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5);

  const medsCount = {};
  completadas.forEach((c) => {
    let meds = c.medicamentos_prescritos;
    if (typeof meds === "string") {
      try { meds = JSON.parse(meds || "[]"); } catch { meds = []; }
    }
    if (Array.isArray(meds)) {
      meds.forEach((m) => {
        const nom = String(m.medicamento || m.nombre || "").trim();
        if (nom) medsCount[nom] = (medsCount[nom] || 0) + 1;
      });
    }
  });
  const topMeds = Object.entries(medsCount)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5);

  const sectionTitle = {
    color: C.textDim,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: 1.5,
    textTransform: "uppercase",
    marginBottom: 8,
  };

  const dataRow = {
    display: "flex",
    justifyContent: "space-between",
    fontSize: 12,
    padding: "3px 0",
  };

  return (
    <div style={{ maxHeight: "70vh", overflowY: "auto" }}>
      <Box style={{ padding: 14, marginBottom: 12 }}>
        <div style={sectionTitle}>📋 Datos generales</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, fontSize: 12 }}>
          <div><strong style={{ color: C.textMid }}>Nombre:</strong> <span style={{ color: C.text }}>{nombre}</span></div>
          <div><strong style={{ color: C.textMid }}>Edad:</strong> <span style={{ color: C.text }}>{edad}</span></div>
          <div><strong style={{ color: C.textMid }}>Sexo:</strong> <span style={{ color: C.text }}>{sexo}</span></div>
          <div><strong style={{ color: C.textMid }}>Teléfono:</strong> <span style={{ color: C.text }}>{telefono || "—"}</span></div>
        </div>
        <div style={{ marginTop: 10, paddingTop: 10, borderTop: `1px solid ${C.border}` }}>
          <div style={{ fontSize: 12, marginBottom: 4 }}>
            <strong style={{ color: C.red }}>⚠️ Alergias:</strong> <span style={{ color: C.text }}>{alergias}</span>
          </div>
          <div style={{ fontSize: 12 }}>
            <strong style={{ color: C.textMid }}>Antecedentes:</strong> <span style={{ color: C.text }}>{antecedentes}</span>
          </div>
        </div>
      </Box>

      <Box style={{ padding: 14, marginBottom: 12 }}>
        <div style={sectionTitle}>📊 Resumen clínico</div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(120px, 1fr))", gap: 12 }}>
          <div>
            <div style={{ color: C.blue, fontWeight: 800, fontSize: 22 }}>{citas.length}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>Total consultas</div>
          </div>
          <div>
            <div style={{ color: C.green, fontWeight: 800, fontSize: 22 }}>{completadas.length}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>Completadas</div>
          </div>
          <div>
            <div style={{ color: C.textDim, fontWeight: 800, fontSize: 14 }}>{primera?.fecha || "—"}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>Primera visita</div>
          </div>
          <div>
            <div style={{ color: C.purple, fontWeight: 800, fontSize: 14 }}>{ultima?.fecha || "—"}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>Última visita</div>
          </div>
          <div>
            <div style={{ color: C.amber, fontWeight: 800, fontSize: 14 }}>{frecuenciaTxt}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>Frecuencia</div>
          </div>
        </div>
      </Box>

      {conVitales.length > 0 && (
        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={sectionTitle}>💓 Signos vitales (promedio últimas {conVitales.length})</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(130px, 1fr))", gap: 10 }}>
            {promTA && (
              <div>
                <div style={{ color: C.red, fontWeight: 700, fontSize: 16 }}>{promTA}</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Presión arterial</div>
              </div>
            )}
            {promFC && (
              <div>
                <div style={{ color: C.blue, fontWeight: 700, fontSize: 16 }}>{promFC} bpm</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Frec. cardíaca</div>
              </div>
            )}
            {promTemp && (
              <div>
                <div style={{ color: C.amber, fontWeight: 700, fontSize: 16 }}>{promTemp}°C</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Temperatura</div>
              </div>
            )}
            {promSat && (
              <div>
                <div style={{ color: C.green, fontWeight: 700, fontSize: 16 }}>{promSat}%</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Saturación O₂</div>
              </div>
            )}
            {promPeso && (
              <div>
                <div style={{ color: C.purple, fontWeight: 700, fontSize: 16 }}>{promPeso} kg</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>
                  Peso {tendenciaPeso && <span style={{ color: C.amber, fontSize: 10 }}> {tendenciaPeso}</span>}
                </div>
              </div>
            )}
          </div>
        </Box>
      )}

      {topDx.length > 0 && (
        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={sectionTitle}>🩺 Diagnósticos frecuentes</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {topDx.map(([dx, count], idx) => (
              <div key={dx} style={dataRow}>
                <span style={{ color: C.text }}>{idx + 1}. {dx}</span>
                <Tag col={C.amber} sm>{count} {count === 1 ? "vez" : "veces"}</Tag>
              </div>
            ))}
          </div>
        </Box>
      )}

      {topMeds.length > 0 && (
        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={sectionTitle}>💊 Medicamentos más recetados</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {topMeds.map(([med, count], idx) => (
              <div key={med} style={dataRow}>
                <span style={{ color: C.text }}>{idx + 1}. {med}</span>
                <Tag col={C.blue} sm>{count} {count === 1 ? "receta" : "recetas"}</Tag>
              </div>
            ))}
          </div>
        </Box>
      )}

      <Box style={{ padding: 14, marginBottom: 12 }}>
        <div style={sectionTitle}>📅 Historial de consultas ({citas.length})</div>
        <div style={{ display: "grid", gap: 8, maxHeight: 300, overflowY: "auto" }}>
          {citas.map((c) => (
            <div
              key={c.id}
              style={{
                padding: 10,
                background: C.bg,
                border: `1px solid ${C.border}`,
                borderRadius: 8,
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
                <div>
                  <strong style={{ color: C.text }}>{c.fecha}</strong>
                  <span style={{ color: C.blue, marginLeft: 8, fontWeight: 700 }}>{c.hora}</span>
                </div>
                <Tag
                  col={
                    c.estado === "pagada" || c.estado === "completada" ? C.green :
                    c.estado === "en_consulta" ? C.amber : C.textDim
                  }
                  sm
                >
                  {c.estado}
                </Tag>
              </div>
              <div style={{ color: C.textMid, fontSize: 12, marginBottom: 2 }}>
                <strong>Motivo:</strong> {c.motivo || "Consulta general"}
              </div>
              {c.diagnostico && (
                <div style={{ color: C.textDim, fontSize: 11, marginBottom: 6 }}>
                  <strong>Dx:</strong> {c.diagnostico}
                </div>
              )}
              {c.seguimiento_fecha && (
                <div style={{ color: C.purple, fontSize: 11, fontWeight: 700, marginBottom: 6 }}>
                  Seguimiento sugerido: {c.seguimiento_fecha}
                  {c.seguimiento_nota ? ` · ${c.seguimiento_nota}` : ""}
                </div>
              )}
              <button
                type="button"
                onClick={() => onVerCita(c)}
                style={{
                  padding: "5px 10px",
                  borderRadius: 6,
                  border: `1px solid ${BRAND.primary}`,
                  background: BRAND.primary + "18",
                  color: BRAND.primary,
                  fontSize: 11,
                  fontWeight: 700,
                  cursor: "pointer",
                }}
              >
                👁️ Ver ficha completa
              </button>
            </div>
          ))}
        </div>
      </Box>
    </div>
  );
}
