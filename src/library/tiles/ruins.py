from src.engine.language.name import Name
from src.library.abstract.material import Material


class Ruins(Material):
    name = Name("обломки")
    layer = "tiles"
    character = ":"

    boring_flag = None
