import { BRAND } from "../../constants";
import { etiquetaVariantePublica } from "../../lib/grupoPublico";

const TIENDA = {
  borde: "#e2e8f0",
  activo: BRAND.primary,
  fondo: "#ffffff",
  fondoActivo: BRAND.primary,
  texto: "#0f172a",
  textoActivo: "#ffffff",
  etiqueta: "#64748b",
};

/**
 * Botones de sabor. onElegir recibe el SKU de esa variante.
 * El inventario no cambia: solo se cambia qué renglón está en pantalla.
 */
export default function SelectorSabores({ variantes, activoId, onElegir, etiqueta = "Sabor", colores }) {
  const lista = variantes || [];
  if (lista.length < 2) return null;
  const c = { ...TIENDA, ...(colores || {}) };
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 12, fontWeight: 800, color: c.etiqueta, marginBottom: 8 }}>{etiqueta}</div>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        {lista.map((v) => {
          const sel = String(v.id) === String(activoId);
          const label = etiquetaVariantePublica(v) || v.nombre;
          return (
            <button
              key={v.id}
              type="button"
              aria-pressed={sel}
              onClick={() => onElegir?.(v)}
              style={{
                padding: "8px 12px",
                borderRadius: 999,
                border: `1px solid ${sel ? c.activo : c.borde}`,
                background: sel ? c.fondoActivo : c.fondo,
                color: sel ? c.textoActivo : c.texto,
                fontWeight: 700,
                fontSize: 13,
                cursor: "pointer",
                fontFamily: "inherit",
                minHeight: 40,
                colorScheme: "light",
              }}
            >
              {label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
