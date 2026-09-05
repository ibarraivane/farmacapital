/** Interruptor de presentación. No filtra ni guarda: solo emite onChange(next). */
export function Switch({ checked, onChange, label, id, disabled = false }) {
  return (
    <label
      className={`fc-switch${checked ? " is-on" : ""}${disabled ? " is-disabled" : ""}`}
      htmlFor={id}
    >
      <input
        id={id}
        type="checkbox"
        role="switch"
        className="fc-switch-input"
        checked={Boolean(checked)}
        disabled={disabled}
        aria-checked={Boolean(checked)}
        onChange={() => {
          if (disabled || typeof onChange !== "function") return;
          onChange(!checked);
        }}
        onKeyDown={(e) => {
          if (disabled || typeof onChange !== "function") return;
          if (e.key === " " || e.key === "Enter") {
            e.preventDefault();
            onChange(!checked);
          }
        }}
      />
      <span className="fc-switch-track" aria-hidden>
        <span className="fc-switch-knob" />
      </span>
      <span className="fc-switch-text">{label}</span>
    </label>
  );
}
