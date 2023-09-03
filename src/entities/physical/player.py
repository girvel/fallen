import random
from pathlib import Path

import yaml
from ecs import OwnedEntity

from src.lib.vector import map_grid
from src.systems.acting.damage import DamageKind, ArmorKind, Weapon, Health
from src.systems.ai import Kind, Senses

names = yaml.safe_load(Path("assets/strange_names.yaml").read_text())

class Player(OwnedEntity):
    character = '@'

    senses = Senses(24, 40, 1)
    ai = None  # set to IO on level loading
    act = None

    def __init__(self):
        self.name = "Sir " + " ".join(random.choice(collection) for collection in names)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.health = Health(100, ArmorKind.Steel)
        self.classifiers = {Kind.Animate}

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
        self.ai.connect_to_level(level)
