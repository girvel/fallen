from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.lib.limited import Limited


class Girl(Humanoid):
    name = CompositeName(reserved_names["morra"], reserved_names["wild"]["female"])

    character = "m"
    color = ColorPair(blue)
    sex = "female"

    def __post_init__(self):
        self.health = Limited(11)

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
