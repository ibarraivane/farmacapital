-- FarmaCapital · Clasificación de vitrina
-- Llena productos.vitrina_seccion y productos.vitrina_subseccion.
-- NO toca productos.categoria (la leen POS, inventario, lotes y reportes).
--
-- Las reglas son deterministas: se pueden volver a correr cuantas veces sea
-- necesario y un producto nuevo queda clasificado sin intervención.
--
-- Correr en orden. La sección 1 solo después de que regrese firmada la hoja
-- 01-receta-para-responsable-sanitario.xlsx.

begin;

-- ============================================================ 0 · Referencia
-- Categorías de inventario que son medicamento. Se usa en las pruebas:
-- ningún producto de esta lista puede terminar en una sección de belleza.
--
--   Medicamentos, Medicamento, Medicamentos OTC, Analgésico, Antiinflamatorio,
--   Antibiótico, Antiviral, Gastro, Diabetes, Hipertensión, Cardiovascular,
--   Alergia, Respiratorio, Hormonales, Hidratación, Dermatología, Ginecología,
--   Pruebas

-- ====================================================== 1 · Receta (firmada)
-- PLANTILLA. Sustituir la lista por los IDs que el responsable sanitario
-- marcó "Sí" en la columna ¿Aprueba? con propuesta Receta o Receta IV.
-- No agregar IDs que no estén en la hoja firmada.
--
-- update public.productos
--    set requiere_receta = true
--  where id in ( /* IDs aprobados */ );
--
-- Para los aprobados como "Receta IV", además marcar el grupo que indique
-- el responsable sanitario:
--
-- update public.productos
--    set requiere_receta = true, grupo_controlado = '<fracción que él indique>'
--  where id in ( /* IDs de Receta IV aprobados */ );

-- ================================================== 2 · Columnas de vitrina
alter table public.productos
  add column if not exists vitrina_seccion    text,
  add column if not exists vitrina_subseccion text;

create index if not exists productos_vitrina_seccion_idx
  on public.productos (vitrina_seccion) where activo;

-- Se limpia para poder recorrer las reglas otra vez sin residuos.
update public.productos set vitrina_seccion = null, vitrina_subseccion = null;

-- ===================================================== 3 · Medicamentos
-- Primero, porque manda sobre cualquier otra regla.
update public.productos set
  vitrina_seccion = 'Medicamentos',
  vitrina_subseccion = case
    when categoria in ('Analgésico','Antiinflamatorio')      then 'Dolor y fiebre'
    when categoria in ('Respiratorio')                        then 'Gripa y tos'
    when categoria in ('Gastro','Hidratación')                then 'Digestión'
    when categoria in ('Alergia')                             then 'Alergia'
    when categoria in ('Diabetes')                            then 'Diabetes'
    when categoria in ('Hipertensión','Cardiovascular')       then 'Presión y corazón'
    when categoria in ('Dermatología')                        then 'Piel'
    when categoria in ('Antibiótico','Antiviral')             then 'Antibióticos'
    else 'Otros'
  end
where activo
  and ( requiere_receta
        or coalesce(controlado, false)
        or coalesce(nullif(btrim(grupo_controlado), ''), '') <> ''
        or categoria in ('Medicamentos','Medicamento','Medicamentos OTC',
                         'Analgésico','Antiinflamatorio','Antibiótico','Antiviral',
                         'Gastro','Diabetes','Hipertensión','Cardiovascular',
                         'Alergia','Respiratorio','Hormonales','Hidratación',
                         'Dermatología','Ginecología') );

-- ===================================================== 4 · Dermocosmética
-- "Cuidado personal" son 1 952 productos y ~95% es dermocosmética de marca
-- (MartiDerm, Isdin, Bioderma, Sesderma, La Roche Posay, Eucerin, Avène,
-- Cetaphil, CeraVe, Uriage, Ducray, A-Derma, Neostrata…). La cola de marca
-- masiva se saca primero; el resto se queda en dermocosmética.
--
-- Nota: si una marca masiva nueva no está en esta lista, el producto cae en
-- Dermocosmética. Es un error cosmético, no de seguridad, y se corrige
-- agregando la marca aquí.
update public.productos set
  vitrina_seccion = 'Higiene y cuidado personal',
  vitrina_subseccion = 'Cuidado diario'
where activo and vitrina_seccion is null
  and categoria = 'Cuidado personal'
  and lower(btrim(coalesce(marca,''))) in (
    'ego','silica','shine sily','moco de gorila','garnier','fructis','jaloma',
    'hinds','koleston','teatrical','nivea','ponds','pond''s','lubriderm',
    'labello','grisi','seda pure','nuvel','xiomara','adidas','revlon','gum',
    'vitacilina','pert','herbal essences','natural gloss','nutribela'
  );

-- Solar es la única subsección derivable con confianza (355 productos).
-- El resto se filtra por marca en la página; poner "Facial" por omisión
-- etiquetaría mal al 72% del bloque.
update public.productos set
  vitrina_seccion = 'Dermocosmética',
  vitrina_subseccion = case
    when nombre ~* '(solar|fps|spf|fotoprotec|sunscreen|heliocare)' then 'Solar'
    else null
  end
where activo and vitrina_seccion is null
  and categoria in ('Cuidado personal','Dermocosmético');

