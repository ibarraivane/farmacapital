-- Completar marca / presentación / PA en fichas Equilibrio huecas.
-- Fuentes: OCR de portada, catálogo Levic, parser de nombre.
begin;

-- EQ-AMS274 · Ezetimiba/Simvasta 14 Tab 10/20 Mg · levic,foto-pa,parser-pres
update public.productos set
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 tabletas')
 where sku = 'EQ-AMS274';

-- EQ-RAD082 · Indometacina 30 Caps 25 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Randall')
 where sku = 'EQ-RAD082';

-- EQ-AMS460 · Etoricoxib 14 Comp 90 Mg · levic,foto-pa,parser-pres
update public.productos set
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 comprimidos')
 where sku = 'EQ-AMS460';

-- EQ-JAY263 · Diflosensi 28 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Jayor')
 where sku = 'EQ-JAY263';

-- EQ-DEG011 · Convifer C/Hierro 1 Sol 3/2/.1mg/110 · levic,foto-pa,parser-pres
update public.productos set
    principio_activo = coalesce(nullif(principio_activo, ''), 'Ciproheptadina + vitaminas + hierro'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Ciproheptadina + vitaminas + hierro')
 where sku = 'EQ-DEG011';

-- EQ-PGE059 · Lorefic-D 30 Caps 4000 Ui · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Progela')
 where sku = 'EQ-PGE059';

-- EQ-AMS497 · Levetiracetam 30 Tab 1000 Mg · levic,foto-pa,parser-pres
update public.productos set
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas')
 where sku = 'EQ-AMS497';

-- EQ-MAI144 · Figral 10 Tab 100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Mavi'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Sildenafil'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Sildenafil'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-MAI144';

-- EQ-ULT145 · Sildenafil 4 Tab 100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Ultra'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Sildenafil'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Sildenafil'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 4 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-ULT145';

-- EQ-AVT216 · Soltadol 10 Tab 750 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Avitus'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Paracetamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Paracetamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '750 mg')
 where sku = 'EQ-AVT216';

-- EQ-HIS081 · Farmarest Salbut 1 Susp/Aer 200do/125 · levic,foto-pa
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Hispanoamericana'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Salbutamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Salbutamol')
 where sku = 'EQ-HIS081';

-- EQ-BEA338 · Prednisona 5mg C/Blister 20tab Bea · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Prednisona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Prednisona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta')
 where sku = 'EQ-BEA338';

-- EQ-MAV331 · Lonvitol 10 Amp .05/2.5 Mg/ 2.5 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Bromuro De Ipratropio / Salbutamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Bromuro De Ipratropio / Salbutamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 soluciones'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución'),
    concentracion = coalesce(nullif(concentracion, ''), '05/2.5 mg/ 2.5 mL')
 where sku = 'EQ-MAV331';

-- EQ-AMS323 · Sertralina 14 Tab 50 Mg · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Sertralina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Sertralina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '50 mg')
 where sku = 'EQ-AMS323';

-- EQ-ULT146 · Pioglitazona 7 Tab 15 Mg · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Ultra'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pioglitazona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pioglitazona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 7 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '15 mg')
 where sku = 'EQ-ULT146';

-- EQ-MAV407 · Daimant 14 Caps 100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Rimantadina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Rimantadina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-MAV407';

-- EQ-COL133 · Nosipren 30 Tab 20 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Collins'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Prednisona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Prednisona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '20 mg')
 where sku = 'EQ-COL133';

-- EQ-QUM068 · Quimunex 1 Sol 100 Mg/100 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Quimpharma'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Prednisolona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Prednisolona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 solución'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg/100 mL')
 where sku = 'EQ-QUM068';

-- EQ-PGE061 · Esterinol 40 Caps 50000ui · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Progela'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Retinol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Retinol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 40 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '50000UI')
 where sku = 'EQ-PGE061';

-- EQ-AMS498 · Popram 28 Tab 40 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pantoprazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pantoprazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 28 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '40 mg')
 where sku = 'EQ-AMS498';

-- EQ-SON225 · Norkin 7 Caps 40 Mg · levic,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 7 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Capsulas'),
    concentracion = coalesce(nullif(concentracion, ''), '40 mg')
 where sku = 'EQ-SON225';

