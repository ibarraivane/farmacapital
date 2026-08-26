import React from "react";
import { C_LIGHT } from "../../../constants";
import { $ } from "../../../utils";
import { posSubtituloProducto } from "../../../utils/posProductDisplay";
import { etiquetaTipoProducto } from "../../../utils/equivalentesPos";

/**
 * Todas las opciones del mismo principio activo, agrupadas por marca.
 *
 * Una tarjeta por marca y adentro sus presentaciones como cajitas: la vendedora
 * ve "Treda" una vez, no tres veces repetida. La patente va primero porque el
 * buscador la hunde — una marca nunca se llama como la sustancia que se teclea.
 */

function etiquetaSustanciaVisible(value) {
  return String(value || "")
    .replace(/\bcaolin\b/gi, "Caolín")
    .replace(/\bneomicina\b/gi, "Neomicina")
    .replace(/\bpectina\b/gi, "Pectina");
}

/** Lo que distingue una presentación de otra dentro de la misma marca. */
function etiquetaPresentacion(producto) {
  const partes = [producto?.concentracion, producto?.presentacion, producto?.forma_farmaceutica]
    .map((x) => String(x || "").trim())
    .filter(Boolean);
  if (partes.length) return partes.join(" · ");
  return posSubtituloProducto(producto) || producto?.sku || "Presentación única";
}

function nombreDeMarca(producto) {
  const marca = String(producto?.marca || "").trim();
  if (marca && !/^gen[eé]rico$/i.test(marca)) return marca;
  return String(producto?.nombre || "").split(/\s+/).slice(0, 2).join(" ") || "Sin marca";
}

function precioNum(p) {
  const n = parseFloat(p?.precio);
  return Number.isFinite(n) ? n : Infinity;
}

/**
 * Agrupa las opciones del grupo por marca, conservando de cuál sección venía
 * cada una para poder avisar cuando cambia la dosis o la forma.
 */
function marcasDelGrupo(grupo) {
  const marcados = [
    ...(grupo?.mismaConfiguracion || []).map((p) => ({ p, aviso: "" })),
    ...(grupo?.otroContenido || []).map((p) => ({ p, aviso: "Otro contenido" })),
    ...(grupo?.otrasPresentaciones || []).map((p) => ({ p, aviso: "Otra dosis o forma" })),
  ];

  const porMarca = new Map();
  for (const item of marcados) {
    const marca = nombreDeMarca(item.p);
    const llave = marca.toLowerCase();
    if (!porMarca.has(llave)) porMarca.set(llave, { marca, patente: false, generico: false, opciones: [] });
    const grupoMarca = porMarca.get(llave);
    grupoMarca.opciones.push(item);
    // Basta con que una presentación declare el tipo: el catálogo lo trae a
    // medias y dejar la tarjeta sin etiqueta es peor que leerlo de la hermana.
    const tipo = etiquetaTipoProducto(item.p);
    if (tipo === "Marca") grupoMarca.patente = true;
    if (tipo === "Genérico") grupoMarca.generico = true;
  }

  const marcas = [...porMarca.values()].map((m) => {
    const opciones = [...m.opciones].sort((a, b) => precioNum(a.p) - precioNum(b.p));
    return { ...m, opciones, precioDesde: precioNum(opciones[0]?.p) };
  });

  marcas.sort((a, b) => {
    if (a.patente !== b.patente) return a.patente ? -1 : 1;
    return a.precioDesde - b.precioDesde;
  });
  return marcas;
}

