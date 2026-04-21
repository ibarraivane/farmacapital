/** Cuenta renglones en medicamentos_prescritos (JSON) por campo surtido. */
export function resumenLineasReceta(citasRows) {
  let farmax = 0;
  let externa = 0;
  let pend = 0;
  let conProductoId = 0;
  for (const c of citasRows || []) {
    const arr = Array.isArray(c.medicamentos_prescritos) ? c.medicamentos_prescritos : [];
    for (const m of arr) {
      if (m.producto_id != null) conProductoId++;
      const s = m.surtido || "pendiente";
      if (s === "farmax") farmax++;
      else if (s === "externa") externa++;
      else pend++;
    }
  }
  return { farmax, externa, pend, conProductoId };
}
