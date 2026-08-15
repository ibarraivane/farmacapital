-- Silka Medic Gel (FC-00740024)
-- Código real del empaque: 650240007408 (12 dígitos, Genomma Lab)
-- En BD quedó 6502400074024 por error de OCR en ticket FL-080826

begin;

update public.productos p
set
  codigo_barras = '650240007408',
  principio_activo = 'Terbinafina',
  marca = coalesce(nullif(trim(p.marca), ''), 'Silka'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Tubo 15 g'),
  categoria = 'Medicamentos'
where p.sku = 'FC-00740024'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '650240007408'
      and o.id <> p.id
  );

commit;
