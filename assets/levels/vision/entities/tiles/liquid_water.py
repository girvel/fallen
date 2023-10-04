from ecs import DynamicEntity

from src.engine.output.colors import Colors


class LiquidWater(DynamicEntity):
    name = 'Water'
    character = '~'
    color = Colors.Blue
    liquid_height = 10
    layer = "tiles"
