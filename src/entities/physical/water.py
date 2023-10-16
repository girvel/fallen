from ecs import DynamicEntity

from src.engine.attitude.implementation import Faction
from src.engine.name import Name
from src.engine.output.colors import blue, white, ColorPair


class Water(DynamicEntity):
    name = Name("вода")
    character = '~'
    color = ColorPair(white, blue)
    layer = "physical"
    faction = Faction.Water
