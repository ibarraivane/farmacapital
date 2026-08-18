import { useState, useEffect, useCallback } from "react";
import { supabase } from "../../supabase";
import { showToast } from "../../ui";
import { C_LIGHT } from "../../constants";
import {
  RH_DOC_TIPOS, RH_DOC_MAX_MB, RH_DOC_ACCEPT, RH_DOC_MIMES, rhDocLabel,
} from "../../constants/rhDocumentos";

/** Misma función Vercel que banners/productos; Hobby solo permite 12 serverless. */
const RH_DOC_API = "/api/admin/storage-upload?type=rh-documento";

function sessionTok() {
  try { return sessionStorage.getItem("farmacapital_session_token") || ""; }
  catch { return ""; }
}

function fmtBytes(n) {
  const b = Number(n) || 0;
  if (b < 1024) return `${b} B`;
  if (b < 1024 * 1024) return `${(b / 1024).toFixed(0)} KB`;
  return `${(b / (1024 * 1024)).toFixed(1)} MB`;
}

function mimeOf(file) {
  const ext = (file.name.split(".").pop() || "").toLowerCase();
  if (file.type && RH_DOC_MIMES.includes(file.type)) return file.type;
  if (ext === "pdf") return "application/pdf";
  if (ext === "png") return "image/png";
  if (ext === "webp") return "image/webp";
  if (ext === "jpg" || ext === "jpeg" || ext === "jfif") return "image/jpeg";
  return "";
}

