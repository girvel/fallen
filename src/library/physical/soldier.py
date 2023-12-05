import random

from src.engine.acting.damage import Health, damage_kinds, armor_kinds, Weapon
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.library import random_composite_name
from src.engine.attitude.implementation import Faction, common_attitude, Constants
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.engine.ai import Senses


class Soldier(Human):
    character = 's'
    color = ColorPair(cyan)
    faction = Faction.Church

    def __post_init__(self):
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.name = random_composite_name(self.sex)
        self.health = Health(40, armor_kinds["Leather"])
        self.weapon = Weapon(5, damage_kinds["Slashing"])
        self.senses = Senses(16, 0, 0)
        self.ai = DummyAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = Constants.Normal

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
