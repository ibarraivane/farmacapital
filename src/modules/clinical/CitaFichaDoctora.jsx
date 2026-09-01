import { useState, useEffect, useCallback, useRef } from "react";
import { supabase } from "../../supabase";
import { C_LIGHT, BRAND } from "../../constants";
import { $ } from "../../utils";
import { Btn, Modal, Box, Tag, Inp, showToast, SearchDropdown } from "../../ui";
import { citaPagoOk } from "../../utils/consultaConstants";
import { alergiasQueCruzan, mensajeAlertaAlergia } from "../../utils/alergiaAlerta";
import { SEGUIMIENTO_OPCIONES, fechaSeguimiento, etiquetaSeguimiento } from "../../utils/seguimientoCita";
import {
  validarRecetaMx,
  buildRecetaHtml,
  openRecetaPrint,
  openRecetaPdf,
} from "../../utils/recetaPrint";

const C = C_LIGHT;

const fieldTextareaStyle = {
  width: "100%",
  boxSizing: "border-box",
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  padding: "8px 10px",
  fontSize: 12,
  resize: "vertical",
  background: "#ffffff",
  color: C.text,
  WebkitTextFillColor: C.text,
  colorScheme: "light",
  fontFamily: "var(--fc-body)",
  lineHeight: 1.45,
};

