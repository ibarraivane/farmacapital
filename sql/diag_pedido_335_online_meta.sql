-- Diagnóstico: pedido #335 (Mercado Pago FARMACAPITAL-PED-335, $10, 15-sep).
-- Solo lectura. Pegar en Supabase SQL Editor.

select
  p.id,
  p.tipo,
  p.estado,
  p.tipo_entrega,
  p.payment_status,
  p.payment_id,
  p.atendido_por,
  u.nombre as vendedora,
  p.total,
  p.metodo_pago,
  p.created_at,
  p.atendido_at,
  p.delivery_status,
  case
    when (p.estado)::text = 'completado' then 'OK: ya cuenta en Tienda online / metas'
    when (p.estado)::text = 'listo' and coalesce(p.tipo_entrega,'') = 'recoger'
      then 'BUG: surtido pero listo — aplicar patch_online_pickup_meta_vendedora_20260916.sql'
    when (p.estado)::text = 'listo'
      then 'Surtido envío: cuenta en metas tras el patch; completado al entregar'
    when (p.estado)::text = 'pendiente' and lower(coalesce(p.payment_status,'')) = 'approved'
      then 'Pagado en MP pero NO surtido en POS — hay que surtirlo para asignar vendedora'
    when (p.estado)::text = 'pendiente'
      then 'Aún pendiente de pago o surtido'
    when (p.estado)::text = 'cancelado'
      then 'Cancelado — no debe aparecer en ventas'
    else 'Revisar estado manualmente'
  end as diagnostico
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where p.id = 335;
