import random

from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Health, Weapon
from src.engine.ai import Senses
from src.engine.attitude.implementation import Faction, common_attitude, Relation
from src.engine.language.library import random_composite_name
from src.engine.output.colors import ColorPair, cyan
from src.library.abstract.humanoid import Humanoid


class Soldier(Humanoid):
    character = 's'
    color = ColorPair(cyan)
    faction = Faction.Church

    def __post_init__(self):
        self.sex = random.choices(["male", "female"], [85, 15])[0]
        self.name = random_composite_name(self.sex)
        self.health = Health(40, armor_kind.leather)
        self.weapon = Weapon(5, damage_kind.slashing)
        self.senses = Senses(16, 0, 0)
        self.ai = None

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = Relation.Normal
