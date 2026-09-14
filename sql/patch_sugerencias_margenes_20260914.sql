-- Sugerencias de PVP — márgenes abismales (14-sep-2026).
-- NO corre solo. Confirmar en Inventario → Margen raro, o Run en SQL Editor.
-- Calibración: Sedal Rizos 135 ml $9.08 → $20 (ya aplicado).
-- Idempotente: solo pisa si el PVP actual sigue por arriba del sugerido.

begin;

-- Escudo Rosa Cuidado · higiene · $4.48 → $42 ⇒ $10 (recargo 838%)
update public.productos
   set precio = 10
 where sku = 'FC-43489004'
   and activo = true
   and costo > 0
   and precio > 10;

-- Nivea Milk Crema corp 400 ML · higiene · $22.30 → $207 ⇒ $50 (recargo 828%)
update public.productos
   set precio = 50
 where sku = 'FC-54558682'
   and activo = true
   and costo > 0
   and precio > 50;

-- Jabon Grisi Neutro · higiene · $6.96 → $56 ⇒ $16 (recargo 705%)
update public.productos
   set precio = 16
 where sku = 'FC-22105207'
   and activo = true
   and costo > 0
   and precio > 16;

-- Escudo Antibacterial Frescura · higiene · $7.23 → $42 ⇒ $16 (recargo 481%)
update public.productos
   set precio = 16
 where sku = 'FC-25605514'
   and activo = true
   and costo > 0
   and precio > 16;

-- Evenflo Colors · higiene · $15.48 → $63 ⇒ $35 (recargo 307%)
update public.productos
   set precio = 35
 where sku = 'FC-27512574'
   and activo = true
   and costo > 0
   and precio > 35;

-- Pert crema para peinar kera + aguacate 100 ml · higiene · $14.80 → $55 ⇒ $33 (recargo 272%)
update public.productos
   set precio = 33
 where sku = 'FC-20500164'
   and activo = true
   and costo > 0
   and precio > 33;

-- Toallas Kotex Nocturna Ext Largo cn alas · higiene · $5.01 → $16 ⇒ $12 (recargo 219%)
update public.productos
   set precio = 12
 where sku = 'FC-43427754'
   and activo = true
   and costo > 0
   and precio > 12;

-- Jabon Dove Original · higiene · $15.10 → $47 ⇒ $34 (recargo 211%)
update public.productos
   set precio = 34
 where sku = 'FC-38891190'
   and activo = true
   and costo > 0
   and precio > 34;

-- Escudo Antibacterial Original · higiene · $13.65 → $42 ⇒ $31 (recargo 208%)
update public.productos
   set precio = 31
 where sku = 'FC-25652716'
   and activo = true
   and costo > 0
   and precio > 31;

-- Claris toallas desmaquillantes aloe C/40 · higiene · $9.43 → $27 ⇒ $21 (recargo 186%)
update public.productos
   set precio = 21
 where sku = 'FC-21012303'
   and activo = true
   and costo > 0
   and precio > 21;

-- Toallas Saba Invisible con alas C/10 · higiene · $10.17 → $29 ⇒ $16 (recargo 185%)
update public.productos
   set precio = 16
 where sku = 'FC-19006371'
   and activo = true
   and costo > 0
   and precio > 16;

-- Desodorante Ego Force 24H roll-on · higiene · $11.95 → $34 ⇒ $27 (recargo 184%)
update public.productos
   set precio = 27
 where sku = 'FC-75064938'
   and activo = true
   and costo > 0
   and precio > 27;

-- Crema para peinar Pert aceite oliva aguacate · higiene · $7.40 → $21 ⇒ $17 (recargo 184%)
update public.productos
   set precio = 17
 where sku = 'FC-20500171'
   and activo = true
   and costo > 0
   and precio > 17;

-- Palmolive Neutro-Bal Dermo Limp · higiene · $13.07 → $37 ⇒ $29 (recargo 183%)
update public.productos
   set precio = 29
 where sku = 'FC-46683133'
   and activo = true
   and costo > 0
   and precio > 29;

-- Gel X-Treme Titan · higiene · $11.31 → $32 ⇒ $25 (recargo 183%)
update public.productos
   set precio = 25
 where sku = 'FC-99425580'
   and activo = true
   and costo > 0
   and precio > 25;

