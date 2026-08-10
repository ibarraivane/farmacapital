#!/usr/bin/env python3
"""Parsea nombres de ticket en categoría, marca, presentación, PA y nombre limpio."""

from __future__ import annotations

import re
from dataclasses import dataclass

# ── Categorías por prefijo de ticket (más específico primero) ───────
CATEGORY_PREFIXES: list[tuple[str, str, str]] = [
    (r"^Enj\s+Buc\b", "Enjuague bucal", "Higiene bucal"),
    (r"^Cep\s+Dent\b", "Cepillo dental", "Higiene bucal"),
    (r"^Crema\s+Dent\b", "Crema dental", "Higiene bucal"),
    (r"^Pasta\s+Dent\b", "Pasta dental", "Higiene bucal"),
    (r"^Tas\s+Hum\b", "Toallas húmedas", "Higiene personal"),
    (r"^Tas\s+Sanit\b", "Toallas sanitarias", "Higiene personal"),
    (r"^Toa\s*[- ]?\s*Hum\b", "Toallas húmedas", "Higiene personal"),
    (r"^Jbn\s+Liq\b", "Jabón líquido", "Higiene personal"),
    (r"^Agua\s+Mic\b", "Agua micelar", "Cuidado personal"),
    (r"^Agua\s+Dest\b", "Agua destilada", "Botiquín"),
    (r"^Agua\s+Oxigenada\b", "Agua oxigenada", "Botiquín"),
    (r"^Sh\s+Int\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Caprice\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Hash\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Hbs\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Pant\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Mennen\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Grisi\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Savile\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Sedal\b", "Shampoo", "Higiene capilar"),
    (r"^Sh\s+Pert\b", "Shampoo", "Higiene capilar"),
    (r"^Silica\s+Shine\b", "Tratamiento capilar", "Higiene capilar"),
    (r"^Cra\s+P/", "Crema", "Cuidado personal"),
    (r"^Cra\b", "Crema", "Cuidado personal"),
    (r"^Crema\b", "Crema", "Cuidado personal"),
    (r"^Jbn\b", "Jabón", "Higiene personal"),
    (r"^Jabon\b", "Jabón", "Higiene personal"),
    (r"^Desod\b", "Desodorante", "Higiene personal"),
    (r"^DEO\b", "Desodorante", "Higiene personal"),
    (r"^Tco\b", "Talco", "Higiene personal"),
    (r"^Sh\b", "Shampoo", "Higiene capilar"),
    (r"^Ac\b", "Acondicionador", "Higiene capilar"),
    (r"^Acono\b", "Acondicionador", "Higiene capilar"),
    (r"^Gel\b", "Gel", "Cuidado personal"),
    (r"^Pomada\b", "Pomada", "Cuidado personal"),
    (r"^Alcohol\b", "Alcohol", "Botiquín"),
    (r"^Algod", "Algodón", "Botiquín"),
    (r"^Venda\b", "Venda", "Botiquín"),
    (r"^Gasa\b", "Gasa", "Botiquín"),
    (r"^Tela\s+Adhesiva\b", "Tela adhesiva", "Botiquín"),
    (r"^Tela\b", "Tela adhesiva", "Botiquín"),
    (r"^Protec\b", "Material de curación", "Botiquín"),
    (r"^Jeringa\b", "Jeringa", "Botiquín"),
    (r"^Cateter\b", "Catéter", "Botiquín"),
    (r"^Gotero\b", "Gotero", "Botiquín"),
    (r"^Cond\b", "Condón", "Higiene personal"),
    (r"^Lubricante\b", "Lubricante", "Higiene personal"),
    (r"^Panuelos\b", "Pañuelos desechables", "Higiene personal"),
    (r"^Toa\b", "Toallas", "Higiene personal"),
    (r"^Hilo\b", "Hilo dental", "Higiene bucal"),
    (r"^Pads\b", "Pads", "Cuidado personal"),
    (r"^Cotonetes\b", "Cotonetes", "Higiene personal"),
    (r"^Leche\b", "Leche", "Abarrotes"),
    (r"^Electrolit\b", "Suero oral", "Higiene personal"),
    (r"^Pedialyte\b", "Suero oral", "Higiene personal"),
    (r"^Ensure\b", "Suplemento", "Abarrotes"),
    (r"^Pediasure\b", "Suplemento", "Abarrotes"),
    (r"^Glucerna\b", "Suplemento", "Abarrotes"),
    (r"^Vick\b", "Balsamo", "Botiquín"),
    (r"^Vaporub\b", "Balsamo", "Botiquín"),
    (r"^Vaseline\b", "Vaselina", "Cuidado personal"),
    (r"^FaseLine\b", "Vaselina", "Cuidado personal"),
    (r"^Naturella\b", "Toallas sanitarias", "Higiene personal"),
    (r"^Saba\b", "Toallas sanitarias", "Higiene personal"),
    (r"^Diapro\b", "Pañales", "Higiene personal"),
    (r"^Silica\b", "Silica gel", "Cuidado personal"),
    (r"^SilkHair\b", "Tratamiento capilar", "Higiene capilar"),
    (r"^Acetona\b", "Acetona", "Cuidado personal"),
    (r"^Mousse\b", "Mousse capilar", "Higiene capilar"),
    (r"^Iv\b", "Inyectable", "Medicamento"),
    (r"^MERCURIO\b", "Producto natural", "Botiquín"),
    (r"^Desmaq\b", "Desmaquillante", "Cuidado personal"),
    (r"^Loc\s+Limp\b", "Loción limpiadora", "Cuidado personal"),
    (r"^Quita\s+Esm\b", "Quita esmalte", "Cuidado personal"),
    (r"^Quita\s+Esmalte\b", "Quita esmalte", "Cuidado personal"),
    (r"^Ting\b", "Polvo", "Cuidado personal"),
    (r"^Ico\s+Desod\b", "Desodorante", "Higiene personal"),
    (r"^C\s+D\b", "Crema dental", "Higiene bucal"),
    (r"^Cd\b", "Crema dental", "Higiene bucal"),
    (r"^Cera\b", "Cera capilar", "Higiene capilar"),
    (r"^Brill\b", "Brillantine", "Higiene capilar"),
    (r"^Tiraleche\b", "Tiraleche", "Botiquín"),
    (r"^Sh\s+Pert\b", "Shampoo", "Higiene capilar"),
    (r"^Deo\b", "Desodorante", "Higiene personal"),
    (r"^Chupon\b", "Chupón", "Bebés"),
    (r"^Cra\s+Corp\b", "Crema corporal", "Cuidado personal"),
    (r"^Tas\s+San\b", "Toallas sanitarias", "Higiene personal"),
    (r"^Azufre\b", "Jabón", "Higiene personal"),
    (r"^Agua\s+De\s+Rosas\b", "Agua de rosas", "Cuidado personal"),
    (r"^Agua\s+Mice\b", "Agua micelar", "Cuidado personal"),
    (r"^Pomada\b", "Pomada", "Botiquín"),
    (r"^Alcohol\b", "Alcohol", "Botiquín"),
    (r"^Agua\s+Dest\b", "Agua destilada", "Botiquín"),
    (r"^Gotero\b", "Gotero", "Botiquín"),
    (r"^Crema\s+Dent\b", "Crema dental", "Higiene bucal"),
    (r"^Cremi\s+Dent\b", "Crema dental", "Higiene bucal"),
    (r"^Cond\b", "Condón", "Higiene personal"),
    (r"^Hilo\b", "Hilo dental", "Higiene bucal"),
    (r"^Bib\b", "Biberón", "Bebés"),
    (r"^Leche\b", "Leche", "Abarrotes"),
    (r"^Nestum\b", "Suplemento", "Abarrotes"),
    (r"^Electrolit\b", "Suero oral", "Higiene personal"),
    (r"^Electrolid\b", "Suero oral", "Higiene personal"),
    (r"^Pedialyte\b", "Suero oral", "Higiene personal"),
    (r"^Toa\s+Hum\b", "Toallas húmedas", "Higiene personal"),
    (r"^Absorsec\b", "Toallas húmedas", "Higiene personal"),
    (r"^Termometro\b", "Termómetro", "Botiquín"),
    (r"^Vaso\s+Recolector\b", "Vaso recolector", "Botiquín"),
    (r"^Espuma\b", "Espuma", "Botiquín"),
    (r"^Stick\b", "Desodorante", "Higiene personal"),
    (r"^Lubricante\b", "Lubricante", "Higiene personal"),
    (r"^Soft\s+Lub\b", "Lubricante", "Higiene personal"),
    (r"^Pomada\s+Labello\b", "Balsamo labial", "Cuidado personal"),
    (r"^Pomada\s+I\.Abeili\b", "Balsamo labial", "Cuidado personal"),
]

