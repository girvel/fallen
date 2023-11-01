from ecs import DynamicEntity

from src.engine.acting.damage import Health
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.naming.library import reserved_names
from src.engine.naming.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.entities.abstract.human import Human


class Girl(Human):
    name = CompositeName(reserved_names.morra, reserved_names.wild_female)

    character = "m"
    color = ColorPair(blue)
    sex = "female"

    def __post_init__(self, **attributes):
        self.health = Health(10, "Organic")

        DynamicEntity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
