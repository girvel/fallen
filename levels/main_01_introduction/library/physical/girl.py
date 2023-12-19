from ecs import Entity

from src.engine.acting.damage import Health
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.library.abstract.humanoid import Humanoid


class Girl(Humanoid):
    name = CompositeName(reserved_names["morra"], reserved_names["wild"]["female"])

    character = "m"
    color = ColorPair(blue)
    sex = "female"

    def __post_init__(self):
        self.health = Health(10, "Organic")

    def after_creation(self):
        self.ai.composite[SpacialMemory].knows(self.level)
