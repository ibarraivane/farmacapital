-- ============================================================================
-- FARMA CAPITAL — EAN que faltaban del lote IMG_5455–5720 (16-ago-2026)
--
-- El primer patch etiquetó 71 EQ- y dio de alta 29 FC- “nuevos”.
-- Varios de esos FC- ya existían como EQ- del ticket Equilibrio (nombre
-- de proveedor). Este script:
--
--   1) Pone el EAN en el EQ- correcto (no toca costo, precio ni stock).
--   2) Quita el EAN del FC- duplicado y lo desactiva.
--
-- No toca: Tiniazol shampoo (≠ suspensión), Pregabalina 28 caps (≠ C/14),
-- Faribrox adulto, Farmiver junior, Figral 50, Oxital-C 1000, Flexiver 15,
-- Meclison gotas, Laritol EX/D, Cirulan solución, Busconet iny.
--
-- Se quedan como altas reales (sin EQ-): Menflixit, Mornin, Ixicrol,
-- Colpradin, Pioglitazona 30 AMSA, Metoclopramida iny AMSA, Pregabalina C/14.
--
-- Idempotente. No va en transacción.
-- ============================================================================

do $fix$
declare
  r record;
  v_eq bigint;
  v_fc bigint;
begin
  for r in
    select * from (values
      -- sku_eq, ean, sku_fc_duplicado (null si el EAN no se cargó en un FC-)
      ('EQ-ULT224',  '7502216803244', null),              -- Telmisartán HCTZ 80/12.5 C/14 Ultra
      ('EQ-BEA403',  '7502209851528', null),              -- Tamsulosina 0.4 C/20 beadvance
      ('EQ-QUI096',  '7501644707506', null),              -- Levonorgestrel/Etinilestradiol C/21
      ('EQ-BIO136',  '7501573904403', null),              -- Lozamir-C crema 30 g
      ('EQ-BEA426',  '7501342804590', null),              -- Óxido de zinc pasta 30 g
      ('EQ-BEA336',  '7501342804583', null),              -- Neomicina/caolín/pectina C/20
      ('EQ-EXA035',  '75049805',      null),              -- Neomicina/polimixina/gramicidina oftálmica 15 mL
      ('EQ-SON220',  '7502001164413', 'FC-01164413'),     -- Clotrimazol óvulo 500 SON'S
      ('EQ-MAV410',  '7502009747205', 'FC-09747205'),     -- Benzocaína gel Maver
      ('EQ-BEA429',  '7501342802565', 'FC-42802565'),     -- Metformina 850 C/30
      ('EQ-AMS463',  '7501349024601', 'FC-49024601'),     -- Butilhioscina 10 mg C/10 AMSA
      ('EQ-ALP0526', '7503004908677', 'FC-04908677'),     -- Clioquinol crema 3% 20 g
      ('EQ-ULT145',  '7502216796843', 'FC-16796843'),     -- Sildenafil 100 C/4 Ultra
      ('EQ-BEA468',  '7506624900908', 'FC-24900908'),     -- Quetiapina 100 C/60
      ('EQ-ULT146',  '7502216796737', 'FC-16796737'),     -- Pioglitazona 15 C/7 Ultra
      ('EQ-LOE096',  '7502211786788', 'FC-11786788'),     -- Viladol/Vidalol Plus 10/500 C/20
      ('EQ-BEA424',  '7501342804408', 'FC-42804408'),     -- Metoprolol 100 C/20
      ('EQ-AMS323',  '7501349021310', 'FC-49021310'),     -- Sertralina 50 AMSA
      ('EQ-AMS370',  '7501349028487', 'FC-49028487'),     -- Pentoxifilina 400 LP C/30
      ('EQ-RAD093',  '7501563380316', 'FC-63380316'),     -- Metronidazol 500 C/30
      ('EQ-AMS503',  '7501349010048', 'FC-49010048'),     -- Sitagliptina 100 C/14
      ('EQ-ULT191',  '7502216797376', 'FC-16797376'),     -- Piroxicam 20 C/20 Ultra
      ('EQ-ALP0410', '7503004908844', 'FC-04908844'),     -- Nistatina susp 24 mL
      ('EQ-SON153',  '7502001164086', 'FC-01164086'),     -- Nysmoson's-V óvulos C/10
      ('EQ-BEA416',  '7501342804385', 'FC-42804385'),     -- Metoclopramida 10 C/20 beadvance
      ('EQ-BRL053',  '7502208892638', 'FC-08892638'),     -- Dirpasid 10 C/20 Bruluagsa
      ('EQ-BEA368',  '7501342803807', 'FC-42803807'),     -- Nifedipino 30 LP C/30
      ('EQ-BEA338',  '7501342803104', 'FC-42803104')      -- Prednisona 5 C/20 beadvance
    ) as t(sku_eq, ean, sku_fc)
  loop
    v_eq := null;
    v_fc := null;

    select id into v_eq from public.productos where sku = r.sku_eq limit 1;
    if v_eq is null then
      raise notice 'NO EXISTE EQ %', r.sku_eq;
      continue;
    end if;

    -- si el EAN vive en el FC- duplicado, soltarlo primero
    if r.sku_fc is not null then
      select id into v_fc from public.productos
       where sku = r.sku_fc and codigo_barras = r.ean
       limit 1;
      if v_fc is not null then
        update public.productos
           set codigo_barras = null,
               activo = false,
               descripcion = coalesce(descripcion,'')
                 || ' · desactivado 2026-08-16: EAN pasado a ' || r.sku_eq
         where id = v_fc;
        raise notice 'FC % desactivado, EAN suelto', r.sku_fc;
      end if;
    end if;

    -- no pisar si otro producto (que no sea el FC de esta fila) ya tiene el EAN
    if exists (
      select 1 from public.productos o
       where o.codigo_barras = r.ean
         and o.sku <> r.sku_eq
         and (r.sku_fc is null or o.sku <> r.sku_fc)
    ) then
      raise notice 'EAN % ya está en otro SKU, salto %', r.ean, r.sku_eq;
      continue;
    end if;

    update public.productos
       set codigo_barras = r.ean
     where id = v_eq
       and coalesce(codigo_barras, '') = '';
    if found then
      raise notice 'EAN % → %', r.ean, r.sku_eq;
    else
      raise notice 'YA TENÍA EAN %', r.sku_eq;
    end if;
  end loop;
end
$fix$;

-- Comprobación
select sku, nombre, codigo_barras, activo, costo, precio, stock
from public.productos
where sku in (
  'EQ-ULT224','EQ-BEA403','EQ-QUI096','EQ-BIO136','EQ-BEA426','EQ-BEA336','EQ-EXA035',
  'EQ-SON220','EQ-MAV410','EQ-BEA429','EQ-AMS463','EQ-ALP0526','EQ-ULT145','EQ-BEA468',
  'EQ-ULT146','EQ-LOE096','EQ-BEA424','EQ-AMS323','EQ-AMS370','EQ-RAD093','EQ-AMS503',
  'EQ-ULT191','EQ-ALP0410','EQ-SON153','EQ-BEA416','EQ-BRL053','EQ-BEA368','EQ-BEA338',
  'FC-01164413','FC-09747205','FC-42802565','FC-49024601','FC-04908677','FC-16796843',
  'FC-24900908','FC-16796737','FC-11786788','FC-42804408','FC-49021310','FC-49028487',
  'FC-63380316','FC-49010048','FC-16797376','FC-04908844','FC-01164086','FC-42804385',
  'FC-08892638','FC-42803807','FC-42803104'
)
order by sku;
