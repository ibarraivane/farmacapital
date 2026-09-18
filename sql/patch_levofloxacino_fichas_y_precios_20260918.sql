-- Levofloxacino: fichas cruzadas + PVP por dosis y laboratorio.
--
-- Qué había mal (tienda / POS, 2026-09-18):
--   FC-C721E8D7 AMSA EAN 7501349021419 es 500 mg 7 tab (ticket + GS1),
--   pero el nombre decía solo "Levofloxacino" y la foto era la caja 750 mg.
--   FC-28833707 Beadvance 500 mg 7 tab compartía el mismo PVP $31.
--   FC-52200809 Cina Landsteiner 750 mg ya iba a $47 (correcto vs 500 mg).
--   El buscador partía "Levofloxaci" vs "Levofloxacino" porque el AMSA
--   no tenía la molécula en un nombre largo.
--
-- Idempotente. Supabase → SQL Editor → Run.
-- No inventa caducidad ni stock.

begin;

-- AMSA 500 mg 7 tab (EAN 7501349021419). PVP = ceil(costo × 1.60).
update public.productos
   set nombre = 'AMSA Levofloxacino 500 mg Caja con 7 tabletas',
       marca = 'AMSA',
       principio_activo = 'Levofloxacino',
       denominacion_generica = 'Levofloxacino',
       concentracion = '500 mg',
       presentacion = 'Caja con 7 tabletas',
       forma_farmaceutica = 'Tabletas',
       categoria = 'Antibiótico',
       tipo = 'generico',
       unidades_por_caja = coalesce(nullif(unidades_por_caja, 0), 7),
       precio = case
         when coalesce(costo, 0) > 0.01 then ceil(costo * 1.60)
         else greatest(coalesce(precio, 0), 31)
       end
 where sku = 'FC-C721E8D7'
   and activo is not false;

-- Beadvance 500 mg 7 tab. Mismo recargo; si el costo es otro, el PVP cambia.
update public.productos
   set nombre = 'Beadvance Levofloxacino 500 mg Caja con 7 tabletas',
       marca = 'Beadvance',
       principio_activo = 'Levofloxacino',
       denominacion_generica = 'Levofloxacino',
       concentracion = '500 mg',
       presentacion = 'Caja con 7 tabletas',
       forma_farmaceutica = 'Tabletas',
       categoria = 'Antibiótico',
       tipo = 'generico',
       unidades_por_caja = coalesce(nullif(unidades_por_caja, 0), 7),
       precio = case
         when coalesce(costo, 0) > 0.01 then ceil(costo * 1.60)
         else greatest(coalesce(precio, 0), 31)
       end
 where sku = 'FC-28833707'
   and activo is not false;

-- Cina / Landsteiner 750 mg 7 tab: no puede quedar al PVP del 500 mg.
update public.productos
   set nombre = 'Cina Levofloxacino 750 mg Caja con 7 tabletas Landsteiner',
       marca = 'Landsteiner',
       principio_activo = 'Levofloxacino',
       denominacion_generica = 'Levofloxacino',
       concentracion = '750 mg',
       presentacion = 'Caja con 7 tabletas',
       forma_farmaceutica = 'Tabletas',
       categoria = 'Antibiótico',
       tipo = 'generico',
       unidades_por_caja = coalesce(nullif(unidades_por_caja, 0), 7),
       precio = greatest(
         47,
         case when coalesce(costo, 0) > 0.01 then ceil(costo * 1.60) else 0 end,
         coalesce(precio, 0)
       )
 where sku = 'FC-52200809'
   and activo is not false;

-- Duplicado pobre: Cina mal etiquetada como ciprofloxacino.
update public.productos
   set activo = false
 where sku = 'FC-B25B4654'
   and activo is distinct from false;

commit;

-- Comprobación
select sku, left(nombre, 56) as nombre, marca, concentracion, presentacion,
       principio_activo, costo, precio, stock, activo, codigo_barras
  from public.productos
 where sku in ('FC-C721E8D7', 'FC-28833707', 'FC-52200809', 'FC-B25B4654')
 order by sku;

-- Otras familias: mismo PA + misma forma, distinta mg, mismo PVP o invertido.
-- Revisar a mano antes de tocar.
with base as (
  select
    id, sku, nombre, marca, principio_activo, concentracion, presentacion, forma_farmaceutica,
    precio, costo, stock, activo,
    lower(regexp_replace(
      regexp_replace(coalesce(principio_activo, ''), '\d+([.,]\d+)?\s*(mg|mcg|g|ml)', '', 'gi'),
      '[^a-zA-Záéíóúñü/+ ]', '', 'g'
    )) as pa_clave,
    (regexp_match(lower(coalesce(concentracion, '') || ' ' || coalesce(nombre, '')), '(\d+)\s*mg'))[1]::int as mg
  from public.productos
  where activo is not false
    and coalesce(precio, 0) > 0.01
    and coalesce(principio_activo, '') <> ''
)
select a.sku as sku_menor, left(a.nombre, 40) as nom_menor, a.mg as mg_menor, a.precio as pvp_menor,
       b.sku as sku_mayor, left(b.nombre, 40) as nom_mayor, b.mg as mg_mayor, b.precio as pvp_mayor,
       a.pa_clave
  from base a
  join base b
    on a.pa_clave = b.pa_clave
   and a.pa_clave <> ''
   and a.mg is not null and b.mg is not null
   and b.mg >= a.mg * 1.2
   and a.id < b.id
   and (
     abs(a.precio - b.precio) < 0.51
     or (b.mg > a.mg and b.precio + 0.01 < a.precio)
   )
   and (
     lower(coalesce(a.forma_farmaceutica, '')) like '%' || left(lower(coalesce(b.forma_farmaceutica, '')), 4) || '%'
     or lower(coalesce(b.forma_farmaceutica, '')) like '%' || left(lower(coalesce(a.forma_farmaceutica, '')), 4) || '%'
     or coalesce(a.forma_farmaceutica, '') = ''
     or coalesce(b.forma_farmaceutica, '') = ''
   )
 order by a.pa_clave, a.mg, b.mg;
