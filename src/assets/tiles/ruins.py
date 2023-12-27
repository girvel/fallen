from src.engine.language.name import Name
from src.assets.abstract.material import Material


class Ruins(Material):
    name = Name.auto("обломки")
    layer = "tiles"
    character = ":"

    boring_flag = None
