-- EAN exactos: clave Equilibrio→Levic o EAN de ticket.
-- Solo WHERE codigo_barras IS NULL. No pisa códigos existentes.
-- Generado por scripts/diagnostico_pricing_20260904.py
begin;

-- Susp 125 Mg/Ml · equilibrio.linea_equilibrio+levic.NOV165
update public.productos
   set codigo_barras = '7501075726251'
 where sku = 'FC-6C2878CF'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501075726251' and x.sku <> 'FC-6C2878CF'
   );
-- Sonblefam S (Crema) · equilibrio.lote_equilibrio+levic.SON256
update public.productos
   set codigo_barras = '7502001166592'
 where sku = 'FC-77FE5C83'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001166592' and x.sku <> 'FC-77FE5C83'
   );
-- Drosquim Ad 1 Ibe 300/160 · equilibrio.lote_equilibrio+levic.QUM070
update public.productos
   set codigo_barras = '7502223111400'
 where sku = 'FC-AA7B0686'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502223111400' and x.sku <> 'FC-AA7B0686'
   );
-- Diclofen · equilibrio.linea_equilibrio+levic.SON039
update public.productos
   set codigo_barras = '7502001163782'
 where sku = 'FC-CF719C07'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001163782' and x.sku <> 'FC-CF719C07'
   );
-- Dison Dex · equilibrio.lote_equilibrio+levic.SON160
update public.productos
   set codigo_barras = '7502001164833'
 where sku = 'FC-1CF27DC9'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001164833' and x.sku <> 'FC-1CF27DC9'
   );
-- Valgab 3 Ibe /6Ml · equilibrio.linea_equilibrio+levic.BIO163
update public.productos
   set codigo_barras = '7501573907688'
 where sku = 'FC-D11D586A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501573907688' and x.sku <> 'FC-D11D586A'
   );
-- Bactiver F (Sulfametoxazol/Trimetoprima) · equilibrio.lote_equilibrio+levic.MAV002
update public.productos
   set codigo_barras = '7503000422283'
 where sku = 'FC-F8691496'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503000422283' and x.sku <> 'FC-F8691496'
   );
-- Cefotaxima IM (Inyectable) · equilibrio.lote_equilibrio+levic.AMS263
update public.productos
   set codigo_barras = '7501349022515'
 where sku = 'FC-22B18244'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349022515' and x.sku <> 'FC-22B18244'
   );
-- Diosmina Hesperidina · equilibrio.lote_equilibrio+levic.BEA428
update public.productos
   set codigo_barras = '7501342804484'
 where sku = 'FC-EADF1484'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501342804484' and x.sku <> 'FC-EADF1484'
   );
-- Indarzona · equilibrio.linea_equilibrio+levic.STR006
update public.productos
   set codigo_barras = '7501547509016'
 where sku = 'FC-F7A2CACF'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501547509016' and x.sku <> 'FC-F7A2CACF'
   );
-- Sibicos · equilibrio.lote_equilibrio+levic.MAV284
update public.productos
   set codigo_barras = '7502009746093'
 where sku = 'FC-F817BC3A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009746093' and x.sku <> 'FC-F817BC3A'
   );
-- N Calcitriol · equilibrio.lote_equilibrio+levic.PGE052
update public.productos
   set codigo_barras = '7503027446125'
 where sku = 'FC-FA3D96E6'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503027446125' and x.sku <> 'FC-FA3D96E6'
   );
-- Hierro Dex · equilibrio.linea_equilibrio+levic.AMS371
update public.productos
   set codigo_barras = '7501349020412'
 where sku = 'FC-2E79C2D8'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349020412' and x.sku <> 'FC-2E79C2D8'
   );
-- Acetonido De Fluocinolona Cma · equilibrio.lote_equilibrio+levic.ALP0598
update public.productos
   set codigo_barras = '7503004908721'
 where sku = 'FC-1BF03D35'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503004908721' and x.sku <> 'FC-1BF03D35'
   );
-- Amlodipino · equilibrio.lote_equilibrio+levic.AVI037
update public.productos
   set codigo_barras = '7502216804661'
 where sku = 'FC-3B001F9B'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216804661' and x.sku <> 'FC-3B001F9B'
   );
