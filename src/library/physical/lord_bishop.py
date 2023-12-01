from src.engine.acting.damage import Health, DamageKind, ArmorKind, Weapon
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.systems.ai import Senses


class LordBishop(Human):
    name = Name("лорд-епископ")
    sex = "male"
    character = 'N'
    color = ColorPair(yellow)
    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(40, ArmorKind.LightSteel)
        self.weapon = Weapon(7, DamageKind.Piercing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 1000

    def after_load(self, level):  # TODO isn't the level already known at this point?
        self.ai.composite[SpacialMemory].knows(level)
