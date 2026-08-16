-- Auditoría inventario 16-ago-2026
-- Idempotente. No borra productos ni referencias de precio.
-- Ejecutar en Supabase SQL Editor.

begin;

-- 1) Jeringas SensiMedical: el SKU es la PIEZA. Costo de caja invertido.

update public.productos set
  costo = 1.37,
  precio = 3,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FC-22300881'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FC-22300881'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 1.4,
  precio = 3,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FC-22300775'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FC-22300775'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 2.18,
  precio = 4,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FMX-307657'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FMX-307657'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 4.1,
  precio = 7,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FMX-307658'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FMX-307658'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 1.48,
  precio = 3,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FMX-506389'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FMX-506389'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 1.4,
  precio = 3,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FMX-506388'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FMX-506388'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

update public.productos set
  costo = 1.48,
  precio = 3,
  venta_unidad = false,
  precio_unidad = 0,
  price_needs_review = false
where sku = 'FMX-506386'
  and costo > precio and costo > 20;
update public.lotes l set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id and p.sku = 'FMX-506386'
  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;

-- 2) Mercurio óxido de zinc: costo de caja / 50 piezas
update public.productos set
  costo = round(costo / nullif(unidades_por_caja, 0), 2),
  price_needs_review = true
where sku = 'FC-0ACC5B6A'
  and venta_unidad = true
  and coalesce(unidades_por_caja, 0) > 1
  and costo > precio;

-- 3) Familia Aspirina / Alka-Seltzer (se reaplica al final para no pisarla)

-- 4) Aliases de categoría
update public.productos set categoria = 'Botiquín' where categoria = 'Botiquin';
update public.productos set categoria = 'Suplemento' where categoria = 'Suplementos';
update public.productos set categoria = 'Gastro' where categoria = 'Digestivo';
update public.productos set categoria = 'Higiene' where categoria in ('Bebes', 'Bebés');

-- 5) Recategorización por nombre/PA (305 SKUs)
update public.productos set categoria = 'Alergia'
where sku in ('FC-29670370', 'FC-6898B64F', 'FC-27875568', 'FC-08895196', 'FC-27872123', 'EQ-BIO100', 'EQ-QUM043', 'EQ-NOV154')
  and categoria is distinct from 'Alergia';

update public.productos set categoria = 'Analgésico'
where sku in ('FC-CF719C07', 'FC-5C8C9C11', 'FC-3D0F54B7', 'FC-58792792', 'FC-75354321', 'FC-08491074', 'FC-84335531', 'FC-08491096', 'FC-08496701', 'FC-25116810', 'FC-98217659', 'FC-40010538', 'FC-50608272', 'FC-54525051', 'FC-34092301', 'FC-50724298', 'FC-37164713', 'FC-37163266', 'FC-07535494', 'FC-98215099', 'FC-08499818', 'FC-053610', 'FC-070839', 'FC-5181402', 'FC-8491966', 'FC-8281209', 'FC-09747236', 'FC-27427392', 'FC-03738879', 'FC-36003621', 'FC-103521', 'FC-11780359', 'FC-37103354', 'FC-83141929', 'FC-36009661', 'FC-09745539', 'FC-83142308', 'FC-01007656', 'FC-01007663', 'EQ-COL226')
  and categoria is distinct from 'Analgésico';
update public.productos set categoria = 'Analgésico'
where sku in ('EQ-ULT103', 'EQ-VIC030', 'EQ-BRU053', 'EQ-MAV043', 'EQ-AMS160', 'EQ-NOV179', 'FMX-505289')
  and categoria is distinct from 'Analgésico';

