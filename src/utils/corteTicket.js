/** Ticket de corte de caja: misma hoja para Epson, PDF e historial. */

import { jsPDF } from "jspdf";

export const CORTES_BUCKET = "cortes";

const money = (n) => `$${parseFloat(n || 0).toFixed(2)}`;

export function snapshotFromCorte({ resultado, turno, zTransac, cajero }) {
  const sistema = parseFloat(resultado?.efectivo_sistema ?? 0);
  const fondo = parseFloat(resultado?.fondo_inicial ?? 0);
  const esperado = parseFloat(resultado?.esperado ?? fondo + sistema);
  const dif = parseFloat(resultado?.diferencia ?? 0);
  const declarado = parseFloat(
    resultado?.efectivo_declarado ?? esperado + dif
  );
  const ventas = (zTransac || []).map((t) => ({
    id: t.id,
    created_at: t.created_at,
    metodo_pago: t.metodo_pago || "—",
    total: parseFloat(t.total || 0),
  }));
  return {
    corte_id: resultado?.corte_id ?? resultado?.id ?? null,
    turno: turno || resultado?.turno || "",
    cajero: cajero || "",
    generado_at: new Date().toISOString(),
    fondo,
    sistema,
    esperado,
    declarado,
    diferencia: dif,
    tarjeta: parseFloat(resultado?.tarjeta ?? resultado?.total_tarjeta ?? 0),
    mercadopago: parseFloat(resultado?.mercadopago ?? resultado?.total_mercadopago ?? 0),
    spei: parseFloat(resultado?.spei ?? resultado?.total_spei ?? 0),
    total_general: parseFloat(resultado?.total_general ?? 0),
    ventas,
  };
}

export function snapshotFromHistorialRow(c) {
  return snapshotFromCorte({
    resultado: {
      id: c.id,
      corte_id: c.id,
      turno: c.turno,
      fondo_inicial: c.fondo_inicial,
      efectivo_sistema: c.efectivo_sistema,
      esperado: c.esperado,
      efectivo_declarado: c.efectivo_declarado,
      diferencia: c.diferencia,
      tarjeta: c.tarjeta,
      total_tarjeta: c.tarjeta,
      mercadopago: c.mercadopago,
      total_mercadopago: c.mercadopago,
      total_general: c.total_general,
    },
    turno: c.turno,
    zTransac: c.ventas || [],
    cajero: c.cajero,
  });
}

function horaLocal(iso) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" });
}

export function corteTicketHtml(snap) {
  const filas = (snap.ventas || [])
    .map(
      (t) => `
      <tr>
        <td>#${t.id}</td>
        <td>${horaLocal(t.created_at)}</td>
        <td>${t.metodo_pago || "—"}</td>
        <td class="r">${money(t.total)}</td>
      </tr>`
    )
    .join("");
  const sum = (snap.ventas || []).reduce((a, t) => a + parseFloat(t.total || 0), 0);
  const fecha = snap.generado_at
    ? new Date(snap.generado_at).toLocaleString("es-MX")
    : new Date().toLocaleString("es-MX");
  return `<!doctype html><html><head><meta charset="utf-8">
      <title>Corte ${snap.turno} — ${fecha}</title>
      <style>
        body{font-family:-apple-system,system-ui,sans-serif;font-size:12px;margin:24px;color:#111}
        h1{font-size:16px;margin:0 0 2px} .sub{color:#666;margin-bottom:16px}
        table{width:100%;border-collapse:collapse;margin-top:8px}
        th,td{text-align:left;padding:4px 6px;border-bottom:1px solid #ddd}
        th{font-size:10px;text-transform:uppercase;color:#666}
        .r{text-align:right} .tot{font-weight:700;border-top:2px solid #111}
        .box{border:1px solid #ccc;padding:10px 12px;margin-bottom:14px}
        .box div{display:flex;justify-content:space-between;padding:2px 0}
        .dif{font-weight:700;border-top:1px solid #ccc;margin-top:4px;padding-top:6px}
      </style></head><body>
      <h1>Corte de caja — turno ${snap.turno}</h1>
      <div class="sub">${fecha} · corte #${snap.corte_id ?? ""} ${snap.cajero ? `· ${snap.cajero}` : ""}</div>
      <div class="box">
        <div><span>Fondo inicial</span><span>${money(snap.fondo)}</span></div>
        <div><span>Ventas en efectivo (sistema)</span><span>${money(snap.sistema)}</span></div>
        <div><span>Esperado en cajón</span><span>${money(snap.esperado)}</span></div>
        <div><span>Contado</span><span>${money(snap.declarado)}</span></div>
        <div class="dif"><span>Diferencia</span><span>${money(snap.diferencia)}</span></div>
      </div>
      <div class="box">
        <div><span>Tarjeta (BBVA + Point)</span><span>${money(snap.tarjeta)}</span></div>
        <div><span>MercadoPago (tienda web)</span><span>${money(snap.mercadopago)}</span></div>
        ${snap.spei > 0 ? `<div><span>SPEI</span><span>${money(snap.spei)}</span></div>` : ""}
        <div class="dif"><span>Total del turno</span><span>${money(snap.total_general)}</span></div>
      </div>
      <h1 style="font-size:13px">Detalle de ventas del turno</h1>
      <table>
        <thead><tr><th>Folio</th><th>Hora</th><th>Método</th><th class="r">Total</th></tr></thead>
        <tbody>${filas || '<tr><td colspan="4">Sin ventas en el turno</td></tr>'}</tbody>
        <tfoot><tr class="tot"><td colspan="3">${(snap.ventas || []).length} venta(s)</td>
          <td class="r">${money(sum)}</td></tr></tfoot>
      </table>
      <p style="margin-top:24px">Contó: ____________________  Recibió: ____________________</p>
      </body></html>`;
}

