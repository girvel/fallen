import random

from src.engine.acting.damage import Health, DamageKind, ArmorKind, Weapon
from src.engine.assets import names
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.output.colors import ColorPair, cyan
from src.entities.abstract.human import Human
from src.entities.ais.dummy_ai import DummyAi
from src.lib.vector import map_grid
from src.systems.ai import Senses


class Soldier(Human):
    name = 'Soldier'
    character = 's'
    color = ColorPair(cyan)
    faction = Faction.Church

    def __post_init__(self):
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.name = random.choice(names["first"][self.sex])
        self.health = Health(40, ArmorKind.Leather)
        self.weapon = Weapon(5, DamageKind.Slashing)
        self.senses = Senses(16, 0, 0)
        self.ai = DummyAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 100

    def after_load(self, level):
        self.ai.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