update public.productos set categoria = 'Antibiótico'
where sku in ('FC-C721E8D7', 'FC-B25B4654', 'FC-9A4E4C31', 'FC-B18E386A', 'FC-8FB65B79', 'FC-7AF7ACB5', 'FC-E4EFC4C2', 'FC-60F627D5', 'FC-443C330E', 'FC-F3E734A0', 'FC-74A5ABEE', 'FC-2005DD57', 'FC-7AA38F97', 'FC-9538F7D6', 'FC-01B2F362', 'FC-50587FA6', 'FC-B72A6420', 'FC-D9391288', 'FC-41339950', 'FC-A0D320D1', 'FC-022543CD', 'FC-D210172A', 'FC-7F90064A', 'FC-F82A6E4B', 'FC-5F30F9D4', 'FC-516C2E89', 'FC-D06E54FE', 'FC-F22C72BE', 'FC-F48FF7EF', 'FC-974EE5FD', 'FC-0E0A9E42', 'FC-6519183A', 'FC-DDFBABDF', 'FC-F4E9C71F', 'FC-428A228F', 'FC-11294615', 'FC-1FEA2FB7', 'FC-AE5EEDF7', 'FC-F8691496', 'FC-22B18244')
  and categoria is distinct from 'Antibiótico';
update public.productos set categoria = 'Antibiótico'
where sku in ('FC-DB4A39AE', 'FC-63975795', 'FC-26EA40A4', 'FC-9F67BB73', 'FC-00422511', 'FC-C636D8EA', 'FC-2001A890', 'FC-DE106642', 'FC-BE76D409', 'FC-07F04F88', 'FC-E9C38DC4', 'FC-347A49C7', 'FC-54221482', 'EQ-WAN013', 'EQ-MAI055', 'EQ-SON214', 'EQ-SON204', 'EQ-MAI152', 'EQ-RAD093', 'FC-49021570', 'FC-01007250', 'FC-01007199', 'FC-09741043', 'FC-09745140', 'FC-90973703', 'FC-83141875')
  and categoria is distinct from 'Antibiótico';

update public.productos set categoria = 'Antiinflamatorio'
where sku in ('FC-E6B50AC3', 'FC-F7A2CACF', 'FC-01165045', 'EQ-MAV322', 'EQ-RAD082', 'EQ-ULT191', 'EQ-AVT213')
  and categoria is distinct from 'Antiinflamatorio';

update public.productos set categoria = 'Botiquín'
where sku in ('FC-68910034', 'FC-926099D3', 'FC-9A1C64E7')
  and categoria is distinct from 'Botiquín';

update public.productos set categoria = 'Cardiovascular'
where sku in ('FC-A909ABC0', 'FC-E4BE37BE', 'FC-8494226', 'FC-08895042', 'EQ-AMS274', 'EQ-AVT203', 'FC-42803524', 'FC-49028913')
  and categoria is distinct from 'Cardiovascular';

update public.productos set categoria = 'Cuidado personal'
where sku in ('FC-54558682', 'FMX-302884', 'FMX-300861')
  and categoria is distinct from 'Cuidado personal';

update public.productos set categoria = 'Diabetes'
where sku in ('FC-52D2A43A', 'FC-3D0ED22B', 'EQ-ULT146', 'EQ-BEA429', 'FC-49024175')
  and categoria is distinct from 'Diabetes';

update public.productos set categoria = 'Dispositivo médico'
where sku in ('FC-68900134', 'FMX-506935', 'FMX-301138')
  and categoria is distinct from 'Dispositivo médico';

update public.productos set categoria = 'Gastro'
where sku in ('FC-405A75E3', 'FC-9A37D44A', 'FC-95467264', 'FC-08443026', 'FC-70612368', 'FC-84999001', 'FC-88915491', 'FC-92730451', 'FC-40036354', 'FC-8497593', 'FC-08443033', 'FC-002663', 'FC-09745027', 'FC-16803800', 'FC-82200016', 'FC-31405888', 'FC-11788690', 'FC-25300366', 'FC-25300373', 'FC-73902584', 'FC-73909859', 'EQ-MAV415', 'EQ-BEA416', 'EQ-BRL053', 'EQ-MAV387', 'EQ-MAV263', 'EQ-AMS292', 'EQ-SON233', 'FC-01162365', 'FC-49024151')
  and categoria is distinct from 'Gastro';

