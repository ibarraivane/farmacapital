/**
 * Receta médica — Consultorio FarmaCapital (México).
 *
 * Reglamento de Insumos para la Salud, art. 29: nombre del médico, domicilio
 * del consultorio, cédula profesional, fecha y firma. Formato carta (letter).
 * Marca de consultorio, no ticket de farmacia.
 * Estupefacientes (grupo I) requieren recetario oficial COFEPRIS — fuera de alcance.
 */

import { jsPDF } from "jspdf";
import { FARMACIA_FISCAL } from "../constants/farmaciaFiscal";

const LOGO_SRC = "/brand/farmacapital-icon.png?v=6";

function esc(s) {
  return String(s ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

/** Folio de respaldo si aún no corrió el SQL (secuencia FC-RX-AAAA-NNNNNN). */
export function folioFromCita(citaId) {
  const n = Number(citaId);
  if (Number.isFinite(n) && n > 0) return `FC-RX-LOCAL-${n}`;
  return `FC-RX-LOCAL-${Date.now()}`;
}

export function esFolioReceta(folio) {
  return /^FC-RX-(\d{4}-\d{6}|LOCAL-\d+)$/.test(String(folio || "").trim());
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

function lineasMed(medicamentos) {
  return (Array.isArray(medicamentos) ? medicamentos : []).filter((m) =>
    String(m.medicamento || m.nombre || "").trim()
  );
}

function detalleLinea(m) {
  const dosis = String(m.dosis || "").trim();
  const via = String(m.via || m.via_admin || "").trim();
  const frec = String(m.frecuencia || "").trim();
  const dur = String(m.duracion || "").trim();
  const ind = String(m.indicaciones || "").trim();
  return [dosis && `Dosis: ${dosis}`, via && `Vía: ${via}`, frec && `Frecuencia: ${frec}`, dur && `Duración: ${dur}`, ind]
    .filter(Boolean)
    .join(" · ");
}

/** Valida mínimo legal / operativo antes de emitir o imprimir. */
export function validarRecetaMx({ medico, medicamentos, diagnostico, firmaModo, firmaDataUrl } = {}) {
  const errores = [];
  const nombre = String(medico?.nombre || "").trim();
  const cedula = String(medico?.cedula || medico?.cedula_profesional || "").trim();
  if (!nombre) errores.push("Falta el nombre del médico que prescribe.");
  if (!cedula) {
    errores.push("Falta la cédula profesional del médico (obligatoria en México). Captúrala en Consultorio → Médicos.");
  }
  const conNombre = lineasMed(medicamentos);
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
  if (firmaModo === "digital" && !String(firmaDataUrl || "").trim()) {
    errores.push("Falta la firma digital o elige firma física (autógrafa en el papel).");
  }
  return { ok: errores.length === 0, errores };
}

function recetaCampos(opts = {}) {
  const cita = opts.cita || {};
  const medico = opts.medico || {};
  const meds = lineasMed(opts.medicamentos);
  const firmaModo = opts.firmaModo === "digital" ? "digital" : "fisica";
  const folio = opts.folio || folioFromCita(cita.id);
  return {
    cita,
    medico,
    meds,
    firmaModo,
    folio,
    nombreMed: String(medico.nombre || "").trim() || "Médico(a) en turno",
    esp: String(medico.especialidad || "").trim() || "Medicina general",
    ced: String(medico.cedula || medico.cedula_profesional || "").trim(),
    institucion: String(medico.institucion || medico.universidad || "").trim(),
    dx: String(opts.diagnostico || "").trim(),
    notas: String(opts.notas || "").trim(),
    alergias: String(opts.alergias || "").trim(),
    extra: opts.pacienteExtra || {},
    edad: String((opts.pacienteExtra || {}).edad || cita.edad || "").trim(),
    sexo: String((opts.pacienteExtra || {}).sexo || cita.sexo || "").trim(),
    domicilio:
      FARMACIA_FISCAL.direccion_comercial ||
      "Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208",
    tel: FARMACIA_FISCAL.telefono_display || FARMACIA_FISCAL.telefono || "",
    web: FARMACIA_FISCAL.sitio_web || "farmacapital.mx",
    firmaDataUrl: opts.firmaDataUrl || "",
    seguimiento: String(opts.seguimiento || "").trim(),
  };
}

/**
 * HTML carta para window.print (misma familia que tickets).
 */
export function buildRecetaHtml(opts = {}) {
  const c = recetaCampos(opts);
  const medsHTML = c.meds
    .map((m, idx) => {
      const nom = esc(m.medicamento || m.nombre);
      const cant = Math.max(1, Number(m.cantidad) || 1);
      const detalle = esc(detalleLinea(m) || "—");
      return `<tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;vertical-align:top;width:28px;color:#64748b;font-size:11px">${idx + 1}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;font-weight:600;vertical-align:top">${nom}${cant > 1 ? ` <span style="color:#64748b;font-weight:500">×${cant}</span>` : ""}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;vertical-align:top;font-size:12px;line-height:1.45">${detalle}</td>
      </tr>`;
    })
    .join("");

  const firmaBlock =
    c.firmaModo === "digital" && c.firmaDataUrl
      ? `<div class="firma-box">
          <img src="${esc(c.firmaDataUrl)}" alt="Firma" style="max-height:72px;max-width:220px;display:block;margin:0 auto 6px"/>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma del médico<br/><strong>${esc(c.nombreMed)}</strong>${c.ced ? `<br/>Céd. ${esc(c.ced)}` : ""}</div>
        </div>`
      : `<div class="firma-box">
          <div style="height:56px"></div>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma autógrafa y sello del médico<br/><strong>${esc(c.nombreMed)}</strong>${c.ced ? `<br/>Céd. ${esc(c.ced)}` : "<br/>Céd. ________________"}</div>
        </div>`;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <title>Receta médica — ${esc(c.folio)}</title>
  <style>
    @page { size: letter; margin: 14mm; }
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
    .notas { border:1px solid #e2e8f0; border-radius:8px; padding:12px 16px; margin-bottom:16px; font-family: Arial, Helvetica, sans-serif; }
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
      <div>${esc(c.domicilio)}</div>
      ${c.tel ? `<div>Tel. ${esc(c.tel)}</div>` : ""}
      <div style="margin-top:6px"><strong>Fecha:</strong> ${esc(fechaLarga(c.cita.fecha || undefined))}</div>
      <div><strong>Folio:</strong> ${esc(c.folio)}</div>
    </div>
  </div>

  <div class="medico">
    <h3>Médico que prescribe</h3>
    <div style="font-weight:700;font-size:15px">${esc(c.nombreMed)}</div>
    <div style="color:#475569;font-size:12px;margin-top:4px">
      ${esc(c.esp)}
      ${c.ced ? ` · Cédula profesional: <strong>${esc(c.ced)}</strong>` : " · Cédula profesional: <strong style='color:#b91c1c'>NO CAPTURADA</strong>"}
    </div>
    ${c.institucion ? `<div style="color:#475569;font-size:11px;margin-top:4px">Institución que expidió el título: ${esc(c.institucion)}</div>` : ""}
    <div style="color:#475569;font-size:11px;margin-top:4px">Domicilio del consultorio: ${esc(c.domicilio)}</div>
  </div>

  <div class="paciente">
    <div class="field"><label>Paciente</label><p>${esc(c.cita.nombre || "—")}</p></div>
    <div class="field"><label>Teléfono</label><p>${esc(c.cita.telefono || "—")}</p></div>
    <div class="field"><label>Edad</label><p>${esc(c.edad || "—")}</p></div>
    <div class="field"><label>Sexo</label><p>${esc(c.sexo || "—")}</p></div>
    <div class="field"><label>Fecha consulta</label><p>${esc(c.cita.fecha || "—")}</p></div>
    <div class="field"><label>Hora</label><p>${esc(horaVista(c.cita.hora))}</p></div>
    <div class="field" style="grid-column:1/-1"><label>Motivo de consulta</label><p>${esc(c.cita.motivo || "Consulta general")}</p></div>
  </div>

  ${c.alergias ? `<div class="notas" style="border-color:#fecaca;background:#fef2f2"><h4 style="color:#b91c1c">Alergias declaradas</h4><p style="line-height:1.6;margin-top:8px">${esc(c.alergias)}</p></div>` : ""}

  <div class="dx">
    <h4>Diagnóstico</h4>
    <p style="line-height:1.6">${esc(c.dx || "—")}</p>
  </div>

  ${medsHTML ? `
  <h4>Prescripción (Rp.)</h4>
  <table>
    <thead><tr><th>#</th><th>Medicamento (genérico / presentación)</th><th>Dosis · vía · frecuencia · duración</th></tr></thead>
    <tbody>${medsHTML}</tbody>
  </table>` : ""}

  ${c.notas ? `
  <div class="notas">
    <h4>Indicaciones adicionales</h4>
    <p style="line-height:1.6;margin-top:8px">${esc(c.notas)}</p>
  </div>` : ""}

  ${c.seguimiento ? `
  <div class="notas">
    <h4>Seguimiento sugerido</h4>
    <p style="line-height:1.6;margin-top:8px">${esc(c.seguimiento)}</p>
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
    ${esc(c.domicilio)}${c.tel ? ` · ${esc(c.tel)}` : ""} · ${esc(c.web)}
  </div>
</body>
</html>`;
}

/** PDF carta (letter, 215.9 × 279.4 mm). */
export function buildRecetaPdf(opts = {}) {
  const c = recetaCampos(opts);
  const doc = new jsPDF({ orientation: "portrait", unit: "mm", format: "letter" });
  const W = 215.9;
  const M = 16;
  const AZUL = [13, 27, 42];
  const GRIS = [71, 85, 105];
  const NEGRO = [15, 23, 42];
  let y = 16;

  doc.setFillColor(...AZUL);
  doc.roundedRect(M, y, 42, 12, 2, 2, "F");
  doc.setTextColor(255, 255, 255);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(10);
  doc.text("FarmaCapital", M + 21, y + 7.5, { align: "center" });

  doc.setTextColor(...NEGRO);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(14);
  doc.text("RECETA MÉDICA", W - M, y + 5, { align: "right" });
  doc.setFont("helvetica", "normal");
  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  doc.text(`Folio ${c.folio}`, W - M, y + 11, { align: "right" });
  doc.text(fechaLarga(c.cita.fecha || undefined), W - M, y + 15, { align: "right" });

  y += 20;
  doc.setDrawColor(...AZUL);
  doc.setLineWidth(0.6);
  doc.line(M, y, W - M, y);
  y += 6;

  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  const dirLines = doc.splitTextToSize(`${c.domicilio}${c.tel ? ` · Tel. ${c.tel}` : ""}`, W - M * 2);
  doc.text(dirLines, M, y);
  y += dirLines.length * 4 + 4;

  doc.setFillColor(240, 244, 249);
  doc.roundedRect(M, y, W - M * 2, 22, 2, 2, "F");
  doc.setTextColor(...AZUL);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(8);
  doc.text("MÉDICO QUE PRESCRIBE", M + 4, y + 5);
  doc.setTextColor(...NEGRO);
  doc.setFontSize(11);
  doc.text(c.nombreMed, M + 4, y + 11);
  doc.setFont("helvetica", "normal");
  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  doc.text(
    `${c.esp} · Cédula profesional: ${c.ced || "NO CAPTURADA"}${c.institucion ? ` · ${c.institucion}` : ""}`,
    M + 4,
    y + 17
  );
  y += 28;

  doc.setFont("helvetica", "bold");
  doc.setFontSize(8);
  doc.setTextColor(...AZUL);
  doc.text("PACIENTE", M, y);
  y += 5;
  doc.setFont("helvetica", "normal");
  doc.setFontSize(10);
  doc.setTextColor(...NEGRO);
  doc.text(String(c.cita.nombre || "—"), M, y);
  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  doc.text(
    `Tel. ${c.cita.telefono || "—"} · Edad ${c.edad || "—"} · Sexo ${c.sexo || "—"} · ${c.cita.fecha || ""} ${horaVista(c.cita.hora)}`,
    M,
    y + 5
  );
  y += 12;

  if (c.alergias) {
    doc.setTextColor(185, 28, 28);
    doc.setFont("helvetica", "bold");
    doc.setFontSize(8);
    doc.text("ALERGIAS DECLARADAS", M, y);
    doc.setFont("helvetica", "normal");
    const al = doc.splitTextToSize(c.alergias, W - M * 2);
    doc.text(al, M, y + 4);
    y += 4 + al.length * 4 + 3;
  }

  doc.setTextColor(...AZUL);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(8);
  doc.text("DIAGNÓSTICO", M, y);
  y += 5;
  doc.setFont("helvetica", "normal");
  doc.setTextColor(...NEGRO);
  doc.setFontSize(10);
  const dxLines = doc.splitTextToSize(c.dx || "—", W - M * 2);
  doc.text(dxLines, M, y);
  y += dxLines.length * 5 + 6;

  doc.setTextColor(...AZUL);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(8);
  doc.text("PRESCRIPCIÓN (Rp.)", M, y);
  y += 6;
  doc.setFont("helvetica", "normal");
  doc.setFontSize(9);
  c.meds.forEach((m, idx) => {
    if (y > 240) {
      doc.addPage();
      y = 18;
    }
    const nom = String(m.medicamento || m.nombre);
    const cant = Math.max(1, Number(m.cantidad) || 1);
    doc.setTextColor(...NEGRO);
    doc.setFont("helvetica", "bold");
    doc.text(`${idx + 1}. ${nom}${cant > 1 ? `  ×${cant}` : ""}`, M, y);
    y += 4;
    const det = detalleLinea(m) || "—";
    doc.setFont("helvetica", "normal");
    doc.setTextColor(...GRIS);
    const detLines = doc.splitTextToSize(det, W - M * 2 - 4);
    doc.text(detLines, M + 4, y);
    y += detLines.length * 4 + 3;
  });

  if (c.notas) {
    y += 2;
    doc.setFont("helvetica", "bold");
    doc.setTextColor(...AZUL);
    doc.setFontSize(8);
    doc.text("INDICACIONES ADICIONALES", M, y);
    y += 5;
    doc.setFont("helvetica", "normal");
    doc.setTextColor(...NEGRO);
    doc.setFontSize(9);
    const nLines = doc.splitTextToSize(c.notas, W - M * 2);
    doc.text(nLines, M, y);
    y += nLines.length * 4 + 4;
  }

  if (c.seguimiento) {
    doc.setFont("helvetica", "bold");
    doc.setTextColor(...AZUL);
    doc.setFontSize(8);
    doc.text("SEGUIMIENTO SUGERIDO", M, y);
    y += 5;
    doc.setFont("helvetica", "normal");
    doc.setTextColor(...NEGRO);
    doc.setFontSize(9);
    doc.text(c.seguimiento, M, y);
    y += 8;
  }

  y = Math.max(y + 10, 230);
  doc.setDrawColor(...NEGRO);
  doc.setLineWidth(0.3);
  doc.line(M + 8, y, M + 78, y);
  doc.line(W - M - 78, y, W - M - 8, y);
  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  doc.text(c.firmaModo === "digital" ? "Firma del médico" : "Firma autógrafa y sello", M + 43, y + 5, { align: "center" });
  doc.text(c.nombreMed, M + 43, y + 9, { align: "center" });
  if (c.ced) doc.text(`Céd. ${c.ced}`, M + 43, y + 13, { align: "center" });
  doc.text("Sello del consultorio", W - M - 43, y + 5, { align: "center" });
  doc.text("FarmaCapital · Consultorio médico", W - M - 43, y + 9, { align: "center" });

  y += 20;
  doc.setFontSize(7);
  doc.setTextColor(148, 163, 184);
  const foot = doc.splitTextToSize(
    "Receta ordinaria. Antibióticos: sello de farmacia al surtir. Controlados grupo I: recetario oficial COFEPRIS. Presentar en mostrador FarmaCapital (planta baja).",
    W - M * 2
  );
  doc.text(foot, W / 2, y, { align: "center" });

  return doc;
}

export function openRecetaPrint(html) {
  if (typeof window === "undefined") return false;
  const win = window.open("", "_blank", "width=750,height=900,scrollbars=1,resizable=1");
  if (!win) {
    try {
      window.alert("No se pudo abrir la ventana de impresión. Permite ventanas emergentes para farmacapital.mx.");
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

/** Abre el PDF carta en una pestaña (imprimir / guardar). */
export function openRecetaPdf(opts = {}) {
  if (typeof window === "undefined") return false;
  const doc = buildRecetaPdf(opts);
  const blob = doc.output("blob");
  const url = URL.createObjectURL(blob);
  const win = window.open(url, "_blank");
  if (!win) {
    doc.save(`${opts.folio || "receta"}.pdf`);
    return true;
  }
  return true;
}

export function recetaOptsDesdeFila(receta, extra = {}) {
  if (!receta) return extra;
  return {
    folio: receta.folio,
    cita: {
      id: receta.cita_id,
      nombre: receta.paciente_nombre,
      telefono: receta.paciente_telefono,
      fecha: receta.created_at,
      hora: "",
      motivo: extra.motivo || "",
    },
    medico: {
      nombre: receta.medico_nombre,
      cedula: receta.medico_cedula,
      especialidad: receta.medico_especialidad,
      institucion: receta.medico_institucion,
    },
    medicamentos: receta.medicamentos,
    diagnostico: receta.diagnostico,
    notas: receta.notas,
    alergias: receta.alergias_snapshot,
    pacienteExtra: { edad: receta.paciente_edad, sexo: receta.paciente_sexo },
    firmaModo: receta.firma_modo,
    firmaDataUrl: receta.firma_data_url,
    seguimiento: extra.seguimiento || "",
    ...extra,
  };
}
