#!/usr/bin/env python3
"""Cruza los productos identificados en las fotos del lote 4 contra el ticket
Equilibrio 440393 para recuperar costo, lote y caducidad.

El ticket no trae EAN, así que el cruce se hace por nombre comercial y, cuando
existe, por la presentación (número de piezas / mg / ml).
"""
import csv
import os
import re
import unicodedata

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TICKET = os.path.join(RAIZ, "sql/generated/ticket_equilibrio_440393.csv")
SALIDA = os.path.join(RAIZ, "sql/generated/match_fotos_lote4_ticket.csv")

# (nombre para buscar, descripción completa del producto, EAN)
PRODUCTOS = [
    ("SAROX", "Sarox Omeprazol cáps 20 mg — caja c/14", "7501573902584"),
    ("SAROX", "Sarox Omeprazol cáps 20 mg — caja c/28", "7501573909859"),
    ("WAMINDEL", "Wamindel Paracetamol gotas 100 mg/mL — frasco 30 mL", "7503001007656"),
    ("WAMINDEL", "Wamindel Paracetamol sol. infantil 3.2 g/100 mL — frasco 120 mL", "7503001007663"),
    ("BRAXIGORT", "Braxigort Nifuroxazida susp. 4.4 g/100 mL — frasco 90 mL", "7501825304555"),
    ("VIRINDREZ", "Virindrez Adulto Oximetazolina 0.050% — atomizador 20 mL", "7501836006042"),
    ("VIRINDREZ", "Virindrez Infantil Oximetazolina 0.025% — atomizador 20 mL", "7501836006028"),
    ("PLAYBOY", "Playboy Playpack mixtos (Classic/Extra Sens/Textured)", "7503014377074"),
    ("PLAYBOY", "Playboy Max Sens Extra Delgados 3+1", "7503014377197"),
    ("MICONAZOL", "Miconazol crema 2% — tubo 20 g (Alpharma)", "7503004908714"),
    ("SENOSIDOS", "Bioadvance Senósidos A-B 8.6 mg — caja c/20 tabs", "7506624901059"),
    ("NOVAKOSID", "Novakosid Senósidos A-B 8.6 mg — caja c/20 tabs (Novag)", "7501075723137"),
    ("DESYN", "Desyn-N Lidocaína/Hidrocortisona — caja c/6 supositorios", "7502211788928"),
    ("PRUGNEX", "Prugnex Senósidos A-B 12 mg + ciruela — caja c/30 cáps", "7503008344150"),
    ("ROSEL", "Rosel-T Amantadina/Clorfenamina/Paracetamol — caja c/15 tabs", "7503003738879"),
    ("ROSEL", "Rosel solución infantil — frasco 60 mL", "7502240450230"),
    ("ERBITRAX", "Erbitrax Terbinafina crema 1% — tubo 30 g", "7502211783282"),
    ("NAFICH", "Nafich Terbinafina crema 1% — tubo 15 g", "7501573902966"),
    ("DUALGOS", "Dualgos Paracetamol/Ibuprofeno 325/200 — caja c/20 tabs", "7501836009661"),
    ("TEMPIRE", "Tempire Paracetamol sol. ped. 100 mg/mL — frasco 30 mL", "0780083142308"),
    ("DOLZYCAM", "Dolzycam Piroxicam gel 0.5% — tubo 60 g", "7502001165045"),
    ("LADEXGEL", "Ladexgel Paracetamol/Loratadina/Dextrometorfano — caja c/12 cáps", "7503008344303"),
    ("REXURDIR", "Rexurdir Nifuroxazida 400 mg — caja c/16 cáps", "7502001165953"),
    ("ESPABION", "Espabion Trimebutina gotas 2 g/100 mL — frasco 30 mL", "7501825300366"),
    ("PAMEDAN", "Pamedan Dexpantenol crema 5% — tubo 30 g", "7502009745997"),
    ("ITAMOL", "Itamol Subsalicilato de bismuto 262 mg — caja c/24 tabs mast.", "0785118752637"),
    ("MOTILAXIL", "Motilaxil-T Picosulfato de sodio 5 mg — caja c/20 tabs", "7502006920021"),
    ("LUMBOXEN", "Lumboxen gel naproxeno/lidocaína — tubo 35 g", "7502009745539"),
    ("LUMBOXEN", "Lumboxen parche — bolsa c/1 parche", ""),
    ("OXITAL", "Oxital-C Vitamina C 2000 mg efervescente — tubo c/10 tabs", "7501258207010"),
    ("BENCIEFEDRIL", "Benciefedril jarabe dextrometorfano/guaifenesina — 120 mL", ""),
    ("PEDIALYTE", "Pedialyte SR 60 mEq uva — frasco 500 mL", "7501033956775"),
    ("HISTIACIL", "Histiacil NF jarabe infantil — frasco 150 mL", "7501328979496"),
    ("NYQUIL", "NyQuil Z Difenhidramina 25 mg — caja c/30 cáps", "7500435145497"),
    ("EXALIV", "Exaliv 325/5/2 mg — caja c/24 tabs (Maver)", "7502009747236"),
    ("TOPRON", "Topron Nifuroxazida 400 mg — caja c/16 cáps (Chinoin)", "7501088579615"),
    ("PRIM", "ML-PRIM Metocarbamol/Naproxeno 375/200 — caja c/12 cáps", "7502227427392"),
    ("NOVAGON", "Novagon polvo plántago psyllium 400 g naranja-piña", "7501075718676"),
    ("NOVAGON", "Novagon polvo (variante tapa azul) 400 g", "7501075713770"),
    ("AJOLOTIUS", "Ajolotius jarabe original 250 mL", "7500462746612"),
    ("AJOLOTIUS", "Ajolotius jarabe con propóleo 250 mL", "7500462746698"),
    ("AJOLOTIUS", "Ajolotius jarabe sin azúcar 250 mL", ""),
    ("NICOS", "Grisi Nicos de Oro crema corporal", "7501022104248"),
    ("METAMUCIL", "Metamucil plántago psyllium", "0020800790246"),
    ("DACLAFIN", "Daclafin suspensión", "7502253601339"),
    ("PROMEGA", "Promega 3 omega 3 — frasco 60 cáps", ""),
    ("GALAVER", "Galaver antiácido/antiflatulento — frasco 250 mL", ""),
    ("OPPELVER", "Oppelver lactulosa 10 g/15 mL — frasco 125 mL", ""),
    ("VASELINA", "Vaselina blanca Jaloma 60 g", ""),
    ("VELATUSS", "Velatuss levodropropizina 600 mg — frasco 120 mL", ""),
    ("AKTYZAR", "Omeprazol Aktyzar 20 mg — frasco 120 cáps", ""),
    ("OMEPRAZOL", "Omeprazol Aktyzar 20 mg — frasco 120 cáps (alterno)", ""),
    ("RASPISONS", "Raspisons ungüento neomicina/retinol — tubo 28 g", ""),
    ("HISOPOS", "Hisopos KIUTS 50 piezas (Jaloma)", ""),
    ("PRECICOL", "Precicol hioscina/paracetamol gotas — frasco 20 mL", ""),
    ("REVENOX", "Revenox melatonina 3 mg — frasco 60 tabs", ""),
    ("BRONCOLIN", "Broncolin Bicoestol pastillas — 16 piezas", ""),
    ("BICOESTOL", "Broncolin Bicoestol pastillas — 16 piezas (alterno)", ""),
    ("PHARMACAINE", "Pharmacaine lidocaína 10% — atomizador 115 mL", ""),
    ("SUPRATEX", "Supratex (Mavi Farmacéutica)", "0785118754259"),
    ("DROPROPIZINA", "Jarabe dropropizina/bromhexina (Quimpharma)", "7502223111387"),
    ("K-PEC", "Novag neomicina/caolín/pectina — frasco susp.", "7501075717914"),
    ("KPEC", "Novag neomicina/caolín/pectina — frasco susp. (alterno)", "7501075717914"),
    ("OFF", "OFF! Extra Duración aerosol 170 g", ""),
    # --- Segunda tanda: fotos IMG_5241-5302 y las 93 UUID posteriores ---
    ("NINEKA", "Nineka susp. neomicina/caolín/pectina — frasco 75 mL (Novag)", "7501075717914"),
    ("TREDA", "Treda tabletas neomicina/caolín/pectina — caja c/20 (Sanfer)", ""),
    ("BACTIVER", "Bactiver susp. sulfametoxazol/trimetoprima — frasco 120 mL", "7503000422511"),
    ("DROSEQUIM", "Drosequim jarabe infantil dropropizina/bromhexina — frasco 200 mL", "7502223111387"),
    ("METANUCIL", "Metamucil plántago psyllium sabor natural — 504 g", "0020800790246"),
    ("BICOESTOL", "Broncolin Bicoestol pastillas", "0714706910906"),
    ("ZIMETON", "Zimeton pancreatina/bilis/dimeticona — caja c/20 tabs (Son's)", ""),
    ("PLUSGEL", "Plusgel masticable 200/200/20 mg — frasco c/50 tabs", ""),
    ("ZUKEDIB", "Zukedib glimepirida 2 mg — caja c/30 tabs (Loeffler)", ""),
    ("BIOBEND", "Biobend bencidamina 0.15 g/100 mL — frasco 360 mL (Biomep)", "7501573906469"),
    ("COLLIFRIN", "Collifrin oximetazolina 0.05% adulto — frasco 20 mL", "0780083144302"),
    ("TRID", "X-TRID antigripal — caja c/12 cáps (Gelpharma)", ""),
    ("RAAMCINET", "Raamcinet cetirizina 10 mg (RAAM)", "7502227872123"),
    ("DESROTAN", "Desrotan fexofenadina 180 mg (RAAM)", "7502227875568"),
    ("FERMIG", "Fermig sumatriptán 100 mg (RAAM)", ""),
    ("RAAMFEN", "Raamfen difenidol 25 mg (RAAM)", "7502227871416"),
    ("LARITOL", "Laritol loratadina 10 mg — caja c/10 tabs (Maver)", ""),
    ("MAGSOKON", "Magsokon sulfato de magnesio polvo 26 g (Quifa)", ""),
    ("NORMEX", "Normex leche de magnesia — frascos 60/180/360 mL (Quifa)", ""),
    ("ALUMAG", "Alu-Mag susp. hidróxido aluminio/magnesio — frasco 240 mL (Novag)", "7501075710113"),
    ("EXHANTIL", "Exhantil susp. antiácido/antiflatulento — frasco 320 mL (Son's)", "7502001165298"),
    ("CULMINAX", "Culminax carbocisteína adulto — frasco 150 mL (Maver)", "7502009747779"),
    ("FEDRIMIN", "Fedrimin teofilina/ambroxol — frasco 150 mL (Maver)", "7502009747168"),
    ("COBADEX", "Cobadex adulto ambroxol/dextrometorfano — frasco 120 mL (Maver)", "7502009740268"),
    ("SIRACUX", "Siracux adulto oxeladina/ambroxol — frasco 120 mL (Maver)", "7502009745393"),
    ("ATROXOLAM", "Atroxolam teofilina/ambroxol — frasco 150 mL (Novag)", "7501075723830"),
    ("RIDIN", "Ridin pediátrica jarabe — frasco 120 mL (Son's)", "7502001163232"),
    ("BRULUAQUIL", "Bruluaquil AAS/paracetamol/cafeína — frasco c/24 tabs", ""),
    ("AFLUSIL", "Aflusil ibuprofeno susp. 2 g/100 mL — frasco 120 mL (Loeffler)", "7502211780359"),
    ("DIOTEXONA", "Diotexona dimeticona pediátrico — frasco gotero 30 mL (Loeffler)", "7502211788690"),
    ("VOLDRATOL", "Voldratol electrolitos — caja c/25 sobres (Solfran)", ""),
    ("BRUNADOL", "Brunadol infantil paracetamol/naproxeno — frasco 100 mL", "7501537103354"),
    ("DOLPRIN", "Dolprin ibuprofeno susp. 2 g/100 mL — frasco 120 mL", "0780083141929"),
    ("HIDRIGORT", "Hidrigort difenhidramina 50 mg — caja c/8 tabs (Degort's)", "7501825304142"),
    ("LESACLOR", "Lesaclor aciclovir crema 5% — tubo 5 g (Mavi)", "0785118753597"),
    ("ARGENTAL", "Argental sulfadiazina de plata crema 1% — tubo 28 g (Liferpal)", "7501836000828"),
    ("PHARMAFIL", "Pharmafil LP teofilina 100 mg — caja c/20 tabs (Alpharma)", "7502226291475"),
    ("FAZOLIN", "Fazolin nafazolina 1 mg/mL — frasco gotero 15 mL (Collins)", "0780083144807"),
    ("SULINDACO", "Sulindaco 200 mg — caja c/20 tabs (AMSA)", "7501349020337"),
    ("HEMOGER", "Hemoger sulfato ferroso — frasco c/50 grageas (Streger)", ""),
    ("VOMISIN", "Vomisin dimenhidrinato 50 mg — caja c/20 tabs (Rayere)", "7502003388107"),
    ("TELMISARTAN", "Telmisartán 40 mg — caja c/28 tabs (AMSA)", "7501349025844"),
    ("GROOBE", "Groobe dimenhidrinato 50 mg — caja c/24 cáps (Gelpharma)", "7502227425008"),
    ("LOZAMIR", "Lozamir-V clotrimazol crema 2% — tubo 20 g (Biomep)", "7501573906407"),
    ("REDBELGY", "Redbelgy cianocobalamina 1000 mcg — frasco c/30 tabs (CMD)", "7501590287992"),
    ("CALTRON", "Caltrón 600+D calcio/vitamina D — frasco c/60 tabs", "0714908100099"),
    ("BENVIA", "Benvia infantil dimenhidrinato — frasco 120 mL (Loeffler)", "7506386100158"),
    ("AMPIGRIN", "Ampigrin PFC infantil jarabe — frasco 60 mL", ""),
    ("BROMHEXINA", "Bromhexina solución Biomep (adulto 160 mg / infantil 80 mg)", ""),
    ("PANTOPRAZOL", "Pantoprazol 20 mg — caja c/7 tabs (AMSA)", ""),
    ("BIOXOVER", "Bioxover dropropizina jarabe 3 mg/mL — frasco 120 mL", ""),
    ("FLOROGLUCINOL", "Floroglucinol/trimetilfloroglucinol 80/80 mg — caja c/20 cáps", "7501471800210"),
    ("TOBRAMICINA", "Tobramicina/dexametasona sol. oftálmica — frasco 5 mL (Grin)", "0008400005823"),
    ("DEXPANTENOL", "Dexpantenol crema 5% — tubo 30 g (Maver)", ""),
    ("SONS", "Baby Son's pomada dexpantenol 5% — tubo 30 g", "7502001166578"),
    ("DIFENHIDRAMINA", "Difenhidramina 25 mg — caja c/10 cáps (Gelpharma)", "7502227424995"),
    ("KERAFFLER", "Keraffler ketotifeno (Loeffler)", ""),
]