/** Sin foto: la marca en letras grandes. Se distingue igual desde el mostrador. */
function Portada({ foto, marca }) {
  const C = C_LIGHT;
  return (
    <div style={{ height: 104, borderRadius: 9, overflow: "hidden", background: foto ? "#fff" : C.amberDim, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", padding: 6, boxSizing: "border-box" }}>
      {foto ? (
        <img src={foto} alt="" style={{ maxWidth: "100%", maxHeight: "100%", objectFit: "contain" }} />
      ) : (
        <span style={{ fontSize: 18, fontWeight: 900, color: "#92400e", textAlign: "center", lineHeight: 1.1, overflowWrap: "anywhere" }}>{marca}</span>
      )}
    </div>
  );
}

function TarjetaMarca({ marca, onSelect, onAdd, estadoStock }) {
  const C = C_LIGHT;
  const conFoto = marca.opciones.find(({ p }) => p.imagen_url || p.imagen_mobile_url);
  const foto = conFoto ? (conFoto.p.imagen_url || conFoto.p.imagen_mobile_url) : "";
  const unaSola = marca.opciones.length === 1;
  const etiquetaTipo = marca.patente ? "Patente" : marca.generico ? "Genérico" : "";

  return (
    <article style={{ border: `1px solid ${C.border}`, borderRadius: 12, background: C.card, padding: 9, display: "flex", flexDirection: "column", gap: 7, minWidth: 0, height: "100%", boxSizing: "border-box" }}>
      <Portada foto={foto} marca={marca.marca} />

      <div style={{ display: "flex", alignItems: "center", gap: 6, minWidth: 0 }}>
        {etiquetaTipo && (
          <span style={{ fontSize: 10, fontWeight: 850, borderRadius: 7, padding: "3px 7px", background: marca.patente ? C.purpleDim : C.tealDim, color: marca.patente ? C.purple : C.teal, flexShrink: 0 }}>
            {etiquetaTipo}
          </span>
        )}
        {/* Sin foto la portada ya trae la marca; repetirla come la tarjeta. */}
        {foto && (
          <span style={{ fontSize: 15, fontWeight: 900, color: C.text, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
            {marca.marca}
          </span>
        )}
      </div>

      {marca.opciones.length > 1 && (
        <div style={{ fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.3 }}>
          {marca.opciones.length} presentaciones
        </div>
      )}

      <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
        {marca.opciones.map(({ p, aviso }) => {
          const estado = estadoStock?.(p) || {};
          const agotado = Boolean(estado.agotado);
          return (
            <button
              key={p.id}
              type="button"
              onClick={() => onSelect(p)}
              title={p.nombre}
              style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8, width: "100%", padding: "7px 8px", borderRadius: 8, border: `1px solid ${C.border}`, background: C.bg, cursor: "pointer", textAlign: "left", opacity: agotado ? 0.55 : 1, minWidth: 0 }}
            >
              <span style={{ minWidth: 0 }}>
                <span style={{ display: "block", fontSize: 11, fontWeight: 700, color: C.textMid, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                  {etiquetaPresentacion(p)}
                </span>
                {/* El aviso de dosis nunca debe tapar el stock: se ven los dos. */}
                <span style={{ display: "block", fontSize: 10, fontWeight: 800, marginTop: 1 }}>
                  {aviso && !agotado && <span style={{ color: C.amber }}>{aviso} · </span>}
                  <span style={{ color: agotado ? C.red : C.green }}>
                    {estado.etiqueta || (agotado ? "No disponible" : "Disponible")}
                  </span>
                </span>
              </span>
              <span style={{ fontSize: 13, fontWeight: 900, color: C.blue, flexShrink: 0 }}>{$(p.precio)}</span>
            </button>
          );
        })}
      </div>

      {unaSola && (
        <button
          type="button"
          disabled={Boolean(estadoStock?.(marca.opciones[0].p)?.agotado)}
          onClick={() => onAdd(marca.opciones[0].p)}
          style={{ minHeight: 42, marginTop: "auto", padding: "8px 13px", border: 0, borderRadius: 9, background: estadoStock?.(marca.opciones[0].p)?.agotado ? C.border : C.blue, color: estadoStock?.(marca.opciones[0].p)?.agotado ? C.textDim : "#fff", fontSize: 12, fontWeight: 850, cursor: "pointer" }}
        >
          Agregar
        </button>
      )}
    </article>
  );
}

export default function TableroEquivalentes({ grupo, onSelect, onAdd, estadoStock }) {
  if (!grupo?.total) return null;
  const marcas = marcasDelGrupo(grupo);
  if (!marcas.length) return null;

  return (
    <div style={{ border: `1px solid ${C_LIGHT.border}`, borderRadius: 14, background: C_LIGHT.bg, padding: 10, marginBottom: 10 }}>
      <div style={{ fontSize: 16, fontWeight: 900, color: C_LIGHT.text }}>
        {grupo.total} opciones con {etiquetaSustanciaVisible(grupo.etiqueta)}
      </div>
      <div style={{ fontSize: 11, color: C_LIGHT.textDim, marginTop: 3 }}>
        Toca una presentación para verla en grande. Revisa la dosis antes de cambiar de marca.
      </div>
      <div className="pos-related-products-grid" style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0, 1fr))", gap: 8, marginTop: 8 }}>
        {marcas.map((m) => (
          <TarjetaMarca key={m.marca} marca={m} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} />
        ))}
      </div>
      <style>{`@media (min-width: 1180px){.pos-related-products-grid{grid-template-columns:repeat(4,minmax(0,1fr))!important}} @media (max-width: 620px){.pos-related-products-grid{grid-template-columns:1fr!important}}`}</style>
    </div>
  );
}
