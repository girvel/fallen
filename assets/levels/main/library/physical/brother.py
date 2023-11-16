from ecs import DynamicEntity

from assets.levels.main.library.ais.brother_ai import BrotherAi
from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
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
        self.name = CompositeName(reserved_names.mike, reserved_names.kinds["male"])

        self.health = Health(30, ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.ai = BrotherAi()

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
