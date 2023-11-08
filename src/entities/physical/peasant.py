import random

from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.naming.library import random_composite_name, first_names
from src.engine.attitude.implementation import common_attitude, Faction
from src.engine.naming.name import CompositeName
from src.entities.abstract.human import Human
from src.entities.ais.peasant_ai import PeasantAi
from src.lib.vector import sub2, area2, map_grid
from src.systems.ai import Senses


class Peasant(Human):
    character = 'p'
    house = None
    faction = Faction.Villagers

    def __post_init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = random_composite_name(self.sex)
        self.health = Health(random.randrange(10, 25) + (self.sex == "male" and 10 or 0), ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.senses = Senses(8, 0, 0)
        self.ai = PeasantAi()
        self.attitude = common_attitude()
        self.attitude.relations[Faction.Villagers] = 50

    def after_load(self, level):
        if len(level.markup.houses) > 0:
            self.house, = random.choices(
                level.markup.houses,
                [area2(sub2(h.house_borders[1], h.house_borders[0])) for h in level.markup.houses]
            )
            self.name = CompositeName(random.choice(first_names[self.sex]), self.house.family_names[self.sex])

        self.ai.composite[SpacialMemory].knows(level)
        self.ai.favourite_zones = level.markup.zones
