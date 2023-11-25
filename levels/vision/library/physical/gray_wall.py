from src.engine.output.colors import ColorPair, white
from src.library.physical.thick_wall import ThickWall


class GrayWall(ThickWall):
    color = ColorPair(white)