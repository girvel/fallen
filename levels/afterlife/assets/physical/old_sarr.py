from src.engine.acting import armor_kind

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, black
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ais.dummy_ai import DummyAi
from src.lib.limited import Limited


class OldSarr(Humanoid):
    name = Name({
        "им": "Старый Сарр",
        "ро": "Старого Сарра",
        "да": "Старому Сарру",
        "ви": "Старого Сарра",
        "тв": "Старым Сарром",
        "пр": "Старом Сарре",
    })

    character = 'S'
    color = ColorPair(black)
    sex = "male"

    def __post_init__(self):
        self.ai = DummyAi()
        self.health = Limited(1_001)

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
