import random

from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.output.colors import cyan, ColorPair
from src.assets.abstract.humanoid import Humanoid
from src.assets.ais.knight_ai import KnightAi
from src.engine.ai import Senses


class Knight(Humanoid):
    character = 'k'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        raise NotImplementedError
        # self.name =
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.health = Limited(71)
        self.damage_source = DamageSource(15, damage_kind.slashing)
        self.senses = Senses(18, 40, 0)
        self.ai = KnightAi()

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = Constants.Normal