-- Compl · equilibrio.linea_equilibrio+levic.AMS398
update public.productos
   set codigo_barras = '7501349025271'
 where sku = 'FC-64EB83AA'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349025271' and x.sku <> 'FC-64EB83AA'
   );
-- Aciclovir · equilibrio.lote_equilibrio+levic.AMS297
update public.productos
   set codigo_barras = '7501349028791'
 where sku = 'FC-FD845E68'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349028791' and x.sku <> 'FC-FD845E68'
   );
-- Clophiven 200 Dosis 50 Mcg · equilibrio.linea_equilibrio+levic.HIS087
update public.productos
   set codigo_barras = '7502213042752'
 where sku = 'FC-0BDE9283'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502213042752' and x.sku <> 'FC-0BDE9283'
   );
-- Aquito 500/100/30/4 Mg · equilibrio.linea_equilibrio+levic.SON264
update public.productos
   set codigo_barras = '7502001166981'
 where sku = 'FC-44B6751A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001166981' and x.sku <> 'FC-44B6751A'
   );
-- Haspen · equilibrio.linea_equilibrio+levic.HIS076
update public.productos
   set codigo_barras = '7502213042370'
 where sku = 'FC-4FD413D2'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502213042370' and x.sku <> 'FC-4FD413D2'
   );
-- Amcef IM 500 mg (Inyectable) · equilibrio.lote_equilibrio+levic.AMS002
update public.productos
   set codigo_barras = '7501349011007'
 where sku = 'FC-07F04F88'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349011007' and x.sku <> 'FC-07F04F88'
   );
-- Tratidri · equilibrio.linea_equilibrio+levic.MAV322
update public.productos
   set codigo_barras = '7502009746932'
 where sku = 'FC-3E863E37'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009746932' and x.sku <> 'FC-3E863E37'
   );
-- Cefalver · equilibrio.lote_equilibrio+levic.MAV260
update public.productos
   set codigo_barras = '7502009745614'
 where sku = 'FC-40CE757D'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009745614' and x.sku <> 'FC-40CE757D'
   );
-- Carbamazepina · equilibrio.lote_equilibrio+levic.RAM054
update public.productos
   set codigo_barras = '7502227872123'
 where sku = 'FC-885F2723'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502227872123' and x.sku <> 'FC-885F2723'
   );
-- Eferox (Cefalexina) · equilibrio.lote_equilibrio+levic.RAD096
update public.productos
   set codigo_barras = '7501563380439'
 where sku = 'FC-DB4A39AE'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501563380439' and x.sku <> 'FC-DB4A39AE'
   );
-- Erispan · equilibrio.lote_equilibrio+levic.MAV360
update public.productos
   set codigo_barras = '7502009745218'
 where sku = 'FC-DF8ADDAB'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009745218' and x.sku <> 'FC-DF8ADDAB'
   );
-- Vernisen · equilibrio.lote_equilibrio+levic.NOV025
update public.productos
   set codigo_barras = '7501075715927'
 where sku = 'FC-174824A0'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501075715927' and x.sku <> 'FC-174824A0'
   );
-- Terficho · equilibrio.lote_equilibrio+levic.HIS075
update public.productos
   set codigo_barras = '7502213042325'
 where sku = 'FC-F967863B'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502213042325' and x.sku <> 'FC-F967863B'
   );
-- Cina (Ciprofloxacino) · equilibrio.linea_equilibrio+levic.LAN043
update public.productos
   set codigo_barras = '7502225092486'
 where sku = 'FC-B25B4654'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502225092486' and x.sku <> 'FC-B25B4654'
   );
-- Acroxil-C · equilibrio.lote_equilibrio+levic.SON139
update public.productos
   set codigo_barras = '7502001163775'
 where sku = 'FC-05965071'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001163775' and x.sku <> 'FC-05965071'
   );
-- Amifarin · equilibrio.lote_equilibrio+levic.WAN024
update public.productos
   set codigo_barras = '7503001007113'
 where sku = 'FC-D5AC44CA'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503001007113' and x.sku <> 'FC-D5AC44CA'
   );
