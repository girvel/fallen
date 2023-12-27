from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.material import Material


class Bed(Material):
    name = Name.auto("кровать")
    character = 'B'
    color = ColorPair(cyan)
    layer = "tiles"
