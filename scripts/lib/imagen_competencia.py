"""Rechazo de logo/placeholder de Del Ahorro al bajar fotos a catalogo-propia.

El CDN Fahorro a veces responde un PNG 500×500 (6334 bytes, MD5 fijo) con la
letra «A» rosa cuando el EAN no tiene packshot. Nunca guardar eso.
"""
from __future__ import annotations

import hashlib
import re
from urllib.parse import urlparse

PLACEHOLDER_FAHORRO_MD5 = "59370f17d7cac03761209f4b0cf46374"
PLACEHOLDER_FAHORRO_BYTES = 6334

_HOST_FAHORRO = re.compile(r"(^|\.)fahorro\.com$", re.I)


def es_url_imagen_competencia(url: str) -> bool:
    raw = (url or "").strip()
    if not raw.lower().startswith(("http://", "https://")):
        return False
    try:
        host = urlparse(raw).hostname or ""
    except Exception:  # noqa: BLE001
        return False
    return bool(_HOST_FAHORRO.search(host))


def es_placeholder_imagen_competencia(
    blob: bytes | None = None,
    *,
    width: int | None = None,
    height: int | None = None,
    md5: str | None = None,
) -> bool:
    digest = (md5 or "").lower()
    if digest and digest == PLACEHOLDER_FAHORRO_MD5:
        return True
    if blob is not None:
        if len(blob) == PLACEHOLDER_FAHORRO_BYTES:
            return True
        if hashlib.md5(blob).hexdigest() == PLACEHOLDER_FAHORRO_MD5:
            return True
        if width == 500 and height == 500 and 0 < len(blob) < 10_000:
            return True
    elif width == 500 and height == 500:
        return True
    return False


def mensaje_rechazo_imagen_competencia() -> str:
    return (
        "Imagen rechazada: logo/placeholder de Del Ahorro (Fahorro). "
        "Usa packshot del producto o deja sin foto."
    )
