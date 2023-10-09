from ecs import DynamicEntity

from src.engine.name import Name


class Hades(DynamicEntity):
    name = Name("hades")

    def __init__(self):
        self.entities_to_destroy = set()
