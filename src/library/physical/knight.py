import random

from src.engine.acting.damage import Health, Weapon, armor_kinds, damage_kinds
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.output.colors import cyan, ColorPair
from src.library.abstract.human import Human
from src.library.ais.knight_ai import KnightAi
from src.engine.ai import Senses


class Knight(Human):
    character = 'k'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        raise NotImplementedError
        # self.name =
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.health = Health(70, armor_kinds["Steel"])
        self.weapon = Weapon(15, damage_kinds["Slashing"])
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = Constants.Normal
