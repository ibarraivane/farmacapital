-- ============================================================================
-- FARMACAPITAL — Medik8 / Dermatotec lista especialistas 2025
-- costo  = precio venta al médico / especialistas c/IVA
-- precio = RRP / precio al público c/IVA (por ahora)
-- Bajo pedido. Sin EAN en la lista → match por SKU estable.
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- Orden: 03_staging → 03a_filas_* → 03b_aplicar
-- ============================================================================

begin;

create table if not exists public._fc_medik8_stg (
  sku text primary key,
  nombre text not null,
  nombre_lista text,
  descripcion text,
  presentacion text,
  gama text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null
);

truncate public._fc_medik8_stg;

commit;
