#!/usr/bin/env python3
"""Tickets 17-nov-2026 (fotos) → altas + cola Recibir.

6 pedidos:
  Surtidor 161443 · Equilibrio 451922 · IFC 134202
  Farma Mayoreo V01000004500 · Cityfarma 15341570 · Surtidor 161448

Nombres de mostrador (no código de ticket). Caducidad null (MMAA de la caja).
Equilibrio/Farma Mayoreo: lote de fábrica sí; caducidad del papel NO.
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_tickets_1711_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_recibir_tickets_1711_SOLO_pegar_esto.md"
FOTO = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    return int(math.ceil(costo * (1.25 if tipo == "marca" else 1.6)))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def foto(name: str | None) -> str | None:
    if not name:
        return None
    path = ROOT / "public" / "catalogo-propia" / name
    if path.exists() and path.stat().st_size >= 4000:
        return f"{FOTO}/{name}"
    return f"{FOTO}/{name}" if name else None


def P(
    ean: str | None,
    *,
    nombre: str,
    tipo: str = "generico",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    if not sku:
        if ean:
            sku = sku_de(ean)
        else:
            raise ValueError(f"sku requerido sin EAN: {nombre}")
    return {
        "ean": ean,
        "sku": sku,
        "nombre": nombre,
        "tipo": tipo,
        "categoria": categoria,
        "subcategoria": subcategoria,
        "forma": forma,
        "marca": marca,
        "laboratorio": laboratorio,
        "presentacion": presentacion,
        "principio": principio,
        "concentracion": concentracion,
        "receta": receta,
        "ya": ya,
        "foto": foto(foto_file),
    }


# Catálogo de fichas (mostrador). Clave = EAN o SKU si no hay EAN.
CAT: dict[str, dict] = {
    # --- Surtidor / Electrolit / Naturella / Kola Loka ---
    "7501125149221": P(
        "7501125149221",
        nombre="Electrolit Fresa-Kiwi 625 ml",
        tipo="marca",
        categoria="Suero oral",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
        sku="FC-25149221",
        foto_file=None,
    ),
    "7501125104688": P(
        "7501125104688",
        nombre="Electrolit Naranja-Mandarina 625 ml",
        tipo="marca",
        categoria="Suero oral",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
        sku="FC-25104688",
        foto_file="electrolit-naranja-mandarina-625ml-7501125104688.jpg",
    ),
    "7501125144851": P(
        "7501125144851",
        nombre="Electrolit Uva 625 ml",
        tipo="marca",
        categoria="Suero oral",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
        sku="FC-25144851",
        foto_file="electrolit-uva-625ml-7501125144851.jpg",
    ),
    "7506195158739": P(
        "7506195158739",
        nombre="Naturella regulares sin alas",
        tipo="marca",
        categoria="Higiene",
        forma="Toallas sanitarias",
        marca="Naturella",
        presentacion="Caja con 8 toallas",
        concentracion="Flujo abundante",
        ya=False,
        sku="FC-95158739",
    ),
    "7501001405335": P(
        "7501001405335",
        nombre="Naturella noche con alas",
        tipo="marca",
        categoria="Higiene",
        forma="Toallas sanitarias",
        marca="Naturella",
        presentacion="Caja con 8 toallas",
        ya=True,
        sku="FC-01405335",
    ),
    "7501102614506": P(
        "7501102614506",
        nombre="Kola Loka brocha",
        tipo="marca",
        categoria="Botiquin",
        forma="Pegamento",
        marca="Kola Loka",
        presentacion="Caja con 8 piezas",
        ya=False,
        sku="FC-02614506",
    ),
    "7501102611000": P(
        "7501102611000",
        nombre="Kola Loka gota",
        tipo="marca",
        categoria="Botiquin",
        forma="Pegamento",
        marca="Kola Loka",
        presentacion="Caja con 10 goteros",
        ya=False,
        sku="FC-02611000",
    ),
    # --- Equilibrio ---
    "0780083142308": P(
        "0780083142308",
        nombre="Tempire paracetamol gotas 100 mg/mL",
        tipo="generico",
        subcategoria="Respiratorio",
        forma="Gotas",
        marca="Tempire",
        laboratorio="Collins",
        presentacion="Frasco 30 mL con pipeta",
        principio="Paracetamol",
        concentracion="100 mg/mL",
        receta=False,
        ya=True,
        sku="FC-83142308",
    ),
    "0780083144302": P(
        "0780083144302",
        nombre="Collifrin Adulto oximetazolina 0.05%",
        tipo="generico",
        subcategoria="Respiratorio",
        forma="Solucion nasal",
        marca="Collifrin",
        laboratorio="Collins",
        presentacion="Frasco 20 mL",
        principio="Oximetazolina",
        concentracion="0.05%",
        receta=False,
        ya=True,
        sku="FC-83144302",
    ),
    "7502227426449": P(
        "7502227426449",
        nombre="Nesajar pinaverio/dimeticona 100/300 mg",
        tipo="marca",
        forma="Capsulas",
        marca="Nesajar",
        laboratorio="Gelpharma",
        presentacion="Caja con 16 capsulas",
        principio="Pinaverio / Dimeticona",
        concentracion="100 mg / 300 mg",
        receta=True,
        ya=True,
        sku="FC-7426449",
    ),
    "7501573902584": P(
        "7501573902584",
        nombre="Sarox omeprazol 20 mg",
        tipo="marca",
        forma="Capsulas",
        marca="Sarox",
        laboratorio="Biomep",
        presentacion="Caja con 14 capsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        receta=True,
        ya=True,
        sku="FC-73902584",
    ),
    "7502227426869": P(
        "7502227426869",
        nombre="Rotumal diclofenaco gel 1.16%",
        tipo="marca",
        forma="Gel",
        marca="Rotumal",
        laboratorio="Vitae",
        presentacion="Tubo 60 g",
        principio="Diclofenaco",
        concentracion="1.16%",
        receta=False,
        ya=True,
        sku="EQ-VIT055",
    ),
    "7502009746321": P(
        "7502009746321",
        nombre="Nisolver prednisolona 1 mg/mL",
        tipo="marca",
        forma="Solucion oral",
        marca="Nisolver",
        laboratorio="Maver",
        presentacion="Frasco 100 mL",
        principio="Prednisolona",
        concentracion="1 mg/mL",
        receta=True,
        ya=True,
        sku="EQ-MAV300",
        foto_file="nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg",
    ),
    "7501349022515": P(
        "7501349022515",
        nombre="Cefotaxima IM 1 g/4 mL",
        tipo="generico",
        forma="Solucion inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Frasco ampula 1 g/4 mL",
        principio="Cefotaxima",
        concentracion="1 g/4 mL",
        receta=True,
        ya=True,
        sku="FC-22B18244",
    ),
    "EQ-ALP0607": P(
        None,
        nombre="Diclofenaco 75 mg/3 mL C/2 ampolletas",
        tipo="generico",
        forma="Solucion inyectable",
        marca="Alpharma",
        laboratorio="Alpharma",
        presentacion="Caja con 2 ampolletas de 3 mL",
        principio="Diclofenaco sodico",
        concentracion="75 mg/3 mL",
        receta=True,
        ya=False,
        sku="EQ-ALP0607",
    ),
    "7501573909859": P(
        "7501573909859",
        nombre="Sarox omeprazol 20 mg",
        tipo="marca",
        forma="Capsulas",
        marca="Sarox",
        laboratorio="Biomep",
        presentacion="Caja con 28 capsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        receta=True,
        ya=True,
        sku="FC-73909859",
    ),
    "7502227870532": P(
        "7502227870532",
        nombre="Voydol ketorolaco 10 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Voydol",
        laboratorio="Raam",
        presentacion="Caja con 10 tabletas",
        principio="Ketorolaco",
        concentracion="10 mg",
        receta=True,
        ya=True,
        sku="EQ-RAM038",
    ),
    "7501349024267": P(
        "7501349024267",
        nombre="Ketorolaco 30 mg/1 mL C/3 ampolletas",
        tipo="generico",
        forma="Solucion inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 3 ampolletas de 1 mL",
        principio="Ketorolaco trometamina",
        concentracion="30 mg/1 mL",
        receta=True,
        ya=True,
        sku="EQ-AMS328",
    ),
    "7501349023369": P(
        "7501349023369",
        nombre="Ketorolaco sublingual 30 mg C/6",
        tipo="generico",
        forma="Tableta sublingual",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 6 tabletas sublinguales",
        principio="Ketorolaco trometamina",
        concentracion="30 mg",
        receta=True,
        ya=True,
        sku="EQ-AMS160",
    ),
    "7501349024328": P(
        "7501349024328",
        nombre="Ketorolaco sublingual 30 mg C/4",
        tipo="generico",
        forma="Tableta sublingual",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 4 tabletas sublinguales",
        principio="Ketorolaco trometamina",
        concentracion="30 mg",
        receta=True,
        ya=False,
        sku="EQ-AMS496",
    ),
    # --- IFC Miyako ---
    "FC-MIY-RANA-MED": P(
        None,
        nombre="Miyako ferula para dedo tipo rana mediana",
        tipo="marca",
        categoria="Botiquin",
        forma="Ferula",
        marca="Miyako",
        presentacion="1 pieza mediana",
        ya=False,
        sku="FC-MIY-RANA-MED",
    ),
    "FC-MIY-RECTA-CH": P(
        None,
        nombre="Miyako ferula para dedo recta chica",
        tipo="marca",
        categoria="Botiquin",
        forma="Ferula",
        marca="Miyako",
        presentacion="1 pieza chica",
        ya=False,
        sku="FC-MIY-RECTA-CH",
    ),
    "0750187760234": P(
        "0750187760234",
        nombre="Miyako ferula para dedo recta grande",
        tipo="marca",
        categoria="Botiquin",
        forma="Ferula",
        marca="Miyako",
        presentacion="1 pieza grande",
        ya=False,
        sku="FC-87760234",
    ),
    "FC-MIY-RECTA-MED": P(
        None,
        nombre="Miyako ferula para dedo recta mediana",
        tipo="marca",
        categoria="Botiquin",
        forma="Ferula",
        marca="Miyako",
        presentacion="1 pieza mediana",
        ya=False,
        sku="FC-MIY-RECTA-MED",
    ),
    # --- Farma Mayoreo ---
    "7501088575396": P(
        "7501088575396",
        nombre="Troferit 3 mg/mL jarabe 120 mL",
        tipo="marca",
        forma="Jarabe",
        marca="Troferit",
        presentacion="Frasco 120 mL",
        principio="Levodropropizina",
        concentracion="3 mg/mL",
        receta=True,
        ya=False,
        sku="FC-88575396",
    ),
    "7501037907117": P(
        "7501037907117",
        nombre="Bisolvon solucion adulto 120 mL",
        tipo="marca",
        forma="Solucion",
        marca="Bisolvon",
        laboratorio="Sanofi",
        presentacion="Frasco 120 mL",
        principio="Bromhexina",
        concentracion="160 mg/100 mL",
        receta=False,
        ya=True,
        sku="FC-7907117",
    ),
    "7501159580182": P(
        "7501159580182",
        nombre="Sinuberase probioticos 4 billones",
        tipo="marca",
        categoria="Gastro",
        forma="Ampolletas",
        marca="Sinuberase",
        presentacion="Caja con 10 ampolletas",
        principio="Bacillus clausii",
        concentracion="4 billones UFC",
        receta=False,
        ya=False,
        sku="FC-59580182",
    ),
    "7501089810526": P(
        "7501089810526",
        nombre="Picosend amoniaco 3.5%",
        tipo="marca",
        categoria="Botiquin",
        forma="Solucion",
        marca="Picosend",
        presentacion="Tubo 11 mL",
        concentracion="3.5%",
        receta=False,
        ya=False,
        sku="FC-89810526",
    ),
    "7501089810625": P(
        "7501089810625",
        nombre="Picosend Protect repelente 120 mL",
        tipo="marca",
        categoria="Botiquin",
        forma="Repelente",
        marca="Picosend",
        presentacion="Frasco 120 mL",
        ya=False,
        sku="FC-89810625",
    ),
    "75012571": P(
        "75012571",
        nombre="Picosend Protect travel 50 mL",
        tipo="marca",
        categoria="Botiquin",
        forma="Repelente",
        marca="Picosend",
        presentacion="Frasco 50 mL",
        ya=False,
        sku="FC-75012571",
    ),
    "7501299368145": P(
        "7501299368145",
        nombre="Sensibit D NF",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Jarabe",
        marca="Sensibit",
        presentacion="2x1",
        ya=False,
        sku="FC-99368145",
    ),
    # --- Cityfarma ---
    "7501070613044": P(
        "7501070613044",
        nombre="Andantol isotipendilo jalea 25 g",
        tipo="marca",
        categoria="Dermatologia",
        forma="Jalea",
        marca="Andantol",
        laboratorio="Sanfer",
        presentacion="Tubo 25 g",
        principio="Isotipendilo",
        concentracion="0.75 g/100 g",
        receta=False,
        ya=False,
        sku="FC-70613044",
    ),
    "7841141004051": P(
        "7841141004051",
        nombre="Arluy Duo 200/300 mg",
        tipo="marca",
        forma="Capsulas",
        marca="Arluy Duo",
        presentacion="Caja con 30 capsulas",
        principio="Mebeverina / Simeticona",
        concentracion="200 mg / 300 mg",
        receta=True,
        ya=False,
        sku="FC-41004051",
    ),
    "7506331301142": P(
        "7506331301142",
        nombre="Autevazen 500 mg",
        tipo="marca",
        forma="Capsulas",
        marca="Autevazen",
        presentacion="Caja con 60 capsulas",
        concentracion="500 mg",
        receta=True,
        ya=False,
        sku="FC-31301142",
    ),
    "7501008409572": P(
        "7501008409572",
        nombre="Berocca Cal Mag",
        tipo="marca",
        categoria="Suplementos",
        forma="Tabletas efervescentes",
        marca="Berocca",
        presentacion="Caja con 10 tabletas",
        ya=False,
        sku="FC-08409572",
    ),
    "0714706903359": P(
        "0714706903359",
        nombre="Bronco Rub exhalador C/12",
        tipo="marca",
        categoria="Botiquin",
        forma="Pastillas",
        marca="Bronco Rub",
        presentacion="Caja con 12 pastillas",
        ya=False,
        sku="FC-06903359",
    ),
    "7501065095718": P(
        "7501065095718",
        nombre="Centrum Balance",
        tipo="marca",
        categoria="Suplementos",
        forma="Tabletas",
        marca="Centrum",
        presentacion="Frasco con 30 tabletas",
        ya=True,
        sku="FC-65095718",
        foto_file="centrum-balance-30-tabletas-7501065095718.jpg",
    ),
    "3664798074680": P(
        "3664798074680",
        nombre="Enterogermina 2 billones",
        tipo="marca",
        categoria="Gastro",
        forma="Ampolletas",
        marca="Enterogermina",
        presentacion="Caja con 10 ampolletas",
        principio="Bacillus clausii",
        concentracion="2 billones UFC",
        ya=True,
        sku="FC-79807468",
    ),
    "7501165010826": P(
        "7501165010826",
        nombre="Enterogermina 4 billones",
        tipo="marca",
        categoria="Gastro",
        forma="Ampolletas",
        marca="Enterogermina",
        presentacion="Caja con 10 ampolletas",
        principio="Bacillus clausii",
        concentracion="4 billones UFC",
        ya=False,
        sku="FC-65010826",
    ),
    "7502009740916": P(
        "7502009740916",
        nombre="Erispan Hypack 8 mg/2 ml",
        tipo="marca",
        forma="Solucion inyectable",
        marca="Erispan",
        laboratorio="Maver",
        presentacion="Frasco ampula 2 ml",
        principio="Betametasona",
        concentracion="8 mg/2 ml",
        receta=True,
        ya=True,
        sku="FC-50AC2C82",
        foto_file="erispan-hypack-8mg-7502009740916.jpg",
    ),
    "7501159525015": P(
        "7501159525015",
        nombre="Eucaliptine jarabe 140 ml",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Jarabe",
        marca="Eucaliptine",
        presentacion="Frasco 140 ml",
        ya=True,
        sku="FC-9525015",
    ),
    "7501300421968": P(
        "7501300421968",
        nombre="Exbufen apixaban",
        tipo="marca",
        forma="Tabletas",
        marca="Exbufen",
        presentacion="Caja",
        principio="Apixaban",
        receta=True,
        ya=False,
        sku="FC-00421968",
    ),
    "7501008497340": P(
        "7501008497340",
        nombre="Flanax 550 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Flanax",
        presentacion="Caja con 12 tabletas",
        principio="Naproxeno sodico",
        concentracion="550 mg",
        ya=True,
        sku="FC-84973401",
        foto_file="flanax-550mg-12tab-7501008497340.jpg",
    ),
    "7501008498866": P(
        "7501008498866",
        nombre="Flanax 550 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Flanax",
        presentacion="Caja con 6 tabletas",
        principio="Naproxeno sodico",
        concentracion="550 mg",
        ya=True,
        sku="FC-08498866",
        foto_file="flanax-550mg-6tab-7501008498866.jpg",
    ),
    "0780083148966": P(
        "0780083148966",
        nombre="Gelmicin crema 40 g",
        tipo="marca",
        categoria="Dermatologia",
        forma="Crema",
        marca="Gelmicin",
        presentacion="Tubo 40 g",
        ya=False,
        sku="FC-83148966",
    ),
    "3664798073256": P(
        "3664798073256",
        nombre="Histiacil GR3 ambroxol",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Jarabe",
        marca="Histiacil",
        laboratorio="Opella",
        presentacion="Frasco",
        principio="Ambroxol",
        ya=True,
        sku="FC-98073256",
    ),
    "3664798073232": P(
        "3664798073232",
        nombre="Histiacil GR3 ambroxol",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Jarabe",
        marca="Histiacil",
        laboratorio="Opella",
        presentacion="Frasco",
        principio="Ambroxol",
        ya=False,
        sku="FC-98073232",
    ),
    "7501064560163": P(
        "7501064560163",
        nombre="Iodex Cristal",
        tipo="marca",
        categoria="Botiquin",
        forma="Unguento",
        marca="Iodex",
        presentacion="60 g",
        ya=True,
        sku="FC-64560163",
    ),
    "7501075713176": P(
        "7501075713176",
        nombre="Lamblit 500 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Lamblit",
        presentacion="Caja con 30 tabletas",
        concentracion="500 mg",
        receta=True,
        ya=False,
        sku="FC-75713176",
    ),
    "7502001161627": P(
        "7502001161627",
        nombre="Lisonin 600 mg/2 ml",
        tipo="marca",
        forma="Solucion inyectable",
        marca="Lisonin",
        laboratorio="Sons",
        presentacion="Ampolleta 2 ml",
        principio="Lincomicina",
        concentracion="600 mg/2 ml",
        receta=True,
        ya=True,
        sku="EQ-SON083",
    ),
    "7502001161641": P(
        "7502001161641",
        nombre="Lisonin 600 mg solucion inyectable",
        tipo="marca",
        forma="Solucion inyectable",
        marca="Lisonin",
        laboratorio="Sons",
        presentacion="Ampolleta",
        principio="Lincomicina",
        concentracion="600 mg",
        receta=True,
        ya=False,
        sku="FC-01161641",
    ),
    "7501258214766": P(
        "7501258214766",
        nombre="Menirol",
        tipo="marca",
        forma="Tabletas",
        marca="Menirol",
        presentacion="Caja con 28 tabletas",
        ya=False,
        sku="FC-58214766",
    ),
    "7501007535487": P(
        "7501007535487",
        nombre="Motrin gotas pediatricas",
        tipo="marca",
        forma="Gotas",
        marca="Motrin",
        presentacion="Frasco",
        principio="Ibuprofeno",
        ya=False,
        sku="FC-07535487",
    ),
    "7501537102395": P(
        "7501537102395",
        nombre="Norapred 50 mg",
        tipo="generico",
        forma="Tabletas",
        marca="Norapred",
        laboratorio="Brudifarma",
        presentacion="Caja con 20 tabletas",
        principio="Prednisolona",
        concentracion="50 mg",
        receta=True,
        ya=True,
        sku="FMX-502376",
    ),
    "7502235760672": P(
        "7502235760672",
        nombre="Sienna suplemento alimenticio",
        tipo="marca",
        categoria="Suplementos",
        forma="Suplemento",
        marca="Sienna",
        presentacion="Caja",
        ya=False,
        sku="FC-35760672",
    ),
    "7501349029729": P(
        "7501349029729",
        nombre="Telmisartan/hidroclorotiazida",
        tipo="generico",
        forma="Tabletas",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja",
        principio="Telmisartan / Hidroclorotiazida",
        receta=True,
        ya=False,
        sku="FC-49029729",
    ),
    "7590002012468": P(
        "7590002012468",
        nombre="Vicks VapoRub 50 g",
        tipo="marca",
        categoria="Botiquin",
        forma="Unguento",
        marca="Vicks",
        presentacion="Tarro 50 g",
        ya=True,
        sku="FC-02012468",
    ),
}


def row(key: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    p = CAT[key]
    return {
        **p,
        "snap": snap,
        "qty": qty,
        "pu": round(pu, 2),
        "sub": round(qty * round(pu, 2), 2),
        "precio": ceil_pvp(pu, p["tipo"]),
        "lote": lote,
    }


TICKETS = [
    {
        "key": "surtidor_161443",
        "tmp": "_fc_sur_161443",
        "folio": "161443",
        "proveedor": "El Surtidor de su Farmacia",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-11-17",
        "total": 216.00,
        "notas": (
            "El Surtidor · venta 161443 · Bodega F48 · 17-nov-2026 11:04 · Luis · "
            "Electrolit c/desc. mayoreo + Naturella · cola Recibir; MMAA de la caja"
        ),
        "header": "El Surtidor · folio 161443 · 2026-11-17 · total $216.00 · 5 renglones · costo = importe neto",
        "rows": [
            row("7501125149221", "ELECTROLIT LIQ 625ML FRESA-KIWI", 2, 19.00),
            row("7501125104688", "ELECTROLIT LIQ 625ML NARANJA-MANDARINA", 2, 19.00),
            row("7501125144851", "ELECTROLIT LIQ 625ML UVA", 2, 19.00),
            row("7506195158739", "NATURELLA FLUJO MOD S/ALAS C/8", 5, 13.00),
            row("7501001405335", "NATURELLA NOCHE CON ALAS C/8", 2, 18.50),
        ],
    },
    {
        "key": "equilibrio_451922",
        "tmp": "_fc_eq_451922",
        "folio": "451922",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-11-17",
        "total": 1541.23,
        "notas": (
            "Equilibrio Iztapalapa 2 · ticket 451922 · pedido online · 17-nov-2026 10:53 · "
            "cliente 307513 Luis Angel Palillero · costo = P.U. neto · lote de fabrica; "
            "caducidad NO (MMAA de la caja) · cola Recibir"
        ),
        "header": "Equilibrio · folio 451922 · 2026-11-17 · total $1,541.23 · 13 renglones / 70 pzas",
        "rows": [
            row("0780083142308", "COL090 TEMPIRE 1 GOT 100MG/30 ML", 3, 19.20, "26141560"),
            row("0780083144302", "COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML", 6, 32.38, "26141294"),
            row("7502227426449", "GEP014 NESAJAR 16 CAPS 300/100 MG", 3, 111.21, "260274"),
            row("7501573902584", "BIO067 SAROX 14 CAPS 20 MG", 10, 7.80, "SH26006"),
            row("7502227426869", "VIT055 ROTUMAL 1 GEL 60G/1.16 %", 2, 23.02, "261306"),
            row("7502009746321", "MAV300 NISOLVER 1 SOL 100 ML", 5, 69.42, "260451"),
            row("7501349022515", "AMS263 CEFOTAXIMA I.M. 1 FA 1G/4 ML", 5, 32.33, "J2611085"),
            row("EQ-ALP0607", "ALP0607 DICLOFENACO 2 AMP 75MG/3 ML", 2, 16.19, "2601498"),
            row("7501573909859", "BIO213 SAROX 28 CAPS 20 MG", 5, 14.39, "SH26113"),
            row("7502227870532", "RAM038 VOYDOL 10 TAB 10 MG", 5, 5.72, "RVD0226"),
            row("7501349024267", "AMS328 KETOROLACO 3 AMP 30 MG", 4, 11.05, "2611001"),
            row("7501349023369", "AMS160 KETOROLACO TROMETAMINA 6 TAB SL 30 MG", 10, 8.99, "U26Y032"),
            row("7501349024328", "AMS496 KETOROLACO SL 4 TAB 30 MG", 10, 5.59, "U26F370"),
        ],
    },
    {
        "key": "ifc_134202",
        "tmp": "_fc_ifc_134202",
        "folio": "134202",
        "proveedor": "IFC",
        "proveedor_ilike": "ifc",
        "fecha": "2026-11-17",
        "total": 372.00,
        "notas": (
            "IFC F8 Tienda · CJ 01 Fol 134202 · 17-nov-2026 11:38 · Luis · efectivo · "
            "Miyako ferulas mayoreo · cola Recibir; MMAA de la caja"
        ),
        "header": "IFC · folio 134202 · 2026-11-17 · total $372.00 · 4 renglones / 6 pzas",
        "rows": [
            row("FC-MIY-RANA-MED", "MIYAKO FERULA PARA DEDO TIPO RANA MED 22087", 2, 62.00),
            row("FC-MIY-RECTA-CH", "MIYAKO FERULA PARA DEDO RECTA CHICA 22089", 1, 62.00),
            row("0750187760234", "MIYAKO FERULA PARA DEDO RECTA GRANDE 81979", 1, 62.00),
            row("FC-MIY-RECTA-MED", "MIYAKO FERULA PARA DEDO RECTA MEDIANA", 2, 62.00),
        ],
    },
    {
        "key": "farmamayoreo_4500",
        "tmp": "_fc_fm_4500",
        "folio": "V01000004500",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-11-17",
        "total": 1625.91,
        "notas": (
            "Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 11:31 · TC BBVA $1,625.91 · "
            "P.U. ya traen IVA (suma renglones = total) · lote de fabrica; caducidad NO · cola Recibir"
        ),
        "header": (
            "Farma Mayoreo · folio V01000004500 · 2026-11-17 · total $1,625.91\n"
            "-- P.U. con IVA. Suma renglones = total."
        ),
        "rows": [
            row("7501088575396", "TROFERIT 3MG/ML CON FRASCO 120ML", 1, 144.97, "BFG058"),
            row("7501037907117", "BISOLVON SOLUCION ADULTO FRASCO CON 120 ML", 2, 146.98, "23980029"),
            row("7501159580182", "SINUBERASE PROBIOTICOS CAJA CON 10 AMPOLLETAS", 3, 217.98, "61175"),
            row("7501089810526", "PICOSEND AMONIACO SOLUCION 3.5% TUBO CON 11 ML", 2, 73.98),
            row("7501089810625", "PICOSEND PROTECT REPELENTE 120ML", 2, 81.98),
            row("75012571", "REPEL PICOSEND PROTECT TRAVE 50 ML", 3, 38.98),
            row("7501299368145", "SENSIBIT D NF 2X1", 2, 52.09, "010484"),
        ],
    },
    {
        "key": "cityfarma_15341570",
        "tmp": "_fc_cf_15341570",
        "folio": "15341570",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-11-17",
        "total": 6982.85,
        "notas": (
            "Cityfarma Iztapalapa · orden 15341570 · 17-nov-2026 10:37 · Eduardo Alcantara · "
            "cliente Luis Angel Palillero · 28 renglones · EANs validados por digito de control · "
            "Enterogermina 2 bill EAN canonico 3664798074680 · total = suma P.U. · cola Recibir"
        ),
        "header": "Cityfarma · folio 15341570 · 2026-11-17 · total $6,982.85 · 28 renglones",
        "rows": [
            row("7501070613044", "ANDANTOL 25GR JALEA", 2, 173.80),
            row("7841141004051", "ARLUY DUO 200MG/300MG", 1, 682.02),
            row("7506331301142", "AUTEVAZEN 500MG C60", 1, 83.52),
            row("7501008409572", "BEROCCA CAL MAG C 10", 1, 144.05),
            row("0714706903359", "BRONCO RUB EXH C12 P", 1, 133.35),
            row("7501065095718", "CENTRUM BALANCE C30T", 1, 136.52),
            row("3664798074680", "ENTEROGERMINA 2 BILL", 3, 200.00),
            row("7501165010826", "ENTEROGERMINA 4 BILL", 2, 442.76),
            row("7502009740916", "ERISPAN HYPACK 8MG/2", 5, 24.80),
            row("7501159525015", "EUCALIPTINE JBE 140", 1, 141.56),
            row("7501300421968", "EXBUFEN APIXABAN TAB", 2, 166.67),
            row("7501008497340", "FLANAX 550 C 12 TABS", 2, 173.02),
            row("7501008498866", "FLANAX 550MG C6 TABS", 2, 98.16),
            row("0780083148966", "GELMICIN CRA 40G BE", 3, 21.71),
            row("3664798073256", "HISTIACIL GR3 AMBROX", 1, 121.18),
            row("3664798073232", "HISTIACIL GR3 AMBROX", 1, 121.18),
            row("7501064560163", "IODEX CRISTAL 24", 3, 71.99),
            row("7501349024328", "KETOROLACO 30MG C/4", 8, 6.49),
            row("7501349023369", "KETOROLACO 30MG C6 T", 5, 9.98),
            row("7501075713176", "LAMBLIT 500 MG C 30", 5, 18.28),
            row("7502001161627", "LISONIN 600 MG C 1 A", 3, 31.48),
            row("7502001161641", "LISONIN 600MG SOL I", 3, 56.13),
            row("7501258214766", "MENIROL C28T 10 24", 2, 95.12),
            row("7501007535487", "MOTRIN GTS PED FSA", 1, 113.76),
            row("7501537102395", "NORAPRED 50MG C20 PR", 5, 30.88),
            row("7502235760672", "SIENNA SUPLEM ALIM C", 1, 1048.94),
            row("7501349029729", "TELMISARTAN HIDROCLO", 2, 42.74),
            row("7590002012468", "VAPORUB 50GR TARRO", 3, 85.56),
        ],
    },
    {
        "key": "surtidor_161448",
        "tmp": "_fc_sur_161448",
        "folio": "161448",
        "proveedor": "El Surtidor de su Farmacia",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-11-17",
        "total": 334.00,
        "notas": (
            "El Surtidor · venta 161448 · Bodega F48 · 17-nov-2026 11:09 · Luis · "
            "Kola Loka brocha + gota (16% IVA incluido en P.U.) · cola Recibir"
        ),
        "header": "El Surtidor · folio 161448 · 2026-11-17 · total $334.00 · 2 renglones",
        "rows": [
            row("7501102614506", "KOLA LOKA BROCHA C/8", 1, 167.00),
            row("7501102611000", "KOLA LOKA C/10 GOTA", 1, 167.00),
        ],
    },
]


def render_ticket(t: dict) -> str:
    rows = t["rows"]
    tmp = t["tmp"]
    folio = t["folio"]
    vals = []
    for i, r in enumerate(rows, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {sub}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {img}, {lote})".format(
                linea=i,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=int(r["precio"]),
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                sub=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta=sql_str(r["receta"]),
                ya=sql_str(r["ya"]),
                img=sql_str(r["foto"]),
                lote=sql_str(r.get("lote")),
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    ilike = sql_str("%" + t["proveedor_ilike"] + "%")
    return f"""