BRAND_ALIASES: dict[str, str] = {
    "LIST": "Listerine", "PANT": "Pantene", "PANTENE": "Pantene", "PALMOL": "Palmolive",
    "PALMOLIVE": "Palmolive", "MENNEN": "Mennen", "NIVEA": "Nivea", "OBAO": "Obao", "OBAD": "Obao",
    "AXE": "Axe", "REXONA": "Rexona", "DOVE": "Dove", "SEDAL": "Sedal", "CAPRICE": "Caprice",
    "FRUCTIS": "Fructis", "LUBRIDERM": "Lubriderm", "GRISI": "Grisi", "ESCUDO": "Escudo",
    "HINDS": "Hinds", "TEATRICAL": "Teatrical", "SAVILE": "Savile", "HASH": "Hask", "HBS": "Herbal Essences",
    "H&S": "Head & Shoulders", "REX": "Rexona",
    "CLINIC": "Colgate", "COLGATE": "Colgate", "ORAL B": "Oral-B", "ORAL-B": "Oral-B",
    "KLEENEX": "Kleenex", "LEENEX": "Kleenex", "KIMBERLY": "Kimberly-Clark", "NESTLE": "Nestlé",
    "NESTUM": "Nestum", "NIDO": "Nido", "NAN": "Nan", "BAYER": "Bayer", "TEMPRA": "Tempra",
    "AFRIN": "Afrin", "BEPANTHEN": "Bepanthen", "ELECTROLIT": "Electrolit", "PISA": "Pisa",
    "DIBAR": "Dibar", "DABAN": "Dibar", "ADIBAR": "Dibar", "DEGASA": "Degasa", "SUNSTAR": "Sunstar",
    "GUM": "GUM", "OLD SPICE": "Old Spice", "BIOALIMENTOS": "Bioalimentos", "AJOLOTIUS": "Ajolotius",
    "PROTEC": "Protec", "QUIRMEX": "Quirmex", "VITACILINA": "Vitacilina", "MERCURIO": "Mercurio",
    "VICK": "Vick", "VAPORUB": "Vaporub", "NATURELLA": "Naturella", "SABA": "Saba", "PEDIASURE": "Pediasure",
    "ENSURE": "Ensure", "GLUCERNA": "Glucerna", "PEDIALYTE": "Pedialyte", "ABBOTT": "Abbott",
    "PRUDENCE": "Prudence", "TROJAN": "Trojan", "HUGGIES": "Huggies", "BEBIN": "Huggies", "TH BEBIN": "Huggies",
    "KENVUE": "Kenvue", "CHINOIN": "Chinoin", "SANFER": "Sanfer", "CENTRUM": "Centrum", "ASPIRINA": "Aspirina",
    "TYLENOL": "Tylenol", "ADVIL": "Advil", "DESENFRIOL": "Desenfriol", "GRANEODIN": "Graneodin",
    "HIPOGLOS": "Hipoglos", "ALKA-SELTZER": "Alka-Seltzer", "ALKASELTZER": "Alka-Seltzer",
    "BISOLVON": "Bisolvon", "EOMELUBRINA": "Eomelubrina", "SENSODYNE": "Sensodyne", "LABELLO": "Labello",
    "ARMSTRONG": "Armstrong", "RB HEALTH": "RB", "RB": "RB", "OPELLA": "Opella", "OPella": "Opella",
    "ANDROMACO": "Andromaco", "BRULUART": "Bruluart", "BRULUART": "Bruluart", "BRULUAGSA": "Bruluart",
    "PROGELA": "Progela", "JAYOR": "Jayor", "EVENELO": "Evenflo", "EVENFlo": "Evenflo", "JALOMA": "Jaloma",
    "EGO": "Ego", "NUTRIBELA": "Nutribela", "NUTRIBELA1O": "Nutribela", "ODOLEX": "Odolex",
    "EUROBION": "Eurobion", "BOLO": "Eurobion", "LUCERNA": "Lucerna", "LIO": "Lio", "BASUYE": "Basuye",
    "EDIGAR": "Edigar", "EDGAR": "Edigar", "VELAZQUEZ": "Velázquez", "KOHN": "Kohn", "MADRID": "Madrid",
    "SUMITEX": "Sumitex", "DABUR": "Dabur", "DABAN": "Dibar",
    "ASEPXIA": "Asepxia", "ASEXIA": "Asepxia", "BLUMEN": "Blumen", "NUVEL": "Nuvel",
    "PERT": "Pert", "LOMECAN": "Lomecan", "SILKHAIR": "SilkHair", "SILICA": "Silica Shine",
    "SILICA SHINE": "Silica Shine", "MEXSANA": "Mexsana", "PONDS": "Ponds", "CLARIS": "Claris",
    "CLARANT": "Clariant", "TERNUURA": "Ternura", "KOTEX": "Kotex", "ACCION": "Acción",
    "ALCAN": "Alcanforada", "RICITOS": "Ricitos de Oro", "RICITOS D ORO": "Ricitos de Oro",
    "RICITOS DE ORO": "Ricitos de Oro", "MOCO DE GORILA": "Moco de Gorila", "X-EXTREME": "X-Treme",
    "X-TREME": "X-Treme", "HERBAL ESS": "Herbal Essences", "LA FLOR": "La Flor",
    "DIAPRO": "Diapro", "FASELINE": "FaseLine", "VASELINE": "Vaseline", "VAPORUB": "Vaporub",
    "VICK NAPORUB": "Vick", "EDIASURE": "Pediasure", "REOMATOLUM": "Reomatolum",
    "DEL VIEJITO": "Del Viejito", "MERTIOLATE": "Mertiolate", "PERILLA": "Perilla",
    "BICARBONATO": "Bicarbonato", "DESENFRIOLITO": "Desenfriolito", "DESENFRIOL": "Desenfriol",
    "GRANEODIN": "Graneodin", "FLANAX": "Flanax", "CAFIASPIRINA": "Cafiaspirina",
    "SARIDON": "Saridon", "TABCIN": "Tabcin", "SYNCOL": "Syncol", "BRUNADOL": "Brunadol",
    "TREDA": "Treda", "ANARA": "Anara", "SCABISAN": "Scabisan", "LOXCEL": "Loxcel",
    "HERKLIN": "Herklin", "SENOSIAIN": "Senosiain", "LACTOPRAM": "Lactopram",
    "TARMIN": "Tarmin", "AGRIFFEN": "Agrifen", "AGRIFEN": "Agrifen", "AFRODIT": "Afrodit",
    "CILOCID": "Cilocid", "NEUROBION": "Neurobion", "BEDOYECTA": "Bedoyecta",
    "DERMODINE": "Dermodine", "DERMOCLEEN": "Dermocleen", "JERMOCLEEN": "Jermocleen",
    "DERMOD": "Dermodine", "TRIBEDOCE": "Tribedoce", "KY6": "Ky6", "NAILEX": "Nailex",
    "LASICO": "Lásico", "PRUDENCE": "Prudence", "MANZANILLA": "Manzanilla", "AJOLOTIUS": "Ajolotius",
    "DIBAR": "Dibar", "QUIRMEX": "Quirmex", "DEGASA": "Degasa", "PISA": "Pisa",
    "OLD SPICE": "Old Spice", "EVENFLO": "Evenflo", "EVENELO": "Evenflo", "KIMBERLY CLARK": "Kimberly-Clark",
    "OPTIMA": "Nan", "OPT IMAL": "Nan", "ÖPT IMAL": "Nan", "ÖPTIMAL": "Nan",
    "NUTRI RINDES": "Nido", "LECHE NIDO": "Nido", "LECHE NIDAL": "Nido", "LECHE NAN": "Nan",
    "SOFT LUB": "Softlub", "PLEASURE": "Softlub", "PLEASÜRE": "Softlub",
    "AFRIN": "Afrin", "BOOST": "Alka-Seltzer", "CAF IASPIRINA": "Cafiaspirina",
    "IASPIRINA": "Aspirina", "SAL DE UVAS": "Sal de Uvas", "SAL DE UVA": "Sal de Uvas",
    "PERFORMANCE": "Centrum", "SILVER": "Centrum", "CENTRUM SILVER": "Centrum",
    "MICRODACYN": "Microdacyn", "LOTRIMIN": "Lotrimin", "PROGELA": "Progela",
    "BRULUAGSA": "Bruluart", "BRULUART": "Bruluart", "HORMONA": "Sanfer",
    "DWIGHTND": "Trojan", "TROJAN": "Trojan", "CHINOTES": "Chinoin", "CHINOIN": "Chinoin",
    "ARMSTRONI": "Armstrong", "ARMSTRONG": "Armstrong", "PG HEALTH": "Kenvue", "PG PERE": "Kenvue",
    "RB HEALTI": "RB", "RB HEALT": "RB", "BAYÉR": "Bayer", "BAYER": "Bayer",
    "KENVUE": "Kenvue", "ABBOTT": "Abbott", "NESTLE": "Nestlé", "MARCAS NESTLE": "Nestlé",
    "BDE MEXICO": "Labello", "BDE MERICO": "Labello", "RDE MEXIC": "Lásico",
    "DKT MEXICO": "Prudence", "DKT": "Prudence", "SUNSTAR AMERICASI": "Sunstar",
    "HNOS": "Manzanilla", "ORO MANZANILLA": "Manzanilla", "PARCHE LEON": "Arnica",
    "POROSO ARNICA": "Arnica", "EDIGAR": "Edigar", "EDGAR": "Edigar", "VELAZQUEZ": "Velázquez",
    "KOHN": "Kohn", "MADRID": "Madrid", "EUROBION": "Eurobion", "BOLO": "Eurobion",
    "LIO": "Lio", "BASUYE": "Basuye", "LUCERNA": "Lucerna", "ENSURE": "Ensure",
    "GLUCERNA": "Glucerna", "PEDIASURE": "Pediasure", "NATURELLA": "Naturella", "SABA": "Saba",
    "VITACILINA": "Vitacilina", "MERCURIO": "Mercurio", "ARNICA": "Mercurio",
}