function uid() {
  return globalThis.crypto?.randomUUID?.() || `m_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
}

/** Normaliza medicamentos_prescritos (JSON, texto legacy o array) a filas de UI. */
function parseMedsPrescritos(mp) {
  if (!mp) return [];
  if (Array.isArray(mp)) {
    return mp
      .map((m) => ({
        _uid: uid(),
        producto_id: m.producto_id != null ? Number(m.producto_id) : null,
        medicamento: String(m.medicamento || m.nombre || "").trim(),
        cantidad: Math.max(1, Number(m.cantidad) || 1),
        dosis: m.dosis != null ? String(m.dosis) : "",
        via: m.via != null ? String(m.via) : "",
        frecuencia: m.frecuencia != null ? String(m.frecuencia) : "",
        duracion: m.duracion != null ? String(m.duracion) : "",
        indicaciones: m.indicaciones != null ? String(m.indicaciones) : "",
        surtido: m.surtido === "farmacapital" || m.surtido === "externa" ? m.surtido : "pendiente",
      }))
      .filter((m) => m.medicamento || m.producto_id);
  }
  if (typeof mp === "string") {
    const t = mp.trim();
    if (t.startsWith("[")) {
      try {
        const arr = JSON.parse(t);
        if (Array.isArray(arr)) return parseMedsPrescritos(arr);
      } catch {
        /* texto legacy */
      }
    }
    return mp
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => ({ _uid: uid(), producto_id: null, medicamento: line, cantidad: 1, dosis: "", via: "", frecuencia: "", duracion: "", indicaciones: "", surtido: "pendiente" }));
  }
  return [];
}

function serializeMeds(rows) {
  return rows
    .map(({ _uid, ...rest }) => ({
      producto_id: rest.producto_id != null ? Number(rest.producto_id) : null,
      medicamento: String(rest.medicamento || "").trim(),
      cantidad: Math.max(1, Number(rest.cantidad) || 1),
      dosis: rest.dosis != null ? String(rest.dosis) : "",
      via: rest.via != null ? String(rest.via) : "",
      frecuencia: rest.frecuencia != null ? String(rest.frecuencia) : "",
      duracion: rest.duracion != null ? String(rest.duracion) : "",
      indicaciones: rest.indicaciones != null ? String(rest.indicaciones) : "",
      surtido: rest.surtido === "farmacapital" || rest.surtido === "externa" ? rest.surtido : "pendiente",
    }))
    .filter((m) => m.medicamento || m.producto_id);
}

function patchConsultaFin(citaRow) {
  const finIso = new Date().toISOString();
  let durSec = null;
  const ini = citaRow?.confirmada_inicio_at;
  if (ini) {
    durSec = Math.max(0, Math.floor((Date.now() - Date.parse(ini)) / 1000));
  }
  return { consulta_fin_at: finIso, duracion_consulta_segundos: durSec };
}

function emptyVitals() {
  return { ta: "", fc: "", temp: "", sat: "", peso: "", talla: "" };
}

function emptyExp() {
  return { alergias: "", antecedentes: "", sexo: "", edad: "" };
}

function FirmaPad({ value, onChange, disabled }) {
  const canvasRef = useRef(null);
  const drawing = useRef(false);

  const pos = (e) => {
    const canvas = canvasRef.current;
    if (!canvas) return { x: 0, y: 0 };
    const r = canvas.getBoundingClientRect();
    const t = e.touches?.[0];
    const x = (t ? t.clientX : e.clientX) - r.left;
    const y = (t ? t.clientY : e.clientY) - r.top;
    return { x: x * (canvas.width / r.width), y: y * (canvas.height / r.height) };
  };

  const start = (e) => {
    if (disabled) return;
    drawing.current = true;
    const ctx = canvasRef.current?.getContext("2d");
    if (!ctx) return;
    const { x, y } = pos(e);
    ctx.beginPath();
    ctx.moveTo(x, y);
  };
  const move = (e) => {
    if (!drawing.current || disabled) return;
    e.preventDefault();
    const ctx = canvasRef.current?.getContext("2d");
    if (!ctx) return;
    const { x, y } = pos(e);
    ctx.lineWidth = 2;
    ctx.lineCap = "round";
    ctx.strokeStyle = "#0f172a";
    ctx.lineTo(x, y);
    ctx.stroke();
  };
  const end = () => {
    if (!drawing.current) return;
    drawing.current = false;
    const data = canvasRef.current?.toDataURL("image/png");
    if (data) onChange?.(data);
  };

  return (
    <div>
      <canvas
        ref={canvasRef}
        width={320}
        height={90}
        onMouseDown={start}
        onMouseMove={move}
        onMouseUp={end}
        onMouseLeave={end}
        onTouchStart={start}
        onTouchMove={move}
        onTouchEnd={end}
        style={{
          width: "100%",
          maxWidth: 320,
          height: 90,
          border: "1px solid #e2e8f0",
          borderRadius: 8,
          background: "#fff",
          touchAction: "none",
          cursor: disabled ? "not-allowed" : "crosshair",
        }}
      />
      <button
        type="button"
        disabled={disabled}
        onClick={() => {
          const ctx = canvasRef.current?.getContext("2d");
          if (ctx && canvasRef.current) ctx.clearRect(0, 0, canvasRef.current.width, canvasRef.current.height);
          onChange?.("");
        }}
        style={{ marginTop: 6, fontSize: 11, border: "none", background: "transparent", color: "#64748b", cursor: "pointer" }}
      >
        Borrar firma
      </button>
      {value ? <span style={{ fontSize: 10, color: "#16a34a", marginLeft: 8 }}>Firma capturada</span> : null}
    </div>
  );
}

/** Acepta objeto o JSON string (PostgREST a veces devuelve texto). */
function parseJsonObject(raw) {
  if (raw && typeof raw === "object") return raw;
  if (typeof raw === "string" && raw.trim()) {
    try {
      const p = JSON.parse(raw);
      return typeof p === "object" && p !== null ? p : {};
    } catch {
      return {};
    }
  }
  return {};
}

function parseJsonArray(raw) {
  if (Array.isArray(raw)) return raw;
  if (typeof raw === "string" && raw.trim()) {
    try {
      const p = JSON.parse(raw);
      return Array.isArray(p) ? p : [];
    } catch {
      return [];
    }
  }
  return [];
}

function getPlantilla(proc) {
  let t = proc?.plantilla_consumibles;
  if (typeof t === "string") {
    try {
      t = JSON.parse(t || "[]");
    } catch {
      return [];
    }
  }
  return Array.isArray(t) ? t : [];
}

/**
 * Ficha clínica por cita: signos vitales, expediente, diagnóstico, medicamentos, receta surtida, procedimientos, consumibles.
 */
export function CitaFichaModal({ cita, open, onClose, prodList, procsList, onSaved, readOnly = false }) {
  const [vit, setVit] = useState(emptyVitals);
  const [exp, setExp] = useState(emptyExp);
  const [diagnostico, setDx] = useState("");
  const [notas, setNotas] = useState("");
  const [medsRows, setMedsRows] = useState([]);
  const [prodBusq, setProdBusq] = useState("");
  const [prodCatalog, setProdCatalog] = useState([]);
  const [recetaSurtido, setRecetaSurtido] = useState("pendiente");
  const [procSel, setProcSel] = useState([]);
  const [guardando, setGuard] = useState(false);
  const [citaLocal, setCitaLocal] = useState(null);
  const [medicos, setMedicos] = useState([]);
  const [medicoId, setMedicoId] = useState("");
  const [firmaModo, setFirmaModo] = useState("fisica");
  const [firmaDataUrl, setFirmaDataUrl] = useState("");
  const [seguimientoDias, setSeguimientoDias] = useState(null);
  const [seguimientoNota, setSeguimientoNota] = useState("");
  const [alertaAlergia, setAlertaAlergia] = useState("");
  const [recetaEmitida, setRecetaEmitida] = useState(null);
  const [enviandoReceta, setEnviandoReceta] = useState(false);

  const reload = useCallback(async () => {
    if (!cita?.id) return;
    const { data, error } = await supabase
      .from("citas")
      .select(`*,consumibles_consulta(id,cantidad,precio,cobrado,producto_id,nombre)`)
      .eq("id", cita.id)
      .single();
    if (error) {
      console.error(error);
      setCitaLocal(cita);
      return;
    }
    setCitaLocal(data);
    const sv = parseJsonObject(data.signos_vitales);
    setVit({
      ta: sv.ta ?? "",
      fc: sv.fc ?? "",
      temp: sv.temp ?? "",
      sat: sv.sat ?? "",
      peso: sv.peso ?? "",
      talla: sv.talla ?? "",
    });
    const ej = parseJsonObject(data.expediente_json);
    setExp({
      alergias: ej.alergias ?? "",
      antecedentes: ej.antecedentes ?? "",
      sexo: ej.sexo ?? "",
      edad: ej.edad ?? "",
    });
    setDx(data.diagnostico || "");
    setNotas(data.notas_medico || "");
    setMedsRows(parseMedsPrescritos(data.medicamentos_prescritos));
    setRecetaSurtido(data.receta_surtido_en || "pendiente");
    setSeguimientoDias(data.seguimiento_dias != null ? Number(data.seguimiento_dias) : null);
    setSeguimientoNota(data.seguimiento_nota || "");
    setRecetaEmitida(data.receta_id ? { id: data.receta_id, folio: data.receta_folio || null } : null);
    const pr = parseJsonArray(data.procedimientos_realizados);
    if (pr.length && typeof pr[0] === "object") {
      setProcSel(pr);
    } else {
      setProcSel([]);
    }
  }, [cita?.id, cita]);

  useEffect(() => {
    if (open && cita?.id) reload();
  }, [open, cita?.id, reload]);

  useEffect(() => {
    if (!open || !cita?.id || readOnly) return;
    let cancelled = false;
    (async () => {
      const { data } = await supabase.from("productos").select("id,nombre,precio,sku,stock").eq("activo", true).order("nombre").limit(2500);
      if (!cancelled) setProdCatalog(data || []);
    })();
    return () => {
      cancelled = true;
    };
  }, [open, cita?.id, readOnly]);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    (async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data } = await supabase.rpc("empleado_listar_medicos_consultorio", { p_session_token: tok });
      if (cancelled) return;
      const list = Array.isArray(data) ? data.filter((m) => m.activo !== false) : [];
      setMedicos(list);
      setMedicoId((prev) => {
        if (prev) return prev;
        const conCedula = list.find((m) => String(m.cedula || "").trim());
        return String((conCedula || list[0])?.id || "");
      });
    })();
    return () => {
      cancelled = true;
    };
  }, [open]);

  const toggleProc = (p) => {
    setProcSel((prev) => {
      const ex = prev.find((x) => x.id === p.id);
      if (ex) return prev.filter((x) => x.id !== p.id);
      return [...prev, { id: p.id, nombre: p.nombre, precio: p.precio }];
    });
  };

  const agregarConsumible = async (prod, qty) => {
    if (!citaLocal?.id) return;
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("agregar_consumible_cita", {
        p_session_token: tok,
        p_cita_id:       citaLocal.id,
        p_producto_id:   prod.id,
        p_cantidad:      qty,
        p_precio:        prod.precio,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo agregar");
      await reload();
    } catch (e) {
      console.error(e);
    }
  };

  const aplicarPlantillaProc = async (proc) => {
    const tpl = getPlantilla(proc);
    if (!citaLocal?.id || !tpl.length) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) return;
    for (const row of tpl) {
      const pid = row.producto_id;
      const cant = Number(row.cantidad) || 1;
      const prod = prodList.find((p) => p.id === pid);
      if (!prod) continue;
      await supabase.rpc("agregar_consumible_cita", {
        p_session_token: tok,
        p_cita_id:       citaLocal.id,
        p_producto_id:   pid,
        p_cantidad:      cant,
        p_precio:        prod.precio,
      });
    }
    await reload();
  };

  const medicoSel = medicos.find((m) => String(m.id) === String(medicoId)) || null;

  const avisarAlergia = (nombreMed) => {
    const cruces = alergiasQueCruzan(exp.alergias, nombreMed);
    const msg = mensajeAlertaAlergia(cruces);
    setAlertaAlergia(msg);
    if (msg) showToast(msg, "warning");
    return cruces;
  };

  const agregarMedCatalogo = (prod) => {
    if (!prod?.id) return;
    if (medsRows.some((r) => r.producto_id === prod.id)) {
      showToast("Ese producto ya está en la receta.", "warning");
      return;
    }
    avisarAlergia(prod.nombre);
    setMedsRows((rows) => [
      ...rows,
      {
        _uid: uid(),
        producto_id: prod.id,
        medicamento: prod.nombre,
        cantidad: 1,
        dosis: "",
        via: "",
        frecuencia: "",
        duracion: "",
        indicaciones: "",
        surtido: "pendiente",
      },
    ]);
    setProdBusq("");
  };

  const agregarLineaLibre = () => {
    setMedsRows((rows) => [...rows, { _uid: uid(), producto_id: null, medicamento: "", cantidad: 1, dosis: "", via: "", frecuencia: "", duracion: "", indicaciones: "", surtido: "pendiente" }]);
  };

  const recetaOptsActuales = (folio) => ({
    folio,
    cita: citaLocal || cita,
    medico: medicoSel || {},
    medicamentos: serializeMeds(medsRows),
    diagnostico,
    notas,
    alergias: exp.alergias,
    pacienteExtra: { edad: exp.edad, sexo: exp.sexo },
    firmaModo,
    firmaDataUrl,
    seguimiento: etiquetaSeguimiento(seguimientoDias, fechaSeguimiento(seguimientoDias, (citaLocal || cita)?.fecha)),
  });

  const vistaPreviaReceta = () => {
    const v = validarRecetaMx({
      medico: medicoSel,
      medicamentos: serializeMeds(medsRows),
      diagnostico,
      firmaModo,
      firmaDataUrl,
    });
    if (!v.ok) {
      showToast(v.errores[0], "warning");
      return;
    }
    const opts = recetaOptsActuales(recetaEmitida?.folio);
    openRecetaPdf(opts);
  };

  const emitirRecetaACaja = async () => {
    const v = validarRecetaMx({
      medico: medicoSel,
      medicamentos: serializeMeds(medsRows),
      diagnostico,
      firmaModo,
      firmaDataUrl,
    });
    if (!v.ok) {
      showToast(v.errores[0], "warning");
      return;
    }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok || !citaLocal?.id) {
      showToast("Sesión expirada.", "error");
      return;
    }
    setEnviandoReceta(true);
    try {
      const { data: resp, error } = await supabase.rpc("empleado_emitir_receta", {
        p_session_token: tok,
        p_cita_id: citaLocal.id,
        p_payload: {
          medico_id: medicoSel?.id || null,
          medico_nombre: medicoSel?.nombre,
          medico_cedula: medicoSel?.cedula,
          medico_especialidad: medicoSel?.especialidad,
          medico_institucion: medicoSel?.institucion,
          paciente_edad: exp.edad,
          paciente_sexo: exp.sexo,
          diagnostico: diagnostico.trim(),
          notas: notas.trim(),
          alergias_snapshot: exp.alergias,
          medicamentos: serializeMeds(medsRows),
          firma_modo: firmaModo,
          firma_data_url: firmaModo === "digital" ? firmaDataUrl : null,
          seguimiento_dias: seguimientoDias,
          seguimiento_nota: seguimientoNota,
        },
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo emitir");
      setRecetaEmitida({ id: resp.receta_id, folio: resp.folio });
      showToast(`Receta ${resp.folio} enviada a caja para imprimir y surtir.`, "success");
      openRecetaPdf(recetaOptsActuales(resp.folio));
      onSaved?.();
    } catch (e) {
      const msg = String(e.message || e);
      if (/empleado_emitir_receta|does not exist|404|PGRST/i.test(msg)) {
        showToast("SQL de recetas pendiente. Vista previa local — corre sql/patch_recetas_doctora_20260901.sql para la cola de caja.", "warning");
        openRecetaPrint(buildRecetaHtml(recetaOptsActuales()));
      } else {
        showToast(msg, "error");
      }
    } finally {
      setEnviandoReceta(false);
    }
  };

  const quitarMed = (_uid) => setMedsRows((rows) => rows.filter((r) => r._uid !== _uid));

  const setMedRow = (_uid, patch) => setMedsRows((rows) => rows.map((r) => (r._uid === _uid ? { ...r, ...patch } : r)));

  const guardar = async () => {
    if (readOnly || !citaLocal?.id) return;
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const medsArr = serializeMeds(medsRows);

      const { data: resp, error } = await supabase.rpc("doctora_completar_consulta", {
        p_session_token: tok,
        p_cita_id:       citaLocal.id,
        p_diagnostico:   diagnostico.trim() || null,
        p_medicamentos:  medsArr.length ? medsArr : [],
        p_procedimientos: procSel.length ? procSel : [],
        p_notas_medico:  notas.trim() || null,
        p_alergias:      exp.alergias || null,
        p_antecedentes:  exp.antecedentes || null,
        p_consumibles:   [],
        p_signos_vitales: {
          ta: vit.ta || null,  fc: vit.fc || null,  temp: vit.temp || null,
          sat: vit.sat || null, peso: vit.peso || null, talla: vit.talla || null,
        },
        p_expediente: {
          alergias: exp.alergias || null,
          antecedentes: exp.antecedentes || null,
          sexo: exp.sexo || null,
          edad: exp.edad || null,
        },
        p_receta_surtido: recetaSurtido === "pendiente" ? null : recetaSurtido,
        p_completar:     false,
      });

      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo guardar");

      showToast("Ficha guardada.", "success");
      onSaved?.();
      onClose?.();
    } catch (e) {
      console.error(e);
      alert("No se pudo guardar la ficha: " + (e.message || e));
    }
    setGuard(false);
  };

  /** Cierra la consulta clínicamente: guarda ficha y marca la cita como completada (requiere diagnóstico). */
  const terminarConsulta = async () => {
    if (readOnly || !citaLocal?.id) return;
    if (!diagnostico.trim()) {
      showToast("Indica un diagnóstico antes de terminar la consulta.", "warning");
      return;
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const medsArr = serializeMeds(medsRows);

      const { data: resp, error } = await supabase.rpc("doctora_completar_consulta", {
        p_session_token:  tok,
        p_cita_id:        citaLocal.id,
        p_diagnostico:    diagnostico.trim(),
        p_medicamentos:   medsArr.length ? medsArr : [],
        p_procedimientos: procSel.length ? procSel : [],
        p_notas_medico:   notas.trim() || null,
        p_alergias:       exp.alergias || null,
        p_antecedentes:   exp.antecedentes || null,
        p_consumibles:    [],
        p_signos_vitales: {
          ta: vit.ta || null,  fc: vit.fc || null,  temp: vit.temp || null,
          sat: vit.sat || null, peso: vit.peso || null, talla: vit.talla || null,
        },
        p_expediente: {
          alergias: exp.alergias || null,
          antecedentes: exp.antecedentes || null,
          sexo: exp.sexo || null,
          edad: exp.edad || null,
        },
        p_receta_surtido: recetaSurtido === "pendiente" ? null : recetaSurtido,
        p_completar:     true,
      });

      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo terminar");

      if (seguimientoDias) {
        try {
          await supabase.rpc("empleado_guardar_seguimiento_cita", {
            p_session_token: tok,
            p_cita_id: citaLocal.id,
            p_dias: seguimientoDias,
            p_nota: seguimientoNota || null,
          });
        } catch (segErr) {
          console.warn("[ficha] seguimiento:", segErr);
        }
      }

      showToast("Consulta terminada y registrada como concluida.", "success");
      onSaved?.();
      onClose?.();
    } catch (e) {
      console.error(e);
      alert("No se pudo terminar la consulta: " + (e.message || e));
    }
    setGuard(false);
  };

  if (!open || !cita) return null;

  const pagoOk = citaPagoOk(citaLocal || cita);
  const puedeEditar = !readOnly && pagoOk;

  return (
    <Modal open={open} onClose={onClose} title="📋 Ficha clínica" ac={BRAND.primary}>
      <div style={{ maxHeight: "min(78vh, 720px)", overflowY: "auto", paddingRight: 4 }}>
        {!readOnly && !pagoOk && (
          <div style={{ background: C.amberDim, border: `1px solid ${C.amber}40`, borderRadius: 10, padding: 12, marginBottom: 14, color: C.amber, fontSize: 12, fontWeight: 700 }}>
            Pendiente de pago en caja. La ficha completa estará disponible cuando el paciente pague la consulta.
          </div>
        )}
        {readOnly && (
          <div style={{ background: C.blueDim, border: `1px solid ${C.blue}35`, borderRadius: 10, padding: 10, marginBottom: 14, color: C.blue, fontSize: 12, fontWeight: 700 }}>
            Solo lectura — expediente / historial. No se pueden guardar cambios.
          </div>
        )}

        <div style={{ color: C.textMid, fontSize: 13, marginBottom: 16 }}>
          <strong style={{ color: C.text }}>{(citaLocal || cita).nombre}</strong> · {(citaLocal || cita).telefono || "—"} · {(citaLocal || cita).hora}
        </div>
        {String(exp.alergias || "").trim() && (
          <div style={{ background: C.redDim, border: `1px solid ${C.red}45`, borderRadius: 10, padding: 10, marginBottom: 14, color: C.red, fontSize: 12, fontWeight: 800 }}>
            Alergias en expediente: {exp.alergias}
          </div>
        )}

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 0.5, marginBottom: 10 }}>
            SIGNOS VITALES
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(120px,1fr))", gap: 8 }}>
            {[
              ["ta", "TA (ej. 120/80)"],
              ["fc", "FC lpm"],
              ["temp", "Temp °C"],
              ["sat", "SpO₂ %"],
              ["peso", "Peso kg"],
              ["talla", "Talla cm"],
            ].map(([k, ph]) => (
              <div key={k}>
                <div style={{ color: C.textMid, fontSize: 10, marginBottom: 3 }}>{ph}</div>
                <Inp value={vit[k]} onChange={(e) => setVit((v) => ({ ...v, [k]: e.target.value }))} disabled={!puedeEditar} style={{ width: "100%" }} />
              </div>
            ))}
          </div>
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 8 }}>EXPEDIENTE</div>
          <div style={{ marginBottom: 8 }}>
            <div style={{ color: C.textMid, fontSize: 10, marginBottom: 3 }}>Edad / sexo</div>
            <div style={{ display: "flex", gap: 8 }}>
              <Inp value={exp.edad} onChange={(e) => setExp((x) => ({ ...x, edad: e.target.value }))} placeholder="Edad" disabled={!puedeEditar} style={{ flex: 1 }} />
              <Inp value={exp.sexo} onChange={(e) => setExp((x) => ({ ...x, sexo: e.target.value }))} placeholder="F / M / NB" disabled={!puedeEditar} style={{ flex: 1 }} />
            </div>
          </div>
          <div style={{ marginBottom: 8 }}>
            <div style={{ color: C.red, fontSize: 10, fontWeight: 700 }}>Alergias</div>
            <textarea
              className="farmacapital-field-input"
              value={exp.alergias}
              onChange={(e) => setExp((x) => ({ ...x, alergias: e.target.value }))}
              disabled={!puedeEditar}
              rows={2}
              placeholder="Ej: Penicilina, AINES, látex…"
              style={fieldTextareaStyle}
            />
            {alertaAlergia && (
              <div style={{ marginTop: 8, padding: 8, background: C.redDim, border: `1px solid ${C.red}40`, borderRadius: 8, color: C.red, fontSize: 11, fontWeight: 700 }}>
                {alertaAlergia}
              </div>
            )}
          </div>
          <div>
            <div style={{ color: C.amber, fontSize: 10, fontWeight: 700 }}>Antecedentes</div>
            <textarea
              className="farmacapital-field-input"
              value={exp.antecedentes}
              onChange={(e) => setExp((x) => ({ ...x, antecedentes: e.target.value }))}
              disabled={!puedeEditar}
              rows={2}
              style={fieldTextareaStyle}
            />
          </div>
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>DIAGNÓSTICO</div>
          <textarea
            className="farmacapital-field-input"
            value={diagnostico}
            onChange={(e) => setDx(e.target.value)}
            disabled={!puedeEditar}
            rows={2}
            placeholder="Diagnóstico o impresión clínica"
            style={fieldTextareaStyle}
          />
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>MEDICAMENTOS (catálogo FarmaCapital + texto libre)</div>
          {!readOnly && (
            <div style={{ color: C.textMid, fontSize: 10, marginBottom: 10, lineHeight: 1.45 }}>
              Agrega productos del <strong>inventario</strong> para vincular con caja: cuando el paciente pague en mostrador con «receta de médico FarmaCapital», el sistema marcará esas líneas como surtidas aquí. Puedes añadir líneas solo con nombre si la receta es externa o a mano.
            </div>
          )}
          {puedeEditar && (
            <div style={{ marginBottom: 12 }}>
              <SearchDropdown
                value={prodBusq}
                onChange={setProdBusq}
                onSelect={(p) => agregarMedCatalogo(p)}
                placeholder="🔍 Buscar medicamento en inventario…"
                items={prodCatalog}
                labelKey="nombre"
                subKey="sku"
                badgeKey="stock"
                badgeCol="#1E3ABA"
                maxResults={12}
                style={{ width: "100%" }}
                emptyMsg="Sin coincidencias"
              />
              <button
                type="button"
                onClick={agregarLineaLibre}
                style={{
                  marginTop: 8,
                  padding: "6px 12px",
                  borderRadius: 8,
                  border: `1px dashed ${C.border}`,
                  background: "transparent",
                  color: C.textMid,
                  fontSize: 11,
                  fontWeight: 600,
                  cursor: "pointer",
                }}
              >
                + Línea libre (sin catálogo)
              </button>
            </div>
          )}
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {medsRows.length === 0 && <div style={{ color: C.textDim, fontSize: 11, fontStyle: "italic" }}>Sin medicamentos registrados.</div>}
            {medsRows.map((row) => (
              <div
                key={row._uid}
                style={{
                  padding: 10,
                  borderRadius: 8,
                  border: `1px solid ${C.border}`,
                  background: C.bg,
                  display: "grid",
                  gridTemplateColumns: "1fr auto",
                  gap: 8,
                  alignItems: "start",
                }}
              >
                <div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center", marginBottom: 6 }}>
                    {row.producto_id ? (
                      <Tag col={C.blue} sm>
                        {row.medicamento}
                      </Tag>
                    ) : (
                      <Inp
                        value={row.medicamento}
                        onChange={(e) => {
                          const nombre = e.target.value;
                          setMedRow(row._uid, { medicamento: nombre });
                          if (nombre.trim().length >= 4) avisarAlergia(nombre);
                        }}
                        disabled={!puedeEditar}
                        placeholder="Nombre del medicamento"
                        style={{ flex: 1, minWidth: 160 }}
                      />
                    )}
                    {!readOnly && row.surtido === "farmacapital" && (
                      <Tag col={C.green} sm>
                        Surtido FarmaCapital
                      </Tag>
                    )}
                    {!readOnly && row.surtido === "externa" && (
                      <Tag col={C.amber} sm>
                        Otra farmacia
                      </Tag>
                    )}
                  </div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                    <div style={{ width: 72 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Cant.</div>
                      <Inp
                        type="number"
                        min={1}
                        value={String(row.cantidad)}
                        onChange={(e) => setMedRow(row._uid, { cantidad: Math.max(1, parseInt(e.target.value, 10) || 1) })}
                        disabled={!puedeEditar}
                        style={{ width: "100%" }}
                      />
                    </div>
                    <div style={{ flex: 1, minWidth: 90 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Dosis</div>
                      <Inp value={row.dosis} onChange={(e) => setMedRow(row._uid, { dosis: e.target.value })} disabled={!puedeEditar} style={{ width: "100%" }} />
                    </div>
                    <div style={{ flex: 1, minWidth: 80 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Vía</div>
                      <Inp value={row.via || ""} onChange={(e) => setMedRow(row._uid, { via: e.target.value })} disabled={!puedeEditar} placeholder="oral" style={{ width: "100%" }} />
                    </div>
                    <div style={{ flex: 1, minWidth: 80 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Frecuencia</div>
                      <Inp value={row.frecuencia || ""} onChange={(e) => setMedRow(row._uid, { frecuencia: e.target.value })} disabled={!puedeEditar} placeholder="c/8 h" style={{ width: "100%" }} />
                    </div>
                    <div style={{ flex: 1, minWidth: 80 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Duración</div>
                      <Inp value={row.duracion || ""} onChange={(e) => setMedRow(row._uid, { duracion: e.target.value })} disabled={!puedeEditar} placeholder="7 días" style={{ width: "100%" }} />
                    </div>
                    <div style={{ flex: 1, minWidth: 120 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Indicaciones</div>
                      <Inp value={row.indicaciones} onChange={(e) => setMedRow(row._uid, { indicaciones: e.target.value })} disabled={!puedeEditar} style={{ width: "100%" }} />
                    </div>
                    {!readOnly && (
                      <div style={{ minWidth: 130 }}>
                        <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Surtido</div>
                        <select
                          value={row.surtido || "pendiente"}
                          onChange={(e) => setMedRow(row._uid, { surtido: e.target.value })}
                          disabled={!puedeEditar}
                          style={{ width: "100%", padding: "6px 8px", borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 11 }}
                        >
                          <option value="pendiente">Pendiente</option>
                          <option value="farmacapital">FarmaCapital</option>
                          <option value="externa">Otra farmacia</option>
                        </select>
                      </div>
                    )}
                  </div>
                </div>
                {puedeEditar && (
                  <button type="button" onClick={() => quitarMed(row._uid)} style={{ border: "none", background: "transparent", color: C.red, cursor: "pointer", fontSize: 16, padding: 4 }}>
                    ✕
                  </button>
                )}
              </div>
            ))}
          </div>
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 8 }}>RECETA MÉXICO · FOLIO + CAJA</div>
          <p style={{ color: C.textMid, fontSize: 11, lineHeight: 1.45, margin: "0 0 10px" }}>
            Formato carta (consultorio, no ticket). Cédula obligatoria. Al enviar, baja a POS → Consultas para imprimir y surtir.
          </p>
          {puedeEditar && (
            <>
              <div style={{ fontSize: 10, color: C.textMid, marginBottom: 4 }}>Médico en turno</div>
              <select
                value={medicoId}
                onChange={(e) => setMedicoId(e.target.value)}
                style={{ width: "100%", padding: "8px 10px", borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 12, marginBottom: 8 }}
              >
                <option value="">Selecciona médico…</option>
                {medicos.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.nombre} {m.cedula ? `· Céd. ${m.cedula}` : "· SIN CÉDULA"}
                  </option>
                ))}
              </select>
              {medicoSel && !String(medicoSel.cedula || "").trim() && (
                <div style={{ fontSize: 11, color: C.red, fontWeight: 700, marginBottom: 8 }}>
                  Este médico no tiene cédula. Captúrala en Consultorio → Médicos (admin).
                </div>
              )}
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 10 }}>
                {[
                  ["fisica", "Firma física (papel)"],
                  ["digital", "Firma digital (tablet)"],
                ].map(([v, lab]) => (
                  <button
                    key={v}
                    type="button"
                    onClick={() => setFirmaModo(v)}
                    style={{
                      padding: "6px 10px",
                      borderRadius: 8,
                      border: `1px solid ${firmaModo === v ? BRAND.primary : C.border}`,
                      background: firmaModo === v ? BRAND.primary + "18" : "transparent",
                      fontSize: 11,
                      fontWeight: 700,
                      cursor: "pointer",
                    }}
                  >
                    {lab}
                  </button>
                ))}
              </div>
              {firmaModo === "digital" && <FirmaPad value={firmaDataUrl} onChange={setFirmaDataUrl} disabled={!puedeEditar} />}
              {recetaEmitida?.folio && (
                <div style={{ margin: "8px 0", fontSize: 12, fontWeight: 700, color: C.green }}>
                  En cola de caja · folio {recetaEmitida.folio}
                </div>
              )}
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginTop: 8 }}>
                <Btn ol col={C.blue} onClick={vistaPreviaReceta}>
                  Vista previa PDF carta
                </Btn>
                <Btn col={BRAND.primary} onClick={emitirRecetaACaja} dis={enviandoReceta}>
                  {enviandoReceta ? "Enviando…" : "Enviar a caja para imprimir"}
                </Btn>
              </div>
            </>
          )}
          {readOnly && recetaEmitida?.folio && (
            <div style={{ fontSize: 12, fontWeight: 700, color: C.green }}>Folio {recetaEmitida.folio}</div>
          )}
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 8 }}>SEGUIMIENTO SUGERIDO</div>
          <p style={{ color: C.textMid, fontSize: 11, margin: "0 0 8px", lineHeight: 1.4 }}>
            No agenda sola: anota cuándo conviene volver. Mostrador o el paciente agendan.
          </p>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 8 }}>
            {SEGUIMIENTO_OPCIONES.map((o) => (
              <button
                key={o.dias}
                type="button"
                disabled={!puedeEditar}
                onClick={() => setSeguimientoDias(seguimientoDias === o.dias ? null : o.dias)}
                style={{
                  padding: "6px 12px",
                  borderRadius: 20,
                  border: `1px solid ${seguimientoDias === o.dias ? BRAND.primary : C.border}`,
                  background: seguimientoDias === o.dias ? BRAND.primary + "18" : "transparent",
                  color: seguimientoDias === o.dias ? BRAND.primary : C.textMid,
                  fontSize: 11,
                  fontWeight: 700,
                  cursor: puedeEditar ? "pointer" : "default",
                }}
              >
                {o.label}
              </button>
            ))}
          </div>
          {seguimientoDias ? (
            <div style={{ fontSize: 12, color: C.green, fontWeight: 700, marginBottom: 8 }}>
              {etiquetaSeguimiento(seguimientoDias, fechaSeguimiento(seguimientoDias, (citaLocal || cita)?.fecha))}
            </div>
          ) : null}
          <Inp
            value={seguimientoNota}
            onChange={(e) => setSeguimientoNota(e.target.value)}
            disabled={!puedeEditar}
            placeholder="Nota (ej. control de TA, revalorar antibiótico)"
            style={{ width: "100%" }}
          />
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 8 }}>NOTAS DE CONSULTA</div>
          <textarea
            className="farmacapital-field-input"
            value={notas}
            onChange={(e) => setNotas(e.target.value)}
            disabled={!puedeEditar}
            rows={3}
            style={fieldTextareaStyle}
          />
        </Box>

        {readOnly && procSel.length > 0 && (
          <Box style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 10 }}>PROCEDIMIENTOS</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {procSel.map((p) => (
                <Tag key={p.id || p.nombre} col={C.blue} sm>
                  {p.nombre}
                </Tag>
              ))}
            </div>
          </Box>
        )}

        {!readOnly && procsList?.length > 0 && puedeEditar && (
          <Box style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 10 }}>PROCEDIMIENTOS</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {procsList.map((p) => {
                const sel = procSel.find((s) => s.id === p.id);
                return (
                  <div key={p.id} style={{ display: "flex", flexDirection: "column", gap: 4, alignItems: "stretch" }}>
                    <button
                      type="button"
                      onClick={() => toggleProc(p)}
                      style={{
                        padding: "6px 12px",
                        borderRadius: 20,
                        border: `1px solid ${sel ? BRAND.primary : C.border}`,
                        background: sel ? BRAND.primary + "22" : "transparent",
                        color: sel ? BRAND.primary : C.textMid,
                        fontSize: 11,
                        fontWeight: 700,
                        cursor: "pointer",
                      }}
                    >
                      {p.nombre} — {$(p.precio)}
                    </button>
                    {sel && getPlantilla(p).length > 0 && (
                      <button type="button" onClick={() => aplicarPlantillaProc(p)} style={{ fontSize: 10, padding: "4px 8px", borderRadius: 6, border: `1px dashed ${C.blue}`, background: C.blueDim, color: C.blue, cursor: "pointer" }}>
                        + Consumibles del procedimiento
                      </button>
                    )}
                  </div>
                );
              })}
            </div>
          </Box>
        )}

        {((puedeEditar && prodList?.length > 0) || (readOnly && (citaLocal?.consumibles_consulta || []).length > 0)) && (
          <Box style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 10 }}>CONSUMIBLES (material de curación)</div>
            {puedeEditar && prodList?.length > 0 && (
              <>
                <div style={{ color: C.textDim, fontSize: 10, marginBottom: 10, lineHeight: 1.4 }}>
                  Solo material típico de consultorio (gasas, jeringas, guantes, etc.). Los precios de productos se editan en Inventario; las categorías permitidas, en <strong>Metas y Precios</strong> (admin).
                </div>
                <div style={{ display: "grid", gap: 6, maxHeight: 200, overflowY: "auto" }}>
                  {prodList.map((p) => (
                    <div key={p.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 8 }}>
                      <span style={{ fontSize: 12 }}>{p.nombre}</span>
                      <div style={{ display: "flex", gap: 4 }}>
                        {[1, 2, 3].map((q) => (
                          <button key={q} type="button" onClick={() => agregarConsumible(p, q)} style={{ padding: "4px 8px", borderRadius: 6, border: `1px solid ${C.blue}`, fontSize: 10, cursor: "pointer" }}>
                            +{q}
                          </button>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </>
            )}
            {(citaLocal?.consumibles_consulta || []).length > 0 && (
              <div style={{ marginTop: 10, fontSize: 11, color: C.textMid }}>
                {(citaLocal.consumibles_consulta || []).map((c, i) => (
                  <div key={i} style={{ display: "flex", justifyContent: "space-between", padding: "4px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span>{c.productos?.nombre || c.nombre || "—"} ×{c.cantidad}</span>
                    <span>{c.cobrado ? <Tag col={C.green} sm>Cobrado</Tag> : <Tag col={C.amber} sm>Pend. caja</Tag>}</span>
                  </div>
                ))}
              </div>
            )}
          </Box>
        )}

        <div style={{ display: "flex", gap: 10, justifyContent: "flex-end", flexWrap: "wrap", marginTop: 8 }}>
          <Btn ol col={C.textMid} onClick={onClose}>
            Cerrar
          </Btn>
          {puedeEditar && (
            <>
              <Btn ol col={C.blue} onClick={guardar} dis={guardando}>
                {guardando ? "Guardando…" : "Guardar avance"}
              </Btn>
              <Btn col={C.green} onClick={terminarConsulta} dis={guardando}>
                {guardando ? "Guardando…" : "Terminar consulta"}
              </Btn>
            </>
          )}
        </div>
        {puedeEditar && (
          <p style={{ color: C.textDim, fontSize: 10, marginTop: 10, lineHeight: 1.45, textAlign: "right" }}>
            <strong>Terminar consulta</strong> guarda la ficha y marca la visita como concluida; así puedes pasar a la siguiente paciente.
          </p>
        )}
      </div>
    </Modal>
  );
}
