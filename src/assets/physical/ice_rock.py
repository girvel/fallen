from src.assets.abstract.material import Material
from src.engine.language.name import Name
from src.engine.output.colors import white, blue, ColorPair
from src.lib.limited import Limited


class IceRock(Material):
    name = Name("ледяная глыба")  # TODO cases
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Limited(1001)
