from src.engine.acting.damage import Health, armor_kinds
from src.engine.language.name import Name
from src.engine.output.colors import white, blue, ColorPair
from src.library.abstract.material import Material


class IceRock(Material):
    name = Name("ледяная глыба")
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(1000, armor_kinds["Ice"])
