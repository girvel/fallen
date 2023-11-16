from ecs import DynamicEntity

from src.engine.language.name import Name
from src.lib.toolkit import death_chance_from_half_life


class Footprint(DynamicEntity):
    name = Name("след")
    layer = "tiles"
    character = ","
    death_chance = death_chance_from_half_life(100)
    boring_flag = None
