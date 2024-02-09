from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import yellow, ColorPair
from src.assets.abstract.material import Material
from src.lib.limited import Limited


class Table(Material):
    name = Name.auto("стол")
    character = '"'
    color = ColorPair(yellow)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Limited(36)
