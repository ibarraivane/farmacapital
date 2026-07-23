// FARMACAPITAL — Utilidad de impresión de tickets

import { mergeFarmaciaConfig } from "../constants/farmaciaFiscal";

const TICKET_CSS = `
* { box-sizing: border-box; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
html, body { margin: 0; padding: 0; background: #fff; }
@page { size: 80mm auto; margin: 0; }

#farmacapital-ticket {
  font-family: 'Courier New', Courier, monospace;
  font-size: 11px;
  line-height: 1.45;
  width: 280px;
  max-width: 280px;
  background: #ffffff;
  color: #000000;
  padding: 10px 8px;
  margin: 0;
  box-sizing: border-box;
}
#farmacapital-ticket * {
  font-family: 'Courier New', Courier, monospace;
  -webkit-print-color-adjust: exact !important;
  print-color-adjust: exact !important;
}
.ticket { width: 280px; font-family: 'Courier New', Courier, monospace; font-size: 11px; line-height: 1.4; background: #fff; color: #000; padding: 8px 6px; }
.center { text-align: center; }
.left   { text-align: left; }
.right  { text-align: right; }
.separator { border: none; border-top: 1px dashed #000; margin: 5px 0; display: block; }
.separator-solid { border: none; border-top: 2px solid #000; margin: 5px 0; display: block; }
.product-row { display: flex; justify-content: space-between; font-size: 10px; padding: 2px 0; }
.product-name  { width: 60%; word-break: break-word; }
.product-total { width: 40%; text-align: right; font-weight: bold; }
.total-line { display: flex; justify-content: space-between; font-weight: bold; font-size: 11px; padding: 2px 0; }
.qr-section { text-align: center; margin-top: 10px; }
.footer { text-align: center; margin-top: 8px; font-size: 9px; color: #333; }
.ticket-puntos { background: #000 !important; color: #fff !important; text-align: center; padding: 5px 4px; font-size: 10px; font-weight: 900; margin: 6px 0; letter-spacing: 1px; }
.ticket-logo-wrap { text-align: center; margin-bottom: 4px; }
.ticket-logo-icon {
  height: 32px;
  width: 32px;
  max-width: 32px;
  max-height: 32px;
  display: block;
  margin: 0 auto 4px;
  object-fit: contain;
}
.ticket-logo-img {
  height: 26px;
  width: auto;
  max-width: 200px;
  max-height: 26px;
  display: block;
  margin: 0 auto 4px;
  object-fit: contain;
}
.ticket-brand-name {
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 2px;
  text-transform: uppercase;
  line-height: 1.2;
}
.ticket-brand-slogan {
  font-size: 9px;
  margin-top: 2px;
  color: #333;
}
`;

/**
 * Abre una ventana popup con el ticket y lanza el diálogo de impresión.
 * Compatible con impresoras térmicas Epson TM-T20III/IV.
 * @param {string} ticketId - ID del elemento DOM del ticket
 */