-- Gel Moco de Gorila Punk · higiene · $14.15 → $40 ⇒ $32 (recargo 183%)
update public.productos
   set precio = 32
 where sku = 'FC-99428024'
   and activo = true
   and costo > 0
   and precio > 32;

-- Nivea Antitransp Pearlb Spray · higiene · $32.37 → $91 ⇒ $56 (recargo 181%)
update public.productos
   set precio = 56
 where sku = 'FC-08837311'
   and activo = true
   and costo > 0
   and precio > 56;

-- Dove tono uniforme 72h · higiene · $32.14 → $90 ⇒ $71 (recargo 180%)
update public.productos
   set precio = 71
 where sku = 'FC-06241206'
   and activo = true
   and costo > 0
   and precio > 71;

-- Palmolive líquido neutro · higiene · $35.61 → $98 ⇒ $79 (recargo 175%)
update public.productos
   set precio = 79
 where sku = 'FC-46059556'
   and activo = true
   and costo > 0
   and precio > 79;

-- Desodorante Obao Ritual Natural Coco (Mujer) · higiene · $24.95 → $68 ⇒ $41 (recargo 172%)
update public.productos
   set precio = 41
 where sku = 'FC-52844825'
   and activo = true
   and costo > 0
   and precio > 41;

-- Crema Nivea Milk Nutritiva · higiene · $25.86 → $69 ⇒ $57 (recargo 167%)
update public.productos
   set precio = 57
 where sku = 'FC-54549796'
   and activo = true
   and costo > 0
   and precio > 57;

-- Desodorante Obao Piel Delicada · higiene · $25.83 → $68 ⇒ $57 (recargo 163%)
update public.productos
   set precio = 57
 where sku = 'FC-27250612'
   and activo = true
   and costo > 0
   and precio > 57;

-- Crema Nivea Softmilk · higiene · $26.30 → $69 ⇒ $56 (recargo 162%)
update public.productos
   set precio = 56
 where sku = 'FC-54549819'
   and activo = true
   and costo > 0
   and precio > 56;

-- Jabon Grisi Avena · higiene · $21.72 → $56 ⇒ $31 (recargo 158%)
update public.productos
   set precio = 31
 where sku = 'FC-22150801'
   and activo = true
   and costo > 0
   and precio > 31;

-- Grisi Leche De Burra · higiene · $21.88 → $56 ⇒ $49 (recargo 156%)
update public.productos
   set precio = 49
 where sku = 'FC-22150092'
   and activo = true
   and costo > 0
   and precio > 49;

-- Crema Nivea Softmilk · higiene · $84.49 → $207 ⇒ $186 (recargo 145%)
update public.productos
   set precio = 186
 where sku = 'FC-08802838'
   and activo = true
   and costo > 0
   and precio > 186;

-- Cepillo Dent Mayor Alcance Pro · higiene · $13.50 → $33 ⇒ $25 (recargo 144%)
update public.productos
   set precio = 25
 where sku = 'FC-86472048'
   and activo = true
   and costo > 0
   and precio > 25;

-- Prudence Natural Lubricante Natural · higiene · $62.06 → $139 ⇒ $87 (recargo 124%)
update public.productos
   set precio = 87
 where sku = 'FC-14983726'
   and activo = true
   and costo > 0
   and precio > 87;

-- Lubricante Intimo Prudence Grosella · higiene · $62.06 → $139 ⇒ $115 (recargo 124%)
update public.productos
   set precio = 115
 where sku = 'FC-14983153'
   and activo = true
   and costo > 0
   and precio > 115;

-- Prudence Lub lubricante íntimo mora azul 75 ml · higiene · $62.06 → $139 ⇒ $87 (recargo 124%)
update public.productos
   set precio = 87
 where sku = 'FC-14980350'
   and activo = true
   and costo > 0
   and precio > 87;

-- Cinitaprida 25 Comp 1 Mg · med_generico · $17.58 → $119 ⇒ $46 (recargo 577%)
update public.productos
   set precio = 46
 where sku = 'EQ-AMS406'
   and activo = true
   and costo > 0
   and precio > 46;

