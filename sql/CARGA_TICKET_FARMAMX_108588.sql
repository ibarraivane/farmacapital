-- ============================================================================
-- FARMA CAPITAL — Carga del ticket Farma MX (nota de caja CAICA1CA108588)
--
-- ARCHIVO GENERADO. Se produce con
--   python3 scripts/generar_carga_farmamx.py
--
-- Proveedor: REINVEX INTEGRA S.A. DE C.V. (farmamx), sucursal Central de
-- Abastos Iztapalapa. Fecha del ticket: 08/08/2026.
--
-- Mete al inventario las 81 líneas del ticket con su nombre, costo, lote,
-- caducidad y cantidad. Sin código de barras: eso se completa después con las
-- fotos, y la clave del proveedor queda guardada para poder empatarlas.
--
-- Para cada línea decide sola entre tres caminos:
--
--   · Hay un único producto en el catálogo cuyo nombre empieza igual
--     -> le agrega el lote y le completa el costo si venía en cero.
--   · No hay ninguno   -> lo crea.
--   · Hay varios       -> no toca nada y lo reporta al final, para decidirlo
--                         a mano.
--
-- Ese último caso es a propósito. Este ticket trae seis presentaciones de
-- Gelcavit (HO, Platinum, Q-10, 9M, Mulier, Colors) con costos que van de
-- $42 a $89: adivinar cuál es cuál sería peor que dejarlo pendiente.
--
-- Sobre el costo: el ticket desglosa el IVA aparte, así que el costo que se
-- guarda es el de antes de IVA, igual que en el ticket de Equilibrio. Para los
-- renglones marcados IVATRA16 la salida real de caja fue 16% mayor; el IVA se
-- acredita, por eso no se capitaliza en el costo.
--
-- No va dentro de una transacción, para que un error a la mitad no deshaga lo
-- que ya se cargó. Es idempotente: se puede correr varias veces.
--
-- Al terminar, correr sql/pricing/004_apply_pricing_idempotente.sql.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) El ticket tal como viene
-- ---------------------------------------------------------------------------
create table if not exists public.ticket_farmamx_108588 (
  id             bigserial primary key,
  pagina         integer,
  clave_prov     text not null,
  descripcion    text not null,
  lote           text,
  caducidad      date,
  cantidad       integer not null default 1,
  costo_unitario numeric(12,4),
  descuento      numeric(12,2) not null default 0,
  subtotal       numeric(12,2)
);

create index if not exists ticket_farmamx_108588_prov_idx
  on public.ticket_farmamx_108588 (clave_prov, lote);

truncate public.ticket_farmamx_108588 restart identity;

insert into public.ticket_farmamx_108588
  (pagina, clave_prov, descripcion, lote, caducidad, cantidad,
   costo_unitario, descuento, subtotal)
