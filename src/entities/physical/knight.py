import random

from ecs import OwnedEntity

from src.engine.assets import names
from src.entities.ais.iolib.colors import Colors
from src.entities.ais.knight_ai import KnightAi
from src.lib.vector import map_grid
from src.systems.acting.damage import Health, ArmorKind, Weapon, DamageKind
from src.systems.ai import Kind, Senses


class Knight(OwnedEntity):
    name = 'knight'
    character = 'k'
    color = Colors.Cyan

    def __init__(self):
        self.name = "Sir " + random.choice(names["last"])
        self.sex = random.choices(["male", "female"], [85, 15])
        self.health = Health(70, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
