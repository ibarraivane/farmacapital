-- Origen de receta capturado en POS al cobrar (analítica consultorio vs externo).
ALTER TABLE public.pedidos
  ADD COLUMN IF NOT EXISTS receta_origen text;

COMMENT ON COLUMN public.pedidos.receta_origen IS 'no_aplica | medico_farmax | medico_externo — registrado en caja al concluir venta';