values
  (1, '506935', 'NORMOGOTERO-SENSIMEDICAL PIEZAS C/1 S/AGUJA', '7033325D', '2030-03-01'::date, 5, 11.53, 0.00, 57.65),
  (1, '301138', 'CINTA-MICROPOROSA-CODIFARMA 2.5 CM X 5 M C/1 BLANCO', '251101-2', '2030-11-01'::date, 1, 9.50, 0.00, 9.50),
  (1, '302174', 'CINTA-MICROPOROSA-CODIFARMA 2.5 CM X 9.1 M C/1 BLANCO', '251101-3', '2030-11-01'::date, 4, 15.21, 0.00, 60.84),
  (1, '506817', 'MEDITEST PRUEBA EMBARAZO C/1', '2510838801', '2028-10-01'::date, 6, 15.18, 0.00, 91.08),
  (1, '301082', 'RINOMAR SOLUCION NASAL C/100 ML', 'RIJ25078', '2028-09-01'::date, 1, 96.55, 9.66, 86.90),
  (1, '307853', 'OMELINA CAPSULAS C/60', 'S26094', '2029-04-01'::date, 1, 74.29, 0.00, 74.29),
  (1, '302947', 'CITRATO MAGNESIO/LECITINA SOYA-NATUREX CAPSULAS C/30', '262440', '2028-04-01'::date, 1, 45.30, 0.00, 45.30),
  (1, '502702', 'PROMEGA-3 CAPSULAS C/60', '0038U', '2029-05-01'::date, 1, 71.60, 0.00, 71.60),
  (1, '502700', 'LA-FEMME CAPSULAS C/30', 'U0377', '2028-04-01'::date, 1, 87.46, 0.00, 87.46),
  (1, '501003', 'GELCAVIT-Q-10 CAPSULAS C/30', '26B668', '2028-02-01'::date, 1, 88.66, 0.00, 88.66),
  (1, '506689', 'LACTIV SOBRES C/6 INFANTIL', '262525', '2028-04-01'::date, 1, 33.65, 0.00, 33.65),
  (1, '501619', 'EUCALIN-MIEL JARABE C/120 ML', '25540582', '2028-12-01'::date, 1, 44.46, 0.00, 44.46),
  (2, '505937', 'PLENIFORM-40 TABLETAS C/30', '26E0001', '2028-11-01'::date, 1, 74.27, 0.00, 74.27),
  (2, '506973', 'LACTIV SOBRES C/6 ADULTO', '262415', '2028-04-01'::date, 1, 40.54, 0.00, 40.54),
  (2, '502465', 'COLAGENO-NATUREX TABLETAS C/60', '256971', '2027-12-01'::date, 1, 41.06, 0.00, 41.06),
  (2, '503270', 'ANIMALIN GOTAS C/30 ML', '255714', '2027-10-01'::date, 1, 22.65, 0.00, 22.65),
  (2, '500995', 'GELCAVIT-9M CAPSULAS C/30', '26C658', '2028-03-01'::date, 1, 66.30, 0.00, 66.30),
  (2, '301721', 'VITA/KID/C JARABE C/240 ML', '26E40105', '2028-01-01'::date, 1, 29.14, 0.00, 29.14),
  (2, '500330', 'DIBENEL CAPSULAS C/30', '26A50040', '2028-04-01'::date, 1, 47.08, 0.00, 47.08),
  (2, '500999', 'GELCAVIT-HO CAPSULAS C/30', '25J662', '2027-09-01'::date, 1, 72.56, 0.00, 72.56),
  (2, '307661', 'HUCIUS CAPSULAS C/30', '26E00193', '2028-01-01'::date, 1, 78.16, 0.00, 78.16),
  (2, '500998', 'GELCAVIT-PLATINUM CAPSULAS C/30', '26A672', '2028-02-01'::date, 1, 71.49, 0.00, 71.49),
  (2, '506967', 'EXZON TABLETAS MASTICABLES C/90', '26D007', '2028-04-01'::date, 1, 77.28, 0.00, 77.28),
  (2, '501002', 'GELCAVIT-MULIER CAPSULAS C/30', '26C694', '2028-04-01'::date, 1, 78.55, 0.00, 78.55),
  (2, '501000', 'GELCAVIT-COLORS CAPSULAS C/30', '26A674', '2028-02-01'::date, 1, 42.43, 0.00, 42.43),
  (2, '302884', 'SOL-SUN CREMA C/50 GR 50-FPS/AH AV', '07026067', '2029-04-01'::date, 2, 48.45, 0.00, 96.90),
  (2, '504851', 'PIOKLEAN SPRAY C/130 ML', '261SP0301', '2029-03-01'::date, 1, 60.85, 0.00, 60.85),
  (2, '502473', 'DIBENEL-MAX CAPSULAS C/30', '26F30810', '2028-03-01'::date, 1, 62.12, 0.00, 62.12),
  (2, '300861', 'FOTOSUN-UV100 CREMA C/125 ML 50-FPS', null, '2028-04-01'::date, 1, 103.89, 0.00, 103.89),
  (3, '302138', 'BIOTINA-NATUREX CAPSULAS C/30', '260021', '2028-01-01'::date, 1, 79.83, 7.98, 71.85),
  (3, '503473', 'LACTIV TABLETAS MASTICABLES C/30 INFANTIL', '260915', '2028-02-01'::date, 1, 28.48, 0.00, 28.48),
  (3, '302906', 'VIZANO CAPSULAS C/30', '26Y01966', '2028-05-01'::date, 1, 41.06, 0.00, 41.06),
  (3, '302907', 'IVERKRAM CAPSULAS C/30', '25A02039', '2027-04-01'::date, 1, 74.02, 7.40, 66.62),
  (3, '300936', 'LADY-FEMM PARCHE C/1', '202602', '2029-02-01'::date, 2, 18.48, 3.70, 33.26),
  (3, '502099', 'ERBITRAX TABLETAS 250 MG C/7', 'R2601829', '2028-02-01'::date, 1, 55.37, 5.54, 49.83),
  (3, '506896', 'VALNAIT CAPSULAS C/30', '26A01381', '2028-04-01'::date, 1, 64.91, 0.00, 64.91),
  (3, '303091', 'PIOJITOS SHAMPOO C/150 GR', 'SP020325', '2027-03-01'::date, 1, 44.95, 13.49, 31.47),
  (3, '301135', 'CINTA-MICROPOROSA-CODIFARMA 1.25 CM X 5 M C/1 BLANCO', '250101-1', '2030-01-01'::date, 5, 4.75, 0.00, 23.75),
  (3, '500311', 'ALI-GOMITAS GOMITAS C/60', '25N50408', '2027-12-01'::date, 1, 62.96, 0.00, 62.96),
  (3, '502046', 'CALAZIN SUSPENSION TOPICA C/180 ML', '260205', '2028-02-01'::date, 2, 36.85, 0.00, 73.70),
  (3, '502376', 'NORAPRED TABLETAS 50 MG C/20', '604203', '2028-04-01'::date, 1, 34.77, 0.00, 34.77),
  (3, '500310', 'ALEVARIN CAPSULAS C/45', '26A01563', '2028-05-01'::date, 1, 68.88, 0.00, 68.88),
  (3, '301546', 'MONTELUKAST-NEOLPHARMA TABLETAS 5 MG C/20', '0925961', '2027-09-01'::date, 1, 41.21, 0.00, 41.21),
  (3, '301516', 'ACEITE/BEBE-JALOMA FRASCO C/120 ML MANZANILLA', '0164389', '2028-06-01'::date, 2, 17.98, 0.00, 35.96),
  (3, '301081', 'HUDICLOR TABLETAS 250 MG C/28', '26141117', '2028-05-01'::date, 1, 104.65, 10.47, 94.19),
  (3, '504790', 'GELCAVIT-GEM CAPSULAS C/30', '25J664', '2027-09-01'::date, 1, 94.83, 0.00, 94.83),
  (3, '300591', 'BIO-CLAP-REPELENTE SPRAY C/60 ML', '0167054', '2028-05-01'::date, 2, 18.00, 5.40, 30.60),
  (4, '303355', 'TAFLAVIX FRASCO C/40', '26540074', '2028-03-01'::date, 1, 90.23, 0.00, 90.23),
  (4, '507495', 'SENLOIR TABLETAS 10 MG C/20', '26140731', '2028-03-01'::date, 1, 34.44, 3.44, 31.00),
  (4, '505399', 'SALUDOL-CORPORAL GEL C/100 GR', '26740135', '2028-06-01'::date, 1, 49.69, 0.00, 49.69),
  (4, '503904', 'ACEITE/BEBE-JALOMA FRASCO C/120 ML', '0165578', '2028-05-01'::date, 2, 17.33, 5.20, 29.46),
  (4, '307574', 'ACEITE/BEBE-JALOMA FRASCO C/120 ML LAVANDA', '0158001', '2028-03-01'::date, 1, 17.98, 0.00, 17.98),
  (4, '307574', 'ACEITE/BEBE-JALOMA FRASCO C/120 ML LAVANDA', '0161683', '2028-06-01'::date, 1, 17.98, 0.00, 17.98),
  (4, '502386', 'GUAXOQUIM JARABE C/140 ML', '26AM34', '2028-01-01'::date, 2, 41.83, 0.00, 83.66),
  (4, '501200', 'LARITOL SOLUCION C/60 ML', '263503', '2028-06-01'::date, 1, 20.67, 0.00, 20.67),
  (4, '302287', 'BELAPIEL/PIERNAS-CANSADAS CREMA C/200 GR', '12026092', '2028-10-01'::date, 1, 53.55, 0.00, 53.55),
  (4, '505289', 'DICLOFENACO/COMPLEJO-B-ULTRA GRAGEAS C/30', '5LM122A', '2027-11-01'::date, 3, 32.74, 0.00, 98.22),
  (4, '302206', 'BELAPIEL/GOLPES CREMA C/75 GR', '06026056', '2028-11-01'::date, 1, 20.40, 0.00, 20.40),
  (4, '307626', 'BROMURO-PINAVERIO-ALPHARMA TABLETAS 100 MG C/14', '0526059', '2028-05-01'::date, 3, 16.88, 0.00, 50.64),
  (4, '303093', 'BELAZIX TABLETAS 5 MG C/10', 'B80046', '2028-03-01'::date, 3, 33.12, 9.94, 89.42),
  (4, '303280', 'MELNOTEX TABLETAS 5 MG C/20', '60705', '2028-03-01'::date, 2, 39.74, 0.00, 79.48),
  (4, '301025', 'MASCARILLA-NEBULIZACION-SENSIMEDICAL BOLSA C/1 CON NEBULIZADOR PEDIATRICA', '2504863004', '2030-04-01'::date, 1, 35.10, 0.00, 35.10),
  (4, '506781', 'CATETER/INTRAVENOSO-SUMITEX PU 24 G X 19 MM C/1 AMARILLO', '3189625E', '2030-04-01'::date, 3, 9.26, 0.00, 27.78),
  (4, '506779', 'CATETER/INTRAVENOSO-SUMITEX PU 20 G X 33 MM C/1 ROSA', '3211825F', '2030-05-01'::date, 3, 9.26, 0.00, 27.78),
  (4, '301136', 'CINTA-MICROPOROSA-CODIFARMA 2.5 CM X 5 M C/1 PIEL', '251102-2', '2030-11-01'::date, 2, 10.45, 0.00, 20.90),
  (5, '301139', 'CINTA-MICROPOROSA-CODIFARMA 1.25 CM X 5 M C/1 PIEL', '251102-1', '2030-11-01'::date, 5, 5.77, 0.00, 28.85),
  (5, '506780', 'CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZUL', '3189325E', '2030-04-01'::date, 3, 9.26, 0.00, 27.78),
  (5, '503320', 'SOLUCION-PISA CS 0.9 C/1000 ML', 'V26Y020', '2028-05-01'::date, 1, 43.71, 0.00, 43.71),
  (5, '503319', 'SOLUCION-PISA CS 0.9 C/500 ML', 'P25T706', '2027-10-01'::date, 2, 35.21, 0.00, 70.42),
  (5, '301565', 'JERINGA-SENSIMEDICAL 60 ML PIVOTE/CONCENTRICO', '2506885808', '2030-06-01'::date, 11, 8.56, 0.00, 94.16),
  (5, '506383', 'JERINGA-SENSIMEDICAL 1 ML 27X13 C/100 INSULINA', '2601973605', '2031-01-01'::date, 1, 152.66, 15.27, 137.39),
  (5, '506385', 'JERINGA-SENSIMEDICAL 3 ML 22X32 C/100 NEGRA', '2506885602', '2030-06-01'::date, 1, 155.00, 15.50, 139.50),
  (5, '503712', 'SOLUCION-PISA CS 0.9 C/250 ML', 'P26F301', '2028-02-01'::date, 2, 30.36, 0.00, 60.72),
  (5, '302168', 'VENDA/STICK 5 CM X 4.5 M C/1 AZUL', '221205-1', '2027-12-01'::date, 1, 25.21, 0.00, 25.21),
  (5, '307658', 'JERINGA-SENSIMEDICAL 20 ML 21X32 C/50 VERDE', '2512962201', '2030-12-13'::date, 1, 204.96, 0.00, 204.96),
  (5, '307657', 'JERINGA-SENSIMEDICAL 10 ML 22X32 C/100 NEGRA', '2504864301', '2030-04-01'::date, 1, 241.72, 24.17, 217.55),
  (5, '300644', 'GUANTE/ESTERIL-PROTEC CLASICO C/100 MEDIANO', '1A12505', '2030-12-01'::date, 1, 160.56, 0.00, 160.56),
  (5, '506389', 'JERINGA-SENSIMEDICAL 5 ML 21X32 C/100 VERDE', '2503853712', '2030-03-01'::date, 1, 164.51, 16.45, 148.06),
  (5, '506388', 'JERINGA-SENSIMEDICAL 3 ML 21X32 C/100 VERDE', '2506885503', '2030-06-06'::date, 1, 155.00, 15.50, 139.50),
  (5, '506386', 'JERINGA-SENSIMEDICAL 5 ML 22X32 C/100 NEGRA', '2504864004', '2030-04-15'::date, 1, 164.51, 16.45, 148.06),
  (6, '504321', 'AGUJA-HIPODERMICA-SENSIMEDICAL 22 G X 32 MM C/1 NEGRO', '2411816005', '2029-11-01'::date, 100, 0.55, 0.00, 55.00);

