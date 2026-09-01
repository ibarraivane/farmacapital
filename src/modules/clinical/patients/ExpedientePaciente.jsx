import { useState, useEffect, useMemo } from "react";
import { C_LIGHT, BRAND } from "../../../constants";
import { supabase } from "../../../supabase";
import { Box, Tag } from "../../../ui";
import { EvolucionClinica } from "./EvolucionClinica";
import {
  promedioCampo,
  promedioTA,
  puntosDesdeCitas,
  tendenciaCampo,
} from "../../../lib/evolucionClinica";

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

  const serieVitales = useMemo(() => puntosDesdeCitas(citas), [citas]);

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

  const promTA = promedioTA(serieVitales)?.texto || null;
  const promFC = promedioCampo(serieVitales, "fc", 1);
  const promTemp = promedioCampo(serieVitales, "temp", 1);
  const promSat = promedioCampo(serieVitales, "sat", 1);
  const promPeso = promedioCampo(serieVitales, "peso", 1);
  const promTalla = promedioCampo(serieVitales, "tallaEfectiva", 1);
  const tendenciaPeso = tendenciaCampo(serieVitales, "peso", { umbral: 0.5, decimales: 1, unidad: " kg" });

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

      <EvolucionClinica puntos={serieVitales} />

      {serieVitales.length > 0 && (
        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={sectionTitle}>💓 Promedio de signos ({serieVitales.length} {serieVitales.length === 1 ? "consulta" : "consultas"})</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(130px, 1fr))", gap: 10 }}>
            {promTA && (
              <div>
                <div style={{ color: C.red, fontWeight: 700, fontSize: 16 }}>{promTA}</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Presión arterial</div>
              </div>
            )}
            {promFC != null && (
              <div>
                <div style={{ color: C.blue, fontWeight: 700, fontSize: 16 }}>{promFC} lpm</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Frec. cardíaca</div>
              </div>
            )}
            {promTemp != null && (
              <div>
                <div style={{ color: C.amber, fontWeight: 700, fontSize: 16 }}>{promTemp}°C</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Temperatura</div>
              </div>
            )}
            {promSat != null && (
              <div>
                <div style={{ color: C.green, fontWeight: 700, fontSize: 16 }}>{promSat}%</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Saturación O₂</div>
              </div>
            )}
            {promPeso != null && (
              <div>
                <div style={{ color: C.purple, fontWeight: 700, fontSize: 16 }}>{promPeso} kg</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>
                  Peso {tendenciaPeso && <span style={{ color: C.amber, fontSize: 10 }}> {tendenciaPeso.texto}</span>}
                </div>
              </div>
            )}
            {promTalla != null && (
              <div>
                <div style={{ color: C.teal, fontWeight: 700, fontSize: 16 }}>{promTalla} cm</div>
                <div style={{ color: C.textMid, fontSize: 11 }}>Talla</div>
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
