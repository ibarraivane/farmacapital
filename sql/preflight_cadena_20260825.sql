-- CORRER ANTES del parche de cadena. Solo lee.
--
-- La cadena hace que el próximo corte barra TODO lo que haya desde el último
-- corte vigente. El último es el #17 (Erika, 24-ago 15:19). Si anoche se
-- vendió después de esa hora, ese dinero va a caer completo en el primer
-- corte que se haga hoy, y va a parecer un faltante enorme.
--
-- Esta consulta dice cuánto hay pendiente.

select
  (max(cc.created_at) at time zone 'America/Mexico_City') as ultimo_corte_cdmx,
  (now() at time zone 'America/Mexico_City')              as ahora_cdmx
from public.cortes_caja cc;

-- Lo que quedó sin conciliar desde el último corte:
with rango as (
  select coalesce(
           (select max(created_at) from public.cortes_caja),
           now() - interval '1 day'
         ) as ini
)
select
  count(*)                                                  as pedidos,
  coalesce(sum(p.total), 0)                                 as monto_total,
  coalesce(sum(p.total) filter (where p.metodo_pago = 'efectivo'), 0) as efectivo,
  min(p.created_at at time zone 'America/Mexico_City')      as primera,
  max(p.created_at at time zone 'America/Mexico_City')      as ultima
from public.pedidos p, rango r
where p.estado = 'completado'
  and p.created_at > r.ini;

-- ¿Quién vendió en ese hueco y bajo qué sesión?
select s.id, u.nombre, s.turno, s.fecha, s.estado,
       (s.abierta_at at time zone 'America/Mexico_City') as abierta_cdmx,
       (s.cerrada_at at time zone 'America/Mexico_City') as cerrada_cdmx
from public.caja_sesiones s
join public.usuarios u on u.id = s.empleado_id
where s.abierta_at > (select max(created_at) from public.cortes_caja)
   or s.estado = 'abierta'
order by s.abierta_at;
