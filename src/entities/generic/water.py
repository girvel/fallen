from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Water(OwnedEntity):
    name = 'water'
    character = '~'
    color = Colors.WhiteOnBlue
