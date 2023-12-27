from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Weapon, Health
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.assets.abstract.humanoid import Humanoid


class Kaledeii(Humanoid):
    name = Name("Каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        self.health = Health(80, armor_kind.steel)
        self.weapon = Weapon(15, damage_kind.slashing)

