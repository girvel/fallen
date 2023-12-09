from src.library.actions.no_action import NoAction
from src.engine.rails.rails_base import RailsBase, Scene
from src.library.ais.dummy_ai import DummyAi
from src.lib.vector.grid import grid_get


class Rails(RailsBase):
    @Scene.new()
    def the_scene(self, scene):
        wall = grid_get(self.level.grids["physical"], (0, 0))
        wall.do_rails_work = True

        wall.ai = DummyAi()
        yield {wall: NoAction()}
