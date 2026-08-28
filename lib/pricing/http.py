"""HTTP con rate-limit ~1 req/s, backoff, User-Agent identificable y caché cruda."""

from __future__ import annotations

import json
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen

USER_AGENT = (
    "FarmaCapitalPricingBot/1.0 (+https://farmacapital.mx) AppleWebKit/537.36"
)
SLEEP_S = 1.05
MAX_REINTENTOS = 4


class HttpError(RuntimeError):
    pass


def _headers(extra: dict | None = None) -> dict:
    h = {
        "User-Agent": USER_AGENT,
        "Accept": "application/json, text/html;q=0.9, */*;q=0.8",
        "Accept-Language": "es-MX,es;q=0.9",
    }
    if extra:
        h.update(extra)
    return h


def ruta_cache(root: Path, fuente: str, fecha: str, nombre: str) -> Path:
    d = root / "pricing" / "importados" / fuente / fecha
    d.mkdir(parents=True, exist_ok=True)
    return d / nombre


def leer_cache(path: Path) -> str | None:
    if path.exists():
        return path.read_text(encoding="utf-8")
    return None


def escribir_cache(path: Path, cuerpo: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(cuerpo, encoding="utf-8")


def fetch(
    url: str,
    *,
    cache_path: Path | None = None,
    usar_cache: bool = True,
    timeout: int = 40,
    extra_headers: dict | None = None,
) -> str:
    if usar_cache and cache_path is not None:
        cached = leer_cache(cache_path)
        if cached is not None:
            return cached

    ultimo: Exception | None = None
    for intento in range(MAX_REINTENTOS):
        try:
            req = Request(url, headers=_headers(extra_headers))
            with urlopen(req, timeout=timeout) as resp:
                raw = resp.read()
            cuerpo = raw.decode("utf-8", "replace")
            if cache_path is not None:
                escribir_cache(cache_path, cuerpo)
            time.sleep(SLEEP_S)
            return cuerpo
        except HTTPError as e:
            ultimo = e
            if e.code in (429, 500, 502, 503, 504) and intento < MAX_REINTENTOS - 1:
                time.sleep(SLEEP_S * (2 ** intento))
                continue
            raise HttpError(f"{e.code} {url}") from e
        except URLError as e:
            ultimo = e
            if intento < MAX_REINTENTOS - 1:
                time.sleep(SLEEP_S * (2 ** intento))
                continue
            raise HttpError(f"red {url}: {e}") from e
    raise HttpError(f"falló {url}: {ultimo}")


def fetch_json(url: str, **kwargs) -> object:
    cuerpo = fetch(url, **kwargs)
    return json.loads(cuerpo)


def host_ok_robots(url: str, robots_txt: str) -> bool:
    """Chequeo mínimo: si Disallow cubre el path exacto (User-agent: *)."""
    path = urlparse(url).path or "/"
    aplica = False
    for linea in robots_txt.splitlines():
        l = linea.strip()
        if l.lower().startswith("user-agent:"):
            ua = l.split(":", 1)[1].strip()
            aplica = ua == "*"
        elif aplica and l.lower().startswith("disallow:"):
            regla = l.split(":", 1)[1].strip()
            if regla and path.startswith(regla):
                return False
    return True
