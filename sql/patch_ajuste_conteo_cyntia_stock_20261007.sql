-- Conteo físico Cyntia (WhatsApp Team FarmaCap) · 2026-10-07
-- Ajusta stock vía lotes (el trigger resincroniza productos.stock).
-- Idempotente: si la suma de lotes activos ya es el objetivo, no toca.
-- No inventa caducidad (fecha_caducidad null en lote de conteo).
-- Ver LEERME_ajuste_conteo_cyntia_20261007.md

begin;

-- Quifa: la caja física es C/28 (sistema decía C/21)
update public.productos
   set presentacion = 'Caja con 28 tabletas',
       nombre = case
         when nombre ilike '%28%' then nombre
         else regexp_replace(nombre, '21', '28', 'g')
       end
 where sku = 'EQ-QUI096';

-- Nysmoson / Neomicina-Kaolín: ya existen; asegurar EAN y activo
update public.productos
   set codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7502001164086'),
       activo = true
 where sku = 'EQ-SON153';

update public.productos
   set codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501342804583'),
       activo = true
 where sku = 'EQ-BEA336';

-- Maviglin: unificar EAN del ticket Equilibrio (sin cero a la izquierda)
update public.productos
   set codigo_barras = '785118754204',
       activo = true
 where sku = 'EQ-MAI150'
   and (codigo_barras is null
        or btrim(codigo_barras) in ('', '0785118754204', '785118754204'));

do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Conteo físico Cyntia WhatsApp 2026-10-07';
begin
  for r in
    -- A–C: alineado con conteo Cinthia #440 (no bajar Alphalock/Celecoxib;
    -- Amikacina 100≠pila 100+500; Budesonida sí).
    select * from (values
      ('FC-BE76D409', 8),   -- Amcef IM 1 g
      ('FC-D210172A', 2),   -- Ampicilina 1 g AMSA
      ('FC-08496701', 2),   -- Aspirina efervescente C/12
      ('FC-070839',   2),   -- Alliviax Garganta (foto C/6; stock 2)
      ('EQ-AMS147',   8),   -- Ácido alendrónico 10 mg C/30
      ('EQ-AMS458',   3),   -- Ácido alendrónico 70 mg C/4
      ('FL-8509810',  2),   -- Antiflu-Des Pediátrico
      ('FC-369D1689', 2),   -- Beneventol 400 mg C/6
      ('FC-447B30F9', 1),   -- Budesonida 0.250 mg/2 ml
      ('EQ-WER038',   5),   -- Charyn 500 mg C/3
      ('EQ-MAV236',   6),   -- Ideliver Pro Duloxetina 60 mg
      ('FC-49022492', 2),   -- Irbesartán 150 mg C/28 Lgen
      ('FC-42700643', 1),   -- Camber Irbesartán + HCTZ
      ('FC-697EEAD0', 1),   -- Kurtosil
      ('FC-93888302', 1),   -- Kenciclen Doxiciclina
      ('EQ-SER024',   2),   -- Lonixer 125 mg C/10
      ('EQ-QUI096',   3),   -- Quifa C/28
      ('FC-09740435', 4),   -- Laritol 10 mg C/10
      ('FC-09742828', 2),   -- Laritol 10 mg C/20
      ('EQ-SON091',   4),   -- Meclison 50/25 C/20
      ('FC-27427392', 4),   -- ML-Prim C/12
      ('EQ-BEA424',   3),   -- Metoprolol 100 mg C/20
      ('EQ-ALP0628',  2),   -- Alpharma Metamizol C/3 amp
      ('EQ-MAI150',   3),   -- Maviglin C/60
      ('EQ-SON153',   1),   -- Nysmoson's-V (confirmar si hay más)
      ('EQ-EXA045',   2),   -- Neomicina/Polimixina/Bacitracina ung.
      ('EQ-BEA336',   3),   -- Neomicina/Kaolín/Pectina C/20
      ('FC-AEA8C8DA', 1),   -- Namifen 500 mg C/20
      ('EQ-MAV196',   1),   -- Oxatech Olanzapina 10 mg C/14
      ('FC-58207010', 1)    -- Oxital-C 2 g C/10
    ) as t(sku, nuevo_stock)
  loop
    select id, costo into v_pid, v_costo
      from public.productos
     where sku = r.sku
     limit 1;

    if v_pid is null then
      raise notice 'SKIP %: no está en productos (ver altas si aplica)', r.sku;
      continue;
    end if;

    select coalesce(sum(l.cantidad_actual), 0) into v_sum
      from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true);

    if v_sum = r.nuevo_stock then
      raise notice 'OK % ya en %', r.sku, r.nuevo_stock;
      continue;
    end if;

    select l.id into v_lote
      from public.lotes l
     where l.producto_id = v_pid
     order by coalesce(l.activo, true) desc,
              coalesce(l.cantidad_actual, 0) desc,
              l.id desc
     limit 1;

    if v_lote is null then
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        fecha_caducidad, costo_unitario, activo
      ) values (
        v_pid, 'INV-CONTEO-20261007', r.nuevo_stock, r.nuevo_stock,
        null, v_costo, true
      )
      returning id into v_lote;
    else
      update public.lotes
         set cantidad_actual = 0,
             activo = false
       where producto_id = v_pid
         and id <> v_lote
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;

      update public.lotes
         set cantidad_actual = r.nuevo_stock,
             activo = true,
             cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), r.nuevo_stock)
       where id = v_lote;
    end if;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo
    ) values (
      v_pid, 'ajuste', r.nuevo_stock,
      v_motivo || ' · ' || r.sku || ' → ' || r.nuevo_stock
    );

    raise notice 'AJUSTE %: lotes % → %', r.sku, v_sum, r.nuevo_stock;
  end loop;
end $$;

commit;

select p.sku, p.nombre, p.stock, p.presentacion, p.codigo_barras,
       coalesce(sum(l.cantidad_actual) filter (where coalesce(l.activo, true)), 0) as lotes_activos
  from public.productos p
  left join public.lotes l on l.producto_id = p.id
 where p.sku in (
   'FC-BE76D409','FC-D210172A','FC-08496701','FC-070839',
   'EQ-AMS147','EQ-AMS458','FL-8509810','FC-369D1689','FC-447B30F9',
   'EQ-WER038','EQ-MAV236','FC-49022492','FC-42700643',
   'FC-697EEAD0','FC-93888302','EQ-SER024','EQ-QUI096','FC-09740435',
   'FC-09742828','EQ-SON091','FC-27427392','EQ-BEA424','EQ-ALP0628',
   'EQ-MAI150','EQ-SON153','EQ-EXA045','EQ-BEA336','FC-AEA8C8DA',
   'EQ-MAV196','FC-58207010','EQ-AVT201','FC-E6B50AC3','FC-347A49C7'
 )
 group by p.id, p.sku, p.nombre, p.stock, p.presentacion, p.codigo_barras
 order by p.sku;
