import random

from src.assets.abstract.humanoid import Humanoid
from src.assets.ai_modules.spacial_memory import CharacterMemory, PathMemory
from src.assets.ais.peasant_ai import PeasantAi
from src.engine.ai import Senses
from src.engine.attitude.implementation import common_attitude, Faction, Relation
from src.engine.language.library import first_names
from src.engine.language.name import CompositeName
from src.lib.limited import Limited
from src.lib.vector.vector import sub2, area2


class Peasant(Humanoid):
    character = 'p'
    house = None
    faction = Faction.Villagers

    def __post_init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = random.choice(first_names[self.sex])
        self.health = Limited(random.randrange(10, 25) + (self.sex == "male" and 10 or 0) + 1)
        self.senses = Senses(8, 0, 0)
        self.ai = PeasantAi()
        self.attitude = peasant_attitude()

    def after_creation(self):
        if len(self.level.markup.houses) > 0:
            self.house, = random.choices(*zip(*(
                (h, area2(sub2(h.house_borders[1], h.house_borders[0])))
                for h in self.level.markup.houses
                if h.reserved_for is None
            )))

            self.name = CompositeName(self.name, self.house.family_names[self.sex])

        # self.ai.composite[CharacterMemory].knows(self.level)
        # self.ai.composite[PathMemory].knows(self.level)
        # TODO NEXT initialize memories


def peasant_attitude():
    result = common_attitude()
    result.relations[Faction.Villagers] = Relation.Normal
    return result
