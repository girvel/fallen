from ecs import Entity

from src.engine.language.name import Name


class Hades(Entity):
    name = Name("Хейдс")

    def __init__(self):
        self.entities_to_destroy = set()