-- ================================================ 5 · Nutrición deportiva
-- "Suplemento" son 2 102 productos, casi todos deportivos (Insane Labz,
-- Optimum Nutrition, RAW, Evogen, Dragon Pharma, Mutant, Cellucor…).
-- La nutrición clínica son 11 productos y se saca primero.
update public.productos set
  vitrina_seccion = 'Vitaminas y bienestar',
  vitrina_subseccion = 'Nutrición clínica'
where activo and vitrina_seccion is null
  and categoria in ('Suplemento','Suplementos')
  and ( lower(coalesce(marca,'')) in ('ensure','glucerna','pediasure','abbott')
        or nombre ~* '(ensure|glucerna|pediasure)' );

-- El tipo (proteína, pre-entreno, creatina) NO se puede derivar del nombre:
-- se probó y el 65% cae en "Otros" porque los nombres son marca y sabor
-- ("The Curse Watermelon" es un pre-entreno, "ISO 100" es proteína aislada).
-- La página se filtra por marca, que sí es dato limpio y es como se compra.
update public.productos set
  vitrina_seccion = 'Nutrición deportiva',
  vitrina_subseccion = null
where activo and vitrina_seccion is null
  and categoria in ('Suplemento','Suplementos');

-- ================================================ 6 · Vitaminas y bienestar
update public.productos set
  vitrina_seccion = 'Vitaminas y bienestar',
  vitrina_subseccion = case
    when categoria = 'Herbolario' then 'Herbolarios'
    when nombre ~* '(probi(o|ó)tic|lactobacil)' then 'Probióticos'
    else 'Vitaminas'
  end
where activo and vitrina_seccion is null
  and categoria in ('Vitaminas','Herbolario');

-- ========================================= 7 · Higiene y cuidado personal
update public.productos set
  vitrina_seccion = 'Higiene y cuidado personal',
  vitrina_subseccion = case
    when nombre ~* '(shampoo|champ(u|ú)|acondicionador|gel .*cabello|cera |tinte|koleston)' then 'Cabello'
    when nombre ~* '(desodorante|antitranspirante)'                        then 'Desodorantes'
    when nombre ~* '(pasta dental|cepillo dent|enjuague bucal|hilo dental)' then 'Higiene bucal'
    when nombre ~* '(rastrillo|afeitar|rasurar|navaja)'                     then 'Afeitado'
    when nombre ~* '(pa(ñ|n)al|bebe|beb(é|e)|toallitas)'                    then 'Bebé'
    when nombre ~* '(cond(o|ó)n|preservativo|lubricante (i|í)ntimo)'        then 'Salud sexual'
    else 'Cuidado diario'
  end
where activo and vitrina_seccion is null
  and categoria in ('Higiene','Bebés');

-- ========================================= 8 · Botiquín y equipo médico
update public.productos set
  vitrina_seccion = 'Botiquín y equipo médico',
  vitrina_subseccion = case
    when nombre ~* '(term(o|ó)metro)'                        then 'Termómetros y baumanómetros'
    when nombre ~* '(baum(a|á)n(o|ó)metro|presi(o|ó)n)'      then 'Termómetros y baumanómetros'
    when nombre ~* '(gluc(o|ó)metro|tiras reactivas|lanceta)' then 'Glucómetros'
    when nombre ~* '(prueba|test)'                            then 'Pruebas'
    else 'Curación'
  end
where activo and vitrina_seccion is null
  and categoria in ('Botiquín','Curación','Dispositivo médico','Dispositivos','Pruebas');

-- ============================================================ 9 · Revisión
-- Lo que quede sin sección NO se muestra en el menú. Es la bandeja de
-- pendientes del admin. Aquí caen los de "Otro", "GENERAL", "Producto" y
-- las categorías de minisuper, que no se venden en la tienda web.

commit;

-- ============================================================ Verificación
-- Correr después. Los tres primeros deben dar CERO.

-- 1 · Receta fuera de Medicamentos
select count(*) as receta_mal_ubicada
  from public.productos
 where activo and requiere_receta
   and vitrina_seccion is not null
   and vitrina_seccion <> 'Medicamentos';

-- 2 · Medicamento en sección de belleza o nutrición
select count(*) as medicamento_mal_ubicado
  from public.productos
 where activo
   and categoria in ('Medicamentos','Medicamento','Medicamentos OTC','Analgésico',
                     'Antiinflamatorio','Antibiótico','Antiviral','Gastro','Diabetes',
                     'Hipertensión','Cardiovascular','Alergia','Respiratorio',
                     'Hormonales','Hidratación','Dermatología','Ginecología')
   and vitrina_seccion in ('Dermocosmética','Nutrición deportiva',
                           'Vitaminas y bienestar','Higiene y cuidado personal');

-- 3 · Controlado fuera de Medicamentos
select count(*) as controlado_mal_ubicado
  from public.productos
 where activo
   and (coalesce(controlado,false) or coalesce(nullif(btrim(grupo_controlado),''),'') <> '')
   and coalesce(vitrina_seccion,'') <> 'Medicamentos';

-- 4 · Reparto final y pendientes
select coalesce(vitrina_seccion, '(sin clasificar · no se muestra)') as seccion,
       count(*) as productos
  from public.productos
 where activo
 group by 1
 order by 2 desc;
