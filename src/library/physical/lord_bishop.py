from src.engine.acting.damage import Health, Weapon
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.humanoid import Humanoid
from src.library.ais.dummy_ai import DummyAi
from src.engine.ai import Senses


class LordBishop(Humanoid):
    name = Name("лорд-епископ")
    sex = "male"
    character = 'N'
    color = ColorPair(yellow)
    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(40, armor_kind.light_steel)
        self.weapon = Weapon(7, damage_kind.piercing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 1000

    def after_creation(self):
        self.ai.composite[SpacialMemory].knows(self.level)
