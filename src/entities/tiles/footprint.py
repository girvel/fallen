from ecs import DynamicEntity

from src.lib.toolkit import death_chance_from_half_life


class Footprint(DynamicEntity):
    name = "Footprint"
    layer = "tiles"
    character = ","
    death_chance = death_chance_from_half_life(100)
