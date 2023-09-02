from ecs import OwnedEntity

from src.lib.vector import map_grid
from src.systems.acting.damage import DamageKind, ArmorKind, Weapon, Health
from src.systems.ai import Kind, Senses


class Player(OwnedEntity):
    name = 'Sir Aethan'
    character = '@'

    senses = Senses(24, 40, 1)
    ai = None  # set to IO on level loading

    def __init__(self):
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.health = Health(100, ArmorKind.Steel)
        self.classifiers = {Kind.Animate}

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
        self.ai.connect_to_level(level)
