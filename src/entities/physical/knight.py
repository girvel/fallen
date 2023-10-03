import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.assets import names
from src.engine.output.colors import Colors
from src.engine.attitude.implementation import Faction, common_attitude
from src.entities.ais.knight_ai import KnightAi
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid

from src.systems.ai import Kind, Senses


class Knight(DynamicEntity):
    name = 'knight'
    character = 'k'
    color = Colors.Cyan

    faction = Faction.Church

    on_death = body_factory

    def __init__(self):
        self.name = "Sir " + random.choice(names["last"])
        self.sex = random.choices(["male", "female"], [85, 15])
        self.health = Health(70, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()
        self.spacial_memory = SpacialMemory()  # TODO move spacial_memory to AI

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 100
