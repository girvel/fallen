from ecs import OwnedEntity

from src.engine.io.colors import Colors


class Water(OwnedEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
