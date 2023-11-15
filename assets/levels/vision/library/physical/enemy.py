from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.naming.name import Name
from src.engine.output.colors import ColorPair, magenta, red
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.systems.ai import Senses


class Enemy(Human):
    character = "E"
    color = ColorPair(red, magenta)
    name = Name("Враг")
    sex = "male"

    def __init__(self, **attributes):
        self.health = Health(10_000, ArmorKind.Organic)
        self.weapon = Weapon(24, DamageKind.Slashing)
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
