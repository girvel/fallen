from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import white, blue, ColorPair
from src.assets.abstract.material import Material


class IceRock(Material):
    name = Name("ледяная глыба")  # TODO cases
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(1000, armor_kind.ice)
