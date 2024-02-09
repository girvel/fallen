from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.ai import Senses
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, red
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ais.dummy_ai import DummyAi
from src.lib.limited import Limited


class Enemy(Humanoid):
    character = "E"
    color = ColorPair(red, magenta)
    name = Name.auto("Враг")
    sex = "male"

    def __post_init__(self):
        self.health = Limited(10_001)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
