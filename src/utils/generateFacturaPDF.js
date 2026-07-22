// ═══════════════════════════════════════════════════════════
// FARMACAPITAL — Generador de Facturas CFDI PDF (A4 Portrait)
// Formato oficial SAT México
// Listo para integración con PAC (Facturama)
// ═══════════════════════════════════════════════════════════
import { jsPDF } from "jspdf";

/**
 * Genera factura PDF formato CFDI oficial SAT México
 */
export function generateFacturaPDF({
  venta = {}, productos = [], cliente = {},
  config = {}, metodoPago = "Efectivo"
}) {
  const doc = new jsPDF({ orientation:"portrait", unit:"mm", format:"a4" });

  const W  = 210;
  const M  = 14;
  const CW = W - M*2; // content width

  // ── Colores ──────────────────────────────────────────────
  const AZUL   = [0,  82, 204];
  const GRIS   = [71, 85, 105];
  const GRIS_L = [248,250,252];
  const NEGRO  = [15, 23, 42];
  const BLANCO = [255,255,255];
  const LINEA  = [200,200,200];

  // ── Helpers ───────────────────────────────────────────────
  const fmt   = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
  const line  = (y) => { doc.setDrawColor(...LINEA); doc.setLineWidth(0.3); doc.line(M, y, W-M, y); };
  const sep   = (y) => { doc.setDrawColor(...GRIS); doc.setLineWidth(0.5); doc.line(M, y, W-M, y); };

  const hoy     = new Date(venta.created_at || Date.now());
  const fechaStr= hoy.toLocaleDateString("es-MX",{day:"2-digit",month:"2-digit",year:"numeric"});
  const folio   = String(venta.id||"0").padStart(8,"0");
  const serie   = "A";
  const subtotal= parseFloat(venta.total||0);
  const ivaAmt  = 0; // IVA incluido en precio (RESICO)
  const total   = subtotal;

  let y = 14;

  // ══════════════════════════════════════════════════════════
  // HEADER — Logo + Datos Emisor
  // ══════════════════════════════════════════════════════════

  // Logo (marca oficial)
  doc.setFillColor(13, 27, 42);
  doc.roundedRect(M, y, 52, 16, 2, 2, "F");
  doc.setTextColor(255, 255, 255);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(11);
  doc.text("FarmaCapital", M + 26, y + 10, { align: "center" });

  // Datos emisor
  doc.setTextColor(...NEGRO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(11);
  doc.text(config.nombre_farmacia||"FarmaCapital", M+44, y+5);

  doc.setFont("helvetica","normal");
  doc.setFontSize(8);
  doc.setTextColor(...GRIS);
  doc.text(`RFC: ${config.rfc||"XAXX010101000"}`, M+44, y+10);
  doc.text(`Régimen: ${config.regimen_fiscal||"General de Ley Personas Morales"}`, M+44, y+15);
  doc.text(config.direccion_farmacia||"Chinampac de Juárez, Iztapalapa, CDMX", M+44, y+20);

  // FACTURA label (derecha)
  doc.setFillColor(...AZUL);
  doc.roundedRect(W-M-45, y, 45, 20, 3, 3, "F");
  doc.setTextColor(...BLANCO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(14);
  doc.text("FACTURA", W-M-22.5, y+9, {align:"center"});
  doc.setFontSize(8);
  doc.setFont("helvetica","normal");
  doc.text(`Serie: ${serie}  Folio: ${folio}`, W-M-22.5, y+15, {align:"center"});

  y += 28;
  sep(y); y += 4;

  // Fecha
  doc.setTextColor(...NEGRO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(9);
  doc.text(`Fecha de emisión: ${fechaStr}`, M, y);
  doc.text(`Lugar de expedición: CDMX`, W-M, y, {align:"right"});
  y += 8;
  sep(y); y += 6;

  // ══════════════════════════════════════════════════════════
  // DATOS DEL CLIENTE
  // ══════════════════════════════════════════════════════════

  // Sección emisor / receptor en 2 columnas
  const col1X = M;
  const col2X = M + CW/2 + 4;
  const colW  = CW/2 - 4;

  // Emisor
  doc.setFillColor(...GRIS_L);
  doc.rect(col1X, y, colW, 5, "F");
  doc.setFont("helvetica","bold");
  doc.setFontSize(8);
  doc.setTextColor(...AZUL);
  doc.text("EMISOR", col1X+2, y+3.5);

  y += 6;
  doc.setFont("helvetica","normal");
  doc.setTextColor(...NEGRO);
  doc.setFontSize(8);
  doc.text(`Nombre: ${config.nombre_farmacia||"FarmaCapital"}`, col1X, y);
  y += 4;
  doc.text(`RFC: ${config.rfc||"XAXX010101000"}`, col1X, y);
  y += 4;
  doc.text(`Régimen: ${config.regimen_fiscal||"601"}`, col1X, y);

  // Receptor
  const recY = y - 14;
  doc.setFillColor(...GRIS_L);
  doc.rect(col2X, recY, colW, 5, "F");
  doc.setFont("helvetica","bold");
  doc.setFontSize(8);
  doc.setTextColor(...AZUL);
  doc.text("RECEPTOR (CLIENTE)", col2X+2, recY+3.5);

  doc.setFont("helvetica","normal");
  doc.setTextColor(...NEGRO);
  doc.text(`Nombre: ${cliente.razon_social||cliente.nombre||"PUBLICO EN GENERAL"}`, col2X, recY+9);
  doc.text(`RFC: ${cliente.rfc||"XAXX010101000"}`, col2X, recY+13);
  doc.text(`Uso CFDI: ${cliente.uso_cfdi||"G03 — Gastos en general"}`, col2X, recY+17);
  if(cliente.email) doc.text(`Email: ${cliente.email}`, col2X, recY+21);

  y += 10;
  sep(y); y += 6;

  // ══════════════════════════════════════════════════════════
  // TABLA DE CONCEPTOS
  // ══════════════════════════════════════════════════════════

  // Header tabla
  doc.setFillColor(...AZUL);
  doc.rect(M, y, CW, 7, "F");
  doc.setTextColor(...BLANCO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(8);

  const c = { desc:M+2, clave:M+80, cant:M+100, unit:M+112, precio:M+135, iva:M+158, imp:W-M-2 };
  doc.text("Descripción", c.desc, y+4.5);
  doc.text("Clave SAT", c.clave, y+4.5);
  doc.text("Cant.", c.cant, y+4.5);
  doc.text("Unidad", c.unit, y+4.5);
  doc.text("P. Unit.", c.precio, y+4.5, {align:"right"});
  doc.text("IVA", c.iva, y+4.5, {align:"right"});
  doc.text("Importe", c.imp, y+4.5, {align:"right"});

  y += 7;

  // Filas
  doc.setFont("helvetica","normal");
  doc.setTextColor(...NEGRO);
  doc.setFontSize(8);

  let sumaSubtotal = 0;
  let sumaIva      = 0;

  productos.forEach((p, i) => {
    const nombre   = (p.nombre||"Producto").slice(0,35);
    const qty      = p.qty || p.cantidad || 1;
    const precio   = parseFloat(p.precio || p.precio_unitario || 0);
    const ivaItem  = precio * qty * 0.16;
    const importe  = precio * qty;
    sumaSubtotal  += importe;
    sumaIva       += ivaItem;

    const rowH = 8;
    if(i%2===0) { doc.setFillColor(250,250,252); doc.rect(M, y, CW, rowH, "F"); }

    doc.setTextColor(...NEGRO);
    doc.text(nombre, c.desc, y+5);
    doc.text("01010101", c.clave, y+5); // Clave SAT genérica
    doc.text(String(qty), c.cant, y+5);
    doc.text("PZA", c.unit, y+5);
    doc.text(`$${precio.toFixed(2)}`, c.precio, y+5, {align:"right"});
    doc.text(`$${ivaItem.toFixed(2)}`, c.iva, y+5, {align:"right"});
    doc.text(`$${importe.toFixed(2)}`, c.imp, y+5, {align:"right"});

    // Descripción adicional (2da línea si hay lote/rx)
    if(p.rxI) {
      doc.setFontSize(7);
      doc.setTextColor(...GRIS);
      doc.text(`Receta: ${p.rxI.receta||"—"} | Médico: ${p.rxI.medico||"—"}`, c.desc+2, y+rowH-1);
      doc.setFontSize(8);
      doc.setTextColor(...NEGRO);
    }

    line(y + rowH);
    y += rowH;
  });

  y += 4;
  sep(y); y += 4;

  // ══════════════════════════════════════════════════════════
  // TOTALES
  // ══════════════════════════════════════════════════════════

  const totX = W - M - 70;
  const totW = 70;

  const drawTotal = (label, valor, bold=false, bg=null) => {
    if(bg) { doc.setFillColor(...bg); doc.rect(totX, y, totW, 7, "F"); }
    doc.setFont("helvetica", bold?"bold":"normal");
    doc.setFontSize(bold?10:8);
    if(bold) doc.setTextColor(...BLANCO); else doc.setTextColor(...NEGRO);
    doc.text(label, totX+3, y+5);
    doc.text(fmt(valor), W-M-2, y+5, {align:"right"});
    y += 7;
  };

  drawTotal("Subtotal:", sumaSubtotal);
  drawTotal("IVA (16%):", sumaIva);
  drawTotal("Descuentos:", 0);
  sep(y-3);
  drawTotal("TOTAL:", total, true, AZUL);

  y += 6;

  // Método de pago
  doc.setFont("helvetica","normal");
  doc.setFontSize(8);
  doc.setTextColor(...NEGRO);
  doc.text(`Método de pago: ${metodoPago}`, M, y);
  doc.text("Moneda: MXN", M+60, y);
  doc.text("Condiciones: Contado", M+90, y);

  y += 10;
  sep(y); y += 6;

  // ══════════════════════════════════════════════════════════
  // QR SAT + SELLO DIGITAL
  // ══════════════════════════════════════════════════════════

  doc.setFillColor(...GRIS_L);
  doc.rect(M, y, CW, 40, "F");

  // QR placeholder
  doc.setDrawColor(...AZUL);
  doc.setLineWidth(0.5);
  doc.rect(M+4, y+4, 32, 32, "S");
  doc.setTextColor(...GRIS);
  doc.setFontSize(7);
  doc.text("QR SAT", M+20, y+17, {align:"center"});
  doc.text("[QR CODE", M+20, y+21, {align:"center"});
  doc.text("CFDI]", M+20, y+25, {align:"center"});

  // Info CFDI
  doc.setTextColor(...NEGRO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(7.5);
  doc.text("Sello Digital del CFDI:", M+40, y+7);
  doc.setFont("helvetica","normal");
  doc.setFontSize(6.5);
  doc.text("(Pendiente de timbrado con PAC autorizado SAT)", M+40, y+11);

  doc.setFont("helvetica","bold");
  doc.text("No. de Serie del Certificado del SAT:", M+40, y+17);
  doc.setFont("helvetica","normal");
  doc.text("(Se generará al activar Facturama)", M+40, y+21);

  doc.setFont("helvetica","bold");
  doc.text("Folio Fiscal UUID:", M+40, y+27);
  doc.setFont("helvetica","normal");
  doc.text("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", M+40, y+31);

  doc.setFont("helvetica","bold");
  doc.text("Fecha y hora de certificación:", M+40, y+37);
  doc.setFont("helvetica","normal");
  doc.text(`${fechaStr} — Pendiente`, M+40, y+41);

  y += 48;

  // ══════════════════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════════════════

  doc.setFillColor(...AZUL);
  doc.rect(0, 272, W, 25, "F");
  doc.setTextColor(...BLANCO);
  doc.setFont("helvetica","bold");
  doc.setFontSize(10);
  doc.text("¡Gracias por su preferencia!", W/2, 281, {align:"center"});
  doc.setFont("helvetica","normal");
  doc.setFontSize(7.5);
  doc.text(`${config.nombre_farmacia||"FarmaCapital"} — ${config.direccion_farmacia||"Chinampac de Juárez, CDMX"}`, W/2, 287, {align:"center"});
  doc.text("Este documento es una representación impresa de un CFDI (pendiente de timbrado)", W/2, 292, {align:"center"});

  return doc;
}

export function downloadFacturaPDF(opts) {
  const doc = generateFacturaPDF(opts);
  const folio = String(opts.venta?.id||"0").padStart(8,"0");
  doc.save(`Factura_CFDI_FarmaCapital_${folio}_${new Date().toISOString().slice(0,10)}.pdf`);
}

export function printFacturaPDF(opts) {
  const doc  = generateFacturaPDF(opts);
  const blob = doc.output("blob");
  const url  = URL.createObjectURL(blob);
  const win  = window.open(url,"_blank");
  if(win) setTimeout(()=>win.print(), 1000);
}
