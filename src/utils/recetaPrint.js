/**
 * Receta médica del consultorio FarmaCapital.
 * Marca de consultorio (no ticket de farmacia). Impresión carta + cola a caja.
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

function folioFromCita(citaId) {
  const n = Number(citaId);
  if (Number.isFinite(n) && n > 0) return `RX-${n}`;
  return `RX-${Date.now()}`;
}

function fechaLarga(isoOrDate) {
  const d = isoOrDate ? new Date(isoOrDate) : new Date();
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

/**
 * @param {object} opts
 * @param {object} opts.cita
 * @param {string} [opts.diagnostico]
 * @param {string} [opts.notas]
 * @param {Array} [opts.medicamentos]
 * @param {{ nombre?: string, especialidad?: string, cedula?: string }} [opts.medico]
 * @param {'fisica'|'digital'} [opts.firmaModo]
 * @param {string|null} [opts.firmaDataUrl] data URL PNG si firma digital
 * @param {string} [opts.folio]
 */
export function buildRecetaHtml(opts = {}) {
  const cita = opts.cita || {};
  const medico = opts.medico || {};
  const meds = Array.isArray(opts.medicamentos) ? opts.medicamentos : [];
  const firmaModo = opts.firmaModo === "digital" ? "digital" : "fisica";
  const folio = opts.folio || folioFromCita(cita.id);
  const nombreMed = String(medico.nombre || "").trim() || "Médico(a) en turno";
  const esp = String(medico.especialidad || "").trim() || "Medicina general";
  const ced = String(medico.cedula || "").trim();
  const dx = String(opts.diagnostico || "").trim();
  const notas = String(opts.notas || "").trim();

  const medsHTML = meds
    .filter((m) => String(m.medicamento || m.nombre || "").trim())
    .map((m) => {
      const nom = esc(m.medicamento || m.nombre);
      const cant = Math.max(1, Number(m.cantidad) || 1);
      const dosis = esc(m.dosis || "—");
      const ind = esc(m.indicaciones || "—");
      return `<tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;font-weight:600">${nom}${cant > 1 ? ` <span style="color:#64748b;font-weight:500">×${cant}</span>` : ""}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${dosis}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${ind}</td>
      </tr>`;
    })
    .join("");

  const firmaBlock =
    firmaModo === "digital" && opts.firmaDataUrl
      ? `<div class="firma-box">
          <img src="${esc(opts.firmaDataUrl)}" alt="Firma" style="max-height:72px;max-width:220px;display:block;margin:0 auto 6px"/>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma del médico<br/><strong>${esc(nombreMed)}</strong></div>
        </div>`
      : `<div class="firma-box">
          <div style="height:56px"></div>
          <div style="border-top:1px solid #0f172a;padding-top:8px">Firma y sello del médico<br/><strong>${esc(nombreMed)}</strong></div>
        </div>`;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <title>Receta médica — ${esc(folio)}</title>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { font-family: Georgia, "Times New Roman", serif; font-size: 13px; color: #0f172a; padding: 28px; max-width: 720px; margin: 0 auto; background:#fff; }
    .sans { font-family: Arial, Helvetica, sans-serif; }
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
      <div>Chinampac de Juárez, Iztapalapa</div>
      <div>${esc(FARMACIA_FISCAL.direccion_comercial)}</div>
      <div style="margin-top:6px"><strong>Fecha:</strong> ${esc(fechaLarga(cita.fecha || undefined))}</div>
      <div><strong>Folio:</strong> ${esc(folio)}</div>
    </div>
  </div>

  <div class="medico">
    <h3>Médico tratante</h3>
    <div style="font-weight:700;font-size:15px">${esc(nombreMed)}</div>
    <div style="color:#475569;font-size:12px;margin-top:4px">${esc(esp)}${ced ? ` · Cédula profesional: ${esc(ced)}` : " · Cédula profesional: __________________"}</div>
  </div>

  <div class="paciente">
    <div class="field"><label>Paciente</label><p>${esc(cita.nombre || "—")}</p></div>
    <div class="field"><label>Teléfono</label><p>${esc(cita.telefono || "—")}</p></div>
    <div class="field"><label>Fecha consulta</label><p>${esc(cita.fecha || "—")}</p></div>
    <div class="field"><label>Hora</label><p>${esc(horaVista(cita.hora))}</p></div>
    <div class="field" style="grid-column:1/-1"><label>Motivo de consulta</label><p>${esc(cita.motivo || "Consulta general")}</p></div>
  </div>

  <div class="dx">
    <h4>Diagnóstico</h4>
    <p style="line-height:1.6">${esc(dx || "—")}</p>
  </div>

  ${medsHTML ? `
  <h4>Medicamentos prescritos</h4>
  <table>
    <thead><tr><th>Medicamento</th><th>Dosis</th><th>Indicaciones</th></tr></thead>
    <tbody>${medsHTML}</tbody>
  </table>` : ""}

  ${notas ? `
  <div class="notas">
    <h4>Indicaciones / notas</h4>
    <p style="line-height:1.6;margin-top:8px">${esc(notas)}</p>
  </div>` : ""}

  <div class="firma">
    ${firmaBlock}
    <div class="firma-box">
      <div style="height:56px"></div>
      <div style="border-top:1px solid #0f172a;padding-top:8px">Sello del consultorio<br/><strong>FarmaCapital · Consultorio</strong></div>
    </div>
  </div>

  <div class="footer">
    Receta del consultorio médico FarmaCapital. Presentar en mostrador para surtir.<br/>
    ${esc(FARMACIA_FISCAL.direccion_comercial)} · ${esc(FARMACIA_FISCAL.sitio_web)}
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

export function stockBadgeLabel(stock) {
  const n = Number(stock);
  if (!Number.isFinite(n)) return { label: "?", tone: "mid" };
  if (n <= 0) return { label: "Sin stock", tone: "red" };
  if (n <= 3) return { label: `Bajo (${n})`, tone: "amber" };
  return { label: `Stock ${n}`, tone: "green" };
}

export { folioFromCita };
