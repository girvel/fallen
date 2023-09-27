import random

from ecs import DynamicEntity

from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.assets import strange_names
from src.engine.attitude.implementation import Faction
from src.engine.traits import Traits
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid

from src.systems.ai import Kind, Senses


class Player(DynamicEntity):
    character = '@'

    ai = None  # set to IO on level loading
    act = None
    faction = None

    on_death = body_factory

    traits = Traits()

    def __init__(self):
        self.name = "Майк"
        self.weapon = Weapon(1, DamageKind.Crushing)
        self.health = Health(10, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(24, 40, 0)

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
        self.ai.connect_to_level(level)
