// FARMACAPITAL — Utilidad de impresión de tickets

/**
 * Imprime el contenido del ticket usando window.print()
 * Compatible con impresoras térmicas 80mm (Epson TM-T20III, etc.)
 * @param {string} ticketId - ID del elemento DOM del ticket
 */
export function printTicket(ticketId = "farmacapital-ticket") {
  const ticket = document.getElementById(ticketId);
  if (!ticket) {
    console.error("[FarmaCapital] Ticket no encontrado:", ticketId);
    return;
  }

  // Clonar el ticket para capturar SVG del QR renderizado
  const clone = ticket.cloneNode(true);

  // Copiar SVG inline (canvas/SVG del QR no se clona bien con solo innerHTML)
  const srcSvgs = ticket.querySelectorAll("svg");
  const dstSvgs = clone.querySelectorAll("svg");
  srcSvgs.forEach((src, i) => {
    if (dstSvgs[i]) dstSvgs[i].outerHTML = src.outerHTML;
  });

  // Obtener las hojas de estilo del documento actual para incluirlas en el popup
  const styles = Array.from(document.styleSheets)
    .map(sheet => {
      try {
        return Array.from(sheet.cssRules || []).map(r => r.cssText).join("\n");
      } catch { return ""; }
    })
    .join("\n");

  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Ticket FarmaCapital</title>
  <style>
    * { box-sizing: border-box; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    html, body { margin: 0; padding: 0; background: #fff; }
    body { font-family: 'Courier New', Courier, monospace; }
    @page { size: 80mm auto; margin: 2mm 1mm; }
    ${styles}
    /* Asegurar negro puro en impresión térmica */
    #farmacapital-ticket { background: #fff !important; color: #000 !important; }
    .ticket-puntos { background: #000 !important; color: #fff !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  </style>
</head>
<body>
  ${clone.outerHTML}
</body>
</html>`;

  const win = window.open("", "_blank", "width=340,height=700,toolbar=0,menubar=0,scrollbars=1");
  if (!win) {
    // Popup bloqueado — fallback a window.print() con aviso
    alert("Permite ventanas emergentes para imprimir tickets.\nEn Chrome: icono 🚫 en la barra de dirección → Permitir.");
    return;
  }
  win.document.open();
  win.document.write(html);
  win.document.close();
  // Esperar a que carguen imágenes y SVG, luego imprimir
  win.addEventListener("load", () => {
    setTimeout(() => {
      win.focus();
      win.print();
      setTimeout(() => win.close(), 1200);
    }, 350);
  });
  // Fallback si load no dispara (Chrome a veces no lo hace en popups)
  setTimeout(() => {
    if (!win.closed) {
      win.focus();
      win.print();
      setTimeout(() => win.close(), 1200);
    }
  }, 900);
}

/**
 * Genera el HTML del ticket para impresión directa
 * Compatible con futura implementación ESC/POS
 * @param {Object} data - Datos de la venta
 */
export function generateTicketHTML(data) {
  const { venta, productos, cliente, metodoPago, config } = data;
  const fecha = new Date(venta.created_at || Date.now());
  const fechaStr = fecha.toLocaleDateString("es-MX", { day:"2-digit", month:"2-digit", year:"numeric" });
  const horaStr  = fecha.toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit" });

  const rows = productos.map(p => `
    <tr>
      <td class="col-prod">${p.nombre?.slice(0,20)||"Producto"}</td>
      <td class="col-cant">${p.qty||p.cantidad||1}</td>
      <td class="col-precio">$${parseFloat(p.precio||p.precio_unitario||0).toFixed(2)}</td>
      <td class="col-total">$${(parseFloat(p.precio||p.precio_unitario||0)*(p.qty||p.cantidad||1)).toFixed(2)}</td>
    </tr>
  `).join("");

  const subtotal = parseFloat(venta.total||0);
  const iva = subtotal * 0.16;
  const total = subtotal;

  return `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Ticket FarmaCapital</title>
      <style>
        body { font-family: 'Courier New', monospace; font-size: 11px; width: 280px; margin: 0; padding: 8px; }
        .center { text-align: center; }
        .right { text-align: right; }
        .bold { font-weight: bold; }
        .big { font-size: 14px; }
        hr { border: none; border-top: 1px dashed #000; margin: 6px 0; }
        table { width: 100%; font-size: 10px; border-collapse: collapse; }
        th { font-size: 9px; text-transform: uppercase; border-bottom: 1px dashed #000; }
        .total-row { display: flex; justify-content: space-between; }
        .total-final { font-size: 14px; font-weight: 900; }
        @page { size: 80mm auto; margin: 0; }
      </style>
    </head>
    <body>
      <div class="center bold" style="font-size:16px">FARMACAPITAL</div>
      <div class="center">Farmacia & Salud</div>
      <div class="center" style="font-size:9px">Chinampac de Juárez, Iztapalapa, CDMX</div>
      <div class="center" style="font-size:9px">Tel: ${config?.telefono_farmacia||"—"}</div>
      <hr>
      <div>Fecha: ${fechaStr}  Hora: ${horaStr}</div>
      <div>Folio: #${venta.id||"—"}</div>
      ${cliente ? `<div>Cliente: ${cliente.nombre||"—"}</div>` : ""}
      <hr>
      <table>
        <thead><tr><th>Producto</th><th>Cant</th><th>Precio</th><th>Total</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
      <hr>
      <div class="total-row"><span>Subtotal:</span><span>$${subtotal.toFixed(2)}</span></div>
      <div class="total-row"><span>IVA (16%):</span><span>$${iva.toFixed(2)}</span></div>
      <hr>
      <div class="total-row total-final"><span>TOTAL:</span><span>$${total.toFixed(2)}</span></div>
      <hr>
      <div>Método de pago: ${metodoPago||"Efectivo"}</div>
      ${cliente?.puntos ? `<div class="center bold" style="background:#000;color:#fff;padding:4px;margin:4px 0">⭐ +${Math.floor(total/10)} puntos ganados</div>` : ""}
      <hr>
      <div class="center" style="font-size:9px">¡Gracias por su preferencia!</div>
      <div class="center" style="font-size:9px">Vuelva pronto a FarmaCapital</div>
      <div style="width:80px;height:80px;border:1px dashed #999;margin:8px auto;display:flex;align-items:center;justify-content:center;font-size:8px;color:#999">QR Code</div>
      <div class="center" style="font-size:8px">farmacapital.mx</div>
    </body>
    </html>
  `;
}

/**
 * Abre ventana de impresión con el ticket generado
 * @param {Object} data - Datos de la venta
 */
export function printTicketWindow(data) {
  const html = generateTicketHTML(data);
  const win = window.open("", "_blank", "width=320,height=600,toolbar=0,menubar=0");
  if (!win) { alert("Por favor permite las ventanas emergentes para imprimir."); return; }
  win.document.write(html);
  win.document.close();
  win.focus();
  setTimeout(() => { win.print(); }, 800);
}
