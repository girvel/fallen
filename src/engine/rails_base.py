from ecs import OwnedEntity


class RailsBase(OwnedEntity):
    name = "Rails"
    rails_flag = None

    def __init__(self, level):
        self.player = level.player

    def options(self, options):
        self.player.ai.memory.options = options
        yield

    def start_cutscene(self):
        yield from []
        self.player.ai.memory.in_cutscene = True

    def end_cutscene(self):
        yield
        self.player.ai.memory.in_cutscene = False
