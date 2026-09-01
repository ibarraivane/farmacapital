import { useEffect, useId, useRef, useState } from "react";
import { fetchAddressSuggestions } from "../lib/addressSuggestClient";

/**
 * Buscador predictivo de dirección CDMX.
 * Al elegir una sugerencia rellena calle / colonia / CP + lat/lng.
 */
export default function AddressAutocomplete({
  value = "",
  onChange,
  onPick,
  placeholder = "Empieza a escribir calle y número…",
  inputStyle = {},
  disabled = false,
}) {
  const listId = useId();
  const wrapRef = useRef(null);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [items, setItems] = useState([]);
  const [active, setActive] = useState(-1);
  const [provider, setProvider] = useState(null);
  const skipSuggestRef = useRef(false);

  useEffect(() => {
    if (disabled) return undefined;
    const q = String(value || "").trim();
    if (skipSuggestRef.current) {
      skipSuggestRef.current = false;
      return undefined;
    }
    if (q.length < 3) {
      setItems([]);
      setOpen(false);
      setLoading(false);
      return undefined;
    }
    let cancelled = false;
    setLoading(true);
    const t = setTimeout(async () => {
      const res = await fetchAddressSuggestions(q);
      if (cancelled) return;
      setLoading(false);
      setProvider(res.provider || null);
      setItems(res.suggestions || []);
      setOpen(Boolean(res.suggestions?.length));
      setActive(-1);
    }, 280);
    return () => {
      cancelled = true;
      clearTimeout(t);
    };
  }, [value, disabled]);

  useEffect(() => {
    const onDoc = (e) => {
      if (!wrapRef.current?.contains(e.target)) setOpen(false);
    };
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  const pick = (item) => {
    if (!item) return;
    skipSuggestRef.current = true;
    setOpen(false);
    setItems([]);
    onPick?.(item);
  };

  const onKeyDown = (e) => {
    if (!open || !items.length) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive((i) => (i + 1) % items.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((i) => (i <= 0 ? items.length - 1 : i - 1));
    } else if (e.key === "Enter" && active >= 0) {
      e.preventDefault();
      pick(items[active]);
    } else if (e.key === "Escape") {
      setOpen(false);
    }
  };

  return (
    <div ref={wrapRef} style={{ position: "relative" }}>
      <input
        value={value}
        disabled={disabled}
        autoComplete="street-address"
        role="combobox"
        aria-expanded={open}
        aria-controls={listId}
        aria-autocomplete="list"
        placeholder={placeholder}
        onChange={(e) => onChange?.(e.target.value)}
        onFocus={() => items.length && setOpen(true)}
        onKeyDown={onKeyDown}
        style={inputStyle}
      />
      {loading && (
        <div style={{ position: "absolute", right: 10, top: "50%", transform: "translateY(-50%)", fontSize: 11, color: "#64748b" }}>
          Buscando…
        </div>
      )}
      {open && items.length > 0 && (
        <ul
          id={listId}
          role="listbox"
          style={{
            position: "absolute",
            zIndex: 40,
            left: 0,
            right: 0,
            top: "calc(100% + 4px)",
            margin: 0,
            padding: 4,
            listStyle: "none",
            background: "#fff",
            border: "1px solid #e2e8f0",
            borderRadius: 10,
            boxShadow: "0 10px 28px rgba(15,23,42,.12)",
            maxHeight: 240,
            overflowY: "auto",
          }}
        >
          {items.map((item, idx) => (
            <li key={item.id || item.label}>
              <button
                type="button"
                role="option"
                aria-selected={idx === active}
                onMouseEnter={() => setActive(idx)}
                onClick={() => pick(item)}
                style={{
                  width: "100%",
                  textAlign: "left",
                  border: 0,
                  background: idx === active ? "#eff6ff" : "transparent",
                  borderRadius: 8,
                  padding: "10px 12px",
                  cursor: "pointer",
                  fontSize: 13,
                  color: "#0f172a",
                  lineHeight: 1.35,
                }}
              >
                <div style={{ fontWeight: 600 }}>{item.calle || item.label}</div>
                <div style={{ fontSize: 11, color: "#64748b", marginTop: 2 }}>
                  {[item.colonia, item.cp].filter(Boolean).join(" · ") || item.label}
                </div>
              </button>
            </li>
          ))}
          {provider && (
            <li style={{ padding: "6px 12px", fontSize: 10, color: "#94a3b8" }}>
              {provider === "google" ? "Sugerencias Google Maps" : "Sugerencias mapa (OSM)"}
            </li>
          )}
        </ul>
      )}
    </div>
  );
}
