from src.engine.acting.damage import Weapon, Health
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.humanoid import Humanoid
from src.library.ais.dummy_ai import DummyAi
from src.engine.ai import Senses


class Kaledeii(Humanoid):
    name = Name("Каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(80, armor_kind.steel)
        self.weapon = Weapon(15, damage_kind.slashing)
        self.senses = Senses(24, 40, 0)
        self.ai = DummyAi()

    def after_creation(self):
        self.ai.composite[SpacialMemory].knows(self.level)
