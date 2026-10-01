#!/usr/bin/env python3
"""Tickets 30-sep-2026 (fotos térmicas) → altas + cola Recibir.

6 pedidos:
  Baracentro 14438
  IFC F8 126446
  Dulcería La Victoria T280035422 (ticket imprime La Famosa)
  Cityfarma S327411
  Equilibrio 446466
  Bodega F-42 Caja 3/84416

Costo = P.U. del ticket (nunca el importe del renglón).
Equilibrio: P.U. post-descuento; lote de fábrica sí; caducidad NO.
Dulcería Skittles 24/10PZ ×2 → 48 bolsas (74.60/24 por bolsa).
F-42: P.U. impreso (líneas suman al total con IVA).
"""
from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
OCR_PATH = GEN_DIR / "tickets_20260930_ocr.json"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    digits = re.sub(r"\D", "", ean or "")
    if len(digits) >= 8:
        return "FC-" + digits[-8:]
    return f"FC-{digits or 'SIN'}"


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def foto_ok(name: str | None) -> tuple[str | None, str | None]:
    if not name:
        return None, None
    path = ROOT / "public" / "catalogo-propia" / name
    if not path.exists() or path.stat().st_size < 4000:
        return None, None
    return f"{FOTO_BASE}/{name}", f"catalogo-propia/{name}"


def fmt_costo(pu: float) -> str:
    """Hasta 4 decimales si el ticket los trae (Skittles 3.1083); si no, 2."""
    r4 = round(pu, 4)
    if abs(r4 - round(pu, 2)) < 1e-9:
        return f"{round(pu, 2):.2f}"
    # quitar ceros sobrantes pero conservar precisión necesaria
    s = f"{r4:.4f}".rstrip("0").rstrip(".")
    if "." not in s:
        s += ".00"
    return s


def p(
    *,
    sku: str,
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
    foto_name: str | None = None,
) -> dict:
    foto, foto_file = foto_ok(foto_name)
    return {
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
        "foto": foto,
        "foto_file": foto_file,
    }


