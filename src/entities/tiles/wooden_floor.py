from ecs import OwnedEntity

from src.entities.special.io import Colors


class WoodenFloor(OwnedEntity):
    name = 'Wooden floor'
    character = '_'
    color = Colors.Yellow
