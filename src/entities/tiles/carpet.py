from ecs import DynamicEntity

from src.engine.output.colors import magenta, ColorPair


class Carpet(DynamicEntity):
    name = 'Carpet'
    character = '`'
    color = ColorPair(magenta)
    layer = "tiles"
