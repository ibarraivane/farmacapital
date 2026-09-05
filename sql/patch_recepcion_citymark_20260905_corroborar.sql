-- Pedido City Mark 20260905 (2026-09-05) — cola Recibir, borrador.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '20260905' and coalesce(proveedor, '') ilike '%city mark%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion City Mark 20260905 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('City Mark', '20260905', '2026-09-05', 5007.41, 'borrador',
              'Pedido City Mark 20260905 · ticket PUBLICO EN GENERAL · EAN del ticket · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 5007.41, fecha = '2026-09-05', proveedor = 'City Mark', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7891010245160', 'NEUTROGENA 200ML AGUA MICELAR C6 SEP26', 2, 45.890::numeric, null),
        ('761318132592', 'PEINES REVLON SALON CARBON 2PK', 1, 44.950, null),
        ('761318128335', 'CEP REVLON MOD PALETA RV2833LA', 1, 45.520, null),
        ('761318020639', 'CEP REVLON ACOLCHMGO GOMARV2063LA', 1, 45.820, null),
        ('7502221187575', 'DESOD BRUT DEEPBLUE 48HR SPY150ML', 2, 45.915, null),
        ('7506306215511', 'DESOD SAVILE SAB-NAC NAT SPY 150ML', 1, 38.960, null),
        ('7506306215528', 'DEO SAVILE B-SOD Y LIM SPY150ML', 1, 38.950, null),
        ('7506306209763', 'DESOD SAVILE MANZANILLA SPY 150ML', 1, 38.950, null),
        ('75065102', 'DESOD SAVILE MANZANILLA STICK 45G', 1, 38.650, null),
        ('75068639', 'DESOD SAVILE B-SOD Y LIM STICK45G', 1, 38.650, null),
        ('75068622', 'DESOD SAVILE B-SOD Y LIM R-ON45ML ABRIL27', 1, 24.560, null),
        ('75064891', 'DESOD SAVILE AGUA/ROSA R-ON 45ML MAR27', 1, 27.990, null),
        ('7501082736021', 'DEO NUVEL ACLA WOM SPY150ML', 2, 35.450, null),
        ('7506309864839', 'DESOD GTTE END COOL SPY150ML', 1, 55.380, null),
        ('7501027286000', 'DESOD OBAO OCEAN R-ON 65G', 1, 25.830, null),
        ('7506309864822', 'DESOD GTTE ENDURARTICIC SP 150', 1, 55.580, null),
        ('7501027286017', 'DESOD OBAO CLAS R-ON 65G', 1, 29.550, null),
        ('7501082731071', 'DESOD NUVEL TROPIC WOM SPY 170 ML', 2, 32.725, null),
        ('7506306251847', 'DESOD AXE BLACK REMIX SPY 210 ML', 3, 68.730, null),
        ('7509546029139', 'DESOD SPEED S 24/7COOL-NIG STIK 85G', 2, 55.340, null),
        ('7500435141796', 'DESOD OLD SPICE MAR PROF SPY 150ML', 1, 61.740, null),
        ('7509552906158', 'DESOD OBAO FRESQUISSIMA R-ON 65G', 1, 26.090, null),
        ('7509552844825', 'DESOD OBAO R-NAT COCO R-ON 65G', 1, 24.950, null),
        ('7509546071275', 'DESOD LADYSS POWDER FRESH SPY 60G FEB27', 3, 29.487, null),
        ('78924338', 'DESOD REXONA WOM POW R-ON 53G', 2, 30.120, null),
        ('7506306226852', 'DESOD AXE WOM ANARCHY SPY 150ML', 2, 45.830, null),
        ('7500435129367', 'DESOD SECRET PH-BALAN STICK GEL 45G', 1, 60.470, null),
        ('7506306209862', 'DESOD AXE SPY 150ML 48H ANARCHY FRESH LOVE FOR HER', 1, 45.830, null),
        ('7791293025919', 'DESOD AXE EXCITE SECO SPY 152ML', 1, 62.830, null),
        ('7509546057545', 'DESOD LADYSS PRO 5EN1 STICK 45G ABRIL27', 1, 49.590, null),
        ('7509546015514', 'DESOD LADYSS D-DEF A-FSH 45G', 1, 50.780, null),
        ('7506306209855', 'DESOD AXE ANARC FLO 48H SPY 150ML', 1, 45.830, null),
        ('7509546029153', 'DESOD LADYSS FLORAL FRESH GEL 65GN', 1, 53.300, null),
        ('78924345', 'DESOD REXONA WOM BAMBOO R-ON 50ML', 2, 30.125, null),
        ('7509546060477', 'DESOD LADYSS POW DER FRES R-ON 50ML', 3, 29.163, null),
        ('7506339349146', 'DESOD OLD SPICE WOLFTHORN SPY 150ML', 1, 56.990, null),
        ('7501027250612', 'DESOD OBAO P/DEL R-ON 65G', 1, 25.830, null),
        ('7501082790481', 'TAS DESMAQ NUVEL HIDRATANTES C25', 1, 25.020, null),
        ('7502221012303', 'TAS HUM CLARIS DESMAQ ALOE C/40', 1, 18.860, null),
        ('7509546029825', 'DESOD NEUTRO B R-ON 65 ML', 3, 28.183, null),
        ('7501022107201', 'SH PERRO CONSE ANTI OLORES 500ML', 1, 72.420, null),
        ('7509546007083', 'C D COLGATE TOTAL12 CLEAN MINT 50ML', 1, 19.290, null),
        ('037836007279', 'SH PERRO CONSE GUAU ALOE VERA 400ML', 1, 45.670, null),
        ('037836084508', 'SH GRISI PERRO AGRADE AVENA 400ML', 1, 74.540, null),
        ('759684900204', 'AGUA JALOMA ROSAS TOC FAC 250ML', 2, 33.095, null),
        ('7509546651743', 'DESOD STEFANO TRIUMPH 159 ML', 1, 60.490, null),
        ('7501056330378', 'LOC LIMP PONDS BIO-HYDRA DUAL 200ML', 2, 88.790, null),
        ('759684900259', 'JALOMA AGUA DE ARROZ 250ML SPRAY C24 PZS', 1, 37.500, null),
        ('814266022627', 'SH HONEYKEEPER KIDS LAVANDA 3EN1 414ML', 1, 80.860, null),
        ('7509546694702', 'DESOD STEFANO NEXT LEVEL SPY150MLN', 1, 60.490, null),
        ('7509546073774', 'DESOD STEFANO SPAZ SPY 113G', 1, 60.490, null),
        ('7509546078434', 'DESOD STEFANO ALP MEN SPY 113G', 1, 60.490, null),
        ('7506267917516', 'CRA HK KIDS OAT 414ML', 1, 85.420, null),
        ('7509546655055', 'MOUSSE CAPRICE VOLUM-CTRL 200 G', 1, 50.510, null),
        ('3600542478359', 'AGUA MIC GARNIER JELLY CARB 400ML', 1, 115.390, null),
        ('7501035911024', 'C D COLGATE MFP 125ML', 2, 49.155, null),
        ('7509546068909', 'C D COLG TRIPL-ACC EXTBL 50ML', 2, 13.525, null),
        ('7506425629442', 'ESCUDO SOL ANTISEP P/MAN SPY 200ML ENE27', 2, 43.785, null),
        ('7702018913954', 'DESOD GTTE 3X CL WAVE R-ON 60G OCT26', 2, 36.495, null),
        ('7500435168991', 'MOUSSE HERBAL ESS EXTR CONT 200G', 1, 67.000, null),
        ('7509546698137', 'C D COLGATE LUMIN W COHIT BRILL 66MLN', 2, 42.805, null),
        ('78926523', 'DESOD REXONA WOM AEMOT R-ON 50G', 1, 30.130, null),
        ('7509546674018', 'C D COLGATE LUMIN WHIT CARBON 66ML', 2, 42.815, null),
        ('7509546000350', 'C D COLGATE TRIPLE ACC 150ML FEB27', 2, 30.000, null),
        ('7509546654997', 'MOUSSE CAPRICE FINAL TOUCH 200 G', 1, 50.510, null),
        ('814266022610', 'SH HK KIDS HONEY', 1, 80.860, null),
        ('7500435169035', 'MOUSSE HERBAL ESS RIZO 200G', 1, 57.900, null),
        ('7891024028827', 'ENJ BUC COLGATE TOTAL12 CLEAN 60ML', 2, 13.385, null),
        ('3616303440534', 'ADIDAS 150ML SPY CONTROL', 2, 39.905, null),
        ('7506267923654', 'GEL HONEY KEEPER MZNILL MIE 200ML', 1, 41.760, null),
        ('7896015592837', 'CEP SENSODYNE GENTLE CARE XTR SUAV 3PZ', 1, 75.450, null),
        ('3616303441173', 'ADIDAS 150ML SPY DYNAMIC PULSE', 1, 39.900, null),
        ('759684900280', 'JALOMA AGUA DE ROSAS 130ML SPRAY', 2, 16.865, null),
        ('7891024027363', 'ENJ BUC PLAX ICE INFINITY 60ML', 2, 13.040, null),
        ('3616303842550', 'ADIDAS 150ML SPY FRESH ENDURANCE', 1, 39.900, null),
        ('3616303441302', 'ADIDAS 150ML SPY TEAMFORCE', 1, 39.900, null),
        ('3616303842420', 'ADIDAS 150ML SPY POWER BOOSTER', 1, 39.900, null),
        ('7891024183182', 'HILO DENT COLGATE ENCERA 25M', 1, 62.660, null),
        ('070942302463', 'CEP DENT GUM GO-BET MICROFINO C/6', 1, 82.630, null),
        ('759684313295', 'JALOMA ATOMIZADOR 60ML MERTODOL BLANCO', 2, 25.775, null),
        ('75075996', 'DESOD REXON HAPPY MOR 48H R-ON 50ML', 1, 34.790, null),
        ('7509552780956', 'DESOD OBAO MEN TATO REBEL R-ON65', 1, 25.830, null),
        ('070942303460', 'CEP DENT GUM TRAV-LER INTERDENTA 0.8', 1, 82.630, null),
        ('7501033204920', 'DESOD SPEED S XTREM 48H CRA30G S N', 6, 14.383, null)
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := null;
      if r.ean is not null and btrim(r.ean) <> '' then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, nullif(btrim(r.ean), ''), r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Recepcion City Mark 20260905 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260905' and coalesce(r.proveedor, '') ilike '%city mark%'
order by i.id;
