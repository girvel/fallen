import random
from pathlib import Path

import yaml
from ecs import OwnedEntity

from src.systems.acting.attack import Health, ArmorKind
from src.systems.ai import Kind

names = yaml.safe_load(Path("assets/names.yaml").read_text())


class Villager(OwnedEntity):
    character = 'v'
    vision = 8

    def __init__(self):
        self.sex = random.choice(["male", "female"])
        self.name = " ".join([random.choice(names["first"][self.sex]), random.choice(names["last"])])
        self.health = Health(random.randrange(10, 25) + (self.sex == "male" and 10 or 0), ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
