-- ============================================================================
-- FARMA CAPITAL — Lote fotos ordenadas 3 (86 fotos / 43 pares) 16-ago-2026
--
-- SOLO huecos. No crea productos. No pisa un campo que ya tenga valor.
-- No toca costo, precio, stock ni nombre.
--
-- codigo_barras / presentacion / PA / forma / marca / concentracion /
-- unidades_por_caja  → solo si están vacíos (unidades 0 cuenta como vacío).
-- activo = true.
--
-- 8 EAN nuevos en SKUs que ya existían sin código.
-- El resto de este lote ya tenía EAN (lote 3/4) o el EAN está en OTRO
-- SKU con nombre equivocado: eso no se mueve aquí.
--
-- Fuera a propósito (avisar antes de tocar):
--   FC-09747236 EAN Exaliv pero nombre Bactiver infantil
--   FC-09745522 EAN Galaver sobres pero nombre Treda sobres
--     (EQ-MAV263 es el Galaver real, sin EAN)
--   FC-75713770 EAN Novagon natural pero nombre Metamizol Novag
--   FC-09745027 EAN Galaver 250 mL pero nombre Treda infantil
--   FC-18754259 EAN Supratex pero nombre Levocetirizina Mavi
--   FC-09745560 EAN Bioxover pero nombre Kao-Paver
--   FC-27427392 EAN X-TRID pero nombre ML-PRIM
--     (EQ-GEP049 es el X-Trid real, sin EAN)
--   Raspisons / Plusgel: ya tienen OTRO EAN — no se reemplaza
--   Laritol 10 tab (ticket MAV039): nunca se creó — no se inventa
--
-- Idempotente. No va en transacción.
-- ============================================================================

do $upd$
declare
  r record;
  v_id bigint;
