import React, { useCallback, useEffect, useMemo, useState } from "react";
import { supabase } from "../../../supabase";
import { C_LIGHT, BRAND } from "../../../constants";
import { $ } from "../../../utils";
import { Box, Btn, Inp, Tag, showToast } from "../../../ui";
import { printServicioTicket } from "../../../utils/servicioTicket";

const CATALOGO_SERVICIOS = [
  { id: "telcel", categoria: "recarga", proveedor: "Telcel", comision: 5, emoji: "📱" },
  { id: "movistar", categoria: "recarga", proveedor: "Movistar", comision: 5, emoji: "📱" },
  { id: "att", categoria: "recarga", proveedor: "AT&T", comision: 5, emoji: "📱" },
  { id: "unefon", categoria: "recarga", proveedor: "Unefon", comision: 5, emoji: "📱" },
  { id: "cfe", categoria: "luz", proveedor: "CFE", comision: 8, emoji: "💡" },
  { id: "telmex", categoria: "telefonia", proveedor: "Telmex", comision: 8, emoji: "☎️" },
  { id: "totalplay", categoria: "telefonia", proveedor: "Totalplay", comision: 8, emoji: "📺" },
  { id: "izzi", categoria: "telefonia", proveedor: "Izzi", comision: 8, emoji: "📺" },
  { id: "sky", categoria: "tv", proveedor: "Sky", comision: 10, emoji: "📡" },
  { id: "agua", categoria: "agua", proveedor: "Agua (local)", comision: 8, emoji: "💧" },
  { id: "gas", categoria: "gas", proveedor: "Gas Natural", comision: 8, emoji: "🔥" },
  { id: "otro", categoria: "otro", proveedor: "Otro servicio", comision: 10, emoji: "📋" },
];

const parseMonto = (s) => {
  const n = parseFloat(String(s || "").replace(/,/g, "").trim());
  return Number.isFinite(n) ? Math.round(n * 100) / 100 : NaN;
};

export async function rpcRegistrarPagoServicio(payload) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) throw new Error("Sesión expirada");
  const { data, error } = await supabase.rpc("registrar_pago_servicio_pos", {
    p_session_token: tok,
    p_proveedor: payload.proveedor,
    p_categoria: payload.categoria,
    p_referencia: payload.referencia || null,
    p_monto_servicio: payload.montoServicio,
    p_comision: payload.comision,
    p_metodo_pago: payload.metodoPago,
    p_liquidado_point: !!payload.liquidadoPoint,
    p_notas: payload.notas || null,
    p_cliente_id: payload.clienteId || null,
  });
  if (error) throw error;
  if (!data?.success) throw new Error(data?.error || "No se pudo registrar");
  return data;
}

