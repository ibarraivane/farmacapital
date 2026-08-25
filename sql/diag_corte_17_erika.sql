-- ¿Qué trae el corte 17 (Erika, 24-ago 15:19)? Solo lee.

select id, empleado_id, turno, fecha,
       hora_apertura, hora_cierre,
       fondo_inicial, efectivo_declarado, efectivo_sistema,
       diferencia, total_tarjeta, total_mercadopago, total_spei,
       total_general, contado_por, denominaciones, notas, created_at
from public.cortes_caja
where id = 17;

-- Sesiones de caja de hoy: ¿de dónde salió ese corte?
select s.id, s.empleado_id, u.nombre, s.turno, s.fecha, s.estado,
       (s.abierta_at at time zone 'America/Mexico_City') as abierta_cdmx,
       (s.cerrada_at at time zone 'America/Mexico_City') as cerrada_cdmx,
       s.fondo_contado, s.corte_id
from public.caja_sesiones s
join public.usuarios u on u.id = s.empleado_id
where s.fecha >= ((now() at time zone 'America/Mexico_City')::date - 1)
order by s.abierta_at desc;

-- Ventas de hoy en la ventana del vespertino (15:30 en adelante).
-- Si esto da 0, el corte 17 se guardó vacío.
select count(*) as pedidos,
       coalesce(sum(total), 0) as monto,
       min(created_at at time zone 'America/Mexico_City') as primera,
       max(created_at at time zone 'America/Mexico_City') as ultima
from public.pedidos
where estado = 'completado'
  and (created_at at time zone 'America/Mexico_City')::date
      = (now() at time zone 'America/Mexico_City')::date
  and (created_at at time zone 'America/Mexico_City')::time >= time '15:30';
