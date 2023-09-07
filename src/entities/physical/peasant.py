import random
from ecs import OwnedEntity

from src.engine.assets import names
from src.entities.ais.peasant_ai import PeasantAi
from src.lib.vector import sub2, area2, map_grid
from src.systems.acting.damage import Health, ArmorKind
from src.systems.ai import Kind, Senses


class Peasant(OwnedEntity):
    character = 'p'

    house = None

    def __init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = " ".join([random.choice(names["first"][self.sex]), random.choice(names["last"])])
        self.health = Health(random.randrange(10, 25) + (self.sex == "male" and 10 or 0), ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(8, 0, 0)
        self.ai = PeasantAi()

    def after_load(self, level):
        if len(level.markup.houses) > 0:
            self.house, = random.choices(
                level.markup.houses,
                [area2(sub2(h.house_borders[1], h.house_borders[0])) for h in level.markup.houses]
            )

        self.spacial_memory = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
        # TODO remove magic character
        self.ai.favourite_zones = level.markup.zones
