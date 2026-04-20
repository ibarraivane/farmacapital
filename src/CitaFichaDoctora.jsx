import { useState, useEffect, useCallback } from "react";
import { supabase } from "./supabase";
import { C_LIGHT, BRAND } from "./constants";
import { $ } from "./utils";
import { Btn, Modal, Box, Tag, Inp, showToast, SearchDropdown } from "./ui";
import { citaPagoOk } from "./utils/consultaConstants";

const C = C_LIGHT;

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
        indicaciones: m.indicaciones != null ? String(m.indicaciones) : "",
        surtido: m.surtido === "farmax" || m.surtido === "externa" ? m.surtido : "pendiente",
      }))
      .filter((m) => m.medicamento || m.producto_id);
  }
  if (typeof mp === "string") {
    return mp
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => ({ _uid: uid(), producto_id: null, medicamento: line, cantidad: 1, dosis: "", indicaciones: "", surtido: "pendiente" }));
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
      indicaciones: rest.indicaciones != null ? String(rest.indicaciones) : "",
      surtido: rest.surtido === "farmax" || rest.surtido === "externa" ? rest.surtido : "pendiente",
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
export function CitaFichaModal({ cita, open, onClose, prodList, procsList, onSaved }) {
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

  const reload = useCallback(async () => {
    if (!cita?.id) return;
    const { data, error } = await supabase
      .from("citas")
      .select(`*,consumibles_consulta(id,cantidad,precio,cobrado,producto_id,productos!producto_id(nombre))`)
      .eq("id", cita.id)
      .single();
    if (error) {
      console.error(error);
      setCitaLocal(cita);
      return;
    }
    setCitaLocal(data);
    const sv = data.signos_vitales && typeof data.signos_vitales === "object" ? data.signos_vitales : {};
    setVit({
      ta: sv.ta ?? "",
      fc: sv.fc ?? "",
      temp: sv.temp ?? "",
      sat: sv.sat ?? "",
      peso: sv.peso ?? "",
      talla: sv.talla ?? "",
    });
    const ej = data.expediente_json && typeof data.expediente_json === "object" ? data.expediente_json : {};
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
    const pr = data.procedimientos_realizados;
    if (Array.isArray(pr) && pr.length && typeof pr[0] === "object") {
      setProcSel(pr);
    } else {
      setProcSel([]);
    }
  }, [cita?.id, cita]);

  useEffect(() => {
    if (open && cita?.id) reload();
  }, [open, cita?.id, reload]);

  useEffect(() => {
    if (!open || !cita?.id) return;
    let cancelled = false;
    (async () => {
      const { data } = await supabase.from("productos").select("id,nombre,precio,sku,stock").eq("activo", true).order("nombre").limit(2500);
      if (!cancelled) setProdCatalog(data || []);
    })();
    return () => {
      cancelled = true;
    };
  }, [open, cita?.id]);

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
      await supabase.from("consumibles_consulta").insert({
        cita_id: citaLocal.id,
        producto_id: prod.id,
        cantidad: qty,
        precio: prod.precio,
        cobrado: false,
      });
      await supabase.from("citas").update({ estado: "en_consulta" }).eq("id", citaLocal.id);
      await reload();
    } catch (e) {
      console.error(e);
    }
  };

  const aplicarPlantillaProc = async (proc) => {
    const tpl = getPlantilla(proc);
    if (!citaLocal?.id || !tpl.length) return;
    for (const row of tpl) {
      const pid = row.producto_id;
      const cant = Number(row.cantidad) || 1;
      const prod = prodList.find((p) => p.id === pid);
      if (!prod) continue;
      await supabase.from("consumibles_consulta").insert({
        cita_id: citaLocal.id,
        producto_id: pid,
        cantidad: cant,
        precio: prod.precio,
        cobrado: false,
      });
    }
    await reload();
  };

  const agregarMedCatalogo = (prod) => {
    if (!prod?.id) return;
    if (medsRows.some((r) => r.producto_id === prod.id)) {
      showToast("Ese producto ya está en la receta.", "warning");
      return;
    }
    setMedsRows((rows) => [
      ...rows,
      {
        _uid: uid(),
        producto_id: prod.id,
        medicamento: prod.nombre,
        cantidad: 1,
        dosis: "",
        indicaciones: "",
        surtido: "pendiente",
      },
    ]);
    setProdBusq("");
  };

  const agregarLineaLibre = () => {
    setMedsRows((rows) => [...rows, { _uid: uid(), producto_id: null, medicamento: "", cantidad: 1, dosis: "", indicaciones: "", surtido: "pendiente" }]);
  };

  const quitarMed = (_uid) => setMedsRows((rows) => rows.filter((r) => r._uid !== _uid));

  const setMedRow = (_uid, patch) => setMedsRows((rows) => rows.map((r) => (r._uid === _uid ? { ...r, ...patch } : r)));

  const guardar = async () => {
    if (!citaLocal?.id) return;
    setGuard(true);
    try {
      const medsArr = serializeMeds(medsRows);

      const { error } = await supabase
        .from("citas")
        .update({
          signos_vitales: {
            ta: vit.ta || null,
            fc: vit.fc || null,
            temp: vit.temp || null,
            sat: vit.sat || null,
            peso: vit.peso || null,
            talla: vit.talla || null,
          },
          expediente_json: {
            alergias: exp.alergias || null,
            antecedentes: exp.antecedentes || null,
            sexo: exp.sexo || null,
            edad: exp.edad || null,
          },
          diagnostico: diagnostico.trim() || null,
          notas_medico: notas.trim() || null,
          medicamentos_prescritos: medsArr.length ? medsArr : null,
          receta_surtido_en: recetaSurtido === "pendiente" ? null : recetaSurtido,
          procedimientos_realizados: procSel.length ? procSel : null,
        })
        .eq("id", citaLocal.id);

      if (error) throw error;

      if (citaLocal.telefono && (exp.alergias?.trim() || exp.antecedentes?.trim())) {
        const nota = [exp.alergias?.trim() && `ALERGIAS: ${exp.alergias.trim()}`, exp.antecedentes?.trim() && `ANTECEDENTES: ${exp.antecedentes.trim()}`]
          .filter(Boolean)
          .join(" | ");
        await supabase.from("clientes").update({ notas: nota }).eq("telefono", citaLocal.telefono);
      }

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
    if (!citaLocal?.id) return;
    if (!diagnostico.trim()) {
      showToast("Indica un diagnóstico antes de terminar la consulta.", "warning");
      return;
    }
    setGuard(true);
    try {
      const medsArr = serializeMeds(medsRows);
      const finPatch = patchConsultaFin(citaLocal);

      const { error } = await supabase
        .from("citas")
        .update({
          signos_vitales: {
            ta: vit.ta || null,
            fc: vit.fc || null,
            temp: vit.temp || null,
            sat: vit.sat || null,
            peso: vit.peso || null,
            talla: vit.talla || null,
          },
          expediente_json: {
            alergias: exp.alergias || null,
            antecedentes: exp.antecedentes || null,
            sexo: exp.sexo || null,
            edad: exp.edad || null,
          },
          diagnostico: diagnostico.trim(),
          notas_medico: notas.trim() || null,
          medicamentos_prescritos: medsArr.length ? medsArr : null,
          receta_surtido_en: recetaSurtido === "pendiente" ? null : recetaSurtido,
          procedimientos_realizados: procSel.length ? procSel : null,
          estado: "completada",
          ...finPatch,
        })
        .eq("id", citaLocal.id);

      if (error) throw error;

      if (citaLocal.telefono && (exp.alergias?.trim() || exp.antecedentes?.trim())) {
        const nota = [exp.alergias?.trim() && `ALERGIAS: ${exp.alergias.trim()}`, exp.antecedentes?.trim() && `ANTECEDENTES: ${exp.antecedentes.trim()}`]
          .filter(Boolean)
          .join(" | ");
        await supabase.from("clientes").update({ notas: nota }).eq("telefono", citaLocal.telefono);
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

  const puedeEditar = citaPagoOk(citaLocal || cita);

  return (
    <Modal open={open} onClose={onClose} title="📋 Ficha clínica" ac={BRAND.primary}>
      <div style={{ maxHeight: "min(78vh, 720px)", overflowY: "auto", paddingRight: 4 }}>
        {!puedeEditar && (
          <div style={{ background: C.amberDim, border: `1px solid ${C.amber}40`, borderRadius: 10, padding: 12, marginBottom: 14, color: C.amber, fontSize: 12, fontWeight: 700 }}>
            Pendiente de pago en caja. La ficha completa estará disponible cuando el paciente pague la consulta.
          </div>
        )}

        <div style={{ color: C.textMid, fontSize: 13, marginBottom: 16 }}>
          <strong style={{ color: C.text }}>{(citaLocal || cita).nombre}</strong> · {(citaLocal || cita).telefono || "—"} · {(citaLocal || cita).hora}
        </div>

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
              value={exp.alergias}
              onChange={(e) => setExp((x) => ({ ...x, alergias: e.target.value }))}
              disabled={!puedeEditar}
              rows={2}
              style={{ width: "100%", borderRadius: 8, border: `1px solid ${C.border}`, padding: 8, fontSize: 12, resize: "vertical" }}
            />
          </div>
          <div>
            <div style={{ color: C.amber, fontSize: 10, fontWeight: 700 }}>Antecedentes</div>
            <textarea
              value={exp.antecedentes}
              onChange={(e) => setExp((x) => ({ ...x, antecedentes: e.target.value }))}
              disabled={!puedeEditar}
              rows={2}
              style={{ width: "100%", borderRadius: 8, border: `1px solid ${C.border}`, padding: 8, fontSize: 12, resize: "vertical" }}
            />
          </div>
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>DIAGNÓSTICO</div>
          <textarea
            value={diagnostico}
            onChange={(e) => setDx(e.target.value)}
            disabled={!puedeEditar}
            rows={2}
            placeholder="Diagnóstico o impresión clínica"
            style={{ width: "100%", borderRadius: 8, border: `1px solid ${C.border}`, padding: 8, fontSize: 12 }}
          />
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>MEDICAMENTOS (catálogo Farmax + texto libre)</div>
          <div style={{ color: C.textMid, fontSize: 10, marginBottom: 10, lineHeight: 1.45 }}>
            Agrega productos del <strong>inventario</strong> para vincular con caja: cuando el paciente pague en mostrador con «receta de médico Farmax», el sistema marcará esas líneas como surtidas aquí. Puedes añadir líneas solo con nombre si la receta es externa o a mano.
          </div>
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
                badgeCol="#0099e6"
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
                        onChange={(e) => setMedRow(row._uid, { medicamento: e.target.value })}
                        disabled={!puedeEditar}
                        placeholder="Nombre del medicamento"
                        style={{ flex: 1, minWidth: 160 }}
                      />
                    )}
                    {row.surtido === "farmax" && (
                      <Tag col={C.green} sm>
                        Surtido Farmax
                      </Tag>
                    )}
                    {row.surtido === "externa" && (
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
                    <div style={{ flex: 1, minWidth: 100 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Dosis</div>
                      <Inp value={row.dosis} onChange={(e) => setMedRow(row._uid, { dosis: e.target.value })} disabled={!puedeEditar} style={{ width: "100%" }} />
                    </div>
                    <div style={{ flex: 1, minWidth: 120 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Indicaciones</div>
                      <Inp value={row.indicaciones} onChange={(e) => setMedRow(row._uid, { indicaciones: e.target.value })} disabled={!puedeEditar} style={{ width: "100%" }} />
                    </div>
                    <div style={{ minWidth: 130 }}>
                      <div style={{ fontSize: 9, color: C.textDim, marginBottom: 2 }}>Surtido</div>
                      <select
                        value={row.surtido || "pendiente"}
                        onChange={(e) => setMedRow(row._uid, { surtido: e.target.value })}
                        disabled={!puedeEditar}
                        style={{ width: "100%", padding: "6px 8px", borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 11 }}
                      >
                        <option value="pendiente">Pendiente</option>
                        <option value="farmax">Farmax</option>
                        <option value="externa">Otra farmacia</option>
                      </select>
                    </div>
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
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>¿Dónde surtió la receta?</div>
          <select
            value={recetaSurtido}
            onChange={(e) => setRecetaSurtido(e.target.value)}
            disabled={!puedeEditar}
            style={{ width: "100%", padding: 8, borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 12 }}
          >
            <option value="pendiente">Pendiente / no aplica</option>
            <option value="farmax">Farmax (esta farmacia)</option>
            <option value="externa">Otra farmacia</option>
          </select>
          <div style={{ color: C.textDim, fontSize: 10, marginTop: 6, lineHeight: 1.4 }}>
            Registrar aquí permite medir ingresos por recetas surtidas en Farmax frente a desviaciones a otras farmacias.
          </div>
        </Box>

        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 8 }}>NOTAS DE CONSULTA</div>
          <textarea
            value={notas}
            onChange={(e) => setNotas(e.target.value)}
            disabled={!puedeEditar}
            rows={3}
            style={{ width: "100%", borderRadius: 8, border: `1px solid ${C.border}`, padding: 8, fontSize: 12 }}
          />
        </Box>

        {procsList?.length > 0 && puedeEditar && (
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

        {puedeEditar && prodList?.length > 0 && (
          <Box style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, marginBottom: 10 }}>CONSUMIBLES (material de curación)</div>
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
            {(citaLocal?.consumibles_consulta || []).length > 0 && (
              <div style={{ marginTop: 10, fontSize: 11, color: C.textMid }}>
                {(citaLocal.consumibles_consulta || []).map((c, i) => (
                  <div key={i} style={{ display: "flex", justifyContent: "space-between", padding: "4px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span>{c.productos?.nombre || "—"} ×{c.cantidad}</span>
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
