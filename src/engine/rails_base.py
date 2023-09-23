from ecs import OwnedEntity

from src.engine.acting.actions.say import Say


class RailsBase(OwnedEntity):
    rails_flag = None

    def __init__(self, level):
        self.player = level.player

    def player_say(self, line):
        yield {self.player: Say(line)}
        yield
