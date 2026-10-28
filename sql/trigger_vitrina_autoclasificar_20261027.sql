-- FarmaCapital · Clasificación automática de vitrina (aplicado en producción 2026-10-27)
--
-- Problema que corrige: el patch_vitrina_seccion_20260924.sql corrió una sola vez,
-- así que cada producto nuevo quedaba con vitrina_seccion = NULL y no aparecía en
-- ninguna categoría de la tienda (caso SVR / Medik8 / Alastin, 26-oct). Además,
-- todo "Cuidado personal" caía en Dermocosmética (Fixodent, Trojan, Gillette…).
--
-- Este trigger SOLO llena la sección cuando viene vacía. Nunca sobreescribe una
-- sección asignada a mano.
--
-- ⚠️ NO volver a correr patch_vitrina_seccion_20260924.sql: limpia todas las
-- secciones y borraría la recategorización manual del 27-oct.

create or replace function public.fn_vitrina_clasificar()
returns trigger language plpgsql as $function$
declare
  n text := coalesce(new.nombre,'');
  s text := coalesce(new.subcategoria,'');
  mk text := lower(btrim(coalesce(new.marca,'')));
begin
  if new.vitrina_seccion is not null or not coalesce(new.activo,false) then
    return new;
  end if;

  if coalesce(new.requiere_receta,false) or coalesce(new.controlado,false)
     or coalesce(nullif(btrim(new.grupo_controlado),''),'') <> ''
     or new.categoria in ('Medicamentos','Medicamento','Medicamentos OTC','Analgésico','Antiinflamatorio',
        'Antibiótico','Antiviral','Gastro','Diabetes','Hipertensión','Cardiovascular','Alergia',
        'Respiratorio','Hormonales','Hidratación','Dermatología','Ginecología') then
    new.vitrina_seccion := 'Medicamentos';
    new.vitrina_subseccion := case
      when new.categoria in ('Analgésico','Antiinflamatorio') then 'Dolor y fiebre'
      when new.categoria = 'Respiratorio' then 'Gripa y tos'
      when new.categoria in ('Gastro','Hidratación') then 'Digestión'
      when new.categoria = 'Alergia' then 'Alergia'
      when new.categoria = 'Diabetes' then 'Diabetes'
      when new.categoria in ('Hipertensión','Cardiovascular') then 'Presión y corazón'
      when new.categoria = 'Dermatología' then 'Piel'
      when new.categoria in ('Antibiótico','Antiviral') then 'Antibióticos'
      else 'Otros' end;
    return new;
  end if;

  if new.categoria in ('Cuidado personal','Dermocosmético') then
    -- Lo que no es de piel va a Higiene (antes caía todo en Dermocosmética).
    if mk in ('ego','silica','shine sily','shinesily','silika','moco de gorila','garnier','fructis','jaloma',
        'hinds','koleston','teatrical','nivea','ponds','pond''s','lubriderm','labello','grisi','seda pure',
        'nuvel','xiomara','adidas','revlon','gum','vitacilina','pert','herbal essences','nutribela',
        'colgate','oral-b','fixodent','gillette','schick','bic','axe','old spice','rexona','dove',
        'head & shoulders','pantene','elvive','tío nacho','tio nacho','saba','kotex','naturella',
        'trojan','tena','xtreme','x-treme','just for men','ricitos de oro','arm & hammer','off!')
       or mk in ('obao','secret','sedal','sensodyne','bexident','bocasan','tampax','sico','escudo','camay',
        'blumen','caprice','super wet','sílice','kbb','johnson''s','benzal','glesol','dibar','bobo','try',
        'pulefin','t.taio','yoli')
       or s in ('Higiene bucal','Bucal','Afeitado','Cabello','Capilar','Cuidado capilar','Cuidado del cabello',
        'Tinte','Depilación','Chupones','Desodorante','Preservativos','Higiene femenina','Higiene','Manicure',
        'Baño','Antibacterial','Desinfectante','Uñas','Bebé')
       or n ~* '(shampoo|champ(u|ú)|acondicionador|gel .*(cabello|fijaci)|cera |tinte|peine|pasta dental|cepillo dent|enjuague|hilo dental|adhesivo dental|rastrillo|afeitar|rasurar|navaja|desodorante|antitranspirante|cond(o|ó)n|preservativo|pa(ñ|n)al|toalla (h|f)|toallitas|pinza|tijera|repelente|cortaúñas|corta(u|ú)ñas|lima de u|acetona|tamp(o|ó)n|crema dental|colutorio|crema para peinar|esponja|desinfectante|antibacterial)' then
      new.vitrina_seccion := 'Higiene y cuidado personal';
      new.vitrina_subseccion := case
        when s in ('Cabello','Capilar','Cuidado capilar','Cuidado del cabello','Tinte') or n ~* 'crema para peinar'
             or n ~* '(shampoo|champ(u|ú)|acondicionador|gel .*(cabello|fijaci)|cera |tinte|peine)' then 'Cabello'
        when s = 'Desodorante' or n ~* '(desodorante|antitranspirante)' then 'Desodorantes'
        when s in ('Higiene bucal','Bucal') or n ~* '(crema dental|colutorio)'
             or n ~* '(pasta dental|cepillo dent|enjuague|hilo dental|adhesivo dental)' then 'Higiene bucal'
        when s = 'Afeitado' or n ~* '(rastrillo|afeitar|rasurar|navaja)' then 'Afeitado'
        when s = 'Chupones' or n ~* '(pa(ñ|n)al|bebe|beb(é|e))' then 'Bebé'
        when s = 'Preservativos' or n ~* '(cond(o|ó)n|preservativo|lubricante (i|í)ntimo)' then 'Salud sexual'
        else 'Cuidado diario' end;
    else
      new.vitrina_seccion := 'Dermocosmética';
      new.vitrina_subseccion := case when n ~* '(solar|fps|spf|fotoprotec|sunscreen|sun secure|heliocare)' then 'Solar' end;
    end if;
    return new;
  end if;

  if new.categoria in ('Suplemento','Suplementos') then
    if mk in ('ensure','glucerna','pediasure','abbott') or n ~* '(ensure|glucerna|pediasure)' then
      new.vitrina_seccion := 'Vitaminas y bienestar'; new.vitrina_subseccion := 'Nutrición clínica';
    else
      new.vitrina_seccion := 'Nutrición deportiva'; new.vitrina_subseccion := null;
    end if;
    return new;
  end if;

  if new.categoria in ('Vitaminas','Herbolario') then
    new.vitrina_seccion := 'Vitaminas y bienestar';
    new.vitrina_subseccion := case when new.categoria='Herbolario' then 'Herbolarios'
      when n ~* '(probi(o|ó)tic|lactobacil)' then 'Probióticos' else 'Vitaminas' end;
    return new;
  end if;

  if new.categoria in ('Higiene','Bebés') then
    new.vitrina_seccion := 'Higiene y cuidado personal';
    new.vitrina_subseccion := case
      when n ~* '(shampoo|champ(u|ú)|acondicionador|gel .*cabello|cera |tinte|koleston)' then 'Cabello'
      when n ~* '(desodorante|antitranspirante)' then 'Desodorantes'
      when n ~* '(pasta dental|cepillo dent|enjuague bucal|hilo dental)' then 'Higiene bucal'
      when n ~* '(rastrillo|afeitar|rasurar|navaja)' then 'Afeitado'
      when n ~* '(pa(ñ|n)al|bebe|beb(é|e)|toallitas)' then 'Bebé'
      when n ~* '(cond(o|ó)n|preservativo|lubricante (i|í)ntimo)' then 'Salud sexual'
      else 'Cuidado diario' end;
    return new;
  end if;

  if new.categoria in ('Botiquín','Curación','Dispositivo médico','Dispositivos','Pruebas') then
    new.vitrina_seccion := 'Botiquín y equipo médico';
    new.vitrina_subseccion := case
      when n ~* '(term(o|ó)metro|baum(a|á)n(o|ó)metro|presi(o|ó)n)' then 'Termómetros y baumanómetros'
      when n ~* '(gluc(o|ó)metro|tiras reactivas|lanceta)' then 'Glucómetros'
      when n ~* '(prueba|test)' then 'Pruebas'
      else 'Curación' end;
  end if;
  return new;
end $function$;

drop trigger if exists trg_productos_vitrina_clasificar on public.productos;
create trigger trg_productos_vitrina_clasificar
  before insert or update of activo, categoria, vitrina_seccion on public.productos
  for each row execute function public.fn_vitrina_clasificar();