export default function PagoServiciosPanel({ onCobrarPoint, isNarrow, refreshToken = 0, config = null }) {
  const C = C_LIGHT;
  const [selId, setSelId] = useState("telcel");
  const [referencia, setReferencia] = useState("");
  const [montoStr, setMontoStr] = useState("");
  const [notas, setNotas] = useState("");
  const [liquidado, setLiquidado] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [historial, setHistorial] = useState([]);
  const [loadHist, setLoadHist] = useState(false);

  const servicio = useMemo(
    () => CATALOGO_SERVICIOS.find((s) => s.id === selId) || CATALOGO_SERVICIOS[0],
    [selId]
  );

  const monto = parseMonto(montoStr);
  const comision = Number(servicio.comision);
  const total = Number.isFinite(monto) && Number.isFinite(comision) ? Math.round((monto + comision) * 100) / 100 : 0;

  const fetchHistorial = useCallback(async () => {
    setLoadHist(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data, error } = tok
        ? await supabase.rpc("empleado_listar_pagos_servicio_dia", { p_session_token: tok, p_limite: 25 })
        : { data: [], error: null };
      if (error) throw error;
      setHistorial(Array.isArray(data) ? data : []);
    } catch (e) {
      console.error(e);
    }
    setLoadHist(false);
  }, []);

  const limpiarForm = () => {
    setReferencia("");
    setMontoStr("");
    setNotas("");
    setLiquidado(false);
  };

  useEffect(() => {
    fetchHistorial();
  }, [fetchHistorial]);

  useEffect(() => {
    if (refreshToken > 0) {
      limpiarForm();
      fetchHistorial();
    }
  }, [refreshToken, fetchHistorial]);

  const resumenDia = useMemo(() => {
    return historial.reduce(
      (acc, row) => {
        acc.ops += 1;
        acc.total += parseFloat(row.total_cobrado || 0);
        acc.comision += parseFloat(row.comision || 0);
        if (row.metodo_pago === "efectivo") acc.efectivo += parseFloat(row.total_cobrado || 0);
        if (row.metodo_pago === "tarjeta") acc.tarjeta += parseFloat(row.total_cobrado || 0);
        return acc;
      },
      { ops: 0, total: 0, comision: 0, efectivo: 0, tarjeta: 0 }
    );
  }, [historial]);

  const validarForm = () => {
    if (!Number.isFinite(monto) || monto <= 0) {
      showToast("Ingresa el monto del servicio o recarga", "error");
      return false;
    }
    if (!Number.isFinite(comision) || comision < 0) {
      showToast("Comisión inválida", "error");
      return false;
    }
    if (!liquidado) {
      showToast("Marca que ya liquidaste el recibo en la terminal Point (Smart Launcher)", "error");
      return false;
    }
    return true;
  };

  const buildPayload = (metodoPago) => ({
    proveedor: servicio.proveedor,
    categoria: servicio.categoria,
    referencia: referencia.trim(),
    montoServicio: monto,
    comision,
    metodoPago,
    liquidadoPoint: liquidado,
    notas: notas.trim() || null,
    total,
  });

  const cobrarEfectivo = async () => {
    if (!validarForm()) return;
    setGuardando(true);
    try {
      const payload = buildPayload("efectivo");
      const data = await rpcRegistrarPagoServicio(payload);
      showToast(`Servicio registrado · ${data.folio} · ${$(data.total_cobrado)}`, "success");
      printServicioTicket({
        ...payload,
        folio: data.folio,
        total: data.total_cobrado,
        comision: data.comision ?? payload.comision,
      }, config);
      limpiarForm();
      fetchHistorial();
    } catch (e) {
      showToast(e?.message || "Error al registrar", "error");
    }
    setGuardando(false);
  };

  const cobrarTarjeta = () => {
    if (!validarForm()) return;
    const folio = `SRV-${Date.now().toString().slice(-8)}`;
    onCobrarPoint?.({ ...buildPayload("tarjeta"), folio });
  };

  return (
    <div>
      <div style={{ background: C.blueDim, border: `1px solid ${C.blue}30`, borderRadius: 10, padding: "12px 16px", marginBottom: 16 }}>
        <div style={{ color: C.blue, fontSize: 13, fontWeight: 700, lineHeight: 1.5 }}>
          <strong>Pago de servicios y recargas.</strong> Aquí solo pones el monto: el recargo ({$(servicio.comision)}) se suma solo. La liquidación del recibo se hace en la terminal Point: menú <strong>Smart Launcher → Pago de servicios</strong> (mismo proveedor y referencia).
        </div>
        <div style={{ color: C.textMid, fontSize: 11, marginTop: 8, lineHeight: 1.45 }}>
          La Point en modo PDV solo cobra tarjeta por API. Para CFE, Telcel, etc. usa Smart Launcher en la misma terminal (puede pedir salir del modo integrado un momento). Sin Prontipagos: la comisión de MP va a Mercado Pago, no se desglosa en FarmaCapital.
        </div>
      </div>

      <div style={{ display: "flex", gap: 10, marginBottom: 16, flexWrap: "wrap" }}>
        {[
          ["Operaciones hoy", resumenDia.ops, C.blue],
          ["Cobrado hoy", $(resumenDia.total), C.green],
          ["Tu comisión hoy", $(resumenDia.comision), C.amber],
        ].map(([lbl, val, col]) => (
          <div key={lbl} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 16px", minWidth: 120 }}>
            <div style={{ color: col, fontWeight: 900, fontSize: isNarrow ? 18 : 22 }}>{val}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>{lbl}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: isNarrow ? "1fr" : "1fr 1fr", gap: 16, alignItems: "start" }}>
        <Box style={{ padding: isNarrow ? 14 : 18 }}>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 14, marginBottom: 12 }}>Nuevo pago de servicio</div>

          <div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 6 }}>SERVICIO</div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginBottom: 14 }}>
            {CATALOGO_SERVICIOS.map((s) => (
              <button
                key={s.id}
                type="button"
                onClick={() => setSelId(s.id)}
                style={{
                  padding: "6px 10px",
                  borderRadius: 8,
                  cursor: "pointer",
                  fontSize: 11,
                  fontWeight: 700,
                  border: `1px solid ${selId === s.id ? BRAND.secondary : C.border}`,
                  background: selId === s.id ? `${BRAND.secondary}18` : C.bg,
                  color: selId === s.id ? BRAND.secondary : C.textMid,
                }}
              >
                {s.emoji} {s.proveedor} +{$(s.comision)}
              </button>
            ))}
          </div>

          <div style={{ marginBottom: 12 }}>
            <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Referencia / teléfono / número de servicio</div>
            <Inp
              value={referencia}
              onChange={(e) => setReferencia(e.target.value)}
              placeholder="Ej. 5512345678, número de servicio CFE..."
              style={{ width: "100%", boxSizing: "border-box" }}
            />
          </div>

          <div style={{ marginBottom: 12 }}>
            <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Monto de la recarga *</div>
            <Inp value={montoStr} onChange={(e) => setMontoStr(e.target.value)} placeholder="100" style={{ width: "100%", boxSizing: "border-box" }} />
          </div>

          <div style={{ background: C.bg, borderRadius: 8, padding: "10px 12px", marginBottom: 12 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
              <span style={{ color: C.textMid, fontSize: 12 }}>Recarga</span>
              <span style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>{Number.isFinite(monto) && monto > 0 ? $(monto) : "—"}</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
              <span style={{ color: C.textMid, fontSize: 12 }}>Recargo {servicio.proveedor} (automático)</span>
              <span style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>+{$(comision)}</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ color: C.textMid, fontSize: 12 }}>Total a cobrar</span>
              <span style={{ color: C.green, fontWeight: 900, fontSize: 20 }}>{$(total)}</span>
            </div>
          </div>

          <div style={{ marginBottom: 12 }}>
            <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Notas (opcional)</div>
            <Inp value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Ej. recarga $100 Telcel" style={{ width: "100%", boxSizing: "border-box" }} />
          </div>

          <label style={{ display: "flex", alignItems: "flex-start", gap: 10, cursor: "pointer", marginBottom: 16, padding: "10px 12px", borderRadius: 8, border: `1px solid ${liquidado ? C.green : C.border}`, background: liquidado ? C.greenDim : C.bg }}>
            <input type="checkbox" checked={liquidado} onChange={(e) => setLiquidado(e.target.checked)} style={{ marginTop: 3 }} />
            <span style={{ color: C.text, fontSize: 12, lineHeight: 1.45 }}>
              Confirmo que <strong>liquidaré / liquidé</strong> este servicio en la Point (Smart Launcher → Pago de servicios → {servicio.proveedor}).
            </span>
          </label>

          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <Btn col={C.green} onClick={cobrarEfectivo} dis={guardando}>
              💵 Efectivo
            </Btn>
            <Btn col={BRAND.secondary} onClick={cobrarTarjeta} dis={guardando}>
              💳 Tarjeta Point
            </Btn>
          </div>
        </Box>

        <Box style={{ padding: isNarrow ? 14 : 18 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>Operaciones de hoy</div>
            <Btn sm ol col={C.textMid} onClick={fetchHistorial} dis={loadHist}>
              ↻
            </Btn>
          </div>
          {!historial.length ? (
            <div style={{ color: C.textMid, padding: 20, textAlign: "center", fontSize: 12 }}>Sin operaciones hoy</div>
          ) : (
            historial.map((row) => (
              <div key={row.id} style={{ borderBottom: `1px solid ${C.border}`, padding: "10px 0" }}>
                <div style={{ display: "flex", justifyContent: "space-between", gap: 8, flexWrap: "wrap" }}>
                  <div>
                    <div style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>{row.proveedor}</div>
                    <div style={{ color: C.textDim, fontSize: 10 }}>{row.folio}{row.referencia ? ` · ${row.referencia}` : ""}</div>
                  </div>
                  <div style={{ textAlign: "right" }}>
                    <div style={{ color: C.green, fontWeight: 800 }}>{$(row.total_cobrado)}</div>
                    <div style={{ color: C.textDim, fontSize: 10 }}>com. {$(row.comision)}</div>
                  </div>
                </div>
                <div style={{ marginTop: 6, display: "flex", gap: 6, flexWrap: "wrap", alignItems: "center" }}>
                  <Tag col={row.metodo_pago === "tarjeta" ? C.blue : C.amber} sm>
                    {row.metodo_pago === "tarjeta" ? "Tarjeta" : "Efectivo"}
                  </Tag>
                  {row.liquidado_point && <Tag col={C.green} sm>Liquidado Point</Tag>}
                  <Btn sm ol col={C.textMid} onClick={() => printServicioTicket(row, config)}>
                    Imprimir
                  </Btn>
                </div>
              </div>
            ))
          )}
        </Box>
      </div>
    </div>
  );
}
