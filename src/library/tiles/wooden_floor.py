from ecs import DynamicEntity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow


class WoodenFloor(DynamicEntity):
    name = Name("дощатый пол")
    character = '_'
    color = ColorPair(yellow)
    layer = "tiles"
    boring_flag = None