def normaliza(texto: str) -> str:
    texto = unicodedata.normalize("NFKD", texto.upper())
    texto = "".join(c for c in texto if not unicodedata.combining(c))
    return re.sub(r"[^A-Z0-9 ]", " ", texto)


def main() -> None:
    with open(TICKET) as fh:
        lineas = list(csv.DictReader(fh))
    for l in lineas:
        l["_norm"] = normaliza(l["descripcion"])

    filas = []
    for clave, descripcion, ean in PRODUCTOS:
        clave_n = normaliza(clave).strip()
        hits = [l for l in lineas if clave_n in l["_norm"]]
        if not hits:
            filas.append({"producto": descripcion, "ean": ean, "estado": "SIN MATCH",
                          "codigo_prov": "", "descripcion_ticket": "", "lote": "",
                          "caducidad": "", "cantidad": "", "costo_unitario": ""})
            continue
        for h in hits:
            filas.append({
                "producto": descripcion, "ean": ean,
                "estado": "MATCH" if len(hits) == 1 else f"MATCH ({len(hits)} candidatos)",
                "codigo_prov": h["codigo_prov"], "descripcion_ticket": h["descripcion"],
                "lote": h["lote"], "caducidad": h["caducidad"],
                "cantidad": h["cantidad"], "costo_unitario": h["costo_unitario"],
            })

    with open(SALIDA, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(filas[0].keys()))
        w.writeheader()
        w.writerows(filas)

    con = {f["producto"] for f in filas if f["estado"] != "SIN MATCH"}
    sin = {f["producto"] for f in filas if f["estado"] == "SIN MATCH"}
    for f in filas:
        if f["estado"] != "SIN MATCH":
            print(f'{f["producto"][:52]:<52} | {f["codigo_prov"]:<7} | '
                  f'{f["descripcion_ticket"][:40]:<40} | {f["lote"]:<12} | '
                  f'{f["caducidad"]:<10} | {f["costo_unitario"]:>8}')
    print(f"\nproductos con match: {len(con)} | sin match: {len(sin)}")
    print("SIN MATCH:", ", ".join(sorted(sin)))
    print("CSV:", SALIDA)


if __name__ == "__main__":
    main()