-- EQ-LOE096 · Vidalol Plus 20 Tab 10/500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Loeffler'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Butilhioscina / Paracetamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Butilhioscina / Paracetamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '10/500 mg')
 where sku = 'EQ-LOE096';

-- EQ-AMS370 · Pentoxifilina 30 Tab 400 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pentoxifilina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pentoxifilina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '400 mg')
 where sku = 'EQ-AMS370';

-- EQ-SER116 · Cyrux 28 Tab 200 Mcg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Serral'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Misoprostol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Misoprostol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 28 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '200 mcg')
 where sku = 'EQ-SER116';

-- EQ-NOV054 · Lambliquin 30 Tab 400/200 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Diyodohidroxiquinoleína / Metronidazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Diyodohidroxiquinoleína / Metronidazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '400/200 mg')
 where sku = 'EQ-NOV054';

-- EQ-MAV198 · Oxatech 14 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Olanzapina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Olanzapina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg')
 where sku = 'EQ-MAV198';

-- EQ-PHG017 · Metronida/Diyohidro 1 Susp · levic,parser-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Pharmagen'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metronida/Diyohidro'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metronida/Diyohidro'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 suspensión'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspension')
 where sku = 'EQ-PHG017';

-- EQ-LOE135 · Rosanil 7 Tab 500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Loeffler'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Nitazoxanida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Nitazoxanida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 7 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-LOE135';

-- EQ-ULT191 · Piroxicam 20 Tab 20 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Ultra'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Piroxicam'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Piroxicam'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '20 mg')
 where sku = 'EQ-ULT191';

-- EQ-ALP0410 · Nistatina 1 Susp 1 Ui /24 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Alpharma'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Nistatina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Nistatina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 24 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspensión'),
    concentracion = coalesce(nullif(concentracion, ''), '1 UI /24 mL')
 where sku = 'EQ-ALP0410';

-- EQ-BEA368 · Nifedipino 30 Comp 30 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Nifedipino'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Nifedipino'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 comprimidos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Comprimidos'),
    concentracion = coalesce(nullif(concentracion, ''), '30 mg')
 where sku = 'EQ-BEA368';

-- EQ-EXA035 · Neomici Polimixi B Gramicidi 1 Sol 15 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Exakta'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Neomicina / Polimixina B / Gramicidina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Neomicina / Polimixina B / Gramicidina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 15 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución'),
    concentracion = coalesce(nullif(concentracion, ''), '15 mL')
 where sku = 'EQ-EXA035';

-- EQ-EXA045 · Neomicina Polimixina-B Bacitracina Ung · levic + nombre
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Exakta'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Neomicina / Polimixina B / Bacitracina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Neomicina / Polimixina B / Bacitracina'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Ungüento'),
    presentacion = coalesce(nullif(presentacion, ''), 'Tubo')
 where sku = 'EQ-EXA045';

-- EQ-NOV176 · Pirinovag 10 Tab 500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metamizol Sódico'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metamizol Sódico'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-NOV176';

-- EQ-SON096 · Fenimeth V 12 Ovs 500mg/100000 Ui · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metronidazol / Nistatina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metronidazol / Nistatina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 12 óvulos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Óvulos'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-SON096';

-- EQ-MAV307 · Veratrin 20 Caps 215/25/0.75 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Betametasona / Indometacina / Metocarbamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Betametasona / Indometacina / Metocarbamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '215/25/0.75 mg')
 where sku = 'EQ-MAV307';

-- EQ-SON153 · Nysmosons-V 10 Ovs 500/0.5mg/100000 Ui · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metronidazol / Nistatina / Fluocinolona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metronidazol / Nistatina / Fluocinolona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 óvulos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Óvulo'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-SON153';

-- EQ-MAI163 · Crostox 30 Tab 20 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Mavi'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Rosuvastatina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Rosuvastatina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '20 mg')
 where sku = 'EQ-MAI163';

-- EQ-NOV092 · Ixicorl 10 Tab 20 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Paroxetina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Paroxetina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '20 mg')
 where sku = 'EQ-NOV092';

-- EQ-AMS503 · Sitagliptina 14 Comp 100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Sitagliptina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Sitagliptina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 comprimidos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Comprimido'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-AMS503';

