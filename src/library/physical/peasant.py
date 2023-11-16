import random

from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.attitude.implementation import common_attitude, Faction
from src.engine.language.library import first_names
from src.engine.language.name import CompositeName
from src.library.abstract.human import Human
from src.library.ais.peasant_ai import PeasantAi
from src.lib.vector import sub2, area2
from src.systems.ai import Senses


class Peasant(Human):
    character = 'p'
    house = None
    faction = Faction.Villagers

    def __post_init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = random.choice(first_names[self.sex])
        self.health = Health(random.randrange(10, 25) + (self.sex == "male" and 10 or 0), ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.senses = Senses(8, 0, 0)
        self.ai = PeasantAi()
        self.attitude = peasant_attitude()

    def after_load(self, level):
        if len(level.markup.houses) > 0:
            self.house, = random.choices(*zip(*(
                (h, area2(sub2(h.house_borders[1], h.house_borders[0])))
                for h in level.markup.houses
                if h.reserved_for is None
            )))

            self.name = CompositeName(self.name, self.house.family_names[self.sex])

        self.ai.composite[SpacialMemory].knows(level)


def peasant_attitude():
    result = common_attitude()
    result.relations[Faction.Villagers] = 50
    return result