-- Cefagen · equilibrio.lote_equilibrio+levic.MAV131
update public.productos
   set codigo_barras = '7502009741296'
 where sku = 'FC-A455EE80'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009741296' and x.sku <> 'FC-A455EE80'
   );
-- Alopurinol · equilibrio.lote_equilibrio+levic.BEA434
update public.productos
   set codigo_barras = '7501342804309'
 where sku = 'FC-ACA2A2F6'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501342804309' and x.sku <> 'FC-ACA2A2F6'
   );
-- Cefaroxil · equilibrio.lote_equilibrio+levic.MAV142
update public.productos
   set codigo_barras = '7502009741500'
 where sku = 'FC-B18E386A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009741500' and x.sku <> 'FC-B18E386A'
   );
-- Cefagen · equilibrio.lote_equilibrio+levic.MAV130
update public.productos
   set codigo_barras = '7502009741302'
 where sku = 'FC-E374F23E'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009741302' and x.sku <> 'FC-E374F23E'
   );
-- Mexapin · equilibrio.linea_equilibrio+levic.WAN006
update public.productos
   set codigo_barras = '7503001007120'
 where sku = 'FC-50587FA6'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503001007120' and x.sku <> 'FC-50587FA6'
   );
-- Acetilsalicilico Ef · equilibrio.linea_equilibrio+levic.ALP0300
update public.productos
   set codigo_barras = '7501384504908'
 where sku = 'FC-95779436'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501384504908' and x.sku <> 'FC-95779436'
   );
-- Amoxicilina · equilibrio.linea_equilibrio+levic.AMS265
update public.productos
   set codigo_barras = '7501349021570'
 where sku = 'FC-A0D320D1'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021570' and x.sku <> 'FC-A0D320D1'
   );
-- Pentiver · equilibrio.lote_equilibrio+levic.MAV061
update public.productos
   set codigo_barras = '7503000422719'
 where sku = 'FC-B72A6420'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503000422719' and x.sku <> 'FC-B72A6420'
   );
-- Azitromicina · equilibrio.lote_equilibrio+levic.SER076
update public.productos
   set codigo_barras = '7501258210393'
 where sku = 'FC-D9391288'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501258210393' and x.sku <> 'FC-D9391288'
   );
-- Cloxan · equilibrio.lote_equilibrio+levic.BIO064
update public.productos
   set codigo_barras = '7501573902706'
 where sku = 'FC-4F737E93'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501573902706' and x.sku <> 'FC-4F737E93'
   );
-- Degortzin · equilibrio.lote_equilibrio+levic.DEG184
update public.productos
   set codigo_barras = '7501825304562'
 where sku = 'FC-29670370'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501825304562' and x.sku <> 'FC-29670370'
   );
-- Amlodipino · equilibrio.lote_equilibrio+levic.AVI027
update public.productos
   set codigo_barras = '7502216804814'
 where sku = 'FC-4A0245DA'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216804814' and x.sku <> 'FC-4A0245DA'
   );
-- Bitenver · equilibrio.lote_equilibrio+levic.MAV350
update public.productos
   set codigo_barras = '7502009747373'
 where sku = 'FC-58DB24C4'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009747373' and x.sku <> 'FC-58DB24C4'
   );
-- Redalip · equilibrio.linea_equilibrio+levic.MAV073
update public.productos
   set codigo_barras = '7503000422498'
 where sku = 'FC-6074BB64'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503000422498' and x.sku <> 'FC-6074BB64'
   );
-- Wexpec · equilibrio.linea_equilibrio+levic.BIO076
update public.productos
   set codigo_barras = '7503001007694'
 where sku = 'FC-69A3C416'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503001007694' and x.sku <> 'FC-69A3C416'
   );
-- Budimin · equilibrio.lote_equilibrio+levic.MAV373
update public.productos
   set codigo_barras = '7502009748868'
 where sku = 'FC-C6C20517'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009748868' and x.sku <> 'FC-C6C20517'
   );
-- Amlodipino · equilibrio.lote_equilibrio+levic.AVI027
update public.productos
   set codigo_barras = '7502216804814'
 where sku = 'FC-97BEFA1A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216804814' and x.sku <> 'FC-97BEFA1A'
   );