-- EQ-LOE066 · Pensodil-S 5 Sup 200/100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Loeffler'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Naproxeno / Paracetamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Naproxeno / Paracetamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 5 supositorios'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Supositorios'),
    concentracion = coalesce(nullif(concentracion, ''), '200/100 mg')
 where sku = 'EQ-LOE066';

-- EQ-SON104 · Neoderm-F 1 Cma 40g · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Acetónido de Fluocinolona / Neomicina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Acetónido de Fluocinolona / Neomicina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 40 tubos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Crema'),
    concentracion = coalesce(nullif(concentracion, ''), '40 G')
 where sku = 'EQ-SON104';

-- EQ-QUM006 · Mitafar 1 Susp 100mg/5/60 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Quimpharma'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Nitazoxanida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Nitazoxanida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 60 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspensión'),
    concentracion = coalesce(nullif(concentracion, ''), '100mg/5/60 mL')
 where sku = 'EQ-QUM006';

-- EQ-MAV266 · Berniver 2% 1 Ung 15 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Mupirocina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Mupirocina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Ungüento 2 % C/tubo 15 g'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Ungüento'),
    concentracion = coalesce(nullif(concentracion, ''), '2 %')
 where sku = 'EQ-MAV266';

-- EQ-RAD093 · Metronidazol 30 Tab 500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Randall'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metronidazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metronidazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-RAD093';

-- EQ-MAV162 · Dolxen 10 Tab 500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Naproxeno'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Naproxeno'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-MAV162';

-- EQ-SER165 · Estranim 10 Caps 75 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Serral'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Oseltamivir'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Oseltamivir'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '75 mg')
 where sku = 'EQ-SER165';

-- EQ-SON098 · Metroson 1 Susp 250mg/5/120 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metronidazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metronidazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 120 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspensión'),
    concentracion = coalesce(nullif(concentracion, ''), '250mg/5/120 mL')
 where sku = 'EQ-SON098';

-- EQ-LOE014 · Neosedal 1 Jbe 5g/100/120 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Loeffler'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metamizol Sódico'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metamizol Sódico'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 120 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Jarabe'),
    concentracion = coalesce(nullif(concentracion, ''), '5 G/100/120 mL')
 where sku = 'EQ-LOE014';

-- EQ-SON089 · Magnil 1 Jbe 250mg/5/100 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metamizol Sódico'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metamizol Sódico'),
    presentacion = coalesce(nullif(presentacion, ''), 'Frasco con 100 mL'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Jarabe'),
    concentracion = coalesce(nullif(concentracion, ''), '250mg/5/100 mL')
 where sku = 'EQ-SON089';

-- EQ-NOV004 · Cirulan 20 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metoclopramida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metoclopramida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg')
 where sku = 'EQ-NOV004';

-- EQ-BEA416 · Metoclopramida 20 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metoclopramida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metoclopramida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg')
 where sku = 'EQ-BEA416';

-- EQ-BEA424 · Metoprolol 20 Tab 100mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metoprolol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metoprolol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-BEA424';

-- EQ-BRL053 · Direpasid (Metoclopramida) 20 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Bruluart'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metoclopramida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metoclopramida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg')
 where sku = 'EQ-BRL053';

-- EQ-MAV392 · Cetilver 1 Gel 8% C/10 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pirfenidona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pirfenidona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tubos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Gel'),
    concentracion = coalesce(nullif(concentracion, ''), '8 g')
 where sku = 'EQ-MAV392';

-- EQ-MAI150 · Maviglin 60 Grag 500/5 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Mavi'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metformina / Glibenclamida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metformina / Glibenclamida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 60 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '500/5 mg')
 where sku = 'EQ-MAI150';

-- EQ-NOV157 · Glunovag 60 Tab 500 Mg · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metformina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metformina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 60 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-NOV157';

-- EQ-BIO058 · Wadil 30 Tab 500/5 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Biomep'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metformina / Glibenclamida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metformina / Glibenclamida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '500/5 mg')
 where sku = 'EQ-BIO058';

-- EQ-BEA429 · Metformina 30 Tab 850 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metformina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metformina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '850 mg')
 where sku = 'EQ-BEA429';

-- EQ-ULT056 · Retoflam-F 10 Tab 215/15 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Ultra'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metocarbamol / Meloxicam'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metocarbamol / Meloxicam'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '215/15 mg')
 where sku = 'EQ-ULT056';