-- ========== {t['proveedor']} {folio} ==========
-- {t['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table {tmp} (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
{",\n".join(vals)};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {t["proveedor"]} {folio} · {t["fecha"]} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(t["proveedor"])},
  {sql_str(folio)},
  {sql_str(t["fecha"])},
  {t["total"]:.2f},
  'borrador',
  {sql_str(t["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {t["total"]:.2f},
  fecha = {sql_str(t["fecha"])},
  proveedor = {sql_str(t["proveedor"])},
  notas = {sql_str(t["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {ilike}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""


def main() -> None:
    for t in TICKETS:
        s = round(sum(r["sub"] for r in t["rows"]), 2)
        expected = t.get("sum_lines", t["total"])
        diff = abs(s - expected)
        if diff > 0.05:
            raise SystemExit(f"{t['folio']}: sum {s} != expected {expected} (diff {diff})")
        print(f"{t['folio']}: {len(t['rows'])} rows · sum {s} · total {t['total']} · Δ{diff:.2f}")

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Tickets 17-nov-2026 → cola Recibir (borrador).",
        "-- Merge a GitHub NO los crea. Sin bloques dollar-quote. Sin producto_imagenes.",
        "-- Caducidad null: MMAA de la caja. No inventar 0000.",
        "-- Cada ticket es begin/commit independiente.",
        "-- Al final: VERIFICACION FINAL con los 6 folios en borrador.",
        "-- Luego: tablet Recibir → recargar → aparecen las tarjetas.",
        "-- =============================================================================",
        "",
    ]
    for t in TICKETS:
        parts.append(render_ticket(t))

    ver_ors = "\n or ".join(
        f"(r.folio = {sql_str(t['folio'])} and coalesce(r.proveedor, '') ilike {sql_str('%' + t['proveedor_ilike'] + '%')})"
        for t in TICKETS
    )
    parts.append(
        f"""
-- ========== VERIFICACION FINAL ==========
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
    {ver_ors}
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
"""
    )
    OUT_SQL.write_text("\n".join(parts), encoding="utf-8")

    table = "\n".join(
        f"| {t['proveedor']} | **{t['folio']}** | ${t['total']:,.2f} | {len(t['rows'])} |"
        for t in TICKETS
    )
    OUT_MD.write_text(
        f"""# Tickets 17-nov-2026 → Recibir

El merge a GitHub **no** crea la cola. Pegar **todo** el SQL en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
{table}

## Pasos

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_tickets_1711_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → pegar → **Run**
3. VERIFICACION FINAL con los 6 folios en `borrador`
4. Tablet Recibir → recargar

## Notas

1. **Surtidor 161443:** Electrolit c/desc. mayoreo + Naturella regulares sin alas EAN caja `7506195158739` (no el con alas `7501001157296`).
2. **Equilibrio 451922:** claves → EAN de ficha. Lote sí; caducidad NO. ALP0607 sin EAN en portal (match por SKU).
3. **IFC 134202:** Miyako férulas; EAN solo en recta grande (`0750187760234`).
4. **Farma Mayoreo V01000004500:** subtotal $1,566.76 + IVA $59.15 = $1,625.91.
5. **Cityfarma 15341570:** Enterogermina 2 `3664798074680`. EANs de caja: Enterogermina 4 `7501165010826`, Arluy Duo `7841141004051`.
6. **Surtidor 161448:** Kola Loka brocha + gota.
7. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
""",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"→ {OUT_MD.relative_to(ROOT)}")
    if "$$" in OUT_SQL.read_text(encoding="utf-8"):
        raise SystemExit("ERROR: el SQL contiene $$ (dollar-quote)")


if __name__ == "__main__":
    main()
