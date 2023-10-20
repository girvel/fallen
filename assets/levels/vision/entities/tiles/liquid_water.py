from src.engine.output.colors import ColorPair, blue
from src.entities.physical.water import Water


class LiquidWater(Water):
    color = ColorPair(blue)
    liquid_height = 10
    layer = "tiles"
    boring_flag = None
