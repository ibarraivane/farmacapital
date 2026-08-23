import React, { forwardRef } from "react";
import { QRCodeSVG } from "qrcode.react";
import { BRAND_LOGO } from "../../brand";
import { mergeFarmaciaConfig } from "../../constants/farmaciaFiscal";
import "../../styles/ticket.css";

/**
 * FARMACAPITAL — TicketVenta (Componente oficial)
 * Ticket térmico 80mm compatible Epson TM-T20III
 *
 * Props:
 * @param {Object} venta      - {id, total, created_at, metodo_pago}
 * @param {Array}  productos  - [{nombre, qty, precio, rxI}]
 * @param {Object} cliente    - {nombre, telefono, puntos}
 * @param {string} metodoPago - "Efectivo" | "Tarjeta" | etc
 * @param {Object} config     - {nombre_farmacia, direccion_farmacia, rfc, telefono_farmacia}
 * @param {string} promoMsg   - Mensaje promocional opcional
 * @param {string} ticketUrl  - URL pública /r/{token} para QR (mismo enlace que WhatsApp)
 */
const TicketVenta = forwardRef(({
  venta      = {},
  productos  = [],
  cliente    = null,
  metodoPago = "Efectivo",
  config     = {},
  promoMsg   = null,
  ticketUrl  = null,
}, ref) => {
  const cfg = mergeFarmaciaConfig(config);

  // ── Datos calculados ────────────────────────────────────
  const fecha    = new Date(venta.created_at || Date.now());
  const fechaStr = fecha.toLocaleDateString("es-MX", { day:"2-digit", month:"2-digit", year:"numeric" });
  const horaStr  = fecha.toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit", second:"2-digit" });
  const folio    = venta.folio || `VTA-${String(venta.id || "0").padStart(8, "0")}`;
  const total    = parseFloat(venta.total || 0);
  // IVA incluido en precio mexicano: IVA = total * 0.16/1.16
  const iva      = venta.iva !== undefined
    ? parseFloat(venta.iva)
    : parseFloat((total * 0.16 / 1.16).toFixed(2));
  const subtotal = venta.neto !== undefined
    ? parseFloat(venta.neto)
    : parseFloat((total - iva).toFixed(2));
  const ptsG     = Math.floor(total / 10);
  const fmt      = n => `$${parseFloat(n||0).toFixed(2)}`;

  // QR: URL digital del ticket (WhatsApp e impreso) o fallback legado sin pedido en servidor
  const qrData = ticketUrl || `FARMACAPITAL|${folio}|${total.toFixed(2)}|${fechaStr}`;
  const qrLabel = ticketUrl
    ? ticketUrl.replace(/^https?:\/\//, "")
    : qrData;

  return (
    <div id="farmacapital-ticket" ref={ref} className="ticket">

      {/* ══ HEADER ══ */}
      <div className="center ticket-logo-wrap">
        <img src={BRAND_LOGO.icon} alt="" className="ticket-logo-icon" aria-hidden="true" />
        <div className="ticket-brand-name">FarmaCapital</div>
        <div className="ticket-brand-slogan">"Tu salud primero"</div>
      </div>

      <div className="separator"/>

      {/* ══ DATOS FARMACIA ══ */}
      <div className="ticket-block">
        <div>Sucursal: {cfg.nombre_farmacia}</div>
        <div>Dirección: {cfg.direccion_farmacia}</div>
        <div>RFC: {cfg.rfc}</div>
        {cfg.telefono_farmacia && <div>Tel: {cfg.telefono_farmacia_display || cfg.telefono_farmacia}</div>}
      </div>

      <div className="separator"/>

      {/* ══ DATOS DE LA VENTA ══ */}
      <div className="ticket-block">
        <div>Fecha:  {fechaStr}</div>
        <div>Hora:   {horaStr}</div>
        <div>Folio:  #{folio}</div>
        {cliente&&<div>Cliente: {cliente.nombre||"—"}</div>}
      </div>

      <div className="separator"/>

      {/* ══ PRODUCTOS ══ */}
      {productos.map((p, i) => {
        const nombre = (p.nombre||"Producto").slice(0,22);
        const qty    = p.qty || p.cantidad || 1;
        const precio = parseFloat(p.precio || p.precio_unitario || 0);
        const ptotal = precio * qty;
        return (
          <div key={i} style={{marginBottom:4}}>
            <div className="product-name ticket-product-name">
              {nombre}
              {p.rxI&&<span className="ticket-rx">Rx</span>}
              {p.esUnidad&&<span> (unit)</span>}
              {p.lote&&<div className="ticket-lote">Lote: {p.lote}{p.caducidad?` | Cad: ${p.caducidad}`:""}</div>}
            </div>
            <div className="product-row">
              <div>{qty} x {fmt(precio)}</div>
              <div className="product-total">{fmt(ptotal)}</div>
            </div>
          </div>
        );
      })}

      <div className="separator"/>

      {/* ══ TOTALES ══ */}
      <div className="total-line">
        <div>Subtotal:</div>
        <div>{fmt(subtotal)}</div>
      </div>
      <div className="total-line">
        <div>IVA (16%):</div>
        <div>{fmt(iva)}</div>
      </div>
      <div className="total-line ticket-total-final">
        <div>TOTAL:</div>
        <div>{fmt(total)}</div>
      </div>

      <div className="separator"/>

      {/* ══ MÉTODO DE PAGO ══ */}
      <div className="ticket-block">Método: {metodoPago}</div>
      {metodoPago === "Efectivo" && venta.recibido != null && (
        <div className="ticket-block" style={{marginTop:4}}>
          <div>Recibido: {fmt(venta.recibido)}</div>
          <div>Cambio: {fmt(venta.cambio)}</div>
          {venta.cambioDesglose && (
            <div style={{marginTop:2}}>Entregar: {venta.cambioDesglose}</div>
          )}
        </div>
      )}

      {/* ══ PUNTOS FARMACAPITAL ══ */}
      {ptsG > 0 && (
        <div className="ticket-puntos">
          ★ +{ptsG} PUNTOS FARMACAPITAL GANADOS
          {cliente&&<div>Saldo: {(cliente.puntos||0)+ptsG} pts = ${(((cliente.puntos||0)+ptsG)*0.5).toFixed(0)}</div>}
        </div>
      )}

      {/* ══ PROMO MSG ══ */}
      {promoMsg&&(
        <div className="ticket-promo">
          {promoMsg}
        </div>
      )}

      <div className="separator"/>

      {/* ══ QR CODE ══ */}
      <div className="qr-section">
        <QRCodeSVG value={qrData} size={80} bgColor="#fff" fgColor="#000" level="M"/>
        <div className="ticket-qr-caption">
          {ticketUrl ? (
            <>
              Escanea para abrir tu ticket digital
              <br/>
              {qrLabel}
            </>
          ) : (
            <>
              Escanea para verificar tu compra
              <br/>
              {qrLabel}
            </>
          )}
        </div>
      </div>

      {/* ══ FOOTER ══ */}
      <div className="footer">
        <div className="ticket-gracias">Gracias por su compra</div>
        <div>¡Vuelva pronto!</div>
        <div className="ticket-web">farmacapital.mx</div>
      </div>

    </div>
  );
});

TicketVenta.displayName = "TicketVenta";
export default TicketVenta;