def row(
    ean: str | None,
    snap: str,
    qty: int,
    pu: float,
    meta: dict,
    lote: str | None = None,
) -> dict:
    return {
        "ean": ean or "",
        "sku": meta["sku"],
        "snap": snap,
        "nombre": meta["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": round(qty * pu, 2),
        "lote": lote,
        **{
            k: meta[k]
            for k in (
                "tipo",
                "categoria",
                "subcategoria",
                "forma",
                "marca",
                "laboratorio",
                "presentacion",
                "principio",
                "concentracion",
                "receta",
                "ya",
                "foto",
                "foto_file",
            )
        },
        "precio": ceil_pvp(pu, meta["tipo"]),
        "match": "ya" if meta["ya"] else ("sin_ean" if not ean else "alta"),
    }


# ── fichas conocidas ───────────────────────────────────────────────
BARACENTRO = {
    "7501438363321": p(
        sku=sku_de("7501438363321"),
        nombre="Kuul Fix Me Urban gel fijador",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Gel",
        marca="Kuul",
        presentacion="Pieza",
    ),
}

IFC = {
    "CORTAUNAS_TRY": p(
        sku=sku_de("6932119800025"),
        nombre="Cortaúñas Try mediano C/12",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Manicure",
        forma="Accesorio",
        marca="Try",
        presentacion="Paquete C/12 (no venta individual)",
    ),
    "CORTAUNAS_BOBO": p(
        sku=sku_de("6976824588236"),
        nombre="Cortaúñas Bobo mediano sin cadena C/12",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Manicure",
        forma="Accesorio",
        marca="Bobo",
        presentacion="Paquete C/12",
    ),
    "PINZA_LADY": p(
        sku=sku_de("7501370204577"),
        nombre="Curtis Lady pinza tijera cejas",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Manicure",
        forma="Accesorio",
        marca="Curtis",
        laboratorio="Curtis",
        presentacion="1 pieza · modelo 57LC",
        ya=True,
    ),
    "YOLI_ENCH": p(
        sku=sku_de("7501370202023"),
        nombre="Yoli enchinador de pestañas",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Maquillaje",
        forma="Accesorio",
        marca="Yoli",
        laboratorio="Curtis",
        presentacion="1 pieza · modelo 102CV",
    ),
    "MIYAKO_IZQ_MED": p(
        sku=sku_de("7501877602203"),
        nombre="Miyako muñequera tipo guante izquierda neopreno mediana",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Soportes",
        forma="Muñequera",
        marca="Miyako",
        presentacion="Pieza mediana izquierda",
    ),
    "MIYAKO_IZQ_CHI": p(
        sku="FC-IFC-MYK-IZQ-CH",
        nombre="Miyako muñequera tipo guante izquierda neopreno chica",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Soportes",
        forma="Muñequera",
        marca="Miyako",
        presentacion="Pieza chica izquierda",
    ),
    "MIYAKO_IZQ_GDE": p(
        sku="FC-IFC-MYK-IZQ-GD",
        nombre="Miyako muñequera tipo guante izquierda neopreno grande",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Soportes",
        forma="Muñequera",
        marca="Miyako",
        presentacion="Pieza grande izquierda",
    ),
    "MIYAKO_DER_MED": p(
        sku="FC-IFC-MYK-DER-MD",
        nombre="Miyako muñequera tipo guante derecha neopreno mediana",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Soportes",
        forma="Muñequera",
        marca="Miyako",
        presentacion="Pieza mediana derecha",
    ),
    "MIYAKO_DER_CHI": p(
        sku="FC-IFC-MYK-DER-CH",
        nombre="Miyako muñequera tipo guante derecha neopreno chica",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Soportes",
        forma="Muñequera",
        marca="Miyako",
        presentacion="Pieza chica derecha",
    ),
    "ALICATA": p(
        sku=sku_de("6855265655229"),
        nombre="Alicata / set manicure económico mango colores",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Manicure",
        forma="Accesorio",
        presentacion="Pieza / set",
    ),
    "RICINO": p(
        sku="FC-00001292",
        nombre="Mercurio aceite de ricino 50 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Aceite",
        marca="Mercurio",
        laboratorio="Droguería Mercurio",
        presentacion="Frasco 50 ml",
        ya=True,
    ),
    "ALMENDRAS": p(
        sku="FC-D4AC123B",
        nombre="Mercurio aceite de almendras",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Aceite",
        marca="Mercurio",
        presentacion="Frasco (caja C/25)",
        ya=True,
    ),
}

DULCERIA = {
    "SKITTLES": p(
        sku="FC-LV-SKITTLES24",
        nombre="Skittles Original bolsa",
        tipo="marca",
        categoria="Impulso",
        subcategoria="Dulces",
        forma="Bolsa",
        marca="Skittles",
        presentacion="Bolsa (caja mayoreo 24/10PZ)",
        ya=True,
        foto_name="skittles-original-22g.jpg",
    ),
}

CITY = {
    "7501349014190": p(
        sku="EQ-AMS147",
        nombre="Ácido alendrónico AMSA 10 mg C/30",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 30 tabletas",
        principio="Ácido alendrónico",
        concentracion="10 mg",
        receta=True,
        ya=True,
        foto_name="alendronico-10-7501349014190.jpg",
    ),
    "7501300450227": p(
        sku=sku_de("7501300450227"),
        nombre="Bactrim suspensión 200/40 mg 100 ml",
        tipo="marca",
        forma="Suspensión",
        marca="Bactrim",
        laboratorio="Roche",
        presentacion="Frasco 100 ml",
        principio="Sulfametoxazol / trimetoprima",
        concentracion="200/40 mg/5 ml",
        receta=True,
        ya=True,
    ),
    "7501008427330": p(
        sku=sku_de("7501008427330"),
        nombre="Bepanthen pomada 100 g",
        tipo="marca",
        categoria="Dermocosmético",
        subcategoria="Piel",
        forma="Pomada",
        marca="Bepanthen",
        laboratorio="Bayer",
        presentacion="Tubo 100 g",
        principio="Dexpantenol",
        ya=True,
    ),
    "7501008427347": p(
        sku=sku_de("7501008427347"),
        nombre="Bepanthen pomada 30 g",
        tipo="marca",
        categoria="Dermocosmético",
        subcategoria="Piel",
        forma="Pomada",
        marca="Bepanthen",
        laboratorio="Bayer",
        presentacion="Tubo 30 g",
        principio="Dexpantenol",
        ya=True,
    ),
    "7506022331502": p(
        sku="EQ-JAY263",
        nombre="Diflosensi dapagliflozina 10 mg C/28",
        tipo="generico",
        forma="Tableta",
        marca="Diflosensi",
        presentacion="Caja con 28 tabletas",
        principio="Dapagliflozina",
        concentracion="10 mg",
        receta=True,
        ya=True,
    ),
    "7501390912599": p(
        sku=sku_de("7501390912599"),
        nombre="Lactiflora Fem probiótico",
        tipo="marca",
        categoria="Vitaminas",
        forma="Cápsula",
        marca="Lactiflora",
        presentacion="Caja",
        ya=True,
    ),
    "7501109902866": p(
        sku=sku_de("7501109902866"),
        nombre="Motrin Infantil suspensión 20 ml",
        tipo="marca",
        forma="Suspensión",
        marca="Motrin",
        laboratorio="Johnson & Johnson",
        presentacion="Frasco 20 ml",
        principio="Ibuprofeno",
        ya=True,
    ),
    "7501417006133": p(
        sku=sku_de("7501417006133"),
        nombre="Pasta de Lassar óxido de zinc 145 g",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Pasta",
        marca="Pasta de Lassar",
        presentacion="Tarro 145 g",
        principio="Óxido de zinc",
        ya=True,
        foto_name="pasta-de-lassar-145g.jpg",
    ),
    "7501314704156": p(
        sku=sku_de("7501314704156"),
        nombre="Senosiain adulto C/10",
        tipo="marca",
        forma="Supositorio",
        marca="Senosiain",
        laboratorio="Senosiain",
        presentacion="Caja con 10",
        ya=True,
    ),
    "7501314704187": p(
        sku=sku_de("7501314704187"),
        nombre="Senosiain bebé C/10",
        tipo="marca",
        forma="Supositorio",
        marca="Senosiain",
        laboratorio="Senosiain",
        presentacion="Caja con 10",
        ya=True,
    ),
    "7501314704163": p(
        sku=sku_de("7501314704163"),
        nombre="Senosiain niño C/10",
        tipo="marca",
        forma="Supositorio",
        marca="Senosiain",
        laboratorio="Senosiain",
        presentacion="Caja con 10",
        ya=True,
    ),
    "785118754259": p(
        sku=sku_de("785118754259"),
        nombre="Supratex levodropropizina jarabe 120 ml",
        tipo="generico",
        forma="Jarabe",
        marca="Supratex",
        laboratorio="MAVI",
        presentacion="Frasco 120 ml",
        principio="Levodropropizina",
        concentracion="600 mg/100 ml",
        ya=True,
    ),
    "650240052545": p(
        sku="FC-00525451",
        nombre="XL-3 antigripal C/10",
        tipo="generico",
        forma="Tableta",
        marca="XL-3",
        laboratorio="Genomma Lab",
        presentacion="Caja con 10 tabletas",
        principio="Paracetamol + fenilefrina + clorfenamina",
        ya=True,
    ),
}

EQ = {
    "AMS165": (
        "7501349012943",
        p(
            sku="FC-5BC5F234",
            nombre="Fluconazol 150 mg C/1",
            tipo="generico",
            forma="Cápsula",
            marca="AMSA",
            laboratorio="AMSA",
            presentacion="Caja con 1 cápsula",
            principio="Fluconazol",
            concentracion="150 mg",
            receta=True,
            ya=True,
        ),
    ),
    "AVT195": (
        "7506624900809",
        p(
            sku=sku_de("7506624900809"),
            nombre="Tusilen adulto jarabe 118 ml",
            tipo="marca",
            forma="Jarabe",
            marca="Tusilen",
            laboratorio="Avitus / Allen",
            presentacion="Frasco 118 ml",
            principio="Dextrometorfano / guaifenesina / fenilefrina",
            concentracion="0.300/2.4/0.050 g/100 ml",
        ),
    ),
    "DEN073": (
        None,
        p(
            sku="EQ-DEN073",
            nombre="Delaphil 20 mg C/4",
            tipo="generico",
            forma="Tableta",
            marca="Delaphil",
            presentacion="Caja con 4 tabletas",
            concentracion="20 mg",
            receta=True,
            ya=True,
        ),
    ),
    "COL009": (
        "780083140922",
        p(
            sku=sku_de("780083140922"),
            nombre="Ampigrin adulto 3 ámpulas",
            tipo="marca",
            forma="Inyectable",
            marca="Ampigrin",
            laboratorio="Collins",
            presentacion="3 ámpulas",
            concentracion="500/500/100/30 mg/3 ml",
            receta=True,
            ya=True,
            foto_name="ampigrin-ad-3amp.jpg",
        ),
    ),
    "RAD100": (
        "7501563380637",
        p(
            sku="EQ-RAD100",
            nombre="Fenazopiridina 100 mg C/20",
            tipo="generico",
            forma="Tableta",
            marca="Randall",
            laboratorio="Randall",
            presentacion="Frasco 20 tabletas",
            principio="Fenazopiridina",
            concentracion="100 mg",
            ya=True,
        ),
    ),
    "SER181": (
        "7501258215947",
        p(
            sku=sku_de("7501258215947"),
            nombre="Ruquimax hidroxicloroquina 200 mg C/20",
            tipo="generico",
            forma="Tableta",
            marca="Ruquimax",
            laboratorio="Serral",
            presentacion="Caja con 20 tabletas",
            principio="Hidroxicloroquina",
            concentracion="200 mg",
            receta=True,
        ),
    ),
    "NOV163": (
        "7501075722543",
        p(
            sku="EQ-NOV163",
            nombre="Pabesorag 150/12.5 mg C/28",
            tipo="generico",
            forma="Tableta",
            marca="Pabesorag",
            laboratorio="Novag",
            presentacion="Caja con 28 tabletas",
            concentracion="150/12.5 mg",
            receta=True,
            ya=True,
        ),
    ),
    "MAV226": (
        "7502009745140",
        p(
            sku=sku_de("7502009745140"),
            nombre="Clamoxin S suspensión 600/42.9 mg 50 ml",
            tipo="generico",
            forma="Suspensión",
            marca="Clamoxin",
            laboratorio="MAVI",
            presentacion="Frasco 50 ml",
            principio="Amoxicilina / ácido clavulánico",
            concentracion="600/42.9 mg/5 ml",
            receta=True,
            ya=True,
        ),
    ),
    "MAV014": (
        "7502009740503",
        p(
            sku=sku_de("7502009740503"),
            nombre="Clamoxin 12H JR suspensión 400/57 mg 50 ml",
            tipo="generico",
            forma="Suspensión",
            marca="Clamoxin",
            laboratorio="MAVI",
            presentacion="Frasco 50 ml",
            principio="Amoxicilina / ácido clavulánico",
            concentracion="400/57 mg/5 ml",
            receta=True,
            ya=True,
        ),
    ),
    "MAV013": (
        "7502009740497",
        p(
            sku=sku_de("7502009740497"),
            nombre="Clamoxin 12H PED suspensión 200/28.5 mg",
            tipo="generico",
            forma="Suspensión",
            marca="Clamoxin",
            laboratorio="MAVI",
            presentacion="Frasco",
            principio="Amoxicilina / ácido clavulánico",
            concentracion="200/28.5 mg/5 ml",
            receta=True,
            ya=True,
        ),
    ),
    "COL090": (
        "780083142308",
        p(
            sku="FC-83142308",
            nombre="Tempire paracetamol gotas 100 mg/ml 30 ml",
            tipo="marca",
            forma="Gotas",
            marca="Tempire",
            laboratorio="Collins",
            presentacion="Frasco 30 ml",
            principio="Paracetamol",
            concentracion="100 mg/ml",
            ya=True,
        ),
    ),
    "AMS424": (
        "7501349020535",
        p(
            sku="EQ-AMS424",
            nombre="Irbesartán 300 mg C/14 AMSA",
            tipo="generico",
            forma="Tableta",
            marca="AMSA",
            laboratorio="AMSA",
            presentacion="Caja con 14 tabletas",
            principio="Irbesartán",
            concentracion="300 mg",
            receta=True,
            ya=True,
        ),
    ),
    "MAV111": (
        "7502009740992",
        p(
            sku="FC-5F30F9D4",
            nombre="Clamoxin amoxicilina/clavulánico 500/125 mg C/10",
            tipo="generico",
            forma="Tableta",
            marca="Clamoxin",
            laboratorio="MAVI",
            presentacion="Caja con 10 tabletas",
            principio="Amoxicilina / ácido clavulánico",
            concentracion="500/125 mg",
            receta=True,
            ya=True,
        ),
    ),
    "LAN057": (
        "7502247373495",
        p(
            sku="EQ-LAN057",
            nombre="Bacat atorvastatina 20 mg C/30",
            tipo="generico",
            forma="Tableta",
            marca="Bacat",
            presentacion="Caja con 30 tabletas",
            principio="Atorvastatina",
            concentracion="20 mg",
            receta=True,
            ya=True,
            foto_name="bacat-atorvastatina-20mg-c30-7502247373495.jpg",
        ),
    ),
}


_BRAND_HINTS = [
    ("TIO NACHO", "Tío Nacho"),
    ("SECRET", "Secret"),
    ("NIVEA", "Nivea"),
    ("NIV ", "Nivea"),
    ("CAMAY", "Camay"),
    ("ESCUDO", "Escudo"),
    ("AXE", "Axe"),
    ("SENSODYNE", "Sensodyne"),
    ("OLD SPICE", "Old Spice"),
    ("BIC ", "BIC"),
    ("GTTE", "Gillette"),
    ("VENUS", "Gillette"),
    ("GRISI", "Grisi"),
    ("COLGATE", "Colgate"),
    ("COLGA", "Colgate"),
    ("JOHNSON", "Johnson's"),
    ("PALMOL", "Palmolive"),
    ("ELVIVE", "Elvive"),
    ("LUBRID", "Lubriderm"),
    ("H&S", "Head & Shoulders"),
    ("FRUCTIS", "Fructis"),
    ("TERNURA", "Ternura"),
    ("RICITOS", "Ricitos de Oro"),
    ("CAPRICE", "Caprice"),
    ("REXONA", "Rexona"),
    ("ODOLEX", "Odolex"),
    ("PROTEC", "Protect"),
    ("ORAL-B", "Oral-B"),
    ("ORAL B", "Oral-B"),
    ("GUM ", "GUM"),
    ("SEDAL", "Sedal"),
    ("PANTENE", "Pantene"),
    ("PANT ", "Pantene"),
    ("KBB", "KBB"),
    ("X-TREME", "X-Treme"),
    ("SILICA", "Sílice"),
    ("SILKHAIR", "Silkhair"),
    ("KOHN", "Kohn"),
    ("SUPER WET", "Super Wet"),
]


def ficha_f42(snap: str, ean: str | None) -> dict:
    up = snap.upper()
    marca = None
    for key, brand in _BRAND_HINTS:
        if key in up:
            marca = brand
            break
    # nombre de mostrador corto
    nombre = re.sub(r"\s+", " ", snap).strip().title()
    nombre = (
        nombre.replace("Sh ", "Shampoo ")
        .replace("Cra ", "Crema ")
        .replace("Desod ", "Desodorante ")
        .replace("Jbn ", "Jabón ")
        .replace("Acond ", "Acondicionador ")
        .replace("Cep Dent ", "Cepillo dental ")
        .replace("Hilo Dent ", "Hilo dental ")
        .replace("Enj Buc ", "Enjuague bucal ")
        .replace("C D ", "Crema dental ")
        .replace("Bloq ", "Bloqueador ")
        .replace("Agua Mice ", "Agua micelar ")
        .replace("Agua Mic ", "Agua micelar ")
        .replace("Pvo ", "Polvo ")
        .replace("Tco ", "Talco ")
    )
    if ean:
        sku = sku_de(ean)
    else:
        slug = re.sub(r"[^A-Z0-9]+", "", up)[:16] or "SIN"
        sku = f"FC-F42-{slug}"
    cat = "Cuidado personal"
    forma = "Pieza"
    if any(x in up for x in ("SH ", "SHAMPOO", "ACOND", "MOUSSE", "GEL X", "SILICA", "SILKHAIR")):
        forma = "Cabello"
    elif any(x in up for x in ("DESOD", "DEO ", "PVO DESOD", "ODOLEX", "TCO ")):
        forma = "Desodorante"
    elif any(x in up for x in ("CRA ", "CREMA", "LUBRID", "AFTER")):
        forma = "Crema"
    elif any(x in up for x in ("C D ", "SENSODYNE", "CEP DENT", "HILO DENT", "ENJ BUC")):
        forma = "Higiene bucal"
        cat = "Cuidado personal"
    elif "BOTIQUIN" in up or "PROTEC 13" in up:
        forma = "Botiquín"
        cat = "Botiquín"
    elif "CHUPON" in up or "TERNURA" in up:
        forma = "Accesorio"
        cat = "Bebé"
    elif "BLOQ" in up or "SUN" in up:
        forma = "Protector solar"
    return p(
        sku=sku,
        nombre=nombre[:80],
        tipo="marca",
        categoria=cat,
        subcategoria=None,
        forma=forma,
        marca=marca,
        presentacion="Pieza",
        ya=False,
    )


def write_carga_sql(ticket: dict) -> Path:
    rows = ticket["rows"]
    tmp = ticket["tmp"]
    folio = ticket["folio"]
    vals = []
    for i, r in enumerate(rows, start=1):
        ean = r["ean"] or None
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=i,
                ean=sql_str(ean),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=fmt_costo(r["pu"]),
                precio=int(r["precio"]),
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                ya="true" if r["ya"] else "false",
                foto=sql_str(r["foto"]),
                foto_file=sql_str(r["foto_file"]),
                lote=sql_str(r.get("lote")),
            )
        )

    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    sin_ean = [r["sku"] for r in rows if not r["ean"]]
    piezas = sum(int(r["qty"]) for r in rows)
    body = f"""-- {ticket['header']}
-- Piezas ticket (suma qty): {piezas}. Total ${ticket['total']:.2f}.
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): {", ".join(sin_ean) or "ninguno"}.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table {tmp} (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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
  foto_file text,
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
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
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {ticket["proveedor"]} {folio} · {ticket["fecha"]} · listo para pistola',
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
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select {sql_str(ticket["proveedor"])}, true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower({sql_str(ticket["proveedor"])})
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(ticket["proveedor"])},
  {sql_str(folio)},
  {sql_str(ticket["fecha"])},
  {ticket["total"]:.2f},
  'borrador',
  {sql_str(ticket["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
);

update public.recepciones
set
  total_ticket = {ticket["total"]:.2f},
  fecha = {sql_str(ticket["fecha"])},
  proveedor = {sql_str(ticket["proveedor"])},
  notas = {sql_str(ticket["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
order by i.id;
"""
    path = OUT_DIR / f"patch_carga_{ticket['key']}.sql"
    path.write_text(body, encoding="utf-8")
    return path


