import { useEffect, useState } from "react";
import { C_LIGHT } from "../../constants";
import { repartoAtencion } from "../../lib/servicioSalud";
import { Inp } from "../../ui";
import { $ } from "../../utils";

/**
 * Ficha corta de atención en mostrador. Solo nombre, precio y activo.
 * Sin stock, lote, costo ni proveedor.
 */
function FilaServicio({ servicio, onGuardar, onToggleActivo }) {
  const C = C_LIGHT;
  const [nombre, setNombre] = useState(servicio.nombre || "");
  const [precio, setPrecio] = useState(servicio.precio == null ? "" : String(servicio.precio));
  const activo = servicio.activo !== false;

  useEffect(() => {
    setNombre(servicio.nombre || "");
    setPrecio(servicio.precio == null ? "" : String(servicio.precio));
  }, [servicio.id, servicio.nombre, servicio.precio]);

  const guardarNombre = () => {
    const next = nombre.trim();
    if (!next || next === String(servicio.nombre || "").trim()) {
      setNombre(servicio.nombre || "");
      return;
    }
    onGuardar(servicio, "nombre", next);
  };

  const guardarPrecio = () => {
    const next = String(precio).trim();
    if (next === "" || next === String(servicio.precio ?? "")) return;
    onGuardar(servicio, "precio", next);
  };

  const partes = repartoAtencion(precio);

  return (
    <div
      data-testid={`servicio-salud-${servicio.sku || servicio.id}`}
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: 10,
        alignItems: "flex-end",
        padding: "12px 0",
        borderBottom: `1px solid ${C.border}`,
        opacity: activo ? 1 : 0.72,
      }}
    >
      <label style={{ display: "flex", flexDirection: "column", gap: 4, flex: "1 1 220px", minWidth: 0 }}>
        <span style={{ fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.4 }}>NOMBRE</span>
        <Inp value={nombre} onChange={(e) => setNombre(e.target.value)} onBlur={guardarNombre} />
        {servicio.sku ? (
          <span style={{ fontSize: 11, color: C.textDim }}>{servicio.sku}</span>
        ) : null}
      </label>
      <label style={{ display: "flex", flexDirection: "column", gap: 4, flex: "0 1 140px" }}>
        <span style={{ fontSize: 10, fontWeight: 800, color: C.textDim, letterSpacing: 0.4 }}>PRECIO</span>
        <Inp
          value={precio}
          onChange={(e) => setPrecio(e.target.value)}
          onBlur={guardarPrecio}
          inputMode="decimal"
        />
        {partes.total > 0 ? (
          <span style={{ fontSize: 11, color: C.textMid, fontWeight: 700 }}>
            Quien aplica {$(partes.aplica)} · Farmacia {$(partes.farmacia)}
          </span>
        ) : null}
      </label>
      <button
        type="button"
        onClick={() => onToggleActivo(servicio)}
        style={{
          minHeight: 40,
          padding: "8px 14px",
          borderRadius: 10,
          border: `1px solid ${activo ? C.green : C.border}`,
          background: activo ? C.greenDim : C.bg,
          color: activo ? C.green : C.textMid,
          fontWeight: 800,
          cursor: "pointer",
        }}
      >
        {activo ? "Activo" : "Inactivo"}
      </button>
    </div>
  );
}

export default function ServiciosSaludPanel({ servicios, onGuardar, onToggleActivo }) {
  const C = C_LIGHT;
  const lista = servicios || [];
  return (
    <section data-testid="servicios-salud-panel" style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 16 }}>
      <h2 style={{ margin: "0 0 4px", fontSize: 16, color: C.text }}>Servicios de salud</h2>
      <p style={{ margin: "0 0 12px", fontSize: 12, color: C.textMid, lineHeight: 1.45 }}>
        Atención en mostrador. Aquí solo se cambia el nombre, el precio y si está activo.
        No llevan stock, lote ni costo de compra. El precio se parte a la mitad: quien aplica y la farmacia.
      </p>
      {lista.length === 0 ? (
        <p style={{ margin: 0, fontSize: 13, color: C.textDim }}>
          Todavía no hay servicios en el catálogo. Aparecen al correr el SQL de atención en mostrador.
        </p>
      ) : (
        lista.map((s) => (
          <FilaServicio key={s.id} servicio={s} onGuardar={onGuardar} onToggleActivo={onToggleActivo} />
        ))
      )}
    </section>
  );
}
