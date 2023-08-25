from ecs import OwnedEntity

from src.entities.special.io import Colors


class Water(OwnedEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
