from ecs import OwnedEntity

from src.lib.vector import floordiv2, sub2


class RailsBase(OwnedEntity):
    name = "Rails"
    rails_flag = None

    def __init__(self, level):
        self.player = level.player

    def options(self, options):
        yield  # TODO should this be needed? Investigate.
        self.player.ai.memory.options = options
        yield

    def start_cutscene(self):
        self.player.ai.memory.in_cutscene = True
        yield
        self.player.ai.rerender()

    def end_cutscene(self):
        yield
        self.player.ai.memory.in_cutscene = False

    def center_camera(self):
        h, w = self.player.ai.output.game._window.getmaxyx()
        self.player.ai.output.game.virtual_p = sub2(self.player.p, floordiv2((w, h), 2))
        yield
