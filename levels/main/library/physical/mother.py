from ecs import Entity

from src.engine.acting.damage import Health, Weapon, armor_kinds, damage_kinds
from src.engine.attitude.implementation import Constants
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, blue
from src.library.abstract.human import Human
from src.library.ais.peasant_ai import PeasantAi
from src.library.physical.peasant import peasant_attitude
from src.library.physical.player import Player


class Mother(Human):
    character = 'L'
    color = ColorPair(blue)
    sex = "female"
    name = CompositeName(reserved_names["lilia"], reserved_names["kinds"]["female"])

    def __post_init__(self, **attributes):
        self.health = Health(50, armor_kinds["Organic"])
        self.weapon = Weapon(4, damage_kinds["Slashing"])
        self.ai = PeasantAi()
        self.attitude = peasant_attitude()

        Entity.__init__(self, **attributes)

    def after_load(self, level):
        self.ai.composite[SpacialMemory].knows(level)
        self.house = next(h for h in level.markup.houses if h.reserved_for == "kinds")
        self.attitude.relations[next(level.find(Player))] = Constants.Love
