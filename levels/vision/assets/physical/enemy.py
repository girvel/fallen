from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Health, DamageSource
from src.engine.ai import Senses
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, red
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ais.dummy_ai import DummyAi


class Enemy(Humanoid):
    character = "E"
    color = ColorPair(red, magenta)
    name = Name.auto("Враг")
    sex = "male"

    def __post_init__(self):
        self.health = Health(10_000, armor_kind.none)
        self.damage_source = DamageSource(24, damage_kind.slashing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
