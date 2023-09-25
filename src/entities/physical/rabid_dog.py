from ecs import DynamicEntity

from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.output.colors import Colors
from src.engine.attitude.implementation import Faction
from src.entities.ais.rabid_ai import RabidAi
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid

from src.systems.ai import Kind, Senses


class RabidDog(DynamicEntity):
    name = 'Rabid dog'
    character = 'd'
    color = Colors.Magenta
    vision = 10

    faction = Faction.Predators
    spacial_memory = None

    on_death = body_factory

    def __init__(self):
        self.weapon = Weapon(3, DamageKind.Piercing)
        self.health = Health(20, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
        self.ai = RabidAi()
        self.senses = Senses(10, 0, 5)

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
