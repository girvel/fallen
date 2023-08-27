from ecs import OwnedEntity

from src.entities.special.io import Colors


class Fire(OwnedEntity):
    name = 'fire'
    character = '*'
    color = Colors.Red
