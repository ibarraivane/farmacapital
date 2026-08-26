import { useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { construirSerie, resumenPunto, ymdMexico } from "./lib/ventasVsMeta";

const GRAINS = [
  { id: "dia", label: "Día" },
  { id: "semana", label: "Semana" },
  { id: "mes", label: "Mes" },
];

const fmtK = (n) => {
  const v = parseFloat(n || 0);
  if (v >= 1000) return `$${(v / 1000).toFixed(1)}k`;
  return `$${Math.round(v).toLocaleString("es-MX")}`;
};

function colorBarra(p) {
  const { pct, ok } = resumenPunto(p);
  if (ok) return C_LIGHT.green;
  if (pct >= 70) return C_LIGHT.blue;
  if (pct >= 40) return C_LIGHT.amber;
  return C_LIGHT.red;
}

export default function VentasVsMetaChart({ porDia, cfg, hoyYmd }) {
  const C = C_LIGHT;
  const [grano, setGrano] = useState("dia");
  const [selKey, setSelKey] = useState(null);

  const hoy = hoyYmd || ymdMexico();
  const serie = useMemo(
    () => construirSerie({ porDia, cfg, grano, hoyYmd: hoy }),
    [porDia, cfg, grano, hoy],
  );

  const elegido = serie.find((p) => p.key === selKey) || serie.find((p) => p.esActual) || serie[serie.length - 1];
  const { pct, falta, ok } = resumenPunto(elegido);
  const max = Math.max(...serie.map((p) => Math.max(p.actual || 0, p.meta || 0)), 1);

  const hayDatos = serie.some((p) => (p.actual || 0) > 0);
  const sub = grano === "dia"
    ? "Cada barra es un día. La raya es la meta de ese día (domingo no es lo mismo que viernes)."
    : grano === "semana"
      ? "Lunes a domingo. La raya es la suma de las metas de esos 7 días."
      : "La raya es la meta mensual que configuraste (no el prorrateo).";

  return (
    <section
      style={{
        background: C.card,
        border: `1px solid ${C.border}`,
        borderRadius: 12,
        padding: "18px 20px 16px",
        marginBottom: 24,
        minWidth: 0,
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, flexWrap: "wrap", marginBottom: 12 }}>
        <div>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.5 }}>
            VENTAS VS META
          </div>
          <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13, lineHeight: 1.45, maxWidth: 520 }}>
            {sub}
          </p>
        </div>
        <div role="tablist" aria-label="Periodo de la gráfica" style={{ display: "flex", background: C.bg, borderRadius: 10, padding: 3, border: `1px solid ${C.border}` }}>
          {GRAINS.map((g) => {
            const on = grano === g.id;
            return (
              <button
                key={g.id}
                type="button"
                role="tab"
                aria-selected={on}
                onClick={() => { setGrano(g.id); setSelKey(null); }}
                style={{
                  padding: "7px 14px",
                  border: "none",
                  borderRadius: 8,
                  background: on ? "#fff" : "transparent",
                  color: on ? C.text : C.textMid,
                  fontWeight: 800,
                  fontSize: 13,
                  cursor: "pointer",
                  boxShadow: on ? "0 1px 2px rgba(15,23,42,.08)" : "none",
                }}
              >
                {g.label}
              </button>
            );
          })}
        </div>
      </div>

      {hayDatos ? null : (
        <div style={{ color: C.textMid, fontSize: 12, marginBottom: 8 }}>
          Aún no hay ventas en este tramo. Las barras se llenan cuando entren tickets.
        </div>
      )}
      <div
            role="img"
            aria-label={elegido
              ? `${elegido.detalle}: ${fmtK(elegido.actual)} de ${fmtK(elegido.meta)}`
              : "Ventas contra meta"}
            style={{
              display: "flex",
              alignItems: "stretch",
              gap: grano === "dia" ? 4 : 10,
              height: 168,
              padding: "8px 0 0",
            }}
          >
            {serie.map((p) => {
              const h = p.actual > 0 ? Math.max(3, (p.actual / max) * 100) : 0;
              const metaH = p.meta > 0 ? (p.meta / max) * 100 : 0;
              const activo = elegido?.key === p.key;
              const col = colorBarra(p);
              return (
                <button
                  key={p.key}
                  type="button"
                  aria-pressed={activo}
                  aria-label={`${p.detalle}: ${fmtK(p.actual)} de meta ${fmtK(p.meta)}`}
                  onClick={() => setSelKey(p.key)}
                  style={{
                    flex: 1,
                    minWidth: 0,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "flex-end",
                    gap: 6,
                    border: "none",
                    background: "transparent",
                    padding: 0,
                    cursor: "pointer",
                    color: activo ? C.text : C.textMid,
                  }}
                >
                  <span style={{
                    position: "relative",
                    width: "100%",
                    maxWidth: grano === "dia" ? 18 : 36,
                    height: 132,
                    background: C.bg,
                    borderRadius: 5,
                    overflow: "hidden",
                    outline: activo ? `2px solid ${BRAND.primary}` : "none",
                    outlineOffset: 1,
                  }}>
                    <span
                      style={{
                        position: "absolute",
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: `${h}%`,
                        background: col,
                        borderRadius: 5,
                      }}
                    />
                    {metaH > 0 && (
                      <span
                        aria-hidden="true"
                        style={{
                          position: "absolute",
                          left: 0,
                          right: 0,
                          bottom: `${metaH}%`,
                          height: 2,
                          background: C.blueDark,
                          opacity: 0.7,
                        }}
                      />
                    )}
                  </span>
                  <span style={{
                    fontSize: 10,
                    fontWeight: p.esActual ? 800 : 600,
                    letterSpacing: 0.2,
                    textTransform: "uppercase",
                    whiteSpace: "nowrap",
                  }}>
                    {p.label}
                  </span>
                </button>
              );
            })}
          </div>

          {elegido && (
            <div
              aria-live="polite"
              style={{
                marginTop: 14,
                paddingTop: 12,
                borderTop: `1px solid ${C.border}`,
                display: "flex",
                justifyContent: "space-between",
                alignItems: "baseline",
                gap: 12,
                flexWrap: "wrap",
              }}
            >
              <div>
                <div style={{ color: C.text, fontWeight: 800, fontSize: 15 }}>
                  {elegido.detalle}
                  {elegido.esActual ? (grano === "dia" ? " · hoy" : " · en curso") : ""}
                </div>
                <div style={{ color: C.textMid, fontSize: 13, marginTop: 2 }}>
                  {ok
                    ? `Meta cubierta. ${fmtK(elegido.actual)} de ${fmtK(elegido.meta)}.`
                    : `${fmtK(elegido.actual)} de ${fmtK(elegido.meta)} · falta ${fmtK(falta)}`}
                </div>
              </div>
              <div style={{ fontWeight: 800, fontSize: 22, color: colorBarra(elegido), fontVariantNumeric: "tabular-nums" }}>
                {pct.toFixed(0)}%
              </div>
            </div>
          )}
    </section>
  );
}
