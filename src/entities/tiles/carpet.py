from ecs import DynamicEntity

from src.engine.name import Name
from src.engine.output.colors import magenta, ColorPair


class Carpet(DynamicEntity):
    name = Name("Ковёр")
    character = '`'
    color = ColorPair(magenta)
    layer = "tiles"
