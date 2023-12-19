from ecs import Entity

from src.engine.language.name import Name


class Hades(Entity):
    name = Name("Хейдс")

    def __init__(self):
        self._entities_to_destroy = []

    def push(self, entity):
        self._entities_to_destroy.append(entity)
        return entity
