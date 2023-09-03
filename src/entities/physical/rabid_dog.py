import random

from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors
from src.entities.ais.rabid_ai import RabidAi
from src.lib.vector import map_grid
from src.systems.acting.damage import DamageKind, ArmorKind, Health, Weapon
from src.systems.ai import Kind, Senses


class RabidDog(OwnedEntity):
    name = 'Rabid dog'
    character = 'd'
    color = Colors.Magenta
    vision = 10

    spacial_memory = None

    def __init__(self):
        self.weapon = Weapon(3, DamageKind.Piercing)
        self.health = Health(20, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
        self.ai = RabidAi()
        self.senses = Senses(10, 0, 5)

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
