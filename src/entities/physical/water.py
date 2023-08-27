from ecs import OwnedEntity

from src.entities.ais.io import Colors


class Water(OwnedEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
