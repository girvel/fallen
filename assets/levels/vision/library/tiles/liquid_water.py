from src.engine.output.colors import ColorPair, blue
from src.library.physical.water import Water


class LiquidWater(Water):
    color = ColorPair(blue)
    liquid_height = 25
    layer = "tiles"
    boring_flag = None
