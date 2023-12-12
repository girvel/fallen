from ecs import Entity

from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, black
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi


class OldSarr(Human):
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

    def __post_init__(self, **attributes):
        self.ai = DummyAi()
        self.health = Health(1_000, armor_kind.mennar)

        Entity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
