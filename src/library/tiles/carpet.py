from src.engine.language.name import Name
from src.engine.output.colors import magenta, ColorPair
from src.library.abstract.material import Material


class Carpet(Material):
    name = Name.auto("ковёр")
    character = '`'
    color = ColorPair(magenta)
    layer = "tiles"

    boring_flag = None
