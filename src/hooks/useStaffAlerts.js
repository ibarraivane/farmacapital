import { useCallback, useEffect, useRef, useState } from "react";
import { supabase } from "../supabase";
import { esPedidoTiendaWebPendiente } from "../utils/pedidosTiendaWeb";
import {
  buildCitaAlert,
  buildPedidoAlert,
  isStaffAlertSeen,
  isStaffAlertSnoozed,
  markStaffAlertSeen,
  playStaffAlertSound,
  snoozeStaffAlert,
  staffAlertKey,
} from "../utils/staffAlerts";

const POLL_MS = 30 * 1000;
const REPEAT_SOUND_MS = 15 * 1000;

function upsertAlert(list, alert) {
  const idx = list.findIndex((a) => a.key === alert.key);
  if (idx >= 0) {
    const next = [...list];
    next[idx] = { ...next[idx], ...alert };
    return next;
  }
  return [alert, ...list].slice(0, 12);
}

export default function useStaffAlerts({
  enabled = true,
  onNewAlert,
  pushNotif,
} = {}) {
  const [alerts, setAlerts] = useState([]);
  const repeatRef = useRef(null);
  const seenSessionRef = useRef(new Set());

  const enqueue = useCallback(
    (alert, { sound = true, notify = true } = {}) => {
      if (!alert?.key) return;
      if (isStaffAlertSeen(alert.key) || isStaffAlertSnoozed(alert.key)) return;
      if (seenSessionRef.current.has(alert.key)) return;

      seenSessionRef.current.add(alert.key);
      setAlerts((prev) => upsertAlert(prev, { ...alert, receivedAt: Date.now() }));

      if (sound) playStaffAlertSound(alert.type);
      onNewAlert?.(alert);
      if (notify && pushNotif) {
        pushNotif(
          `${alert.icon || "🔔"} ${alert.titulo}`,
          `${alert.subtitulo} — ${alert.detalle}`,
          alert.type === "pedido" ? "/admin/pedidos-online" : "/admin/punto-de-venta"
        );
      }
    },
    [onNewAlert, pushNotif]
  );

  const dismissAlert = useCallback((key) => {
    markStaffAlertSeen(key);
    setAlerts((prev) => prev.filter((a) => a.key !== key));
  }, []);

  const snoozeAlert = useCallback((key, minutes = 2) => {
    snoozeStaffAlert(key, minutes);
    setAlerts((prev) => prev.filter((a) => a.key !== key));
  }, []);

  const attendAlert = useCallback((key) => {
    markStaffAlertSeen(key);
    setAlerts((prev) => prev.filter((a) => a.key !== key));
  }, []);

  const activeAlert = alerts[0] || null;

  useEffect(() => {
    if (!enabled) return undefined;

    const ch = supabase
      .channel(`farmacapital-staff-alerts-${Date.now()}`)
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "pedidos" },
        (payload) => {
          const row = payload.new;
          if (!row || row.estado !== "pendiente" || !esPedidoTiendaWebPendiente(row)) return;
          enqueue(buildPedidoAlert(row));
        }
      )
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "citas" },
        (payload) => {
          const row = payload.new;
          if (!row) return;
          if (row.estado === "cancelada") return;
          enqueue(buildCitaAlert(row));
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(ch);
    };
  }, [enabled, enqueue]);

  useEffect(() => {
    if (!enabled) return undefined;

    const poll = async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      try {
        const hoy = new Date().toISOString().slice(0, 10);
        const desde = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
        const hasta = new Date(Date.now() + 45 * 86400000).toISOString().slice(0, 10);

        const [pedListRes, citaSnap] = await Promise.all([
          supabase.rpc("empleado_listar_pedidos_tienda_web_pendientes", {
            p_session_token: tok,
            p_limit: 8,
          }),
          supabase.rpc("empleado_listar_citas_ventana_pos", {
            p_session_token: tok,
            p_desde: desde,
            p_hasta: hasta,
          }),
        ]);

        const pedRows = Array.isArray(pedListRes?.data) ? pedListRes.data : [];
        pedRows.slice(0, 3).forEach((row) => {
          if (esPedidoTiendaWebPendiente(row)) {
            enqueue(buildPedidoAlert(row), { sound: false, notify: false });
          }
        });

        const citas = Array.isArray(citaSnap?.data) ? citaSnap.data : [];
        citas
          .filter((c) => c.canal === "web" && c.fecha === hoy && c.pago_estado === "pendiente")
          .slice(0, 3)
          .forEach((row) => {
            enqueue(buildCitaAlert(row), { sound: false, notify: false });
          });
      } catch (e) {
        console.warn("[StaffAlerts] poll:", e);
      }
    };

    poll();
    const iv = setInterval(poll, POLL_MS);
    return () => clearInterval(iv);
  }, [enabled, enqueue]);

  useEffect(() => {
    if (!activeAlert || isStaffAlertsMuted()) {
      if (repeatRef.current) clearInterval(repeatRef.current);
      repeatRef.current = null;
      return undefined;
    }
    repeatRef.current = setInterval(() => {
      playStaffAlertSound(activeAlert.type);
    }, REPEAT_SOUND_MS);
    return () => {
      if (repeatRef.current) clearInterval(repeatRef.current);
    };
  }, [activeAlert?.key, activeAlert?.type]);

  return {
    alerts,
    activeAlert,
    dismissAlert,
    snoozeAlert,
    attendAlert,
    enqueue,
  };
}

function isStaffAlertsMuted() {
  try {
    return localStorage.getItem("farmacapital_staff_mute") === "1";
  } catch {
    return false;
  }
}
