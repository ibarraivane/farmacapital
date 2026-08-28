import { useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { $ } from "./utils";
import { serieCostoGanancia, totalesCostoGanancia } from "./lib/margenPorDia";
import { ymdMexico } from "./lib/ventasVsMeta";

const COSTO = "#64748b";
const GANANCIA = C_LIGHT.green;

export default function CostoVsGananciaChart({ porDia, dias = 30, hoyYmd }) {
  const C = C_LIGHT;
  const [selKey, setSelKey] = useState(null);
  const hoy = hoyYmd || ymdMexico();
  const serie = useMemo(
    () => serieCostoGanancia({ porDia, dias, hoyYmd: hoy }),
    [porDia, dias, hoy],
  );
  const tot = useMemo(() => totalesCostoGanancia(porDia), [porDia]);
  const elegido = serie.find((p) => p.key === selKey) || serie.find((p) => p.esActual) || serie[serie.length - 1];
  const max = Math.max(...serie.map((p) => p.ingreso || 0), 1);
  const hayDatos = serie.some((p) => (p.ingreso || 0) > 0);

  return (
    <section
      style={{
        background: C.card,
        border: `1px solid ${C.border}`,
        borderRadius: 12,
        padding: "18px 20px 16px",
        marginBottom: 16,
        minWidth: 0,
      }}
    >
      <div style={{ marginBottom: 14 }}>
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.5 }}>
          COSTO VS GANANCIA POR DÍA
        </div>
        <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13, lineHeight: 1.45, maxWidth: 540 }}>
          Cada barra es un día de mostrador. Abajo lo que pagaste al proveedor, arriba lo que quedó.
        </p>
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          gap: 16,
          flexWrap: "wrap",
          marginBottom: 16,
          padding: "12px 14px",
          background: C.bg,
          borderRadius: 10,
        }}
      >
        <div style={{ minWidth: 0, flex: "1 1 220px" }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 800, letterSpacing: 0.6, textTransform: "uppercase" }}>
            En este período
          </div>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 15, marginTop: 4 }}>
            {$(tot.ganancia)} de ganancia · costo {$(tot.costo)}
          </div>
          <div style={{ color: C.textMid, fontSize: 13, marginTop: 2 }}>
            {tot.ingreso > 0 ? `${tot.margenPct}% de lo cobrado se queda.` : "Aún no hay ventas en este filtro."}
          </div>
          <div style={{ height: 8, background: C.card, borderRadius: 99, overflow: "hidden", marginTop: 10, maxWidth: 360, display: "flex" }}>
            {tot.ingreso > 0 && (
              <>
                <div style={{ width: `${(tot.costo / tot.ingreso) * 100}%`, height: "100%", background: COSTO }} />
                <div style={{ width: `${Math.max(0, tot.ganancia) / tot.ingreso * 100}%`, height: "100%", background: GANANCIA }} />
              </>
            )}
          </div>
        </div>
        <div style={{ display: "flex", gap: 14, flexWrap: "wrap" }}>
          <Leyenda color={COSTO} label="Costo" />
          <Leyenda color={GANANCIA} label="Ganancia" />
        </div>
      </div>

      {!hayDatos && (
        <div style={{ color: C.textMid, fontSize: 12, marginBottom: 8 }}>
          Las barras se llenan cuando hay tickets en el filtro.
        </div>
      )}

      <div
        role="img"
        aria-label={elegido
          ? `${elegido.detalle}: costo ${$(elegido.costo)}, ganancia ${$(elegido.ganancia)}`
          : "Costo contra ganancia por día"}
        style={{ display: "flex", alignItems: "stretch", gap: 4, height: 168, padding: "8px 0 0" }}
      >
        {serie.map((p) => {
          const hCosto = p.ingreso > 0 ? Math.max(3, (p.costo / max) * 100) : 0;
          const hGan = p.ingreso > 0 ? Math.max(p.ganancia > 0 ? 3 : 0, (Math.max(0, p.ganancia) / max) * 100) : 0;
          const activo = elegido?.key === p.key;
          return (
            <button
              key={p.key}
              type="button"
              aria-pressed={activo}
              aria-label={`${p.detalle}: costo ${$(p.costo)}, ganancia ${$(p.ganancia)}`}
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
                maxWidth: 18,
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
                    height: `${hCosto}%`,
                    background: COSTO,
                    borderRadius: p.ganancia > 0 ? "0" : 5,
                  }}
                />
                <span
                  style={{
                    position: "absolute",
                    left: 0,
                    right: 0,
                    bottom: `${hCosto}%`,
                    height: `${hGan}%`,
                    background: GANANCIA,
                    borderRadius: "5px 5px 0 0",
                  }}
                />
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
              {elegido.esActual ? " · hoy" : ""}
            </div>
            <div style={{ color: C.textMid, fontSize: 13, marginTop: 2 }}>
              {elegido.ingreso > 0
                ? `Venta ${$(elegido.ingreso)} · costo ${$(elegido.costo)} · queda ${$(elegido.ganancia)}`
                : "Sin ventas ese día."}
            </div>
          </div>
          <div style={{
            fontWeight: 800,
            fontSize: 22,
            color: elegido.ingreso > 0 ? GANANCIA : C.textMid,
            fontVariantNumeric: "tabular-nums",
          }}>
            {elegido.ingreso > 0
              ? `${((elegido.ganancia / elegido.ingreso) * 100).toFixed(0)}%`
              : "—"}
          </div>
        </div>
      )}
    </section>
  );
}

function Leyenda({ color, label }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 6, color: C_LIGHT.textMid, fontSize: 12, fontWeight: 700 }}>
      <span style={{ width: 10, height: 10, borderRadius: 2, background: color }} />
      {label}
    </div>
  );
}
