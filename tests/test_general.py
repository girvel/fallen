from pathlib import Path

from src.assets.actions.no_action import NoAction
from src.assets.special.level import Level
from src.ecs import build_metasystem
from src.lib.vector.grid import grid_get


def test_build():
    ms, hades, genesis = build_metasystem(False)
    ms.update()


def test_loading_empty_level():
    ms, hades, genesis = build_metasystem(False)
    Level.create(Path('tests/levels/empty'), hades, genesis)
    ms.update()
    ms.update()


# TODO test uses Level() instead of Level.create(), fix it
def test_rails_run():
    ms, hades, genesis = build_metasystem(False)
    level = ms.add(Level(ms, Path('tests/levels/rails'), False, genesis))
    ms.update()

    wall = grid_get(level.grids["physical"], (0, 0))
    assert wall.do_rails_work
    assert wall.act == NoAction()
