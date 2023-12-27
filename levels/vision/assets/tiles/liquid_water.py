from src.engine.output.colors import ColorPair, blue
from src.assets.physical.water import Water


class LiquidWater(Water):
    color = ColorPair(blue)
    layer = "tiles"
    boring_flag = None

    def __post_init__(self, *, liquid_height=25):
        self.liquid_height = liquid_height