-- EQ-WER040 · Punab 30 Tab 50 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Wermar'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Losartán'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Losartán'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '50 mg')
 where sku = 'EQ-WER040';

-- EQ-MAV175 · Flexiver Compuesto 20 Caps 215/7.5 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Meloxicam / Metocarbamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Meloxicam / Metocarbamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '215/7.5 mg')
 where sku = 'EQ-MAV175';

-- EQ-LIF006 · Carbafen 30 Tab 400/350mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Liferpal'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metocarbamol / Paracetamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metocarbamol / Paracetamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '400/350mg')
 where sku = 'EQ-LIF006';

-- EQ-SON034 · Busconet 10 Tab 250/10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metamizol sódico / Hioscina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metamizol sódico / Hioscina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '250/10 mg')
 where sku = 'EQ-SON034';

-- EQ-BIO003 · Biomesina Compuesta 10 Grag 250/10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Biomep'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Butilbromuro de hioscina / Metamizol sódico'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Butilbromuro de hioscina / Metamizol sódico'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '250/10 mg')
 where sku = 'EQ-BIO003';

-- EQ-SON175 · Ardosons 20 Caps 215/25/0.75 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Indometacina / Betametasona / Metocarbamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Indometacina / Betametasona / Metocarbamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsulas'),
    concentracion = coalesce(nullif(concentracion, ''), '215/25/0.75 mg')
 where sku = 'EQ-SON175';

-- EQ-SON091 · Meclison 20 Tab 50/25 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Meclizina / Piridoxina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Meclizina / Piridoxina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '50/25 mg')
 where sku = 'EQ-SON091';

-- EQ-BEA426 · Oxido De Zinc 1 Pasta 30 G · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Óxido de Zinc'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Óxido de Zinc')
 where sku = 'EQ-BEA426';

-- EQ-VIT073 · Bocetix 1 Sol 50 Mg 150 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Vitae'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Levocetirizina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Levocetirizina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 solución'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución')
 where sku = 'EQ-VIT073';

-- EQ-COD086 · Bano Coloide 1 Pvo 96.5/2/90 G · levic,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Suanca')
 where sku = 'EQ-COD086';

-- EQ-VIT055 · Rotumal 1 Gel 60g/1.16 % · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Vitae'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Diclofenaco'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Diclofenaco')
 where sku = 'EQ-VIT055';

-- EQ-NOV137 · Nineka 20 Tab 129/280/30 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Novag'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Neomicina / Caolín y Pectina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Neomicina / Caolín y Pectina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '129/280/30 mg')
 where sku = 'EQ-NOV137';

-- EQ-COL239 · Volfenac Gel 1 Gel 2.32g/100 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Collins'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Diclofenaco'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Diclofenaco'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 tubo'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Gel'),
    concentracion = coalesce(nullif(concentracion, ''), '2.32%')
 where sku = 'EQ-COL239';

-- EQ-LIF153 · Realdrax Mxd 10 Tab 20/400 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Liferpal'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Hioscina / Ibuprofeno'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Hioscina / Ibuprofeno'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '20/400 mg')
 where sku = 'EQ-LIF153';

-- EQ-APO142 · Espadiva 10 Tab 20/400 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Apotex'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Hioscina / Ibuprofeno'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Hioscina / Ibuprofeno'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '20/400 mg')
 where sku = 'EQ-APO142';

-- EQ-BEA336 · Neomi/Cao/Pecti 20tab 129/280/30 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Neomicina / Caolín y Pectina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Neomicina / Caolín y Pectina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '129 mg')
 where sku = 'EQ-BEA336';

-- EQ-AMS463 · Butilhioscina 10 Tab 10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Butilhioscina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Butilhioscina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 10 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg')
 where sku = 'EQ-AMS463';

-- EQ-ALP0526 · Clioquinol 1 Cma 3% 20 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Alpharma'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Clioquinol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Clioquinol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Crema 3 % C/tubo 20 g ALPHARMA'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Crema'),
    concentracion = coalesce(nullif(concentracion, ''), '3% 20 G')
 where sku = 'EQ-ALP0526';

-- EQ-BRL072 · Lo Bruquin 2 Tab 150/200 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Bruluart'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Quinfamida / Albendazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Quinfamida / Albendazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 2 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '150/200 mg')
 where sku = 'EQ-BRL072';

