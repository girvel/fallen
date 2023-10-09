import random

from src.engine.acting.damage import Health, DamageKind, ArmorKind, Weapon
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.output.colors import ColorPair, yellow
from src.entities.abstract.human import Human
from src.entities.ais.dummy_ai import DummyAi
from src.lib.vector import map_grid
from src.systems.ai import Senses


class LordBishop(Human):
    name = 'Лорд Натаниэль'
    sex = "male"
    character = 'B'
    color = ColorPair(yellow)
    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(40, ArmorKind.LightSteel)
        self.weapon = Weapon(7, DamageKind.Piercing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 1000

    def after_load(self, level):
        self.ai.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
