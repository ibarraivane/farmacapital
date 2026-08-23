import React, { useCallback, useEffect, useMemo, useState } from "react";
import { supabase } from "../../../supabase";
import { C_LIGHT, BRAND } from "../../../constants";
import { $ } from "../../../utils";
import { Box, Btn, Inp, Tag, showToast } from "../../../ui";
import { compensacionMpDe, compensacionMpDeFila, CLAVES_SALDO_MP, esMismoDiaMexico, parseSaldoConfig, recargoEsValido, utilidadServicio } from "../../../lib/pagoServicio";
import { rolEsAdmin } from "../../../utils/permissions";
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

export default function PagoServiciosPanel({ onCobrarPoint, isNarrow, refreshToken = 0, usuario = null, config = null }) {
  const C = C_LIGHT;
  const [selId, setSelId] = useState("telcel");
  const [referencia, setReferencia] = useState("");
  const [montoStr, setMontoStr] = useState("");
  const [comisionStr, setComisionStr] = useState("");
  const [notas, setNotas] = useState("");
  const [liquidado, setLiquidado] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [historial, setHistorial] = useState([]);
  const [loadHist, setLoadHist] = useState(false);
  const [saldoMp, setSaldoMp] = useState(() => parseSaldoConfig([]));
  const [saldoStr, setSaldoStr] = useState("");
  const [minimoStr, setMinimoStr] = useState("500");
  const [salvandoSaldo, setSalvandoSaldo] = useState(false);
  const esAdmin = rolEsAdmin(usuario?.rol);

  const servicio = useMemo(
    () => CATALOGO_SERVICIOS.find((s) => s.id === selId) || CATALOGO_SERVICIOS[0],
    [selId]
  );

  useEffect(() => {
    setComisionStr(String(servicio.comision));
  }, [servicio]);

  const monto = parseMonto(montoStr);
  const comision = parseMonto(comisionStr);
  const total = Number.isFinite(monto) && Number.isFinite(comision) ? Math.round((monto + comision) * 100) / 100 : 0;
  const compensacionMp = Number.isFinite(monto) ? compensacionMpDe(monto) : 0;
  const utilidad = Number.isFinite(comision) ? utilidadServicio({ comision, compensacionMp }) : 0;

  const fetchSaldoMp = useCallback(async () => {
    try {
      const { data, error } = await supabase.from("configuracion").select("clave,valor").in("clave", CLAVES_SALDO_MP);
      if (error) throw error;
      const st = parseSaldoConfig(data);
      setSaldoMp(st);
      setSaldoStr(st.configurado ? String(st.saldo) : "");
      setMinimoStr(String(st.minimo));
    } catch (e) {
      console.error(e);
    }
  }, []);

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
    fetchSaldoMp();
  }, [fetchHistorial, fetchSaldoMp]);

  useEffect(() => {
    if (refreshToken > 0) {
      limpiarForm();
      fetchHistorial();
      fetchSaldoMp();
    }
  }, [refreshToken, fetchHistorial, fetchSaldoMp]);

  const historialHoy = useMemo(
    () => historial.filter((row) => !row.created_at || esMismoDiaMexico(row.created_at)),
    [historial]
  );

  const resumenDia = useMemo(() => {
    return historialHoy.reduce(
      (acc, row) => {
        const cobrado = parseFloat(row.total_cobrado || 0);
        const recargo = parseFloat(row.comision || 0);
        const comp = compensacionMpDeFila(row);
        acc.ops += 1;
        acc.total += cobrado;
        acc.comision += recargo;
        acc.compensacionMp += comp;
        acc.utilidad += utilidadServicio({ comision: recargo, compensacionMp: comp });
        if (row.metodo_pago === "efectivo") acc.efectivo += cobrado;
        if (row.metodo_pago === "tarjeta") acc.tarjeta += cobrado;
        return acc;
      },
      { ops: 0, total: 0, comision: 0, compensacionMp: 0, utilidad: 0, efectivo: 0, tarjeta: 0 }
    );
  }, [historialHoy]);

  const validarForm = () => {
    if (!Number.isFinite(monto) || monto <= 0) {
      showToast("Ingresa el monto del servicio o recarga", "error");
      return false;
    }
    if (!recargoEsValido(comision)) {
      setComisionStr(String(servicio.comision));
      showToast(`El recargo de ${servicio.proveedor} es $${servicio.comision}. No se guarda en cero.`, "error");
      return false;
    }
    if (!liquidado) {
      showToast("Marca que ya pagaste la recarga (saldo Mercado Pago o Smart Launcher)", "error");
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
      fetchSaldoMp();
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

  const guardarSaldoAdmin = async () => {
    const saldo = parseMonto(saldoStr);
    const minimo = parseMonto(minimoStr);
    if (!Number.isFinite(saldo) || saldo < 0) {
      showToast("Pon el saldo que ves en la app de Mercado Pago", "error");
      return;
    }
    if (!Number.isFinite(minimo) || minimo < 0) {
      showToast("Mínimo inválido", "error");
      return;
    }
    setSalvandoSaldo(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data, error } = await supabase.rpc("admin_set_saldo_recargas", {
        p_session_token: tok,
        p_saldo: saldo,
        p_minimo: minimo,
      });
      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || "No se pudo guardar");
      showToast(`Saldo de recargas: ${$(saldo)} · aviso desde ${$(minimo)}`, "success");
      fetchSaldoMp();
    } catch (e) {
      showToast(e?.message || "No se pudo guardar el saldo", "error");
    }
    setSalvandoSaldo(false);
  };

  const leerSaldoMercadoPago = async () => {
    setSalvandoSaldo(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const resp = await fetch("/api/payments/mp/balance", { headers: { "x-session-token": tok || "" } });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok || data.available_balance == null) {
        throw new Error(data?.message || "Mercado Pago no deja leer el saldo. Ponlo a mano desde la app.");
      }
      setSaldoStr(String(data.available_balance));
      showToast(`Saldo MP: ${$(data.available_balance)}. Revisa y guarda.`, "info");
    } catch (e) {
      showToast(e?.message || "No se pudo leer Mercado Pago", "error");
    }
    setSalvandoSaldo(false);
  };

  return (
    <div>
      {saldoMp.bajo && (
        <div style={{ background: C.red ? `${C.red}14` : "#fef2f2", border: `1px solid ${C.red || "#dc2626"}40`, borderRadius: 10, padding: "12px 16px", marginBottom: 12 }}>
          <div style={{ color: C.red || "#dc2626", fontSize: 13, fontWeight: 800 }}>Saldo de recargas bajo</div>
          <div style={{ color: C.text, fontSize: 12, marginTop: 4, lineHeight: 1.45 }}>
            Quedan {$(saldoMp.saldo)} en el control de FarmaCapital (mínimo {$(saldoMp.minimo)}). Mercado Pago no avisa: hay que fondear la cuenta o las recargas se apagan.
          </div>
        </div>
      )}
      {esAdmin && (
        <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 10, padding: "12px 16px", marginBottom: 16 }}>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 13, marginBottom: 6 }}>Saldo MP para recargas (solo admin)</div>
          <div style={{ color: C.textDim, fontSize: 11, lineHeight: 1.45, marginBottom: 10 }}>
            MP no manda alerta de saldo bajo. Aquí lo tratamos como inventario: pegas lo que ves en la app, y cada recarga lo va descontando. Aviso cuando baje del mínimo.
          </div>
          <div style={{ display: "grid", gridTemplateColumns: isNarrow ? "1fr" : "1fr 1fr", gap: 10, marginBottom: 10 }}>
            <div>
              <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Saldo actual</div>
              <Inp value={saldoStr} onChange={(e) => setSaldoStr(e.target.value)} placeholder="Lo que ves en MP" style={{ width: "100%", boxSizing: "border-box" }} />
            </div>
            <div>
              <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Avisar si baja de</div>
              <Inp value={minimoStr} onChange={(e) => setMinimoStr(e.target.value)} placeholder="500" style={{ width: "100%", boxSizing: "border-box" }} />
            </div>
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <Btn col={BRAND.secondary} onClick={guardarSaldoAdmin} dis={salvandoSaldo}>Guardar saldo</Btn>
            <Btn ol col={C.textMid} onClick={leerSaldoMercadoPago} dis={salvandoSaldo}>Leer de Mercado Pago</Btn>
          </div>
          {saldoMp.configurado && !saldoMp.bajo && (
            <div style={{ color: C.textDim, fontSize: 11, marginTop: 8 }}>Control actual: {$(saldoMp.saldo)} · aviso en {$(saldoMp.minimo)}</div>
          )}
        </div>
      )}
      <div style={{ background: C.blueDim, border: `1px solid ${C.blue}30`, borderRadius: 10, padding: "12px 16px", marginBottom: 16 }}>
        <div style={{ color: C.blue, fontSize: 13, fontWeight: 700, lineHeight: 1.5 }}>
          <strong>Pago de servicios y recargas.</strong> Primero la recarga en la Point (Smart Launcher → Recargas). Aquí anotas lo que cobraste al cliente (recarga + tu recargo). Prefiere <strong>Efectivo</strong>: con tarjeta, Point se come la ganancia.
        </div>
        <div style={{ color: C.textMid, fontSize: 11, marginTop: 8, lineHeight: 1.45 }}>
          El dinero de la recarga sale de tu <strong>saldo de Mercado Pago</strong>, no del cajón. MP te acredita <strong>1%</strong> en esa misma cuenta (Actividad), no en efectivo. El recargo de ${servicio.comision} que le cobras al cliente sí entra al cajón. Los dos son ganancia; son distintos.
        </div>
      </div>

      <div style={{ display: "flex", gap: 10, marginBottom: 16, flexWrap: "wrap" }}>
        {[
          ["Operaciones hoy", resumenDia.ops, C.blue],
          ["Cobrado hoy", $(resumenDia.total), C.green],
          ["Utilidad hoy", $(resumenDia.utilidad), C.amber],
        ].map(([lbl, val, col]) => (
          <div key={lbl} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 16px", minWidth: 120 }}>
            <div style={{ color: col, fontWeight: 900, fontSize: isNarrow ? 18 : 22 }}>{val}</div>
            <div style={{ color: C.textMid, fontSize: 11 }}>{lbl}</div>
          </div>
        ))}
      </div>
      {resumenDia.ops > 0 && (
        <div style={{ color: C.textDim, fontSize: 11, marginTop: -8, marginBottom: 16, lineHeight: 1.4 }}>
          Utilidad = recargo al cliente {$(resumenDia.comision)} + compensación MP {$(resumenDia.compensacionMp)}. El 1% no está en el cajón.
        </div>
      )}

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
                {s.emoji} {s.proveedor}
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

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 12 }}>
            <div>
              <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Monto servicio *</div>
              <Inp value={montoStr} onChange={(e) => setMontoStr(e.target.value)} placeholder="0.00" style={{ width: "100%", boxSizing: "border-box" }} />
            </div>
            <div>
              <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Tu recargo *</div>
              <Inp
                value={comisionStr}
                onChange={(e) => setComisionStr(e.target.value)}
                onBlur={() => {
                  if (!recargoEsValido(parseMonto(comisionStr))) setComisionStr(String(servicio.comision));
                }}
                placeholder={String(servicio.comision)}
                style={{ width: "100%", boxSizing: "border-box" }}
              />
            </div>
          </div>

          <div style={{ background: C.bg, borderRadius: 8, padding: "10px 12px", marginBottom: 12 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ color: C.textMid, fontSize: 12 }}>Total a cobrar al cliente</span>
              <span style={{ color: C.green, fontWeight: 900, fontSize: 20 }}>{$(total)}</span>
            </div>
            {Number.isFinite(monto) && monto > 0 && (
              <div style={{ color: C.textDim, fontSize: 11, marginTop: 8, lineHeight: 1.45 }}>
                Recargo farmacia {$(Number.isFinite(comision) ? comision : 0)} (cajón) + compensación MP {$(compensacionMp)} (saldo MP) = utilidad {$(utilidad)}. El 1% no lo cobras tú: lo acredita Mercado Pago.
              </div>
            )}
          </div>

          <div style={{ marginBottom: 12 }}>
            <div style={{ color: C.textMid, fontSize: 11, marginBottom: 4 }}>Notas (opcional)</div>
            <Inp value={notas} onChange={(e) => setNotas(e.target.value)} placeholder="Ej. recarga $100 Telcel" style={{ width: "100%", boxSizing: "border-box" }} />
          </div>

          <label style={{ display: "flex", alignItems: "flex-start", gap: 10, cursor: "pointer", marginBottom: 16, padding: "10px 12px", borderRadius: 8, border: `1px solid ${liquidado ? C.green : C.border}`, background: liquidado ? C.greenDim : C.bg }}>
            <input type="checkbox" checked={liquidado} onChange={(e) => setLiquidado(e.target.checked)} style={{ marginTop: 3 }} />
            <span style={{ color: C.text, fontSize: 12, lineHeight: 1.45 }}>
              Confirmo que <strong>ya pagué</strong> esta recarga / servicio (saldo de Mercado Pago o Smart Launcher → {servicio.proveedor}).
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
          <div style={{ color: C.textDim, fontSize: 11, marginTop: 8, lineHeight: 1.4 }}>
            Tarjeta Point cobra comisión sobre recarga + recargo. En CFE u otros montos grandes se pierde dinero. Prefiere efectivo.
          </div>
        </Box>

        <Box style={{ padding: isNarrow ? 14 : 18 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>Operaciones de hoy</div>
            <Btn sm ol col={C.textMid} onClick={fetchHistorial} dis={loadHist}>
              ↻
            </Btn>
          </div>
          {!historialHoy.length ? (
            <div style={{ color: C.textMid, padding: 20, textAlign: "center", fontSize: 12 }}>Sin operaciones hoy</div>
          ) : (
            historialHoy.map((row) => (
              <div key={row.id} style={{ borderBottom: `1px solid ${C.border}`, padding: "10px 0" }}>
                <div style={{ display: "flex", justifyContent: "space-between", gap: 8, flexWrap: "wrap" }}>
                  <div>
                    <div style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>{row.proveedor}</div>
                    <div style={{ color: C.textDim, fontSize: 10 }}>{row.folio}{row.referencia ? ` · ${row.referencia}` : ""}</div>
                  </div>
                  <div style={{ textAlign: "right" }}>
                    <div style={{ color: C.green, fontWeight: 800 }}>{$(row.total_cobrado)}</div>
                    <div style={{ color: C.textDim, fontSize: 10 }}>
                      recargo {$(row.comision)} · MP {$(compensacionMpDeFila(row))}
                    </div>
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
