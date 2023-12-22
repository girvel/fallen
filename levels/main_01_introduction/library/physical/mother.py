from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Health, Weapon
from src.engine.attitude.implementation import Relation
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.library.abstract.humanoid import Humanoid
from src.library.ai_modules.spacial_memory import PathMemory
from src.library.ais.peasant_ai import PeasantAi
from src.library.markup.house import House
from src.library.physical.peasant import peasant_attitude
from src.library.physical.player import Player


class Mother(Humanoid):
    character = 'L'
    color = ColorPair(blue)
    sex = "female"
    name = CompositeName(reserved_names["lilia"], reserved_names["kinds"]["female"])

    house: House

    def __post_init__(self):
        self.health = Health(50, armor_kind.none)
        self.weapon = Weapon(4, damage_kind.slashing)
        self.ai = PeasantAi()
        self.attitude = peasant_attitude()
        self.house = None

    def after_creation(self):
        self.ai.composite[PathMemory].knows(self.level)
        self.house = next(h for h in self.level.markup.houses if h.reserved_for == "kinds")
        self.attitude.relations[next(self.level.find(Player))] = Relation.Love
