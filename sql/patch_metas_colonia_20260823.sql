-- Metas de una farmacia de colonia (Chinampac, 2 turnos).
-- Cifras alineadas a lo que ya mueve caja (~$1,300–1,600 efectivo por turno
-- + tarjeta/SPEI): $4,000 el día L–V es “hay que llegar”, no un sueño.
-- Ejecutar TODO en Supabase → SQL Editor → Run.

begin;

insert into public.configuracion (clave, valor) values
  ('meta_matutino_lv',       '2000'),
  ('meta_vespertino_lv',     '2000'),
  ('meta_sabado_matutino',   '2200'),
  ('meta_sabado_vespertino', '2200'),
  ('meta_domingo',           '2800'),
  ('meta_ventas_dia',        '4000'),
  ('meta_ventas_semana',     '27200'),
  ('meta_ventas_mes',        '110000'),
  ('meta_ticket_prom',       '120'),
  ('meta_consultas_dia',     '6'),
  ('meta_consultas_mes',     '120')
on conflict (clave) do update
  set valor = excluded.valor;

commit;
