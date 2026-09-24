-- ============================================================================
-- Rendimiento escritura · 24-sep-2026 · no auditar cambios que son solo `stock`
--
-- Hoy cada cambio en `lotes` dispara trg_sync_productos_stock, que hace UPDATE
-- a productos (stock derivado + updated_at). Ese UPDATE a su vez dispara
-- trg_audit_productos (copia completa de la fila antes y después en
-- audit_log_detallado, que tiene 4 índices y solo crece).
--
-- Esto deja la auditoría de productos igual EXCEPTO cuando lo único que cambia
-- es `stock` y/o `updated_at`: ese cambio ya queda registrado por la auditoría
-- de `lotes` y por movimientos_inventario. Menos escrituras por venta/recepción.
--
-- DECISIÓN DE IVÁN: si COFEPRIS/forense requiere ver el historial de productos.stock
-- fila por fila, NO apliques este archivo (o avísame y lo ajustamos).
--
-- Solo cambia la definición de triggers (no datos). Para revertir:
--   ver bloque REVERTIR al final. Idempotente.
-- ============================================================================

begin;

-- INSERT y DELETE siguen auditándose siempre (trigger original, ya sin UPDATE)
drop trigger if exists trg_audit_productos on public.productos;
create trigger trg_audit_productos
  after insert or delete on public.productos
  for each row execute function public.fn_audit_trigger();

-- UPDATE: solo si cambió algo distinto de stock / updated_at
drop trigger if exists trg_audit_productos_upd on public.productos;
create trigger trg_audit_productos_upd
  after update on public.productos
  for each row
  when ((to_jsonb(old) - 'stock' - 'updated_at') is distinct from (to_jsonb(new) - 'stock' - 'updated_at'))
  execute function public.fn_audit_trigger();

commit;

-- REVERTIR (vuelve a auditar todo UPDATE):
--   drop trigger if exists trg_audit_productos_upd on public.productos;
--   drop trigger if exists trg_audit_productos on public.productos;
--   create trigger trg_audit_productos after insert or update or delete on public.productos
--     for each row execute function public.fn_audit_trigger();
