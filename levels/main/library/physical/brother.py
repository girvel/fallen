from ecs import Entity

from levels.main.library.ais.brother_ai import BrotherAi
from src.engine.acting.damage import Health, Weapon, armor_kinds, damage_kinds
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.library.abstract.human import Human


class Brother(Human):
    character = 'M'
    color = ColorPair(blue)
    sex = "male"

    def __post_init__(self, **attributes):
        self.name = CompositeName(reserved_names["mike"], reserved_names["kinds"]["male"])

        self.health = Health(30, armor_kinds["Organic"])
        self.weapon = Weapon(4, damage_kinds["Slashing"])
        self.ai = BrotherAi()

        Entity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
