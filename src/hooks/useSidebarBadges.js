// Badges contextuales del sidebar: cuenta pendientes por módulo.
// Una sola llamada agrupa todas las queries en paralelo; se refresca cada 60s
// y también on-demand cuando el usuario cambia de módulo (para que el badge
// baje al instante cuando resuelve algo).
import { useCallback, useEffect, useRef, useState } from "react";
import { supabase } from "../supabase";

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
      const [
        { count: bajoStock, error: errBajo },
        { count: porCaducar, error: errCad },
        { count: cortesDif, error: errCortes },
        { count: onlinePend, error: errOnline },
        { data: cofeprisRows, error: errCof },
      ] = await Promise.all([
        supabase.from("productos").select("id", { count: "exact", head: true }).eq("activo", true).lte("stock", 0),
        supabase.from("productos").select("id", { count: "exact", head: true }).eq("activo", true).not("fecha_caducidad", "is", null).lte("fecha_caducidad", limite30),
        supabase.from("cortes_caja").select("id", { count: "exact", head: true }).neq("diferencia", 0),
        supabase
          .from("pedidos")
          .select("id", { count: "exact", head: true })
          .eq("estado", "pendiente")
          .or("tipo.eq.online,and(tipo.is.null,metodo_pago.eq.tarjeta),and(tipo.is.null,metodo_pago.eq.mercadopago)"),
        supabase.from("alertas_legales").select("fecha_vencimiento").eq("activo", true).not("fecha_vencimiento", "is", null).lte("fecha_vencimiento", limite30),
      ]);
      if (errBajo) console.warn("[Badges] bajo stock:", errBajo.message);
      if (errCad) console.warn("[Badges] por caducar:", errCad.message);
      if (errCortes) console.warn("[Badges] cortes con diferencia:", errCortes.message);
      if (errOnline) console.warn("[Badges] pedidos online:", errOnline.message);
      if (errCof) console.warn("[Badges] alertas cofepris:", errCof.message);

      const cofeprisCount = (cofeprisRows || []).length;
      const cofeprisVencidas = (cofeprisRows || []).filter(r => r.fecha_vencimiento && r.fecha_vencimiento < hoyISO).length;

      // El mismo set de productos con stock ≤ 0 alimenta Inventario y Reabasto.
      const nextCounts = {
        pos:   onlinePend ?? 0,
        inv:   bajoStock ?? 0,
        rea:   bajoStock ?? 0,
        lotes: porCaducar ?? 0,
        caja:  cortesDif ?? 0,
        cof:   cofeprisCount,
      };
      // Los críticos (pintan rojo). El resto pinta ámbar.
      const nextCritical = {
        inv:  (bajoStock ?? 0) > 0,
        rea:  (bajoStock ?? 0) > 0,
        caja: (cortesDif ?? 0) > 0,
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
