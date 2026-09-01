/**
 * Receta médica — Consultorio FarmaCapital (México).
 *
 * Reglamento de Insumos para la Salud, art. 29: nombre del médico, domicilio,
 * número de cédula profesional, fecha y firma. Marca de consultorio (no ticket
 * de farmacia). Estupefacientes (grupo I) requieren recetario COFEPRIS aparte.
 */

import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";

const LOGO_SRC = "/brand/farmacapital-icon.png?v=6";

function esc(s) {
  return String(s ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

export function folioFromCita(citaId) {
  const n = Number(citaId);
  if (Number.isFinite(n) && n > 0) return `RX-${n}`;
  return `RX-${Date.now()}`;
}

function fechaLarga(isoOrDate) {
  const raw = isoOrDate ? String(isoOrDate).slice(0, 10) : "";
  const d = raw ? new Date(`${raw}T12:00:00`) : new Date();
  if (Number.isNaN(d.getTime())) {
    return new Date().toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" });
  }
  return d.toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" });
}

function horaVista(h) {
  const s = String(h ?? "").trim();
  if (!s) return "—";
  const m = s.match(/^(\d{1,2}):(\d{2})/);
  if (!m) return s;
  return `${String(parseInt(m[1], 10)).padStart(2, "0")}:${m[2]}`;
}

export function stockBadgeLabel(stock) {
  const n = Number(stock);
  if (!Number.isFinite(n)) return { label: "?", tone: "mid" };
  if (n <= 0) return { label: "Sin stock", tone: "red" };
  if (n <= 3) return { label: `Bajo (${n})`, tone: "amber" };
  return { label: `Stock ${n}`, tone: "green" };
}

/** Valida mínimo legal / operativo antes de imprimir o enviar a caja. */
export function validarRecetaMx({ medico, medicamentos, diagnostico } = {}) {
  const errores = [];
  const nombre = String(medico?.nombre || "").trim();
  const cedula = String(medico?.cedula || medico?.cedula_profesional || "").trim();
  if (!nombre) errores.push("Falta el nombre del médico que prescribe.");
  if (!cedula) {
    errores.push(
      "Falta la cédula profesional del médico (obligatoria en México). Captúrala en Consultorio → Médicos."
    );
  }
  const meds = Array.isArray(medicamentos) ? medicamentos : [];
  const conNombre = meds.filter((m) => String(m.medicamento || m.nombre || "").trim());
  if (!conNombre.length) errores.push("Agrega al menos un medicamento.");
  conNombre.forEach((m, i) => {
    const dosis = String(m.dosis || "").trim();
    const frec = String(m.frecuencia || "").trim();
    const ind = String(m.indicaciones || "").trim();
    if (!dosis && !frec && !ind) {
      errores.push(`Medicamento ${i + 1}: indica dosis, frecuencia o indicaciones.`);
    }
  });
  if (!String(diagnostico || "").trim()) {
    errores.push("Captura el diagnóstico antes de emitir la receta.");
  }
  return { ok: errores.length === 0, errores };
}

/**
 * @param {object} opts
 */
export function buildRecetaHtml(opts = {}) {
  const cita = opts.cita || {};
  const medico = opts.medico || {};
  const meds = Array.isArray(opts.medicamentos) ? opts.medicamentos : [];
  const firmaModo = opts.firmaModo === "digital" ? "digital" : "fisica";
  const folio = opts.folio || folioFromCita(cita.id);
  const nombreMed = String(medico.nombre || "").trim() || "Médico(a) en turno";
  const esp = String(medico.especialidad || "").trim() || "Medicina general";
  const ced = String(medico.cedula || medico.cedula_profesional || "").trim();
  const institucion = String(medico.institucion || medico.universidad || "").trim();
  const dx = String(opts.diagnostico || "").trim();
  const notas = String(opts.notas || "").trim();
  const extra = opts.pacienteExtra || {};
  const edad = String(extra.edad || cita.edad || "").trim();
  const sexo = String(extra.sexo || cita.sexo || "").trim();

  const domicilio =
    FARMACIA_FISCAL.direccion_comercial ||
    "Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208";
  const tel = FARMACIA_FISCAL.telefono_display || FARMACIA_FISCAL.telefono || "";
  const web = FARMACIA_FISCAL.sitio_web || "farmacapital.mx";

  const medsHTML = meds
    .filter((m) => String(m.medicamento || m.nombre || "").trim())
    .map((m, idx) => {
      const nom = esc(m.medicamento || m.nombre);
      const cant = Math.max(1, Number(m.cantidad) || 1);
      const dosis = String(m.dosis || "").trim();
      const via = String(m.via || m.via_admin || "").trim();
      const frec = String(m.frecuencia || "").trim();
      const dur = String(m.duracion || "").trim();
      const ind = String(m.indicaciones || "").trim();
      const detalle =
        [dosis && `Dosis: ${dosis}`, via && `Vía: ${via}`, frec && `Frecuencia: ${frec}`, dur && `Duración: ${dur}`, ind]
          .filter(Boolean)
          .map(esc)
          .join(" · ") || "—";
      return `<tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;vertical-align:top;width:28px;color:#64748b;font-size:11px">${idx + 1}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;font-weight:600;vertical-align:top">${nom}${cant > 1 ? ` <span style="color:#64748b;font-weight:500">×${cant}</span>` : ""}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;vertical-align:top;font-size:12px;line-height:1.45">${detalle}</td>
      </tr>`;
    })
    .join("");

  const firmaBlock =
    firmaModo === "digital" && opts.firmaDataUrl
      ? `<div class="firma-box">
          <img src="${esc(opts.firmaDataUrl)}" alt="Firma" style="max-height:72px;max-width:220px;display:block;margin:0 auto 6px"/>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma del médico<br/><strong>${esc(nombreMed)}</strong>${ced ? `<br/>Céd. ${esc(ced)}` : ""}</div>
        </div>`
      : `<div class="firma-box">
          <div style="height:56px"></div>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma autógrafa y sello del médico<br/><strong>${esc(nombreMed)}</strong>${ced ? `<br/>Céd. ${esc(ced)}` : "<br/>Céd. ________________"}</div>
        </div>`;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <title>Receta médica — ${esc(folio)}</title>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { font-family: Georgia, "Times New Roman", serif; font-size: 13px; color: #0f172a; padding: 28px; max-width: 720px; margin: 0 auto; background:#fff; }
    .header { display:flex; justify-content:space-between; align-items:flex-start; border-bottom: 2.5px solid #0D1B2A; padding-bottom: 14px; margin-bottom: 18px; gap:16px; }
    .brand-name { font-family: Arial, Helvetica, sans-serif; font-size: 18px; font-weight: 800; color:#0D1B2A; letter-spacing:0.02em; margin-top:6px; }
    .brand-sub { font-family: Arial, Helvetica, sans-serif; font-size:11px; color:#475569; margin-top:2px; }
    .logo img { height: 40px; width: 40px; display:block; object-fit:contain; }
    .clinic { text-align:right; font-size:11px; color:#475569; font-family: Arial, Helvetica, sans-serif; line-height:1.45; }
    .medico { background:#f0f4f9; border-radius:8px; padding:12px 16px; margin-bottom:16px; font-family: Arial, Helvetica, sans-serif; }
    .medico h3 { color:#0D1B2A; font-size:11px; margin-bottom:6px; text-transform:uppercase; letter-spacing:0.06em; }
    .paciente { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px; padding:12px 16px; border:1px solid #e2e8f0; border-radius:8px; font-family: Arial, Helvetica, sans-serif; }
    .field label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; letter-spacing:0.04em; }
    .field p { font-size:13px; color:#0f172a; font-weight:600; margin-top:2px; }
    h4 { font-family: Arial, Helvetica, sans-serif; color:#0D1B2A; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px; }
    table { width:100%; border-collapse:collapse; margin-bottom:16px; font-family: Arial, Helvetica, sans-serif; }
    thead tr { background:#f8fafc; }
    th { padding:8px 12px; text-align:left; font-size:11px; color:#475569; font-weight:700; border-bottom:1px solid #e2e8f0; }
    .dx { background:#f8fafc; border-radius:8px; padding:12px 16px; margin-bottom:16px; font-family: Arial, Helvetica, sans-serif; }
    .notas { border:1px solid #e2e8f0; border-radius:8px; padding:12px 16px; margin-bottom:24px; font-family: Arial, Helvetica, sans-serif; }
    .aviso { font-family: Arial, Helvetica, sans-serif; font-size:10px; color:#64748b; margin:12px 0 0; line-height:1.45; }
    .firma { display:grid; grid-template-columns:1fr 1fr; gap:40px; margin-top:36px; font-family: Arial, Helvetica, sans-serif; }
    .firma-box { text-align:center; font-size:11px; color:#475569; }
    .footer { text-align:center; font-size:10px; color:#94a3b8; border-top:1px solid #e2e8f0; padding-top:12px; margin-top:20px; font-family: Arial, Helvetica, sans-serif; line-height:1.5; }
    @media print { body { padding:12px; } .no-print { display:none !important; } }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div class="logo"><img src="${LOGO_SRC}" alt="FarmaCapital"/></div>
      <div class="brand-name">FarmaCapital</div>
      <div class="brand-sub">Consultorio médico</div>
    </div>
    <div class="clinic">
      <div>${esc(domicilio)}</div>
      ${tel ? `<div>Tel. ${esc(tel)}</div>` : ""}
      <div style="margin-top:6px"><strong>Fecha:</strong> ${esc(fechaLarga(cita.fecha || undefined))}</div>
      <div><strong>Folio:</strong> ${esc(folio)}</div>
    </div>
  </div>

  <div class="medico">
    <h3>Médico que prescribe</h3>
    <div style="font-weight:700;font-size:15px">${esc(nombreMed)}</div>
    <div style="color:#475569;font-size:12px;margin-top:4px">
      ${esc(esp)}
      ${ced ? ` · Cédula profesional: <strong>${esc(ced)}</strong>` : " · Cédula profesional: <strong style='color:#b91c1c'>NO CAPTURADA</strong>"}
    </div>
    ${institucion ? `<div style="color:#475569;font-size:11px;margin-top:4px">Institución que expidió el título: ${esc(institucion)}</div>` : ""}
    <div style="color:#475569;font-size:11px;margin-top:4px">Domicilio del consultorio: ${esc(domicilio)}</div>
  </div>

  <div class="paciente">
    <div class="field"><label>Paciente</label><p>${esc(cita.nombre || "—")}</p></div>
    <div class="field"><label>Teléfono</label><p>${esc(cita.telefono || "—")}</p></div>
    <div class="field"><label>Edad</label><p>${esc(edad || "—")}</p></div>
    <div class="field"><label>Sexo</label><p>${esc(sexo || "—")}</p></div>
    <div class="field"><label>Fecha consulta</label><p>${esc(cita.fecha || "—")}</p></div>
    <div class="field"><label>Hora</label><p>${esc(horaVista(cita.hora))}</p></div>
    <div class="field" style="grid-column:1/-1"><label>Motivo de consulta</label><p>${esc(cita.motivo || "Consulta general")}</p></div>
  </div>

  <div class="dx">
    <h4>Diagnóstico</h4>
    <p style="line-height:1.6">${esc(dx || "—")}</p>
  </div>

  ${medsHTML ? `
  <h4>Prescripción (Rp.)</h4>
  <table>
    <thead><tr><th>#</th><th>Medicamento (genérico / presentación)</th><th>Dosis · vía · frecuencia · duración</th></tr></thead>
    <tbody>${medsHTML}</tbody>
  </table>` : ""}

  ${notas ? `
  <div class="notas">
    <h4>Indicaciones adicionales</h4>
    <p style="line-height:1.6;margin-top:8px">${esc(notas)}</p>
  </div>` : ""}

  <p class="aviso">
    Receta ordinaria del consultorio médico FarmaCapital. Los antibióticos requieren sello de farmacia al surtir.
    Estupefacientes y psicotrópicos de control especial requieren recetario oficial COFEPRIS (no usar esta plantilla).
  </p>

  <div class="firma">
    ${firmaBlock}
    <div class="firma-box">
      <div style="height:56px"></div>
      <div style="border-top:1px solid #0f172a;padding-top:8px">Sello del consultorio<br/><strong>FarmaCapital · Consultorio médico</strong></div>
    </div>
  </div>

  <div class="footer">
    Presentar en mostrador FarmaCapital (planta baja) para surtir.<br/>
    ${esc(domicilio)}${tel ? ` · ${esc(tel)}` : ""} · ${esc(web)}
  </div>
</body>
</html>`;
}

/** Abre ventana e imprime (carta). */
export function openRecetaPrint(html) {
  if (typeof window === "undefined") return false;
  const win = window.open("", "_blank", "width=750,height=900,scrollbars=1,resizable=1");
  if (!win) {
    try {
      window.alert(
        "No se pudo abrir la ventana de impresión. Permite ventanas emergentes para farmacapital.mx."
      );
    } catch {
      /* noop */
    }
    return false;
  }
  win.document.open();
  win.document.write(html);
  win.document.close();
  win.focus();
  setTimeout(() => {
    try {
      win.print();
    } catch (e) {
      console.error("[recetaPrint]", e);
    }
  }, 450);
  return true;
}
