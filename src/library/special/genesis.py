from ecs import Entity

from src.engine.language.name import Name


class Genesis(Entity):
    name = Name("Генезис")

    def __init__(self):
        self._entities_to_create = []

    def push(self, entity):
        self._entities_to_create.append(entity)
        return entity
