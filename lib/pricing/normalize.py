"""Normalización de nombres, marcas, tamaños y tipos de producto."""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

try:
    from rapidfuzz import fuzz, process
except ImportError:  # pragma: no cover
    fuzz = None
    process = None

ROOT = Path(__file__).resolve().parents[2]
ABREVIATURAS_PATH = ROOT / "pricing" / "abreviaturas.yml"


def quitar_acentos(texto: str) -> str:
    s = unicodedata.normalize("NFKD", texto or "")
    return "".join(c for c in s if not unicodedata.combining(c))


def colapsar(texto: str) -> str:
    s = quitar_acentos(str(texto or "")).lower()
    s = s.replace("&", " ").replace("+", " ")
    s = re.sub(r"[^\w\s./-]", " ", s)
    # Conservar "/" para packs 4/40 y C/8; el resto de signos se colapsa.
    s = re.sub(r"[_\-.]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def cargar_abreviaturas(path: Path | None = None) -> dict:
    p = path or ABREVIATURAS_PATH
    if yaml is None or not p.exists():
        return {"abreviaturas": [], "tipos": {}}
    data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    pares = data.get("abreviaturas") or []
    pares = sorted(pares, key=lambda x: len(str(x.get("de", ""))), reverse=True)
    return {"abreviaturas": pares, "tipos": data.get("tipos") or {}}


_CACHE_ABREV: dict | None = None


def _abrev() -> dict:
    global _CACHE_ABREV
    if _CACHE_ABREV is None:
        _CACHE_ABREV = cargar_abreviaturas()
    return _CACHE_ABREV


def expandir_abreviaturas(texto: str, dicc: dict | None = None) -> str:
    """Expande jbn→jabon, sh→shampoo, etc. Solo tokens / frases completas."""
    dicc = dicc or _abrev()
    s = colapsar(texto)
    for par in dicc.get("abreviaturas") or []:
        de = colapsar(par.get("de", ""))
        a = colapsar(par.get("a", ""))
        if not de or not a:
            continue
        s = re.sub(rf"(?<!\w){re.escape(de)}(?!\w)", a, s)
    return colapsar(s)


@dataclass(frozen=True)
class Tamano:
    cantidad: float
    unidad: str  # g | ml | pza
    empaque_unidades: int = 1  # cuántas unidades de consumo vienen en la caja
    crudo: str = ""

    @property
    def normalizado(self) -> tuple[float, str]:
        return (self.cantidad, self.unidad)

    def piezas_totales(self) -> float:
        return self.empaque_unidades * (self.cantidad if self.unidad == "pza" else 1)


# Más específicos primero: ml antes que L, gr antes que g, kg, etc.
_PATRONES_TAMANO: list[tuple[re.Pattern, str, float]] = [
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*(?:mls?|mililitros?)\b", re.I), "ml", 1),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*m\s*l\b", re.I), "ml", 1),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*(?:lts?|litros?)\b", re.I), "ml", 1000),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*l\b", re.I), "ml", 1000),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*(?:kgs?|kilos?)\b", re.I), "g", 1000),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*(?:grs?|gramos?)\b", re.I), "g", 1),
    (re.compile(r"(\d+(?:[.,]\d+)?)\s*g\b", re.I), "g", 1),
]

_RE_PACK_NM = re.compile(
    r"(\d+)\s*/\s*(\d+)\s*(?:pzas?|piezas?|pz|uds?|unidades?)?\b", re.I
)
_RE_CAJA_CON = re.compile(
    r"caja\s+con\s+(\d+)\s*(?:pzas?|piezas?|pz|bolsas?|barras?|frascos?|botellas?)?",
    re.I,
)
_RE_C_SLASH = re.compile(r"\bc\s*/\s*(\d+)\b", re.I)
_RE_PZAS = re.compile(r"(\d+)\s*(?:pzas?|piezas?|pz)\b", re.I)


def _num(raw: str) -> float:
    return float(raw.replace(",", "."))


