// Badges contextuales del sidebar: cuenta pendientes por módulo.
// Una sola llamada agrupa todas las queries en paralelo; se refresca cada 60s
// y también on-demand cuando el usuario cambia de módulo (para que el badge
// baje al instante cuando resuelve algo).
import { useCallback, useEffect, useRef, useState } from "react";
import { supabase } from "../supabase";
import { countPedidosTiendaPendientesHead } from "../utils/pedidosTiendaWeb";

const REFRESH_MS = 60 * 1000;

function addDaysISO(days) {
  return new Date(Date.now() + days * 86400000).toISOString().slice(0, 10);
}

export default function useSidebarBadges(currentPage) {
  const [counts, setCounts] = useState({});
  const [critical, setCritical] = useState({});
  const [loading, setLoading] = useState(false);
  const timerRef = useRef(null);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const hoyISO = new Date().toISOString().slice(0, 10);
    const limite30 = addDaysISO(30);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const cofeprisRpc = tok
        ? supabase.rpc("admin_alertas_cofepris_ventana", {
            p_session_token: tok,
            p_limite: limite30,
            p_hoy: hoyISO,
          })
        : Promise.resolve({ data: null, error: null });

      const cortesRpc = tok
        ? supabase.rpc("empleado_contar_cortes_con_diferencia", { p_session_token: tok })
        : Promise.resolve({ data: 0, error: null });

      const [
        { count: bajoStock, error: errBajo },
        cortesRes,
        { count: onlinePend, error: errOnline },
        { data: cofeprisVentana, error: errCof },
      ] = await Promise.all([
        supabase.from("productos").select("id", { count: "exact", head: true }).eq("activo", true).lte("stock", 0),
        cortesRpc,
        countPedidosTiendaPendientesHead(supabase, tok),
        cofeprisRpc,
      ]);
      const cortesDif = Number(cortesRes?.data);
      const errCortes = cortesRes?.error;
      if (errBajo) console.warn("[Badges] bajo stock:", errBajo.message);
      if (errCortes) console.warn("[Badges] cortes con diferencia:", errCortes.message);
      if (errOnline) console.warn("[Badges] pedidos online:", errOnline.message);
      if (errCof) console.warn("[Badges] alertas cofepris:", errCof.message);

      const cofeprisCount = Number(cofeprisVentana?.total_ventana) || 0;
      const cofeprisVencidas = Number(cofeprisVentana?.vencidas) || 0;

      // El badge de inv consolidó Reabasto y Lotes PEPS en tabs. Solo mostramos
      // el crítico (bajo stock) en el sidebar — por caducar sigue visible en la
      // tab Lotes y en "Lo que necesitas hacer hoy" del dashboard.
      const pend = onlinePend ?? 0;
      const nextCounts = {
        pos:  pend,
        ped_online: pend,
        inv:  bajoStock ?? 0,
        caja: Number.isFinite(cortesDif) ? cortesDif : 0,
        cof:  cofeprisCount,
      };
      const nextCritical = {
        inv:  (bajoStock ?? 0) > 0,
        caja: (Number.isFinite(cortesDif) ? cortesDif : 0) > 0,
        cof:  cofeprisVencidas > 0,
      };
      setCounts(nextCounts);
      setCritical(nextCritical);
    } catch (e) {
      console.warn("[Badges] fetchAll error:", e?.message || e);
    } finally {
      setLoading(false);
    }
  }, []);

  // Primer fetch + refresco periódico.
  useEffect(() => {
    fetchAll();
    timerRef.current = setInterval(fetchAll, REFRESH_MS);
    return () => { if (timerRef.current) clearInterval(timerRef.current); };
  }, [fetchAll]);

  // Al cambiar de módulo, refrescar con un pequeño delay (permite que la escritura
  // del módulo anterior concluya antes de releer).
  useEffect(() => {
    if (currentPage === undefined) return;
    const t = setTimeout(fetchAll, 600);
    return () => clearTimeout(t);
  }, [currentPage, fetchAll]);

  return { counts, critical, loading, refresh: fetchAll };
}
