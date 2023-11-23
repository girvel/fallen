from ecs import DynamicEntity

from assets.levels.main.library.ais.brother_ai import BrotherAi
from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName, Name
from src.engine.output.colors import ColorPair, blue, black
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
        self.health = Health(1_000, ArmorKind.Menith)

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
