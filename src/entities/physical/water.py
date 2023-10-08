from ecs import DynamicEntity

from src.engine.attitude.implementation import Faction
from src.engine.output.colors import blue, white, ColorPair


class Water(DynamicEntity):
    name = 'Water'
    character = '~'
    color = ColorPair(white, blue)
    layer = "physical"
    faction = Faction.Water
