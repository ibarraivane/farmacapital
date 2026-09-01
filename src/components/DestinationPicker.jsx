import { useEffect, useState } from "react";
import AddressAutocomplete from "./AddressAutocomplete";
import {
  checkoutNumeroOk,
  cleanCheckoutColonia,
  formatDestinoLabel,
  applyDestinoSuggestion,
  isCheckoutDestinoListo,
  parseTypedMxAddress,
} from "../lib/checkoutAddress";
import { fetchColoniasByCp } from "../lib/sepomexColoniasClient";
import {
  loadSavedAddresses,
  upsertSavedAddress,
  deleteSavedAddress,
  savedAddressToDestino,
} from "../lib/savedCheckoutAddresses";

function foldMx(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

function matchColonia(list, colonia) {
  const cur = foldMx(cleanCheckoutColonia(colonia));
  if (!cur) return "";
  return (list || []).find((c) => foldMx(c) === cur) || "";
}

/**
 * Destino: buscador + CP editable + colonia del CP + direcciones con nombre.
 */
export default function DestinationPicker({
  calle = "",
  numero = "",
  colonia = "",
  cp = "",
  lat = null,
  lng = null,
  referencia = "",
  user = null,
  onConfirm,
  onNumeroChange,
  onColoniaChange,
  onCpChange,
  inputStyle = {},
  fieldStyle = {},
}) {
  const [query, setQuery] = useState("");
  const [colonias, setColonias] = useState([]);
  const [coloniasLoading, setColoniasLoading] = useState(false);
  const [saveName, setSaveName] = useState("");
  const [saved, setSaved] = useState(() => loadSavedAddresses(user));
  const [saveMsg, setSaveMsg] = useState("");

  const dest = { calle, numero, colonia, cp, lat, lng };
  const label = formatDestinoLabel(dest);
  const tieneCalle = String(calle || "").trim().length >= 5;
  const faltaNumero = tieneCalle && !checkoutNumeroOk(numero);
  const listo = isCheckoutDestinoListo(dest);
  const zip = String(cp || "").replace(/\D/g, "").slice(0, 5);

  useEffect(() => {
    setSaved(loadSavedAddresses(user));
  }, [user?.id, user?.telefono]);

  useEffect(() => {
    if (zip.length !== 5) {
      setColonias([]);
      setColoniasLoading(false);
      return undefined;
    }
    let cancelled = false;
    setColoniasLoading(true);
    fetchColoniasByCp(zip).then((res) => {
      if (cancelled) return;
      setColoniasLoading(false);
      const list = res.colonias || [];
      setColonias(list);
      const matched = matchColonia(list, colonia);
      if (matched) {
        if (matched !== colonia) onColoniaChange?.(matched);
      } else if (list.length === 1) {
        onColoniaChange?.(list[0]);
      } else if (cleanCheckoutColonia(colonia) && list.length > 0) {
        onColoniaChange?.("");
      }
    });
    return () => {
      cancelled = true;
    };
    // Solo al cambiar el CP: no reaccionar a cada tecla de colonia.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [zip]);

  const pick = (sug) => {
    const typed = parseTypedMxAddress(query);
    const next = applyDestinoSuggestion(sug, dest);
    if (typed?.cp && typed.cp.length === 5) next.cp = typed.cp;
    if (typed?.colonia && cleanCheckoutColonia(typed.colonia).length >= 3 && !cleanCheckoutColonia(next.colonia)) {
      next.colonia = cleanCheckoutColonia(typed.colonia);
    }
    onConfirm?.(next);
    setQuery("");
  };

  const applySaved = (entry) => {
    const next = savedAddressToDestino(entry);
    if (!next) return;
    onConfirm?.(next);
    setQuery("");
  };

  const onSave = () => {
    const r = upsertSavedAddress(user, {
      name: saveName,
      dest,
      referencia,
    });
    if (!r.ok) {
      setSaveMsg(r.error === "incomplete" ? "Completa calle, CP y colonia para guardar." : "No se pudo guardar.");
      return;
    }
    setSaved(r.list);
    setSaveName("");
    setSaveMsg(`Guardada como «${r.entry.name}».`);
  };

  const onDeleteSaved = (id) => {
    setSaved(deleteSavedAddress(user, id));
  };

  const coloniaInList = matchColonia(colonias, colonia);
  const useSelect = colonias.length > 0;
  const selectValue = coloniaInList || (cleanCheckoutColonia(colonia) ? "__current__" : "");

  const savedChips =
    saved.length > 0 ? (
      <div style={{ marginBottom: 10 }}>
        <div style={{ color: "#64748b", fontSize: 11, fontWeight: 700, marginBottom: 6 }}>
          Direcciones guardadas
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
          {saved.map((a) => (
            <span
              key={a.id}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: 4,
                border: "1px solid #bfdbfe",
                background: "#eff6ff",
                borderRadius: 999,
                padding: "4px 4px 4px 10px",
              }}
            >
              <button
                type="button"
                onClick={() => applySaved(a)}
                style={{
                  background: "none",
                  border: "none",
                  color: "#1e3a8a",
                  fontWeight: 700,
                  fontSize: 12,
                  cursor: "pointer",
                  padding: 0,
                }}
              >
                {a.name}
              </button>
              <button
                type="button"
                aria-label={`Borrar ${a.name}`}
                onClick={() => onDeleteSaved(a.id)}
                style={{
                  background: "none",
                  border: "none",
                  color: "#64748b",
                  fontSize: 14,
                  cursor: "pointer",
                  lineHeight: 1,
                  padding: "0 6px 0 2px",
                }}
              >
                ×
              </button>
            </span>
          ))}
        </div>
      </div>
    ) : null;

  const cpColoniaFields = (
    <div style={{ display: "grid", gridTemplateColumns: "110px 1fr", gap: 10, marginTop: 10 }}>
      <div>
        <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
          Código postal <span style={{ color: "#dc2626" }}>*</span>
        </div>
        <input
          className="farmacapital-field-input"
          value={cp || ""}
          onChange={(e) => onCpChange?.(e.target.value.replace(/\D/g, "").slice(0, 5))}
          placeholder="Ej. 06700"
          inputMode="numeric"
          autoComplete="postal-code"
          maxLength={5}
          aria-label="Código postal"
          style={fieldStyle}
        />
      </div>
      <div>
        <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
          Colonia <span style={{ color: "#dc2626" }}>*</span>
        </div>
        {useSelect ? (
          <select
            className="farmacapital-field-input farmacapital-field-select"
            value={selectValue}
            onChange={(e) => {
              const v = e.target.value;
              if (v === "__current__") return;
              onColoniaChange?.(v);
            }}
            aria-label="Colonia"
            disabled={coloniasLoading}
            style={{ ...fieldStyle, appearance: "auto", color: selectValue ? undefined : "#b8b0a6" }}
          >
            <option value="">{coloniasLoading ? "Cargando…" : "Ej. elige tu colonia"}</option>
            {colonias.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
            {!coloniaInList && cleanCheckoutColonia(colonia) ? (
              <option value="__current__">{cleanCheckoutColonia(colonia)}</option>
            ) : null}
          </select>
        ) : (
          <input
            className="farmacapital-field-input"
            value={colonia || ""}
            onChange={(e) => onColoniaChange?.(e.target.value)}
            placeholder={coloniasLoading ? "Buscando colonias…" : "Ej. tu colonia"}
            aria-label="Colonia"
            style={fieldStyle}
          />
        )}
      </div>
    </div>
  );

  const saveRow = listo ? (
    <div style={{ marginTop: 10 }}>
      <div style={{ color: "#64748b", fontSize: 12, marginBottom: 6, fontWeight: 600 }}>
        Guardar para otras compras
      </div>
      <div style={{ display: "flex", gap: 8 }}>
        <input
          value={saveName}
          onChange={(e) => {
            setSaveName(e.target.value);
            setSaveMsg("");
          }}
          className="farmacapital-field-input"
          placeholder="Ej. Casa, Trabajo…"
          aria-label="Nombre de la dirección"
          style={{ ...fieldStyle, flex: 1 }}
        />
        <button
          type="button"
          onClick={onSave}
          disabled={!saveName.trim()}
          style={{
            border: 0,
            borderRadius: 8,
            padding: "0 14px",
            background: saveName.trim() ? "#1d4ed8" : "#cbd5e1",
            color: "#fff",
            fontWeight: 700,
            fontSize: 13,
            cursor: saveName.trim() ? "pointer" : "default",
            flexShrink: 0,
          }}
        >
          Guardar
        </button>
      </div>
      {saveMsg ? (
        <div style={{ fontSize: 11, color: "#166534", marginTop: 4 }}>{saveMsg}</div>
      ) : null}
    </div>
  ) : null;

  if (tieneCalle) {
    return (
      <div>
        {savedChips}
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
              {listo ? (
                <div style={{ fontSize: 11, color: "#166534", marginTop: 4 }}>Destino listo</div>
              ) : (
                <div style={{ fontSize: 11, color: "#b45309", marginTop: 4 }}>
                  Revisa código postal y colonia
                </div>
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
              className="farmacapital-field-input"
              value={numero || ""}
              onChange={(e) => onNumeroChange?.(e.target.value)}
              placeholder="Ej. 12"
              inputMode="text"
              autoComplete="address-line2"
              style={fieldStyle}
            />
          </div>
        )}
        {cpColoniaFields}
        {saveRow}
      </div>
    );
  }

  return (
    <div>
      {savedChips}
      <AddressAutocomplete
        value={query}
        onChange={setQuery}
        onPick={pick}
        inputStyle={inputStyle}
      />
      {cpColoniaFields}
    </div>
  );
}
