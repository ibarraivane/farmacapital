#!/usr/bin/env python3
"""Compat: los iconos salen del logotipo oficial, no de una cruz inventada."""
from pathlib import Path
import runpy

runpy.run_path(str(Path(__file__).with_name("generate_app_icons_oficiales.py")), run_name="__main__")
