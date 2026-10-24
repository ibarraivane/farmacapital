-- El Surtidor 131164 · Soltrim suspensión 120 ml
--
-- Qué falló:
--   El renglón gris (FC-537179045) tiene el EAN 7501537179045.
--   La caja Bruluart que Rosa escaneó es 7501537102067
--   (7 501537 102067 · Reg. 89701 SSA · frasco 120 ml).
--   La pistola responde «Ese beep no está en este ticket».
--   El nombre sí es el de la caja: Soltrim 40/200 mg/5 ml, 120 ml.
--
-- Esto:
--   Pone el EAN de la caja en el producto y en el renglón gris
--   del folio 131164. No toca precio, costo ni stock.
--   SKU canónico = FC- + últimos 8 del EAN de la caja (FC-537102067).
--   No inventa caducidad. El MMAA se teclea al escanear.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- Después: salir del ticket y volver a abrirlo, escanear la caja.

begin;

update public.productos p
set
  codigo_barras = '7501537102067',
  sku = case
    when p.sku = 'FC-537179045'
     and not exists (
       select 1
       from public.productos o
       where o.sku = 'FC-537102067'
         and o.id <> p.id
     )
    then 'FC-537102067'
    else p.sku
  end,
  presentacion = 'Caja con frasco 120 ml y vaso dosificador de 5 ml',
  descripcion = 'El Surtidor 131164 · Bruluart Soltrim susp 40/200 mg/5 ml 120 ml · EAN caja 7501537102067 · el ticket traía 7501537179045 · 3 × $28.80'
where p.id = 3701
  and (
    p.codigo_barras = '7501537179045'
    or p.sku in ('FC-537179045', 'FC-537102067')
  )
  and coalesce(p.codigo_barras, '') is distinct from '7501537102067';

-- Si el UPDATE de arriba ya corrió, el where no entra. El renglón
-- igual hay que apuntarlo al EAN de la caja.
update public.recepcion_items i
set codigo_escaneado = '7501537102067'
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '131164'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
  and coalesce(i.confirmado, false) = false
  and (
    i.producto_id = 3701
    or regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501537179045'
  )
  and regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g')
      is distinct from '7501537102067';

commit;
