from ecs import OwnedEntity

from src.entities.ais.io import Colors


class WoodenFloor(OwnedEntity):
    name = 'Wooden floor'
    character = '_'
    color = Colors.Yellow
