-- ============================================================================
-- FarmaCapital — 2026-09-21
-- Recategoriza TODO el catálogo con las mismas reglas de la vitrina.
-- Solo toca `categoria`. No inventa sustancia, precio ni foto.
--
-- Cubos que corrige: Otro, GENERAL, Producto, Higiene mal puesta (Electrolit),
-- Gastro/Analgésico mal puestos (Ensure, Pediasure), Bebidas (Pedialyte).
-- Si no hay señal (nombre/marca/PA), no mueve el renglón.
--
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos
   set categoria = v.cat
  from (
    select
      id,
      case
        when t ~ '(^|[^a-z0-9])(electrolit|electrolid|pedialyte|suerox|oralit|voldratol|suero oral|electrolitos)([^a-z0-9]|$)'
          then 'Hidratación'
        when t ~ '(^|[^a-z0-9])(solucion cs|cloruro de sodio 0\.?9|nacl 0\.?9|hartmann|solucion fisiologica)([^a-z0-9]|$)'
          then 'Hidratación'
        when t ~ '(^|[^a-z0-9])(gasa|venda|jeringa|algodon|tegaderm|curita|micropore|tela adhesiva|cubrebocas|tensolastic|material de curacion|agua oxigenada|agua destilada)([^a-z0-9]|$)'
          then 'Botiquín'
        when t ~ '(^|[^a-z0-9])(alcohol etilico|alcohol 70|isodine|termometro|gotero|cateter)([^a-z0-9]|$)'
          then 'Botiquín'
        when t ~ '(^|[^a-z0-9])(omron|glucometro|tensiometro|oximetro|accu-?chek|softclix|monitor de presion)([^a-z0-9]|$)'
          then 'Dispositivo médico'
        when t ~ '(^|[^a-z0-9])(amoxicilina|ampicilina|azitromicina|ciprofloxacino|levofloxacino|cefalexina|cefaclor|ceftriaxona|claritromicina|doxiciclina|clindamicina|dicloxacilina|penicilina|amikacina|nitrofurantoina|trimetoprima|sulfametoxazol|cefuroxima|cefixima)([^a-z0-9]|$)'
          then 'Antibiótico'
        when t ~ '(^|[^a-z0-9])(clamoxin|cefalver|cefaroxil|gimalxina|valclan)([^a-z0-9]|$)'
          then 'Antibiótico'
        when t ~ '(^|[^a-z0-9])(antiflu|desenfriol|theraflu|syncol|agrifen|tabcin)([^a-z0-9]|$)'
          then 'Respiratorio'
        when t ~ '(^|[^a-z0-9])(alka[- ]?seltzer|sal de uvas)([^a-z0-9]|$)'
          then 'Gastro'
        when t ~ '(^|[^a-z0-9])(ibuprofeno|naproxeno|diclofenaco|nimesulida|piroxicam|celecoxib|ketoprofeno|acemetacina|meloxicam|indometacina|flanax|advil|motrin)([^a-z0-9]|$)'
          then 'Antiinflamatorio'
        when t ~ '(^|[^a-z0-9])(paracetamol|acetaminofen|metamizol|neomelubrina|ketorolaco|tramadol|tempra|tylenol|cafiaspirina)([^a-z0-9]|$)'
          then 'Analgésico'
        when t ~ '(^|[^a-z0-9])(acido acetilsalicilico|acetilsalicilico|aspirina)([^a-z0-9]|$)'
          then 'Analgésico'
        when t ~ '(^|[^a-z0-9])(omeprazol|pantoprazol|esomeprazol|lansoprazol|ranitidina|famotidina|sucralfato|bismuto|estomaquil|loperamida|butilhioscina|butilescopolamina|metoclopramida|ondansetron|dimenhidrinato|buscapina|gaviscon)([^a-z0-9]|$)'
          then 'Gastro'
        when t ~ '(^|[^a-z0-9])(metformina|glibenclamida|insulina|sitagliptina|empagliflozina|dapagliflozina|linagliptina|gliclazida)([^a-z0-9]|$)'
          then 'Diabetes'
        when t ~ '(^|[^a-z0-9])(losartan|enalapril|amlodipino|telmisartan|valsartan|captopril|nifedipino|hidroclorotiazida|metoprolol|atenolol|bisoprolol|irbesartan|candesartan)([^a-z0-9]|$)'
          then 'Hipertensión'
        when t ~ '(^|[^a-z0-9])(atorvastatina|simvastatina|rosuvastatina|pravastatina|clopidogrel|rivaroxaban|warfarina|acenocumarol)([^a-z0-9]|$)'
          then 'Cardiovascular'
        when t ~ '(^|[^a-z0-9])(loratadina|cetirizina|levocetirizina|desloratadina|fexofenadina|clorfenamina|clarityne|claritin|allegra|zyrtec)([^a-z0-9]|$)'
          then 'Alergia'
        when t ~ '(^|[^a-z0-9])(ambroxol|dextrometorfano|bromhexina|guaifenesina|oxolamina|salbutamol|budesonida|montelukast|afrin|broncolin|nasalub|histiacil|bisolvon|antigripal)([^a-z0-9]|$)'
          then 'Respiratorio'
        when t ~ '(^|[^a-z0-9])(levonorgestrel|etinilestradiol|levotiroxina|desogestrel|drospirenona|anticonceptivo)([^a-z0-9]|$)'
          then 'Hormonales'
        -- Vitamina en sérum/crema/gel es piel. Dove con vitamina E es higiene.
        -- Tableta, cápsula, jarabe, gomita o polvo se queda en Vitaminas.
        when t ~ '(^|[^a-z0-9])(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)([^a-z0-9]|$)'
         and t !~ '(^|[^a-z0-9])(tabletas?|tabs?|capsulas?|caps|comprimidos?|grageas?|gomitas?|efervescentes?|jarabes?|polvos?|sobres?|ampolletas?|softgels?|masticables?|perlas?|porcion(es)?|suplementos?)([^a-z0-9]|$)'
         and t ~ '(^|[^a-z0-9])(shampoo|acondicionador|desodorante|antitranspirante|pantene|sedal|dove|crema dental|pasta dental|enjuague bucal)([^a-z0-9]|$)'
          then 'Higiene'
        when t ~ '(^|[^a-z0-9])(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)([^a-z0-9]|$)'
         and t !~ '(^|[^a-z0-9])(tabletas?|tabs?|capsulas?|caps|comprimidos?|grageas?|gomitas?|efervescentes?|jarabes?|polvos?|sobres?|ampolletas?|softgels?|masticables?|perlas?|porcion(es)?|suplementos?)([^a-z0-9]|$)'
         and (
           t ~ '(^|[^a-z0-9])(serums?|cremas?|gel(es)?|mascarillas?|limpiador(es)?|locion(es)?|fluidos?|fluidbase|fps[0-9]*|spf[0-9]*|protector solar|bloqueador|exfoliantes?|tonicos?|balsamos?|pomadas?|unguentos?|desmaquillantes?|agua micelar|peeling|retinol|activo puro|liftactiv|geneskin|pigmentbio|depiderm|actine|facial|contorno)([^a-z0-9]|$)'
           or (
             t ~ '(^|[^a-z0-9])aceite([^a-z0-9]|$)'
             and t !~ 'aceite de (pescado|higado|coco|onagra|primula|krill|lino|oliva|germen)'
           )
         )
          then 'Cuidado personal'
        when t ~ '(^|[^a-z0-9])(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)([^a-z0-9]|$)'
          then 'Vitaminas'
        when t ~ '(^|[^a-z0-9])(ensure|pediasure|glucerna|omega 3|suplemento nutricional)([^a-z0-9]|$)'
          then 'Suplemento'
        when t ~ '(^|[^a-z0-9])(ajolotius|arnica|homeopatico|producto homeopatico|producto natural)([^a-z0-9]|$)'
          then 'Herbolario'
        when t ~ '(^|[^a-z0-9])(antitranspirante|surfactantes / formula|jabon / tensioactivos|fluoruro de sodio)([^a-z0-9]|$)'
          then 'Higiene'
        when t ~ '(^|[^a-z0-9])(emolientes /|vaselina \+ lanolina)([^a-z0-9]|$)'
          then 'Cuidado personal'
        when t ~ '(^|[^a-z0-9])(pantene|sedal|caprice|savile|shampoo|acondicionador|crema dental|pasta dental|enjuague bucal|listerine|colgate|sensodyne|cepillo dental|hilo dental)([^a-z0-9]|$)'
          then 'Higiene'
        when t ~ '(^|[^a-z0-9])(desodorante|rexona|dove|obao|jabon|toallas sanitarias|naturella|saba|condon|lubricante|prudence|huggies|toallas humedas)([^a-z0-9]|$)'
          then 'Higiene'
        when t ~ '(^|[^a-z0-9])(protector solar|bloqueador|anthelios|cerave|acetona|agua micelar|crema corporal|vaselina|emolientes)([^a-z0-9]|$)'
          then 'Cuidado personal'
        when t ~ '(^|[^a-z0-9])(nido|nan|nestum|leche en polvo|formula lactea)([^a-z0-9]|$)'
          then 'Abarrotes'
        else null
      end as cat
    from (
      select
        id,
        lower(regexp_replace(
          translate(
            coalesce(nombre, '') || ' ' ||
            coalesce(marca, '') || ' ' ||
            coalesce(principio_activo, '') || ' ' ||
            coalesce(forma_farmaceutica, '') || ' ' ||
            coalesce(presentacion, ''),
            'áéíóúüñÁÉÍÓÚÜÑ',
            'aeiouunAEIOUUN'
          ),
          '\s+',
          ' ',
          'g'
        )) as t
      from public.productos
    ) x
  ) v
 where public.productos.id = v.id
   and v.cat is not null
   and public.productos.categoria is distinct from v.cat;

commit;

select categoria, count(*) as n
  from public.productos
 where activo is not false
 group by 1
 order by 2 desc;
