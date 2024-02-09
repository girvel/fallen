from src.assets.abstract.humanoid import Humanoid
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.lib.limited import Limited


class Kaledeii(Humanoid):
    name = Name("Каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __post_init__(self):
        self.health = Limited(81)

