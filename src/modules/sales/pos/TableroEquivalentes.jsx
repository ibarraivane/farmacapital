import React from "react";
import { C_LIGHT } from "../../../constants";
import { $ } from "../../../utils";
import { posSubtituloProducto } from "../../../utils/posProductDisplay";

/**
 * Todas las opciones del mismo principio activo, de un vistazo.
 *
 * Una tarjeta por marca; adentro, sus presentaciones como cajitas. La patente
 * va primero: en la lista normal siempre caía al final porque la marca no se
 * llama como la sustancia que teclea la vendedora.
 */

/** Segunda línea de la cajita: lo que distingue una presentación de otra. */
function etiquetaPresentacion(producto) {
  const partes = [producto?.concentracion, producto?.presentacion, producto?.forma_farmaceutica]
    .map((x) => String(x || "").trim())
    .filter(Boolean);
  if (partes.length) return partes.join(" · ");
  return posSubtituloProducto(producto) || producto?.sku || "";
}

/** Sin foto: la marca en grande. Se lee y se distingue aunque falte el packshot. */
function Portada({ foto, marca, alto }) {
  const C = C_LIGHT;
  if (foto) {
    return (
      <div style={{ height: alto, borderRadius: 8, overflow: "hidden", background: "#fff", border: `1px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <img src={foto} alt="" style={{ maxWidth: "100%", maxHeight: "100%", objectFit: "contain" }} />
      </div>
    );
  }
  return (
    <div style={{ height: alto, borderRadius: 8, background: C.amberDim, border: `1px solid ${C.border}`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 4, padding: "0 6px" }}>
      <span style={{ fontSize: 15, fontWeight: 900, color: "#92400e", textAlign: "center", lineHeight: 1.15, overflow: "hidden", textOverflow: "ellipsis", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" }}>
        {marca}
      </span>
      <span style={{ fontSize: 9, fontWeight: 700, color: "#b45309", letterSpacing: 0.3 }}>SIN FOTO</span>
    </div>
  );
}

function TarjetaMarca({ marca, seleccionadoId, onSelect, estadoStock, stack }) {
  const C = C_LIGHT;
  const tieneSeleccion = marca.opciones.some((p) => p.id === seleccionadoId);
  const color = marca.patente ? C.purple : C.teal;
  const colorDim = marca.patente ? C.purpleDim : C.tealDim;

  return (
    <div
      style={{
        border: `${tieneSeleccion ? 2 : 1}px solid ${tieneSeleccion ? C.blue : C.border}`,
        borderRadius: 12,
        background: C.card,
        padding: 10,
        display: "flex",
        flexDirection: "column",
        gap: 8,
        minWidth: 0,
      }}
    >
      <Portada foto={marca.foto} marca={marca.marca} alto={stack ? 70 : 84} />

      <div style={{ display: "flex", alignItems: "center", gap: 6, minWidth: 0 }}>
        <span style={{ fontSize: 9, fontWeight: 800, padding: "2px 6px", borderRadius: 6, background: colorDim, color, letterSpacing: 0.3, flexShrink: 0 }}>
          {marca.patente ? "PATENTE" : "GENÉRICO"}
        </span>
        {/* Sin foto la portada ya trae la marca; repetirla come la tarjeta. */}
        {marca.foto && (
          <span style={{ fontSize: 13, fontWeight: 800, color: C.text, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
            {marca.marca}
          </span>
        )}
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
        {marca.opciones.map((p) => {
          const sel = p.id === seleccionadoId;
          const estado = estadoStock ? estadoStock(p) : null;
          const noDisp = Boolean(estado?.agotado);
          return (
            <button
              key={p.id}
              type="button"
              onClick={() => onSelect(p)}
              title={p.nombre}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                gap: 8,
                width: "100%",
                padding: "6px 8px",
                borderRadius: 8,
                border: `1px solid ${sel ? C.blue : C.border}`,
                background: sel ? C.blueDim : C.bg,
                cursor: "pointer",
                textAlign: "left",
                opacity: noDisp ? 0.55 : 1,
                minWidth: 0,
              }}
            >
              <span style={{ minWidth: 0 }}>
                <span style={{ display: "block", fontSize: 11, fontWeight: sel ? 800 : 600, color: sel ? C.blue : C.textMid, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                  {etiquetaPresentacion(p) || "Presentación única"}
                </span>
                {noDisp && (
                  <span style={{ display: "block", fontSize: 10, color: C.red, fontWeight: 700 }}>
                    {estado.etiqueta}
                  </span>
                )}
              </span>
              <span style={{ fontSize: 12, fontWeight: 800, color: C.text, flexShrink: 0 }}>{$(p.precio)}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default function TableroEquivalentes({ grupo, seleccionadoId, onSelect, estadoStock, stack = false }) {
  const C = C_LIGHT;
  if (!grupo?.marcas?.length) return null;

  const patentes = grupo.marcas.filter((m) => m.patente).length;
  const resumen = patentes
    ? `${patentes} de patente · ${grupo.marcas.length - patentes} genérico${grupo.marcas.length - patentes === 1 ? "" : "s"}`
    : `${grupo.marcas.length} marcas · todas genéricas`;

  return (
    <div style={{ border: `1px solid ${C.border}`, borderRadius: 12, background: C.bg, padding: 10, marginBottom: 8 }}>
      <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 8, marginBottom: 8, flexWrap: "wrap" }}>
        <span style={{ fontSize: 11, fontWeight: 800, color: C.text, letterSpacing: 0.3 }}>
          🔎 Mismo principio activo{grupo.etiqueta ? `: ${grupo.etiqueta}` : ""}
        </span>
        <span style={{ fontSize: 10, color: C.textDim, fontWeight: 700 }}>{resumen}</span>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: `repeat(auto-fit, minmax(${stack ? 132 : 148}px, 1fr))`, gap: 8 }}>
        {grupo.marcas.map((m) => (
          <TarjetaMarca
            key={m.marca}
            marca={m}
            seleccionadoId={seleccionadoId}
            onSelect={onSelect}
            estadoStock={estadoStock}
            stack={stack}
          />
        ))}
      </div>

      <div style={{ fontSize: 10, color: C.textDim, marginTop: 8, lineHeight: 1.4 }}>
        Revisa gramaje y presentación antes de cambiar: comparten sustancia, no siempre la dosis.
      </div>
    </div>
  );
}
