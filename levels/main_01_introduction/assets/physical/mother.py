from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.attitude.implementation import Relation
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ais.peasant_ai_legacy import PeasantAi
from src.assets.markup.house import House
from src.assets.physical.peasant import peasant_attitude
from src.assets.physical.player import Player
from src.lib.limited import Limited


class Mother(Humanoid):
    character = 'L'
    color = ColorPair(blue)
    sex = "female"
    name = CompositeName(reserved_names["lilia"], reserved_names["kinds"]["female"])

    house: House

    def __post_init__(self):
        self.health = Limited(51)
        self.ai = PeasantAi()
        self.attitude = peasant_attitude()
        self.house = None

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
        self.house = next(h for h in self.level.markup.houses if h.reserved_for == "kinds")
        self.attitude.relations[next(self.level.find(Player))] = Relation.Love