-- EQ-BIO021 · Docsi 20 Tab 4 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Biomep'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Clorfenamina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Clorfenamina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '4 mg')
 where sku = 'EQ-BIO021';

-- EQ-COD060 · Maracina 1 Spray 30 Ml 150 Mg /100 Ml · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Suanca'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Bencidamina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Bencidamina')
 where sku = 'EQ-COD060';

-- EQ-STR008 · Trociletas-B Limon. 12 Tab 2.5/10 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Streger'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Cloruro de cetilpiridinio / Benzocaína'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Cloruro de cetilpiridinio / Benzocaína'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 12 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '2.5/10 mg')
 where sku = 'EQ-STR008';

-- EQ-BIO138 · Lozamir-C 1 Cma 1/30 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Biomep'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Clotrimazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Clotrimazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Crema 1.0 g / 100 g C/tubo 30 g BIOMEP'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Crema'),
    concentracion = coalesce(nullif(concentracion, ''), '1/30 G')
 where sku = 'EQ-BIO138';

-- EQ-PGE046 · Progelben 20 Caps 100 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Progela'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Benzonato'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Benzonato'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '100 mg')
 where sku = 'EQ-PGE046';

-- EQ-BIO188 · Broxtorfan Inf 1 Jbe 150/113 Mg/120 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Biomep'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Dextrometorfano / Ambroxol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Dextrometorfano / Ambroxol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 frasco'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Jarabe'),
    concentracion = coalesce(nullif(concentracion, ''), '150/113 mg/120 mL')
 where sku = 'EQ-BIO188';

-- EQ-FAC0057 · Farmiver Infantil 1 Susp 100/400mg/10 · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Fármacos Continentales'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Quinfamida / Albendazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Quinfamida / Albendazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 suspensión'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspensión'),
    concentracion = coalesce(nullif(concentracion, ''), '100/400mg/10')
 where sku = 'EQ-FAC0057';

-- EQ-SON164 · Clotrinazol Dual 3 Ovs 200mg 1cma 10g · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Clotrimazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Clotrimazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 3 óvulos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Óvulo'),
    concentracion = coalesce(nullif(concentracion, ''), '200 mg')
 where sku = 'EQ-SON164';

-- EQ-HIS045 · Cifhir 1 Gel 60g/5 % · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Hispanoamericana'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Bencidamina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Bencidamina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 tubo'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Gel'),
    concentracion = coalesce(nullif(concentracion, ''), '5%')
 where sku = 'EQ-HIS045';

-- EQ-WER025 · Amantadina(Rosel) 24 Caps 50/3/300 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Wermar'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Amantadina / Clorfenamina / Paracetamol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Amantadina / Clorfenamina / Paracetamol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 24 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '50/3/300 mg')
 where sku = 'EQ-WER025';

-- EQ-LOE131 · Faribrox Tm Inf 1 Jbe 150/113mg/100/150 · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Loeffler'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Ambroxol / Dextrometorfano'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Ambroxol / Dextrometorfano'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 frasco'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Jarabe'),
    concentracion = coalesce(nullif(concentracion, ''), '150/113mg/100/150')
 where sku = 'EQ-LOE131';

-- EQ-MAV410 · Benzocaina 1 Gel 10 G .1/1 G · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Benzocaína'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Benzocaína'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 tubo'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Gel')
 where sku = 'EQ-MAV410';

-- EQ-SER183 · Murreolak 20 Tab Efervecentes 600 Mg · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Serral'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Acetilcisteína'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Acetilcisteína'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), 'EFERVECENTES 600 mg')
 where sku = 'EQ-SER183';

-- EQ-CMD015 · Materfol 90 Comp 0.4 Mg · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'CMD'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Ácido fólico'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Ácido fólico'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 90 comprimidos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Comprimidos'),
    concentracion = coalesce(nullif(concentracion, ''), '0.4 mg')
 where sku = 'EQ-CMD015';

-- EQ-MAV387 · Trimebut/Simetic Sup Ped 0.60g/0.60g · levic + nombre
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Trimebutina / Simeticona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Trimebutina / Simeticona'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Suspensión'),
    presentacion = coalesce(nullif(presentacion, ''), 'Sobre + frasco pediátrico')
 where sku = 'EQ-MAV387';

