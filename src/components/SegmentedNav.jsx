import { BRAND, C_LIGHT } from "../constants";

const C = C_LIGHT;

export function IconWell({ Icon, active, size = 15, well = 28 }) {
  return (
    <span
      className={`fc-dash-tab-well${active ? " is-active" : ""}`}
      style={{
        width: well,
        height: well,
        borderRadius: 8,
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        flexShrink: 0,
        background: active ? `${BRAND.primary}16` : "#e8eef6",
        color: active ? BRAND.primary : C.textMid,
      }}
    >
      <Icon size={size} strokeWidth={1.9} aria-hidden />
    </span>
  );
}

/** Riel tipo Vercel Geist / shadcn: track muted + pastilla blanca activa. */
export function SegmentedNav({ items, value, onChange, ariaLabel }) {
  return (
    <div
      className="fc-dash-seg"
      role="tablist"
      aria-label={ariaLabel}
    >
      {items.map((it) => {
        const active = value === it.id;
        const Icon = it.Icon;
        return (
          <button
            key={it.id}
            type="button"
            role="tab"
            aria-selected={active}
            disabled={it.disabled}
            title={it.title}
            onClick={() => { if (!it.disabled && onChange) onChange(it.id); }}
            className={`fc-dash-seg-tab${active ? " is-active" : ""}`}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: 8,
              padding: "4px 10px 4px 4px",
              border: "none",
              borderRadius: 10,
              background: active ? "#fff" : "transparent",
              boxShadow: active ? "0 1px 2px rgba(15,23,42,.08), 0 0 0 1px rgba(15,23,42,.05)" : "none",
              color: it.disabled ? C.textDim : active ? C.text : C.textMid,
              fontWeight: active ? 700 : 600,
              fontSize: 13,
              cursor: it.disabled ? "not-allowed" : "pointer",
              opacity: it.disabled ? 0.55 : 1,
              whiteSpace: "nowrap",
              flexShrink: 0,
            }}
          >
            {Icon && <IconWell Icon={Icon} active={active && !it.disabled} />}
            {it.label}
          </button>
        );
      })}
    </div>
  );
}
