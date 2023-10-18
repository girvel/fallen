from pathlib import Path

from src.entities.special.level import Level
from src.init_ecs import build_metasystem


def test_build():
    ms, genesis = build_metasystem(False)
    ms.update()


def test_loading_empty_level():
    ms, genesis = build_metasystem(False)
    ms.add(Level(ms, Path('tests/levels/empty'), False, genesis))
    ms.update()
