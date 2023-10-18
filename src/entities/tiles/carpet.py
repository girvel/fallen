from ecs import DynamicEntity

from src.engine.naming.name import Name
from src.engine.output.colors import magenta, ColorPair


class Carpet(DynamicEntity):
    name = Name("ковёр")
    character = '`'
    color = ColorPair(magenta)
    layer = "tiles"
