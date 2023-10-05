import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.assets import names
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.output.colors import cyan, ColorPair
from src.entities.abstract.human import Human
from src.entities.ais.knight_ai import KnightAi
from src.entities.tiles.body import body_factory
from src.systems.ai import Kind, Senses


class Knight(Human):
    character = 'k'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __init__(self):
        self.name = "Sir " + random.choice(names["last"])
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.health = Health(70, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 100
