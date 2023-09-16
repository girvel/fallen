import random
from collections import defaultdict

from ecs import OwnedEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.assets import names
from src.engine.io.colors import Colors
from src.engine.reputation import Faction
from src.entities.ais.knight_ai import KnightAi
from src.lib.vector import map_grid

from src.systems.ai import Kind, Senses


class Knight(OwnedEntity):
    name = 'knight'
    character = 'k'
    color = Colors.Cyan

    faction = Faction.Church

    def __init__(self):
        self.name = "Sir " + random.choice(names["last"])
        self.sex = random.choices(["male", "female"], [85, 15])
        self.health = Health(70, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()
        self.spacial_memory = None

        self.faction_relations = {"Predators": -100}
        self.personal_relations = {}

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda _: None)
        self.ai.follower.subject = level.player
