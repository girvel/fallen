from src.engine.language.name import Name
from src.engine.output.colors import ColorPair
from src.library.abstract.material import Material


class Void(Material):
    name = Name.auto("пустота")
    character = ' '
    color = ColorPair()
    layer = "physical"

    boring_flag = None
