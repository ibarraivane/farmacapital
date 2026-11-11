#!/usr/bin/env python3
"""Tickets 10-nov-2026 (fotos) → altas + cola Recibir.

6 pedidos (+ Benavides 09-nov en el mismo lote de fotos):
  Benavides 7993605 · Cityfarma S339687 · Equilibrio 451326
  Farmalive 16337 · Bodega F-42 28786 · FESA 1-5573418

Nombres de mostrador (no código de ticket). Caducidad null (MMAA de la caja).
Farmalive: costo = P.U. neto después del descuento del renglón.
Equilibrio: costo = P.U. neto; lote/cad del papel NO se guarda.
FESA ACTÚA 2+1: 3 piezas, costo = total/3.
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_tickets_1011_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_tickets_20261110.md"
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
    return f"{FOTO}/{name}" if name else None


def P(
    ean: str,
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
    return {
        "ean": ean,
        "sku": sku or sku_de(ean),
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


# Catálogo de fichas (mostrador). ya=True si ya vimos el EAN en cargas previas.
CAT: dict[str, dict] = {
    # Benavides / FESA
    "7730766001562": P(
        "7730766001562",
        nombre="Vedipal diosmina/hesperidina 900/100 mg",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Circulación",
        forma="Tabletas",
        marca="Vedipal",
        laboratorio="Asofarma",
        presentacion="Caja con 30 tabletas",
        principio="Diosmina / Hesperidina",
        concentracion="900 mg / 100 mg",
        receta=False,
        ya=False,
    ),
    "7730766001067": P(
        "7730766001067",
        nombre="Vilzermet vildagliptina/metformina 50/1000 mg",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Diabetes",
        forma="Comprimidos",
        marca="Vilzermet",
        laboratorio="Asofarma",
        presentacion="Caja con 30 comprimidos",
        principio="Vildagliptina / Metformina",
        concentracion="50 mg / 1000 mg",
        receta=True,
        ya=False,
    ),
    # Equilibrio
    "7502001165328": P(
        "7502001165328",
        nombre="Expicin ampicilina 500 mg",
        tipo="generico",
        forma="Cápsulas",
        marca="Expicin",
        laboratorio="Sons",
        presentacion="Caja con 20 cápsulas",
        principio="Ampicilina",
        concentracion="500 mg",
        receta=True,
        ya=False,
    ),
    "7502001163485": P(
        "7502001163485",
        nombre="Clotrimazol Dual",
        tipo="generico",
        forma="Óvulos + crema",
        marca="Clotrimazol Dual",
        laboratorio="Sons",
        presentacion="3 óvulos 200 mg + crema 1% 10 g",
        principio="Clotrimazol",
        concentracion="200 mg / 1%",
        receta=False,
        ya=False,
        foto_file="clotrimazol-dual-sons.jpg",
    ),
    # Cityfarma
    "7501125116810": P(
        "7501125116810",
        nombre="Agrifen",
        tipo="marca",
        forma="Tabletas",
        marca="Agrifen",
        laboratorio="Pisa",
        presentacion="Caja con 10 tabletas",
        principio="Paracetamol / Fenilefrina / Clorfenamina",
        ya=True,
    ),
    "7500462746643": P(
        "7500462746643",
        nombre="Ajolotius pastillas",
        tipo="marca",
        categoria="Vitaminas",
        forma="Pastillas",
        marca="Ajolotius",
        laboratorio="Bioalimentos",
        presentacion="Caja con 10 pastillas",
        ya=True,
    ),
    "7506452400267": P(
        "7506452400267",
        nombre="Ajolotius jarabe Elderberry",
        tipo="marca",
        categoria="Vitaminas",
        forma="Jarabe",
        marca="Ajolotius",
        laboratorio="Bioalimentos",
        presentacion="Frasco 250 ml",
        ya=True,
    ),
    "7501349027343": P(
        "7501349027343",
        nombre="Amsafast orlistat 120 mg",
        tipo="marca",
        categoria="Gastro",
        subcategoria="Obesidad",
        forma="Cápsulas",
        marca="Amsafast",
        laboratorio="AMSA",
        presentacion="Caja con 21 cápsulas",
        principio="Orlistat",
        concentracion="120 mg",
        receta=True,
        ya=True,
        foto_file="amsafast-120mg-c21.jpg",
    ),
    "7502211781059": P(
        "7502211781059",
        nombre="Bromicof solución infantil",
        tipo="marca",
        forma="Solución",
        marca="Bromicof",
        presentacion="Frasco 100 ml",
        ya=False,
    ),
    "7501349027329": P(
        "7501349027329",
        nombre="Dexametasona 8 mg/2 ml",
        tipo="generico",
        forma="Solución inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Ampolleta 2 ml",
        principio="Dexametasona",
        concentracion="8 mg/2 ml",
        receta=True,
        ya=False,
    ),
    "7502009747274": P(
        "7502009747274",
        nombre="Dolver ibuprofeno 600 mg",
        tipo="marca",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Dolver",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Ibuprofeno",
        concentracion="600 mg",
        ya=True,
        foto_file="dolver-600mg-10tab-7502009747274.jpg",
    ),
    "7501300408556": P(
        "7501300408556",
        nombre="Dorixina Relax",
        tipo="marca",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Dorixina",
        laboratorio="Roemmers",
        presentacion="Caja con 20 tabletas",
        principio="Clonixinato de lisina / Ciclobenzaprina",
        concentracion="125 mg / 5 mg",
        receta=True,
        ya=False,
    ),
    "7501034605115": P(
        "7501034605115",
        nombre="Jardianz empagliflozina 25 mg",
        tipo="marca",
        subcategoria="Diabetes",
        forma="Tabletas",
        marca="Jardianz",
        presentacion="Caja con 30 tabletas",
        principio="Empagliflozina",
        concentracion="25 mg",
        receta=True,
        ya=False,
    ),
    "7503008344488": P(
        "7503008344488",
        nombre="Lactopram AD",
        tipo="marca",
        categoria="Gastro",
        forma="Cápsulas",
        marca="Lactopram",
        presentacion="Caja con 20 cápsulas",
        ya=False,
    ),
    "7503008344716": P(
        "7503008344716",
        nombre="Lafemme vitaminas",
        tipo="marca",
        categoria="Vitaminas",
        forma="Tabletas",
        marca="Lafemme",
        presentacion="Multivitamínico",
        ya=False,
    ),
    "7501007535487": P(
        "7501007535487",
        nombre="Motrin gotas pediátricas",
        tipo="marca",
        categoria="Analgésico",
        subcategoria="Pediátrico",
        forma="Gotas",
        marca="Motrin",
        laboratorio="Kenvue",
        presentacion="Frasco gotero",
        principio="Ibuprofeno",
        ya=False,
    ),
    "7502001166028": P(
        "7502001166028",
        nombre="Neoderm-F crema",
        tipo="generico",
        categoria="Dermatología",
        forma="Crema",
        marca="Neoderm-F",
        laboratorio="Sons",
        presentacion="Tubo",
        ya=False,
    ),
    "7506442700759": P(
        "7506442700759",
        nombre="Olmesartán 20 mg",
        tipo="generico",
        subcategoria="Cardiovascular",
        forma="Tabletas",
        marca="Olmesartán",
        presentacion="Caja con 14 tabletas",
        principio="Olmesartán",
        concentracion="20 mg",
        receta=True,
        ya=False,
    ),
    "7503000422658": P(
        "7503000422658",
        nombre="Pentiver ampicilina",
        tipo="generico",
        forma="Cápsulas",
        marca="Pentiver",
        presentacion="Caja",
        principio="Ampicilina",
        receta=True,
        ya=False,
    ),
    "7501075723724": P(
        "7501075723724",
        nombre="Rovemax diosmina/hesperidina",
        tipo="marca",
        subcategoria="Circulación",
        forma="Tabletas",
        marca="Rovemax",
        laboratorio="Novag",
        presentacion="Caja con 20 tabletas",
        principio="Diosmina / Hesperidina",
        ya=False,
    ),
    "7501089810007": P(
        "7501089810007",
        nombre="Venastat gel fresco",
        tipo="marca",
        subcategoria="Circulación",
        forma="Gel",
        marca="Venastat",
        presentacion="Tubo",
        ya=False,
    ),
    "7502009744853": P(
        "7502009744853",
        nombre="Versalver 160 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Versalver",
        laboratorio="Maver",
        presentacion="Caja con 14 tabletas",
        concentracion="160 mg",
        receta=True,
        ya=False,
    ),
    # Farmalive
    "6502400315021": P(
        "6502400315021",
        nombre="Tukol-D jarabe infantil",
        tipo="marca",
        forma="Jarabe",
        marca="Tukol-D",
        laboratorio="Genomma",
        presentacion="Frasco 120 ml",
        principio="Guaifenesina / Dextrometorfano",
        ya=True,
    ),
    "3614225108785": P(
        "3614225108785",
        nombre="Koleston 50 castaño claro",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Tinte",
        marca="Koleston",
        laboratorio="Wella / HFC",
        presentacion="Kit",
        ya=True,
        foto_file="koleston-50-castano-claro.jpg",
    ),
    "7501298219370": P(
        "7501298219370",
        nombre="Iliadin Lub spray infantil",
        tipo="marca",
        forma="Spray",
        marca="Iliadin",
        laboratorio="P&G Health",
        presentacion="Frasco 20 ml",
        ya=False,
    ),
    "7502208894779": P(
        "7502208894779",
        nombre="Tribedoce",
        tipo="marca",
        categoria="Vitaminas",
        forma="Tabletas",
        marca="Tribedoce",
        laboratorio="Bruluart",
        presentacion="Caja con 30 tabletas",
        principio="Tiamina / Piridoxina / Cianocobalamina",
        ya=True,
    ),
    "7502304290246": P(
        "7502304290246",
        nombre="GUM kit viaje infantil Bob Esponja",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Kit",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="3 piezas",
        ya=False,
    ),
    "070942125352": P(
        "070942125352",
        nombre="GUM kit de ortodoncia",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Kit",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="6 piezas",
        ya=True,
        foto_file="gum-kit-ortodoncia-6pzas-070942125352.jpg",
    ),
    "070942303194": P(
        "070942303194",
        nombre="GUM hilo dental 128 m",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Hilo dental",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="128 m",
        ya=False,
    ),
    "7501008491140": P(
        "7501008491140",
        nombre="Tabcin Pods Active",
        tipo="marca",
        forma="Cápsulas",
        marca="Tabcin",
        laboratorio="Bayer",
        presentacion="2 packs con 12 cápsulas",
        ya=False,
    ),
    "070942302357": P(
        "070942302357",
        nombre="GUM capuchones para cepillos",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Accesorio",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="Caja con 4",
        ya=False,
    ),
    "7501007533896": P(
        "7501007533896",
        nombre="Cotonetes Johnson's",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Hisopos",
        marca="Johnson's",
        laboratorio="Kenvue",
        presentacion="Bolsa con 150",
        ya=False,
    ),
    "7501033953361": P(
        "7501033953361",
        nombre="Ensure polvo chocolate",
        tipo="marca",
        categoria="Vitaminas",
        subcategoria="Nutrición",
        forma="Polvo",
        marca="Ensure",
        laboratorio="Abbott",
        presentacion="Lata 400 g",
        ya=False,
    ),
    "759684272103": P(
        "759684272103",
        nombre="Cotonetes Kiuts",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Hisopos",
        marca="Kiuts",
        laboratorio="Jaloma",
        presentacion="Bote con 100",
        ya=False,
    ),
    "759684273094": P(
        "759684273094",
        nombre="Cotonetes Kiuts",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Hisopos",
        marca="Kiuts",
        laboratorio="Jaloma",
        presentacion="Bote con 50",
        ya=False,
    ),
    "7501125174797": P(
        "7501125174797",
        nombre="Electrolit mora azul",
        tipo="marca",
        categoria="Suero",
        forma="Solución",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
    ),
    "7501125187179": P(
        "7501125187179",
        nombre="Electrolit guayaba",
        tipo="marca",
        categoria="Suero",
        forma="Solución",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
        foto_file="electrolit-guayaba-625ml-7501125187179.jpg",
    ),
    "7501125149221": P(
        "7501125149221",
        nombre="Electrolit fresa-kiwi",
        tipo="marca",
        categoria="Suero",
        forma="Solución",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 ml",
        ya=True,
    ),
    "714706918964": P(
        "714706918964",
        nombre="Properlas propóleo y eucalipto",
        tipo="marca",
        forma="Pastillas",
        marca="Properlas",
        laboratorio="Broncolin",
        presentacion="50 g",
        ya=False,
    ),
    "714706918940": P(
        "714706918940",
        nombre="Properlas propóleo y jengibre",
        tipo="marca",
        forma="Pastillas",
        marca="Properlas",
        laboratorio="Broncolin",
        presentacion="50 g",
        ya=False,
    ),
}


def bodega_p(ean: str, nombre: str, **kw) -> dict:
    defaults = dict(
        tipo="marca",
        categoria="Cuidado personal",
        ya=False,
    )
    defaults.update(kw)
    return P(ean, nombre=nombre, **defaults)


# Bodega F-42 — higiene / desodorantes / jabones
for ean, nombre, kw in [
    ("7506306209862", "Axe Anarchy Fresh Love for Her spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7506306213081", "Axe Music Fresh spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7506306209855", "Axe Anarchy for Her spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7506306245686", "Axe Epic Fresh spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7506306251847", "Axe Black Remix spray 210 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "210 ml"}),
    ("7791293025810", "Axe Fusion spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7509546073767", "Stefano Black spray 113 g", {"marca": "Stefano", "forma": "Spray", "presentacion": "113 g"}),
    ("7506306250604", "Axe Dark Temptation spray 210 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "210 ml"}),
    ("7506306244795", "Axe Intense spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7791293025780", "Axe Apollo spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("7509546694702", "Stefano Next Level spray 150 ml", {"marca": "Stefano", "forma": "Spray", "presentacion": "150 ml"}),
    ("7791293025803", "Axe Excite spray 150 ml", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Spray", "presentacion": "150 ml"}),
    ("8700216334655", "Old Spice Wolfthorn stick 50 g", {"marca": "Old Spice", "laboratorio": "P&G", "forma": "Stick", "presentacion": "50 g"}),
    ("7506309806068", "Old Spice Fresh gel 80 g", {"marca": "Old Spice", "laboratorio": "P&G", "forma": "Gel", "presentacion": "80 g"}),
    ("810120501628", "Grisi Control Azufre jabón 100 g", {"marca": "Grisi", "forma": "Jabón", "presentacion": "100 g", "subcategoria": "Piel"}),
    ("7503014119032", "Jabón de azufre con miel 80 g", {"marca": "Azufre", "forma": "Jabón", "presentacion": "80 g", "subcategoria": "Piel"}),
    ("7505514121782", "Jabón proteína de arroz y concha nácar 80 g", {"marca": "Concha Nácar", "forma": "Jabón", "presentacion": "80 g", "subcategoria": "Piel"}),
    ("850040940121", "Grisi Agua de Rosas jabón 125 g", {"marca": "Grisi", "forma": "Jabón", "presentacion": "125 g", "subcategoria": "Piel"}),
    ("7501022150818", "Grisi Concha Nácar jabón 125 g", {"marca": "Grisi", "forma": "Jabón", "presentacion": "125 g", "subcategoria": "Piel", "ya": True, "foto_file": "grisi-concha-nacar-jabon-125g.jpg"}),
    ("7501027278487", "Obao Fresquísima roll-on 65 g", {"marca": "Obao", "forma": "Roll-on", "presentacion": "65 g", "ya": True, "foto_file": "obao-fresquissima-rollon-65g.jpg"}),
    ("7509552876284", "Obao Dermo Niacinamida roll-on 65 g", {"marca": "Obao", "forma": "Roll-on", "presentacion": "65 g"}),
    ("75076221", "Axe Epic Fresh stick 45 g", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Stick", "presentacion": "45 g", "sku": "FC-AXE-EPIC-ST"}),
    ("7509552909821", "Obao Rosa Tea roll-on 65 g", {"marca": "Obao", "forma": "Roll-on", "presentacion": "65 g"}),
    ("7509546073781", "Stefano Midnight spray 113 g", {"marca": "Stefano", "forma": "Spray", "presentacion": "113 g"}),
    ("75076238", "Axe Apollo stick 45 g", {"marca": "Axe", "laboratorio": "Unilever", "forma": "Stick", "presentacion": "45 g", "sku": "FC-AXE-APOL-ST"}),
    ("7501035911208", "Palmolive Aquarium jabón líquido 221 ml", {"marca": "Palmolive", "laboratorio": "Colgate-Palmolive", "forma": "Jabón líquido", "presentacion": "221 ml"}),
    ("7509546059556", "Palmolive Neutro Balance Dermol jabón líquido 221 ml", {"marca": "Palmolive", "laboratorio": "Colgate-Palmolive", "forma": "Jabón líquido", "presentacion": "221 ml"}),
    ("7501022150092", "Grisi Leche de Burra jabón 125 g", {"marca": "Grisi", "forma": "Jabón", "presentacion": "125 g", "subcategoria": "Piel"}),
    ("7501019006623", "Saba Buenas Noches con alas", {"marca": "Saba", "forma": "Toalla sanitaria", "presentacion": "Caja con 8", "subcategoria": "Higiene femenina"}),
    ("7509552876352", "Obao Dermo Magnesio roll-on 65 g", {"marca": "Obao", "forma": "Roll-on", "presentacion": "65 g"}),
    ("7509552876369", "Obao Dermo Zinc roll-on 65 g", {"marca": "Obao", "forma": "Roll-on", "presentacion": "65 g"}),
    ("7501361156007", "Avant Concha Nácar crema corporal 90 g", {"marca": "Avant", "forma": "Crema", "presentacion": "90 g", "subcategoria": "Piel"}),
    ("7501022104217", "Grisi Concha Nácar crema 110 g", {"marca": "Grisi", "forma": "Crema", "presentacion": "110 g", "subcategoria": "Piel"}),
    ("7506267923654", "Honey Keeper gel manzanilla y miel 200 ml", {"marca": "Honey Keeper", "forma": "Gel", "presentacion": "200 ml", "subcategoria": "Piel", "foto_file": "honey-keeper-gel-manzanilla-200ml.jpg"}),
    ("3614225108914", "Koleston 77 castaño bambi", {"marca": "Koleston", "laboratorio": "Wella / HFC", "forma": "Tinte", "presentacion": "Kit", "subcategoria": "Cabello", "ya": True, "foto_file": "koleston-77-castano-bambi-3614225108914.jpg"}),
    ("850040940602", "Grisi Organogal Silver shampoo kit", {"marca": "Grisi", "forma": "Shampoo", "presentacion": "400 ml + 130 ml", "subcategoria": "Cabello", "foto_file": "grisi-organogal-silver-kit.jpg"}),
    ("7509552901511", "Fructis rizos elásticos 48h 300 ml", {"marca": "Fructis", "laboratorio": "Garnier", "forma": "Crema", "presentacion": "300 ml", "subcategoria": "Cabello"}),
    ("7509552908749", "Fructis pelo dañado perfecto 300 ml", {"marca": "Fructis", "laboratorio": "Garnier", "forma": "Crema", "presentacion": "300 ml", "subcategoria": "Cabello"}),
    ("7501048351046", "Protec gel antibacterial lima-limón 125 ml", {"marca": "Protec", "forma": "Gel", "presentacion": "125 ml", "subcategoria": "Antiséptico"}),
    ("7501199416168", "X-Treme Attraction gel 200 g", {"marca": "X-Treme", "forma": "Gel", "presentacion": "200 g", "subcategoria": "Cabello"}),
    ("7509546072272", "Colgate Kids Fresantástico 50 g", {"marca": "Colgate", "laboratorio": "Colgate-Palmolive", "forma": "Pasta dental", "presentacion": "50 g", "subcategoria": "Higiene bucal"}),
    ("7509552914696", "Fructis control definición rizos 300 ml", {"marca": "Fructis", "laboratorio": "Garnier", "forma": "Crema", "presentacion": "300 ml", "subcategoria": "Cabello"}),
    ("7501048351039", "Protec gel antibacterial 50 ml", {"marca": "Protec", "forma": "Gel", "presentacion": "50 ml", "subcategoria": "Antiséptico"}),
]:
    CAT[ean] = bodega_p(ean, nombre, **kw)


def row(ean: str, snap: str, qty: int, pu: float) -> dict:
    p = CAT[ean]
    return {
        **p,
        "snap": snap,
        "qty": qty,
        "pu": round(pu, 2),
        "sub": round(qty * round(pu, 2), 2),
        "precio": ceil_pvp(pu, p["tipo"]),
    }


TICKETS = [
    {
        "key": "benavides_7993605",
        "tmp": "_fc_ben_7993605",
        "folio": "7993605",
        "proveedor": "Benavides",
        "proveedor_ilike": "benavides",
        "fecha": "2026-11-09",
        "total": 2208.00,
        "notas": (
            "Benavides ecommerce · No. Pedido 7993605 · Pedido Internet 222927347 · "
            "09-nov-2026 22:05 · Suc. Rojo Gómez · PayPal $2,208 · Vedipal x4 · cola Recibir"
        ),
        "header": "Benavides · folio 7993605 · 2026-11-09 · total $2,208.00 · 1 renglón (Vedipal x4)",
        "rows": [
            row("7730766001562", "VEDIPAL 900MG/100MG 30 TAB", 4, 552.00),
        ],
    },
    {
        "key": "cityfarma_s339687",
        "tmp": "_fc_cf_s339687",
        "folio": "S339687",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-11-10",
        "total": 3211.17,
        "notas": (
            "Cityfarma Iztapalapa · orden S339687 · 10-nov-2026 16:59 · Jonathan Moreno · "
            "cliente Luis Angel Palillero · ALMACEN · TC $3,211.17 · cola Recibir"
        ),
        "header": "Cityfarma Iztapalapa · folio S339687 · 2026-11-10 · total $3,211.17 · 18 renglones",
        "rows": [
            row("7501125116810", "AGRIFEN TAB C 10 PIS", 10, 16.11),
            row("7500462746643", "AJOLOTIUS C10 PAST M", 2, 18.11),
            row("7506452400267", "AJOLOTIUS JBE 250ML", 2, 69.92),
            row("7501349027343", "AMSAFAST 120MG CAP C", 2, 87.10),
            row("7502211781059", "BROMICOF SOL INF 100", 2, 13.95),
            row("7501349027329", "DEXAMETASONA 8MG 2ML", 10, 7.00),
            row("7502009747274", "DOLVER 600MG C 10 TA", 5, 17.53),
            row("7501300408556", "DORIXINA RELAX C 20", 2, 320.00),
            row("7501034605115", "JARDIANZ 25MG TAB C3", 1, 850.00),
            row("7503008344488", "LACTOPRAM AD C20 CA", 3, 27.33),
            row("7503008344716", "LAFEMME VITAMINAS ME", 2, 84.97),
            row("7501007535487", "MOTRIN GTS PED FSA-", 2, 113.76),
            row("7502001166028", "NEODERM-F CREMA ACE", 1, 25.30),
            row("7506442700759", "OLMESARTAN 20MG C14", 1, 73.79),
            row("7503000422658", "PENTIVER AMPICILINA", 2, 24.58),
            row("7501075723724", "ROVEMAX TAB C20 DIOS", 2, 59.95),
            row("7501089810007", "VENASTAT GEL FRESCO", 1, 112.65),
            row("7502009744853", "VERSALVER 160MG C14", 2, 82.00),
        ],
    },
    {
        "key": "equilibrio_451326",
        "tmp": "_fc_eq_451326",
        "folio": "451326",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-11-10",
        "total": 202.63,
        "notas": (
            "Equilibrio Iztapalapa 2 · ticket 451326 · 10-nov-2026 17:11 · cliente 307513 "
            "Luis Angel Palillero · costo neto tras descuento · ahorro ticket $1,067.37 · "
            "lote/cad del papel NO se guarda (MMAA de la caja) · cola Recibir"
        ),
        "header": (
            "Equilibrio · folio 451326 · 2026-11-10 · total $202.63 · 2 renglones\n"
            "-- Claves SON237/SON164 → EAN Sons. Costo = P.U. neto."
        ),
        "rows": [
            row("7502001165328", "SON237 EXPICIN 20 CAPS 500 MG", 3, 32.43),
            row("7502001163485", "SON164 CLOTRIMAZOL DUAL 3 OVS 200MG 1CMA 10G", 2, 52.67),
        ],
    },
    {
        "key": "farmalive_16337",
        "tmp": "_fc_fl_16337",
        "folio": "16337",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-11-10",
        "total": 1912.97,
        "notas": (
            "Farmalive Club Iztapalapa 1 · ticket 16337 · 10-nov-2026 18:31 · "
            "subtotal $1,973 − descuento $60.03 = $1,912.97 · costo = P.U. neto · cola Recibir"
        ),
        "header": "Farmalive · folio 16337 · 2026-11-10 · total $1,912.97 · 18 renglones · costo neto",
        "rows": [
            row("6502400315021", "TUKOL D JBE INF 120 ML", 2, 129.75),
            row("3614225108785", "TINTE KOLESTON # 50 CASTANO CLARO", 1, 53.20),
            row("7501298219370", "ILIADIN LUB SPRAY INF 20 ML", 3, 144.06),
            row("7502208894779", "TRIBEDOCE TAB C/30 NVO", 5, 17.64),
            row("7502304290246", "KIT VIAJE GUM INF BOB ESPONJA 3 PZAS", 2, 42.83),
            row("070942125352", "CEPILLO GUM KIT DE ORTODONCIA 6 PZ", 1, 115.74),
            row("070942303194", "HILO DENTAL GUM 128 MTS", 1, 50.37),
            row("7501008491140", "TABCIN PODS ACTIVE CAPS C/12 2PACK", 2, 117.60),
            row("070942302357", "CAPUCHONES GUM P/CEPILLOS C/4", 1, 27.34),
            row("7501007533896", "COTONETES JOHNSON'S BOLSA C/150", 2, 28.03),
            row("7501033953361", "ENSURE PVO CHOCOLATE 400 GR", 1, 281.06),
            row("759684272103", "COTONETES KIUTS BOTE C/100", 5, 12.19),
            row("759684273094", "COTONETES KIUTS BOTE C/50", 2, 6.92),
            row("7501125174797", "ELECTROLIT MORA AZUL 625 ML", 2, 19.60),
            row("7501125187179", "ELECTROLIT GUAYABA 625 ML", 1, 19.60),
            row("7501125149221", "ELECTROLIT FRESA-KIWI 625 ML", 2, 19.60),
            row("714706918964", "PROPERLAS PROPOLEO Y EUCALIPTO 50 G", 1, 27.83),
            row("714706918940", "PROPERLAS BRONCOLIN PROP Y JENGIBRE 50GR", 1, 27.83),
        ],
    },
    {
        "key": "bodega_f42_28786",
        "tmp": "_fc_bf42_28786",
        "folio": "28786",
        "proveedor": "Bodega F-42",
        "proveedor_ilike": "bodega%f-42",
        "fecha": "2026-11-10",
        "total": 2319.12,
        "notas": (
            "Bodega F-42 Ejidos del Moral · Caja 4/28786 · 10-nov-2026 17:26 · "
            "Público en general · TC $2,319.12 · P.U. ya con IVA · cola Recibir"
        ),
        "header": "Bodega F-42 · folio 28786 · 2026-11-10 · total $2,319.12 · 43 renglones · P.U. con IVA",
        "rows": [
            row("7506306209862", "DEO AXE SPY 150ML 48H ANARCHY FRESH LOVE FOR HER", 1, 45.83),
            row("7506306213081", "DESOD AXE MUSIC FRES 48H SPY150ML", 2, 45.83),
            row("7506306209855", "DESOD AXE ANARC FLO 48H SPY 150ML", 1, 45.83),
            row("7506306245686", "DESOD AXE MEN EPIC-F 48H SPY 150ML", 2, 45.83),
            row("7506306251847", "DESOD AXE BLACK REMIX SPY 210 ML", 1, 68.73),
            row("7791293025810", "DESOD AXE MEN FUSION SPY 150ML", 1, 45.83),
            row("7509546073767", "DESOD STEFANO BLACK SPY 113G", 1, 61.18),
            row("7506306250604", "DESOD AXE MEN DARK TEM SPY 210ML", 1, 68.73),
            row("7506306244795", "DESOD AXE INTENSE 48H SPY 150ML", 1, 45.83),
            row("7791293025780", "DESOD AXE MEN APOLLO SPY 150ML", 1, 45.83),
            row("7509546694702", "DESOD STEFANO NEXT LEVEL SPY150MLN", 1, 61.18),
            row("7791293025803", "DESOD AXE MEN EXCITE SPY 150ML", 1, 45.83),
            row("8700216334655", "OLD SPICE 50GR STICK WOLFTHORN", 2, 56.20),
            row("7506309806068", "DESOD OLD SPICE FRESH-GEL80G", 2, 69.70),
            row("810120501628", "JBN GRISI CONTROL AZUFRE 100 G", 1, 40.40),
            row("7503014119032", "AZUFRE JABON C MIEL 80 GR", 1, 15.06),
            row("7505514121782", "JABON DE PROTEINA DE ARROZ Y CONCHA NACAR 80GR", 1, 17.78),
            row("850040940121", "GRISI 125GR JBN AGUA ROSAS SUAV", 1, 21.72),
            row("7501022150818", "JBN GRISI CONCHA NACAR 125G", 1, 21.72),
            row("7501027278487", "DESOD OBAO FRESC SVE R-ON 65G", 1, 30.71),
            row("7509552876284", "DEO OBAO ROLL 65GR DERMO NIACINAMID", 1, 27.63),
            row("75076221", "DESOD AXE MEN EPIC-F 48H STICK 45G", 1, 52.50),
            row("7509552909821", "DESOD OBAO RSA TEN 48H R-ON 65G", 1, 30.72),
            row("7509546073781", "DESOD STEFANO MID-N SPY 113G", 1, 61.18),
            row("75076238", "DESOD AXE MEN APOLLO 48H STICK 45G", 1, 52.50),
            row("7501035911208", "JBN LIQ PALMOL AQUARIUM 221ML", 2, 24.06),
            row("7509546059556", "JBN LIQ PALMOL N-BAL DERMOL 221MLN", 2, 37.43),
            row("7501022150092", "JBN GRISI LECHE DE BURRA 125G", 1, 21.88),
            row("7501019006623", "TAS SANIT SABA B-NOCHES ALAS C/8", 3, 27.50),
            row("7509552876352", "DESOD OBAO 65G DERMO EF MAGNE R ON", 1, 31.10),
            row("7509552876369", "DESOD OBAO 65G DERMO EF ZINC R ON", 1, 31.66),
            row("7501361156007", "AVANT CONCHA NACAR 90GR CREMA CORPORAL", 2, 21.76),
            row("7501022104217", "CRA GRISI SDA CONCHA NACAR 110G", 2, 55.93),
            row("7506267923654", "GEL HONEY KEEPER MZNILL MIE 200ML", 1, 41.76),
            row("3614225108914", "TIN KOLESTON CRA CAST BAMBI 77", 1, 54.07),
            row("850040940602", "GRISI 400ML SH ORGAN SILVER + 130ML CANAS F LATI", 1, 87.35),
            row("7509552901511", "CRA FRUCTIS RISOS ELAS48H300", 1, 46.08),
            row("7509552908749", "CRA FRUCTIS PEI B-DANO PERF 300ML", 1, 46.08),
            row("7501048351046", "PROTEC LIMA-LIMON 125 ML GEL ANTIBACTERIAL", 3, 19.40),
            row("7501199416168", "GEL X-TREME ATTRACTION 200G", 3, 22.61),
            row("7509546072272", "C D COLGATE KIDS FRESANTASTICO 50G", 2, 21.39),
            row("7509552914696", "CRA FRUCTIS PEI CONT-DEF RIZ 300ML", 1, 46.08),
            row("7501048351039", "PROTEC 50ML GEL ANTIBACTERIAL C24", 3, 13.85),
        ],
    },
    {
        "key": "fesa_15573418",
        "tmp": "_fc_fesa_15573418",
        "folio": "1-5573418",
        "proveedor": "Farmacias Especializadas",
        "proveedor_ilike": "especializada",
        "fecha": "2026-11-10",
        "total": 1084.46,
        "notas": (
            "FESA / Fármacos Especializados · folio contact center 1-5573418 · Id 6635450 · "
            "10-nov-2026 10:46 · Suc. Iztapalapa · ACTÚA 2+1 Vilzermet (3 pzas, pagó 2 @ $542.23) · "
            "costo unitario promedio $361.49 · cola Recibir"
        ),
        "header": (
            "Farmacias Especializadas · folio 1-5573418 · 2026-11-10 · total $1,084.46\n"
            "-- ACTÚA 2+1: qty=3, costo=361.49. EAN 7730766001067."
        ),
        "rows": [
            row("7730766001067", "VILZERMET 50 MG / 1000 MG COM CAJ C/30", 3, 361.49),
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
            "{receta}, {ya}, {img})".format(
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
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    ilike = sql_str("%" + t["proveedor_ilike"] + "%")
    return f"""