export default function EmpleadoDocumentos({ empleados, S }) {
  const C = C_LIGHT;
  const [empleadoId, setEmpleadoId] = useState("");
  const [docs, setDocs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(null);

  const sel = empleados.find((e) => String(e.id) === String(empleadoId));

  const cargar = useCallback(async (id) => {
    if (!id) { setDocs([]); return; }
    setLoading(true);
    const tok = sessionTok();
    const { data, error } = await supabase.rpc("admin_listar_documentos_empleado", {
      p_session_token: tok,
      p_empleado_id: Number(id),
    });
    setLoading(false);
    if (error) {
      if (/could not find the function|pgrst202/i.test(error.message || "")) {
        showToast("Falta actualizar la base. Ejecuta sql/patch_rh_bonos_documentos.sql en Supabase.", "error");
      } else {
        showToast(error.message || "No se pudieron cargar los documentos.", "error");
      }
      setDocs([]);
      return;
    }
    setDocs(Array.isArray(data) ? data : []);
  }, []);

  useEffect(() => { cargar(empleadoId); }, [empleadoId, cargar]);

  const porTipo = (tipo) => docs.filter((d) => d.tipo === tipo);
  const faltantes = RH_DOC_TIPOS.filter((t) => t.requerido && porTipo(t.id).length === 0);

  const subir = async (tipo, file) => {
    if (!sel || !file) return;
    const mime = mimeOf(file);
    if (!mime) {
      showToast("Solo PDF, JPG, PNG o WEBP.", "error");
      return;
    }
    if (file.size > RH_DOC_MAX_MB * 1024 * 1024) {
      showToast(`El archivo pesa más de ${RH_DOC_MAX_MB} MB.`, "error");
      return;
    }
    const tok = sessionTok();
    if (!tok) { showToast("Sesión expirada.", "error"); return; }
    setUploading(tipo);
    try {
      const resp = await fetch(RH_DOC_API, {
        method: "POST",
        headers: {
          "Content-Type": mime,
          "X-Session-Token": tok,
          "X-Empleado-Id": String(sel.id),
          "X-Tipo": tipo,
          "X-File-Name": file.name.replace(/[^\w.\- áéíóúñÁÉÍÓÚÑ]/g, "_").slice(0, 180),
        },
        body: file,
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        throw new Error(data?.message || data?.error || `Error ${resp.status}`);
      }
      showToast("Documento guardado.", "success");
      await cargar(sel.id);
    } catch (e) {
      showToast(e.message || "No se pudo subir.", "error");
    } finally {
      setUploading(null);
    }
  };

  const ver = async (doc) => {
    const tok = sessionTok();
    try {
      const resp = await fetch(`${RH_DOC_API}&id=${doc.id}`, {
        headers: { "X-Session-Token": tok },
      });
      if (!resp.ok) {
        const data = await resp.json().catch(() => ({}));
        throw new Error(data?.message || data?.error || `Error ${resp.status}`);
      }
      const blob = await resp.blob();
      const url = URL.createObjectURL(blob);
      window.open(url, "_blank", "noopener,noreferrer");
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch (e) {
      showToast(e.message || "No se pudo abrir.", "error");
    }
  };

  const borrar = async (doc) => {
    if (!window.confirm(`¿Quitar ${rhDocLabel(doc.tipo)} (${doc.nombre_archivo})?`)) return;
    const tok = sessionTok();
    try {
      const resp = await fetch(`${RH_DOC_API}&id=${doc.id}`, {
        method: "DELETE",
        headers: { "X-Session-Token": tok },
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        throw new Error(data?.message || data?.error || `Error ${resp.status}`);
      }
      showToast("Documento eliminado.", "success");
      await cargar(sel?.id);
    } catch (e) {
      showToast(e.message || "No se pudo eliminar.", "error");
    }
  };

  return (
    <div style={S.section}>
      <div style={S.h2}>📁 Expediente de documentos</div>
      <p style={{ color: C.textMid, fontSize: 13, margin: "0 0 16px", lineHeight: 1.45 }}>
        Contrato, INE y papeles de alta. Solo los ve el administrador; no salen en el POS.
      </p>

      {!empleados.length ? (
        <p style={{ color: C.textMid }}>Registra un empleado primero.</p>
      ) : (
        <>
          <div style={{ maxWidth: 360, marginBottom: 16 }}>
            <label style={S.label}>Empleado</label>
            <select
              style={S.select}
              value={empleadoId}
              onChange={(e) => setEmpleadoId(e.target.value)}
            >
              <option value="">— Seleccionar —</option>
              {empleados.map((e) => (
                <option key={e.id} value={e.id}>{e.nombre}</option>
              ))}
            </select>
          </div>

          {!sel ? null : loading ? (
            <p style={{ color: C.textMid }}>Cargando expediente…</p>
          ) : (
            <>
              <div style={{
                display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 16, fontSize: 12,
              }}>
                {faltantes.length === 0 ? (
                  <span style={{ color: C.green, fontWeight: 700 }}>
                    Contrato e INE listos.
                  </span>
                ) : (
                  <span style={{ color: C.amber, fontWeight: 700 }}>
                    Falta: {faltantes.map((t) => t.label).join(", ")}
                  </span>
                )}
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                {RH_DOC_TIPOS.map((t) => {
                  const lista = porTipo(t.id);
                  const ok = lista.length > 0;
                  return (
                    <div
                      key={t.id}
                      style={{
                        border: `1px solid ${C.border}`,
                        borderRadius: 10,
                        padding: 12,
                        background: C.bg,
                      }}
                    >
                      <div style={{
                        display: "flex", alignItems: "center", justifyContent: "space-between",
                        gap: 10, flexWrap: "wrap",
                      }}>
                        <div>
                          <div style={{ fontWeight: 700, fontSize: 13, color: C.text }}>
                            {ok ? "●" : "○"} {t.label}
                            {t.requerido && !ok && (
                              <span style={{ color: C.amber, fontWeight: 700, fontSize: 11, marginLeft: 8 }}>
                                recomendado
                              </span>
                            )}
                          </div>
                        </div>
                        <label style={{
                          ...S.btnBlue,
                          padding: "7px 12px",
                          fontSize: 12,
                          cursor: uploading === t.id ? "wait" : "pointer",
                          opacity: uploading && uploading !== t.id ? 0.5 : 1,
                        }}>
                          {uploading === t.id ? "Subiendo…" : "Subir"}
                          <input
                            type="file"
                            accept={RH_DOC_ACCEPT}
                            hidden
                            disabled={!!uploading}
                            onChange={(e) => {
                              const f = e.target.files?.[0];
                              e.target.value = "";
                              if (f) subir(t.id, f);
                            }}
                          />
                        </label>
                      </div>
                      {lista.length > 0 && (
                        <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 6 }}>
                          {lista.map((d) => (
                            <div
                              key={d.id}
                              style={{
                                display: "flex", alignItems: "center", justifyContent: "space-between",
                                gap: 8, fontSize: 12, color: C.textMid, flexWrap: "wrap",
                              }}
                            >
                              <span style={{ wordBreak: "break-all" }}>
                                {d.nombre_archivo}
                                <span style={{ marginLeft: 8, opacity: 0.8 }}>{fmtBytes(d.bytes)}</span>
                              </span>
                              <div style={{ display: "flex", gap: 6 }}>
                                <button
                                  type="button"
                                  onClick={() => ver(d)}
                                  style={{ ...S.btnGreen, padding: "5px 10px", fontSize: 11 }}
                                >
                                  Ver
                                </button>
                                <button
                                  type="button"
                                  onClick={() => borrar(d)}
                                  aria-label={`Eliminar ${d.nombre_archivo}`}
                                  style={{
                                    background: C.redDim, color: C.red, border: `1px solid ${C.red}30`,
                                    borderRadius: 8, padding: "5px 10px", fontSize: 11, fontWeight: 700,
                                    cursor: "pointer",
                                  }}
                                >
                                  Quitar
                                </button>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
}
