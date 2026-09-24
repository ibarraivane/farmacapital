import { useEffect, useRef, useState } from "react";
import {
  alternarCategoriaFiltro,
  etiquetaFiltroCategorias,
} from "../constants/categoriasProducto";

/**
 * Filtro de inventario: casillas para una o varias categorías.
 * Lista vacía = todas.
 */
export default function FiltroCategoriasCheck({ categorias = [], value = [], onChange, style }) {
  const [abierto, setAbierto] = useState(false);
  const caja = useRef(null);
  const marcas = Array.isArray(value) ? value : [];

  useEffect(() => {
    if (!abierto) return undefined;
    const cerrar = (e) => {
      if (!caja.current?.contains(e.target)) setAbierto(false);
    };
    const tecla = (e) => {
      if (e.key === "Escape") setAbierto(false);
    };
    document.addEventListener("mousedown", cerrar);
    document.addEventListener("keydown", tecla);
    return () => {
      document.removeEventListener("mousedown", cerrar);
      document.removeEventListener("keydown", tecla);
    };
  }, [abierto]);

  const toggle = (cat) => onChange?.(alternarCategoriaFiltro(marcas, cat));

  return (
    <div ref={caja} style={{ position: "relative", minWidth: 180, maxWidth: 240 }}>
      <button
        type="button"
        aria-expanded={abierto}
        aria-haspopup="listbox"
        onClick={() => setAbierto((v) => !v)}
        style={{
          ...style,
          width: "100%",
          maxWidth: "100%",
          textAlign: "left",
          cursor: "pointer",
          background: "#ffffff",
          color: "#0f172a",
        }}
      >
        {etiquetaFiltroCategorias(marcas)}
      </button>
      {abierto ? (
        <div
          role="listbox"
          aria-label="Categorías"
          aria-multiselectable="true"
          style={{
            position: "absolute",
            zIndex: 40,
            top: "calc(100% + 4px)",
            left: 0,
            minWidth: 220,
            maxHeight: 320,
            overflowY: "auto",
            background: "#ffffff",
            color: "#0f172a",
            border: "1px solid #dce2ea",
            borderRadius: 8,
            boxShadow: "0 8px 24px rgba(15,23,42,.12)",
            padding: 6,
          }}
        >
          <label style={{ display: "flex", alignItems: "center", gap: 8, padding: "6px 8px", fontSize: 13, fontWeight: 700, cursor: "pointer" }}>
            <input
              type="checkbox"
              className="farmacapital-field-input"
              checked={marcas.length === 0}
              onChange={() => onChange?.([])}
              style={{ colorScheme: "light", accentColor: "#1E3ABA" }}
            />
            Todas las categorías
          </label>
          {categorias.map((c) => (
            <label key={c} style={{ display: "flex", alignItems: "center", gap: 8, padding: "6px 8px", fontSize: 13, cursor: "pointer" }}>
              <input
                type="checkbox"
                className="farmacapital-field-input"
                checked={marcas.includes(c)}
                onChange={() => toggle(c)}
                style={{ colorScheme: "light", accentColor: "#1E3ABA" }}
              />
              {c}
            </label>
          ))}
        </div>
      ) : null}
    </div>
  );
}