begin
  for r in
    select * from (values
      -- EAN nuevo en SKU que ya existía
      ('EQ-SON233', '7502001165397', 'Caja con 20 tabletas', 'Pancreatina / Extracto de bilis / Dimeticona', 'Tableta', 'SON''S', '130 mg / 50 mg / 40 mg', 20),  -- 0001/0008 Zimeton
      ('EQ-RAM014', '7502227871058', 'Caja con 2 tabletas', 'Sumatriptán', 'Tableta', 'RAAM', '100 mg', 2),  -- 0002 Fermig
      ('FC-52D2A43A', '7502211784029', 'Caja con 30 tabletas', 'Glimepirida', 'Tableta', 'Loeffler', '2 mg', 30),  -- 0005 Zukedib 2 mg
      ('EQ-QUM014', '7502223111202', 'Frasco atomizador 115 mL', 'Lidocaína', 'Solución tópica', 'Quimpharma', '10%', null),  -- 0017 Pharmacaine
      ('EQ-LOE013', '7502211780229', 'Frasco 120 mL', 'Ketotifeno', 'Solución', 'Loeffler', '20 mg / 100 mL', null),  -- 0025 Keraffler
      ('EQ-SAN025', '714908100228', 'Frasco con 60 tabletas', 'Melatonina', 'Tableta', 'Salud Natural', '3 mg', 60),  -- 0031 Revenox
      ('EQ-AMS292', '7501349022485', 'Caja con 7 tabletas', 'Pantoprazol', 'Tableta liberación retardada', 'AMSA', '20 mg', 7),  -- 0033 Pantoprazol
      ('EQ-QUI091', '7501109763986', 'Bolsa 26 g', 'Sulfato de magnesio', 'Polvo', 'Quifa', null, null),  -- 0035 Magsokon
      -- Ya tenían EAN correcto: solo huecos de catálogo
      ('FC-83144302', null, 'Frasco 20 mL', 'Oximetazolina', 'Solución nasal', 'Collins', '0.05%', null),  -- 0004 Collifrin
      ('FC-04908738', null, 'Tubo 35 g', 'Lidocaína', 'Ungüento', 'Alpharma', '5%', null),  -- 0006 Lidocaína
      ('FC-03738879', null, 'Caja con 15 tabletas', 'Amantadina / Clorfenamina / Paracetamol', 'Tableta', 'Wermar', '50 mg / 3 mg / 300 mg', 15),  -- 0007 Rosel-T
      ('FC-24901059', null, 'Caja con 20 tabletas', 'Senósidos A-B', 'Tableta', 'beadvance', '8.6 mg', 20),  -- 0010 Senósidos (marca Novag en BD: no se pisa)
      ('FC-27875568', null, 'Caja con 10 tabletas', 'Fexofenadina', 'Tableta', 'RAAM', '180 mg', 10),  -- 0011 Desrotan
      ('FC-27872123', null, 'Caja con 10 tabletas', 'Cetirizina', 'Tableta', 'RAAM', '10 mg', 10),  -- 0012 Raamcinet
      ('FC-27871416', null, 'Caja con 30 tabletas', 'Difenidol', 'Tableta', 'RAAM', '25 mg', 30),  -- 0014 Raamfen
      ('FC-75723137', null, 'Caja con 20 tabletas', 'Senósidos A-B', 'Tableta', 'Novag', '8.6 mg', 20),  -- 0015 Novakosid
      ('FC-23111387', null, null, 'Dropropizina / Bromhexina', 'Jarabe', 'Quimpharma', '150 mg / 80 mg / 100 mL', null),  -- 0018 Drosequim infantil
      ('FC-73906469', null, 'Frasco 360 mL', 'Bencidamina', 'Solución bucal', 'Biomep', '0.15 g / 100 mL', null),  -- 0019 Biobend
      ('FC-03388008', null, 'Frasco 120 mL', 'Levodropropizina', 'Solución', 'Rayere', '600 mg / 120 mL', null),  -- 0023 Velatuss
      ('FC-09745584', null, 'Frasco 125 mL', 'Lactulosa', 'Jarabe', 'Maver', '10 g / 15 mL', null),  -- 0024 Oppelver
      ('FC-36003621', null, 'Gotero 20 mL', 'Hioscina / Paracetamol', 'Solución', 'Liferpal', '2 mg / 100 mg / mL', null),  -- 0030 Precicol
      ('FC-16803800', null, 'Frasco con 60 cápsulas', 'Omeprazol', 'Cápsula', 'Avivia', '20 mg', 60),  -- 0032 Omeprazol Avivia
      ('FC-82200016', null, 'Frasco con 120 cápsulas', 'Omeprazol', 'Cápsula', 'Solfrán', '20 mg', 120),  -- 0038 Aktyzar
      ('FC-53601339', null, 'Frasco 120 mL', 'Subsalicilato de bismuto', 'Suspensión', 'Daclafin', '1.750 g / 100 mL', null),  -- 0039 Daclafin
      ('FC-75717914', null, 'Frasco 75 mL', 'Neomicina / Caolín / Pectina', 'Suspensión', 'Novag', null, null),  -- 0040 Nineka
      ('FC-01165953', null, 'Caja con 16 cápsulas', 'Nifuroxazida', 'Cápsula', 'SON''S', '400 mg', 16)  -- 0043 Rexurdir
    ) as t(sku, ean, presentacion, pa, forma, marca, conc, upc)
  loop
    v_id := null;
    select id into v_id from public.productos where sku = r.sku limit 1;
    if v_id is null then
      raise notice 'NO EXISTE %', r.sku;
      continue;
    end if;

    if r.ean is not null and exists (
      select 1 from public.productos o
       where o.codigo_barras = r.ean and o.sku <> r.sku
    ) then
      raise notice 'EAN % ya está en otro SKU, no lo pongo en %', r.ean, r.sku;
      r.ean := null;
    end if;

    update public.productos set
      activo              = true,
      codigo_barras       = case
                              when coalesce(codigo_barras,'') = '' and r.ean is not null
                              then r.ean else codigo_barras end,
      presentacion        = coalesce(nullif(presentacion,''), r.presentacion),
      principio_activo    = coalesce(nullif(principio_activo,''), r.pa),
      denominacion_generica = coalesce(nullif(denominacion_generica,''), r.pa),
      forma_farmaceutica  = coalesce(nullif(forma_farmaceutica,''), r.forma),
      marca               = coalesce(nullif(marca,''), r.marca),
      concentracion       = coalesce(nullif(concentracion,''), r.conc),
      unidades_por_caja   = case
                              when unidades_por_caja is null or unidades_por_caja = 0
                              then coalesce(r.upc, unidades_por_caja)
                              else unidades_por_caja end
    where id = v_id;
    raise notice 'ACTUALIZADO %', r.sku;
  end loop;
end
$upd$;


-- Altas omitidas a propósito: no crear SKU sin avisar.


select sku, nombre, codigo_barras, activo, presentacion, principio_activo,
       forma_farmaceutica, marca, concentracion, unidades_por_caja, costo, precio, stock
from public.productos
where sku in (
  'EQ-SON233','EQ-RAM014','FC-52D2A43A','EQ-QUM014','EQ-LOE013','EQ-SAN025',
  'EQ-AMS292','EQ-QUI091','FC-83144302','FC-04908738','FC-03738879',
  'FC-24901059','FC-27875568','FC-27872123','FC-27871416','FC-75723137',
  'FC-23111387','FC-73906469','FC-03388008','FC-09745584','FC-36003621',
  'FC-16803800','FC-82200016','FC-53601339','FC-75717914','FC-01165953'
)
order by sku;
