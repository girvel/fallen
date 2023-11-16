from src.engine.acting.damage import Weapon, DamageKind, ArmorKind, Health
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.systems.ai import Senses


class Kaledeii(Human):
    name = Name("Каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __init__(self):
        self.health = Health(80, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.senses = Senses(24, 40, 0)
        self.ai = DummyAi()

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
