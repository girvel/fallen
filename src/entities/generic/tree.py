from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Tree(OwnedEntity):
    name = 'Tree'
    character = 'T'
    color = Colors.Green
    health = 100
