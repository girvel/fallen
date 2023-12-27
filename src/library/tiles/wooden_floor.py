from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.material import Material


class WoodenFloor(Material):
    name = Name("дощатый пол")  # TODO cases
    character = '_'
    color = ColorPair(yellow)
    layer = "tiles"
    boring_flag = None