def build_tickets(ocr: dict) -> list[dict]:
    by_folio = {t["folio"]: t for t in ocr["tickets"]}
    # normalize keys from OCR
    bara = next(t for t in ocr["tickets"] if "Baracentr" in t["proveedor"])
    ifc = next(t for t in ocr["tickets"] if t["proveedor"] == "IFC")
    dul = next(t for t in ocr["tickets"] if "Dulcer" in t["proveedor"] or "Famosa" in t["proveedor"])
    city = next(t for t in ocr["tickets"] if "Cityfarma" in t["proveedor"])
    eq = next(t for t in ocr["tickets"] if "Equilibrio" in t["proveedor"])
    f42 = next(t for t in ocr["tickets"] if "F-42" in t["proveedor"] or "Bodega" in t["proveedor"])

    # Baracentro
    bl = bara["lineas"][0]
    t_bara = {
        "key": "baracentro_14438",
        "tmp": "_fc_bara_14438",
        "proveedor": "Baracentro",
        "proveedor_ilike": "Baracentro",
        "folio": "14438",
        "fecha": "2026-09-30",
        "total": 95.0,
        "header": (
            "Baracentro · folio 14438 · 2026-09-30 17:25 · Central de Abasto F34 B\n"
            "-- 1 pieza · total $95.00. P.U. = costo."
        ),
        "notas": "Baracentro 14438 · 30-sep-2026 · Kuul Fix Me Urban · stock al escanear",
        "rows": [
            row(bl["ean"], bl["nombre_ticket"], bl["cantidad"], bl["precio_unitario"], BARACENTRO[bl["ean"]])
        ],
    }

    # IFC — qty literal del ticket (PAQ = 1, PIEZA = piezas)
    # EANs de caja (fotos 01-oct): Try/Bobo/Lady/Yoli/Alicata/Ricino.
    ifc_map = [
        ("CORTAUNAS_TRY", "6932119800025"),
        ("CORTAUNAS_BOBO", "6976824588236"),
        ("PINZA_LADY", "7501370204577"),
        ("YOLI_ENCH", "7501370202023"),
        ("MIYAKO_IZQ_MED", "7501877602203"),
        ("MIYAKO_IZQ_CHI", None),
        ("MIYAKO_IZQ_GDE", None),
        ("MIYAKO_DER_MED", None),
        ("MIYAKO_DER_CHI", None),
        ("ALICATA", "6855265655229"),
        ("RICINO", "3311000001292"),
        ("ALMENDRAS", None),
    ]
    ifc_rows = []
    for (key, ean_force), line in zip(ifc_map, ifc["lineas"]):
        ean = ean_force or line.get("ean")
        ifc_rows.append(
            row(ean, line["nombre_ticket"], line["cantidad"], line["precio_unitario"], IFC[key])
        )
    assert abs(sum(r["sub"] for r in ifc_rows) - 867.0) < 0.02
    t_ifc = {
        "key": "ifc_126446",
        "tmp": "_fc_ifc_126446",
        "proveedor": "IFC F8 Tienda",
        "proveedor_ilike": "IFC",
        "folio": "126446",
        "fecha": "2026-09-30",
        "total": 867.0,
        "header": (
            "IFC F8 Tienda · folio 126446 · 2026-09-30 17:02 · CJ 01 · cliente LUIS ANGEL\n"
            "-- 38 artículos / 12 productos · total $867.00. Costo = P.PUBLICO unitario."
        ),
        "notas": "IFC F8 126446 · 30-sep-2026 · mayoreo+menudeo · MMAA de la caja",
        "rows": ifc_rows,
    }

    # Dulcería — 24/10PZ × 2 cajas = 48 bolsas; costo unitario 74.60/24
    dl = dul["lineas"][0]
    assert dl["cantidad"] == 2 and abs(dl["precio_unitario"] - 74.6) < 0.01
    sk_qty = 48
    sk_pu = round(74.60 / 24, 4)  # 3.1083
    assert abs(sk_qty * sk_pu - 149.20) < 0.02
    t_dul = {
        "key": "dulceria_victoria_T280035422",
        "tmp": "_fc_lv_t280035422",
        "proveedor": "Dulcería La Victoria",
        "proveedor_ilike": "Victoria",
        "folio": "T280035422",
        "fecha": "2026-09-30",
        "total": 149.20,
        "header": (
            "Dulcería La Victoria · nota T280035422 · 2026-09-30 17:25\n"
            "-- Ticket imprime «DULCERIA LA FAMOSA» (WinCaja); negocio La Victoria F-20.\n"
            "-- SKITTLES ORIGINAL 24/10PZ ×2 cajas → 48 bolsas · P.U. caja $74.60 → $3.1083/bolsa.\n"
            "-- Total tarjeta $149.20."
        ),
        "notas": (
            "La Famosa/La Victoria T280035422 · Skittles 48 bolsas "
            "(2×24 mayoreo) · EAN pendiente de caja"
        ),
        "rows": [row(None, dl["nombre_ticket"], sk_qty, sk_pu, DULCERIA["SKITTLES"])],
    }

    # Cityfarma
    city_rows = []
    for line in city["lineas"]:
        ean = line["ean"]
        if ean not in CITY:
            raise SystemExit(f"Cityfarma sin ficha: {ean} {line['nombre_ticket']}")
        city_rows.append(
            row(ean, line["nombre_ticket"], line["cantidad"], line["precio_unitario"], CITY[ean])
        )
    assert abs(sum(r["sub"] for r in city_rows) - 4165.25) < 0.02
    t_city = {
        "key": "cityfarma_s327411",
        "tmp": "_fc_cf_s327411",
        "proveedor": "Cityfarma",
        "proveedor_ilike": "Cityfarma",
        "folio": "S327411",
        "fecha": "2026-09-30",
        "total": 4165.25,
        "header": (
            "Cityfarma · S327411 · 2026-09-30 17:22 · Pasillo E-F 44A\n"
            "-- 43 piezas / 13 productos · pendiente $4,165.25 (= subtotal + IVA 16%).\n"
            "-- Costo = P.U. unitario del ticket. Pasta Lassar EAN 7501417006133 (check digit)."
        ),
        "notas": "Cityfarma S327411 · 30-sep-2026 · Luis Angel · MMAA de la caja",
        "rows": city_rows,
    }

    # Equilibrio
    eq_codes = [
        "AMS165",
        "AVT195",
        "DEN073",
        "COL009",
        "RAD100",
        "SER181",
        "NOV163",
        "MAV226",
        "MAV014",
        "MAV013",
        "COL090",
        "AMS424",
        "MAV111",
        "LAN057",
    ]
    eq_rows = []
    for code, line in zip(eq_codes, eq["lineas"]):
        ean, meta = EQ[code]
        snap = f"{code} {line['nombre_ticket']}"
        eq_rows.append(
            row(ean, snap, line["cantidad"], line["precio_unitario"], meta, line.get("lote"))
        )
    assert abs(sum(r["sub"] for r in eq_rows) - 2532.66) < 0.02
    assert sum(r["qty"] for r in eq_rows) == 71
    t_eq = {
        "key": "equilibrio_446466",
        "tmp": "_fc_eq_446466",
        "proveedor": "Equilibrio Farmacéutico",
        "proveedor_ilike": "Equilibrio",
        "folio": "446466",
        "fecha": "2026-09-30",
        "total": 2532.66,
        "header": (
            "Equilibrio Farmacéutico · ticket 446466 · 2026-09-30 16:57 · Iztapalapa 2\n"
            "-- Cliente 307513 Luis Angel · 71 artículos · total $2,532.66.\n"
            "-- Costo = P.U. neto post-descuento. Lote de fábrica sí. Caducidad NO."
        ),
        "notas": "Equilibrio 446466 · 30-sep-2026 · P.U. post-dto · MMAA de la caja",
        "rows": eq_rows,
    }

    # Bodega F-42
    f42_rows = []
    for line in f42["lineas"]:
        ean = line.get("ean")
        meta = ficha_f42(line["nombre_ticket"], ean)
        f42_rows.append(
            row(ean, line["nombre_ticket"], line["cantidad"], line["precio_unitario"], meta)
        )
    assert abs(sum(r["sub"] for r in f42_rows) - 6972.10) < 0.05, sum(r["sub"] for r in f42_rows)
    assert sum(r["qty"] for r in f42_rows) == 128
    t_f42 = {
        "key": "bodega_f42_84416",
        "tmp": "_fc_bf42_84416",
        "proveedor": "Bodega F-42 Ejidos del Moral",
        "proveedor_ilike": "F-42",
        "folio": "84416",
        "fecha": "2026-09-30",
        "total": 6972.10,
        "header": (
            "Bodega F-42 Ejidos del Moral · Caja 3/84416 · 2026-09-30 16:47\n"
            "-- 89 renglones / 128 piezas · subtotal $6,010.44 + impuestos $961.66 = $6,972.10.\n"
            "-- Costo = P.U. impreso (las líneas ya suman al total con IVA).\n"
            "-- Ítem 46 Grisi Ricitos Biopure: EAN cortado en foto; match por SKU al escanear."
        ),
        "notas": "Bodega F-42 84416 · 30-sep-2026 · P.U. con IVA · MMAA de la caja",
        "rows": f42_rows,
    }

    return [t_bara, t_ifc, t_dul, t_city, t_eq, t_f42]


