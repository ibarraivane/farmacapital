-- ============================================================================
-- FARMA CAPITAL — Vitaminas + dispositivos desde Farma Integral
-- 17-sep-2026
--
-- Fuente: https://farmacia-integral.odoo.com/shop (fichas públicas, no el slug).
-- 125 SKU(s) con packshot. Stock 0. Sin lote ni caducidad.
-- Precio shop > $1.50 = ancla Encargar; $0.01 = Cotizar (Integral no publica precio).
-- Si el EAN ya existe CON stock de anaquel: no se marca bajo_pedido.
--
-- ANTES: sql/patch_bajo_pedido_20260916.sql
-- DESPUÉS del deploy: las jpg viven en /catalogo-propia/
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'productos'
       and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql (falta productos.bajo_pedido)';
  end if;
end
$$;

create temp table _fc_vitrina_bp (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  precio numeric(12,2) not null,
  imagen_url text not null,
  descripcion text not null
) on commit drop;

insert into _fc_vitrina_bp values
  ('025715974804', 'FC-15974804', 'Ferula de Dedo Flents Dos Tamaños M/l Color Metalico', 'Flents', '1 pieza', 'Botiquín', 'Curación', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/ferula-de-dedo-flents-dos-tama-os-m-l-color-meta-025715974804.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g555825-ferula-de-dedo-flents-dos-tamanos-m-l-color-metalico-25904 · EAN 025715974804 · sin precio público (cotizar)'),
  ('4042809258813', 'FC-09258813', 'Hypafix Gasa Adhesiva 5mx10cm', 'Hypafix', '5m', 'Botiquín', 'Curación', 'Gasa', 270.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/hypafix-gasa-adhesiva-5mx10cm-4042809258813.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/m1bsnhyp10x5-hypafix-gasa-adhesiva-5mx10cm-18343 · EAN 4042809258813 · precio shop $270'),
  ('4042809591385', 'FC-09591385', 'Hypafix Leukoplast 10CM x 10metros', 'Hypafix', '10CM', 'Botiquín', 'Curación', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/hypafix-leukoplast-10cm-x-10metros-4042809591385.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b24551-hypafix-leukoplast-10cm-x-10metros-18347 · EAN 4042809591385 · sin precio público (cotizar)'),
  ('4042809001006', 'FC-09001006', 'Hypafix Leukoplast 10CM x 2metros', 'Hypafix', '10CM', 'Botiquín', 'Curación', 'Aparato', 120.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/hypafix-leukoplast-10cm-x-2metros-4042809001006.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/m1bsnhyp102m-hypafix-leukoplast-10cm-x-2metros-18342 · EAN 4042809001006 · precio shop $120'),
  ('7506022301772', 'FC-22301772', '100 Jeringas Hipodérmicas SensiMedical 22gx32mm 3ML', 'SensiMedical', '22g', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-hipod-rmicas-sensimedical-22gx32mm-7506022301772.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f482788-100-jeringas-hipodermicas-sensimedical-22gx32mm-3ml-25870 · EAN 7506022301772 · sin precio público (cotizar)'),
  ('7506022301888', 'FC-22301888', '100 Jeringas para Insulina SensiMedical 27G x 13MM (1/2) 1ML', 'SensiMedical', '27G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-para-insulina-sensimedical-27g-x-13-7506022301888.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b86786-100-jeringas-para-insulina-sensimedical-27g-x-13mm-1-2-1ml-20666 · EAN 7506022301888 · sin precio público (cotizar)'),
  ('7506022314505', 'FC-22314505', '100 Jeringas para Insulina SensiMedical 29G x 13MM 1ML', 'SensiMedical', '29G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-para-insulina-sensimedical-29g-x-13-7506022314505.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d221881939390-g877624-100-jeringas-para-insulina-sensimedical-29g-x-13mm-1ml-26129 · EAN 7506022314505 · sin precio público (cotizar)'),
  ('7506022327215', 'FC-22327215', '100 Jeringas para Insulina SensiMedical 31G x 6MM 0.3ML', 'SensiMedical', '31G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-para-insulina-sensimedical-31g-x-6m-7506022327215.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d8883901-100-jeringas-para-insulina-sensimedical-31g-x-6mm-0-3ml-20754 · EAN 7506022327215 · sin precio público (cotizar)'),
  ('7506022327345', 'FC-22327345', '100 Jeringas para Insulina SensiMedical 31G x 6MM 0.5ML', 'SensiMedical', '31G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-para-insulina-sensimedical-31g-x-6m-7506022327345.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b15266-100-jeringas-para-insulina-sensimedical-31g-x-6mm-0-5ml-26267 · EAN 7506022327345 · sin precio público (cotizar)'),
  ('7506022326744', 'FC-22326744', '100 Jeringas para Insulina SensiMedical 31G x 8MM 0.5ML', 'SensiMedical', '31G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/100-jeringas-para-insulina-sensimedical-31g-x-8m-7506022326744.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f961896-100-jeringas-para-insulina-sensimedical-31g-x-8mm-0-5ml-26130 · EAN 7506022326744 · sin precio público (cotizar)'),
  ('7506022314642', 'FC-22314642', '50 Jeringas SensiMedical 20G x 32MM 20ML Capacidad en Volumen 20 ml', 'SensiMedical', '20G', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/50-jeringas-sensimedical-20g-x-32mm-20ml-capacid-7506022314642.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/50-jeringas-sensimedical-20g-x-32mm-20ml-capacidad-en-volumen-20-ml-97232 · EAN 7506022314642 · sin precio público (cotizar)'),
  ('4015630006779', 'FC-30006779', 'Accu Chek Softclix 200 Lancetas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 220.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-200-lancetas-4015630006779.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/m1acclans200-accu-chek-softclix-200-lancetas-18324 · EAN 4015630006779 · precio shop $220'),
  ('4015630018284', 'FC-30018284', 'Accu Chek Softclix C/100 Lancetas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 190.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-c-100-lancetas-4015630018284.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d929292092-accu-chek-softclix-c-100-lancetas-26254 · EAN 4015630018284 · precio shop $190'),
  ('4015630066841', 'FC-30066841', 'Accu-Chek Guide 50 Tiras', 'Accu-Chek', '50 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-guide-50-tiras-4015630066841.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f476610888-accu-chek-guide-50-tiras-34683 · EAN 4015630066841 · sin precio público (cotizar)'),
  ('799192067402', 'FC-92067402', 'Accu-Chek Instant + 25 Lancetas Softclix', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-instant-25-lancetas-softclix-799192067402.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f65475823-accu-chek-instant-25-lancetas-softclix-26185 · EAN 799192067402 · sin precio público (cotizar)'),
  ('4015630067077', 'FC-30067077', 'Accu-Chek Instant C/25 Tiras', 'Accu-Chek', '25 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 230.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-instat-c-25-tiras-4015630067077.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e475000-accu-chek-instat-c-25-tiras-18330 · EAN 4015630067077 · precio shop $230'),
  ('7506022304728', 'FC-22304728', 'Aguja Hipodérmica SensiMedical 18gx32mm 100 Piezas', 'SensiMedical', '18g', 'Dispositivo médico', 'Inyectables', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/aguja-hipodermica-sensimedical-18gx32mm-100-piez-7506022304728.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g934304-aguja-hipodermica-sensimedical-18gx32mm-100-piezas-26125 · EAN 7506022304728 · sin precio público (cotizar)'),
  ('7506022304131', 'FC-22304131', 'Aguja Hipodérmica SensiMedical 21gx32mm 100 Piezas', 'SensiMedical', '21g', 'Dispositivo médico', 'Inyectables', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/aguja-hipodermica-sensimedical-21gx32mm-100-piez-7506022304131.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d8827289-aguja-hipodermica-sensimedical-21gx32mm-100-piezas-20670 · EAN 7506022304131 · sin precio público (cotizar)'),
  ('659525501181', 'FC-25501181', 'Ejercitador Pulmonar Incentivo Respiprogram', 'Respiprogram', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/ejercitador-pulmonar-incentivo-respiprogram-659525501181.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g980428-ejercitador-pulmonar-incentivo-respiprogram-18459 · EAN 659525501181 · sin precio público (cotizar)'),
  ('799192067426', 'FC-92067426', 'Glucómetro Accu-Check Instant Kit con 50 Tiras y 25 Lancetas Color Verde', 'Accu-Chek', '50 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 670.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f589632-glucometro-accu-check-instant-kit-con-50-tiras-y-25-x000d-x000d-lancetas-color-verde-21666 · EAN 799192067426 · precio shop $670'),
  ('0353885010146', 'FC-85010146', 'Glucómetro OneTouch Select Plus Simple 25 Tiras 25 Lancetas', 'OneTouch', '25 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/gluc-metro-onetouch-select-plus-simple-25-tiras-0353885010146.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e930017177-e9182123220-e3184779557-g470127-glucometro-onetouch-select-plus-simple-25-tiras-25-lancetas-27888 · EAN 0353885010146 · sin precio público (cotizar)'),
  ('7613427028781', 'FC-27028781', 'Kit 25 Tiras One Touch +10 Lancetas+lancetador+glucometro', 'OneTouch', '25 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 479.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/kit-25-tiras-one-touch-10-lancetas-lancetador-gl-7613427028781.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f847963-kit-25-tiras-one-touch-10-lancetas-lancetador-glucometro-26274 · EAN 7613427028781 · precio shop $479'),
  ('7613427032702', 'FC-27032702', 'Kit Tiras Select Plus One Touch 75 Tiras y 25 Lancetas Delica Plus', 'OneTouch', '75 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 519.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/kit-tiras-select-plus-one-touch-75-tiras-y-25-la-7613427032702.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e224984324-kit-tiras-select-plus-one-touch-75-tiras-y-25-lancetas-x000d-x000d-delica-plus-26171 · EAN 7613427032702 · precio shop $519'),
  ('781718982849', 'FC-18982849', 'Kit Vitalcare Estetoscopio Simple/esfigmomanómetro Aneroide', 'VitalCare', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/kit-vitalcare-estetoscopio-simple-esfigmoman-met-781718982849.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f787435543-kit-vitalcare-estetoscopio-simple-esfigmomanometro-aneroide-21574 · EAN 781718982849 · sin precio público (cotizar)'),
  ('4015630018277', 'FC-30018277', 'Lanceta Accu-Chek Softclix 25pzas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 80.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/lanceta-accu-chek-softclix-25pzas-4015630018277.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d73736183-lanceta-accu-chek-softclix-25pzas-18326 · EAN 4015630018277 · precio shop $80'),
  ('7613427011424', 'FC-27011424', 'Lancetas One Touch Ultra Soft con 25 Piezas', 'OneTouch', '25 Piezas', 'Dispositivo médico', 'Tiras', 'Lancetas', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/lancetas-one-touch-ultra-soft-con-25-piezas-7613427011424.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g759529-lancetas-one-touch-ultra-soft-con-25-piezas-34552 · EAN 7613427011424 · sin precio público (cotizar)'),
  ('4015630082988', 'FC-30082988', 'Medidor Accu-Chek Active', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/medidor-accu-chek-active-4015630082988.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f6587412574-medidor-accu-chek-active-26256 · EAN 4015630082988 · sin precio público (cotizar)'),
  ('7613427029061', 'FC-27029061', 'Medidor One Touch Select Plus Flex + 50 Tiras Select Plus', 'OneTouch', '50 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 400.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/medidor-one-touch-select-plus-flex-50-tiras-sele-7613427029061.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g768796-medidor-one-touch-select-plus-flex-50-tiras-select-plus-34726 · EAN 7613427029061 · precio shop $400'),
  ('073796612429', 'FC-96612429', 'Monitor Presión Arterial de muñeca 30 Memorias Omron Hem6124', 'Omron', '30 M', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 600.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796612429.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e382794-monitor-presion-arterial-de-muneca-30-memorias-omron-hem6124-17572 · EAN 073796612429 · precio shop $600'),
  ('4580193650870', 'FC-93650870', 'Monitor de Presión Arterial Digital de muñeca Automático Citizen Ch-617 Blanco', 'Citizen', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 615.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/monitor-de-presi-n-arterial-digital-de-mu-eca-au-4580193650870.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g159097-monitor-de-presion-arterial-digital-de-muneca-automatico-citizen-ch-617-blanco-34109 · EAN 4580193650870 · precio shop $615'),
  ('859108003075', 'FC-08003075', 'Monitor de Presión Arterial Neutek Bp-202h de muñeca', 'Neutek', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/monitor-de-presi-n-arterial-neutek-bp-202h-de-mu-859108003075.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d451000290-monitor-de-presion-arterial-neutek-bp-202h-de-muneca-21938 · EAN 859108003075 · sin precio público (cotizar)'),
  ('073796803216', 'FC-96803216', 'Nebulizador de Compresor Omron Elite Ne C803 100v/240v', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/nebulizador-de-compresor-omron-elite-ne-c803-100-073796803216.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b30672-nebulizador-de-compresor-omron-elite-ne-c803-100v-240v-17584 · EAN 073796803216 · sin precio público (cotizar)'),
  ('614143495489', 'FC-43495489', 'Nebulizador de Compresor Vitalcare 405b Blanco 120v', 'VitalCare', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/nebulizador-de-compresor-vitalcare-405b-blanco-1-614143495489.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g909342-nebulizador-de-compresor-vitalcare-405b-blanco-120v-18441 · EAN 614143495489 · sin precio público (cotizar)'),
  ('6939663900072', 'FC-63900072', 'Neutek Termómetro Digital Contra Agua', 'Neutek', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 68.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/neutek-term-metro-digital-contra-agua-6939663900072.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b47866-neutek-termometro-digital-contra-agua-26258 · EAN 6939663900072 · precio shop $68'),
  ('4015672110892', 'FC-72110892', 'Omron Micro Nebulizador Adulto/infantil Microair U100', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-micro-nebulizador-adulto-infantil-microair-4015672110892.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e4598402-omron-micro-nebulizador-adulto-infantil-microair-u100-18333 · EAN 4015672110892 · sin precio público (cotizar)'),
  ('073796712020', 'FC-96712020', 'Omron Monitor de Presión Arterial de Brazo. Hem-7120', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-monitor-de-presi-n-arterial-de-brazo-hem-7-073796712020.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f896569-omron-monitor-de-presion-arterial-de-brazo-hem-7120-34530 · EAN 073796712020 · sin precio público (cotizar)'),
  ('73796713003', 'FC-96713003', 'Omron Monitor de Presión de Brazo Hem 7130', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 1100.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-monitor-de-presion-de-brazo-hem-7130-73796713003.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/omron-monitor-de-presion-de-brazo-hem-7130-48885 · EAN 73796713003 · precio shop $1100'),
  ('073796612726', 'FC-96612726', 'Omron Monitor de Presión de muñeca Hem-6127', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-monitor-de-presi-n-de-mu-eca-hem-6127-073796612726.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/a946834164-omron-monitor-de-presion-de-muneca-hem-6127-25916 · EAN 073796612726 · sin precio público (cotizar)'),
  ('073796801427', 'FC-96801427', 'Omron Nebulizador Compresor con Ducha Nasal Ne-C101n', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-nebulizador-compresor-con-ducha-nasal-ne-c-073796801427.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f398702-omron-nebulizador-compresor-con-ducha-nasal-ne-c101n-17583 · EAN 073796801427 · sin precio público (cotizar)'),
  ('073796451011', 'FC-96451011', 'Omron Nebulizador de Compresor Ne-C101', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796451011.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/c72627387-omron-nebulizador-de-compresor-ne-c101-17569 · EAN 073796451011 · sin precio público (cotizar)'),
  ('073796801212', 'FC-96801212', 'Omron Nebulizador de Compresor Ne-C80la Blanco', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 890.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796801212.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/n89945984-omron-nebulizador-de-compresor-ne-c80la-blanco-17582 · EAN 073796801212 · precio shop $890'),
  ('812608030088', 'FC-08030088', 'One Touch Delica Plus 100 Lancetas', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 155.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-delica-plus-100-lancetas-812608030088.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b24351-f47766753-one-touch-delica-plus-100-lancetas-26276 · EAN 812608030088 · precio shop $155'),
  ('7613427032214', 'FC-27032214', 'One Touch Plus Kit Completo de Inicio', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-plus-kit-completo-de-inicio-7613427032214.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f877412554-one-touch-plus-kit-completo-de-inicio-21497 · EAN 7613427032214 · sin precio público (cotizar)'),
  ('7613427011707', 'FC-27011707', 'One Touch Selec Plus 25 Tiras Reactivas', 'OneTouch', '25 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 160.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-selec-plus-25-tiras-reactivas-7613427011707.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d55161678-one-touch-selec-plus-25-tiras-reactivas-26272 · EAN 7613427011707 · precio shop $160'),
  ('7613427011004', 'FC-27011004', 'One Touch Select 50 Tiras Reactivas', 'OneTouch', '50 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 327.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-select-50-tiras-reactivas-7613427011004.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b60442-one-touch-select-50-tiras-reactivas-21496 · EAN 7613427011004 · precio shop $327'),
  ('6945630117121', 'FC-30117121', 'One Touch ULTRASOFT2 25 Lancetas', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 64.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-ultrasoft2-25-lancetas-6945630117121.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/one-touch-ultrasoft2-25-lancetas-97200 · EAN 6945630117121 · precio shop $64'),
  ('7501554500112', 'FC-54500112', 'One Touch Ultra 75 Tiras Reactivas y 25 Lancetas', 'OneTouch', '75 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-ultra-75-tiras-reactivas-y-25-lancetas-7501554500112.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/one-touch-ultra-75-tiras-reactivas-y-25-lancetas-96340 · EAN 7501554500112 · sin precio público (cotizar)'),
  ('353885771504', 'FC-85771504', 'One Touch Ultra C/50 Tiras', 'OneTouch', '50 Tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 370.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-ultra-c-50-tiras-353885771504.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d44161788-one-touch-ultra-c-50-tiras-18132 · EAN 353885771504 · precio shop $370'),
  ('812608030095', 'FC-08030095', 'One-Touch Delica Plus 25 Lancetas', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-delica-plus-25-lancetas-812608030095.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/one-touch-delica-plus-25-lancetas-97109 · EAN 812608030095 · sin precio público (cotizar)'),
  ('7613427043340', 'FC-27043340', 'One-Touch Select Plus Flex', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/one-touch-select-plus-flex-7613427043340.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/one-touch-select-plus-flex-97260 · EAN 7613427043340 · sin precio público (cotizar)'),
  ('7613427043418', 'FC-27043418', 'Onetouch® Select Plus Simple System Kit (medidor Sps+10 Lancetas + Sistema de Punción)', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 250.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/onetouch-select-plus-simple-system-kit-medidor-s-7613427043418.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/onetouch-r-select-plus-simple-system-kit-medidor-sps-10-lancetas-sistema-de-puncion-48880 · EAN 7613427043418 · precio shop $250'),
  ('4015630018239', 'FC-30018239', 'Puncionador Lancetero Accu-Chek con 25 Lancetas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Lancetas', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/puncionador-lancetero-accu-chek-con-25-lancetas-4015630018239.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d83738391-puncionador-lancetero-accu-chek-con-25-lancetas-18325 · EAN 4015630018239 · sin precio público (cotizar)'),
  ('7501563020038', 'FC-63020038', 'Punzocat Catéter 17gx38mm (1 1/2) Roja 5 Piezas', 'Punzocat', '17g', 'Dispositivo médico', 'Inyectables', 'Catéter', 15.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/punzocat-cat-ter-17gx38mm-1-1-2-roja-5-piezas-7501563020038.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/punzocat-cateter-17gx38mm-1-1-2-roja-5-piezas-97063 · EAN 7501563020038 · precio shop $15'),
  ('7501563020076', 'FC-63020076', 'Punzocat Catéter 21gx19mm (3/4) Blanco 5 Piezas', 'Punzocat', '21g', 'Dispositivo médico', 'Inyectables', 'Catéter', 15.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/punzocat-cat-ter-21gx19mm-3-4-blanco-5-piezas-7501563020076.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g212839-punzocat-cateter-21gx19mm-3-4-blanco-5-piezas-19734 · EAN 7501563020076 · precio shop $15'),
  ('7501563020366', 'FC-63020366', 'Punzocat Catéter 23gx19mm (3/4) Morada 5 Piezas', 'Punzocat', '23g', 'Dispositivo médico', 'Inyectables', 'Catéter', 15.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/punzocat-cat-ter-23gx19mm-3-4-morada-5-piezas-7501563020366.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g750291-punzocat-cateter-23gx19mm-3-4-morada-5-piezas-19738 · EAN 7501563020366 · precio shop $15'),
  ('7501563020069', 'FC-63020069', 'Punzocat Catéter Intravenoso 20G x 3/4 " (19 Mm)', 'Punzocat', '20G', 'Dispositivo médico', 'Inyectables', 'Catéter', 15.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/punzocat-cateter-intravenoso-20g-x-3-4-34-19-mm-7501563020069.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/punzocat-cateter-intravenoso-20g-x-3-4-19-mm-96347 · EAN 7501563020069 · precio shop $15'),
  ('7501563020120', 'FC-63020120', 'Punzocat Catéter Intravenoso 22G x 1" (25mm) Azul', 'Punzocat', '22G', 'Dispositivo médico', 'Inyectables', 'Catéter', 15.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/punzocat-cat-ter-intravenoso-22g-x-1-34-25mm-azu-7501563020120.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/punzocat-cateter-intravenoso-22g-x-1-25mm-azul-96331 · EAN 7501563020120 · precio shop $15'),
  ('073796832315', 'FC-96832315', 'Repuesto Brazalete para Baumanómetro Digital Hem-Rml31 Omron', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/repuesto-brazalete-para-bauman-metro-digital-hem-073796832315.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g842708-repuesto-brazalete-para-baumanometro-digital-hem-rml31-omron-17585 · EAN 073796832315 · sin precio público (cotizar)'),
  ('073796452216', 'FC-96452216', 'Repuesto Kit Nebulizador Nec801 Omron®', 'Omron', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/repuesto-kit-nebulizador-nec801-omron-073796452216.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g364456-repuesto-kit-nebulizador-nec801-omron-r-17570 · EAN 073796452216 · sin precio público (cotizar)'),
  ('7506022301758', 'FC-22301758', 'SensiMedical Jeringa de Plástico Hipodérmica 3ML 21 g x 32 Mm', 'SensiMedical', '3ML', 'Dispositivo médico', 'Inyectables', 'Jeringa', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/sensimedical-jeringa-de-palstico-hipodermica-3ml-7506022301758.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f52490665-sensimedical-jeringa-de-palstico-hipodermica-3ml-21-g-x-32-mm-97224 · EAN 7506022301758 · sin precio público (cotizar)'),
  ('7506022305282', 'FC-22305282', 'Sonda Foley Silicon Dos Vias Globo 5 Calibre 14FR', 'SensiMedical', '1 pieza', 'Dispositivo médico', 'Inyectables', 'Sonda', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/sonda-foley-silicon-dos-vias-globo-5-calibre-14f-7506022305282.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e050514-sonda-foley-silicon-dos-vias-globo-5-calibre-14fr-20693 · EAN 7506022305282 · sin precio público (cotizar)'),
  ('7503019332016', 'FC-19332016', 'Termómetro Infrarrojo Sin Contacto Neutek Nt1 Función 2 en 1 Cuerpo Humano y Objetos', 'Neutek', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/termometro-infrarrojo-sin-contacto-neutek-nt1-fu-7503019332016.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g238491-termometro-infrarrojo-sin-contacto-neutek-nt1-funcion-2-en-1-cuerpo-humano-y-objetos-34236 · EAN 7503019332016 · sin precio público (cotizar)'),
  ('781159452611', 'FC-59452611', 'Termómetro Infrarrojo de Frente Sin Contacto Yuwell', 'Yuwell', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/term-metro-infrarrojo-de-frente-sin-contacto-yuw-781159452611.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g840362-termometro-infrarrojo-de-frente-sin-contacto-yuwell-21563 · EAN 781159452611 · sin precio público (cotizar)'),
  ('4015630981977', 'FC-30981977', 'Tiras Accuchek Performa 50pzas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Tiras', 325.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/tiras-accuchek-performa-50pzas-4015630981977.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/c3334141-e14635792-tiras-accuchek-performa-50pzas-26257 · EAN 4015630981977 · precio shop $325'),
  ('4015630064076', 'FC-30064076', 'Tiras Reactivas Accu-Chek Active 50pzas', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Tiras', 'Tiras', 270.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/tiras-reactivas-accu-chek-active-50pzas-4015630064076.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g783347-tiras-reactivas-accu-chek-active-50pzas-18328 · EAN 4015630064076 · precio shop $270'),
  ('7613427040967', 'FC-27040967', 'Tiras Simple 25', 'OneTouch', '1 pieza', 'Dispositivo médico', 'Tiras', 'Tiras', 150.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/tiras-simple-25-7613427040967.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e25818158-tiras-simple-25-97223 · EAN 7613427040967 · precio shop $150'),
  ('4015672111837', 'FC-72111837', 'Toma Presión Digital Brazo 7154 Omron 2 Usuarios Topmedic Color Negro/ Blanco', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 850.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/toma-presi-n-digital-brazo-7154-omron-2-usuarios-4015672111837.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g806343-toma-presion-digital-brazo-7154-omron-2-usuarios-topmedic-color-negro-blanco-34334 · EAN 4015672111837 · precio shop $850'),
  ('614143359422', 'FC-43359422', 'Vitalcare Oxímetro de Pulso YX300 / Saturación', 'VitalCare', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 580.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/vitalcare-oximetro-de-pulso-yx300-saturaci-n-614143359422.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f654899-vitalcare-oximetro-de-pulso-yx300-saturacion-18440 · EAN 614143359422 · precio shop $580'),
  ('7503031003741', 'FC-31003741', 'Belabear Colageno y Biotina', 'BelaBear', '1 pieza', 'Suplemento', 'Colágeno', null, 220.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/belabear-colageno-y-biotina-7503031003741.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f588758-belabear-colageno-y-biotina-20601 · EAN 7503031003741 · precio shop $220'),
  ('7503023641470', 'FC-23641470', 'Belabear Colágeno + Biotina 60 Gomitas', 'BelaBear', '60 G', 'Suplemento', 'Colágeno', 'Gomita', 160.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/belabear-col-geno-biotina-60-gomitas-7503023641470.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f8793145-belabear-colageno-biotina-60-gomitas-20526 · EAN 7503023641470 · precio shop $160'),
  ('7500326106989', 'FC-26106989', 'Biomiral Vitem 3ra Vitamena A, C, D, E, Omega3 y Calcio', 'Biomiral', '1 pieza', 'Suplemento', 'Omega', null, 95.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/biomiral-vitem-3ra-vitamena-a-c-d-e-omega3-y-cal-7500326106989.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b68715-biomiral-vitem-3ra-vitamena-a-c-d-e-omega3-y-calcio-18617 · EAN 7500326106989 · precio shop $95'),
  ('7503023641203', 'FC-23641203', 'Colageno + Biotina Gomitas', 'JustCollagen', '1 pieza', 'Suplemento', 'Colágeno', 'Gomita', 220.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/colageno-biotina-gomitas-7503023641203.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g715929-colageno-biotina-gomitas-26264 · EAN 7503023641203 · precio shop $220'),
  ('7501060806982', 'FC-60806982', 'Colageno Hidrolizado 120 Tabletas Vidanat Sabor Sin Sabor', 'Vidanat', '120 Tabletas', 'Suplemento', 'Colágeno', 'Tableta', 80.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/colageno-hidrolizado-120-tabletas-vidanat-sabor-7501060806982.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d88272829-colageno-hidrolizado-120-tabletas-vidanat-sabor-sin-sabor-19034 · EAN 7501060806982 · precio shop $80'),
  ('7503024083422', 'FC-24083422', 'Colageno y Gomitas Justcollagen 120 Gomitas 3.3G C/u', 'JustCollagen', '120 G', 'Suplemento', 'Colágeno', 'Gomita', 250.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/colageno-y-gomitas-justcollagen-120-gomitas-3-3g-7503024083422.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g648526-colageno-y-gomitas-justcollagen-120-gomitas-3-3g-c-u-34254 · EAN 7503024083422 · precio shop $250'),
  ('7501033960499', 'FC-33960499', 'Ensure Advance Suplemento Líquido 237 ml', 'Ensure', '237 ml', 'Suplemento', 'Nutrición clínica', 'Líquido', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-suplemento-l-quido-237-ml-7501033960499.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/ensure-advance-suplemento-liquido-237-ml-97252 · EAN 7501033960499 · sin precio público (cotizar)'),
  ('7501033952913', 'FC-33952913', 'Glucerna Ayuda A Controlar los Niveles de Glucosa 400gr Sabor Vainilla', 'Glucerna', '400g', 'Suplemento', 'Nutrición clínica', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/glucerna-ayuda-a-controlar-los-niveles-de-glucos-7501033952913.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g553360-glucerna-ayuda-a-controlar-los-niveles-de-glucosa-400gr-sabor-vainilla-34608 · EAN 7501033952913 · sin precio público (cotizar)'),
  ('7501033956133', 'FC-33956133', 'Glucerna Líquido Sabor Chocolate 237ML', 'Glucerna', '237ML', 'Suplemento', 'Nutrición clínica', 'Líquido', 50.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/glucerna-l-quido-sabor-chocolate-237ml-7501033956133.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g942917-glucerna-liquido-sabor-chocolate-237ml-34665 · EAN 7501033956133 · precio shop $50'),
  ('7501590281778', 'FC-90281778', 'Glutamax Gold 60 Tabs .66g C/u Omega 3 Tirosina Metionina Ac Sabor Sin Sabor', 'Glutamax', '66g', 'Suplemento', 'Omega', null, 104.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/glutamax-gold-60-tabs-66g-c-u-omega-3-tirosina-m-7501590281778.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f6689711-glutamax-gold-60-tabs-66g-c-u-omega-3-tirosina-metionina-ac-sabor-sin-sabor-19772 · EAN 7501590281778 · precio shop $104'),
  ('7501821812535', 'FC-21812535', 'Just Glucosamina Condroitina con Colágeno Sin Azúcar 120caps', 'JustCollagen', '1 pieza', 'Suplemento', 'Colágeno', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/just-glucosamina-condroitina-con-col-geno-sin-az-7501821812535.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/c787181718-just-glucosamina-condroitina-con-colageno-sin-azucar-120caps-19793 · EAN 7501821812535 · sin precio público (cotizar)'),
  ('7501821812528', 'FC-21812528', 'Justcollagen Colageno Hidrolizado 1800 180 Tabletas C E K Sabor Justcollagen', 'JustCollagen', '180 Tabletas', 'Suplemento', 'Colágeno', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/justcollagen-colageno-hidrolizado-1800-180-table-07501821812528.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g109731-justcollagen-colageno-hidrolizado-1800-180-tabletas-c-e-k-sabor-justcollagen-17665 · EAN 07501821812528 · sin precio público (cotizar)'),
  ('7503024083637', 'FC-24083637', 'Justcollagen Colágeno Hidrolizado 240tabs 1150MG C/u Sabor Sin Sabor', 'JustCollagen', '1150MG', 'Suplemento', 'Colágeno', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/justcollagen-col-geno-hidrolizado-240tabs-1150mg-7503024083637.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g890785-justcollagen-colageno-hidrolizado-240tabs-1150mg-c-u-sabor-sin-sabor-27894 · EAN 7503024083637 · sin precio público (cotizar)'),
  ('7502268270476', 'FC-68270476', 'Justcollagen Fórmula Premium Colágeno Hidrolizado 30caps', 'JustCollagen', '1 pieza', 'Suplemento', 'Colágeno', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/justcollagen-f-rmula-premium-col-geno-hidrolizad-7502268270476.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g568026-justcollagen-formula-premium-colageno-hidrolizado-30caps-34252 · EAN 7502268270476 · sin precio público (cotizar)'),
  ('7501358174021', 'FC-58174021', 'Nartex Aceite de Salmon Omega 3,6,9', 'Nartex', '1 pieza', 'Suplemento', 'Omega', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/nartex-aceite-de-salmon-omega-3-6-9-7501358174021.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/nartex-aceite-de-salmon-omega-369-97229 · EAN 7501358174021 · sin precio público (cotizar)'),
  ('031604136543', 'FC-04136543', 'Nature Made Omega 3 Aceite de Pescado 300 Caps', 'Nature Made', '1 pieza', 'Suplemento', 'Omega', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/nature-made-omega-3-aceite-de-pescado-300-caps-031604136543.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d222811003-nature-made-omega-3-aceite-de-pescado-300-caps-17413 · EAN 031604136543 · sin precio público (cotizar)'),
  ('031604136932', 'FC-04136932', 'Nature Made Omega Triple 3, 6 y 9 150 Caps', 'Nature Made', '1 pieza', 'Suplemento', 'Omega', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/nature-made-omega-triple-3-6-y-9-150-caps-031604136932.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b11932-nature-made-omega-triple-3-6-y-9-150-caps-17414 · EAN 031604136932 · sin precio público (cotizar)'),
  ('7501060825440', 'FC-60825440', 'Omega 3, 6 y 9 Vidanat 60 Cápsulas', 'Vidanat', '60 Cápsulas', 'Suplemento', 'Omega', 'Cápsula', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/omega-3-6-y-9-vidanat-60-c-psulas-7501060825440.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d929201887-omega-3-6-y-9-vidanat-60-capsulas-19052 · EAN 7501060825440 · sin precio público (cotizar)'),
  ('7503002047958', 'FC-02047958', 'Omelina Gel Omega 3,6,9 Aceite de Linaza Orgánica 60 Cap', 'Omelina', '1 pieza', 'Suplemento', 'Omega', null, 85.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/omelina-gel-omega-3-6-9-aceite-de-linaza-org-nic-7503002047958.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g205204-omelina-gel-omega-369-aceite-de-linaza-organica-60-cap-20411 · EAN 7503002047958 · precio shop $85'),
  ('7503008344501', 'FC-08344501', 'Promega Capsulas C/60 Omega 3 Sabor Na', 'Promega', '1 pieza', 'Suplemento', 'Omega', 'Cápsula', 110.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/promega-capsulas-c-60-omega-3-sabor-na-7503008344501.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f0851115-promega-capsulas-c-60-omega-3-sabor-na-20456 · EAN 7503008344501 · precio shop $110'),
  ('7501033954061', 'FC-33954061', 'Suplemento Alimenticio Ensure Sabor Chocolate 237 ml', 'Ensure', '237 ml', 'Suplemento', 'Nutrición clínica', null, 42.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/suplemento-alimenticio-ensure-sabor-chocolate-23-7501033954061.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g542352-suplemento-alimenticio-ensure-sabor-chocolate-237-ml-34651 · EAN 7501033954061 · precio shop $42'),
  ('7503024083415', 'FC-24083415', 'Suplemento Biotina Arandano 120 Gomitas Just 1 Pza', 'JustCollagen', '120 G', 'Suplemento', null, 'Gomita', 50.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/suplemento-biotina-arandano-120-gomitas-just-1-p-7503024083415.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/suplemento-biotina-arandano-120-gomitas-just-1-pza-34911 · EAN 7503024083415 · precio shop $50'),
  ('096619926626', 'FC-19926626', 'Suplemento en Cápsulas Kirkland Signature Aceite de Pescado Concentrado Omega-3 Ácidos Grasos en Bote de 605G 400 Un', 'Kirkland', '605G', 'Suplemento', 'Omega', 'Cápsula', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/suplemento-en-c-psulas-kirkland-signature-aceite-096619926626.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d443572-suplemento-en-capsulas-kirkland-signature-aceite-de-pescado-concentrado-omega-3-acidos-grasos-en-bote-de-605g-400-un-17786 · EAN 096619926626 · sin precio público (cotizar)'),
  ('7501060807347', 'FC-60807347', 'Vidanat Colageno Tipo Ii Ácido Hialurónico Suplemento 30caps', 'Vidanat', '1 pieza', 'Suplemento', 'Colágeno', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/vidanat-colageno-tipo-ii-cido-hialur-nico-suplem-7501060807347.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f829392-vidanat-colageno-tipo-ii-acido-hialuronico-suplemento-30caps-19040 · EAN 7501060807347 · sin precio público (cotizar)'),
  ('810089954862', 'FC-89954862', 'Vital Proteins Péptidos de Colágeno Suplemento Kosher 680G', 'Vital Proteins', '680G', 'Suplemento', 'Colágeno', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/vital-proteins-p-ptidos-de-col-geno-suplemento-k-810089954862.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f851788-vital-proteins-peptidos-de-colageno-suplemento-kosher-680g-21695 · EAN 810089954862 · sin precio público (cotizar)'),
  ('7503008344754', 'FC-08344754', 'Afrodit Tocofersolan Vitamina E 99 Capsulas 400UI Progela', 'Afrodit', '99 Capsulas', 'Vitaminas', null, 'Cápsula', 145.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/afrodit-tocofersolan-vitamina-e-99-capsulas-400u-7503008344754.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g236821-afrodit-tocofersolan-vitamina-e-99-capsulas-400ui-progela-34034 · EAN 7503008344754 · precio shop $145'),
  ('7503023641463', 'FC-23641463', 'Belabear Acido Hialuronico', 'BelaBear', '1 pieza', 'Vitaminas', null, null, 150.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/belabear-acido-hialuronico-7503023641463.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f7891034-belabear-acido-hialuronico-20525 · EAN 7503023641463 · precio shop $150'),
  ('7500326108754', 'FC-26108754', 'Biomivit 400 Biomiral Vitaminas Minerales y Omega 3 30 Caps', 'Biomiral', '1 pieza', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/biomivit-400-biomiral-vitaminas-minerales-y-omeg-7500326108754.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f497797-biomivit-400-biomiral-vitaminas-minerales-y-omega-3-30-caps-18619 · EAN 7500326108754 · sin precio público (cotizar)'),
  ('7501124183240', 'FC-24183240', 'C-Tech Citrato de Calcio con Colecalciferol 60 Tabletas', 'C-Tech', '60 Tabletas', 'Vitaminas', null, 'Tableta', 210.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/c-tech-citrato-de-calcio-con-colecalciferol-60-t-7501124183240.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f8874115252-c-tech-citrato-de-calcio-con-colecalciferol-60-tabletas-19285 · EAN 7501124183240 · precio shop $210'),
  ('7501065095718', 'FC-65095718', 'Centrum Balance 30 Tabletas', 'Centrum', '30 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/centrum-balance-30-tabletas-7501065095718.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d9983901-centrum-balance-30-tabletas-19103 · EAN 7501065095718 · sin precio público (cotizar)'),
  ('7501065095978', 'FC-65095978', 'Centrum Performance Tabletas, 30 Tabletas', 'Centrum', '30 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/centrum-performance-tabletas-30-tabletas-7501065095978.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/centrum-performance-tabletas-30-tabletas-97095 · EAN 7501065095978 · sin precio público (cotizar)'),
  ('7501060806371', 'FC-60806371', 'Citrato de Magnesio con Zinc Vidanat 60 Tabs', 'Vidanat', '1 pieza', 'Vitaminas', null, null, 150.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/citrato-de-magnesio-con-zinc-vidanat-60-tabs-7501060806371.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d230980654-citrato-de-magnesio-con-zinc-vidanat-60-tabs-19031 · EAN 7501060806371 · precio shop $150'),
  ('7503181041556', 'FC-81041556', 'Colagener Colageno Hidrolizado Vitamina C 60 Tabletas Tipo de Piel Todo Tipo de Piel', 'Colagener', '60 Tabletas', 'Vitaminas', null, 'Tableta', 100.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/colagener-colageno-hidrolizado-vitamina-c-60-tab-7503181041556.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/colagener-colageno-hidrolizado-vitamina-c-60-tabletas-tipo-de-piel-todo-tipo-de-piel-97225 · EAN 7503181041556 · precio shop $100'),
  ('031604136123', 'FC-04136123', 'Coq10 Nature Made 790 mg 90 Caps', 'Nature Made', '790 mg', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/coq10-nature-made-790-mg-90-caps-031604136123.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d82999200-coq10-nature-made-790-mg-90-caps-17411 · EAN 031604136123 · sin precio público (cotizar)'),
  ('7501298223704', 'FC-98223704', 'Dolo Neurobion Caja con 20 Tabletas', 'Neurobion', '20 Tabletas', 'Vitaminas', null, 'Tableta', 232.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/dolo-neurobion-caja-con-20-tabletas-7501298223704.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g254462-dolo-neurobion-caja-con-20-tabletas-19482 · EAN 7501298223704 · precio shop $232'),
  ('7501165009431', 'FC-65009431', 'Duo Pack Aderogyl Vitaminas A, C, D 5 Ampolletas Cu', 'Aderogyl', '5 Ampolletas', 'Vitaminas', null, 'Ampolleta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/duo-pack-aderogyl-vitaminas-a-c-d-5-ampolletas-c-7501165009431.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f7890242-duo-pack-aderogyl-vitaminas-a-c-d-5-ampolletas-cu-19383 · EAN 7501165009431 · sin precio público (cotizar)'),
  ('7501065086372', 'FC-65086372', 'Duo Pack Caltrate 600+d 60 Tabletas + 30 Tabletas Gratis', 'Caltrate', '60 Tabletas', 'Vitaminas', null, 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/duo-pack-caltrate-600-d-60-tabletas-30-tabletas-7501065086372.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d33332258-duo-pack-caltrate-600-d-60-tabletas-30-tabletas-gratis-19102 · EAN 7501065086372 · sin precio público (cotizar)'),
  ('7501008499580', 'FC-08499580', 'Elevit 3-Luteína Suplemento Alimenticio 30 Cápsulas', 'Elevit', '30 Cápsulas', 'Vitaminas', 'Prenatal', 'Cápsula', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/elevit-3-lute-na-suplemento-alimenticio-30-c-psu-7501008499580.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f846829-elevit-3-luteina-suplemento-alimenticio-30-capsulas-18811 · EAN 7501008499580 · sin precio público (cotizar)'),
  ('7501008497623', 'FC-08497623', 'Elevit Embarazo Caja 30 Tabletas Sabor Sin Sabor', 'Elevit', '30 Tabletas', 'Vitaminas', 'Prenatal', 'Tableta', 310.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/elevit-embarazo-caja-30-tabletas-sabor-sin-sabor-7501008497623.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/d883739-elevit-embarazo-caja-30-tabletas-sabor-sin-sabor-96088 · EAN 7501008497623 · precio shop $310'),
  ('7501065054678', 'FC-65054678', 'Emulsión de Scott Vitamina A y D Sabor Cereza 400ML', 'Emulsión de Scott', '400ML', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/emulsi-n-de-scott-vitamina-a-y-d-sabor-cereza-40-7501065054678.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/c098757930-emulsion-de-scott-vitamina-a-y-d-sabor-cereza-400ml-19089 · EAN 7501065054678 · sin precio público (cotizar)'),
  ('7508006184500', 'FC-06184500', 'Lera Co Suplemento Ácido Lipólico Omega 3 Vitamina E 30 Caps Neutra', 'Lera', '1 pieza', 'Vitaminas', null, null, 990.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/lera-co-suplemento-cido-lip-lico-omega-3-vitamin-7508006184500.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f2222338-lera-co-suplemento-acido-lipolico-omega-3-vitamina-e-30-caps-neutra-21307 · EAN 7508006184500 · precio shop $990'),
  ('7503008344204', 'FC-08344204', 'Melidam Multivitamínico para Diabéticos 30 Cápsulas', 'Melidam', '30 Cápsulas', 'Vitaminas', 'Multivitamínico', 'Cápsula', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/melidam-multivitam-nico-para-diab-ticos-30-c-psu-7503008344204.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f4789121-melidam-multivitaminico-para-diabeticos-30-capsulas-20451 · EAN 7503008344204 · sin precio público (cotizar)'),
  ('7501060805923', 'FC-60805923', 'Multivitaminas para Mujer Vidanat Suplemento 30caps', 'Vidanat', '1 pieza', 'Vitaminas', 'Multivitamínico', null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitaminas-para-mujer-vidanat-suplemento-30c-7501060805923.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e048772366-multivitaminas-para-mujer-vidanat-suplemento-30caps-19024 · EAN 7501060805923 · sin precio público (cotizar)'),
  ('7501065095985', 'FC-65095985', 'Multivitaminico Centrum Performance - 100 Tabletas', 'Centrum', '100 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitaminico-centrum-performance-100-tabletas-7501065095985.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g616950-multivitaminico-centrum-performance-100-tabletas-19106 · EAN 7501065095985 · sin precio público (cotizar)'),
  ('7501065003973', 'FC-65003973', 'Multivitamínico Centrum Hombre con Vitamina B Vitamina C Magnesio Calcio y Manganeso 60 Tabletas', 'Centrum', '60 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-centrum-hombre-con-vitamina-b-vi-7501065003973.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g423265-multivitaminico-centrum-hombre-con-vitamina-b-vitamina-c-magnesio-calcio-y-manganeso-60-tabletas-17648 · EAN 7501065003973 · sin precio público (cotizar)'),
  ('7501065004000', 'FC-65004000', 'Multivitamínico Centrum Mujer con Vitamina C Vitamina E Calcio Hierro y Retinol 60 Tabletas', 'Centrum', '60 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-centrum-mujer-con-vitamina-c-vit-7501065004000.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g382520-multivitaminico-centrum-mujer-con-vitamina-c-vitamina-e-calcio-hierro-y-retinol-60-tabletas-17649 · EAN 7501065004000 · sin precio público (cotizar)'),
  ('7501065095947', 'FC-65095947', 'Multivitamínico Centrum Silver +50 Adultos con Vitamina B Vitamina C Calcio Potasio y Zinc 30 Tabletas', 'Centrum', '30 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-centrum-silver-50-adultos-con-vi-7501065095947.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g142087-multivitaminico-centrum-silver-50-adultos-con-vitamina-b-vitamina-c-calcio-potasio-y-zinc-30-tabletas-19105 · EAN 7501065095947 · sin precio público (cotizar)'),
  ('7501228300390', 'FC-28300390', 'Multivitamínico Stresstabs Pfizer con Hierro 30 Tabletas', 'Stresstabs', '30 Tabletas', 'Vitaminas', 'Multivitamínico', 'Tableta', 180.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-stresstabs-pfizer-con-hierro-30-7501228300390.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g104089-multivitaminico-stresstabs-pfizer-con-hierro-30-tabletas-19401 · EAN 7501228300390 · precio shop $180'),
  ('7501058624017', 'FC-58624017', 'Multivitamínico con Dha Nestlé Materplus Caja con 30 Cápsulas', 'Materplus', '30 Cápsulas', 'Vitaminas', 'Multivitamínico', 'Cápsula', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-con-dha-nestl-materplus-caja-con-7501058624017.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/multivitaminico-con-dha-nestle-materplus-caja-con-30-capsulas-97330 · EAN 7501058624017 · sin precio público (cotizar)'),
  ('7503051939051', 'FC-51939051', 'Naturagel Vitamina D3 con K2 y Omega 3 700MG 60 Caps Sabor Sin Sabor', 'Naturagel', '700MG', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/naturagel-vitamina-d3-con-k2-y-omega-3-700mg-60-7503051939051.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g481982-naturagel-vitamina-d3-con-k2-y-omega-3-700mg-60-caps-sabor-sin-sabor-41382 · EAN 7503051939051 · sin precio público (cotizar)'),
  ('7508304413296', 'FC-04413296', 'Onedrop Ade Suplemento Alimenticio Vitaminas A, D y E, 3 ml Sabor Aceite de Coco', 'Onedrop', '3 ml', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/onedrop-ade-suplemento-alimenticio-vitaminas-a-d-7508304413296.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e44680565-onedrop-ade-suplemento-alimenticio-vitaminas-a-d-y-e-3-ml-sabor-aceite-de-coco-21311 · EAN 7508304413296 · sin precio público (cotizar)'),
  ('7501390916092', 'FC-90916092', 'Onivix Fem con 30 Sobres de 2.1 g Suplemento Alimenticio', 'Onivix', '30 Sobres', 'Vitaminas', null, 'Sobre', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/onivix-fem-con-30-sobres-de-2-1-g-suplemento-ali-7501390916092.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/g215037-onivix-fem-con-30-sobres-de-2-1-g-suplemento-alimenticio-34738 · EAN 7501390916092 · sin precio público (cotizar)'),
  ('7501008499368', 'FC-08499368', 'Redoxon Aox Sabor Naranja Paquete de 4 Tubos 10 Tabletas', 'Redoxon', '10 Tabletas', 'Vitaminas', null, 'Tableta', 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/redoxon-aox-sabor-naranja-paquete-de-4-tubos-10-7501008499368.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e97618006-redoxon-aox-sabor-naranja-paquete-de-4-tubos-10-tabletas-18803 · EAN 7501008499368 · sin precio público (cotizar)'),
  ('7501060807002', 'FC-60807002', 'Vitamina C 120 Tabletas Vidanat Sabor Sin Sabor', 'Vidanat', '120 Tabletas', 'Vitaminas', null, 'Tableta', 75.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/vitamina-c-120-tabletas-vidanat-sabor-sin-sabor-7501060807002.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/f46766745-vitamina-c-120-tabletas-vidanat-sabor-sin-sabor-19036 · EAN 7501060807002 · precio shop $75'),
  ('096619980161', 'FC-19980161', 'Vitamina C Kirkland 30 Tabs Efervescentes Naranja', 'Kirkland', '1 pieza', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/vitamina-c-kirkland-30-tabs-efervescentes-naranj-096619980161.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/b93721-vitamina-c-kirkland-30-tabs-efervescentes-naranja-17789 · EAN 096619980161 · sin precio público (cotizar)'),
  ('7501060825457', 'FC-60825457', 'Zinc Suplemento Vidanat 100 Tabs', 'Vidanat', '1 pieza', 'Vitaminas', null, null, 90.00::numeric, 'https://www.farmacapital.mx/catalogo-propia/zinc-suplemento-vidanat-100-tabs-7501060825457.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e9820976363-zinc-suplemento-vidanat-100-tabs-19053 · EAN 7501060825457 · precio shop $90'),
  ('7501060805879', 'FC-60805879', 'Ácido Alfa Lipoico Vidanat Suplemento 60 Caps', 'Vidanat', '1 pieza', 'Vitaminas', null, null, 0.01::numeric, 'https://www.farmacapital.mx/catalogo-propia/cido-alfa-lipoico-vidanat-suplemento-60-caps-7501060805879.jpg', 'Farma Integral · https://farmacia-integral.odoo.com/shop/e99828783-acido-alfa-lipoico-vidanat-suplemento-60-caps-19022 · EAN 7501060805879 · sin precio público (cotizar)');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria, imagen_url,
  bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.subcategoria,
  t.imagen_url,
  true
from _fc_vitrina_bp t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       categoria = case
         when coalesce(nullif(trim(p.categoria), ''), '') in ('', 'Otro', 'General')
           then t.categoria else p.categoria end,
       subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
       precio = case when coalesce(p.precio, 0) <= 0.01 then t.precio else p.precio end
  from _fc_vitrina_bp t
 where (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean))
   and coalesce(p.stock, 0) = 0;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id, t.imagen_url, 1, true, 'distribuidor'
  from _fc_vitrina_bp t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where coalesce(p.bajo_pedido, false) = true
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and i.url = t.imagen_url
   );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.categoria,
  p.subcategoria,
  p.precio,
  p.stock,
  p.bajo_pedido,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in (
  '025715974804',
  '4042809258813',
  '4042809591385',
  '4042809001006',
  '7506022301772',
  '7506022301888',
  '7506022314505',
  '7506022327215',
  '7506022327345',
  '7506022326744',
  '7506022314642',
  '4015630006779',
  '4015630018284',
  '4015630066841',
  '799192067402',
  '4015630067077',
  '7506022304728',
  '7506022304131',
  '659525501181',
  '799192067426',
  '0353885010146',
  '7613427028781',
  '7613427032702',
  '781718982849',
  '4015630018277',
  '7613427011424',
  '4015630082988',
  '7613427029061',
  '073796612429',
  '4580193650870',
  '859108003075',
  '073796803216',
  '614143495489',
  '6939663900072',
  '4015672110892',
  '073796712020',
  '73796713003',
  '073796612726',
  '073796801427',
  '073796451011',
  '073796801212',
  '812608030088',
  '7613427032214',
  '7613427011707',
  '7613427011004',
  '6945630117121',
  '7501554500112',
  '353885771504',
  '812608030095',
  '7613427043340',
  '7613427043418',
  '4015630018239',
  '7501563020038',
  '7501563020076',
  '7501563020366',
  '7501563020069',
  '7501563020120',
  '073796832315',
  '073796452216',
  '7506022301758',
  '7506022305282',
  '7503019332016',
  '781159452611',
  '4015630981977',
  '4015630064076',
  '7613427040967',
  '4015672111837',
  '614143359422',
  '7503031003741',
  '7503023641470',
  '7500326106989',
  '7503023641203',
  '7501060806982',
  '7503024083422',
  '7501033960499',
  '7501033952913',
  '7501033956133',
  '7501590281778',
  '7501821812535',
  '7501821812528',
  '7503024083637',
  '7502268270476',
  '7501358174021',
  '031604136543',
  '031604136932',
  '7501060825440',
  '7503002047958',
  '7503008344501',
  '7501033954061',
  '7503024083415',
  '096619926626',
  '7501060807347',
  '810089954862',
  '7503008344754',
  '7503023641463',
  '7500326108754',
  '7501124183240',
  '7501065095718',
  '7501065095978',
  '7501060806371',
  '7503181041556',
  '031604136123',
  '7501298223704',
  '7501165009431',
  '7501065086372',
  '7501008499580',
  '7501008497623',
  '7501065054678',
  '7508006184500',
  '7503008344204',
  '7501060805923',
  '7501065095985',
  '7501065003973',
  '7501065004000',
  '7501065095947',
  '7501228300390',
  '7501058624017',
  '7503051939051',
  '7508304413296',
  '7501390916092',
  '7501008499368',
  '7501060807002',
  '096619980161',
  '7501060825457',
  '7501060805879'
)
order by p.categoria, p.nombre;
