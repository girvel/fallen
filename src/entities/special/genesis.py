from ecs import DynamicEntity

from src.engine.name import Name


class Genesis(DynamicEntity):
    name = Name("Генезис")

    def __init__(self):
        self.entities_to_create = set()
