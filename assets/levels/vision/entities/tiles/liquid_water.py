from ecs import DynamicEntity

from src.engine.attitude.implementation import Faction
from src.engine.name import Name
from src.engine.output.colors import ColorPair, blue


class LiquidWater(DynamicEntity):
    name = Name("Вода")
    character = '~'
    color = ColorPair(blue)
    liquid_height = 10
    layer = "tiles"
    faction = Faction.Water
