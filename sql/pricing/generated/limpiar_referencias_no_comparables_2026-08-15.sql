-- Limpieza de referencias de precio que no se sostienen
-- Generado 2026-08-15
--
-- Criterio: si no hay algo realmente comparable, no se guarda. Un precio de referencia
-- falso es peor que no tener ninguno, porque con el se fija nuestro precio de venta.
-- Sobrevive solo lo que trae el nombre del producto competidor y sus atributos
-- (principio activo, concentracion, forma, piezas) confirmados uno por uno.
--
-- De 659 referencias de venta se borran 590 y quedan 69.

BEGIN;

-- ── 206 · Claude: el campo del competidor trae NUESTRO propio nombre, no hay evidencia. Rastreando sus notas, la mitad comparo productos sin relacion (Pralex vs ESCITALOPRAM, 21% de parecido).
--      Lubricante Sico Softlube Origi   $   84.00  Claude 20260815 · GEL LUBRICANTE VAGINAL 113GR.. (Sc
--      Vicks Vaporub pomada 12 g        $   28.00  Claude 20260815 · Vicks Vaporub pomada 12g - precio 

-- ── 5 · precio inventado ("precio base"), no hubo ningun match
--      Vicks Vaporub pomada 12 g        $   28.00  Vicks Vaporub pomada 12g - precio base
--      Alka-Seltzer                     $  308.00  Alka-Seltzer C/100 - precio base recomendado

-- ── 5 · ya anuladas con confianza 0, basura de una corrida vieja
--      Clamoxin 12H (Amoxicilina/Clav   $    0.00  __anulado__
--      Clamoxin 12H (Amoxicilina/Clav   $    0.00  __anulado__

-- ── 134 · nota en texto libre, sin evidencia comprobable. No se borran por ser
--   equivalencias con generico, que si valen: se borran porque no guardaron el producto
--   competidor en nombre_fuente y no hay como verificarlas. Entre ellas hay empaques 10x
--   distintos (Cafiaspirina C/10 comparada contra C/100). Las equivalencias genericas
--   legitimas se vuelven a capturar, ya con evidencia, al correr de nuevo el sync.
--      Aspirina efervescente C/12       $   36.38  ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENT
--      Epicin                           $   46.50  Similares solo tiene ERITROMICINA 500MG en TABLETAS 

-- ── 123 · sin nota y sin nombre_fuente: no hay registro de contra que producto se comparo
--      Centrum Balance                  $  199.00  sin nota
--      Clamoxin (Amoxicilina/Clavulán   $  143.00  sin nota

-- ── 30 · la concentracion o la forma CONTRADICEN al competidor: no es el mismo producto (jarabe vs tableta, 500mg vs 250mg)
--      Silka Medic Gel                  $   34.00  excel:articulos_farmacias.xlsx | principios activos 
--      Valgab 3 jarabe 6 mL             $   99.00  excel:articulos_farmacias.xlsx | misma marca comerci

-- ── 8 · el competidor no declara cuantas piezas trae: imposible comparar
--      K-PEC suspension infantil Nova   $   73.00  termino:neomicina caolin 100ml | principios activos 
--      Vicks Vaporub ungüento 50G       $   46.00  termino:alcanfor mentol 50000mg | principios activos

-- ── 79 · RECUPERABLE: el que no trae concentracion es NUESTRO catalogo, no la referencia. Se recuperan solos volviendo a correr el sync despues de llenar productos.concentracion.
--      Aderogyl ampolletas C/4          $  119.00  excel:articulos_farmacias.xlsx | misma marca comerci
--      Plusgel antiacido C/50 mastica   $   63.00  excel:articulos_farmacias.xlsx | misma marca comerci

DELETE FROM producto_precios_referencia WHERE id IN (
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28,
    29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
    43, 44, 45, 46, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
    140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153,
    154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167,
    168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181,
    182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195,
    196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
    210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
    224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237,
    238, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254,
    255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268,
    269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282,
    283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296,
    297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310,
    311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324,
    325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338,
    339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352,
    353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366,
    367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380,
    381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394,
    395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408,
    409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422,
    423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436,
    437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450,
    451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464,
    465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478,
    479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492,
    493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506,
    507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520,
    521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534,
    535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548,
    549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 720, 721, 724,
    727, 728, 729, 730, 732, 733, 734, 735, 737, 738, 739, 743, 744, 745,
    750, 751, 754, 756, 757, 761, 765, 767, 768, 769, 771, 772, 774, 775,
    777, 782, 783, 785, 786, 787, 788, 789, 790, 792, 793, 794, 797, 798,
    799, 801, 802, 803, 804, 805, 807, 808, 812, 814, 815, 817, 818, 819,
    820, 821, 823, 824, 825, 826, 827, 828, 829, 832, 833, 836, 837, 840,
    842, 845, 848, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860,
    862, 863, 864, 866, 867, 868, 869, 871, 872, 873, 874, 876, 879, 881,
    882, 883, 884, 887, 889, 891, 892, 893, 894, 895, 898, 899, 900, 901,
    902, 905
);

-- ── 18 referencias del MISMO producto en otro empaque. No son falsas: se les graba
-- las piezas del competidor para que la comparacion sea por unidad y no por caja.
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:10 | ' || notas WHERE id = 897 AND notas NOT LIKE 'piezas_fuente:%';  -- Sedalmerck C/40 tabletas
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:24 | ' || notas WHERE id = 723 AND notas NOT LIKE 'piezas_fuente:%';  -- XL-3 C/10
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:60 | ' || notas WHERE id = 725 AND notas NOT LIKE 'piezas_fuente:%';  -- Novakosid senosidos A-B 8.6 mg C/20
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:10 | ' || notas WHERE id = 764 AND notas NOT LIKE 'piezas_fuente:%';  -- Amlodipino
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:24 | ' || notas WHERE id = 766 AND notas NOT LIKE 'piezas_fuente:%';  -- TUMS
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:24 | ' || notas WHERE id = 770 AND notas NOT LIKE 'piezas_fuente:%';  -- Next tabletas C/10
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:20 | ' || notas WHERE id = 779 AND notas NOT LIKE 'piezas_fuente:%';  -- Aspirina 500 mg
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:10 | ' || notas WHERE id = 781 AND notas NOT LIKE 'piezas_fuente:%';  -- Alka-Seltzer
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:24 | ' || notas WHERE id = 795 AND notas NOT LIKE 'piezas_fuente:%';  -- Tabcin 500 C/12
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:12 | ' || notas WHERE id = 810 AND notas NOT LIKE 'piezas_fuente:%';  -- Bicarbonato Sobres
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:12 | ' || notas WHERE id = 822 AND notas NOT LIKE 'piezas_fuente:%';  -- Amifarin
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:30 | ' || notas WHERE id = 834 AND notas NOT LIKE 'piezas_fuente:%';  -- Aspirina Junior 100 mg C/60
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:12 | ' || notas WHERE id = 838 AND notas NOT LIKE 'piezas_fuente:%';  -- Alliviax Garganta C/8 tabletas
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:20 | ' || notas WHERE id = 841 AND notas NOT LIKE 'piezas_fuente:%';  -- Aspirina 500 mg C/40
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:10 | ' || notas WHERE id = 844 AND notas NOT LIKE 'piezas_fuente:%';  -- Amlodipino
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:10 | ' || notas WHERE id = 846 AND notas NOT LIKE 'piezas_fuente:%';  -- Amlodipino
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:12 | ' || notas WHERE id = 865 AND notas NOT LIKE 'piezas_fuente:%';  -- Ciprofloxacino G.I
UPDATE producto_precios_referencia SET notas = 'piezas_fuente:12 | ' || notas WHERE id = 870 AND notas NOT LIKE 'piezas_fuente:%';  -- Charlyn (Ciprofloxacino)

COMMIT;

-- Comprobacion: todo lo que quede debe traer el nombre del competidor y su verificacion.
select fuente, count(*) refs, count(nombre_fuente) con_evidencia, round(avg(confianza)) conf_prom
from producto_precios_referencia where tipo='venta' group by fuente order by refs desc;
