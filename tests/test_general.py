from pathlib import Path

from src.library.actions.no_action import NoAction
from src.library.special.level import Level
from src.init_ecs import build_metasystem
from src.lib.vector import grid_get


def test_build():
    ms, genesis = build_metasystem(False)
    ms.update()


def test_loading_empty_level():
    ms, genesis = build_metasystem(False)
    ms.add(Level(ms, Path('tests/levels/empty'), False, genesis))
    ms.update()


def test_rails_run():
    ms, genesis = build_metasystem(False)
    level = ms.add(Level(ms, Path('tests/levels/rails'), False, genesis))
    ms.update()

    wall = grid_get(level.grids.physical, (0, 0))
    assert wall.do_rails_work
    assert wall.act == NoAction()