def write_leerme(tickets: list[dict]) -> Path:
    lines = [
        "# Tickets Recibir · 30-sep-2026",
        "",
        "Fotos térmicas. Pegar **cada** SQL en Supabase → SQL Editor → Run.",
        "No pegar este `LEERME_*.md`.",
        "",
        "| Pedido | Archivo | Piezas | Total |",
        "|--------|---------|--------|-------|",
    ]
    labels = {
        "baracentro_14438": "Baracentro 14438",
        "ifc_126446": "IFC F8 126446",
        "dulceria_victoria_T280035422": "Dulcería La Victoria T280035422",
        "cityfarma_s327411": "Cityfarma S327411",
        "equilibrio_446466": "Equilibrio 446466",
        "bodega_f42_84416": "Bodega F-42 84416",
    }
    for t in tickets:
        piezas = sum(r["qty"] for r in t["rows"])
        lines.append(
            f"| {labels[t['key']]} | `patch_carga_{t['key']}.sql` | {piezas} | ${t['total']:,.2f} |"
        )
    lines += [
        "",
        "## Cantidades / precios (ojo)",
        "",
        "- **Costo = P.U. unitario**, nunca el importe del renglón.",
        "- **Dulcería Skittles:** ticket `74.60 × 2 PZA` (cajas 24/10PZ) → **48 bolsas** a **$3.1083**.",
        "- **IFC:** qty = la del ticket (PAQ C/12 = 1 paquete; aceites = piezas sueltas).",
        "- **Equilibrio:** P.U. post-descuento; lote sí; MMAA de la caja.",
        "- **Cityfarma Pasta Lassar:** EAN `7501417006133` (check digit; no `…6138`).",
        "- **F-42 #46** Grisi Ricitos Biopure: EAN cortado entre fotos → sin EAN hasta escanear.",
        "",
        "Regenerar: `python3 scripts/generar_carga_tickets_20260930.py`",
        "",
    ]
    path = OUT_DIR / "LEERME_tickets_20260930.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def write_todos(tickets: list[dict]) -> Path:
    parts = []
    for t in tickets:
        pth = OUT_DIR / f"patch_carga_{t['key']}.sql"
        body = pth.read_text(encoding="utf-8")
        # strip trailing select for combined file? keep full including begin/commit
        parts.append(f"-- ===== {t['key']} =====\n{body}")
    path = OUT_DIR / "patch_carga_tickets_20260930_TODOS.sql"
    path.write_text(
        "-- Tickets 30-sep-2026 · TODOS (Baracentro, IFC, Dulcería, Cityfarma, Equilibrio, F-42)\n"
        "-- Preferible pegar cada patch_carga_*.sql por separado si el editor corta.\n\n"
        + "\n\n".join(parts),
        encoding="utf-8",
    )
    return path


