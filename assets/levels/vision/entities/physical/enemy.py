from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.name import Name
from src.engine.output.colors import ColorPair, magenta, red
from src.entities.abstract.human import Human
from src.entities.ais.dummy_ai import DummyAi
from src.lib.vector import map_grid
from src.systems.ai import Senses


class Enemy(Human):
    character = "E"
    color = ColorPair(red, magenta)
    name = Name("Враг")
    sex = "male"

    def __init__(self, **attributes):
        self.health = Health(10_000, ArmorKind.Organic)
        self.weapon = Weapon(24, DamageKind.Slashing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
