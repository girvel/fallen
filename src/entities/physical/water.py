from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors


class Water(OwnedEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