def extraer_tamano(texto: str) -> Tamano | None:
    """Extrae tamaño de consumo y, si existe, el empaque (N/M, caja con N).

    1 L y 1000 ML colisionan en 1000 ml.
    '4/40 Pz' → 40 pza de consumo, 4 unidades de empaque (160 piezas sueltas).
    """
    s = colapsar(texto)
    if not s:
        return None

    empaque = 1
    m_nm = _RE_PACK_NM.search(s)
    if m_nm:
        empaque = int(m_nm.group(1))
        inner = int(m_nm.group(2))
        resto = s[: m_nm.start()] + " " + s[m_nm.end() :]
        for pat, unidad, factor in _PATRONES_TAMANO:
            m = pat.search(resto)
            if m:
                return Tamano(_num(m.group(1)) * factor, unidad, empaque, m.group(0))
        return Tamano(float(inner), "pza", empaque, m_nm.group(0))

    m_caja = _RE_CAJA_CON.search(s)
    if m_caja:
        empaque = int(m_caja.group(1))

    for pat, unidad, factor in _PATRONES_TAMANO:
        m = pat.search(s)
        if m:
            return Tamano(_num(m.group(1)) * factor, unidad, empaque, m.group(0))

    m_c = _RE_C_SLASH.search(s)
    if m_c:
        return Tamano(float(m_c.group(1)), "pza", empaque, m_c.group(0))

    m_pz = _RE_PZAS.search(s)
    if m_pz:
        return Tamano(float(m_pz.group(1)), "pza", empaque, m_pz.group(0))

    if empaque > 1:
        return Tamano(1.0, "pza", empaque, "caja")
    return None


def tamanos_equivalentes(a: Tamano | None, b: Tamano | None, tolerancia: float = 0.02) -> bool:
    if a is None or b is None:
        return False
    if a.unidad != b.unidad:
        return False
    if a.cantidad <= 0 or b.cantidad <= 0:
        return False
    mayor = max(a.cantidad, b.cantidad)
    return abs(a.cantidad - b.cantidad) / mayor <= tolerancia


def inferir_tipo(texto: str, dicc: dict | None = None) -> str:
    dicc = dicc or _abrev()
    s = expandir_abreviaturas(texto, dicc)
    for tipo, palabras in (dicc.get("tipos") or {}).items():
        for p in palabras:
            if re.search(rf"(?<!\w){re.escape(colapsar(p))}(?!\w)", s):
                return tipo
    return ""


def normalizar_nombre(texto: str, dicc: dict | None = None) -> str:
    return expandir_abreviaturas(texto, dicc)


def normalizar_marca(marca: str) -> str:
    return colapsar(marca)


def corregir_marca(
    marca_raw: str,
    catalogo_marcas: Iterable[str],
    umbral: int = 82,
) -> tuple[str, int]:
    """Fuzzy contra marcas del inventario (asexia → asepxia)."""
    cand = normalizar_marca(marca_raw)
    if not cand:
        return "", 0
    pool = [normalizar_marca(m) for m in catalogo_marcas if m]
    pool = [m for m in pool if m]
    if cand in pool:
        return cand, 100
    if not pool or process is None:
        return cand, 0
    best = process.extractOne(cand, pool, scorer=fuzz.ratio)
    if best is None:
        return cand, 0
    nombre, score, _ = best
    if score >= umbral:
        return nombre, int(score)
    return cand, int(score)


def precio_por_unidad_base(precio_unitario: float | None, tamano: Tamano | None) -> float | None:
    """MXN por 100 g, 100 ml o por pieza. Nunca precio de caja contra precio de caja."""
    if precio_unitario is None or precio_unitario <= 0:
        return None
    if tamano is None or tamano.cantidad <= 0:
        return float(precio_unitario)
    if tamano.unidad == "pza":
        # precio_unitario ya es por unidad de consumo (barra, pack, frasco).
        # Si el tamaño es N piezas (pack de 40), el precio por pieza suelta es / N.
        if tamano.cantidad > 1:
            return float(precio_unitario) / tamano.cantidad
        return float(precio_unitario)
    # g / ml → por 100 unidades de base
    return float(precio_unitario) / tamano.cantidad * 100.0


def inferir_marca_de_nombre(nombre: str, catalogo_marcas: Iterable[str]) -> str:
    """Si el proveedor no trae marca, busca una marca del catálogo dentro del nombre."""
    n = colapsar(nombre)
    marcas = sorted({normalizar_marca(m) for m in catalogo_marcas if m}, key=len, reverse=True)
    for m in marcas:
        if m and re.search(rf"(?<!\w){re.escape(m)}(?!\w)", n):
            return m
    return ""
