from src.library.actions.no_action import NoAction
from src.engine.rails.rails_base import RailsBase
from src.engine.rails.scene import Scene
from src.library.ais.dummy_ai import DummyAi
from src.lib.vector.grid import grid_get


class Rails(RailsBase):
    def __post_init__(self):
        self.characters = {}

    # TODO test more functionality (characters, tags, lists of characters)
    @Scene.new()
    class the_scene:
        def run(self, rails: "Rails"):
            wall = grid_get(rails.level.grids["physical"], (0, 0))
            wall.do_rails_work = True

            wall.ai = DummyAi()
            yield {wall: NoAction()}