-- ---------------------------------------------------------------------------
-- 2) Respaldo de lo que se pueda modificar
-- ---------------------------------------------------------------------------
create table if not exists public.productos_backup_farmamx108588 (
  backup_at     timestamptz not null default now(),
  producto_id   bigint primary key,
  sku           text,
  nombre        text,
  costo         numeric(10,2),
  precio        numeric(10,2),
  stock         integer
);

-- ---------------------------------------------------------------------------
-- 3) Carga
-- ---------------------------------------------------------------------------
do $carga$
declare
  r              record;
  v_pid          bigint;
  v_marca        text;
  v_nombre       text;
  v_sku          text;
  v_sufijo       integer;
  v_cand         bigint[];
  v_cols         text;
  v_vals         text;
  v_set          text;
  n_altas        integer := 0;
  n_ligadas      integer := 0;
  n_lotes        integer := 0;
  n_ambiguas     integer := 0;
begin
  for r in select * from public.ticket_farmamx_108588 order by pagina, id loop

    -- --- Marca: la primera palabra larga de la descripción ---
    v_marca := (
      select p from unnest(string_to_array(
               upper(translate(r.descripcion,
                               'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN')), ' ')) p
      where length(p) >= 4 and p ~ '^[A-Z]'
      limit 1
    );

    -- --- ¿Existe ya en el catálogo? ---
    v_cand := '{}';
    if v_marca is not null then
      select array_agg(p.id) into v_cand
      from public.productos p
      where upper(translate(p.nombre, 'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN'))
            like v_marca || '%';
    end if;

    if coalesce(array_length(v_cand, 1), 0) > 1 then
      -- Varios candidatos: no adivinar. Sale en el reporte final.
      n_ambiguas := n_ambiguas + 1;
      continue;
    end if;

    if coalesce(array_length(v_cand, 1), 0) = 1 then
      v_pid := v_cand[1];

      insert into public.productos_backup_farmamx108588
        (producto_id, sku, nombre, costo, precio, stock)
      select p.id, p.sku, p.nombre, p.costo, p.precio, p.stock
      from public.productos p where p.id = v_pid
      on conflict (producto_id) do nothing;

      update public.productos
         set costo  = r.costo_unitario,
             precio = case when coalesce(precio, 0) = 0
                           then ceil(r.costo_unitario * 1.6) else precio end
       where id = v_pid
         and coalesce(costo, 0) = 0;
      if found then
        n_ligadas := n_ligadas + 1;
      end if;
    else
      -- --- Alta nueva, sin código de barras ---
      v_nombre := initcap(lower(r.descripcion));

      v_sku := 'FMX-' || r.clave_prov;
      v_sufijo := 0;
      while exists (select 1 from public.productos where sku = v_sku) loop
        v_sufijo := v_sufijo + 1;
        v_sku := 'FMX-' || r.clave_prov || '-' || v_sufijo;
      end loop;

      insert into public.productos
        (nombre, sku, categoria, tipo, descripcion, costo, precio,
         stock, stock_minimo, activo, requiere_receta)
      values
        (v_nombre, v_sku, 'Medicamentos', 'generico',
         'Ticket Farma MX CAICA1CA108588 · clave de proveedor ' || r.clave_prov
           || ' · ' || r.descripcion || ' · falta código de barras',
         r.costo_unitario, ceil(r.costo_unitario * 1.6),
         0, 1, true, false)
      returning id into v_pid;

      n_altas := n_altas + 1;
    end if;

    -- --- Columnas opcionales: sólo las que existan en este ambiente ---
    v_set := null;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'proveedor') then
      v_set := 'proveedor = ' || quote_literal('FARMA MX (REINVEX INTEGRA)');
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'notas') then
      v_set := concat_ws(', ', v_set,
        'notas = coalesce(nullif(notas, ''''), '
        || quote_literal('Clave proveedor Farma MX: ' || r.clave_prov) || ')');
    end if;
    if v_set is not null then
      execute format('update public.productos set %s where id = %s', v_set, v_pid);
    end if;

    -- --- Lote ---
    if r.lote is not null and not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid and l.numero_lote = r.lote
    ) then
      v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
      v_vals := v_pid || ', ' || quote_literal(r.lote) || ', '
                || greatest(r.cantidad, 1) || ', '
                || coalesce(quote_literal(r.caducidad::text) || '::date', 'null') || ', '
                || coalesce(r.costo_unitario::text, 'null');

      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'cantidad_inicial') then
        v_cols := v_cols || ', cantidad_inicial';
        v_vals := v_vals || ', ' || greatest(r.cantidad, 1);
      end if;
      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'activo') then
        v_cols := v_cols || ', activo';
        v_vals := v_vals || ', true';
      end if;

      execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
      n_lotes := n_lotes + 1;
    end if;

  end loop;

  raise notice 'Productos nuevos creados: %', n_altas;
  raise notice 'Productos existentes a los que se les completó el costo: %', n_ligadas;
  raise notice 'Lotes registrados: %', n_lotes;
  raise notice 'Líneas con varios candidatos, pendientes de decidir: %', n_ambiguas;
end
$carga$;

-- ---------------------------------------------------------------------------
-- 4) Stock = suma de los lotes
-- ---------------------------------------------------------------------------
update public.productos p
set stock = coalesce(t.total, 0)
from (
  select l.producto_id, sum(l.cantidad_actual) as total
  from public.lotes l
  where coalesce(l.activo, true)
  group by l.producto_id
) t
where p.id = t.producto_id
  and p.stock is distinct from coalesce(t.total, 0);

-- ---------------------------------------------------------------------------
-- 5) Las líneas que no se pudieron resolver solas
-- ---------------------------------------------------------------------------
with marca as (
  select
    t.*,
    (select p from unnest(string_to_array(
              upper(translate(t.descripcion,
                              'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN')), ' ')) p
     where length(p) >= 4 and p ~ '^[A-Z]' limit 1) as primera_palabra
  from public.ticket_farmamx_108588 t
)
select
  m.clave_prov,
  m.descripcion,
  m.lote,
  m.costo_unitario,
  count(p.id)                       as candidatos_en_catalogo,
  string_agg(p.sku || ' · ' || p.nombre, ' | ' order by p.nombre) as cuales
from marca m
join public.productos p
  on upper(translate(p.nombre, 'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN'))
     like m.primera_palabra || '%'
group by m.clave_prov, m.descripcion, m.lote, m.costo_unitario
having count(p.id) > 1
order by m.descripcion;

-- ---------------------------------------------------------------------------
-- 6) Resumen
-- ---------------------------------------------------------------------------
select
  (select count(*) from public.ticket_farmamx_108588)                  as lineas_del_ticket,
  (select count(*) from public.productos where sku like 'FMX-%')       as altas_desde_el_ticket,
  (select count(*) from public.productos
    where sku like 'FMX-%' and codigo_barras is null)                  as sin_codigo_de_barras,
  (select count(*) from public.productos)                              as productos_en_total;