-- ========== {t['proveedor']} {folio} ==========
-- {t['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacía, no PVP.
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
  imagen text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
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
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
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
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

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
  public.fc_buscar_producto_escaneo(t.sku)
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
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
  t.nombre,
  t.qty,
  null,
  null,
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
    )
  ),
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
    public.fc_buscar_producto_escaneo(t.sku)
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
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""


def main() -> None:
    # sanity: every ticket row EAN in CAT; sums close to totals
    for t in TICKETS:
        s = round(sum(r["sub"] for r in t["rows"]), 2)
        diff = abs(s - t["total"])
        if diff > 0.05:
            raise SystemExit(f"{t['folio']}: sum {s} != total {t['total']} (diff {diff})")
        print(f"{t['folio']}: {len(t['rows'])} rows · sum {s} · total {t['total']} · Δ{diff:.2f}")

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Tickets 10-nov-2026 (+ Benavides 09-nov) → cola Recibir (borrador).",
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
        f"""# Tickets 10-nov-2026 → Recibir

Incluye Benavides del 09-nov (misma tanda de fotos). Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_1011_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
{table}

## Notas

1. **Benavides 7993605:** ecommerce PayPal · EAN Vedipal `7730766001562` (no venía en el ticket).
2. **Cityfarma S339687:** ALMACEN · EANs validados por dígito de control.
3. **Equilibrio 451326:** claves SON → EAN Sons. Lote/cad del papel **no** se guarda.
4. **Farmalive 16337:** costo = P.U. **neto** tras descuento de renglón. Tukol EAN canónico `6502400315021`.
5. **Bodega F-42 28786:** Caja 4 · P.U. ya con IVA · stick Axe usan SKU corto (EAN 8 dígitos del ticket).
6. **FESA 1-5573418:** ACTÚA 2+1 Vilzermet → **3** piezas, costo unitario $361.49.
7. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
8. **Fotos:** varias ya en `catalogo-propia/`; el resto queda pendiente (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **6 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.
""",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"→ {OUT_MD.relative_to(ROOT)}")
    if "$$" in OUT_SQL.read_text(encoding="utf-8"):
        raise SystemExit("ERROR: el SQL contiene $$ (dollar-quote)")


if __name__ == "__main__":
    main()