update public.productos set categoria = 'Herbolario'
where sku in ('FC-00003920', 'FC-21042481', 'FC-52400038', 'FC-45307181', 'FC-62746643', 'FC-62034164', 'FC-3676D5DC', 'FC-5A697CC2', 'FC-DFF99C3F', 'FC-D037156B', 'FC-CB5C11ED', 'FC-578F060C', 'FC-FBD776D2', 'FC-5EF90195', 'FC-47AAF23B', 'FC-9507CD66', 'FC-64560163', 'FC-85278507', 'FC-06910487', 'FC-53601339', 'FC-18752637', 'FMX-501619', 'FMX-505399', 'FC-00001049')
  and categoria is distinct from 'Herbolario';

update public.productos set categoria = 'Hidratación'
where sku in ('FC-40015366')
  and categoria is distinct from 'Hidratación';

update public.productos set categoria = 'Higiene'
where sku in ('FC-16800803', 'FC-89810021', 'FC-43475014', 'FC-56371159', 'EQ-LIF039', 'FMX-303091')
  and categoria is distinct from 'Higiene';

update public.productos set categoria = 'Hipertensión'
where sku in ('FC-4A0245DA', 'FC-82F88FED', 'FC-3B001F9B', 'FC-5885E577', 'FC-53506FA4', 'FC-262F2A30', 'FC-BDB2E087', 'FC-49025844', 'EQ-BEA368', 'EQ-ULT224')
  and categoria is distinct from 'Hipertensión';

update public.productos set categoria = 'Respiratorio'
where sku in ('FC-B4477A00', 'FC-85BDBD3D', 'FC-4C621D07', 'FC-05965071', 'FC-4F737E93', 'FC-69A3C416', 'FC-1FFBB505', 'FC-1DAD5EF1', 'FC-06134531', 'FC-89794961', 'FC-08485316', 'FC-60403681', 'FC-85097661', 'FC-40017100', 'FC-00170941', 'FC-00525451', 'FC-00315021', 'FC-40010712', 'FC-01508201', 'FC-5008473', 'FC-9525015', 'FC-08499702', 'FC-08485408', 'FC-08499689', 'FC-7426449', 'FC-09745560', 'FC-03388008', 'FC-18754259', 'FC-23111387', 'FC-31144302', 'FC-75723830', 'FC-75710465', 'FC-73903260', 'FC-73903246', 'FC-09740268', 'FC-83144302', 'FC-09747168', 'FC-09740657', 'FC-01163232', 'FC-09745393')
  and categoria is distinct from 'Respiratorio';
update public.productos set categoria = 'Respiratorio'
where sku in ('FC-36006042', 'FC-36006028', 'EQ-QUM070', 'EQ-RAD092')
  and categoria is distinct from 'Respiratorio';

update public.productos set categoria = 'Suplemento'
where sku in ('FC-2E79C2D8', 'FC-69200016', 'FC-00204798', 'FC-13071164', 'FC-9890331', 'FC-1041884', 'FC-9741524', 'EQ-RAD096', 'EQ-DEG011', 'FMX-502700', 'FMX-505937', 'FMX-502465', 'FMX-300936', 'FMX-501003', 'FMX-500998', 'FMX-501000')
  and categoria is distinct from 'Suplemento';

update public.productos set categoria = 'Vitaminas'
where sku in ('FC-62746605', 'FC-62746698', 'FC-65095718', 'FC-80596011', 'FC-8062229', 'FC-8421321', 'FC-08421321', 'FC-8505126', 'FC-08344716', 'FC-0287855', 'FC-0211225', 'FMX-500999', 'FMX-302138')
  and categoria is distinct from 'Vitaminas';

-- 6) Precio de venta donde hay costo y el PVP está en cero
update public.productos set
  precio = 17,
  price_needs_review = true
where sku = 'FC-84500546'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;
update public.productos set
  precio = 31,
  price_needs_review = true
where sku = 'FC-28833707'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;
update public.productos set
  precio = 221,
  price_needs_review = true
where sku = 'FC-09741425'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;
update public.productos set
  precio = 47,
  price_needs_review = true
where sku = 'FC-52200809'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;
update public.productos set
  precio = 142,
  price_needs_review = true