-- Erispan Compuesto 1 Sol 5/100mg/60 Ml · sin_clasificar · $22.53 → $112 ⇒ $59 (recargo 397%)
update public.productos
   set precio = 59
 where sku = 'EQ-MAV187'
   and activo = true
   and costo > 0
   and precio > 59;

-- Diclofenaco 20 Tab 100 Mg · med_generico · $7.60 → $35 ⇒ $20 (recargo 360%)
update public.productos
   set precio = 20
 where sku = 'EQ-ULT103'
   and activo = true
   and costo > 0
   and precio > 20;

-- Graneodin B Frambuesa · sin_clasificar · $42.64 → $193 ⇒ $111 (recargo 353%)
update public.productos
   set precio = 111
 where sku = 'FC-58715517'
   and activo = true
   and costo > 0
   and precio > 111;

-- BIO ELCTRO · sin_clasificar · $16.60 → $75 ⇒ $44 (recargo 352%)
update public.productos
   set precio = 44
 where sku = 'FC-40007651'
   and activo = true
   and costo > 0
   and precio > 44;

-- Pioglitazona · med_generico · $13.35 → $60 ⇒ $35 (recargo 349%)
update public.productos
   set precio = 35
 where sku = 'EQ-ULT146'
   and activo = true
   and costo > 0
   and precio > 35;

-- Diosmina Hesperidina · med_generico · $39.41 → $176 ⇒ $103 (recargo 347%)
update public.productos
   set precio = 103
 where sku = 'FC-EADF1484'
   and activo = true
   and costo > 0
   and precio > 103;

-- Amoxicilina · med_generico · $23.57 → $98 ⇒ $62 (recargo 316%)
update public.productos
   set precio = 62
 where sku = 'FC-F4E9C71F'
   and activo = true
   and costo > 0
   and precio > 62;

-- Clindamicina · med_generico · $30.54 → $120 ⇒ $80 (recargo 293%)
update public.productos
   set precio = 80
 where sku = 'FC-CF18C740'
   and activo = true
   and costo > 0
   and precio > 80;

-- Ercatriv M Calcitriol 30 Caps 0.25 Mcg · vitaminas · $47.13 → $167 ⇒ $95 (recargo 254%)
update public.productos
   set precio = 95
 where sku = 'EQ-PGE052'
   and activo = true
   and costo > 0
   and precio > 95;

-- Jarabe Ajolotiux Orig Con Miel · vitaminas · $28.00 → $98 ⇒ $43 (recargo 250%)
update public.productos
   set precio = 43
 where sku = 'FC-62746605'
   and activo = true
   and costo > 0
   and precio > 43;

-- Ketorolaco / Tramadol solución inyectable 10 mg - 25 mg / 1  · med_generico · $100.00 → $350 ⇒ $260 (recargo 250%)
update public.productos
   set precio = 260
 where sku = 'FC-49029040'
   and activo = true
   and costo > 0
   and precio > 260;

-- Bromuro-Pinaverio-Alpharma Tabletas 100 Mg C/14 · sin_clasificar · $16.88 → $59 ⇒ $44 (recargo 250%)
update public.productos
   set precio = 44
 where sku = 'FMX-307626'
   and activo = true
   and costo > 0
   and precio > 44;

-- Nido Kinder 1+ bolsa 144 g · impulso · $30.28 → $92 ⇒ $61 (recargo 204%)
update public.productos
   set precio = 61
 where sku = 'FC-9233072'
   and activo = true
   and costo > 0
   and precio > 61;

-- Leche en Polvo NAN Optimal Pro 2 / 6 a 12 M · bebe · $58.70 → $170 ⇒ $106 (recargo 190%)
update public.productos
   set precio = 106
 where sku = 'FC-51078531'
   and activo = true
   and costo > 0
   and precio > 106;

-- Dibenel cápsulas vitaminas omega 3 C/30 · vitaminas · $47.08 → $127 ⇒ $95 (recargo 170%)
update public.productos
   set precio = 95
 where sku = 'FC-0211225'
   and activo = true
   and costo > 0
   and precio > 95;

-- Leche en polvo NAN Optimal Pro 1/ 0 a 6 M · bebe · $63.41 → $170 ⇒ $115 (recargo 168%)
update public.productos
   set precio = 115
 where sku = 'FC-51078461'
   and activo = true
   and costo > 0
   and precio > 115;

commit;
