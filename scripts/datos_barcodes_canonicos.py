"""
Fuente única de verdad: productos con EAN verificado (empaque / farmacias MX).

Usar en:
  - scripts/generar_patch_catalogo_canonico.py
  - scripts/generar_patch_corregir_barcodes_ocr.py (MANUAL)
  - scripts/auditar_lista_farmalive.py (lista usuario)

Cada entrada:
  - barcode: EAN-13 escaneable
  - sku: opcional; si falta → FC-{últimos 8 del barcode}
  - action: fix_barcode | insert | fix_and_stock
  - fix_sku: SKU existente a corregir (fix_barcode)
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class ProductoCanonico:
    barcode: str
    nombre: str
    marca: str = ""
    presentacion: str = ""
    principio_activo: str = ""
    forma_farmaceutica: str = ""
    categoria: str = "Otro"
    tipo: str = "marca"
    costo: float = 0.0
    precio: float = 0.0
    stock: int = 0
    stock_minimo: int = 3
    requiere_receta: bool = False
    subcategoria: str = ""
    descripcion: str = ""
    sku: str = ""
    action: str = "insert"  # insert | fix_barcode | fix_and_stock
    fix_sku: str = ""  # SKU a actualizar si ya existe con barcode malo
    notas: str = ""


def sku_from_bc(barcode: str) -> str:
    return f"FC-{barcode[-8:]}"


# ── Barcodes corregidos (existían en BD con OCR/ticket equivocado) ──
CORRECCIONES: list[ProductoCanonico] = [
    ProductoCanonico(
        barcode="650240007408",
        fix_sku="FC-00740024",
        action="fix_barcode",
        nombre="Silka Medic Gel",
        marca="Silka",
        presentacion="Tubo 15 g",
        principio_activo="Terbinafina",
        forma_farmaceutica="GEL",
        categoria="Medicamentos",
        tipo="MEDICAMENTO",
        notas="OCR ticket: 65024000740024 → patch erróneo 6502400074024",
    ),
    ProductoCanonico(
        barcode="7501095409004",
        fix_sku="FC-58715517",
        action="fix_and_stock",
        stock=2,
        nombre="Graneodin B Frambuesa",
        marca="Graneodin",
        presentacion="C/24 pastillas",
        principio_activo="Benzocaina",
        forma_farmaceutica="PASTILLAS",
        costo=42.64,
        precio=57.57,
        notas="Ticket tenía 7501058715517 (otro sabor); físico frambuesa",
    ),
    ProductoCanonico(
        barcode="7501008485316",
        fix_sku="FC-08485316",
        action="fix_barcode",
        nombre="Tabcin efervescente C/12",
        marca="Tabcin",
        presentacion="C/12 tabletas efervescentes",
        principio_activo="Acido acetilsalicilico + Fenilefrina + Clorfenamina",
        forma_farmaceutica="Tabletas efervescentes",
        categoria="Medicamentos",
        tipo="marca",
        costo=37.73,
        precio=49.05,
        subcategoria="Antigripal",
        notas="EAN caja azul; distinto de Noche/500/Active",
    ),
    ProductoCanonico(
        barcode="7501088509773",
        fix_sku="FC-01508201",
        action="fix_barcode",
        nombre="Antiflu-Des C/24",
        marca="Antiflu-Des",
        presentacion="C/24 capsulas",
        principio_activo="Amantadina + Clorfenamina + Paracetamol",
        forma_farmaceutica="Capsulas",
        categoria="Medicamentos",
        tipo="marca",
        costo=149.35,
        precio=201.63,
        subcategoria="Antigripal",
        notas="OCR ticket 525301508201 / 7505253015021; EAN Chinoin 7501088509773",
    ),
]

# ── Altas manuales (lista Farmalive / anaquel, no en ticket OCR) ──
ALTAS_MANUALES: list[ProductoCanonico] = [
    ProductoCanonico(
        barcode="7501369200016",
        nombre="Estomaquil Polvo C/20",
        marca="Higia",
        presentacion="C/20 sobres 3 g",
        principio_activo="Bismuto subsalicilato; Hidróxido de magnesio; Carbonato de calcio",
        forma_farmaceutica="Polvo",
        categoria="Producto",
        costo=98.79,
        precio=133.37,
        stock=0,
    ),
    ProductoCanonico(
        barcode="3664798062229",
        sku="FC-98062229",
        nombre="Pharmaton Complete",
        marca="Pharmaton",
        presentacion="C/30 tabletas",
        principio_activo="Multivitaminas + Ginseng G115",
        forma_farmaceutica="Tabletas",
        categoria="Producto",
        costo=118.0,
        precio=159.30,
    ),
    ProductoCanonico(
        barcode="7501159525015",
        nombre="Eucaliptine Jarabe 140 ml",
        marca="Eucaliptine",
        presentacion="Frasco 140 ml",
        principio_activo="Dextrometorfano + Sulfoguayacol",
        forma_farmaceutica="Jarabe",
        categoria="Medicamentos",
        tipo="marca",
        costo=107.0,
        precio=144.45,
    ),
    ProductoCanonico(
        barcode="7501125112881",
        nombre="Pisacaina 2% 20 mg/ml Sol 50 ml",
        marca="Pisacaina",
        presentacion="Frasco ampula 50 ml",
        principio_activo="Lidocaina",
        forma_farmaceutica="Solucion inyectable",
        categoria="Medicamentos",
        tipo="MEDICAMENTO",
        requiere_receta=True,
        costo=85.0,
        precio=114.75,
        subcategoria="Anestesico local",
    ),
    ProductoCanonico(
        barcode="7501008421321",
        nombre="Redoxon 1g 2-pack Naranja",
        marca="Redoxon",
        presentacion="Caja 2 tubos x 10 tab",
        principio_activo="Acido ascorbico (Vitamina C)",
        forma_farmaceutica="Tabletas efervescentes",
        costo=130.0,
        precio=175.50,
        subcategoria="Vitamina C / inmunidad",
    ),
    ProductoCanonico(
        barcode="7501008497593",
        nombre="Alka-Seltzer Boost C/10",
        marca="Alka-Seltzer",
        presentacion="C/10 tabletas efervescentes",
        principio_activo="Acido acetilsalicilico + Cafeina",
        forma_farmaceutica="Tabletas",
        stock=2,
        costo=42.0,
        precio=56.70,
        subcategoria="Antiacido / analgesico",
        notas="Distinto de FC-84999001 (Boost C/50)",
    ),
    ProductoCanonico(
        barcode="7501008499702",
        nombre="Tabcin Noche C/12",
        marca="Tabcin",
        presentacion="C/12 capsulas",
        principio_activo="Paracetamol + Fenilefrina + Dextrometorfano + Doxilamina",
        forma_farmaceutica="Capsulas",
        categoria="Medicamentos",
        tipo="marca",
        costo=71.21,
        precio=96.14,
        subcategoria="Antigripal / noche",
        notas="Distinto de FC-08485316 (Tabcin efervescente 7501008485316)",
    ),
    ProductoCanonico(
        barcode="7501008485408",
        nombre="Tabcin 500 C/12",
        marca="Tabcin",
        presentacion="C/12 capsulas",
        principio_activo="Paracetamol + Amantadina + Clorfenamina + Fenilefrina",
        forma_farmaceutica="Capsulas",
        categoria="Medicamentos",
        tipo="marca",
        costo=46.06,
        precio=62.19,
        subcategoria="Antigripal",
        notas="EAN caja roja; ticket Farmalive $46.06/caja",
    ),
    ProductoCanonico(
        barcode="7501008499689",
        nombre="Tabcin Active C/12",
        marca="Tabcin",
        presentacion="C/12 capsulas",
        principio_activo="Paracetamol + Fenilefrina + Dextrometorfano + Guaifenesina",
        forma_farmaceutica="Capsulas",
        categoria="Medicamentos",
        tipo="marca",
        costo=70.60,
        precio=95.31,
        subcategoria="Antigripal / tos",
        notas="Nueva formula; Exprezo $70.60; EAN caja morada/amarilla",
    ),
    ProductoCanonico(
        barcode="7501007535494",
        nombre="Motrin Infantil Suspension 120 ml",
        marca="Motrin",
        presentacion="Frasco 120 ml sabor frutas",
        principio_activo="Ibuprofeno 2 g/100 ml",
        forma_farmaceutica="Suspension oral",
        categoria="Medicamentos",
        tipo="marca",
        costo=186.40,
        precio=251.64,
        subcategoria="Analgesico / antipiretico infantil",
        notas="Ticket FL-080826 tenia MOTRIN SUSP sin barcode OCR; EAN del empaque",
    ),
    ProductoCanonico(
        barcode="7501298215099",
        nombre="Sedalmerck Max C/24",
        marca="Sedalmerck",
        presentacion="C/24 tabletas",
        principio_activo="Paracetamol + Clorfenamina + Fenilefrina",
        forma_farmaceutica="Tabletas",
        categoria="Medicamentos",
        tipo="marca",
        stock=2,
        costo=122.06,
        precio=164.78,
        subcategoria="Antigripal",
        notas="Ticket OCR #7B 222821509 (barcode truncado); 2 cajas a $122.06 c/u",
    ),
    ProductoCanonico(
        barcode="0736085278507",
        sku="FC-85278507",
        nombre="Manzanilla Sophia Solucion 15 ml",
        marca="Sophia",
        presentacion="Frasco 15 ml",
        principio_activo="Manzanilla (Matricaria chamomilla)",
        forma_farmaceutica="Solucion oral",
        categoria="Medicamentos",
        tipo="marca",
        stock=1,
        costo=63.41,
        precio=85.61,
        subcategoria="Digestivo / calmante",
        notas="OCR ticket: 7360852785071 mezclado con Aspirina; cad 03/2028",
    ),
    ProductoCanonico(
        barcode="7501008499818",
        nombre="Aspirina 500 mg C/80",
        marca="Aspirina",
        presentacion="C/80 tabletas 500 mg",
        principio_activo="Acido acetilsalicilico 500 mg",
        forma_farmaceutica="Tabletas",
        categoria="Medicamentos",
        tipo="marca",
        stock=2,
        costo=61.15,
        precio=82.56,
        subcategoria="Analgesico / antipiretico",
        notas="Distinto de FC-08491074 (doble pack 7501008491074); cad ene 2029",
    ),
    ProductoCanonico(
        barcode="7501008443033",
        nombre="Alka-Seltzer C/12 alivio rapido",
        marca="Alka-Seltzer",
        presentacion="C/12 tabletas efervescentes",
        principio_activo="Acido acetilsalicilico + Bicarbonato + Citrico",
        forma_farmaceutica="Tabletas efervescentes",
        stock=2,
        costo=39.00,
        precio=52.65,
        subcategoria="Antiacido / analgesico",
        notas="Ticket OCR 73010084430331; 2 cajas $39 c/u; cad 01-ene-2029",
    ),
    ProductoCanonico(
        barcode="7502246642073",
        nombre="Microdacyn Solucion 60 ml",
        marca="Microdacyn",
        presentacion="Frasco 60 ml",
        principio_activo="Acido hipocloroso / solucion antiseptica",
        forma_farmaceutica="Solucion topica",
        categoria="Botiquín",
        tipo="marca",
        stock=1,
        costo=114.66,
        precio=154.80,
        subcategoria="Antiseptico / curacion de heridas",
        notas="Ticket FL-080826 MICRODACYN 60 sin barcode OCR; distinto lubricante Sico FC-87932321",
    ),
    ProductoCanonico(
        barcode="7501088579615",
        nombre="Topron C/16 400 mg",
        marca="Topron",
        presentacion="C/16 capsulas 400 mg",
        principio_activo="Nifuroxazida 400 mg",
        forma_farmaceutica="Capsulas",
        categoria="Medicamentos",
        tipo="marca",
        stock=1,
        costo=153.47,
        precio=251.40,
        subcategoria="Antidiarreico",
        notas="Chinoin; ticket OCR c71010885796151; lote 8FB077 cad feb 2028; PMP $251.40",
    ),
    ProductoCanonico(
        barcode="7501537103521",
        nombre="Brunadol C/10",
        marca="Brunadol",
        presentacion="C/10 tabletas",
        principio_activo="Paracetamol 300 mg + Naproxeno 275 mg",
        forma_farmaceutica="Tabletas",
        categoria="Medicamentos",
        tipo="generico",
        stock=4,
        costo=19.31,
        precio=72.00,
        subcategoria="Analgesico / antipiretico / antinflamatorio",
        notas="Bruluart; ticket $19.31/caja x4; lote 604188 cad abr 2028; PMP $72",
    ),
    ProductoCanonico(
        barcode="7502209747366",
        nombre="Veridex C/4 6 mg",
        marca="Veridex",
        presentacion="C/4 tabletas 6 mg",
        principio_activo="Ivermectina 6 mg",
        forma_farmaceutica="Tabletas",
        categoria="Medicamentos",
        tipo="marca",
        stock=1,
        costo=75.46,
        precio=360.00,
        requiere_receta=True,
        subcategoria="Antiparasitario",
        notas="Maver; ticket OCR 75020027471 truncado; lote 261181 cad feb 2028; PMP $360",
    ),
    ProductoCanonico(
        barcode="7501037907117",
        nombre="Bisolvon Solucion Adulto 120 ml",
        marca="Bisolvon",
        presentacion="Frasco 120 ml",
        principio_activo="Bromhexina",
        forma_farmaceutica="Solucion oral",
        categoria="Respiratorio",
        tipo="marca",
        stock=1,
        costo=141.94,
        precio=191.62,
        subcategoria="Expectorante / antitusivo",
        notas="Sanfer; distinto de FC-79071241 infantil 7501037907124; cad feb 2028",
    ),
    ProductoCanonico(
        barcode="020800753067",
        nombre="Pepto-Bismol Suspension 118 ml",
        marca="Pepto-Bismol",
        presentacion="Frasco 118 ml",
        principio_activo="Subsalicilato de bismuto 1.75 g/100 ml",
        forma_farmaceutica="Suspension oral",
        categoria="Digestivo",
        tipo="marca",
        stock=1,
        costo=96.73,
        precio=150.00,
        subcategoria="Antiácido / antidiarreico",
        notas="P&G; ticket OCR 0208007530671; UPC 020800753067; cad jun 2027; PMP $150",
    ),
]

# Mapa OCR/ticket erróneo → EAN canónico (para patch masivo OCR)
MAPA_OCR_A_CANONICO: dict[str, str] = {
    "65024000740024": "650240007408",
    "6502400074024": "650240007408",
    "7501058715517": "7501095409004",  # solo si FC-58715517 es frambuesa en tu anaquel
    "7501354312225027": "3543122250276",
    "7501354312250": "3543122250276",
    "75015015371829601": "7501537182960",
    "7501501537161": "7501537182960",
    "750222503430721": "7502250343072",
    "222821509": "7501298215099",
    "750129821509": "7501298215099",
    "736085278507": "0736085278507",
    "7360852785071": "0736085278507",
    "73010084430331": "7501008443033",
    "75010084430331": "7501008443033",
    "75010885796151": "7501088579615",
    "71010885796151": "7501088579615",
    "c71010885796151": "7501088579615",
    "75020027471": "7502209747366",
    "750220974736": "7502209747366",
    "750525301508201": "7501088509773",
    "7505253015021": "7501088509773",
    "525301508201": "7501088509773",
    "0208007530671": "020800753067",
    "208007530671": "020800753067",
    "20800753067": "020800753067",
}


def all_canonicos() -> list[ProductoCanonico]:
    out = list(CORRECCIONES) + list(ALTAS_MANUALES)
    for p in out:
        if not p.sku:
            p.sku = sku_from_bc(p.barcode)
    return out
