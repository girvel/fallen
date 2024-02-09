
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green
from src.assets.abstract.material import Material
from src.lib.limited import Limited


class Bush(Material):
    name = Name.auto("куст")
    character = 'b'
    color = ColorPair(green)
    solid_flag = None
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Limited(21)
