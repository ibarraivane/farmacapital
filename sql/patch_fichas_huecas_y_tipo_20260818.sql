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


-- ── Tipo: genérico vs marca (patente de origen) ──────────────

-- Similares / INN / laboratorio genérico (570)
update public.productos
   set tipo = 'generico'
 where sku in ('FC-C721E8D7', 'FC-B25B4654', 'FC-ACA2A2F6', 'FC-D5AC44CA', 'FC-9A4E4C31', 'FC-40CE757D', 'FC-B18E386A', 'FC-1DA570E3', 'FC-A455EE80', 'FC-E374F23E', 'FC-8FB65B79', 'FC-2EDC6E3B', 'FC-C101D5B1', 'FC-CF18C740', 'FC-6EAD98A9', 'FC-CF719C07', 'FC-60F627D5', 'FC-492D652F', 'FC-86A95D07', 'FC-697EEAD0', 'FC-830BF3FB', 'FC-F3E734A0', 'FC-74A5ABEE', 'FC-AEA8C8DA', 'FC-2005DD57', 'FC-B4477A00', 'FC-85BDBD3D', 'FC-7AA38F97', 'FC-01B2F362', 'FC-50587FA6', 'FC-B72A6420', 'FC-D9391288', 'FC-41339950', 'FC-E6112F15', 'FC-F183C6E9', 'FC-A0D320D1', 'FC-4C621D07', 'FC-022543CD', 'FC-D210172A', 'FC-7F90064A', 'FC-F82A6E4B', 'FC-5F30F9D4', 'FC-516C2E89', 'FC-05965071', 'FC-405A75E3', 'FC-D06E54FE', 'FC-3A4583F3', 'FC-F22C72BE', 'FC-F48FF7EF', 'FC-4BD80686', 'FC-974EE5FD', 'FC-6519183A', 'FC-DDFBABDF', 'FC-C9F4ACCC', 'FC-17376CAE', 'FC-369D1689', 'FC-B69FCBF4', 'FC-F4E9C71F', 'FC-428A228F', 'FC-FD845E68', 'FC-B2123139', 'FC-11294615', 'FC-1FEA2FB7', 'FC-AE5EEDF7', 'FC-F8691496', 'FC-6074BB64', 'FC-E826D304', 'FC-4F737E93', 'FC-DB3B2584', 'FC-22B18244', 'FC-4A0245DA', 'FC-29670370', 'FC-69A3C416', 'FC-F817BC3A', 'FC-447B30F9', 'FC-3CAA7C5C', 'FC-E6B50AC3', 'FC-DB4A39AE', 'FC-63975795', 'FC-C6C20517')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('FC-58DB24C4', 'FC-1FFBB505', 'FC-A909ABC0', 'FC-82F88FED', 'FC-3B001F9B', 'FC-B25094C4', 'FC-26EA40A4', 'FC-885F2723', 'FC-DF8ADDAB', 'FC-50AC2C82', 'FC-281E0F22', 'FC-9F67BB73', 'FC-00422511', 'FC-C636D8EA', 'FC-9B93AC4C', 'FC-2001A890', 'FC-DE106642', 'FC-BE76D409', 'FC-07F04F88', 'FC-357D4A17', 'FC-5D9DFA3D', 'FC-E9C38DC4', 'FC-347A49C7', 'FC-E4BE37BE', 'FC-6898B64F', 'FC-5C8C9C11', 'FC-A23F290E', 'FC-5885E577', 'FC-3D0F54B7', 'FC-F7A2CACF', 'FC-50D044FF', 'FC-E535DE28', 'FC-9A37D44A', 'FC-1BF03D35', 'FC-5BC5F234', 'FC-A2B284E0', 'FC-2E79C2D8', 'FC-28A424E5', 'FC-52D2A43A', 'FC-3D0ED22B', 'FC-04D83B46', 'FC-D11D586A', 'FC-53506FA4', 'FC-F7DB080D', 'FC-FD92D114', 'FC-57925EF3', 'FC-27875568', 'FC-EADF1484', 'FC-262F2A30', 'FC-1DAD5EF1', 'FC-759A5EF9', 'FC-92504539', 'FC-92506045', 'FC-82790016', 'FC-62746605', 'FC-45307181', 'FC-88947797', 'FC-95467264', 'FC-88915491', 'FC-08895196', 'FC-1FBF5206', 'FC-2E5B7248', 'FC-E69F2E63', 'FC-B8D7C997', 'FC-08DB70CB', 'FC-D751525D', 'FC-4F05124E', 'FC-1812D26D', 'FC-53601247', 'FC-12225027', 'FC-54221482', 'FC-71829601', 'FC-12250181', 'FC-40036354', 'FC-83146207', 'FC-69200016', 'FC-37164713', 'FC-37163266', 'FC-9525015', 'FC-5112881')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('FC-85278507', 'FC-2225010', 'FC-053610', 'FC-070839', 'FC-08344501', 'FC-9303047', 'FC-7426449', 'FC-7048853', 'FC-8505126', 'FC-00204798', 'FC-9892403', 'FC-08344716', 'FC-13071164', 'FC-9890331', 'FC-08100013', 'FC-1041884', 'FC-9741524', 'FC-0287855', 'FC-0211225', 'FC-88579615', 'FC-09745027', 'FC-09745560', 'FC-09745584', 'FC-75717914', 'FC-75713770', 'FC-75718676', 'FC-75723137', 'FC-24901059', 'FC-09747236', 'FC-09749209', 'FC-03388008', 'FC-18754259', 'FC-73906469', 'FC-27427392', 'FC-03738879', 'FC-01165953', 'FC-11165726', 'FC-23111387', 'FC-53601339', 'FC-04908738', 'FC-16803800', 'FC-82200016', 'FC-31405888', 'FC-36003621', 'FC-27872123', 'FC-27871416', 'FC-09747366', 'FC-103521', 'FC-08344495', 'FC-50003314', 'FC-11780359', 'FC-75710113', 'FC-36000828', 'FC-75723830', 'FC-01166578', 'FC-75710465', 'FC-86100158', 'FC-25304555', 'FC-73903260', 'FC-73903246', 'FC-08895042', 'FC-37103354', 'FC-08100099', 'FC-09740268', 'FC-83144302', 'FC-09747779', 'FC-11788928', 'FC-27424995', 'FC-11788690', 'FC-83141929', 'FC-01165045', 'FC-36009661', 'FC-11783282', 'FC-25300366', 'FC-25300373', 'FC-01165298', 'FC-83144807', 'FC-09747168', 'FC-71800210', 'FC-27425008')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('FC-47521025', 'FC-25304142', 'FC-08344303', 'FC-09740657', 'FC-18753597', 'FC-73906407', 'FC-09745539', 'FC-04908714', 'FC-06922711', 'FC-06922728', 'FC-06920021', 'FC-73902966', 'FC-09760541', 'FC-09790739', 'FC-09790029', 'FC-58207010', 'FC-09745997', 'FC-26291475', 'FC-08344150', 'FC-90287992', 'FC-01163232', 'FC-40450230', 'FC-73902584', 'FC-73909859', 'FC-09745393', 'FC-49020337', 'FC-49025844', 'FC-83142308', 'FC-00005823', 'FC-36006042', 'FC-36006028', 'FC-74792047', 'FC-74792061', 'FC-03388107', 'FC-01007656', 'FC-01007663', 'EQ-HIS075', 'EQ-NOV025', 'EQ-MAV142', 'EQ-WER038', 'EQ-SON039', 'EQ-SON237', 'EQ-MAI071', 'EQ-ALP0300', 'EQ-AMS398', 'EQ-WAN013', 'EQ-SON160', 'EQ-HIS085', 'EQ-RAD096', 'EQ-PGE052', 'EQ-AMS406', 'EQ-NOV165', 'EQ-HIS076', 'EQ-HIS087', 'EQ-SON256', 'EQ-SON264', 'EQ-MAI141', 'EQ-COL226', 'EQ-MAI099', 'EQ-COL120', 'EQ-MAV322', 'EQ-QUM070', 'EQ-MAV311', 'EQ-RAD081', 'EQ-MAI078', 'EQ-ULT103', 'EQ-ACC066', 'EQ-VIC030', 'EQ-MAV415', 'EQ-AMS274', 'EQ-BIO100', 'EQ-RAD082', 'EQ-BEA379', 'EQ-BRU053', 'EQ-MAV236', 'EQ-SON193', 'EQ-SER025', 'EQ-BEA342', 'EQ-MAI055', 'EQ-SON024')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('EQ-AMS472', 'EQ-MAV065', 'EQ-RAD100', 'EQ-AMS460', 'EQ-QUM043', 'EQ-BRU016', 'EQ-MAV320', 'EQ-JAY263', 'EQ-WER046', 'EQ-ALP0633', 'EQ-MAV140', 'EQ-RAD092', 'EQ-SON214', 'EQ-AVT203', 'EQ-OFF009', 'EQ-DEG011', 'EQ-PGE059', 'EQ-AMS288', 'EQ-BIO212', 'EQ-EXA042', 'EQ-AMS209', 'EQ-AMS428', 'EQ-LOE058', 'EQ-MAV378', 'EQ-SON204', 'EQ-AMS497', 'EQ-SER001', 'EQ-MAV043', 'EQ-AMS160', 'EQ-LOE013', 'EQ-QUM014', 'EQ-NOV032', 'EQ-MAI152', 'EQ-ULT230', 'EQ-COL073', 'EQ-IFA001', 'EQ-SOF041', 'EQ-TEM009', 'EQ-MAV358', 'EQ-NOV154', 'EQ-MAI144', 'EQ-ULT145', 'EQ-AVT216', 'EQ-HIS081', 'EQ-BEA338', 'EQ-MAV331', 'EQ-AMS323', 'EQ-ULT146', 'EQ-AMS232', 'EQ-MAV407', 'EQ-COL133', 'EQ-QUM068', 'EQ-PGE061', 'EQ-AMS498', 'EQ-SON225', 'EQ-LOE096', 'EQ-AMS370', 'EQ-SER116', 'EQ-NOV054', 'EQ-MAV198', 'EQ-PHG017', 'EQ-LOE135', 'EQ-ULT191', 'EQ-ALP0410', 'EQ-BEA368', 'EQ-EXA035', 'EQ-EXA045', 'EQ-NOV176', 'EQ-SON096', 'EQ-MAV307', 'EQ-SON153', 'EQ-MAI163', 'EQ-NOV092', 'EQ-AMS503', 'EQ-LOE066', 'EQ-SON104', 'EQ-BIO017', 'EQ-QUM006', 'EQ-MAV266', 'EQ-RAD093')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('EQ-MAV162', 'EQ-SER165', 'EQ-SON098', 'EQ-LOE014', 'EQ-SON089', 'EQ-NOV004', 'EQ-BEA416', 'EQ-BEA424', 'EQ-BRL053', 'EQ-MAV392', 'EQ-MAI150', 'EQ-NOV157', 'EQ-BIO058', 'EQ-BEA429', 'EQ-ULT056', 'EQ-WER040', 'EQ-MAV175', 'EQ-LIF006', 'EQ-SON034', 'EQ-AVT213', 'EQ-BIO003', 'EQ-SON175', 'EQ-BEA468', 'EQ-SON091', 'EQ-BEA426', 'EQ-COL016', 'EQ-VIT073', 'EQ-COD086', 'EQ-VIT055', 'EQ-NOV137', 'EQ-COL239', 'EQ-LIF039', 'EQ-LIF153', 'EQ-APO142', 'EQ-BEA336', 'EQ-AMS463', 'EQ-QUI096', 'EQ-ALP0526', 'EQ-BRL072', 'EQ-BIO021', 'EQ-COD060', 'EQ-STR008', 'EQ-BIO138', 'EQ-PGE046', 'EQ-BIO188', 'EQ-FAC0057', 'EQ-SON164', 'EQ-HIS045', 'EQ-WER025', 'EQ-LOE131', 'EQ-MAV410', 'EQ-BIO167', 'EQ-SER183', 'EQ-CMD015', 'EQ-MAV387', 'EQ-MAV239', 'EQ-QUM052', 'EQ-COL258', 'EQ-LIF064', 'EQ-NUC034', 'EQ-BIO112', 'EQ-ULT224', 'EQ-SON220', 'EQ-LIF033', 'EQ-DEN074', 'EQ-BEA403', 'EQ-MAV208', 'EQ-SER117', 'EQ-RAM014', 'EQ-MAV401', 'EQ-MAV263', 'EQ-NOV179', 'EQ-GEP049', 'EQ-AMS292', 'EQ-SON233', 'EQ-SAN025', 'EQ-QUI091', 'EQ-PYG016', 'EQ-BRL072-1', 'FC-20089077')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('FC-30713851', 'FC-30713547', 'FC-MULIER30', 'FMX-302947', 'FMX-502700', 'FMX-501619', 'FMX-505937', 'FMX-502465', 'FMX-301721', 'FMX-500999', 'FMX-504851', 'FMX-502473', 'FMX-302138', 'FMX-302906', 'FMX-302907', 'FMX-300936', 'FMX-500311', 'FMX-502046', 'FMX-502376', 'FMX-301546', 'FMX-301081', 'FMX-504790', 'FMX-303355', 'FMX-507495', 'FMX-505399', 'FMX-502386', 'FMX-302287', 'FMX-505289', 'FMX-302206', 'FMX-307626', 'FMX-303280', 'FMX-503320', 'FC-09749421', 'FMX-501003', 'FMX-500998', 'FMX-501000', 'FMX-503473', 'FMX-501200', 'FC-49025967', 'FC-01162365', 'FC-49024151', 'FC-49024175', 'FC-42803524', 'FC-83141226', 'FC-49020269', 'FC-02045312', 'FC-49028913', 'FC-49021570', 'FC-01007250', 'FC-01007199', 'FC-28833707', 'FC-09741425', 'FC-52200809', 'FC-49021044', 'FC-09741043', 'FC-09745140', 'FC-90973703', 'EQ-AMS424', 'EQ-AVT135', 'EQ-MAV380', 'EQ-AMS328', 'EQ-AMS253', 'EQ-AMS362', 'EQ-BEA313', 'EQ-AMS221', 'EQ-AMS275', 'EQ-MAV295', 'EQ-MAV187', 'EQ-MAV318', 'EQ-MAV134', 'EQ-MAV167', 'EQ-MAV064', 'EQ-MAV115', 'EQ-MAV182', 'EQ-MAV174', 'EQ-MAV228', 'EQ-OFF008', 'EQ-OFF010', 'EQ-AVT205', 'EQ-LOE155')
   and coalesce(tipo, '') is distinct from 'generico';