export function printTicket(ticketId = "farmacapital-ticket") {
  const ticket = document.getElementById(ticketId);
  if (!ticket) {
    console.error("[FarmaCapital] Ticket no encontrado:", ticketId);
    return;
  }

  // Clonar el nodo para capturar SVG y estilos inline actuales
  const clone = ticket.cloneNode(true);

  // Copiar el SVG del QR inline (canvas/SVG no sobreviven cloneNode solo)
  const srcSvgs = ticket.querySelectorAll("svg");
  const dstSvgs = clone.querySelectorAll("svg");
  srcSvgs.forEach((src, i) => {
    if (dstSvgs[i]) {
      const fresh = src.cloneNode(true);
      dstSvgs[i].replaceWith(fresh);
    }
  });

  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Ticket FarmaCapital</title>
  <style>${TICKET_CSS}</style>
</head>
<body>
${clone.outerHTML}
</body>
</html>`;

  const win = window.open("", "_blank", "width=320,height=700,toolbar=0,menubar=0,scrollbars=1,resizable=1");
  if (!win) {
    alert(
      "🖨️ Permite ventanas emergentes para imprimir el ticket.\n" +
      "En Chrome: ícono 🚫 en la barra de dirección → Permitir ventanas emergentes."
    );
    return;
  }

  win.document.open();
  win.document.write(html);
  win.document.close();

  // Imprimir después de que el DOM termine de renderizar
  const tryPrint = () => {
    try {
      win.focus();
      win.print();
      // Cerrar después de que el usuario confirme/cancele la impresión
      setTimeout(() => { if (!win.closed) win.close(); }, 3000);
    } catch (e) {
      console.error("[FarmaCapital] Error al imprimir:", e);
    }
  };

  // Esperar carga completa, o usar fallback a los 800ms
  let printed = false;
  win.addEventListener("load", () => {
    if (printed) return;
    printed = true;
    setTimeout(tryPrint, 300);
  });
  setTimeout(() => {
    if (!printed && !win.closed) {
      printed = true;
      tryPrint();
    }
  }, 800);
}

/**
 * Genera HTML completo del ticket a partir de datos estructurados.
 * Útil para impresión sin componente React montado.
 */
export function generateTicketHTML(data) {
  const { venta, productos, cliente, metodoPago, config } = data;
  const fecha = new Date(venta.created_at || Date.now());
  const fechaStr = fecha.toLocaleDateString("es-MX", { day:"2-digit", month:"2-digit", year:"numeric" });
  const horaStr  = fecha.toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit" });
  const folio = venta.folio || `VTA-${String(venta.id || "0").padStart(8, "0")}`;
  const total = parseFloat(venta.total || 0);
  const fmt = n => `$${parseFloat(n || 0).toFixed(2)}`;

  const cfg = mergeFarmaciaConfig(config || {});

  const rows = (productos || []).map(p => `
    <div style="margin-bottom:3px">
      <div style="font-size:10px;font-weight:bold">${(p.nombre||"Producto").slice(0,22)}</div>
      <div style="display:flex;justify-content:space-between;font-size:10px">
        <span>${p.qty||p.cantidad||1} x ${fmt(p.precio||p.precio_unitario||0)}</span>
        <span style="font-weight:bold">${fmt((p.precio||p.precio_unitario||0)*(p.qty||p.cantidad||1))}</span>
      </div>
    </div>`).join("");

  const iconSrc = `${process.env.PUBLIC_URL || ""}/brand/farmacapital-icon.png?v=6`;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Ticket FarmaCapital</title>
  <style>${TICKET_CSS}</style>
</head>
<body>
<div id="farmacapital-ticket" class="ticket">
  <div class="center ticket-logo-wrap">
    <img src="${iconSrc}" alt="" class="ticket-logo-icon" aria-hidden="true"/>
    <div class="ticket-brand-name">FarmaCapital</div>
    <div class="ticket-brand-slogan">"Tu salud primero"</div>
  </div>
  <hr class="separator">
  <div style="font-size:9px;line-height:1.6">
    <div>Sucursal: ${cfg.nombre_farmacia}</div>
    <div>Dirección: ${cfg.direccion_farmacia}</div>
    <div>RFC: ${cfg.rfc}</div>
    ${cfg.telefono_farmacia?`<div>Tel: ${cfg.telefono_farmacia_display||cfg.telefono_farmacia}</div>`:""}
  </div>
  <hr class="separator">
  <div style="font-size:9px;line-height:1.7">
    <div>Fecha:  ${fechaStr}</div>
    <div>Hora:   ${horaStr}</div>
    <div>Folio:  #${folio}</div>
    ${cliente?`<div>Cliente: ${cliente.nombre||"—"}</div>`:""}
  </div>
  <hr class="separator">
  ${rows}
  <hr class="separator">
  <div style="display:flex;justify-content:space-between;font-size:10px;padding:1px 0">
    <span>Subtotal:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div style="display:flex;justify-content:space-between;font-size:14px;font-weight:900;padding:3px 0">
    <span>TOTAL:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div style="font-size:10px">Método: ${metodoPago||"Efectivo"}</div>
  <hr class="separator">
  <div class="footer">
    <div style="font-weight:bold;font-size:11px;letter-spacing:1px">Gracias por su compra</div>
    <div>¡Vuelva pronto!</div>
    <div style="margin-top:3px;font-size:8px;color:#555">farmacapital.mx</div>
  </div>
</div>
</body>
</html>`;
}

/** Abre ventana popup e imprime HTML generado programáticamente. */
export function printTicketWindow(data) {
  const html = generateTicketHTML(data);
  const win = window.open("", "_blank", "width=320,height=600,toolbar=0,menubar=0");
  if (!win) { alert("Por favor permite las ventanas emergentes para imprimir."); return; }
  win.document.open();
  win.document.write(html);
  win.document.close();
  setTimeout(() => { win.focus(); win.print(); }, 800);
}
