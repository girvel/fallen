import random

from src.engine.acting import armor_kind
from src.engine.acting.damage import Health
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair
from src.library.abstract.material import Material
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.library.tiles.ruins import Ruins


class Slope(Material):
    name = Name.auto("склон")
    character = "%"
    color = ColorPair()
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(random.randrange(2500, 6000), armor_kind.stone)

    def on_destruction(self, _hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(Ruins(p=self.p, level=self.level))