-- Elaphteron · equilibrio.linea_equilibrio+levic.AVT204
update public.productos
   set codigo_barras = '7502209858251'
 where sku = 'FC-9ABFB996'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502209858251' and x.sku <> 'FC-9ABFB996'
   );
-- Zukedib · equilibrio.lote_equilibrio+levic.LOE071
update public.productos
   set codigo_barras = '7502211784036'
 where sku = 'FC-3D0ED22B'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502211784036' and x.sku <> 'FC-3D0ED22B'
   );
-- Zukedib · equilibrio.lote_equilibrio+levic.LOE070
update public.productos
   set codigo_barras = '7502211784029'
 where sku = 'FC-52D2A43A'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502211784029' and x.sku <> 'FC-52D2A43A'
   );
-- Enalapril · equilibrio.linea_equilibrio+levic.ULT104
update public.productos
   set codigo_barras = '7502216792845'
 where sku = 'FC-53506FA4'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216792845' and x.sku <> 'FC-53506FA4'
   );
-- Ibupro-Cafe · equilibrio.lote_equilibrio+levic.VIT068
update public.productos
   set codigo_barras = '7501478316813'
 where sku = 'FC-3D0F54B7'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501478316813' and x.sku <> 'FC-3D0F54B7'
   );
-- Wermy · equilibrio.lote_equilibrio+levic.WER036
update public.productos
   set codigo_barras = '7502240450773'
 where sku = 'FC-50D044FF'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502240450773' and x.sku <> 'FC-50D044FF'
   );
-- Pabesorag · equilibrio.linea_equilibrio+levic.NOV163
update public.productos
   set codigo_barras = '7501075722543'
 where sku = 'FC-5885E577'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501075722543' and x.sku <> 'FC-5885E577'
   );
-- Gentamicina · equilibrio.lote_equilibrio+levic.AMS071
update public.productos
   set codigo_barras = '7501349026094'
 where sku = 'FC-60F627D5'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349026094' and x.sku <> 'FC-60F627D5'
   );
-- Bisoprolol · equilibrio.lote_equilibrio+levic.QUI131
update public.productos
   set codigo_barras = '7501109763375'
 where sku = 'FC-C101D5B1'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501109763375' and x.sku <> 'FC-C101D5B1'
   );
-- Amcef IM 1 g (Inyectable) · equilibrio.lote_equilibrio+levic.AMS004
update public.productos
   set codigo_barras = '7501349012004'
 where sku = 'FC-BE76D409'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349012004' and x.sku <> 'FC-BE76D409'
   );
-- Ceftriaxona IM 1 g (Inyectable) · equilibrio.lote_equilibrio+levic.BEA462
update public.productos
   set codigo_barras = '7506624900519'
 where sku = 'FC-C636D8EA'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7506624900519' and x.sku <> 'FC-C636D8EA'
   );
-- Acemetacina · levic_9012078353
update public.productos
   set codigo_barras = '7502216800984'
 where sku = 'FC-C9F4ACCC'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216800984' and x.sku <> 'FC-C9F4ACCC'
   );
-- Clindamicina · equilibrio.lote_equilibrio+levic.AMS296
update public.productos
   set codigo_barras = '7501349020788'
 where sku = 'FC-CF18C740'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349020788' and x.sku <> 'FC-CF18C740'
   );
-- Fasiclor · equilibrio.lote_equilibrio+levic.MAV123
update public.productos
   set codigo_barras = '7502009741043'
 where sku = 'FC-01B2F362'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009741043' and x.sku <> 'FC-01B2F362'
   );
-- Cefalexina · equilibrio.linea_equilibrio+levic.AMS322
update public.productos
   set codigo_barras = '7501349021181'
 where sku = 'FC-2005DD57'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021181' and x.sku <> 'FC-2005DD57'
   );
-- Claritromicina · equilibrio.lote_equilibrio+levic.AMS492
update public.productos
   set codigo_barras = '7501349021686'
 where sku = 'FC-41339950'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021686' and x.sku <> 'FC-41339950'
   );
