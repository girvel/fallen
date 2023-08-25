from ecs import OwnedEntity

from src.entities.special.screen import Colors


class ThickWall(OwnedEntity):
    character = '#'

    def __init__(self):
        super().__init__(name='thick_wall', color=Colors.Yellow)