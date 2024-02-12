import random

from src.assets.abstract.material import Material
from src.assets.tiles.ruins import Ruins
from src.components import Genesis, Hades
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.lib.limited import Limited


class ThickWall(Material):
    name = Name.auto("стена")
    character = '#'
    color = ColorPair(yellow)
    layer = "physical"

    solid_flag = None
    boring_flag = None
    hard_flag = None

    def __post_init__(self):
        self.health = Limited(random.randrange(5000, 10001, 500))

    def on_destruction(self, _hades: Hades, genesis: Genesis):
        genesis.push(Ruins(p=self.p, level=self.level))