-- Cefagen · equilibrio.lote_equilibrio+levic.MAV228
update public.productos
   set codigo_barras = '7502009745126'
 where sku = 'FC-443C330E'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009745126' and x.sku <> 'FC-443C330E'
   );
-- Epicin · equilibrio.linea_equilibrio+levic.SON237
update public.productos
   set codigo_barras = '7502001165328'
 where sku = 'FC-48F732CF'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001165328' and x.sku <> 'FC-48F732CF'
   );
-- Cefalver · equilibrio.lote_equilibrio+levic.MAV163
update public.productos
   set codigo_barras = '7502009740480'
 where sku = 'FC-492D652F'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009740480' and x.sku <> 'FC-492D652F'
   );
-- Kurtosil · equilibrio.lote_equilibrio+levic.MAV357
update public.productos
   set codigo_barras = '7502009747656'
 where sku = 'FC-697EEAD0'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009747656' and x.sku <> 'FC-697EEAD0'
   );
-- Ciprofloxacino · equilibrio.linea_equilibrio+levic.AMS430
update public.productos
   set codigo_barras = '7501349020894'
 where sku = 'FC-74A5ABEE'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349020894' and x.sku <> 'FC-74A5ABEE'
   );
-- Diviltac · equilibrio.lote_equilibrio+levic.SON189
update public.productos
   set codigo_barras = '7502001165311'
 where sku = 'FC-830BF3FB'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001165311' and x.sku <> 'FC-830BF3FB'
   );
-- Tropharma · equilibrio.lote_equilibrio+levic.ALP0237
update public.productos
   set codigo_barras = '7503003134268'
 where sku = 'FC-86A95D07'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503003134268' and x.sku <> 'FC-86A95D07'
   );
-- Klarix · equilibrio.lote_equilibrio+levic.MAV389
update public.productos
   set codigo_barras = '7502009749223'
 where sku = 'FC-8FB65B79'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009749223' and x.sku <> 'FC-8FB65B79'
   );
-- Namifen · equilibrio.lote_equilibrio+levic.NOV013
update public.productos
   set codigo_barras = '7501075713718'
 where sku = 'FC-AEA8C8DA'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501075713718' and x.sku <> 'FC-AEA8C8DA'
   );
-- Penipot · equilibrio.linea_equilibrio+levic.AMS021
update public.productos
   set codigo_barras = '7501349012172'
 where sku = 'FC-3A4583F3'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349012172' and x.sku <> 'FC-3A4583F3'
   );
-- Aspitak-P · equilibrio.lote_equilibrio+levic.SON192
update public.productos
   set codigo_barras = '7502001162976'
 where sku = 'FC-17376CAE'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001162976' and x.sku <> 'FC-17376CAE'
   );
-- Ursodesoxicolico · equilibrio.lote_equilibrio+levic.AMS501
update public.productos
   set codigo_barras = '7501349020269'
 where sku = 'FC-405A75E3'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349020269' and x.sku <> 'FC-405A75E3'
   );
-- Vanmoxol · equilibrio.linea_equilibrio+levic.WAN015
update public.productos
   set codigo_barras = '7503001007205'
 where sku = 'FC-4C621D07'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503001007205' and x.sku <> 'FC-4C621D07'
   );
-- Nalixone · equilibrio.linea_equilibrio+levic.SON102
update public.productos
   set codigo_barras = '7502001165533'
 where sku = 'FC-E6112F15'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502001165533' and x.sku <> 'FC-E6112F15'
   );
-- Celecoxib · equilibrio.lote_equilibrio+levic.ULT180
update public.productos
   set codigo_barras = '7502216805361'
 where sku = 'FC-E6B50AC3'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216805361' and x.sku <> 'FC-E6B50AC3'
   );
-- Lincomicina /2Ml 6 Ampolletas · equilibrio.lote_equilibrio+levic.AMS354
update public.productos
   set codigo_barras = '7501349021983'
 where sku = 'FC-E826D304'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021983' and x.sku <> 'FC-E826D304'
   );
-- Ciprofloxacino G.I · equilibrio.lote_equilibrio+levic.AMS184
update public.productos
   set codigo_barras = '7501349021532'
 where sku = 'FC-E9C38DC4'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021532' and x.sku <> 'FC-E9C38DC4'
   );