def main() -> None:
    if not OCR_PATH.exists():
        print("Falta", OCR_PATH, file=sys.stderr)
        sys.exit(1)
    ocr = json.loads(OCR_PATH.read_text(encoding="utf-8"))
    tickets = build_tickets(ocr)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    GEN_DIR.mkdir(parents=True, exist_ok=True)

    for t in tickets:
        # verify math
        s = round(sum(r["sub"] for r in t["rows"]), 2)
        if abs(s - t["total"]) > 0.05:
            raise SystemExit(f"{t['key']}: suma {s} != total {t['total']}")
        path = write_carga_sql(t)
        # csv
        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        import csv as csvmod

        with csv_path.open("w", newline="", encoding="utf-8") as fh:
            w = csvmod.writer(fh)
            w.writerow(
                [
                    "linea",
                    "folio",
                    "ean",
                    "sku",
                    "snap",
                    "nombre",
                    "qty",
                    "pu",
                    "sub",
                    "lote",
                    "match",
                ]
            )
            for i, r in enumerate(t["rows"], 1):
                w.writerow(
                    [
                        i,
                        t["folio"],
                        r["ean"],
                        r["sku"],
                        r["snap"],
                        r["nombre"],
                        r["qty"],
                        fmt_costo(r["pu"]),
                        f"{r['sub']:.2f}",
                        r.get("lote") or "",
                        r["match"],
                    ]
                )
        print(f"OK {t['key']}: {len(t['rows'])} líneas, {sum(r['qty'] for r in t['rows'])} pzas, ${t['total']:.2f} → {path.name}")

    leerme = write_leerme(tickets)
    todos = write_todos(tickets)
    print("LEERME", leerme.name)
    print("TODOS", todos.name, f"({todos.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
