/**
 * Tras venta POS con receta de médico del consultorio, marca en la cita del día
 * los renglones de medicamentos_prescritos que tienen producto_id y coinciden con el carrito.
 */
export async function marcarMedicamentosRecetaFarmaxSurtidos(supabase, {
  p_session_token,
  fechaCitaLocal,
  telefonoCliente,
  clienteId,
  pedidoId,
  items,
}) {
  if (!p_session_token) return { ok: false, reason: "sin_sesion" };
  if (!items?.length || (!telefonoCliente && !clienteId)) return { ok: false, reason: "sin_datos" };

  const telNorm = String(telefonoCliente || "")
    .replace(/\D/g, "");

  const { data: citas, error } = await supabase
    .from("citas")
    .select("id, medicamentos_prescritos, telefono, cliente_id, confirmada_inicio_at")
    .eq("fecha", fechaCitaLocal)
    .neq("estado", "cancelada")
    .order("id", { ascending: false })
    .limit(40);

  if (error) {
    console.warn("[recetaCitaSync]", error);
    return { ok: false, error };
  }

  const match = (citas || []).find((c) => {
    if (clienteId != null && c.cliente_id != null && Number(c.cliente_id) === Number(clienteId)) return true;
    const ct = String(c.telefono || "").replace(/\D/g, "");
    if (telNorm.length >= 10 && ct === telNorm) return true;
    return false;
  });

  if (!match) return { ok: false, reason: "sin_cita" };

  const raw = match.medicamentos_prescritos;
  let arr = Array.isArray(raw) ? raw : [];
  if (!arr.length) return { ok: false, reason: "sin_medicamentos" };

  const qtyByPid = new Map();
  for (const it of items) {
    const pid = it.producto_id ?? it.id;
    if (pid == null) continue;
    const q = Number(it.qty ?? it.cantidad ?? 1) || 1;
    qtyByPid.set(Number(pid), (qtyByPid.get(Number(pid)) || 0) + q);
  }

  let changed = false;
  const next = arr.map((row) => {
    const pid = row.producto_id != null ? Number(row.producto_id) : null;
    if (pid == null || !qtyByPid.has(pid)) return row;
    if (row.surtido === "externa") return row;
    changed = true;
    return {
      ...row,
      surtido: "farmax",
      pedido_surtido_id: pedidoId,
      cantidad_surtida_caja: qtyByPid.get(pid),
    };
  });

  if (!changed) return { ok: false, reason: "sin_coincidencia" };

  const { data: patchData, error: uErr } = await supabase.rpc("empleado_patch_cita_medicamentos", {
    p_session_token,
    p_cita_id: match.id,
    p_medicamentos: next,
  });

  if (uErr) console.warn("[recetaCitaSync] rpc", uErr);
  if (!uErr && patchData && patchData.success === false) {
    console.warn("[recetaCitaSync]", patchData.error);
  }
  const ok = !uErr && patchData?.success !== false;
  return { ok, citaId: match.id };
}