update public.productos
   set tipo = 'generico'
 where sku in ('EQ-LOE132', 'EQ-SON033', 'EQ-SON092', 'EQ-FAC0058', 'EQ-SER093', 'EQ-ALP0628', 'EQ-MAI142', 'EQ-PGE033', 'EQ-AMS407', 'EQ-QUI127')
   and coalesce(tipo, '') is distinct from 'generico';

-- Patente u OTC de origen (valor UI: marca) (554)
update public.productos
   set tipo = 'marca'
 where sku in ('FC-95779436', 'FC-64EB83AA', 'FC-7D1D9857', 'FC-6B2ADEE9', 'FC-6C2878CF', 'FC-44B6751A', 'FC-1321B34F', 'FC-3E863E37', 'FC-9ABFB996', 'FC-AA7B0686', 'FC-52844825', 'FC-52933307', 'FC-27250612', 'FC-27286017', 'FC-52876406', 'FC-30622622', 'FC-06213906', 'FC-93037806', 'FC-55280956', 'FC-93025919', 'FC-93022567', 'FC-06244795', 'FC-75076009', 'FC-93025797', 'FC-93038223', 'FC-75062897', 'FC-06245686', 'FC-93025865', 'FC-22105207', 'FC-38891190', 'FC-75062927', 'FC-40036965', 'FC-40004643', 'FC-22150801', 'FC-25605514', 'FC-14119032', 'FC-06230507', 'FC-22150092', 'FC-22111352', 'FC-75069223', 'FC-46059556', 'FC-67905186', 'FC-46683133', 'FC-06241206', 'FC-43489004', 'FC-42326414', 'FC-76000284', 'FC-82790504', 'FC-45722547', 'FC-67905131', 'FC-21012303', 'FC-14121782', 'FC-25652716', 'FC-06248052', 'FC-06248045', 'FC-35911208', 'FC-08837311', 'FC-06209862', 'FC-43489165', 'FC-84900280', 'FC-06226852', 'FC-46657035', 'FC-56330378', 'FC-76040436', 'FC-61113000', 'FC-61123009', 'FC-41500096', 'FC-20500201', 'FC-72300171', 'FC-06217461', 'FC-82740011', 'FC-52910971', 'FC-52816297', 'FC-40025839', 'FC-40030338', 'FC-45720550', 'FC-92511261', 'FC-92509213', 'FC-06257597', 'FC-46073156')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-20500171', 'FC-35155922', 'FC-07457826', 'FC-56340131', 'FC-01165321', 'FC-06249783', 'FC-56360429', 'FC-56340025', 'FC-56342227', 'FC-06249776', 'FC-01303454', 'FC-07457796', 'FC-35155847', 'FC-06249240', 'FC-06249226', 'FC-24511629', 'FC-06234062', 'FC-56342258', 'FC-61111501', 'FC-61124013', 'FC-56340124', 'FC-35020008', 'FC-35169035', 'FC-35168991', 'FC-35231237', 'FC-38312374', 'FC-35231244', 'FC-35020077', 'FC-92503558', 'FC-99425580', 'FC-99428024', 'FC-46073040', 'FC-46073033', 'FC-54073302', 'FC-24511711', 'FC-24511636', 'FC-75001865', 'FC-46655055', 'FC-06247468', 'FC-92506601', 'FC-86494262', 'FC-84431050', 'FC-45720567', 'FC-84437151', 'FC-48640775', 'FC-48640799', 'FC-46640629', 'FC-48640751', 'FC-26462078', 'FC-54500216', 'FC-75064938', 'FC-20501673', 'FC-08802838', 'FC-36040450', 'FC-56330309', 'FC-42270027', 'FC-00942760', 'FC-54504535', 'FC-40030963', 'FC-26462061', 'FC-35469151', 'FC-36032776', 'FC-07502441', 'FC-46655079', 'FC-36041402', 'FC-07528939', 'FC-31244486', 'FC-46074504', 'FC-36033735', 'FC-46650708', 'FC-22133286', 'FC-86472048', 'FC-09498091', 'FC-95129166', 'FC-42417644', 'FC-09419324', 'FC-40013898', 'FC-54549819', 'FC-17360604', 'FC-46072050')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-22150221', 'FC-20501765', 'FC-56326142', 'FC-48691005', 'FC-31976394', 'FC-43427754', 'FC-31887928', 'FC-54503095', 'FC-85800198', 'FC-72629012', 'FC-10974329', 'FC-00701992', 'FC-46655727', 'FC-35908130', 'FC-48691104', 'FC-35908147', 'FC-19006371', 'FC-85103015', 'FC-48690800', 'FC-40171550', 'FC-48690909', 'FC-68900264', 'FC-68960257', 'FC-68900226', 'FC-68990023', 'FC-77620056', 'FC-00003920', 'FC-76000260', 'FC-76000253', 'FC-16800803', 'FC-86901100', 'FC-68901131', 'FC-68901117', 'FC-68901124', 'FC-33950100', 'FC-33950063', 'FC-33950070', 'FC-33956133', 'FC-33956140', 'FC-07521317', 'FC-01157296', 'FC-01405335', 'FC-33951008', 'FC-33950209', 'FC-19006623', 'FC-56131681', 'FC-60009851', 'FC-23273451', 'FC-75163051', 'FC-27512574', 'FC-75125811', 'FC-34067851', 'FC-48623006', 'FC-23272151', 'FC-68910041', 'FC-89100101', 'FC-3406723', 'FC-34067471', 'FC-34067781', 'FC-68910034', 'FC-66534951', 'FC-83510531', 'FC-68900127', 'FC-68900134', 'FC-50882017', 'FC-50882024', 'FC-76000277', 'FC-01163983', 'FC-83351691', 'FC-83351381', 'FC-33956775', 'FC-33961373', 'FC-48335305', 'FC-33954740', 'FC-59225411', 'FC-51067711', 'FC-86167151', 'FC-92821171', 'FC-58611420', 'FC-51078461')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-51078531', 'FC-29003221', 'FC-51448511', 'FC-25104411', 'FC-25149221', 'FC-25104268', 'FC-51747971', 'FC-43471900', 'FC-34064021', 'FC-14983153', 'FC-43454811', 'FC-49824391', 'FC-14985348', 'FC-49853867', 'FC-49824911', 'FC-14985805', 'FC-14983726', 'FC-49824771', 'FC-58203691', 'FC-14982514', 'FC-45079011', 'FC-14980596', 'FC-49800151', 'FC-45045281', 'FC-54504870', 'FC-52400212', 'FC-24004581', 'FC-56034041', 'FC-21042481', 'FC-52400267', 'FC-62746612', 'FC-52400038', 'FC-62746698', 'FC-62746643', 'FC-65054135', 'FC-56323066', 'FC-56323059', 'FC-01246730', 'FC-02012475', 'FC-02012468', 'FC-76040610', 'FC-60101231', 'FC-87154871', 'FC-60101521', 'FC-06134531', 'FC-08427330', 'FC-58792792', 'FC-50002301', 'FC-28979502', 'FC-89794961', 'FC-79071241', 'FC-47624171', 'FC-80950139', 'FC-50959781', 'FC-80953017', 'FC-54521161', 'FC-95201021', 'FC-08485316', 'FC-65095947', 'FC-95451096', 'FC-79400556', 'FC-58793249', 'FC-87932321', 'FC-08443026', 'FC-75354321', 'FC-08491074', 'FC-70612368', 'FC-88508929', 'FC-84335531', 'FC-23001331', 'FC-85592111', 'FC-84999001', 'FC-08498798', 'FC-08491096', 'FC-50003151', 'FC-24227339', 'FC-98100381', 'FC-14704156', 'FC-14704163', 'FC-08344488')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-65095718', 'FC-01015141', 'FC-08496701', 'FC-08344747', 'FC-89810021', 'FC-60101378', 'FC-60403681', 'FC-88923551', 'FC-25116810', 'FC-35246309', 'FC-47640531', 'FC-84095411', 'FC-85097661', 'FC-06247327', 'FC-84973401', 'FC-08426944', 'FC-82176351', 'FC-30133021', 'FC-98217659', 'FC-66888171', 'FC-66873531', 'FC-86708021', 'FC-03406600', 'FC-03406501', 'FC-34063651', 'FC-34062421', 'FC-60689091', 'FC-73629981', 'FC-62034164', 'FC-3676D5DC', 'FC-5A697CC2', 'FC-39036C88', 'FC-DFF99C3F', 'FC-931B4809', 'FC-D4AC123B', 'FC-38CAFE6B', 'FC-926099D3', 'FC-25E452B6', 'FC-127F5753', 'FC-D3D28E20', 'FC-69387811', 'FC-A680F97E', 'FC-C4530823', 'FC-D037156B', 'FC-CB5C11ED', 'FC-A871D831', 'FC-578F060C', 'FC-FBD776D2', 'FC-5EF90195', 'FC-9A1C64E7', 'FC-47AAF23B', 'FC-FFC25DD1', 'FC-614E4F82', 'FC-C22EBFE6', 'FC-BCF59548', 'FC-9507CD66', 'FC-FEAECBF1', 'FC-9827438F', 'FC-EFB599B5', 'FC-89F00320', 'FC-FD718DF3', 'FC-0ACC5B6A', 'FC-5D59ED54', 'FC-66055303', 'FC-00E8A9C7', 'FC-DA34D88D', 'FC-BE2ACF63', 'FC-DF39BB27', 'FC-C8B741F6', 'FC-BE0A0E46', 'FC-43475014', 'FC-33954078', 'FC-33956126', 'FC-56371159', 'FC-06226739', 'FC-35919129', 'FC-46073118', 'FC-56340117', 'FC-01303464', 'FC-06237407')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-46682815', 'FC-54549796', 'FC-36041273', 'FC-40013850', 'FC-35908116', 'FC-22322395', 'FC-84500522', 'FC-84500607', 'FC-40017100', 'FC-00170941', 'FC-00525451', 'FC-12225164', 'FC-03430721', 'FC-03405381', 'FC-40015366', 'FC-40010538', 'FC-00740024', 'FC-50608272', 'FC-92730451', 'FC-80596011', 'FC-54525051', 'FC-00315021', 'FC-40010712', 'FC-85171118', 'FC-58367129', 'FC-83683367', 'FC-34092301', 'FC-58715517', 'FC-01508201', 'FC-5008473', 'FC-54054221', 'FC-50724298', 'FC-64560163', 'FC-40006647', 'FC-00322571', 'FC-40032264', 'FC-40032271', 'FC-40032295', 'FC-00323011', 'FC-40032325', 'FC-40035395', 'FC-00661391', 'FC-40066306', 'FC-00721471', 'FC-00721541', 'FC-00744481', 'FC-40074455', 'FC-54558682', 'FC-85171113', 'FC-8062229', 'FC-8497593', 'FC-8421321', 'FC-08421321', 'FC-08499702', 'FC-07535494', 'FC-98215099', 'FC-08499818', 'FC-08443033', 'FC-46642073', 'FC-08485408', 'FC-08499689', 'FC-7907117', 'FC-00753067', 'FC-9490651', 'FC-8494226', 'FC-9511421', 'FC-85132069', 'FC-5181402', 'FC-8645080', 'FC-8491966', 'FC-6040351', 'FC-14704187', 'FC-8281209', 'FC-002663', 'FC-8505003', 'FC-013340', 'FC-007206', 'FC-09839202', 'FC-39390230', 'FC-9233072')
   and coalesce(tipo, '') is distinct from 'marca';

