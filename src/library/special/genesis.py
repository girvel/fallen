from ecs import Entity

from src.engine.language.name import Name


class Genesis(Entity):
    name = Name("Генезис")

    def __init__(self):
        self.entities_to_create = set()
