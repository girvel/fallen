from src.engine.output.colors import ColorPair, white, black
from src.assets.physical.thick_wall import ThickWall as OldThickWall


class ThickWall(OldThickWall):
    color = ColorPair(black, white)