update public.productos
   set tipo = 'marca'
 where sku in ('FC-3961366', 'FC-10631207', 'FC-5106788', 'FC-8910003', 'FC-58616678', 'FC-25104688', 'FC-03476594', 'FC-36041389', 'FC-49835773', 'FC-50882000', 'FC-84471476', 'FC-42003469', 'FC-06903205', 'FC-43454873', 'FC-42303194', 'FC-90031475', 'FC-42302289', 'FC-49828111', 'FC-4980275', 'FC-84272103', 'FC-36041341', 'FC-36041297', 'FC-06910487', 'FC-22130063', 'FC-06910913', 'FC-42507240', 'FC-36041259', 'FC-70100307', 'FC-14980350', 'FC-9890973', 'FC-06910906', 'FC-8432071', 'FC-84273094', 'FC-4391156', 'FC-84154058', 'FC-5145497', 'FC-32911454', 'FC-18752637', 'FC-14377074', 'EQ-PBY007', 'EQ-PBY008', 'FC-09749063', 'FMX-506935', 'FMX-301138', 'FMX-302884', 'FMX-300861', 'FMX-303091', 'FMX-301516', 'FMX-300591', 'FMX-301025', 'FMX-506781', 'FMX-301565', 'FMX-302168', 'FMX-300644', 'FMX-504321', 'FMX-301139', 'FMX-307574', 'FMX-506779', 'FC-84500546', 'FC-25100123', 'FC-25100116', 'FC-22300881', 'FC-22300775', 'FMX-307657', 'FMX-307658', 'FMX-506389', 'FMX-506388', 'FMX-506386', 'FMX-301135', 'FMX-301136', 'FC-46601138', 'FC-00001612', 'FC-00001292', 'FC-00001049')
   and coalesce(tipo, '') is distinct from 'marca';

commit;
