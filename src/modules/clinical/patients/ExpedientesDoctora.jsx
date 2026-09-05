import { useState, useEffect, useCallback } from "react";
import { FolderOpen } from "lucide-react";
import { C_LIGHT, BRAND } from "../../../constants";
import { PageHero } from "../../../components/AdminChrome";
import { supabase } from "../../../supabase";
import { Box, Tag, Inp, Modal, SkeletonTable } from "../../../ui";
import { CitaFichaModal } from "../CitaFichaDoctora";
import { ExpedientePaciente } from "./ExpedientePaciente";
import { productMatchesSearchQuery } from "../../../utils/fuzzySearch";

const C = C_LIGHT;

function agruparPacientesDesdeCitas(data) {
  const byPhone = new Map();
  for (const c of data || []) {
    const t = String(c.telefono || "").trim();
    if (!t) continue;
    const completada =
      c.estado === "completada" ||
      c.estado === "en_consulta" ||
      (c.diagnostico && String(c.diagnostico).trim()) ||
      c.consulta_fin_at;
    if (!completada) continue;
    const cur = byPhone.get(t);
    if (!cur) {
      byPhone.set(t, {
        telefono: t,
        nombre: (c.nombre || "").trim() || "—",
        ultima: c.fecha,
        primera: c.fecha,
        n: 1,
        n_completadas: 1,
      });
    } else {
      cur.n += 1;
      cur.n_completadas += 1;
      if (c.fecha < cur.primera) cur.primera = c.fecha;
      if (c.fecha > cur.ultima) {
        cur.ultima = c.fecha;
        if ((c.nombre || "").trim()) cur.nombre = c.nombre.trim();
      }
    }
  }
  return Array.from(byPhone.values()).sort((a, b) => b.ultima.localeCompare(a.ultima));
}

