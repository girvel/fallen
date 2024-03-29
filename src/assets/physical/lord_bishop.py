from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.attitude.implementation import Faction, common_attitude
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.assets.abstract.humanoid import Humanoid
from src.lib.limited import Limited


class LordBishop(Humanoid):
    name = Name("лорд-епископ")
    sex = "male"
    character = 'N'
    color = ColorPair(yellow)
    faction = Faction.Church

    def __post_init__(self):
        self.health = Limited(41)

        self.attitude = common_attitude()
        self.attitude.relations[Faction.Church] = 1000
