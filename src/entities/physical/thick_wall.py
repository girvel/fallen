import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.tiles.ruins import Ruins


class ThickWall(DynamicEntity):
    name = Name("мощная стена")
    character = '#'
    color = ColorPair(yellow)
    solid_flag = None
    layer = "physical"

    def __init__(self, **attributes):
        self.health = Health(random.randrange(5000, 10001, 500), ArmorKind.Stone)
        super().__init__(**attributes)

    def on_death(self, hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(Ruins(p=self.p, level=self.level))
        return True
