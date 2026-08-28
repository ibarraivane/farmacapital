#!/usr/bin/env python3
"""
Sincroniza precios de venta de Farmacias Similares (VTEX público) → producto_precios_referencia.

API: https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/{termino}

A diferencia de la versión anterior, este script NO acepta el primer resultado que
devuelve VTEX: puntúa todos los candidatos contra el producto (principio activo,
concentración, cantidad y forma farmacéutica) y descarta lo que no alcance el umbral.
La confianza que se guarda es la calculada, no un valor fijo.

Uso:
  python3 scripts/sync_precios_similares.py --dry-run
  python3 scripts/sync_precios_similares.py --dry-run --limit 60 --csv
  python3 scripts/sync_precios_similares.py --apply
  python3 scripts/sync_precios_similares.py --apply --umbral 75

Rate limit: ~1 req/s (configurable con --delay). Cachea cada término consultado.
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
REPORTE_DIR = ROOT / "pricing" / "reportes"
LOCK_PATH = Path(os.environ.get("TMPDIR", "/tmp")) / "fc_sync_similares.lock"

VTEX_SEARCH = "https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/{query}"

# Umbrales de confianza calculada
UMBRAL_DEFAULT = 85
UMBRAL_ALTA = 85

# Hallazgos que descalifican un match por completo, no que solo le bajan puntos.
# Regla: si no se puede comprobar que es comparable, no se guarda. Un precio de
# referencia falso es peor que no tener referencia, porque se usa para decidir.
DESCALIFICA = (
    "concentracion difiere",
    "forma difiere",
    "nuestro catalogo sin concentracion",
    "candidato sin tamano declarado",
    "marca parecida",
    "principio activo demasiado generico",
)

# "cantidad difiere 40≠10" no descalifica: es el mismo producto en otro empaque, y con las
# piezas de los dos lados el precio se compara por unidad. Lo que no sirve es que falte uno
# de los dos números, porque entonces la comparación es a ciegas.
RE_CANT_DIFIERE = re.compile(r"cantidad difiere\s*(\d+)\s*≠\s*(\d+)")


def descalificado(razones: list[str]) -> str | None:
    """Devuelve el motivo por el que el match no es comparable, o None si pasa."""
    for r in razones:
        if r.startswith(("al competidor le faltan", "al competidor le sobran")) or (
            r.startswith("solo ") and "principios activos" in r
        ):
            return r
        if r.startswith("cantidad difiere"):
            if not RE_CANT_DIFIERE.search(r):
                return f"{r} (sin las piezas de ambos lados no hay como comparar)"
            continue
        for d in DESCALIFICA:
            if r.startswith(d):
                return r
    return None

try:
    import requests
except ImportError:
    requests = None

try:
    from rapidfuzz import fuzz
except ImportError:
    sys.exit("Falta rapidfuzz. Instala con: python3 -m pip install --user rapidfuzz")


# ──────────────────────────────────────────────────────────────────────
# Normalización y extracción de atributos
# ──────────────────────────────────────────────────────────────────────

# Palabras que NO son principio activo y que producían búsquedas basura
# ("Producto", "Solucion", "Latex" traían el primer resultado arbitrario de VTEX).
RUIDO = {
    "producto", "productos", "solucion", "solucion", "sol", "latex", "reg", "sa",
    "cv", "de", "del", "la", "el", "con", "sin", "para", "por", "y", "en",
    "generico", "generica", "marca", "caja", "frasco", "tubo", "sobre", "sobres",
    "tableta", "tabletas", "tab", "tabs", "capsula", "capsulas", "cap", "caps",
    "comprimido", "comprimidos", "gragea", "grageas", "pieza", "piezas", "pza",
    "jarabe", "suspension", "crema", "unguento", "gel", "locion", "spray",
    "ampolleta", "ampolletas", "inyectable", "gotas", "oral", "topico", "topica",
    "mg", "ml", "gr", "g", "mcg", "ui", "kg", "lt", "l",
    "surfactantes", "antitranspirante", "excipiente", "excipientes", "vehiculo",
    "nan", "none", "null", "otros", "varios", "s", "n", "a",
    # Categorías que aparecen en el campo principio_activo pero no identifican al
    # producto: sin esto, "Antitranspirante / desodorante" hacía que cualquier
    # desodorante de la competencia contara como principio activo completo.
    "desodorante", "shampoo", "champu", "acondicionador", "jabon", "detergente",
    "limpiador", "limpiadora", "humectante", "hidratante", "bloqueador", "protector",
    "solar", "dental", "dentifrico", "enjuague", "bucal", "talco", "panal", "toallita",
    "toallitas", "algodon", "gasa", "venda", "curita", "condon", "preservativo",
    "lubricante", "cosmetico", "capilar", "corporal", "facial", "homeopatico",
    "suplemento", "alimenticio", "fragancia", "perfume", "aceite", "esencia",
    "formula", "natural", "organico", "herbal", "tradicional", "activo", "activos",
}

FORMAS = {
    "tableta": "tableta", "tabletas": "tableta", "tab": "tableta", "tabs": "tableta",
    "comprimido": "tableta", "comprimidos": "tableta", "gragea": "tableta", "grageas": "tableta",
    "capsula": "capsula", "capsulas": "capsula", "cap": "capsula", "caps": "capsula",
    "jarabe": "jarabe", "suspension": "suspension", "susp": "suspension",
    "solucion": "solucion", "gotas": "gotas",
    "crema": "crema", "unguento": "unguento", "pomada": "unguento",
    "gel": "gel", "locion": "locion", "spray": "spray", "aerosol": "spray",
    "supositorio": "supositorio", "supositorios": "supositorio",
    "inyectable": "inyectable", "ampolleta": "inyectable", "ampolletas": "inyectable",
    "ovulo": "ovulo", "ovulos": "ovulo", "parche": "parche", "parches": "parche",
    "polvo": "polvo", "granulado": "polvo", "sobre": "sobre", "sobres": "sobre",
    "talco": "polvo", "pasta": "unguento",
    "barra": "barra", "stick": "barra", "roll": "rollon", "rollon": "rollon",
    "paleta": "paleta", "paletas": "paleta", "caramelo": "pastilla",
    "pastilla": "pastilla", "pastillas": "pastilla", "trocisco": "pastilla",
    "globulo": "globulo", "globulos": "globulo", "jalea": "jalea",
    "emulsion": "emulsion", "elixir": "jarabe", "colirio": "gotas",
    "nebulizacion": "inyectable", "vaporizador": "spray",
}

# Cómo se mide cada forma. Dos formas de la misma familia se comparan bien por unidad
# aunque se llamen distinto: una pastilla para la garganta y una tableta se cuentan por
# pieza, y un jarabe y una solución oral por mililitro. Lo que no se puede comparar es
# entre familias, porque no hay unidad común: un jarabe de 120 ml contra 20 tabletas.
FAMILIA_FORMA = {
    "tableta": "pieza_oral", "capsula": "pieza_oral", "pastilla": "pieza_oral",
    "supositorio": "pieza", "ovulo": "pieza", "parche": "pieza", "paleta": "pieza",
    "globulo": "pieza", "sobre": "sobre",
    "jarabe": "liquido_oral", "suspension": "liquido_oral", "solucion": "liquido_oral",
    "emulsion": "liquido_oral",
    "crema": "topico", "unguento": "topico", "gel": "topico", "jalea": "topico",
    "locion": "topico",
    "gotas": "gotas", "spray": "spray", "polvo": "polvo", "barra": "barra",
    "rollon": "rollon", "inyectable": "inyectable",
}

# Separadores de principios activos en un polifármaco
RE_SEPARADOR_PA = re.compile(r"\s*[/+,]\s*|\s+y\s+|\s+con\s+", re.IGNORECASE)

RE_CONCENTRACION = re.compile(r"(\d+(?:[.,]\d+)?)\s*(mg|mcg|g|gr|ml|ui|%)\b")
RE_CANTIDAD = re.compile(
    r"(?:c/\s*(\d+)"
    r"|(?:con|x)\s+(\d+)\b"
    r"|(\d+)\s*(?:tabletas?|tabs?|capsulas?|caps?|comprimidos?|grageas?|"
    r"piezas?|pzas?|pzs?|pz|sobres?|ampolletas?|ampulas?|supositorios?|ovulos?|"
    r"parches?|jeringas?|frascos?|viales?|tubos?|pastillas?|paletas?|globulos?)\b)",
    re.IGNORECASE,
)


def normalizar(s) -> str:
    """Minúsculas, sin acentos, sin puntuación, espacios colapsados."""
    if s is None:
        return ""
    s = str(s)
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.lower()
    s = re.sub(r"[^a-z0-9./%\s]", " ", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def extraer_concentraciones(texto: str) -> set[str]:
    """{'500mg', '10ml'} — unidades homologadas para poder comparar."""
    out: set[str] = set()
    for valor, unidad in RE_CONCENTRACION.findall(normalizar(texto)):
        try:
            num = float(valor.replace(",", "."))
        except ValueError:
            continue
        unidad = {"gr": "g", "mcg": "mcg"}.get(unidad, unidad)
        # homologar g→mg para que "1 g" y "1000 mg" sean el mismo valor
        if unidad == "g":
            num, unidad = num * 1000, "mg"
        out.add(f"{num:g}{unidad}")
    return out


def concentracion_legible(p: dict) -> bool:
    """
    ¿Se puede leer la concentración de este producto? Es la misma lectura que hace
    evaluar_candidato, sobre los mismos tres campos. Sin ella el match acaba en
    "nuestro catalogo sin concentracion", que descalifica, así que consultar la API
    para ese producto es tiempo perdido.
    """
    texto = " ".join(filter(None, [
        str(p.get("principio_activo") or ""),
        str(p.get("nombre") or ""),
        str(p.get("presentacion") or ""),
    ]))
    return bool(extraer_concentraciones(texto))


def extraer_cantidad(texto: str) -> int | None:
    """Piezas por caja: 'C/20', 'con 20', '20 tabletas' → 20."""
    for grupos in RE_CANTIDAD.findall(normalizar(texto)):
        for g in grupos:
            if g:
                try:
                    n = int(g)
                except ValueError:
                    continue
                if 1 <= n <= 500:
                    return n
    return None


def extraer_forma(texto: str) -> str | None:
    for palabra in normalizar(texto).split():
        if palabra in FORMAS:
            return FORMAS[palabra]
    return None


def ingredientes(pa: str) -> list[str]:
    """
    'Diclofenaco + Tiamina, Piridoxina' → ['diclofenaco', 'tiamina', 'piridoxina'].
    Permite exigir que un polifármaco coincida en todos sus componentes y no
    solo en el primero (Tribedoce Compuesto no es Diclofenaco a secas).
    """
    out: list[str] = []
    for parte in RE_SEPARADOR_PA.split(pa or ""):
        toks = tokens_utiles(parte)
        if toks:
            out.append(toks[0])
    return out


# El mismo fármaco cambia de nombre según el país o el laboratorio. Sin esto, una
# referencia perfecta se descarta sola: Neo-Melubrina dice "dipirona" en nuestro catálogo
# y "METAMIZOL SODICO" en el de Similares, y son el mismo principio activo.
SINONIMOS = {
    "dipirona": "metamizol",
    "metamizol": "metamizol",
    "acetaminofen": "paracetamol",
    "paracetamol": "paracetamol",
    "clorfeniramina": "clorfenamina",
    "clorfenamina": "clorfenamina",
    "hidroxizina": "hidroxicina",
    "hidroxicina": "hidroxicina",
    "ascorbico": "vitaminac",
    "trimetoprim": "trimetoprima",
    "escopolamina": "butilhioscina",
    "butilhioscina": "butilhioscina",
    "hioscina": "butilhioscina",
    "salbutamol": "salbutamol",
    "albuterol": "salbutamol",
}


def canonico(token: str) -> str:
    return SINONIMOS.get(token, token)


# Palabras que describen a quién va dirigido, por dónde se aplica o a qué sabe. Ninguna
# es un principio activo, y sin esta lista 'ADULTO', 'VAGINAL' o 'NASAL' se confundían con
# un componente de más y tiraban referencias correctas.
NO_ES_ACTIVO = {
    "adulto", "adultos", "infantil", "infantiles", "pediatrico", "pediatrica", "junior",
    "bebe", "bebes", "ninos", "nino", "niña", "ninas", "vaginal", "nasal", "oftalmica",
    "oftalmico", "otica", "otico", "topica", "topico", "rectal", "sublingual", "bucal",
    "cutanea", "cutaneo", "inhalado", "sabor", "naranja", "frambuesa", "cereza", "menta",
    "limon", "fresa", "uva", "coco", "mora", "durazno", "chocolate", "vainilla",
    "piezas", "pieza", "envase", "frasco", "caja", "blister", "libre", "cero",
}


def activos_extra_del_candidato(nombre_candidato: str, pa_lista: list[str],
                                marca_tokens: list[str]) -> list[str]:
    """
    Principios activos que trae el competidor y el nuestro no. Simétrico a la regla de
    los que faltan, y hace falta: un ungüento de lidocaína no es lo mismo que uno de
    naproxeno con lidocaína, aunque la lidocaína esté en los dos.

    El catálogo del proveedor lista los activos separados por diagonal al inicio del
    nombre ('NAPROXENO/LIDOCAINA 10G/2G GEL'), así que se revisa la cabeza de cada
    segmento y se ignora lo que sea forma, ruido, marca o número.
    """
    cabezas: list[str] = []
    for segmento in normalizar(nombre_candidato).split("/"):
        toks = tokens_utiles(segmento)
        if not toks:
            continue
        cabeza = toks[0]
        if len(cabeza) < 5 or cabeza in FORMAS or cabeza in RUIDO or cabeza in NO_ES_ACTIVO:
            continue
        if cabeza[0].isdigit():  # '10tabletas', '275mg': tamaño, no componente
            continue
        cabezas.append(cabeza)

    # Solo se concluye que sobran activos si el competidor lista más componentes que
    # nosotros. Sin este corte, la marca propia del proveedor ('AGRIFEN PARACETAMOL /
    # CAFEINA / FENILEFRINA') se confundiría con un principio activo de más.
    if len(cabezas) <= len(pa_lista):
        return []

    propios = {canonico(i) for i in pa_lista}
    marcas = {canonico(mt) for mt in marca_tokens} | set(marca_tokens)
    return [
        c for c in cabezas
        if c not in marcas
        and canonico(c) not in propios
        and not token_presente(c, pa_lista)
    ]


def token_presente(token: str, candidatos: list[str]) -> bool:
    """
    ¿Aparece nuestro principio activo en el nombre del competidor? Tolera tres cosas
    reales de los catálogos: sinónimos del fármaco, abreviaturas del proveedor
    ('SULFA' por sulfametoxazol, 'PARAC' por paracetamol) y errores de dedo.
    """
    t_can = canonico(token)
    for t in candidatos:
        c_can = canonico(t)
        if t_can == c_can or token == t:
            return True
        if fuzz.ratio(t_can, c_can) >= 85:
            return True
        # Abreviatura: uno es el principio del otro. Se exigen 4 letras para que
        # 'ace' o 'sod' no emparejen con cualquier cosa.
        corto, largo = sorted((t_can, c_can), key=len)
        if len(corto) >= 4 and largo.startswith(corto):
            return True
    return False


def tokens_utiles(texto: str) -> list[str]:
    """Palabras que sí identifican al producto (quita ruido, unidades y números sueltos)."""
    out = []
    # La diagonal se conserva en normalizar() para poder leer '275mg/300mg', pero como
    # separador de palabras hay que abrirla: el proveedor escribe 'NAPROXENO SOD/PARAC'
    # y sin abrirla el paracetamol queda escondido dentro de un token.
    for w in re.split(r"[/\s-]+", normalizar(texto)):
        if not w or w in RUIDO or len(w) < 3:
            continue
        if re.fullmatch(r"[\d./%]+", w):
            continue
        if RE_CONCENTRACION.fullmatch(w):
            continue
        out.append(w)
    return out


# ──────────────────────────────────────────────────────────────────────
# Términos de búsqueda
# ──────────────────────────────────────────────────────────────────────

def terminos_de_busqueda(p: dict) -> list[str]:
    """
    Devuelve términos candidatos, del más específico al más general.
    Nunca devuelve palabras de ruido como 'Producto' o 'Solucion'.
    """
    pa_tokens = tokens_utiles(p.get("principio_activo"))
    nombre_tokens = tokens_utiles(p.get("nombre"))
    marca_tokens = tokens_utiles(p.get("marca"))

    concs = sorted(extraer_concentraciones(
        f"{p.get('principio_activo') or ''} {p.get('nombre') or ''} {p.get('presentacion') or ''}"
    ))
    conc = concs[0] if concs else ""

    terminos: list[str] = []

    def agregar(t: str) -> None:
        t = t.strip()
        if t and len(t) >= 4 and t not in terminos:
            terminos.append(t[:60])

    if pa_tokens:
        base = " ".join(pa_tokens[:2])
        if conc:
            agregar(f"{base} {conc}")
        agregar(base)
        agregar(pa_tokens[0])
        if nombre_tokens:
            agregar(" ".join(nombre_tokens[:2]))
    else:
        # Sin principio activo la marca es lo que identifica al producto
        if marca_tokens:
            marca = marca_tokens[0]
            resto = [t for t in nombre_tokens if t != marca]
            agregar(f"{marca} {resto[0]}" if resto else marca)
            agregar(marca)
        if nombre_tokens:
            agregar(" ".join(nombre_tokens[:2]))
            agregar(nombre_tokens[0])

    return terminos


# ──────────────────────────────────────────────────────────────────────
# Scoring del match
# ──────────────────────────────────────────────────────────────────────

def evaluar_candidato(p: dict, nombre_candidato: str) -> tuple[int, list[str]]:
    """
    Confianza 0-100 de que `nombre_candidato` (de Similares) sea el mismo
    producto que `p` (de nuestro catálogo). Devuelve (confianza, razones).
    """
    texto_nuestro = " ".join(filter(None, [
        str(p.get("principio_activo") or ""),
        str(p.get("nombre") or ""),
        str(p.get("presentacion") or ""),
    ]))
    razones: list[str] = []

    nuestros_tokens = tokens_utiles(texto_nuestro)
    cand_tokens = tokens_utiles(nombre_candidato)
    if not nuestros_tokens or not cand_tokens:
        return 0, ["sin tokens comparables"]

    # 1) Similitud léxica base
    score = fuzz.token_set_ratio(" ".join(nuestros_tokens), " ".join(cand_tokens))
    tope = 100  # techo de confianza; algunas diferencias impiden considerarlo match exacto
    piso = 0  # suelo de confianza cuando la identidad quedó probada por otra vía

    # 2) Identidad del producto.
    #    En medicamento manda el principio activo; en perfumería/higiene manda la marca
    #    (un Axe no es un Old Spice aunque ambos digan "desodorante").
    pa_lista = ingredientes(p.get("principio_activo") or "")
    marca_tokens = tokens_utiles(p.get("marca"))

    if pa_lista:
        presentes = [ing for ing in pa_lista if token_presente(ing, cand_tokens)]
        cobertura = len(presentes) / len(pa_lista)
        if cobertura == 0:
            score -= 45
            razones.append(f"sin principio activo '{pa_lista[0]}'")
        elif cobertura < 1.0:
            # Falta al menos un activo, y en las combinaciones ese activo es justo lo que
            # define al producto: la doxilamina es lo que hace dormir al Tabcin Noche y la
            # amantadina es el antiviral del XL-3 VR. Si el competidor no lo trae, no es
            # el mismo medicamento y su precio no sirve de referencia.
            faltan = [i for i in pa_lista if i not in presentes]
            score -= 32 if cobertura < 0.6 else 10
            tope = min(tope, 65)
            razones.append(
                f"al competidor le faltan {len(faltan)}/{len(pa_lista)} principios activos "
                f"({', '.join(faltan[:3])})"
            )
        else:
            sobran = activos_extra_del_candidato(nombre_candidato, pa_lista, marca_tokens)
            if sobran:
                score -= 32
                tope = min(tope, 65)
                razones.append(f"al competidor le sobran principios activos ({', '.join(sobran[:3])})")
                return max(0, min(tope, int(round(score)))), razones
            score += 10
            razones.append("principios activos completos")
            # Un medicamento de marca contra su genérico comparte el tratamiento pero no el
            # nombre, así que el parecido léxico se hunde (Histiacil NF vs AMBROXOL/
            # DEXTROMETORFANO). Con todos los activos verificados la identidad ya está
            # probada por composición, y ese es el precio contra el que se compite en el
            # mostrador. El techo sigue mandando: si la concentración o la forma
            # contradicen, esto no lo rescata.
            piso = UMBRAL_ALTA
            if len(pa_lista) > 1:
                razones.append("equivalente generico verificado por composicion")
    elif marca_tokens:
        # Sin principio activo confiable, la marca es obligatoria
        if token_presente(marca_tokens[0], cand_tokens):
            score += 8
            razones.append("marca coincide")
        else:
            score -= 50
            tope = min(tope, 55)
            razones.append(f"marca '{marca_tokens[0]}' ausente")
    else:
        ancla = nuestros_tokens[0]
        if not token_presente(ancla, cand_tokens):
            score -= 45
            razones.append(f"sin ancla '{ancla}'")

    # 3) Concentración / tamaño
    c_nuestra = extraer_concentraciones(texto_nuestro)
    c_cand = extraer_concentraciones(nombre_candidato)
    if c_nuestra and c_cand:
        # Que se cruce un valor no basta cuando hay varios: paracetamol 500 + cafeina 50
        # y paracetamol 500 + cafeina 25 comparten el 500 y no son la misma formula. Se
        # exige que el conjunto chico esté contenido en el grande.
        chico, grande = sorted((c_nuestra, c_cand), key=len)
        if chico <= grande:
            score += 12
            razones.append("concentracion coincide")
        elif c_nuestra & c_cand:
            score -= 30
            tope = min(tope, 70)
            razones.append(
                f"concentracion difiere en parte {sorted(c_nuestra)}≠{sorted(c_cand)}"
            )
        else:
            score -= 30
            tope = min(tope, 70)
            razones.append(f"concentracion difiere {sorted(c_nuestra)}≠{sorted(c_cand)}")
    elif c_nuestra and not c_cand:
        # Nosotros declaramos tamaño y el candidato no: no podemos confirmar que sea
        # el mismo empaque (Vaporub 50 g y 100 g caían en el mismo candidato).
        score -= 8
        tope = min(tope, 82)
        razones.append("candidato sin tamano declarado")
    elif c_cand and not c_nuestra:
        # Nuestro catálogo no registra la concentración: el match es plausible pero
        # no verificable, y varios SKUs nuestros pueden colapsar en el mismo candidato
        # (los tres Fasiclor cayeron todos en CEFACLOR 250 MG). No puede ser confianza alta.
        score -= 6
        tope = min(tope, 80)
        razones.append("nuestro catalogo sin concentracion")

    # 4) Cantidad por caja: si difiere, el precio no es comparable unidad a unidad
    n_nuestra = extraer_cantidad(texto_nuestro)
    n_cand = extraer_cantidad(nombre_candidato)
    if n_nuestra and n_cand:
        if n_nuestra == n_cand:
            score += 8
            razones.append("cantidad coincide")
        else:
            # Mismo producto en otro empaque. Se penaliza porque el precio de caja no es
            # comparable tal cual, pero no se hunde por debajo del umbral: las piezas de
            # los dos lados quedan guardadas y la comparación se hace por unidad.
            score -= 12
            tope = min(tope, 90)
            razones.append(f"cantidad difiere {n_nuestra}≠{n_cand}")

    # 5) Forma farmacéutica
    f_nuestra = extraer_forma(texto_nuestro) or extraer_forma(p.get("forma_farmaceutica") or "")
    f_cand = extraer_forma(nombre_candidato)
    if f_nuestra and f_cand:
        if f_nuestra == f_cand:
            score += 5
            razones.append("forma coincide")
        elif (
            FAMILIA_FORMA.get(f_nuestra) is not None
            and FAMILIA_FORMA.get(f_nuestra) == FAMILIA_FORMA.get(f_cand)
        ):
            # Distinto nombre, misma manera de medirse (pastilla y tableta se cuentan por
            # pieza). El precio por unidad sigue siendo comparable.
            score -= 8
            tope = min(tope, 92)
            razones.append(f"forma equivalente {f_nuestra}~{f_cand}")
        else:
            score -= 22
            tope = min(tope, 72)
            razones.append(f"forma difiere {f_nuestra}≠{f_cand}")

    return max(0, min(tope, max(piso, int(round(score))))), razones


def validar_precio(precio: float, costo: float | None) -> str | None:
    """Guardarraíl económico. Devuelve motivo de rechazo o None si pasa."""
    if precio is None or precio <= 0:
        return "precio no positivo"
    if costo and costo > 0:
        ratio = precio / costo
        if ratio > 6:
            return f"precio {ratio:.1f}x el costo"
        if ratio < 0.2:
            return f"precio {ratio:.2f}x el costo"
    return None


# ──────────────────────────────────────────────────────────────────────
# Entorno / Supabase
# ──────────────────────────────────────────────────────────────────────

def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip()
    out.setdefault("REACT_APP_SUPABASE_URL", os.environ.get("REACT_APP_SUPABASE_URL", ""))
    out.setdefault("REACT_APP_SUPABASE_ANON_KEY", os.environ.get("REACT_APP_SUPABASE_ANON_KEY", ""))
    return out


def fetch_productos(url: str, key: str) -> list[dict]:
    if not requests:
        sys.exit("Falta requests")
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 499}"}
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers=h,
            params={
                "select": "id,sku,nombre,principio_activo,marca,presentacion,forma_farmaceutica,costo,precio,categoria,tipo",
                "activo": "eq.true",
            },
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        rows.extend(batch)
        if len(batch) < 500:
            break
        offset += 500
    return rows


VENTA_FUENTES = ("fahorro", "similares", "otros_venta")

# Categorías / pistas de nombre que no viven en el catálogo de Similares.
NO_FARMA_CAT = {
    "higiene", "higiene personal", "higiene bucal", "higiene capilar",
    "cuidado personal", "abarrotes", "minisuper", "botiquin", "botiquín",
}
NO_FARMA_NOMBRE = (
    "shampoo", "champu", "acondicionador", "desodorante", "jabon", "pañal",
    "panal", "toalla", "papel higien", "crema dental", "colgate", "pantene",
    "sedal", "axe", "dove", "rexona", "nivea", "ensure", "pediasure", "nido ",
    "electrolit", "suerox", "diapro",
)


def parece_canal_medicamento(p: dict) -> bool:
    """True si vale la pena preguntarle a Similares (genérico / medicamento)."""
    cat = str(p.get("categoria") or "").strip().lower()
    if cat in NO_FARMA_CAT:
        return False
    blob = f"{p.get('nombre') or ''} {cat}".lower()
    if any(x in blob for x in NO_FARMA_NOMBRE):
        return False
    if (p.get("principio_activo") or "").strip():
        return True
    tipo = str(p.get("tipo") or "").lower()
    if tipo in ("generico", "genérico", "marca"):
        return True
    if (p.get("forma_farmaceutica") or "").strip():
        return True
    sku = str(p.get("sku") or "")
    if sku.startswith("EQ-"):
        return True
    if re.search(r"medic|fármaco|farmaco|antib|analge|vitamin|hipert|diabetes", cat):
        return True
    return False


def productos_con_ref_venta(url: str, key: str) -> set[int]:
    """IDs que ya tienen al menos una ref vigente de venta (cualquier fuente)."""
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    ids: set[int] = set()
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 999}"}
        r = requests.get(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=h,
            params={
                "select": "producto_id,fuente,precio,notas",
                "tipo": "eq.venta",
            },
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        for row in batch:
            if row.get("notas") == "__anulado__":
                continue
            try:
                precio = float(row.get("precio") or 0)
            except (TypeError, ValueError):
                continue
            if precio > 0 and row.get("fuente") in VENTA_FUENTES:
                ids.add(row["producto_id"])
        if len(batch) < 1000:
            break
        offset += 1000
    return ids


def productos_ya_sincronizados_hoy(url: str, key: str, fecha: str) -> set[int]:
    """Evita duplicar filas si el script se corre dos veces el mismo día."""
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    ids: set[int] = set()
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 999}"}
        r = requests.get(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=h,
            params={"select": "producto_id", "fuente": "eq.similares", "fecha": f"eq.{fecha}"},
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        ids.update(row["producto_id"] for row in batch)
        if len(batch) < 1000:
            break
        offset += 1000
    return ids


# ──────────────────────────────────────────────────────────────────────
# VTEX
# ──────────────────────────────────────────────────────────────────────

def vtex_buscar(term: str, cache: dict[str, list[dict]]) -> list[dict]:
    """Devuelve [{nombre, precio, vtex_id}] para un término. Cacheado."""
    if term in cache:
        return cache[term]
    url = VTEX_SEARCH.format(query=urllib.parse.quote(term))
    resultados: list[dict] = []
    try:
        req = urllib.request.Request(
            url, headers={"Accept": "application/json", "User-Agent": "Mozilla/5.0 (FarmaCapital)"}
        )
        with urllib.request.urlopen(req, timeout=20) as resp:
            items = json.loads(resp.read())
        for it in items[:25]:
            sellers = (it.get("items") or [{}])[0].get("sellers") or []
            if not sellers:
                continue
            precio = sellers[0].get("commertialOffer", {}).get("Price")
            if precio is None:
                continue
            resultados.append({
                "nombre": it.get("productName") or "",
                "precio": float(precio),
                "vtex_id": str(it.get("productId") or ""),
            })
    except Exception:
        resultados = []
    cache[term] = resultados
    return resultados


def mejor_match(p: dict, cache: dict[str, list[dict]], delay: float) -> dict | None:
    """Consulta términos en orden y devuelve el candidato con mayor confianza."""
    mejor: dict | None = None
    for term in terminos_de_busqueda(p):
        nuevo = term not in cache
        candidatos = vtex_buscar(term, cache)
        if nuevo:
            time.sleep(delay)
        for c in candidatos:
            conf, razones = evaluar_candidato(p, c["nombre"])
            if mejor is None or conf > mejor["confianza"]:
                mejor = {
                    "confianza": conf,
                    "precio": c["precio"],
                    "nombre_fuente": c["nombre"],
                    "vtex_id": c["vtex_id"],
                    "termino": term,
                    "razones": "; ".join(razones),
                    "razones_lista": razones,
                }
        # Si ya tenemos un match sólido no seguimos gastando requests
        if mejor and mejor["confianza"] >= UMBRAL_ALTA:
            break
    return mejor


# ──────────────────────────────────────────────────────────────────────
# Escritura
# ──────────────────────────────────────────────────────────────────────

def apply_rows(url: str, key: str, fecha: str, rows: list[dict], umbral: int) -> None:
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }
    imp = requests.post(
        f"{url}/rest/v1/importaciones_referencia",
        headers=headers,
        json={
            "fuente": "similares",
            "tipo": "venta",
            "fecha_lista": fecha,
            "archivo": "job_vtex_similares",
            "filas_ok": len(rows),
            "notas": f"sync_precios_similares.py (match verificado, umbral {umbral})",
        },
        timeout=60,
    )
    imp.raise_for_status()
    import_id = imp.json()[0]["id"]

    payload = []
    for r in rows:
        # Las piezas del empaque del competidor se guardan explícitas: sin ellas no se
        # puede comparar precio por unidad y hay que volver a adivinarlas del nombre.
        piezas = extraer_cantidad(r["nombre_fuente"] or "")
        detalle = f"termino:{r['termino']} | {r['razones']}"
        if piezas:
            detalle = f"piezas_fuente:{piezas} | {detalle}"
        payload.append({
            "producto_id": r["producto_id"],
            "fuente": "similares",
            "tipo": "venta",
            "precio": round(r["precio"], 2),
            "fecha": fecha,
            "nombre_fuente": r["nombre_fuente"],
            "sku_externo": r.get("vtex_id") or None,
            "confianza": r["confianza"],
            "origen": "job_vtex",
            "import_id": import_id,
            "notas": detalle[:500],
        })
    for i in range(0, len(payload), 100):
        r = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=headers,
            json=payload[i: i + 100],
            timeout=120,
        )
        r.raise_for_status()
    print(f"Guardadas {len(payload)} referencias (import_id={import_id}).")


def recalibrar(url: str, key: str, umbral: int, aplicar: bool) -> None:
    """
    Re-evalúa la confianza de las filas ya guardadas usando `nombre_fuente`,
    sin volver a pegarle a VTEX. Sirve cuando se ajusta el scoring y no queremos
    que queden filas viejas con una confianza que ya no corresponde.
    """
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    productos = {p["id"]: p for p in fetch_productos(url, key)}

    filas: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 999}"}
        r = requests.get(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=h,
            params={"select": "id,producto_id,confianza,nombre_fuente,notas", "origen": "eq.job_vtex"},
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        filas.extend(batch)
        if len(batch) < 1000:
            break
        offset += 1000

    cambios: list[tuple[dict, int, str]] = []
    for f in filas:
        p = productos.get(f["producto_id"])
        if not p or not f.get("nombre_fuente"):
            continue
        nueva, razones = evaluar_candidato(p, f["nombre_fuente"])
        if nueva != f["confianza"]:
            cambios.append((f, nueva, "; ".join(razones)))

    bajan = [c for c in cambios if c[1] < c[0]["confianza"]]
    caen = [c for c in cambios if c[1] < umbral]
    print(f"Filas job_vtex revisadas: {len(filas)}")
    print(f"  cambian de confianza: {len(cambios)} (bajan {len(bajan)})")
    print(f"  quedan por debajo del umbral {umbral}: {len(caen)}")
    for f, nueva, _ in sorted(cambios, key=lambda c: c[1] - c[0]["confianza"])[:15]:
        p = productos[f["producto_id"]]
        print(f"    {p.get('sku')}: {f['confianza']} → {nueva}  ({f['nombre_fuente'][:48]})")

    if not aplicar:
        print("Usa --apply para escribir la recalibración.")
        return
    if not cambios:
        print("Nada que recalibrar.")
        return

    wh = {**headers, "Content-Type": "application/json", "Prefer": "return=minimal"}
    hechos = 0
    for f, nueva, razones in cambios:
        base = (f.get("notas") or "").split(" | ")[0]
        r = requests.patch(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=wh,
            params={"id": f"eq.{f['id']}"},
            json={"confianza": nueva, "notas": f"{base} | {razones}"[:500]},
            timeout=60,
        )
        if r.status_code in (401, 403):
            # La llave anon tiene política de UPDATE pero no el GRANT correspondiente.
            ruta = escribir_sql_recalibracion(cambios)
            print(f"Sin permiso de UPDATE con la llave anon. SQL generado en:\n  {ruta}")
            return
        r.raise_for_status()
        hechos += 1
    print(f"Recalibradas {hechos} filas.")


def escribir_sql_recalibracion(cambios: list[tuple[dict, int, str]]) -> Path:
    destino = ROOT / "sql" / "pricing" / "generated" / f"recalibrar_confianza_{date.today().isoformat()}.sql"
    destino.parent.mkdir(parents=True, exist_ok=True)

    def q(s: str) -> str:
        return "'" + str(s).replace("'", "''") + "'"

    lineas = [
        "-- Recalibración de confianza de referencias Similares (origen job_vtex).",
        "-- Generado por scripts/sync_precios_similares.py --recalibrar",
        "-- La confianza se recalcula comparando nombre_fuente contra el catálogo:",
        "-- concentración, cantidad por caja, forma farmacéutica y principios activos.",
        "",
        "BEGIN;",
        "",
    ]
    for f, nueva, razones in cambios:
        base = (f.get("notas") or "").split(" | ")[0]
        notas = f"{base} | {razones}"[:500]
        lineas.append(
            f"UPDATE public.producto_precios_referencia "
            f"SET confianza = {nueva}, notas = {q(notas)} WHERE id = {f['id']};"
        )
    lineas += [
        "",
        "-- Permite que el script recalibre por REST en el futuro (la política RLS ya existe,",
        "-- lo que faltaba era el GRANT de UPDATE a la llave anon).",
        "GRANT UPDATE ON public.producto_precios_referencia TO anon, authenticated;",
        "",
        "COMMIT;",
        "",
    ]
    destino.write_text("\n".join(lineas), encoding="utf-8")
    return destino


def escribir_csv(fecha: str, aceptados: list[dict], rechazados: list[dict]) -> None:
    REPORTE_DIR.mkdir(parents=True, exist_ok=True)
    ruta_ok = REPORTE_DIR / f"similares_match_{fecha}.csv"
    with ruta_ok.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["sku", "nombre", "costo", "precio_fc", "precio_similares",
                    "confianza", "nombre_similares", "termino", "razones"])
        for r in sorted(aceptados, key=lambda x: -x["confianza"]):
            w.writerow([r["sku"], r["nombre"], r.get("costo"), r.get("precio_fc"),
                        round(r["precio"], 2), r["confianza"], r["nombre_fuente"],
                        r["termino"], r["razones"]])
    ruta_no = REPORTE_DIR / f"similares_sin_match_{fecha}.csv"
    with ruta_no.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["sku", "nombre", "principio_activo", "costo", "precio_fc",
                    "mejor_confianza", "mejor_candidato", "motivo"])
        for r in rechazados:
            w.writerow([r["sku"], r["nombre"], r.get("principio_activo"), r.get("costo"),
                        r.get("precio_fc"), r.get("confianza"), r.get("nombre_fuente"),
                        r.get("motivo")])
    print(f"CSV: {ruta_ok}")
    print(f"CSV: {ruta_no}")


# ──────────────────────────────────────────────────────────────────────

def tomar_lock() -> "object":
    """
    Candado exclusivo: dos corridas simultáneas con --apply insertan la misma
    lista dos veces, porque ambas leen el estado antes de que la otra escriba.
    """
    import fcntl

    fh = LOCK_PATH.open("w")
    try:
        fcntl.flock(fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(f"Ya hay otra corrida en curso ({LOCK_PATH}). Espera a que termine.")
    fh.write(str(os.getpid()))
    fh.flush()
    return fh


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0, help="Máx productos (0=todos)")
    parser.add_argument("--delay", type=float, default=0.5, help="Segundos entre requests VTEX nuevos")
    parser.add_argument("--umbral", type=int, default=UMBRAL_DEFAULT,
                        help=f"Confianza mínima para guardar (default {UMBRAL_DEFAULT})")
    parser.add_argument("--csv", action="store_true", help="Escribir CSV de revisión")
    parser.add_argument("--solo-verificables", action="store_true",
                        help="Consultar solo productos cuya concentracion se puede leer; "
                             "sin ese dato el match se rechaza por regla y la consulta se "
                             "desperdicia")
    parser.add_argument("--recalibrar", action="store_true",
                        help="Re-evaluar confianza de filas ya guardadas (sin consultar VTEX)")
    parser.add_argument("--solo-sin-venta", action="store_true",
                        help="Omitir productos que ya tienen Similares, Del Ahorro u Otros")
    parser.add_argument("--canal", choices=["todos", "medicamento"], default="todos",
                        help="medicamento: no consulta higiene, abarrotes ni dermo de consumo")
    args = parser.parse_args()

    env = cargar_env()
    sb_url = env.get("REACT_APP_SUPABASE_URL", "")
    sb_key = env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not sb_url or not sb_key:
        sys.exit("Faltan credenciales Supabase en .env")

    lock = tomar_lock() if args.apply else None  # noqa: F841 — vive hasta el fin del proceso

    if args.recalibrar:
        recalibrar(sb_url, sb_key, args.umbral, args.apply)
        return

    fecha = date.today().isoformat()
    productos = fetch_productos(sb_url, sb_key)

    if args.apply:
        ya = productos_ya_sincronizados_hoy(sb_url, sb_key, fecha)
        if ya:
            antes = len(productos)
            productos = [p for p in productos if p["id"] not in ya]
            print(f"Omitidos {antes - len(productos)} productos ya sincronizados hoy.")

    if args.solo_verificables:
        antes = len(productos)
        productos = [p for p in productos if concentracion_legible(p)]
        print(f"Omitidos {antes - len(productos)} productos sin concentracion legible "
              f"(se rechazarian por regla).")

    if args.solo_sin_venta:
        ya_venta = productos_con_ref_venta(sb_url, sb_key)
        antes = len(productos)
        productos = [p for p in productos if p["id"] not in ya_venta]
        print(f"Omitidos {antes - len(productos)} que ya tienen precio de venta.")

    if args.canal == "medicamento":
        antes = len(productos)
        productos = [p for p in productos if parece_canal_medicamento(p)]
        print(f"Omitidos {antes - len(productos)} fuera de canal medicamento "
              f"(higiene / abarrotes / dermo de consumo).")

    if args.limit:
        productos = productos[: args.limit]
    print(f"Productos a consultar: {len(productos)}  ·  umbral de confianza: {args.umbral}",
          flush=True)

    cache: dict[str, list[dict]] = {}
    aceptados: list[dict] = []
    rechazados: list[dict] = []

    for i, p in enumerate(productos, start=1):
        costo = p.get("costo")
        costo = float(costo) if costo not in (None, "") else None
        base = {
            "producto_id": p["id"],
            "sku": p.get("sku"),
            "nombre": p.get("nombre"),
            "principio_activo": p.get("principio_activo"),
            "costo": costo,
            "precio_fc": p.get("precio"),
        }

        m = mejor_match(p, cache, args.delay)
        if m is None:
            rechazados.append({**base, "confianza": 0, "nombre_fuente": "", "motivo": "sin resultados VTEX"})
            continue

        no_comparable = descalificado(m.get("razones_lista") or [])
        if no_comparable:
            rechazados.append({**base, **m, "motivo": f"no comparable: {no_comparable}"})
        elif m["confianza"] < args.umbral:
            rechazados.append({**base, **m, "motivo": f"confianza {m['confianza']} < {args.umbral}"})
        else:
            motivo_precio = validar_precio(m["precio"], costo)
            if motivo_precio:
                rechazados.append({**base, **m, "motivo": motivo_precio})
            else:
                aceptados.append({**base, **m})

        if i % 25 == 0 or i == len(productos):
            print(f"  {i}/{len(productos)} — aceptados {len(aceptados)} · descartados {len(rechazados)}",
                  flush=True)

    total = len(productos) or 1
    alta = [r for r in aceptados if r["confianza"] >= UMBRAL_ALTA]
    media = [r for r in aceptados if r["confianza"] < UMBRAL_ALTA]
    print("\n─── Resultado ───")
    print(f"Aceptados : {len(aceptados)}/{total} ({len(aceptados)/total:.1%})")
    print(f"  alta  (>={UMBRAL_ALTA}): {len(alta)}")
    if media:
        print(f"  media ({args.umbral}-{UMBRAL_ALTA - 1}): {len(media)}")
    print(f"Descartados: {len(rechazados)}")

    if args.csv:
        escribir_csv(fecha, aceptados, rechazados)

    if args.dry_run or not args.apply:
        if not args.dry_run:
            print("Usa --apply para guardar en Supabase")
        return
    if not aceptados:
        print("Nada que insertar.")
        return
    apply_rows(sb_url, sb_key, fecha, aceptados, args.umbral)


if __name__ == "__main__":
    main()
