-- Segundo pase: medicamentos identificables que el SQL de paréntesis no cubrió.
-- Solo llena `principio_activo` vacío. No pisa lo capturado.
-- Jabón, shampoo, pañales y botiquín no entran.

BEGIN;

-- Nombre que ya ES el genérico
UPDATE public.productos SET principio_activo = 'Amlodipino'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^amlodipino\b';
UPDATE public.productos SET principio_activo = 'Aciclovir'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^aciclovir\b';
UPDATE public.productos SET principio_activo = 'Celecoxib'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^celecoxib\b';
UPDATE public.productos SET principio_activo = 'Budesonida'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^budesonida\b';
UPDATE public.productos SET principio_activo = 'Ceftriaxona'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^ceftriaxona\b';
UPDATE public.productos SET principio_activo = 'Cefotaxima'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^cefotaxima\b';
UPDATE public.productos SET principio_activo = 'Lincomicina'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^lincomicina\b';
UPDATE public.productos SET principio_activo = 'Ácido ursodesoxicólico'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'ursodesoxicolico';
UPDATE public.productos SET principio_activo = 'Ácido acetilsalicílico'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^acetilsalicilico\b';
UPDATE public.productos SET principio_activo = 'Fluocinolona'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'acetonido de fluocinolona|fluocinolona';
UPDATE public.productos SET principio_activo = 'Calcitriol'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'calcitriol';
UPDATE public.productos SET principio_activo = 'Hierro'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* '^hierro\b';

-- Marca comercial conocida
UPDATE public.productos SET principio_activo = 'Paracetamol'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^tylenol$' OR nombre ~* '^tylenol\b');
UPDATE public.productos SET principio_activo = 'Paracetamol / Cafeína / Clorfenamina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^agrifen$' OR nombre ~* '^agrifen\b');
UPDATE public.productos SET principio_activo = 'Oximetazolina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^afrin$' OR nombre ~* '^afrin\b');
UPDATE public.productos SET principio_activo = 'Naproxeno'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^flanax$' OR nombre ~* '^flanax\b');
UPDATE public.productos SET principio_activo = 'Paracetamol / Propifenazona / Cafeína'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^saridon$' OR nombre ~* '^saridon\b');
UPDATE public.productos SET principio_activo = 'Tiamina / Piridoxina / Cianocobalamina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^neurobion$' OR nombre ~* '^neurobi[oó]n\b');
UPDATE public.productos SET principio_activo = 'Ácido acetilsalicílico / Fenilefrina / Clorfenamina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^tabcin$' OR nombre ~* '^tabcin\b');
UPDATE public.productos SET principio_activo = 'Glimepirida'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^zukedib$' OR nombre ~* '^zukedib\b');
UPDATE public.productos SET principio_activo = 'Terbinafina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^erbitrax$' OR nombre ~* 'erbitrax|terbinafina');
UPDATE public.productos SET principio_activo = 'Valeriana'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^valnait$' OR nombre ~* 'valeriana');
UPDATE public.productos SET principio_activo = 'Permetrina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^scabisan$' OR nombre ~* '^scabisan\b');
UPDATE public.productos SET principio_activo = 'Cefaclor'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^(lesaclor|fasiclor)$';
UPDATE public.productos SET principio_activo = 'Cefadroxilo'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^(cefaroxil|cepobrom)$';
UPDATE public.productos SET principio_activo = 'Cefalexina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^(cefalver|cefagen|eferox)$' OR nombre ~* 'eferox|cefalexina');
UPDATE public.productos SET principio_activo = 'Amoxicilina / Ácido clavulánico'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* 'acroxil|clamoxin|valclan' OR nombre ~* 'acroxil');
UPDATE public.productos SET principio_activo = 'Ampicilina / Dicloxacilina'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^ampigrin$' OR nombre ~* 'ampigrin|ampicilina \+ dicloxacilina');
UPDATE public.productos SET principio_activo = 'Sulfametoxazol / Trimetoprima'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^bactiver$' OR nombre ~* 'bactiver|sulfametoxazol');
UPDATE public.productos SET principio_activo = 'Ciprofloxacino'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* '^(cina|charlyn)$' OR nombre ~* '^cina\b|ciprofloxacino');
UPDATE public.productos SET principio_activo = 'Ibuprofeno / Cafeína'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* 'ibupro' OR nombre ~* 'ibupro-cafe');
UPDATE public.productos SET principio_activo = 'Ácido acetilsalicílico'
WHERE coalesce(btrim(principio_activo), '') = '' AND (marca ~* 'aspitak' OR nombre ~* 'aspitak');
UPDATE public.productos SET principio_activo = 'Neomicina / Bacitracina'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^vitacilina$' AND nombre ~* 'vitacilina';
UPDATE public.productos SET principio_activo = 'Multivitamínico'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^(gelcavit|animalin)$';
UPDATE public.productos SET principio_activo = 'Amoxicilina'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^gimalxina$';
UPDATE public.productos SET principio_activo = 'Diclofenaco'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^diclofen$';
UPDATE public.productos SET principio_activo = 'Eritromicina'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^epicin$';
UPDATE public.productos SET principio_activo = 'Nitrofurantoína'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^knoricin$';
UPDATE public.productos SET principio_activo = 'Claritromicina'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^klarix$';
UPDATE public.productos SET principio_activo = 'Dextrometorfano'
WHERE coalesce(btrim(principio_activo), '') = '' AND marca ~* '^histiacil$';
UPDATE public.productos SET principio_activo = 'Ácido cítrico / Bicarbonato de sodio'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'sal de uvas';
UPDATE public.productos SET principio_activo = 'Paracetamol / Diclofenaco'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'paracetamol \+ diclofenaco';
UPDATE public.productos SET principio_activo = 'Inmunoglobulina'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'inmunoglobulina';
UPDATE public.productos SET principio_activo = 'Metamizol / Dexametasona'
WHERE coalesce(btrim(principio_activo), '') = '' AND nombre ~* 'metamizol';

COMMIT;
