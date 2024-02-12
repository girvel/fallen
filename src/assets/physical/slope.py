import random

from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair
from src.assets.abstract.material import Material
from src.components import Genesis, Hades
from src.assets.tiles.ruins import Ruins
from src.lib.limited import Limited


class Slope(Material):
    name = Name.auto("склон")
    character = "%"
    color = ColorPair()
    layer = "physical"

    boring_flag = None
    hard_flag = None

    def __post_init__(self):
        self.health = Limited(random.randrange(2501, 6002))

    def on_destruction(self, _hades: Hades, genesis: Genesis):
        genesis.push(Ruins(p=self.p, level=self.level))
