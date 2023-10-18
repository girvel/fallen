from ecs import DynamicEntity

from src.engine.naming.name import Name


class Zone(DynamicEntity):
    def __init__(self, name, center, attractiveness):
        self.name = Name(name)
        self.center = tuple(center)  # TODO figure out how to do this at loading markup
        self.attractiveness = attractiveness
