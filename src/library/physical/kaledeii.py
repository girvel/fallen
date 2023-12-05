from src.engine.acting.damage import Weapon, damage_kinds, armor_kinds, Health
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.engine.ai import Senses


class Kaledeii(Human):
    name = Name("Каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(80, armor_kinds["Steel"])
        self.weapon = Weapon(15, damage_kinds["Slashing"])
        self.senses = Senses(24, 40, 0)
        self.ai = DummyAi()

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