KNOWN_BRANDS = set(BRAND_ALIASES.values()) | {
    "PANTENE", "OBAO", "AXE", "REXONA", "NESTLE", "BAYER", "GARNIER", "LOREAL", "JOHNSON",
    "NEUTROGENA", "GILLETTE", "LOTRIMIN", "MICRODACYN", "MANZANILLA", "DABUR", "ARNICA",
    "BLUMEN", "NUVEL", "PERT", "LOMECAN", "PONDS", "MEXSANA", "ASEPXIA", "CLARIS",
    "KOTEX", "RICITOS DE ORO", "MOCO DE GORILA", "DIAPRO", "ENSURE", "GLUCERNA",
    "DESENFRIOLITO", "TEMPRA", "GRANEODIN", "FLANAX", "ELECTROLIT", "PRUDENCE",
    "QUIRMEX", "DIBAR", "DEGASA", "PEDIALYTE", "NIDO", "NAN", "CENTRUM", "HIPOGLOS",
    "BEPANTHEN", "AJOLOTIUS", "LABELLO", "OLD SPICE", "EVENFLO", "COLGATE", "ORAL-B",
}

# Laboratorios/distribuidores al final de ticket FarmaLive (no son marca del producto)
DISTRIBUIDOR_TOKENS = {
    "BAYER", "OTC", "RB", "HEALTH", "HEALTI", "HEALT", "CHINOIN", "SANFER", "BRULUART",
    "BRULUAGSA", "BRULUART", "PROGELA", "HORMONA", "LAB", "PG", "PERE", "PEREG", "KENVUE",
    "ANDROMACO", "OPella", "OPELLA", "MARCAS", "NESTLE", "ABBOTT", "PISA", "DEGASA",
    "QUIRMEX", "DIBAR", "DIBAR", "KIMBERLY", "CLARK", "BDEMEXICO", "BDEMERICO", "RDE",
    "MEXIC", "MEXICO", "DKT", "SUNSTAR", "AMERICASI", "AMERICAS", "BIOALIMENTOS", "NATI",
    "NAT", "BDE", "MERICO", "MEXIC(", "HEALTH9", "HEALTH1", "CLARK", "OT", "OTO", "ONC",
    "PACI", "PACE", "PACS", "DWIGHTND", "DESCTO", "DESATO", "MANT", "MEXICO", "GR", "GF",
    "PISA", "HORMONA", "MARCAS", "BRULUART", "BRULUAGSA", "CHINOIN", "SANFER", "KSK",
    "NVO", "NARANJ",
}

