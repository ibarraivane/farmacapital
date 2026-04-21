import { useState, useEffect } from "react";
import { C_LIGHT, BRAND } from "../../../constants";
import { supabase } from "../../../supabase";
import { Box, Tag, Inp, Modal, SkeletonTable } from "../../../ui";
import { CitaFichaModal } from "../CitaFichaDoctora";
import { ExpedientePaciente } from "./ExpedientePaciente";

const C = C_LIGHT;

/** Lista de pacientes por teléfono + expediente / ficha en solo lectura. */
export default function ExpedientesDoctora() {
  const [pacientes, setPacientes] = useState([]);
  const [loading, setLoad] = useState(true);
  const [busq, setBusq] = useState("");
  const [pacienteModal, setPacienteModal] = useState(null);
  const [citaVerModal, setCitaVerModal] = useState(null);

  useEffect(() => {
    (async () => {
      const { data, error } = await supabase
        .from("citas")
        .select("nombre,telefono,fecha,estado")
        .neq("estado", "cancelada")
        .order("fecha", { ascending: false })
        .limit(3000);
      if (error) console.error("[ExpedientesDoctora]", error);
      const byPhone = new Map();
      for (const c of data || []) {
        const t = String(c.telefono || "").trim();
        if (!t) continue;
        const cur = byPhone.get(t);
        if (!cur) {
          byPhone.set(t, {
            telefono: t,
            nombre: (c.nombre || "").trim() || "—",
            ultima: c.fecha,
            primera: c.fecha,
            n: 1,
          });
        } else {
          cur.n += 1;
          if (c.fecha < cur.primera) cur.primera = c.fecha;
          if (c.fecha > cur.ultima) {
            cur.ultima = c.fecha;
            if ((c.nombre || "").trim()) cur.nombre = c.nombre.trim();
          }
        }
      }
      setPacientes(Array.from(byPhone.values()).sort((a, b) => b.ultima.localeCompare(a.ultima)));
      setLoad(false);
    })();
  }, []);

  const filtrados = pacientes.filter((r) => {
    const s = busq.trim().toLowerCase();
    if (!s) return true;
    return r.telefono.replace(/\D/g, "").includes(s.replace(/\D/g, "")) || (r.nombre || "").toLowerCase().includes(s);
  });

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16, flexWrap: "wrap", gap: 12 }}>
        <div>
          <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: 0 }}>📂 Expedientes</h1>
          <p style={{ color: C.textMid, fontSize: 12, margin: "6px 0 0", maxWidth: 560, lineHeight: 1.45 }}>
            Pacientes con al menos una cita (agrupados por teléfono). Abre el expediente clínico o revisa una consulta en solo lectura.
          </p>
        </div>
        <Inp value={busq} onChange={(e) => setBusq(e.target.value)} placeholder="🔍 Buscar por nombre o teléfono…" style={{ minWidth: 220, maxWidth: 320 }} />
      </div>

      {loading ? (
        <SkeletonTable rows={6} cols={5} />
      ) : !filtrados.length ? (
        <Box style={{ padding: 28, textAlign: "center", color: C.textMid }}>
          {pacientes.length === 0
            ? "Aún no hay citas con teléfono registrado. Las citas deben incluir teléfono para aparecer aquí."
            : "Ningún paciente coincide con la búsqueda."}
        </Box>
      ) : (
        <Box>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
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
                    <Tag col={C.blue} sm>{r.n}</Tag>
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

      <Modal open={!!pacienteModal} onClose={() => setPacienteModal(null)} title={`📂 Expediente clínico · ${pacienteModal?.nombre || ""}`} ac={BRAND.primary}>
        {pacienteModal && (
          <ExpedientePaciente
            telefono={pacienteModal.telefono}
            nombre={pacienteModal.nombre}
            onVerCita={(cita) => {
              setPacienteModal(null);
              setCitaVerModal(cita);
            }}
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
      />
    </div>
  );
}
