from ecs import DynamicEntity

from src.engine.naming.name import Name


class Hades(DynamicEntity):
    name = Name("Хейдс")

    def __init__(self):
        self.entities_to_destroy = set()