/** Lista de pacientes por teléfono + expediente / ficha en solo lectura. */
export default function ExpedientesDoctora() {
  const [pacientes, setPacientes] = useState([]);
  const [loading, setLoad] = useState(true);
  const [loadErr, setLoadErr] = useState("");
  const [busq, setBusq] = useState("");
  const [pacienteModal, setPacienteModal] = useState(null);
  const [citaVerModal, setCitaVerModal] = useState(null);

  const cargarPacientes = useCallback(async () => {
    setLoad(true);
    setLoadErr("");
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      setPacientes([]);
      setLoadErr("Sesión expirada. Vuelve a iniciar sesión en el admin.");
      setLoad(false);
      return;
    }

    const { data, error } = await supabase.rpc("empleado_listar_pacientes_expedientes", {
      p_session_token: tok,
      p_limite: 500,
    });

    if (error) {
      console.error("[ExpedientesDoctora] RPC:", error);
      const desde = new Date();
      desde.setFullYear(desde.getFullYear() - 3);
      const hasta = new Date();
      hasta.setFullYear(hasta.getFullYear() + 1);
      const pad = (n) => String(n).padStart(2, "0");
      const toSv = (dt) => `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())}`;
      const { data: fallback, error: fbErr } = await supabase.rpc("empleado_agenda_listar_citas_rango_fecha", {
        p_session_token: tok,
        p_fecha_desde: toSv(desde),
        p_fecha_hasta: toSv(hasta),
      });
      if (fbErr) {
        setLoadErr(fbErr.message || "No se pudieron cargar los expedientes.");
        setPacientes([]);
      } else {
        const rows = Array.isArray(fallback) ? fallback : [];
        setPacientes(agruparPacientesDesdeCitas(rows));
        if (!rows.length) {
          setLoadErr("");
        } else {
          setLoadErr("Usando respaldo local. Ejecuta sql/rpc_expedientes_pacientes.sql en Supabase para el listado optimizado.");
        }
      }
    } else {
      const rows = Array.isArray(data) ? data : [];
      setPacientes(rows);
    }
    setLoad(false);
  }, []);

  useEffect(() => {
    cargarPacientes();
  }, [cargarPacientes]);

  const filtrados = pacientes.filter((r) => {
    const s = busq.trim();
    if (!s) return true;
    const dig = s.replace(/\D/g, "");
    if (dig.length >= 3 && r.telefono.replace(/\D/g, "").includes(dig)) return true;
    return productMatchesSearchQuery(r, busq, [(x) => x.nombre]);
  });

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16, flexWrap: "wrap", gap: 12 }}>
        <div style={{ flex: "1 1 240px", minWidth: 0 }}>
          <PageHero Icon={FolderOpen}>Expedientes</PageHero>
          <p style={{ color: C.textMid, fontSize: 12, margin: "6px 0 0", maxWidth: 560, lineHeight: 1.45 }}>
            Pacientes que ya tuvieron consulta (completada, en curso o con diagnóstico), agrupados por teléfono.
          </p>
        </div>
        <Inp value={busq} onChange={(e) => setBusq(e.target.value)} placeholder="🔍 Buscar por nombre o teléfono…" style={{ flex: "1 1 200px", minWidth: 0, maxWidth: "100%", width: "100%" }} />
      </div>

      {loadErr && (
        <div style={{ background: C.amberDim, border: `1px solid ${C.amber}40`, borderRadius: 10, padding: "10px 14px", marginBottom: 14, color: C.amber, fontSize: 12, lineHeight: 1.45 }}>
          {loadErr}
        </div>
      )}

      {loading ? (
        <SkeletonTable rows={6} cols={5} />
      ) : !filtrados.length ? (
        <Box style={{ padding: 28, textAlign: "center", color: C.textMid }}>
          {pacientes.length === 0
            ? "Aún no hay pacientes con consulta registrada. Aparecen aquí cuando la doctora termina una consulta o guarda diagnóstico en la ficha clínica."
            : "Ningún paciente coincide con la búsqueda."}
        </Box>
      ) : (
        <Box style={{ overflowX: "auto", WebkitOverflowScrolling: "touch" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", minWidth: 520 }}>
            <thead>
              <tr>
                {["Paciente", "Teléfono", "Consultas", "Primera visita", "Última visita", ""].map((h) => (
                  <th key={h} style={{ padding: "8px 14px", color: C.textDim, fontSize: 9, textAlign: "left", letterSpacing: 1.2, textTransform: "uppercase", borderBottom: `1px solid ${C.border}` }}>
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.map((r) => (
                <tr key={r.telefono} style={{ borderBottom: `1px solid ${C.border}` }}>
                  <td style={{ padding: "10px 14px", color: C.text, fontWeight: 700, fontSize: 13 }}>{r.nombre}</td>
                  <td style={{ padding: "10px 14px", color: C.textMid, fontSize: 12 }}>{r.telefono}</td>
                  <td style={{ padding: "10px 14px" }}>
                    <Tag col={C.blue} sm>{r.n_completadas ?? r.n}</Tag>
                  </td>
                  <td style={{ padding: "10px 14px", color: C.textMid, fontSize: 12 }}>{r.primera}</td>
                  <td style={{ padding: "10px 14px", color: C.blue, fontWeight: 700, fontSize: 12 }}>{r.ultima}</td>
                  <td style={{ padding: "10px 14px" }}>
                    <button
                      type="button"
                      onClick={() => setPacienteModal({ telefono: r.telefono, nombre: r.nombre })}
                      style={{
                        padding: "6px 12px",
                        borderRadius: 8,
                        border: `1px solid ${BRAND.primary}`,
                        background: BRAND.primary + "18",
                        color: BRAND.primary,
                        fontWeight: 700,
                        fontSize: 11,
                        cursor: "pointer",
                      }}
                    >
                      Ver expediente
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Box>
      )}

      <Modal
        open={!!pacienteModal && !citaVerModal}
        onClose={() => setPacienteModal(null)}
        title={`📂 Expediente clínico · ${pacienteModal?.nombre || ""}`}
        ac={BRAND.primary}
      >
        {pacienteModal && (
          <ExpedientePaciente
            telefono={pacienteModal.telefono}
            nombre={pacienteModal.nombre}
            onVerCita={(cita) => setCitaVerModal(cita)}
          />
        )}
      </Modal>

      <CitaFichaModal
        cita={citaVerModal}
        open={!!citaVerModal}
        onClose={() => setCitaVerModal(null)}
        prodList={[]}
        procsList={[]}
        onSaved={() => setCitaVerModal(null)}
        readOnly={true}
        closeLabel="← Volver a citas"
      />
    </div>
  );
}
