from ecs import DynamicEntity

from assets.levels.main.entities.ais.brother_ai import BrotherAi
from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.assets import reserved_names
from src.engine.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.entities.abstract.human import Human
from src.lib.vector import map_grid
from src.systems.ai import Senses


class Brother(Human):
    character = 'M'
    color = ColorPair(blue)
    sex = "male"

    def __post_init__(self, **attributes):
        self.name = CompositeName(reserved_names.mike, reserved_names.kinds_male)

        self.health = Health(30, ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.senses = Senses(12, 0, 0)
        self.ai = BrotherAi()

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory][level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
