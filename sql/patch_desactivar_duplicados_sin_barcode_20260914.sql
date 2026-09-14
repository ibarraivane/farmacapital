-- Desactiva fichas pobres SIN EAN que ya existen con código de barras.
-- 22 pares confirmados. No toca Mercurio Árnica (revisar caja).
--
-- Candados:
--   · el SKU pobre sigue activo y sin codigo_barras
--   · el SKU bueno está activo y tiene exactamente ese EAN
--   · NO suma stock (el mismo lote se contó dos veces), salvo Cintapore
--     (FMX-301136 → FC-84500546: el de EAN tiene 0; pasa las 2 piezas)
--   · deja stock 0 y apaga lotes del SKU pobre para que no siga en caducidad
--
-- Idempotente. Correr en Supabase SQL Editor.

begin;

create temporary table _fc_dup_sin_ean (
  sku_pobre text primary key,
  nombre_pobre text,
  sku_bueno text not null,
  ean_bueno text not null,
  pasar_stock boolean not null default false
) on commit drop;

insert into _fc_dup_sin_ean (sku_pobre, nombre_pobre, sku_bueno, ean_bueno, pasar_stock)
values
  ('FC-A0D320D1', 'Amoxicilina 500 mg 12 cápsulas', 'FC-49021570', '7501349021570', false),
  ('FC-022543CD', 'Valclan 500/125 mg 10 tabletas', 'FC-01007199', '7503001007199', false),
  ('FC-7D1D9857', 'Acetilsalicilico 100 mg 30 tabletas', 'FC-42803524', '7501342803524', false),
  ('FC-95779436', 'Ácido acetilsalicílico efervescente 300 mg C/20', 'EQ-ALP0300', '7501384504908', false),
  ('FC-B25B4654', 'Cina (Ciprofloxacino) 750 mg 7 tabletas', 'FC-52200809', '7502225092486', false),
  ('FC-6C2878CF', 'Budenova budesonida 0.125 mg/ml 5 amp × 2 ml', 'EQ-NOV165', '7501075726251', false),
  ('FC-26EA40A4', 'Raamcinet cetirizina 10 mg C/10', 'FC-27872123', '7502227872123', false),
  ('FC-44B6751A', 'LAÜR Adulto solución inyectable C/3', 'EQ-SON264', '7502001166981', false),
  ('FC-1321B34F', 'Hidroxin hidroxizina 10 mg C/30', 'EQ-MAI099', '785120754681', false),
  ('FC-AA7B0686', 'Drosequim Adulto jarabe 300/160 mg 200 ml', 'EQ-QUM070', '7502223111400', false),
  ('FC-926099D3', 'Merthiolate Rojo Kohn 20 ml', 'FC-46601138', '7506346601138', false),
  ('EQ-MAV401', 'Dexpantenol 1 Cma 5% 30 G', 'FC-09749421', '7502009749421', false),
  ('EQ-BRL072-1', 'Lo Bruquin 2 Tab 150/200 Mg', 'EQ-BRL072', '7502208894915', false),
  ('FMX-501619', 'Eucalin-Miel Jarabe C/120 Ml', 'FC-08100013', '714908100013', false),
  ('FMX-502465', 'Colageno-Naturex Tabletas C/60', 'FC-9741524', '7502009741524', false),
  ('FMX-301136', 'Cintapore cinta microporosa piel 2.5 cm x 5 m', 'FC-84500546', '7506484500546', true),
  ('FMX-501000', 'Gelcavit-Colors Capsulas C/30', 'FC-30713547', '7501130713547', false),
  ('FMX-500998', 'Gelcavit-Platinum Capsulas C/30', 'FC-30713851', '7501130713851', false),
  ('FMX-501003', 'Gelcavit-Q-10 Capsulas C/30', 'FC-13071164', '7501130711642', false),
  ('FMX-505937', 'Pleniform-40 Tabletas C/30', 'FC-1041884', '7503181041884', false),
  ('FMX-302947', 'Citrato Magnesio/Lecitina Soya-Naturex Capsulas C/30', 'FC-9892403', '7502259892403', false),
  ('FMX-506935', 'Normogotero-Sensimedical Piezas C/1 S/Aguja', 'FC-22322395', '7506022322395', false);

-- Vista previa (debe dar 22 filas listo_para_desactivar).
select
  d.sku_pobre,
  p.nombre as pobre_nombre,
  p.stock as pobre_stock,
  d.sku_bueno,
  b.nombre as bueno_nombre,
  b.codigo_barras as bueno_ean,
  b.stock as bueno_stock,
  d.pasar_stock,
  case
    when p.id is null then 'pobre_ya_no_existe'
    when p.activo is not true then 'pobre_ya_inactivo'
    when nullif(btrim(p.codigo_barras), '') is not null then 'pobre_ahora_tiene_ean'
    when b.id is null then 'bueno_no_existe'
    when b.activo is not true then 'bueno_inactivo'
    when regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
         <> regexp_replace(d.ean_bueno, '\D', '', 'g') then 'ean_del_bueno_no_cuadra'
    else 'listo_para_desactivar'
  end as estado
from _fc_dup_sin_ean d
left join public.productos p on p.sku = d.sku_pobre
left join public.productos b on b.sku = d.sku_bueno
order by d.sku_pobre;

-- Cintapore: el de EAN tiene 0. Pasa el stock del pobre.
update public.productos b
   set stock = coalesce(b.stock, 0) + coalesce(p.stock, 0)
  from _fc_dup_sin_ean d
  join public.productos p
    on p.sku = d.sku_pobre
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
 where d.pasar_stock
   and b.sku = d.sku_bueno
   and b.activo = true
   and regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
       = regexp_replace(d.ean_bueno, '\D', '', 'g')
   and coalesce(b.stock, 0) = 0;

update public.lotes l
   set activo = false
  from public.productos p
  join _fc_dup_sin_ean d on d.sku_pobre = p.sku
  join public.productos b on b.sku = d.sku_bueno
 where l.producto_id = p.id
   and l.activo = true
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and b.activo = true
   and regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
       = regexp_replace(d.ean_bueno, '\D', '', 'g');

update public.productos p
   set activo = false,
       stock = 0
  from _fc_dup_sin_ean d
  join public.productos b on b.sku = d.sku_bueno
 where p.sku = d.sku_pobre
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and b.activo = true
   and regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
       = regexp_replace(d.ean_bueno, '\D', '', 'g');

-- Verificación: pobres deben quedar inactivos.
select p.sku, p.nombre, p.activo, p.stock, p.codigo_barras
  from public.productos p
  join _fc_dup_sin_ean d on d.sku_pobre = p.sku
 order by p.sku;

commit;
