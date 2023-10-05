from ecs import DynamicEntity

from src.engine.output.colors import ColorPair, blue


class LiquidWater(DynamicEntity):
    name = 'Water'
    character = '~'
    color = ColorPair(blue)
    liquid_height = 10
    layer = "tiles"
