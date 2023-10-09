from ecs import DynamicEntity

from src.engine.name import Name


class Ruins(DynamicEntity):
    name = Name("Ruins")
    layer = "tiles"
    character = ":"