-- Amikacina · equilibrio.lote_equilibrio+levic.AMS252
update public.productos
   set codigo_barras = '7501349021440'
 where sku = 'FC-1FEA2FB7'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349021440' and x.sku <> 'FC-1FEA2FB7'
   );
-- Ramcinet · equilibrio.linea_equilibrio+levic.RAM054
update public.productos
   set codigo_barras = '7502227872123'
 where sku = 'FC-26EA40A4'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502227872123' and x.sku <> 'FC-26EA40A4'
   );
-- Cinarizina · equilibrio.lote_equilibrio+levic.ALP0340
update public.productos
   set codigo_barras = '7503004908820'
 where sku = 'FC-3CAA7C5C'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503004908820' and x.sku <> 'FC-3CAA7C5C'
   );
-- Gentamicina · equilibrio.lote_equilibrio+levic.AMS406
update public.productos
   set codigo_barras = '7501349027312'
 where sku = 'FC-63975795'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349027312' and x.sku <> 'FC-63975795'
   );
-- Cepobrom · equilibrio.lote_equilibrio+levic.MAV122
update public.productos
   set codigo_barras = '7502009741289'
 where sku = 'FC-6EAD98A9'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009741289' and x.sku <> 'FC-6EAD98A9'
   );
-- Pentiver · equilibrio.lote_equilibrio+levic.MAV062
update public.productos
   set codigo_barras = '7503000422696'
 where sku = 'FC-7AA38F97'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503000422696' and x.sku <> 'FC-7AA38F97'
   );
-- Captopril · equilibrio.lote_equilibrio+levic.ULT097
update public.productos
   set codigo_barras = '7502216792579'
 where sku = 'FC-82F88FED'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502216792579' and x.sku <> 'FC-82F88FED'
   );
-- Bactiver · equilibrio.linea_equilibrio+levic.MAV001
update public.productos
   set codigo_barras = '7503000422238'
 where sku = 'FC-AE5EEDF7'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7503000422238' and x.sku <> 'FC-AE5EEDF7'
   );
-- Charlyn (Ciprofloxacino) · equilibrio.lote_equilibrio+levic.WER038
update public.productos
   set codigo_barras = '7502240450018'
 where sku = 'FC-7AF7ACB5'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502240450018' and x.sku <> 'FC-7AF7ACB5'
   );
-- Odivitor · equilibrio.linea_equilibrio+levic.MAV212
update public.productos
   set codigo_barras = '7502009744877'
 where sku = 'FC-A909ABC0'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502009744877' and x.sku <> 'FC-A909ABC0'
   );
-- Oxivag · equilibrio.lote_equilibrio+levic.NOV094
update public.productos
   set codigo_barras = '7501075717860'
 where sku = 'FC-B2123139'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501075717860' and x.sku <> 'FC-B2123139'
   );
-- Tusilen Ad 1 Ibe 240/30/50Mg/100 · equilibrio.linea_equilibrio+levic.AVT134
update public.productos
   set codigo_barras = '7502209810365'
 where sku = 'FC-1DAD5EF1'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7502209810365' and x.sku <> 'FC-1DAD5EF1'
   );
-- Budesonida · equilibrio.lote_equilibrio+levic.AMS477
update public.productos
   set codigo_barras = '7501349024304'
 where sku = 'FC-281E0F22'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349024304' and x.sku <> 'FC-281E0F22'
   );
-- Amikacina · equilibrio.lote_equilibrio+levic.AMS471
update public.productos
   set codigo_barras = '7501349020740'
 where sku = 'FC-347A49C7'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501349020740' and x.sku <> 'FC-347A49C7'
   );
-- Ovisen · equilibrio.lote_equilibrio+levic.BIO183
update public.productos
   set codigo_barras = '7501573900290'
 where sku = 'FC-FD92D114'
   and (codigo_barras is null or btrim(codigo_barras) = '')
   and not exists (
     select 1 from public.productos x
      where x.codigo_barras = '7501573900290' and x.sku <> 'FC-FD92D114'
   );

commit;
