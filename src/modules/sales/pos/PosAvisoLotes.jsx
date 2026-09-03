import React from "react";
import { avisoLotesAnaquel } from "../../../lib/posAvisoLotes";

function colores(aviso, C) {
  if (aviso.urgente) return { color: C.amber, bg: C.amberDim, border: `${C.amber}55` };
  return { color: C.blue, bg: C.blueDim, border: `${C.blue}35` };
}

/** Banner en la ficha: lista de caducidades y cuál tomar. */
export function PosAvisoLotesFicha({ producto, hoy, C }) {
  const aviso = avisoLotesAnaquel(producto, hoy);
  if (!aviso.mostrar) return null;
  const tone = colores(aviso, C);
  return (
    <div
      role="status"
      data-testid="pos-aviso-lotes-ficha"
      style={{
        background: tone.bg,
        border: `1px solid ${tone.border}`,
        borderRadius: 12,
        padding: "10px 12px",
      }}
    >
      <div style={{ fontSize: 10, fontWeight: 800, color: tone.color, letterSpacing: 0.5, textTransform: "uppercase", marginBottom: 4 }}>
        {aviso.multi ? "En anaquel · toma este primero" : "Caducidad"}
      </div>
      <div style={{ fontSize: 14, fontWeight: 850, color: C.text, lineHeight: 1.3 }}>
        {aviso.textoFichaTitulo}
      </div>
      {aviso.textoFichaOtros ? (
        <div style={{ fontSize: 12, fontWeight: 600, color: C.textMid, marginTop: 4, lineHeight: 1.35 }}>
          {aviso.textoFichaOtros}
        </div>
      ) : null}
    </div>
  );
}

/** Línea corta bajo el nombre en el carrito. */
export function PosAvisoLotesCarrito({ producto, hoy, C }) {
  const aviso = avisoLotesAnaquel(producto, hoy);
  if (!aviso.textoCarrito) return null;
  return (
    <div
      data-testid="pos-aviso-lotes-carrito"
      style={{ color: aviso.urgente ? C.amber : C.textMid, fontSize: 11, fontWeight: 700, marginTop: 2 }}
    >
      {aviso.textoCarrito}
    </div>
  );
}

/** Badge en tarjeta de búsqueda: solo si hay más de una fecha. */
export function PosAvisoLotesTarjeta({ producto, hoy, C }) {
  const aviso = avisoLotesAnaquel(producto, hoy);
  if (!aviso.multi || !aviso.textoCorto) return null;
  return (
    <div
      data-testid="pos-aviso-lotes-tarjeta"
      style={{
        padding: "5px 8px",
        borderRadius: 8,
        background: aviso.urgente ? C.amberDim : C.blueDim,
        color: aviso.urgente ? C.amber : C.blue,
        fontSize: 11,
        fontWeight: 800,
        lineHeight: 1.3,
      }}
    >
      {aviso.textoCorto}
    </div>
  );
}
