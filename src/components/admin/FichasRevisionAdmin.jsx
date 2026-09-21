import { useEffect, useMemo, useState } from "react";
import { supabase } from "../../supabase";
import { C_LIGHT, BRAND } from "../../constants";
import { Btn, showToast, SkeletonTable } from "../../ui";

const C = C_LIGHT;

function pretty(v) {
  try {
    return JSON.stringify(v ?? {}, null, 2);
  } catch {
    return "{}";
  }
}

export default function FichasRevisionAdmin() {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sel, setSel] = useState(null);
  const [draft, setDraft] = useState("");
  const [imagenSel, setImagenSel] = useState(0);
  const [saving, setSaving] = useState(false);

  const cargar = async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error } = await supabase.rpc("admin_listar_fichas_revision", {
      p_session_token: tok,
    });
    if (error) {
      showToast(error.message, "error");
      setJobs([]);
    } else {
      setJobs(Array.isArray(data) ? data : []);
    }
    setLoading(false);
  };

  useEffect(() => { cargar(); }, []);

  useEffect(() => {
    if (!sel) return;
    setDraft(pretty(sel.resultado));
    setImagenSel(0);
  }, [sel]);

  const parsed = useMemo(() => {
    try {
      return JSON.parse(draft);
    } catch {
      return null;
    }
  }, [draft]);

  const fuentes = parsed?.fuentes || sel?.resultado?.fuentes || [];
  const imagenes = parsed?.imagenes || sel?.resultado?.imagenes || [];

  const guardar = async (accion) => {
    if (!sel) return;
    if (!parsed) {
      showToast("El JSON del borrador no es válido.", "error");
      return;
    }
    setSaving(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_guardar_ficha_revision", {
      p_session_token: tok,
      p_job_id: sel.id,
      p_accion: accion,
      p_payload: {
        ...parsed,
        imagen_principal: imagenes[imagenSel] || null,
      },
    });
    setSaving(false);
    if (error) {
      showToast(error.message, "error");
      return;
    }
    showToast(
      accion === "publicar" ? "Publicada. Quedó quién y cuándo." : accion === "rechazar" ? "Rechazada." : "Borrador guardado.",
      accion === "rechazar" ? "info" : "success"
    );
    setSel(null);
    cargar();
  };

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16, gap: 12, flexWrap: "wrap" }}>
        <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: 0 }}>Fichas por revisar</h1>
        <Btn col={BRAND.primary} onClick={cargar}>Actualizar</Btn>
      </div>
      <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.5, marginBottom: 16 }}>
        Nada se publica solo. El texto entra como borrador; solo un admin lo pasa a publicado.
        A la derecha ves las fuentes. Elige la foto principal antes de aprobar.
      </p>
      {loading ? <SkeletonTable rows={6} cols={4} /> : (
        <div style={{ display: "grid", gridTemplateColumns: sel ? "minmax(240px,320px) 1fr" : "1fr", gap: 16 }}>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {!jobs.length ? (
              <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 28, color: C.textMid, textAlign: "center" }}>
                No hay fichas pendientes. Al dar de alta un producto se crea un job.
              </div>
            ) : jobs.map((j) => (
              <button
                key={j.id}
                type="button"
                onClick={() => setSel(j)}
                style={{
                  textAlign: "left",
                  border: `1px solid ${sel?.id === j.id ? BRAND.primary : C.border}`,
                  background: C.card,
                  borderRadius: 10,
                  padding: 12,
                  cursor: "pointer",
                }}
              >
                <div style={{ fontWeight: 800, color: C.text, fontSize: 14 }}>{j.nombre}</div>
                <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>
                  {j.estado} · {j.sku || "sin SKU"} · job #{j.id}
                </div>
                {j.revisado_por ? (
                  <div style={{ color: C.textDim, fontSize: 11, marginTop: 4 }}>
                    Revisó {j.revisado_por}{j.revisado_en ? ` · ${String(j.revisado_en).slice(0, 16)}` : ""}
                  </div>
                ) : null}
              </button>
            ))}
          </div>
          {sel ? (
            <div style={{ display: "grid", gridTemplateColumns: "1fr 280px", gap: 14 }}>
              <div>
                <label style={{ display: "block", fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 6 }}>BORRADOR EDITABLE</label>
                <textarea
                  className="farmacapital-field-input"
                  value={draft}
                  onChange={(e) => setDraft(e.target.value)}
                  style={{
                    width: "100%",
                    minHeight: 420,
                    fontFamily: "ui-monospace, monospace",
                    fontSize: 12,
                    background: "#fff",
                    color: "#0f172a",
                    colorScheme: "light",
                    border: `1px solid ${C.border}`,
                    borderRadius: 10,
                    padding: 12,
                  }}
                />
                <div style={{ display: "flex", gap: 8, marginTop: 12, flexWrap: "wrap" }}>
                  <Btn col={BRAND.accent} disabled={saving} onClick={() => guardar("publicar")}>Aprobar y publicar</Btn>
                  <Btn outline col={BRAND.primary} disabled={saving} onClick={() => guardar("guardar")}>Guardar borrador</Btn>
                  <Btn outline col={C.red} disabled={saving} onClick={() => guardar("rechazar")}>Rechazar</Btn>
                </div>
              </div>
              <div>
                <div style={{ fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 8 }}>FUENTES</div>
                <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
                  {fuentes.length ? fuentes.map((f, i) => (
                    <a key={`${f.url}-${i}`} href={f.url} target="_blank" rel="noopener noreferrer" style={{ fontSize: 13, color: BRAND.primary }}>
                      {f.titulo || f.url}
                      <div style={{ color: C.textDim, fontSize: 11 }}>{f.tipo} · {(f.campos || []).join(", ")}</div>
                    </a>
                  )) : <div style={{ color: C.textMid, fontSize: 12 }}>Sin fuentes en el borrador.</div>}
                </div>
                <div style={{ fontSize: 11, fontWeight: 700, color: C.textMid, marginBottom: 8 }}>CANDIDATOS DE IMAGEN</div>
                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  {imagenes.length ? imagenes.map((im, i) => (
                    <button
                      key={`${im.url}-${i}`}
                      type="button"
                      onClick={() => setImagenSel(i)}
                      style={{
                        border: `2px solid ${i === imagenSel ? BRAND.primary : C.border}`,
                        borderRadius: 8,
                        background: "#fff",
                        padding: 8,
                        textAlign: "left",
                        cursor: "pointer",
                      }}
                    >
                      {im.url ? <img src={im.url} alt="" style={{ width: "100%", height: 80, objectFit: "contain" }} /> : null}
                      <div style={{ fontSize: 11, color: C.textMid, marginTop: 4 }}>
                        {im.origen} · {im.licencia || "licencia no indicada"}
                      </div>
                    </button>
                  )) : <div style={{ color: C.textMid, fontSize: 12 }}>Sin candidatos.</div>}
                </div>
                {sel.error ? (
                  <div style={{ marginTop: 12, color: C.red, fontSize: 12 }}>{sel.error}</div>
                ) : null}
              </div>
            </div>
          ) : null}
        </div>
      )}
    </div>
  );
}