export function printCorteTicket(snap) {
  const w = window.open("", "_blank", "width=720,height=800");
  if (!w) return false;
  w.document.write(corteTicketHtml(snap));
  w.document.close();
  w.focus();
  w.print();
  return true;
}

export function corteTicketPdfBlob(snap) {
  const ventas = snap.ventas || [];
  const lineH = 5.2;
  const h = Math.max(140, 92 + ventas.length * lineH);
  const doc = new jsPDF({ unit: "mm", format: [80, h] });
  const W = 80;
  const M = 5;
  let y = 8;
  const line = (label, value, bold) => {
    doc.setFont("helvetica", bold ? "bold" : "normal");
    doc.setFontSize(bold ? 9 : 8);
    doc.text(String(label), M, y);
    doc.text(String(value), W - M, y, { align: "right" });
    y += 4.2;
  };

  doc.setFont("helvetica", "bold");
  doc.setFontSize(11);
  doc.text("FarmaCapital", W / 2, y, { align: "center" });
  y += 5;
  doc.setFontSize(9);
  doc.text(`Corte ${snap.turno || ""}`.trim(), W / 2, y, { align: "center" });
  y += 4;
  doc.setFont("helvetica", "normal");
  doc.setFontSize(7);
  const when = snap.generado_at
    ? new Date(snap.generado_at).toLocaleString("es-MX")
    : new Date().toLocaleString("es-MX");
  doc.text(`#${snap.corte_id ?? "—"} · ${when}`, W / 2, y, { align: "center" });
  y += 3;
  if (snap.cajero) {
    doc.text(String(snap.cajero), W / 2, y, { align: "center" });
    y += 4;
  }
  y += 1;
  doc.setDrawColor(0);
  doc.line(M, y, W - M, y);
  y += 5;

  line("Fondo inicial", money(snap.fondo));
  line("Ef. sistema", money(snap.sistema));
  line("Esperado", money(snap.esperado));
  line("Contado", money(snap.declarado));
  line("Diferencia", money(snap.diferencia), true);
  y += 1;
  doc.line(M, y, W - M, y);
  y += 5;
  line("Tarjeta", money(snap.tarjeta));
  line("MercadoPago", money(snap.mercadopago));
  if (parseFloat(snap.spei || 0) > 0) line("SPEI", money(snap.spei));
  line("Total turno", money(snap.total_general), true);
  y += 2;
  doc.line(M, y, W - M, y);
  y += 5;
  doc.setFont("helvetica", "bold");
  doc.setFontSize(8);
  doc.text("Ventas del turno", M, y);
  y += 4.5;
  doc.setFont("helvetica", "normal");
  doc.setFontSize(7);
  if (!ventas.length) {
    doc.text("Sin ventas en el turno", M, y);
    y += 4;
  } else {
    ventas.forEach((t) => {
      if (y > h - 12) return;
      doc.text(`#${t.id} ${horaLocal(t.created_at)} ${t.metodo_pago || ""}`, M, y);
      doc.text(money(t.total), W - M, y, { align: "right" });
      y += lineH - 0.8;
    });
  }
  y += 3;
  doc.setFontSize(7);
  doc.text("Conto: __________  Recibio: __________", M, y);
  return doc.output("blob");
}

export function corteTicketFileName(corteId) {
  return `corte-${Number(corteId)}.pdf`;
}

export async function uploadCorteTicketPdf(corteId, blob, sessionToken) {
  const tok = String(sessionToken || "").trim();
  if (!tok) throw new Error("Sesión expirada");
  const resp = await fetch("/api/admin/storage-upload", {
    method: "POST",
    headers: {
      "Content-Type": "application/pdf",
      "X-Session-Token": tok,
      "X-Bucket": CORTES_BUCKET,
      "X-File-Name": corteTicketFileName(corteId),
      "X-Upsert": "true",
    },
    body: blob,
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    throw new Error(data?.message || data?.error || `Error ${resp.status}`);
  }
  return data.publicUrl;
}

export function getSupabasePublicUrl() {
  return String(
    process.env.REACT_APP_SUPABASE_URL || process.env.VITE_SUPABASE_URL || ""
  ).replace(/\/+$/, "");
}

export function corteTicketPublicUrl(corteId, supabaseUrl = getSupabasePublicUrl()) {
  const base = String(supabaseUrl || "").replace(/\/+$/, "");
  return `${base}/storage/v1/object/public/${CORTES_BUCKET}/${corteTicketFileName(corteId)}`;
}

export async function ticketPdfExiste(url) {
  try {
    const r = await fetch(url, { method: "GET", cache: "no-store" });
    return r.ok;
  } catch {
    return false;
  }
}

export async function abrirOCrearTicketCorte({ corte, sessionToken, fetchVentas }) {
  const id = corte?.id ?? corte?.corte_id;
  if (!id) throw new Error("Corte sin id");
  const existente = corteTicketPublicUrl(id);
  if (existente && (await ticketPdfExiste(existente))) {
    window.open(`${existente}?v=${Date.now()}`, "_blank", "noopener,noreferrer");
    return existente;
  }
  const ventas = fetchVentas ? await fetchVentas(corte) : corte.ventas || [];
  const snap = snapshotFromHistorialRow({ ...corte, ventas });
  const blob = corteTicketPdfBlob(snap);
  const publicUrl = await uploadCorteTicketPdf(id, blob, sessionToken);
  window.open(publicUrl, "_blank", "noopener,noreferrer");
  return publicUrl;
}
