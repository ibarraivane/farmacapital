-- Opcional: marcar pedidos antiguos de checkout web como tipo 'online' (antes no se guardaba).
-- Ejecutar una vez en Supabase si aún hay pendientes sin tipo.

UPDATE public.pedidos
SET tipo = 'online'
WHERE estado = 'pendiente'
  AND (tipo IS NULL OR btrim(tipo) = '')
  AND metodo_pago IN ('tarjeta', 'mercadopago');
