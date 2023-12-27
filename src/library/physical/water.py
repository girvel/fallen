from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import blue, white, ColorPair
from src.library.abstract.material import Material


class Water(Material):
    name = Name.auto("вода")
    character = '~'
    color = ColorPair(white, blue)
    layer = "physical"
    faction = Faction.Water

    boring_flag = None
