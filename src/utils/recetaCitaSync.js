/**
 * Tras venta POS con receta de médico del consultorio, marca en la cita del día
 * los renglones de medicamentos_prescritos que tienen producto_id y coinciden con el carrito.
 */
export async function marcarMedicamentosRecetaFarmaxSurtidos(supabase, {
  fechaCitaLocal,
  telefonoCliente,
  clienteId,
  pedidoId,
  items,
}) {
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

  const { error: uErr } = await supabase
    .from("citas")
    .update({ medicamentos_prescritos: next })
    .eq("id", match.id);

  if (uErr) console.warn("[recetaCitaSync] update", uErr);
  return { ok: !uErr, citaId: match.id };
}