# Líneas de producto FarmaLive (OCR) → marca canónica
FARMALIVE_PRODUCT_LINES: list[tuple[str, str]] = [
    (r"ELECTROLIT?", "Electrolit"),
    (r"ELECTROLID", "Electrolit"),
    (r"PEDIALYTE", "Pedialyte"),
    (r"NESTUM", "Nestum"),
    (r"LECHE\s+NAN", "Nan"),
    (r"LECHE\s+NIDO", "Nido"),
    (r"LECHE\s+NIDAL", "Nido"),
    (r"NUTRI\s+RINDES", "Nido"),
    (r"ENSURE", "Ensure"),
    (r"GLUCERNA", "Glucerna"),
    (r"PEDIASURE", "Pediasure"),
    (r"TEMPRA", "Tempra"),
    (r"DESENFRIOL", "Desenfriol"),
    (r"GRANEODIN", "Graneodin"),
    (r"EOMELUBRINA", "Eomelubrina"),
    (r"HISTIACIL", "Histiacil"),
    (r"BISOLVON", "Bisolvon"),
    (r"HIPOGLOS", "Hipoglos"),
    (r"TABCIN", "Tabcin"),
    (r"ALKASELTZER|ALKA-SELTZER", "Alka-Seltzer"),
    (r"CAFIASPIRINA", "Cafiaspirina"),
    (r"ASPIRINA", "Aspirina"),
    (r"TYLENOL", "Tylenol"),
    (r"FLANAX", "Flanax"),
    (r"BEPANTHEN", "Bepanthen"),
    (r"PRUDENCE", "Prudence"),
    (r"LABELLO", "Labello"),
    (r"QUIRMEX", "Quirmex"),
    (r"VITACILINA", "Vitacilina"),
    (r"AJOLOTIUS", "Ajolotius"),
    (r"CENTRUM", "Centrum"),
    (r"COLGATE", "Colgate"),
    (r"OLD\s+SPICE", "Old Spice"),
    (r"EVENFLO|EVENELO", "Evenflo"),
    (r"COND\s+TROJAN|TROJAN", "Trojan"),
]

FLAVOR_STOP = {
    "ML", "MI", "GR", "G", "LT", "L", "MG", "UI", "TAB", "TABS", "CAP", "CAPS",
    "C", "K", "H", "DC", "JBE", "JAR", "SPY", "SPRAY", "CREMA", "POMADA", "GEL",
    "SUSP", "SOL", "AMP", "FA", "INE", "ADTO", "SHAM",
}


def nombre_ticket_sucio(s: str) -> bool:
    if not s or len(s) > 72:
        return True
    return bool(
        re.search(r"\$|Descto|Desato|\||\blab\b|\blăb\b|\[\d|Marcas\s+Nestle", s, re.I)
    )

FORM_MAP = {
    "TAB": "TABLETAS", "TABS": "TABLETAS", "TAR": "TABLETAS", "CAP": "CAPSULAS", "CAPS": "CAPSULAS",
    "CAPSULAS": "CAPSULAS", "COMP": "COMPRIMIDOS", "COMPR": "COMPRIMIDOS", "GRAG": "GRAGEAS",
    "FA": "FRASCO AMPULA", "AMP": "AMPOLLETA", "JBE": "JARABE", "JAR": "JARABE", "SUSP": "SUSPENSION",
    "SOL": "SOLUCION", "SO": "SOLUCION", "GEL": "GEL", "CREMA": "CREMA", "CMA": "CREMA",
    "SUP": "SUPOSITORIO", "SUPOS": "SUPOSITORIO", "OV": "OVULOS", "OVULOS": "OVULOS", "SPY": "SPRAY",
    "SPRAY": "SPRAY", "UNG": "UNGÜENTO", "POM": "POMADA", "DC": "DUAL CAPS", "JGA": "JERINGA",
}

GENERIC_SUFFIXES = (
    "OXACINO", "MICINA", "MYCIN", "PRIL", "STATIN", "METFORM", "AZOL", "PAM", "ZOL", "PRAZOL",
    "DIPINA", "ARTAN", "CILLIN", "PRIL", "SARTAN", "AFIL", "VASTAT", "BULIN", "METRO",
)

COMMERCIAL_MED_NAMES = {
    "TERFICHO", "VERNISEN", "AMIFARIN", "CEFALVER", "CEFAROXIL", "CLOXAN", "PERLUDIL", "OVISEN",
    "FASICLOR", "CEFAGEN", "KLARIX", "CHARLYN", "CEPOBROM", "DICLOFEN", "EPICIN", "KNORICIN",
    "TROPHARMA", "CLAMOXIN", "BACTIVER", "GIMALXINA", "VALCLAN", "LESACLOR", "AMCEF", "ACROXIL",
    "PENTIVER", "PENIPOT", "ERISPAN", "AMPIGRIN", "WERMY", "ZUKEDIB", "BENEVENTOL", "AMIFARIN",
    "ERBITRAX", "VALNAIT", "ALEVARIN", "HUCIUS", "GELCAVIT", "ANIMALIN", "FOTOSUN", "MEDITEST",
}

GENERIC_PA_HINTS = {
    "FASICLOR": "CEFACLOR", "CEFAGEN": "CEFALEXINA", "KLARIX": "CLARITROMICINA", "CHARLYN": "CIPROFLOXACINO",
    "CEPOBROM": "CEFADROXIL", "DICLOFEN": "DICLOFENACO", "EPICIN": "ERITROMICINA", "KNORICIN": "NITROFURANTOINA",
    "CLAMOXIN": "AMOXICILINA/AC. CLAVULANICO", "GIMALXINA": "AMOXICILINA", "VALCLAN": "AMOXICILINA/AC. CLAVULANICO",
}


@dataclass
class ParsedProducto:
    nombre: str
    marca: str | None = None
    presentacion: str | None = None
    principio_activo: str | None = None
    concentracion: str | None = None
    forma_farmaceutica: str | None = None
    categoria: str | None = None
    notas_parser: str | None = None


