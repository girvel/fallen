from levels.main_01_introduction.assets.ais.brother_ai import BrotherAi
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Health, DamageSource
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory


class Brother(Humanoid):
    character = 'M'
    color = ColorPair(blue)
    sex = "male"

    def __post_init__(self):
        self.name = CompositeName(reserved_names["mike"], reserved_names["kinds"]["male"])

        self.health = Health(30, armor_kind.none)
        self.damage_source = DamageSource(4, damage_kind.slashing)
        self.ai = BrotherAi()

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
