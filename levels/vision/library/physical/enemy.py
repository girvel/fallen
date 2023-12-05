from ecs import Entity

from src.engine.acting.damage import Health, Weapon, armor_kinds, damage_kinds
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, red
from src.library.abstract.human import Human
from src.library.ais.dummy_ai import DummyAi
from src.engine.ai import Senses


class Enemy(Human):
    character = "E"
    color = ColorPair(red, magenta)
    name = Name("Враг")
    sex = "male"

    def __init__(self, **attributes):
        self.health = Health(10_000, armor_kinds["Organic"])
        self.weapon = Weapon(24, damage_kinds["Slashing"])
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        Entity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
