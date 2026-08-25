"""Interfaz común ProveedorAdapter — scrapers y cargadores CSV/EDI implementan esto."""

from __future__ import annotations

from abc import ABC, abstractmethod
from datetime import date
from pathlib import Path

from lib.pricing.io_csv import DIR_PROVEEDORES, escribir_csv, leer_csv
from lib.pricing.schema import nombre_archivo_fuente


class ProveedorAdapter(ABC):
    nombre: str = ""
    tipo_fuente: str = "mayorista"
    requiere_credenciales: bool = False

    def archivo_hoy(self, fecha: date | None = None) -> Path:
        return DIR_PROVEEDORES / nombre_archivo_fuente(self.nombre, fecha)

    def guardar(self, filas: list[dict], fecha: date | None = None) -> Path:
        return escribir_csv(self.archivo_hoy(fecha), filas)

    def cargar_csv(self, path: Path | None = None) -> list[dict]:
        p = path or self.archivo_hoy()
        if not p.exists():
            # último archivo de esta fuente
            cands = sorted(DIR_PROVEEDORES.glob(f"{self.nombre}_*.csv"))
            if not cands:
                return []
            p = cands[-1]
        return leer_csv(p)

    @abstractmethod
    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        """Devuelve filas normalizadas. Idempotente: si el CSV del día existe y no force, lo relee."""


class AdapterManualCSV(ProveedorAdapter):
    """Nadro / Marzam / Levic / etc.: no scrapea; espera un CSV/EDI en precios_proveedores."""

    requiere_credenciales = True
    tipo_fuente = "distribuidor_farma"
    columnas_alias: dict[str, str] = {}

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        return self.cargar_csv()