where sku = 'FC-49021044'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;
update public.productos set
  precio = 17,
  price_needs_review = true
where sku = 'FC-00001049'
  and coalesce(precio, 0) <= 0.01
  and coalesce(costo, 0) > 0.01;

-- 7) Precio desde referencia de mercado (sin costo)
update public.productos set
  precio = 34,
  price_needs_review = true
where sku = 'FC-31144302'
  and coalesce(precio, 0) <= 0.01;

-- 8) EAN duplicados: se deja el más completo; al sombra se le quita el código
-- colisión distinta: FC-89F00320 Mercurio Arnica vs FC-DFF99C3F
update public.productos set
  codigo_barras = null,
  price_needs_review = true
where sku = 'FC-89F00320'
  and codigo_barras = '3311000003920';

-- colisión distinta: FC-7D1D9857 Acetilsalicilico vs FC-08491074
update public.productos set
  codigo_barras = null,
  price_needs_review = true
where sku = 'FC-7D1D9857'
  and codigo_barras = '7501008491074';

-- sombra de FC-262F2A30 Irbesartan
update public.productos set
  codigo_barras = null,
  activo = false,
  price_needs_review = true
where sku = 'FC-BDB2E087'
  and codigo_barras = '7501349022454'
  and sku is distinct from 'FC-262F2A30';

-- colisión distinta: FC-022543CD Valclan vs FC-5F30F9D4
update public.productos set
  codigo_barras = null,
  price_needs_review = true
where sku = 'FC-022543CD'
  and codigo_barras = '7502009740992';

-- sombra de FC-A455EE80 Cefagen (mismo EAN, misma ficha)
update public.productos set
  codigo_barras = null,
  activo = false,
  price_needs_review = true
where sku = 'FC-443C330E'
  and exists (
    select 1 from public.productos k
    where k.sku = 'FC-A455EE80'
      and k.activo = true
      and k.codigo_barras = '7502009741296'
  );

-- sombra de FC-F3E734A0 Fasiclor
update public.productos set
  codigo_barras = null,
  activo = false,
  price_needs_review = true
where sku = 'FC-9538F7D6'
  and codigo_barras = '7502009741050'
  and sku is distinct from 'FC-F3E734A0';

-- colisión distinta: FC-2E5B7248 Reumatol vs FC-03406600
update public.productos set
  codigo_barras = null,
  price_needs_review = true
where sku = 'FC-2E5B7248'
  and codigo_barras = '7503003406600';

-- colisión distinta: FC-6898B64F Bioerter vs FC-08344747
update public.productos set
  codigo_barras = null,
  price_needs_review = true
where sku = 'FC-6898B64F'
  and codigo_barras = '7503008344747';

-- 9) Códigos de barras recuperables (SKU FC-XXXXXXXX → EAN 7501… si un hermano lo confirma)
-- recuperados por cola de SKU: 0

-- 11) Aspirina / Alka al final (no las pisa otra regla)
update public.productos set categoria = 'Analgésico'
where activo = true and categoria is distinct from 'Analgésico'
  and nombre ~* 'aspirina|cafiaspirina';
update public.productos set categoria = 'Gastro'
where activo = true and categoria is distinct from 'Gastro'
  and nombre ~* 'alka.?seltzer';
update public.productos set categoria = 'Cardiovascular'
where activo = true and categoria is distinct from 'Cardiovascular'
  and nombre ~* 'acetilsalic' and nombre ~* '100\s*mg';

-- 10) EAN conocidos de altas/fotos
-- skip FMX-302884: EAN 7502009749063 ya lo tiene FC-09749063
-- skip FMX-301136: EAN 7506484500546 ya lo tiene FC-84500546

commit;

-- Verificación rápida
select categoria, count(*) from public.productos where activo group by 1 order by 2 desc;
select count(*) filter (where coalesce(precio,0) <= 0.01) as sin_precio,
       count(*) filter (where codigo_barras is null or btrim(codigo_barras)='') as sin_ean
from public.productos where activo;
