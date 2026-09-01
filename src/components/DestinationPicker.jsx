import { useState } from "react";
import AddressAutocomplete from "./AddressAutocomplete";
import {
  checkoutNumeroOk,
  cleanCheckoutColonia,
  formatDestinoLabel,
  applyDestinoSuggestion,
} from "../lib/checkoutAddress";

/**
 * Destino de entrega al estilo Uber: un buscador, eliges, queda fijado.
 * No pide calle / número / CP / colonia por separado.
 */
export default function DestinationPicker({
  calle = "",
  numero = "",
  colonia = "",
  cp = "",
  lat = null,
  lng = null,
  onConfirm,
  onNumeroChange,
  onColoniaChange,
  onCpChange,
  inputStyle = {},
  fieldStyle = {},
}) {
  const [query, setQuery] = useState("");
  const label = formatDestinoLabel({ calle, numero, colonia, cp });
  const tieneCalle = String(calle || "").trim().length >= 5;
  const faltaNumero = tieneCalle && !checkoutNumeroOk(numero);
  const faltaColonia = cleanCheckoutColonia(colonia).length < 3;
  const faltaCp = String(cp || "").replace(/\D/g, "").length !== 5;

  const pick = (sug) => {
    const next = applyDestinoSuggestion(sug, { calle, numero, colonia, cp, lat, lng });
    onConfirm?.(next);
    setQuery("");
  };

  if (tieneCalle) {
    return (
      <div>
        <div
          style={{
            border: "1px solid #e2e8f0",
            borderRadius: 12,
            padding: "12px 14px",
            background: "#f8fafc",
          }}
        >
          <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
            <span aria-hidden style={{ fontSize: 18, lineHeight: 1.2 }}>📍</span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 700, color: "#0f172a", fontSize: 14, lineHeight: 1.35 }}>
                {label || calle}
              </div>
              {Number.isFinite(Number(lat)) && Number.isFinite(Number(lng)) && (
                <div style={{ fontSize: 11, color: "#166534", marginTop: 4 }}>Destino fijado</div>
              )}
            </div>
            <button
              type="button"
              onClick={() => {
                setQuery("");
                onConfirm?.({
                  calle: "",
                  numero: "",
                  colonia: "",
                  cp: "",
                  lat: null,
                  lng: null,
                });
              }}
              style={{
                background: "none",
                border: "none",
                color: "#1d4ed8",
                fontWeight: 700,
                fontSize: 13,
                cursor: "pointer",
                padding: 0,
                flexShrink: 0,
              }}
            >
              Cambiar
            </button>
          </div>
        </div>
        {faltaNumero && (
          <div style={{ marginTop: 10 }}>
            <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
              Número exterior <span style={{ color: "#dc2626" }}>*</span>
            </div>
            <input
              value={numero || ""}
              onChange={(e) => onNumeroChange?.(e.target.value)}
              placeholder="Ej. 1750"
              inputMode="text"
              autoComplete="address-line2"
              style={fieldStyle}
            />
          </div>
        )}
        {(faltaColonia || faltaCp) && (
          <div style={{ display: "grid", gridTemplateColumns: faltaColonia && faltaCp ? "1fr 1fr" : "1fr", gap: 10, marginTop: 10 }}>
            {faltaColonia && (
              <div>
                <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
                  Colonia <span style={{ color: "#dc2626" }}>*</span>
                </div>
                <input
                  value={colonia || ""}
                  onChange={(e) => onColoniaChange?.(e.target.value)}
                  placeholder="Roma Norte"
                  style={fieldStyle}
                />
              </div>
            )}
            {faltaCp && (
              <div>
                <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
                  CP <span style={{ color: "#dc2626" }}>*</span>
                </div>
                <input
                  value={cp || ""}
                  onChange={(e) => onCpChange?.(e.target.value)}
                  placeholder="06700"
                  inputMode="numeric"
                  autoComplete="postal-code"
                  style={fieldStyle}
                />
              </div>
            )}
          </div>
        )}
      </div>
    );
  }

  return (
    <AddressAutocomplete
      value={query}
      onChange={setQuery}
      onPick={pick}
      placeholder="Av. Insurgentes Sur 300, Roma Norte"
      inputStyle={inputStyle}
    />
  );
}
