from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.assets.abstract.material import Material
from src.lib.limited import Limited


class Throne(Material):
    name = Name.auto("трон")
    layer = "physical"
    character = 't'
    color = ColorPair(yellow)

    def __post_init__(self):
        self.health = Limited(701)
