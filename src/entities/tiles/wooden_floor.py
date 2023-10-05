from ecs import DynamicEntity

from src.engine.output.colors import ColorPair, yellow


class WoodenFloor(DynamicEntity):
    name = 'Wooden floor'
    character = '_'
    color = ColorPair(yellow)
    layer = "tiles"
