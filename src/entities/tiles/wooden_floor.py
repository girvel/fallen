from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors


class WoodenFloor(OwnedEntity):
    name = 'Wooden floor'
    character = '_'
    color = Colors.Yellow
