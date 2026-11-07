-- Inyección intramuscular: el público paga $30.
-- Reparto (no es costo de compra; costo sigue en 0):
--   $15 quien aplica · $15 farmacia.
-- Presión y oximetría se quedan en $20 ($10 y $10). No se tocan aquí.
-- Glucosa sigue inactiva, en $40, hasta definir tira y lanceta.
--
-- Correr fuera de hora pico. lock_timeout corto para no trabar la caja.

begin;
set local lock_timeout = '5s';

update public.productos
   set precio = 30
 where sku = 'SERV-INY-IM'
   and tipo = 'servicio'
   and precio is distinct from 30;

commit;