def _norm_spaces(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip(" .,-|/\"'")


def _is_garbage_name(s: str) -> bool:
    u = s.upper().strip()
    if re.match(r"^FC\s+\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}", u):
        return True
    if u.startswith("CLAVE "):
        return True
    if u.startswith("PRODUCTO IFC"):
        return True
    if re.match(r"^/\s*\d", u):
        return True
    return False


def _normalize_ticket_text(nombre: str) -> str:
    s = str(nombre or "").strip()
    if not s:
        return ""
    s = re.sub(r"\$\s*[\d.,]+", " ", s)
    s = re.sub(r"Descto:\s*[\d.,]+%?\s*", " ", s, flags=re.I)
    s = re.sub(r"\b\d{8,14}\b", " ", s)
    s = re.sub(r"^\d+\s+", "", s)
    s = s.replace("|", " ")
    s = re.sub(r"\b(Marcas|Lab|Otc|Pg|Pere|Dkt)\b", " ", s, flags=re.I)
    s = re.sub(r"Spy(\d+(?:\.\d+)?)\s*(Ml|ML)?", r"Spy \1 ML", s, flags=re.I)
    s = re.sub(r"Ms[pP]y(\d+(?:\.\d+)?)\s*(Ml|ML)?", r"Spy \1 ML", s, flags=re.I)
    s = re.sub(r"Stick(\d+(?:\.\d+)?)\s*G", r"Stick \1 G", s, flags=re.I)
    s = re.sub(r"R-On(\d+(?:\.\d+)?)\s*G?", r"R-On \1 G", s, flags=re.I)
    s = re.sub(r"(\d+)Cml\b", r"\1 ML", s, flags=re.I)
    s = re.sub(r"(\d+)Opzs\b", r"\1 PZA", s, flags=re.I)
    s = re.sub(r"(\d+)Gr\b", r"\1 G", s, flags=re.I)
    s = re.sub(r"(\d+)Mi\b", r"\1 ML", s, flags=re.I)
    s = re.sub(r"(\d+)Mln\b", r"\1 ML", s, flags=re.I)
    s = re.sub(r"Pom-Dry(\d+)H", r"Pom-Dry \1 H", s, flags=re.I)
    # Separar unidades pegadas: 250Ml, 45G, 500Mln, R-On65
    s = re.sub(r"(\d)(Ml|ML|Mln|MLN|Gr|GR|Gn|G|Cm|CM|Lt|LT)(?=\b|$)", r"\1 \2", s, flags=re.I)
    s = re.sub(r"R-On(\d+)", r"R-On \1", s, flags=re.I)
    s = re.sub(r"(\d)(C/\d+)", r"\1 \2", s)
    s = re.sub(r"\s+", " ", s).strip()

    words = s.split()
    if len(words) >= 8:
        half = len(words) // 2
        a, b = " ".join(words[:half]), " ".join(words[half:])
        if b.lower().startswith(a[: min(20, len(a))].lower()):
            s = a
    return _norm_spaces(s)


def _extract_presentacion(text: str) -> tuple[str | None, str]:
    patterns = [
        (r"\bC/\s*(\d+)\b", lambda m: f"C/{m.group(1)}"),
        (r"\bTab\s*/\s*(\d+)\b", lambda m: f"C/{m.group(1)}"),
        (r"\b€/\s*(\d+)\b", lambda m: f"C/{m.group(1)}"),
        (r"\bTab\s+(\d+)\b", lambda m: f"{m.group(1)} TABLETAS"),
        (r"\b(\d+(?:\.\d+)?)\s*Ui\b", lambda m: f"{m.group(1)} UI"),
        (r"\bR-On\s*(\d+(?:\.\d+)?)\s*G\b", lambda m: f"R-ON {m.group(1)} G"),
        (r"\bStick\s*(\d+(?:\.\d+)?)\s*G\b", lambda m: f"STICK {m.group(1)} G"),
        (r"\bSpy\s*(\d+(?:\.\d+)?)\s*ML\b", lambda m: f"SPRAY {m.group(1)} ML"),
        (r"\b(\d+)\s*Pack\b", lambda m: f"{m.group(1)} PACK"),
        (r"\b(\d+(?:\.\d+)?)\s*(ML|Ml|ml|MLN|Mln)\b", lambda m: f"{m.group(1)} ML"),
        (r"\b(\d+(?:\.\d+)?)\s*(LT|Lt|lt|L)\b", lambda m: f"{m.group(1)} L"),
        (r"\b(\d+(?:\.\d+)?)\s*(GR|Gr|gr|GN|Gn)\b", lambda m: f"{m.group(1)} G"),
        (r"\b(\d+(?:\.\d+)?)\s*G\b", lambda m: f"{m.group(1)} G"),
        (r"\b(\d+)\s*CM\s*[Xx×]\s*(\d+)\s*M\b", lambda m: f"{m.group(1)} CM x {m.group(2)} M"),
        (r"\b(\d+)\s*CM\b", lambda m: f"{m.group(1)} CM"),
        (r"\b(\d+)\s*PZA\b", lambda m: f"{m.group(1)} PZA"),
        (r"\b(\d+)\s*(?:Tab|TAB|TAR)\b", lambda m: f"{m.group(1)} TABLETAS"),
        (r"\b(\d+)\s*(?:Cap|CAP|Caps|CAPS)\b", lambda m: f"{m.group(1)} CAPSULAS"),
        (r"\b(\d+)\s*MG\b", lambda m: f"{m.group(1)} MG"),
    ]
    best = None
    best_raw = None
    rest = text
    for pat, fmt in patterns:
        for m in re.finditer(pat, rest, flags=re.I):
            raw = m.group(0)
            if best is None or len(raw) > len(best_raw or ""):
                best = fmt(m)
                best_raw = raw
    if best_raw:
        rest = _norm_spaces(rest.replace(best_raw, " "))
    return best, rest


def _match_category(text: str) -> tuple[str | None, str | None, str, str | None]:
    for pat, forma, cat in CATEGORY_PREFIXES:
        m = re.match(pat, text, flags=re.I)
        if m:
            prefix = text[: m.end()]
            rest = _norm_spaces(text[m.end() :])
            brand = _brand_from_prefix(prefix)
            return forma, cat, rest, brand
    return None, None, text, None


def _brand_from_prefix(prefix: str) -> str | None:
    tokens = prefix.split()
    if len(tokens) < 2:
        return None
    for size in (3, 2, 1):
        key = " ".join(tokens[-size:]).upper()
        if key in BRAND_ALIASES:
            return BRAND_ALIASES[key]
    key1 = tokens[1].upper()
    if key1 in BRAND_ALIASES:
        return BRAND_ALIASES[key1]
    if key1 in KNOWN_BRANDS:
        return key1.title()
    return None


def _resolve_brand(tokens: list[str]) -> tuple[str | None, list[str]]:
    if not tokens:
        return None, tokens
    upper_line = " ".join(tokens).upper()
    for alias, brand in sorted(BRAND_ALIASES.items(), key=lambda x: -len(x[0])):
        if re.search(rf"\b{re.escape(alias)}\b", upper_line):
            rest = re.sub(rf"\b{re.escape(alias)}\b", " ", upper_line, flags=re.I)
            rest_tokens = [t for t in _norm_spaces(rest).split() if t]
            return brand, rest_tokens
    for brand in sorted(KNOWN_BRANDS, key=len, reverse=True):
        if re.search(rf"\b{re.escape(brand)}\b", upper_line, flags=re.I):
            rest = re.sub(rf"\b{re.escape(brand)}\b", " ", " ".join(tokens), flags=re.I)
            return brand.title() if brand.isupper() else brand, [t for t in _norm_spaces(rest).split() if t]
    for size in (2, 1):
        key = " ".join(tokens[:size]).upper()
        if key in BRAND_ALIASES:
            return BRAND_ALIASES[key], tokens[size:]
    return None, tokens


def _title_tokens(tokens: list[str]) -> str:
    if not tokens:
        return ""
    s = " ".join(tokens)
    return s.title() if s.isupper() else s


def _looks_generic(word: str) -> bool:
    w = word.upper()
    if any(suf in w for suf in GENERIC_SUFFIXES):
        return True
    if re.match(r"^[A-ZÁÉÍÓÚÑ]{4,}(INA|OL|ONE|IDE|ATE|INE|MICINA|OXACINO)$", w):
        return True
    if w.endswith(("MICINA", "OXACINO", "PRIL", "STATIN", "MYCIN")):
        return True
    return False


def _parse_medicamento(text: str) -> ParsedProducto | None:
    # C/N al final: ERBITRAX TABLETAS 250 MG C/7
    c_match = re.search(r"\bC/\s*(\d+)\s*$", text, flags=re.I)
    c_pres = f"C/{c_match.group(1)}" if c_match else None
    base = _norm_spaces(re.sub(r"\bC/\s*\d+\s*$", "", text, flags=re.I))

    m = re.match(
        r"^(?P<head>.+?)\s+(?P<qty>\d+)\s+"
        r"(?P<form>TAB|TABS|TAR|CAP|CAPS|CAPSULAS|COMP|COMPR|GRAG|OV|OVULOS|FA|AMP|JBE|JAR|SUSP|SOL|SO|GEL|CREMA|CMA|SUP|SUPOS|SPY|SPRAY|UNG|POM|DC|JGA)\.?\b"
        r"(?:\s+(?P<conc>.+))?$",
        base,
        flags=re.I,
    )
    if not m and re.search(r"\b(FA|SUSP|SOL|JBE|JAR|GEL|CREMA|CMA|AMP|SO)\b", base, flags=re.I):
        m2 = re.match(
            r"^(?P<head>.+?)\s+(?P<form>FA|SUSP|SOL|JBE|JAR|GEL|CREMA|CMA|AMP|SO|SPY|SPRAY)\s+(?P<conc>.+)$",
            base,
            flags=re.I,
        )
        if m2:
            head = _norm_spaces(m2.group("head"))
            form = FORM_MAP.get(m2.group("form").upper(), m2.group("form").upper())
            conc = _norm_spaces(m2.group("conc"))
            first = head.split()[0].upper()
            marca = None
            pa = None
            if _looks_generic(first):
                pa = head.upper()
            elif first in COMMERCIAL_MED_NAMES:
                marca = head.split()[0].title()
                pa = GENERIC_PA_HINTS.get(first)
            else:
                marca = head.split()[0].title()
                pa = GENERIC_PA_HINTS.get(first)
            pres = c_pres or form
            return ParsedProducto(
                nombre=_title_tokens(head.split()[1:]) or head.title(),
                marca=marca,
                principio_activo=pa or (head.upper() if _looks_generic(first) else None),
                presentacion=pres,
                concentracion=conc.upper() or None,
                forma_farmaceutica=form,
                categoria="Medicamento",
            )

    if not m:
        # TABLETAS 250 MG C/7 sin qty form estándar
        m3 = re.match(
            r"^(?P<head>.+?)\s+(?P<form>TABLETAS|CAPSULAS|COMPRIMIDOS|JARABE|SUSPENSION|GOTAS)\s+(?P<conc>.+)$",
            base,
            flags=re.I,
        )
        if m3:
            head = _norm_spaces(m3.group("head"))
            form = m3.group("form").upper()
            conc = _norm_spaces(m3.group("conc"))
            first = head.split()[0].upper()
            marca = None if _looks_generic(first) else head.split()[0].title()
            return ParsedProducto(
                nombre=head.title(),
                marca=marca,
                principio_activo=head.upper() if _looks_generic(first) else GENERIC_PA_HINTS.get(first),
                presentacion=c_pres or form,
                concentracion=conc.upper(),
                forma_farmaceutica=form,
                categoria="Medicamento",
            )
        return None

    head = _norm_spaces(m.group("head"))
    qty, form_raw = m.group("qty"), m.group("form")
    form = FORM_MAP.get(form_raw.upper(), form_raw.upper())
    conc = _norm_spaces(m.group("conc") or "")
    presentacion = c_pres or f"{qty} {form}"
    first = head.split()[0].upper()

    if _looks_generic(first):
        return ParsedProducto(
            nombre=head.title(),
            principio_activo=head.upper(),
            presentacion=presentacion,
            concentracion=conc.upper() or None,
            forma_farmaceutica=form,
            categoria="Medicamento",
        )

    marca = head.split()[0].title()
    pa = GENERIC_PA_HINTS.get(first)
    variant = _title_tokens(head.split()[1:])
    return ParsedProducto(
        nombre=variant or marca,
        marca=marca,
        principio_activo=pa,
        presentacion=presentacion,
        concentracion=conc.upper() or None,
        forma_farmaceutica=form,
        categoria="Medicamento",
    )


def _parse_mercurio(text: str) -> ParsedProducto | None:
    if not re.match(r"^MERCURIO\b", text, flags=re.I):
        return None
    pres, rest = _extract_presentacion(text)
    rest = re.sub(r"^MERCURIO\s+", "", rest, flags=re.I)
    rest = re.sub(r"\b\d{6,}\b", " ", rest)
    rest = _norm_spaces(rest)
    forma = "Producto natural"
    u = rest.upper()
    for kw, f in [
        ("ACEITE", "Aceite"), ("POMADA", "Pomada"), ("JARABE", "Jarabe"), ("POLVO", "Polvo"),
        ("SOBRES", "Sobres"), ("PERLAS", "Perlas"), ("YODO", "Yodo"), ("ARNICA", "Arnica"),
        ("GLICERINA", "Glicerina"), ("BICARBONATO", "Bicarbonato"), ("BORAX", "Borax"),
        ("MAGNESIA", "Magnesia"), ("HABA", "Haba alcanforada"),
    ]:
        if kw in u:
            forma = f
            break
    return ParsedProducto(
        nombre=rest.title(),
        marca="Mercurio",
        presentacion=pres,
        forma_farmaceutica=forma,
        categoria="Botiquín",
    )


def _parse_higiene(text: str) -> ParsedProducto | None:
    forma, categoria, rest, prefix_brand = _match_category(text)
    pres, rest = _extract_presentacion(rest)

    tokens = rest.split()
    marca_early = prefix_brand
    if tokens:
        m0, after = _resolve_brand(tokens)
        if m0:
            marca_early = m0
            tokens = after
            if not forma:
                f2, c2, rest2, b2 = _match_category(" ".join(tokens))
                forma, categoria = f2 or forma, c2 or categoria
                marca_early = marca_early or b2
                tokens = rest2.split() if rest2 else tokens

    marca, variant = _resolve_brand(tokens)
    if marca_early and not marca:
        marca = marca_early

    if not forma and not marca and not pres:
        return None

    nombre = _title_tokens(variant)
    if marca and nombre:
        nombre_display = f"{marca} {nombre}".strip()
    elif marca:
        nombre_display = marca
    else:
        nombre_display = nombre or rest.title()

    return ParsedProducto(
        nombre=nombre_display,
        marca=marca,
        presentacion=pres,
        forma_farmaceutica=forma,
        categoria=categoria,
    )


def _dedupe_farmalive_text(text: str) -> str:
    s = _norm_spaces(text)
    words = s.split()
    if len(words) >= 6:
        half = len(words) // 2
        a, b = " ".join(words[:half]), " ".join(words[half:])
        if len(b) >= 8 and (b.lower() in a.lower() or a.lower() in b.lower() or _similar_prefix(a, b)):
            s = a if len(a) <= len(b) else b
    return _norm_spaces(s)


def _similar_prefix(a: str, b: str) -> bool:
    aa = re.sub(r"[^a-z0-9]", "", a.lower())[:18]
    bb = re.sub(r"[^a-z0-9]", "", b.lower())[:18]
    return bool(aa and bb and (aa.startswith(bb) or bb.startswith(aa)))


def _strip_distribuidor_tail(text: str) -> str:
    s = text.replace("|", " ")
    s = re.sub(r"\b(?:Descto|Desato):\s*[\d.,]+%?\s*", " ", s, flags=re.I)
    s = re.sub(r"\$\s*[\d.,]+", " ", s)
    s = re.sub(r"\[\d{8,14}\]", " ", s)
    s = re.sub(r"\{[^}]*\}", " ", s)
    tokens = s.split()
    while tokens and tokens[-1].upper().strip(".,|") in DISTRIBUIDOR_TOKENS:
        tokens.pop()
    while len(tokens) >= 2 and " ".join(tokens[-2:]).upper() in BRAND_ALIASES:
        key = " ".join(tokens[-2:]).upper()
        if key in {"RB HEALTH", "PG HEALTH", "PG PERE", "KIMBERLY CLARK", "MARCAS NESTLE", "BDE MEXICO"}:
            tokens = tokens[:-2]
            continue
        break
    return _norm_spaces(" ".join(tokens))


def _deep_clean_farmalive(text: str) -> str:
    s = _norm_spaces(text)
    s = s.replace("Electrolid", "Electrolit").replace("electrolid", "Electrolit")
    s = re.sub(r"Èresa", "Fresa", s, flags=re.I)
    s = re.sub(r"^\d+(?:\.\d+)?\s*(?:ML|MI|GR|G|LT|L)\s*", "", s, flags=re.I)
    s = re.sub(r"\b(?:Lab|Lăb|LÄb)\s+\w+\s*", " ", s, flags=re.I)
    s = re.sub(r"\b(?:Marcas|Otc|Ot\s*C|Pg|Pere|Pacs?|Paci|Pace|Nvo|Er\s*I)\b", " ", s, flags=re.I)
    s = re.sub(r"\b[A-Z]\d{5,}\b", " ", s)
    s = re.sub(r"\b\d{8,14}\b", " ", s)
    s = re.sub(r"\$\s*[\d.,]+", " ", s)
    s = re.sub(r"\b(?:Descto|Desato):\s*[\d.,]+%?\s*", " ", s, flags=re.I)
    s = re.sub(r"\(\s*[A-Z]\s*\)", " ", s)
    return _norm_spaces(s)


def _variant_after_brand(text_after: str) -> str:
    tokens: list[str] = []
    for tok in text_after.split():
        tu = tok.upper().rstrip(".,|")
        if re.match(r"^\d", tu):
            break
        if tu in FLAVOR_STOP or tu in DISTRIBUIDOR_TOKENS:
            break
        if len(tu) <= 2 and tu.isalpha() and tu not in {"SR", "DC", "NE"}:
            break
        tokens.append(tok)
    variant = _title_tokens(tokens)
    variant = re.sub(r"\s+\d+\s*$", "", variant).strip()
    return variant


def _extract_farmalive_product(text: str) -> tuple[str, str | None, str | None] | None:
    s = _deep_clean_farmalive(_dedupe_farmalive_text(_normalize_ticket_text(text)))
    if not s:
        return None

    for pat, brand in FARMALIVE_PRODUCT_LINES:
        m = re.search(pat, s, flags=re.I)
        if not m:
            continue
        variant = _variant_after_brand(s[m.end() :])
        nombre = f"{brand} {variant}".strip() if variant else brand
        return nombre, brand, variant or None

    med = re.match(
        r"^(?P<name>.+?)\s+(?P<form>Tab|TABS|Tar|CAP|CAPS|CAPSULAS|Jbe|JBE|Jar|Crema|Pomada|Gel|Spray|SPY|SUSP|Grag|Supos|Amp|Iv)\b",
        s,
        flags=re.I,
    )
    if med:
        name_part = re.sub(r"\s+\d+\s*MG\s*$", "", _norm_spaces(med.group("name")), flags=re.I)
        tokens = name_part.split()
        marca, rest = _resolve_brand(tokens)
        if not marca and tokens:
            marca = BRAND_ALIASES.get(tokens[0].upper(), tokens[0].title())
            rest = tokens[1:]
        variant = _title_tokens(rest)
        if marca:
            nombre = f"{marca} {variant}".strip() if variant else marca
            return nombre, marca, variant or None
        return name_part.title(), None, None

    tokens = [t for t in s.split() if t.upper() not in DISTRIBUIDOR_TOKENS]
    marca, rest = _resolve_brand(tokens)
    if marca:
        variant = _title_tokens(rest)
        nombre = f"{marca} {variant}".strip() if variant else marca
        if len(nombre) <= 60 and not nombre_ticket_sucio(nombre):
            return nombre, marca, variant or None
    return None


def _detect_forma_keyword(text: str) -> tuple[str | None, str | None]:
    m = re.search(
        r"\b(Tab|TABS|TAR|Cap|CAPS|CAPSULAS|Jbe|JBE|Jar|JAR|Crema|CREMA|CMA|Pomada|POMADA|Pom|POM|"
        r"Gel|GEL|Spray|SPY|SPRAY|Supos|SUPOS|Sup|SUP|SUSP|Sol|SOL|Ung|UNG|Grag|GRAG|Tar|TAR|"
        r"Sham|SHAM|Ine|INE|Adto|ADTO|Amp|AMP|Spy|SPY|Gotas|GOTAS|Lub|LUB)\b",
        text,
        flags=re.I,
    )
    if not m:
        return None, text
    raw = m.group(1).upper()
    form_map_extra = {
        "TAB": "TABLETAS", "TABS": "TABLETAS", "TAR": "TABLETAS", "CAP": "CAPSULAS", "CAPS": "CAPSULAS",
        "CAPSULAS": "CAPSULAS", "JBE": "JARABE", "JAR": "JARABE", "CREMA": "CREMA", "CMA": "CREMA",
        "POMADA": "POMADA", "POM": "POMADA", "GEL": "GEL", "SPRAY": "SPRAY", "SPY": "SPRAY",
        "SUPOS": "SUPOSITORIO", "SUP": "SUPOSITORIO", "SUSP": "SUSPENSION", "SOL": "SOLUCION",
        "UNG": "UNGÜENTO", "GRAG": "GRAGEAS", "SHAM": "SHAMPOO", "INE": "SOLUCION", "ADTO": "ADULTO",
        "AMP": "AMPOLLETA", "GOTAS": "GOTAS", "LUB": "LUBRICANTE",
    }
    forma = form_map_extra.get(raw, FORM_MAP.get(raw, raw))
    before = _norm_spaces(text[: m.start()])
    after = _norm_spaces(text[m.end() :])
    return forma, _norm_spaces(f"{before} {after}")


def _parse_farmalive(text: str, tipo: str | None = None) -> ParsedProducto | None:
    extracted = _extract_farmalive_product(text)
    cleaned = _deep_clean_farmalive(_dedupe_farmalive_text(_normalize_ticket_text(text)))
    if not cleaned and not extracted:
        return None

    pres_parts: list[str] = []
    pres, rest = _extract_presentacion(cleaned or text)
    if pres:
        pres_parts.append(pres)
    c_match = re.search(r"\bC/\s*(\d+)\b", rest or cleaned, flags=re.I)
    if c_match:
        pres_parts.append(f"C/{c_match.group(1)}")

    forma, rest_form = _detect_forma_keyword(cleaned or text)
    cat: str | None = None
    if not forma:
        forma, cat, _, _ = _match_category(cleaned or text)
    elif str(tipo or "").upper() == "MEDICAMENTO":
        cat = "Medicamento"

    if extracted:
        nombre_display, marca, _variant = extracted
    else:
        tokens = [t for t in (rest_form or cleaned or "").split() if t.upper() not in DISTRIBUIDOR_TOKENS]
        marca, variant = _resolve_brand(tokens)
        nombre_display = _title_tokens(variant) or (cleaned or text).title()
        if marca and not nombre_display.lower().startswith(marca.lower()):
            nombre_display = f"{marca} {nombre_display}".strip()

    if forma and not cat:
        cat = "Medicamento" if forma in {
            "TABLETAS", "CAPSULAS", "JARABE", "SUSPENSION", "GOTAS", "SUPOSITORIO", "GEL", "POMADA",
            "AMPOLLETA", "GRAGEAS", "COMPRIMIDOS", "UNGÜENTO", "SOLUCION", "INYECTABLE",
        } else "Producto"

    if not cat and marca in {"Electrolit", "Pedialyte"}:
        cat = "Higiene personal"
        forma = forma or "Suero oral"

    presentacion = " · ".join(dict.fromkeys(pres_parts)) if pres_parts else pres
    if not presentacion and forma in {"TABLETAS", "CAPSULAS", "GRAGEAS"}:
        presentacion = forma
    if not presentacion and c_match:
        presentacion = f"C/{c_match.group(1)}"

    if not (marca or presentacion or forma or extracted):
        return None

    return ParsedProducto(
        nombre=nombre_display,
        marca=marca,
        presentacion=presentacion,
        forma_farmaceutica=forma,
        categoria=cat or "Producto",
    )


def _parse_caps_catalog(text: str) -> ParsedProducto | None:
    raw = _norm_spaces(text)
    if not raw or not re.match(r"^[A-Z0-9ÁÉÍÓÚÑ\s./+\-]+$", raw):
        return None
    pres, rest = _extract_presentacion(raw)
    tokens = rest.split()
    marca, tokens = _resolve_brand(tokens)
    if not marca and tokens:
        key1 = tokens[0].upper()
        key2 = " ".join(tokens[:2]).upper() if len(tokens) >= 2 else ""
        if key2 in BRAND_ALIASES:
            marca = BRAND_ALIASES[key2]
            tokens = tokens[2:]
        elif key1 in BRAND_ALIASES:
            marca = BRAND_ALIASES[key1]
            tokens = tokens[1:]
        elif key1 not in {"AGUA", "ALCOHOL", "CREMA", "POMADA", "GOTERO", "TB", "BOLO", "LIO"}:
            marca = tokens[0].title()
            tokens = tokens[1:]

    rest_text = " ".join(tokens)
    forma, categoria, rest2, _ = _match_category(rest_text)
    if not forma:
        u = rest_text.upper()
        for kw, f, c in [
            ("ALCOHOL", "Alcohol", "Botiquín"),
            ("AGUA DEST", "Agua destilada", "Botiquín"),
            ("POMADA", "Pomada", "Botiquín"),
            ("UNG", "Ungüento", "Botiquín"),
            ("LIQ", "Líquido", "Suplemento"),
            ("GOTERO", "Gotero", "Botiquín"),
            ("TAB", "Tabletas", "Medicamento"),
            ("CREMA", "Crema", "Cuidado personal"),
            ("VAPORUB", "Balsamo", "Botiquín"),
            ("VICK", "Balsamo", "Botiquín"),
            ("VASELINE", "Vaselina", "Cuidado personal"),
            ("FASELINE", "Vaselina", "Cuidado personal"),
            ("FLUJO", "Toallas sanitarias", "Higiene personal"),
            ("NOCHE", "Toallas sanitarias", "Higiene personal"),
            ("SURT", "Surtido", "Botiquín"),
        ]:
            if kw in u:
                forma, categoria = f, c
                break

    nombre = _title_tokens(rest2.split()) if rest2 else (marca or raw.title())
    if marca and nombre and not nombre.lower().startswith(marca.lower()):
        nombre = f"{marca} {nombre}".strip()
    elif marca and not nombre:
        nombre = marca

    return ParsedProducto(
        nombre=nombre,
        marca=marca,
        presentacion=pres,
        forma_farmaceutica=forma,
        categoria=categoria or "Producto",
    )


def _parse_ifc(text: str) -> ParsedProducto | None:
    raw = _norm_spaces(text)
    if not raw:
        return None
    pres, rest = _extract_presentacion(raw)
    rest = re.sub(r"\b(?:VARFAM|LAVA|OJOS|VIDRIO|ABR\d+|CAJA|C\s+A)\b.*$", "", rest, flags=re.I)
    rest = re.sub(r"\b\d{5,}\b", " ", rest)
    rest = _norm_spaces(rest)
    tokens = rest.split()
    marca, tokens = _resolve_brand(tokens)
    if not marca and tokens:
        marca = tokens[0].title()
        tokens = tokens[1:]
    forma = None
    u = rest.upper()
    if "POMADA" in u:
        forma = "Pomada"
    elif "ACEITE" in u:
        forma = "Aceite"
    elif "BICARBONATO" in u:
        forma = "Bicarbonato"
    elif "MERTIOLATE" in u:
        forma = "Antiséptico"
    elif "PERILLA" in u:
        forma = "Perilla"
    nombre = _title_tokens(tokens) or rest.title()
    if marca:
        nombre = f"{marca} {nombre}".strip() if nombre else marca
    return ParsedProducto(
        nombre=nombre,
        marca=marca,
        presentacion=pres,
        forma_farmaceutica=forma,
        categoria="Botiquín",
    )


def parse_nombre_producto(nombre: str, tipo: str | None = None) -> ParsedProducto:
    raw = str(nombre or "").strip()
    if not raw:
        return ParsedProducto(nombre="")
    if _is_garbage_name(raw):
        return ParsedProducto(nombre=raw, notas_parser="nombre_ticket_invalido")

    cleaned = _normalize_ticket_text(raw)
    tipo_u = str(tipo or "").upper()

    if tipo_u == "MEDICAMENTO" or re.search(
        r"\b(\d+\s+(TAB|TABS|TAR|CAP|CAPS|COMP|FA|AMP|JBE|GRAG|OV|SUSP|CMA|SUP)|"
        r"TABLETAS|CAPSULAS|SUSPENSION|GOTAS)\b",
        cleaned,
        re.I,
    ):
        med = _parse_medicamento(cleaned.upper())
        if med:
            return med

    # Tickets FarmaLive: OCR con duplicados y laboratorio al final
    if re.search(r"\$\s*[\d.,]+|Descto:|Desato:|\|\s*Lab\b", raw, re.I) or re.search(
        r"\b(Bayer Otc|Rb Health|Pg Health|Kimberly Clark)\b", raw, re.I
    ):
        fl = _parse_farmalive(raw, tipo)
        if fl:
            return fl

    # Catálogo Mercurio / mayoreo en MAYÚSCULAS (sin patrón medicamento)
    if raw.isupper() and len(raw) >= 8 and not re.search(
        r"\b\d+\s+(TAB|TABS|TAR|CAP|CAPS|FA|AMP|JBE|SUSP|CMA|SUP)\b", raw
    ):
        caps = _parse_caps_catalog(raw)
        if caps:
            return caps

    # IFC: marca + producto + códigos
    if re.search(r"\b(?:EDIGAR|EDGAR|VELAZQUEZ|KOHN|MADRID|REOMATOLUM)\b", cleaned, re.I):
        ifc = _parse_ifc(cleaned)
        if ifc:
            return ifc

    mer = _parse_mercurio(cleaned.upper())
    if mer:
        return mer

    hig = _parse_higiene(cleaned)
    if hig:
        return hig

    pres, rest = _extract_presentacion(cleaned)
    marca, tokens = _resolve_brand(rest.split())
    return ParsedProducto(
        nombre=_title_tokens(tokens) or cleaned,
        marca=marca,
        presentacion=pres,
        categoria="Otro",
    )
