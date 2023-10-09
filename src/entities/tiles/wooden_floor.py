from ecs import DynamicEntity

from src.engine.name import Name
from src.engine.output.colors import ColorPair, yellow


class WoodenFloor(DynamicEntity):
    name = Name("Wooden floor")
    character = '_'
    color = ColorPair(yellow)
    layer = "tiles"