-- EQ-QUM052 · Quimikan 1 Sol C/ Apli 10 Ml 200mg/ 1 Ml · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Quimpharma'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Benzocaína'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Benzocaína'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 solución'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución'),
    concentracion = coalesce(nullif(concentracion, ''), '200 mg')
 where sku = 'EQ-QUM052';

-- EQ-LIF064 · Cineprac 20 Tab 200 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Liferpal'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Trimebutina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Trimebutina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '200 mg')
 where sku = 'EQ-LIF064';

-- EQ-NUC034 · Tefilinb 28 Tab 2 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Nucitec'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Tolterodina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Tolterodina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 28 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '2 mg')
 where sku = 'EQ-NUC034';

-- EQ-BIO112 · Gristalit 1 Jbe 600/100mg/30 Ml · levic,foto-pa,parser-pres
update public.productos set
    principio_activo = coalesce(nullif(principio_activo, ''), 'Loratadina / Ambroxol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Loratadina / Ambroxol'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Jarabe'),
    concentracion = coalesce(nullif(concentracion, ''), '600/100mg/30 mL')
 where sku = 'EQ-BIO112';

-- EQ-SON220 · Clotrimazol 1 Ov 500 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Clotrimazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Clotrimazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 óvulo'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Óvulo'),
    concentracion = coalesce(nullif(concentracion, ''), '500 mg')
 where sku = 'EQ-SON220';

-- EQ-DEN074 · Delaphil 14 Tab 5 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Dentilab'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Tadalafil'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Tadalafil'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '5 mg')
 where sku = 'EQ-DEN074';

-- EQ-BEA403 · Tamsulosina 20 Caps 0.4 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Be Advance'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Tamsulosina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Tamsulosina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 20 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '0.4 mg')
 where sku = 'EQ-BEA403';

-- EQ-MAV208 · Versalver 30 Comp 80 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Valsartán'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Valsartán'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 comprimidos'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Comprimido'),
    concentracion = coalesce(nullif(concentracion, ''), '80 mg')
 where sku = 'EQ-MAV208';

-- EQ-SER117 · Lisertil 30 Tab 2.5 Mg · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Serral'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Tibolona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Tibolona'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 30 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
    concentracion = coalesce(nullif(concentracion, ''), '2.5 mg')
 where sku = 'EQ-SER117';

-- EQ-MAV401 · Dexpantenol 1 Cma 5% 30 G · levic,parser-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Maver'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Dexpantenol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Dexpantenol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 1 tubo'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Crema'),
    concentracion = coalesce(nullif(concentracion, ''), '5% 30 G')
 where sku = 'EQ-MAV401';

-- EQ-BRL072-1 · Lo Bruquin 2 Tab 150/200 Mg · misma caja que EQ-BRL072
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Bruluart'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Quinfamida / Albendazol'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Quinfamida / Albendazol'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 2 tabletas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas'),
    concentracion = coalesce(nullif(concentracion, ''), '150/200 mg')
 where sku = 'EQ-BRL072-1';

-- FC-49025967 · Pregabalina 75 mg C/14 AMSA · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pregabalina'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pregabalina'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 14 cápsulas'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula'),
    concentracion = coalesce(nullif(concentracion, ''), '75 mg')
 where sku = 'FC-49025967';

-- FC-01162365 · Mornin (Omeprazol) 40 mg C/7 SON'S · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'Son''s'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Cápsula')
 where sku = 'FC-01162365';

-- FC-49024151 · Metoclopramida inyectable 10 mg/2 mL C/6 AMSA · levic,foto-pa,foto-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Metoclopramida'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Metoclopramida'),
    presentacion = coalesce(nullif(presentacion, ''), 'Caja con 6 soluciones'),
    forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Solución'),
    concentracion = coalesce(nullif(concentracion, ''), '10 mg/2 mL')
 where sku = 'FC-49024151';

-- FC-49024175 · Pioglitazona 30 mg AMSA · levic,foto-pa,parser-pres
update public.productos set
    marca = coalesce(nullif(marca, ''), 'AMSA'),
    principio_activo = coalesce(nullif(principio_activo, ''), 'Pioglitazona'),
    denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Pioglitazona')
 where sku = 'FC-49024175';

commit;
