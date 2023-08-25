from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Water(OwnedEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
