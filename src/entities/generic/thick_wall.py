from ecs import OwnedEntity

from src.entities.special.screen import Colors


class ThickWall(OwnedEntity):
    name = 'thick_wall'
    character = '#'
    color = Colors.Yellow