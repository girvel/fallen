from ecs import DynamicEntity

from src.engine.language.name import Name


class Ruins(DynamicEntity):
    name = Name("обломки")
    layer = "tiles"
    character = ":"
