import random
from pathlib import Path

import yaml
from ecs import OwnedEntity

from src.entities.ais.peasant_ai import PeasantAi
from src.lib.vector import sub2, area2
from src.systems.acting.damage import Health, ArmorKind
from src.systems.ai import Kind, Senses

names = yaml.safe_load(Path("assets/names.yaml").read_text())


class Peasant(OwnedEntity):
    character = 'p'

    home = None
    senses = Senses(8, 0, 0)
    ai = PeasantAi()

    def __init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = " ".join([random.choice(names["first"][self.sex]), random.choice(names["last"])])
        self.health = Health(random.randrange(10, 25) + (self.sex == "male" and 10 or 0), ArmorKind.Organic)
        self.classifiers = {Kind.Animate}

    def after_load(self, markup):
        if len(markup.houses) > 0:
            self.home, = random.choices(markup.houses, [area2(sub2(h.end, h.start)) for h in markup.houses])
