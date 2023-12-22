from src.engine.acting import armor_kind
from src.engine.acting.damage import Health
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, black
from src.library.abstract.humanoid import Humanoid
from src.library.ai_modules.spacial_memory import PathMemory
from src.library.ais.dummy_ai import DummyAi


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
        self.health = Health(1_000, armor_kind.mennar)

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
