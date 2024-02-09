from levels.main_01_introduction.assets.ais.brother_ai import BrotherAi
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.items.engraved_cavalry_saber import EngravedCavalrySaber
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.lib.limited import Limited


class Brother(Humanoid):
    character = 'M'
    color = ColorPair(blue)
    sex = "male"

    def __post_init__(self):
        self.name = CompositeName(reserved_names["mike"], reserved_names["kinds"]["male"])

        self.health = Limited(31)
        self.damage_source = EngravedCavalrySaber()
        self.ai = BrotherAi()

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
