from ecs import OwnedEntity

from src.entities.ais.io import Colors


class Fire(OwnedEntity):
    name = 'fire'
    character = '*'
    color = Colors.Red
